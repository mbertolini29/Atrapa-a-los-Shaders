Shader "Custom/CircleVariationsPattern"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScaleX ("Scale X", Range(0.1, 5.0)) = 1.0
        _ScaleY ("Scale Y", Range(0.1, 5.0)) = 1.0
        _GlobalScale ("Global Scale", Range(0.1, 5.0)) = 1.0
        _WaveSpeed ("Wave Speed", Range(0.1, 20.0)) = 1.0
        _RadialFreq ("Radial Frequency", Range(1.0, 300.0)) = 200.0
        _AngularFreq ("Angular Frequency", Range(0.0, 10.0)) = 10.0
        _WaveAmplitude ("Wave Amplitude", Range(0.001, 0.1)) = 0.08
        _PatternType ("Pattern Type", Range(0, 2)) = 0 // 0: Normal, 1: Radial, 2: Angular
        _BorderWidth ("Border Width", Range(0.001, 0.1)) = 0.02
        _BorderColor ("Border Color", Color) = (1,1,1,1)
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
            float _ScaleX;
            float _ScaleY;
            float _GlobalScale;
            float _WaveSpeed;
            float _RadialFreq;
            float _AngularFreq;
            float _WaveAmplitude;
            float _PatternType;
            float _BorderWidth;
            float4 _BorderColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Centrar las coordenadas UV
                float2 uv = i.uv - 0.5;
                
                // Aplicar escala X e Y
                uv.x *= _ScaleX;
                uv.y *= _ScaleY;
                
                // Aplicar escala global
                uv *= _GlobalScale;
                
                // Calcular radio y ángulo desde el centro
                float radio = length(uv);
                float angulo = atan2(uv.x, uv.y);
                
                float forma = 0;
                
                if (_PatternType < 1)
                {
                    // Patrón principal con giros
                    forma = sin(angulo * _AngularFreq + _Time.y * _WaveSpeed) * _WaveAmplitude *
                           sin(radio * _RadialFreq + _Time.y * _WaveSpeed);
                }
                else if (_PatternType < 2)
                {
                    // Patrón radial (círculos)
                    forma = sin(radio * 3.0 - _Time.y * _WaveSpeed) * _WaveAmplitude;
                }
                else
                {
                    // Patrón angular (triángulos/líneas)
                    forma = sin(angulo * 3.0 - _Time.y * _WaveSpeed) * _WaveAmplitude;
                }
                
                // Suavizar el borde
                float suavizarBorde = smoothstep(0.88, 0.9, (1.0 - radio) + forma);
                
                // Crear el marco
                float2 bordeUV = abs(i.uv * 2.0 - 1.0);
                float borde = step(max(bordeUV.x, bordeUV.y), 1.0 - _BorderWidth);
                float lineaBorde = step(1.0 - _BorderWidth, max(bordeUV.x, bordeUV.y)) * step(max(bordeUV.x, bordeUV.y), 1.0);
                
                // Combinar el patrón con el marco
                float3 colorFinal = suavizarBorde;
                colorFinal = lerp(colorFinal, _BorderColor.rgb, lineaBorde);
                
                return float4(colorFinal, 1.0);
            }
            ENDCG
        }
    }
}
