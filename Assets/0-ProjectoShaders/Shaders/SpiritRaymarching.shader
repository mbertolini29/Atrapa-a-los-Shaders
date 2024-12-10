Shader "Custom/SpiritRaymarching"
{
    Properties
    {
        _MainColor ("Spirit Color", Color) = (0.5, 0.8, 1.0, 0.5)
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
            float _GlowIntensity;
            float _SpiritSize;
            float _WobbleSpeed;
            float _WobbleAmount;

            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define SURF_DIST 0.001

            // Signed Distance Function for a sphere with wobble effect
            float sdSphere(float3 p, float radius)
            {
                float wobble = sin(_Time.y * _WobbleSpeed) * _WobbleAmount;
                p.y += wobble * p.x;
                p.x += wobble * p.z;
                return length(p) - radius * _SpiritSize;
            }

            float GetDist(float3 p)
            {
                float d = sdSphere(p, 0.5);
                return d;
            }

            float RayMarch(float3 ro, float3 rd)
            {
                float dO = 0;
                float dS;
                
                for(int i = 0; i < MAX_STEPS; i++)
                {
                    float3 p = ro + rd * dO;
                    dS = GetDist(p);
                    dO += dS;
                    if(dS < SURF_DIST || dO > MAX_DIST) break;
                }
                
                return dO;
            }

            float3 GetNormal(float3 p)
            {
                float2 e = float2(0.01, 0);
                float3 n = GetDist(p) - float3(
                    GetDist(p - e.xyy),
                    GetDist(p - e.yxy),
                    GetDist(p - e.yyx)
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
                    
                    // Basic lighting
                    float3 lightDir = normalize(float3(1, 1, -1));
                    float diff = dot(n, lightDir) * 0.5 + 0.5;
                    
                    // Fresnel effect
                    float fresnel = pow(1 - dot(n, -rd), 2);
                    
                    // Combine effects
                    col.rgb = _MainColor.rgb * diff;
                    col.rgb += fresnel * _MainColor.rgb * _GlowIntensity;
                    
                    // Fade based on distance from center
                    float fade = 1 - length(p) / _SpiritSize;
                    col.a = saturate(fade * _MainColor.a);
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
