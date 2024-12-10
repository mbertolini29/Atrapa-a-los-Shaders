Shader "Custom/KodeLifePattern"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale ("Scale", Range(0.1, 2.0)) = 1.0
        _PulseSpeed ("Pulse Speed", Range(0.1, 5.0)) = 1.0
        _MinSize ("Min Size", Range(0.1, 1.0)) = 0.1
        _MaxSize ("Max Size", Range(1.0, 5.0)) = 2.0
        _BorderThickness ("Border Thickness", Range(0.001, 0.1)) = 0.02
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
            float _Scale;
            float _PulseSpeed;
            float _MinSize;
            float _MaxSize;
            float _BorderThickness;
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
                // Usar directamente las coordenadas UV
                float2 uv = i.uv;
                
                // Calcular la escala pulsante
                float pulseScale = lerp(_MinSize, _MaxSize, (sin(_Time.y * _PulseSpeed) * 0.5 + 0.5));
                
                // Mantener el aspecto pero ajustando la escala
                float2 resolution = _ScreenParams.xy;
                float fix = (resolution.x / resolution.y) * _Scale;
                uv.x *= fix;
                
                // Punto central y cálculos (usando UV directamente)
                float2 punto = float2(0.5 * fix, 0.5) - uv;
                float radio = length(punto) * (1.0 / pulseScale); // Aplicar escala pulsante al radio
                float angulo = atan2(punto.x, punto.y);
                
                // Formar dibujos
                float forma = sin(angulo * 50.0 + _Time.y) * 0.08 *
                            sin(radio * 200.0 + _Time.y);
                
                // Puntitos cuadraditos
                forma = sin(uv.x * 0.0 + _Time.y) * 0.08 *
                        sin(uv.y * 200.0 + _Time.y);
                
                // Suavizar borde
                float suavizarBorde = smoothstep(0.88, 0.9, (1.0 - radio) + forma);

                // Crear el borde del cuadro
                float2 bordeUV = abs(i.uv * 2.0 - 1.0);
                float borde = step(max(bordeUV.x, bordeUV.y), 1.0 - _BorderThickness);
                float lineaBorde = step(1.0 - _BorderThickness, max(bordeUV.x, bordeUV.y)) * step(max(bordeUV.x, bordeUV.y), 1.0);
                
                // Combinar el patrón con el borde
                float3 colorFinal = suavizarBorde;
                colorFinal = lerp(colorFinal, _BorderColor.rgb, lineaBorde);
                
                return fixed4(colorFinal, 1.0);
            }
            ENDCG
        }
    }
}
