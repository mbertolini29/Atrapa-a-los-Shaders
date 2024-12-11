Shader "Custom/CircleWavePattern"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CenterX ("Center X", Range(0.0, 1.0)) = 0.65
        _WaveSpeed ("Wave Speed", Range(0.1, 20.0)) = 1.0
        _RadialFreq ("Radial Frequency", Range(1.0, 300.0)) = 200.0
        _AngularFreq ("Angular Frequency", Range(0.0, 10.0)) = 6.0
        _WaveAmplitude ("Wave Amplitude", Range(0.001, 0.1)) = 0.025
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
            float _CenterX;
            float _WaveSpeed;
            float _RadialFreq;
            float _AngularFreq;
            float _WaveAmplitude;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Obtener coordenadas UV
                float2 uv = i.uv;
                
                // Arreglar el aspecto
                float2 resolution = _ScreenParams.xy;
                float fix = resolution.x / resolution.y;
                uv.x *= fix;
                
                // Crear punto central y calcular radio y ángulo
                float2 punto = float2(_CenterX * fix, 0.5) - uv;
                float radio = length(punto);
                float angulo = atan2(punto.x, punto.y);
                
                // Crear la forma animada
                float forma = sin(angulo * _AngularFreq + _Time.y * _WaveSpeed +
                             sin(radio * _RadialFreq + _Time.y * _WaveSpeed * 10.0)) 
                             * _WaveAmplitude;
                
                // Suavizar el borde
                float suavizarBorde = smoothstep(0.88, 0.9, (1.0 - radio) + forma);
                
                return float4(suavizarBorde.xxx, 1.0);
            }
            ENDCG
        }
    }
}
