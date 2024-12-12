Shader "Custom/ThinSpiritRaymarching"
{
    
    Properties
    {
        _MainColor ("Spirit Color", Color) = (0.5, 0.8, 1.0, 0.5)
        _EyeColor ("Eye Color", Color) = (1.0, 0.0, 0.0, 1.0)
        _GlowIntensity ("Glow Intensity", Range(0, 2)) = 1.0
        _SpiritSize ("Spirit Size", Range(0.1, 2)) = 1.0
        _WobbleSpeed ("Wobble Speed", Range(0, 5)) = 1.0
        _WobbleAmount ("Wobble Amount", Range(0, 1)) = 0.1
        _TaperAmount ("Taper Amount", Range(0, 1)) = 0.7    // Controla qué tan fino es en la parte inferior
        _AscendSpeed ("Ascend Speed", Range(0, 2)) = 0.5    // Velocidad de ascenso
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
            float _TaperAmount;
            float _AscendSpeed;

            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define SURF_DIST 0.001

            float smin(float a, float b, float k)
            {
                float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
                return lerp(b, a, h) - k * h * (1.0 - h);
            }

            float sdSphere(float3 p, float radius)
            {
                return length(p) - radius;
            }

            // Función modificada para crear una forma más cónica/estilizada
            float sdTaperedShape(float3 p, float height, float baseRadius, float topRadius)
            {
                float2 q = float2(length(p.xz), p.y);
                
                // Calcular el radio en función de la altura (forma cónica)
                float radius = lerp(baseRadius, topRadius, (q.y + height/2) / height);
                
                // Suavizar los extremos
                radius *= smoothstep(0, 0.1, height/2 - abs(q.y));
                
                return length(float2(q.x, max(abs(q.y) - height/2, 0.0))) - radius;
            }

            float2 sdGhost(float3 p)
            {
                // Efecto de ascenso
                float ascend = _Time.y * _AscendSpeed;
                p.y -= ascend;

                float t = _Time.y * _WobbleSpeed;
                
                // Wobble más suave y etéreo
                float wobble = sin(t + p.y * 2.0) * _WobbleAmount;
                p.x += wobble * smoothstep(-1, 1, p.y);  // El wobble es más pronunciado en el centro
                
                // Forma principal estilizada y afinada hacia abajo
                float height = 1.0 * _SpiritSize;
                float baseRadius = 0.1 * _SpiritSize * (1.0 - _TaperAmount);  // Radio más pequeño en la base
                float topRadius = 0.4 * _SpiritSize;     // Radio más grande en la parte superior
                
                float body = sdTaperedShape(p, height, baseRadius, topRadius);
                
                // Agregar una forma más redondeada en la parte superior
                float topSphere = sdSphere(p - float3(0, height/3, 0), topRadius * 0.8);
                body = smin(body, topSphere, 0.2);
                
                // Ojos
                float3 eyeOffset = float3(0.15, height/4, 0.2) * _SpiritSize;
                float leftEye = sdSphere(p + eyeOffset, 0.08 * _SpiritSize);
                float rightEye = sdSphere(p + float3(-eyeOffset.x, eyeOffset.y, eyeOffset.z), 0.08 * _SpiritSize);
                float eyes = min(leftEye, rightEye);
                
                // Agregar ondulación vertical suave
                body += sin(p.y * 8.0 + t) * 0.02 * _WobbleAmount;
                
                return float2(body, eyes < body ? 1 : 0);
            }

            float2 GetDist(float3 p)
            {
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
                    
                    float3 lightDir = normalize(float3(1, 1, -1));
                    float diff = dot(n, lightDir) * 0.5 + 0.5;
                    
                    float fresnel = pow(1 - dot(n, -rd), 3.0);
                    
                    // Color base
                    if(GetDist(p).y == 0)
                    {
                        col.rgb = _MainColor.rgb * diff;
                        
                        // Gradiente vertical para hacer más transparente la parte inferior
                        float verticalGradient = smoothstep(-0.5, 0.5, p.y);
                        col.a = _MainColor.a * verticalGradient;
                    }
                    else
                    {
                        col.rgb = _EyeColor.rgb;
                        col.a = 1.0;
                    }
                    
                    // Efecto de brillo interno
                    float innerGlow = exp(-length(p) * 2.0) * _GlowIntensity;
                    col.rgb += _MainColor.rgb * innerGlow;
                    
                    // Efecto de borde fantasmal
                    col.rgb += fresnel * _MainColor.rgb * _GlowIntensity;
                    
                    // Fade desde el centro
                    float fade = 1 - length(p) / (_SpiritSize * 1.5);
                    col.a *= saturate(fade);
                    
                    // Hacer más transparente la parte inferior
                    col.a *= smoothstep(-1, 0.5, p.y);
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
