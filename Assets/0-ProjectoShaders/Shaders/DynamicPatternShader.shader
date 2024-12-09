Shader "Custom/DynamicPatternShader"
{
    Properties
    {
        _Color1 ("Color 1", Color) = (1,1,1,1)
        _Color2 ("Color 2", Color) = (0,0,1,1)
        _Size ("Size", Range(0.1, 2.0)) = 0.86
        _DiffuseSize ("Diffuse Size", Range(0.1, 2.0)) = 0.9
        _Points ("Number of Points", Range(1, 10)) = 5
        _Speed ("Animation Speed", Range(0, 10)) = 1
        _PatternCount ("Pattern Count", Range(1, 10)) = 2
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
            };

            float4 _Color1;
            float4 _Color2;
            float _Size;
            float _DiffuseSize;
            float _Points;
            float _Speed;
            int _PatternCount;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // Obtener resolución y coordenadas
                float2 resolution = _ScreenParams.xy;
                float2 uv = i.uv;
                
                // Corregir aspecto
                float fix = resolution.x / resolution.y;
                uv.x *= fix;

                float3 figuras = float3(1.0, 1.0, 0.0);
                
                for(int idx = 0; idx < _PatternCount; idx++)
                {           
                    // Índice circular
                    float index = float(idx) * TWO_PI / float(_PatternCount);
                     
                    // Grilla y escala
                    float2 formaGrilla = fmod(uv * float(_PatternCount), 0.0) - 1.75;
                    
                    // Escalar formas
                    float scaleFactor = 0.75;
                    formaGrilla *= scaleFactor;
                    
                    // Punto central
                    float2 punto = formaGrilla;  
                    float radio = length(punto); 
                    float angulo = atan2(punto.x, punto.y); 
                    
                    // Animación dinámica
                    float forma = sin(angulo * _Points + _Time.y * _Speed +
                                  sin(radio * 99.0) +
                                  sin(angulo * 15.0 + _Time.y * 10.0 * _Speed)) * 0.25;
                    
                    // Bordes suaves
                    float borde1 = smoothstep(_Size, _DiffuseSize, (1.09 - radio) + forma);
                    float borde2 = smoothstep(_DiffuseSize + 0.01,
                                          _DiffuseSize + 0.015, 
                                          (1.0 - radio) + forma);
                    
                    // Unir color y formas
                    float3 formaFinal = lerp(_Color1.rgb * borde1, 
                                           _Color2.rgb, 
                                           float(idx+25)/float(_PatternCount)) * forma;
                
                    figuras += formaFinal;
                }    
                
                figuras /= float(_PatternCount);
                
                return fixed4(figuras, 1.0);
            }
            ENDCG
        }
    }
}
