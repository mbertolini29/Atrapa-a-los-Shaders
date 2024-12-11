Shader "Custom/CircularPattern"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Animation Speed", Range(0.1, 5.0)) = 1.0
        _Frequency ("Pattern Frequency", Range(1.0, 10.0)) = 3.0
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
            float _Speed;
            float _Frequency;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Obtener coordenadas UV y centrarlas
                float2 uv = i.uv;
                float2 p = float2(0.5, 0.5) - uv;
                
                // Calcular radio y ángulo
                float r = length(p);
                float a = atan2(p.x, p.y);
                
                // Crear el patrón angular animado
                float3 formarAngulo = sin(a * _Frequency - _Time.y * _Speed);
                
                return float4(formarAngulo, 1.0);
            }
            ENDCG
        }
    }
}
