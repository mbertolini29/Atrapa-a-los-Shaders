Shader "Unlit/YellowMaterial"
{
    Properties
    {
        _Size ("Size", Range(0.1, 2.0)) = 0.86
        _DiffuseSize ("Diffuse Size", Range(0.1, 2.0)) = 0.9
        _NumPoints ("Number of Points", Range(1.0, 10.0)) = 5.0
        _AnimSpeed ("Animation Speed", Range(0.1, 20.0)) = 1.0
        _Color1 ("Color 1", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color2 ("Color 2", Color) = (0.0, 0.0, 1.0, 1.0)
        _Cantidad ("Cantidad", Int) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            #define PI 3.14159265359
            #define TWO_PI PI*2.0

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            float _Size = 0.86;
            float _DiffuseSize = 0.9;
            float _NumPoints = 5.0;
            float _AnimSpeed;
            float4 _Color1;
            float4 _Color2;
            int _Cantidad;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // Obtener coordenadas de pantalla normalizadas
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float2 resolution = _ScreenParams.xy;
                float2 uv = screenUV;
                
                // Corregir aspecto
                float fix = resolution.x / resolution.y;
                uv.x *= fix;

                float3 figuras = float3(0.0, 0.0, 0.0);
                
                for(int idx = 0; idx < _Cantidad; idx++)
                {           
                    // Calcula un índice circular para cada iteración.
                    float index = float(idx) * TWO_PI / float(_Cantidad);
                    
                    // Grilla y escala.
                    // Usar mod en lugar de fract para la grilla
                    float2 formaGrilla = fmod(uv * float(_Cantidad), 1.0) - 0.5; //?
                    
                    //Escalar las formas dentro de cada celda. 
                    float scaleFactor = 0.75;
                    formaGrilla *= scaleFactor;
                    
                    // Definir punto central en cada celda. 
                    float2 punto = formaGrilla;
                    float radio = length(punto);
                    float angulo = atan2(punto.y, punto.x);
                    
                    // 
                    float forma = sin(angulo * _NumPoints + _Time.y * _AnimSpeed +
                                  sin(radio * 99.0) +
                                  sin(angulo * 15.0 + _Time.y * _AnimSpeed * 10.0)
                                  ) * 0.25;
                    
                    // Bordes suaves mejorados
                    float borde1 = smoothstep(_Size, _DiffuseSize, (1.09 - radio) + forma);
                    float borde2 = smoothstep(_DiffuseSize + 0.01, 
                                              _DiffuseSize + 0.015, 
                                              (1.0 - radio) + forma);
                    
                    // Mezcla de colores mejorada
                    float3 formaFinal = lerp(_Color1.rgb * borde1, 
                                             _Color2.rgb, 
                                            float(idx + 25) / float(_Cantidad)) * forma;
                    
                    figuras += formaFinal;
                }
                
                figuras /= float(_Cantidad);
                
                // Asegurar que los colores estén en rango válido
                figuras = saturate(figuras);
                
                return fixed4(figuras, 1.0);
            }
            ENDCG
        }
    }
}