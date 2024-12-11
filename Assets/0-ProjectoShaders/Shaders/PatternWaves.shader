Shader "Custom/PatternWaves"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            #define PI 3.14159265359

            float3 GetColor(float red, float green, float blue)
            {
                return float3(red, green, blue);
            }

            float getFrq(float num)
            {
                return num * PI;
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
                float2 uv = i.uv;
                float time = _Time.y;
                
                float3 color1 = GetColor(1.0, 0.0, 1.0);
                float3 color2 = GetColor(0.0, 0.0, 0.0);
                
                float forma1 = sin(uv.x * getFrq(25.) + time
                             + sin(uv.y * getFrq(10.) + time
                             + sin(uv.y * getFrq(2.) - time
                             )))
                             * 0.5 + 0.5;
                             
                float forma2 = sin(uv.y * getFrq(10.) - time 
                             + sin(uv.x * getFrq(20.) - time
                             + sin(uv.x * getFrq(15.) + time
                             )))
                             * 0.5 + 0.5;
                
                float mixForma = sin(forma1 * forma2 * 10.0 + time);
                
                return float4(mixForma.xxx, 1.0);
            }
            ENDCG
        }
    }
}
