Shader "Custom/HollowSpiritRaymarching"
{
    Properties
    {
        _MainColor ("Spirit Color", Color) = (0.02, 0.02, 0.02, 0.95)
        _EyeColor ("Eye Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _ParticleColor ("Particle Color", Color) = (0.3, 0.3, 0.3, 0.7)
        _GlowIntensity ("Glow Intensity", Range(0, 2)) = 1.2
        _SpiritSize ("Spirit Size", Range(0.1, 2)) = 0.5
        _HeadSize ("Head Size", Range(0.1, 2)) = 1.2
        _HornLength ("Horn Length", Range(0, 1)) = 0.2
        _EarSize ("Ear Size", Range(0, 1)) = 0.3
        _EarAngle ("Ear Angle", Range(0, 90)) = 30
        _WobbleSpeed ("Wobble Speed", Range(0, 5)) = 1.2
        _WobbleAmount ("Wobble Amount", Range(0, 1)) = 0.05
        _ParticleSpeed ("Particle Speed", Range(0, 5)) = 1.0
        _ParticleAmount ("Particle Amount", Range(0, 20)) = 12.0
        _TatterAmount ("Tatter Amount", Range(1, 10)) = 5
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define SURF_DIST 0.001

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 ro : TEXCOORD1;
                float3 hitPos : TEXCOORD2;
                float3 normal : TEXCOORD3;
            };

            float4 _MainColor;
            float4 _EyeColor;
            float4 _ParticleColor;
            float _GlowIntensity;
            float _SpiritSize;
            float _HeadSize;
            float _HornLength;
            float _EarSize;
            float _EarAngle;
            float _WobbleSpeed;
            float _WobbleAmount;
            float _ParticleSpeed;
            float _ParticleAmount;
            float _TatterAmount;

            float sdSphere(float3 p, float r)
            {
                return length(p) - r;
            }

            float sdEllipsoid(float3 p, float3 r)
            {
                float k0 = length(p/r);
                float k1 = length(p/(r*r));
                return k0*(k0-1.0)/k1;
            }

            float smin(float a, float b, float k)
            {
                float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
                return lerp(b, a, h) - k * h * (1.0 - h);
            }

            float hash31(float3 p3)
            {
                p3 = frac(p3 * float3(.1031, .1030, .0973));
                p3 += dot(p3, p3.yxz + 33.33);
                return frac((p3.x + p3.y) * p3.z);
            }

            float sdParticles(float3 p)
            {
                float particles = 1000;
                
                for(int i = 0; i < _ParticleAmount; i++)
                {
                    float t = _Time.y * _ParticleSpeed;
                    float offset = hash31(float3(i, i*2, i*3)) * 6.28;
                    float speed = 1.0 + hash31(float3(i*2, i, i*4)) * 0.5;
                    
                    // Posición de la partícula
                    float radius = (0.2 + hash31(float3(i*3, i, i*2)) * 0.1) * _SpiritSize;
                    float height = (-0.2 + hash31(float3(i, i*4, i*2)) * 0.4) * _SpiritSize;
                    
                    float3 center = float3(
                        sin(t * speed + offset) * radius,
                        height + sin(t * 0.5 + offset) * 0.1,
                        cos(t * speed * 0.7 + offset) * radius
                    );
                    
                    // Tamaño variable de partículas
                    float size = (0.01 + hash31(float3(i*4, i*2, i)) * 0.015) * _SpiritSize;
                    float particleDist = length(p - center) - size;
                    
                    particles = min(particles, particleDist);
                }
                
                return particles;
            }

            float sdEars(float3 p, float3 headCenter, float headSize)
            {
                // Convertir el ángulo a radianes
                float angleRad = radians(_EarAngle);
                
                // Posición base de las orejas
                float earOffset = headSize * 0.15;
                float earHeight = headSize * 0.1;
                
                float3 rightEarBase = headCenter + float3(earOffset, earHeight, 0);
                float3 leftEarBase = headCenter + float3(-earOffset, earHeight, 0);
                
                // Crear orejas usando elipsoides alargados
                float3 rightEarCenter = rightEarBase + float3(0.1, 0.15, 0) * _SpiritSize;
                float3 leftEarCenter = leftEarBase + float3(-0.1, 0.15, 0) * _SpiritSize;
                
                // Tamaños diferentes para cada dimensión del elipsoide
                float3 earScale = float3(0.15, 0.25, 0.1) * _SpiritSize * _EarSize;
                
                // Rotar los puntos para las orejas inclinadas
                float3 pRight = p - rightEarCenter;
                float3 pLeft = p - leftEarCenter;
                
                // Matriz de rotación para las orejas
                float3x3 rotRight = float3x3(
                    cos(angleRad), -sin(angleRad), 0,
                    sin(angleRad), cos(angleRad), 0,
                    0, 0, 1
                );
                
                float3x3 rotLeft = float3x3(
                    cos(-angleRad), -sin(-angleRad), 0,
                    sin(-angleRad), cos(-angleRad), 0,
                    0, 0, 1
                );
                
                // Aplicar rotación
                pRight = mul(rotRight, pRight);
                pLeft = mul(rotLeft, pLeft);
                
                // Calcular SDF para cada oreja usando elipsoides
                float rightEar = sdEllipsoid(pRight, earScale);
                float leftEar = sdEllipsoid(pLeft, earScale);
                
                // Combinar las orejas con una unión suave
                return smin(rightEar, leftEar, 0.1 * _SpiritSize);
            }

            float2 sdGhost(float3 p)
            {
                float t = _Time.y * _WobbleSpeed;
                
                // Movimiento básico
                p.y += sin(t * 0.5) * 0.05;
                p.x += sin(t + p.y * 2.0) * _WobbleAmount;
                p.z += cos(t * 1.1 + p.y * 2.0) * _WobbleAmount;

                // Posición de la cabeza
                float3 headCenter = float3(0, 0.15, 0) * _SpiritSize;
                float3 headScale = float3(0.12, 0.15, 0.12) * _SpiritSize * _HeadSize;
                
                // Forma básica del fantasma
                float head = sdEllipsoid(p - headCenter, headScale);
                float body = sdEllipsoid(p - float3(0, -0.15, 0) * _SpiritSize, 
                    float3(0.08, 0.2, 0.08) * _SpiritSize);

                // Agregar orejas
                float ears = sdEars(p, headCenter, headScale.x);
                
                // Combinar formas
                float ghost = smin(head, body, 0.1 * _SpiritSize);
                ghost = smin(ghost, ears, 0.08 * _SpiritSize);

                // Ojos
                float3 eyeOffset = float3(0.06, 0.2, 0.08) * _SpiritSize * _HeadSize;
                float eyeSize = 0.02 * _SpiritSize;
                float leftEye = sdSphere(p - float3(eyeOffset.x, eyeOffset.y, eyeOffset.z), eyeSize);
                float rightEye = sdSphere(p - float3(-eyeOffset.x, eyeOffset.y, eyeOffset.z), eyeSize);
                float eyes = min(leftEye, rightEye);

                // Agregar partículas
                float particles = sdParticles(p);

                // Determinar el material (0: cuerpo, 1: ojos, 2: partículas)
                float material = 0;
                if (eyes < ghost) material = 1;
                if (particles < ghost && particles < eyes) material = 2;

                return float2(min(min(ghost, eyes), particles), material);
            }

            float3 GetNormal(float3 p)
            {
                float2 e = float2(1e-3, 0);
                float3 n = sdGhost(p).x - float3(
                    sdGhost(p - e.xyy).x,
                    sdGhost(p - e.yxy).x,
                    sdGhost(p - e.yyx).x
                );
                return normalize(n);
            }

            float RayMarch(float3 ro, float3 rd)
            {
                float dO = 0;
                float dS;
                
                for(int i = 0; i < MAX_STEPS; i++)
                {
                    float3 p = ro + rd * dO;
                    dS = sdGhost(p).x;
                    dO += dS;
                    if(dS < SURF_DIST || dO > MAX_DIST) break;
                }
                
                return dO;
            }

            v2f vert(appdata v)
            {
                v2f o;
                
                // Posición del vértice en espacio de clip
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                
                // Posición del vértice en espacio mundial
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                // Origen del rayo (posición de la cámara en espacio de objeto)
                float3 worldCameraPos = _WorldSpaceCameraPos;
                o.ro = mul(unity_WorldToObject, float4(worldCameraPos, 1)).xyz;
                
                // Posición del hit en espacio de objeto
                o.hitPos = v.vertex.xyz;
                
                // Normal en espacio mundial
                o.normal = UnityObjectToWorldNormal(v.normal);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Dirección del rayo en espacio de objeto
                float3 rd = normalize(i.hitPos - i.ro);
                
                // Raymarching
                float d = RayMarch(i.ro, rd);
                
                // Color inicial
                fixed4 col = 0;

                if(d < MAX_DIST)
                {
                    // Punto de intersección
                    float3 p = i.ro + rd * d;
                    
                    // Normal y luz
                    float3 n = GetNormal(p);
                    float3 l = normalize(float3(1,2,-1));
                    float diff = dot(n, l) * 0.5 + 0.5;
                    
                    // Material
                    float2 mat = sdGhost(p);
                    
                    if(mat.y == 1) // Ojos
                    {
                        col.rgb = _EyeColor.rgb;
                        col.a = 1;
                    }
                    else if(mat.y == 2) // Partículas
                    {
                        col.rgb = _ParticleColor.rgb;
                        col.a = _ParticleColor.a * 0.7;
                        
                        // Efecto de brillo para partículas
                        float glow = exp(-length(p) * 2.0);
                        col.rgb += glow * _ParticleColor.rgb * _GlowIntensity * 0.3;
                    }
                    else // Cuerpo
                    {
                        col.rgb = _MainColor.rgb * diff;
                        col.a = _MainColor.a;
                        
                        // Efecto fresnel
                        float fresnel = pow(1 - dot(n, -rd), 3);
                        col.rgb += fresnel * _MainColor.rgb * _GlowIntensity * 0.2;
                    }
                }
                
                return col;
            }
            ENDCG
        }
    }
}
