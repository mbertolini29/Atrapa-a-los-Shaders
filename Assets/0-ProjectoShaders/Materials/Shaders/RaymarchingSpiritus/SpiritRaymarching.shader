Shader "Custom/SpiritRaymarching"
{
    Properties
    {
        _MainColor ("Spirit Color", Color) = (0.5, 0.8, 1.0, 0.5)
        _EyeColor ("Eye Color", Color) = (1.0, 0.0, 0.0, 1.0)
        _GlowIntensity ("Glow Intensity", Range(0, 2)) = 1.0
        _SpiritSize ("Spirit Size", Range(0.1, 2)) = 1.0
        _WobbleSpeed ("Wobble Speed", Range(0, 5)) = 1.0
        _WobbleAmount ("Wobble Amount", Range(0, 1)) = 0.1
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 rayOrigin : TEXCOORD1;
                float3 hitPos : TEXCOORD2;
            };

            float4 _MainColor;
            float4 _EyeColor;
            float _GlowIntensity;
            float _SpiritSize;
            float _WobbleSpeed;
            float _WobbleAmount;

            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define SURF_DIST 0.001

            // Operaciones SDF
            float smin(float a, float b, float k) {
                float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
                return lerp(b, a, h) - k * h * (1.0 - h);
            }

            float sdSphere(float3 p, float radius) {
                return length(p) - radius;
            }

            float sdEllipsoid(float3 p, float3 r) {
                float k0 = length(p/r);
                float k1 = length(p/(r*r));
                return k0*(k0-1.0)/k1;
            }

            float2 sdGhost(float3 p) {
                // Tiempo para animación
                float t = _Time.y * _WobbleSpeed;
                
                // Wobble effect
                float wobble = sin(t + p.y * 5.0) * _WobbleAmount;
                p.x += wobble;
                
                // Cuerpo principal (forma de gota alargada)
                float3 bodyPos = p;
                bodyPos.y += 0.2; // Ajustar posición vertical
                float3 bodyScale = float3(0.45, 0.75, 0.5) * _SpiritSize;
                float body = sdEllipsoid(bodyPos, bodyScale);
                
                // Parte inferior ondulante
                float bottomWave = sin(p.x * 4.0 + t) * 0.1;
                float bottom = sdEllipsoid(float3(p.x, p.y + 0.5 + bottomWave, p.z), 
                                           float3(0.4, 0.3, 0.4) * _SpiritSize);
                
                // Combinar cuerpo y parte inferior
                float ghost = smin(body, bottom, 0.2);
                
                // Ojos
                float3 eyeOffset = float3(0.15, 0.32, 0.3) * _SpiritSize;
                float leftEye = sdSphere(p + eyeOffset, 0.08);
                float rightEye = sdSphere(p + float3(-eyeOffset.x, eyeOffset.y, eyeOffset.z), 0.08);
                float eyes = min(leftEye, rightEye);
                
                // Retornar distancia y ID material (0 para cuerpo, 1 para ojos)
                return float2(ghost, eyes < ghost ? 1 : 0);
            }

            float2 GetDist(float3 p) {
                return sdGhost(p);
            }

            float RayMarch(float3 ro, float3 rd)
            {
                float dO = 0;
                float dS;
                
                for(int i = 0; i < MAX_STEPS; i++)
                {
                    float3 p = ro + rd * dO;
                    dS = GetDist(p).x;
                    dO += dS;
                    if(dS < SURF_DIST || dO > MAX_DIST) break;
                }
                
                return dO;
            }

            float3 GetNormal(float3 p)
            {
                float2 e = float2(0.01, 0);
                float3 n = GetDist(p).x - float3(
                    GetDist(p - e.xyy).x,
                    GetDist(p - e.yxy).x,
                    GetDist(p - e.yyx).x
                );
                return normalize(n);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                
                // Transform ray origin and hit position to object space
                float3 worldVertex = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.rayOrigin = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1)).xyz;
                o.hitPos = v.vertex.xyz;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 ro = i.rayOrigin;
                float3 rd = normalize(i.hitPos - ro);

                float d = RayMarch(ro, rd);
                fixed4 col = 0;

                if(d < MAX_DIST)
                {
                    float3 p = ro + rd * d;
                    float3 n = GetNormal(p);
                    
                    // Lighting
                    float3 lightDir = normalize(float3(1, 1, -1));
                    float diff = dot(n, lightDir) * 0.5 + 0.5;
                    
                    // Fresnel
                    float fresnel = pow(1 - dot(n, -rd), 3.0);
                    
                    // Color base
                    if(GetDist(p).y == 0)
                        col.rgb = _MainColor.rgb * diff;
                    else
                        col.rgb = _EyeColor.rgb;
                    
                    // Efecto de brillo interno
                    float innerGlow = exp(-length(p) * 2.0) * _GlowIntensity;
                    col.rgb += _MainColor.rgb * innerGlow;
                    
                    // Fresnel effect
                    col.rgb += fresnel * _MainColor.rgb * _GlowIntensity;
                    
                    // Fade from center
                    float fade = 1 - length(p) / (_SpiritSize * 1.5);
                    col.a = saturate(fade * _MainColor.a);
                    
                    // Add some ethereal glow
                    col.rgb += _MainColor.rgb * pow(fresnel, 2.0) * 0.5;
                }
                else
                {
                    discard;
                }

                return col;
            }

            ENDCG
        }
    }
}
