Shader "Unlit/CirculoColor"
{   Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScaleX ("Scale X", Range(0.1, 5.0)) = 1.0
        _ScaleY ("Scale Y", Range(0.1, 5.0)) = 1.0
        _GlobalScale ("Global Scale", Range(0.1, 5.0)) = 1.0
        _WaveSpeed ("Wave Speed", Range(0.1, 20.0)) = 1.0
        _RadialFreq ("Radial Frequency", Range(1.0, 300.0)) = 200.0
        _AngularFreq ("Angular Frequency", Range(0.0, 10.0)) = 6.0
        _WaveAmplitude ("Wave Amplitude", Range(0.001, 0.1)) = 0.025        
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
                // Obtener coordenadas UV
                float2 uv = i.uv - 0.5;
                
                // Aplicar escala X e Y
                uv.x *= _ScaleX;
                uv.y *= _ScaleY;
                
                // Aplicar escala global
                uv *= _GlobalScale;

                // Arreglar el aspecto
                float2 resolution = _ScreenParams.xy;
                float fix = resolution.x / resolution.y;
                uv.x *= fix;
                
                // Crear punto central y calcular radio y ángulo
                //float2 punto = float2(_CenterX * fix, 0.5) - uv;
                float radio = length(uv);
                float angulo = atan2(uv.x, uv.y);
                
                // Crear la forma animada
                float forma = sin(radio * _RadialFreq + _Time * _WaveSpeed * 10.0) 
                             * _WaveAmplitude;

                // Suavizar el borde
                float suavizarBorde = smoothstep(0.88, 0.9, (1.0 - radio) + forma);                      
                      suavizarBorde -= smoothstep(0.9, 0.92, (1.0 - radio) + forma);

                // Combinar el patrón con el marco
                float3 colorFinal = suavizarBorde;
                colorFinal = colorFinal * _BorderColor.rgb;

                return float4(colorFinal, 1.0);
            }
            ENDCG
        }
    }
}
