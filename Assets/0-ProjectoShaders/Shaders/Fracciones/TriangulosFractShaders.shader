Shader "Unlit/SphereBlueShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RepeatFactor ("Repeat Factor", Float) = 5
        _Speed ("Animation Speed", Float) = 0.25
        _Size ("Triangle Size", Range(0, 0.5)) = 0.1
        _Diffuse ("Edge Softness", Range(0, 0.5)) = 0.1
        _Sides ("Polygon Sides", Int) = 3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _RepeatFactor;
            float _Speed;
            float _Size;
            float _Diffuse;
            int _Sides;

            #define PI 3.14159265359
            #define TWO_PI (PI * 2.0)

            float poly(float2 uv, float2 p, float s, float dif, int N, float a)
            {
                float2 st = p - uv;
                float a2 = atan2(st.x, st.y) + a;
                float r = TWO_PI / float(N);
                float d = cos(floor(0.5 + a2 / r) * r - a2) * length(st);
                float e = 1.0 - smoothstep(s, s + dif, d);
                return e;
            }

            float3 MainF(float2 UV, float Time)
            {
                UV = frac(UV * _RepeatFactor + Time * _Speed);
                float e = poly(UV, float2(0.5, 0.5), _Size, _Diffuse, _Sides, Time);
                return float3(e, e, e);
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float3 result = MainF(i.uv, _Time.y);
                return float4(result, 1);
            }
            ENDCG
        }
    }
}