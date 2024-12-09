Shader "Custom/PlasmaProjectile"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (0.5, 0.8, 1.0, 1.0)
        _GlowColor ("Glow Color", Color) = (0.0, 0.5, 1.0, 1.0)
        _GlowIntensity ("Glow Intensity", Range(0, 10)) = 2.0
        _PulseSpeed ("Pulse Speed", Range(0, 10)) = 1.0
        _NoiseScale ("Noise Scale", Range(0, 50)) = 10
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            float4 _MainColor;
            float4 _GlowColor;
            float _GlowIntensity;
            float _PulseSpeed;
            float _NoiseScale;

            // Simple noise function
            float noise(float3 x)
            {
                float3 p = floor(x);
                float3 f = frac(x);
                f = f * f * (3.0 - 2.0 * f);
                float n = p.x + p.y * 157.0 + 113.0 * p.z;
                return lerp(lerp(lerp(frac(sin(n + 0.0) * 43758.5453123),
                                   frac(sin(n + 1.0) * 43758.5453123), f.x),
                               lerp(frac(sin(n + 157.0) * 43758.5453123),
                                   frac(sin(n + 158.0) * 43758.5453123), f.x), f.y),
                           lerp(lerp(frac(sin(n + 113.0) * 43758.5453123),
                                   frac(sin(n + 114.0) * 43758.5453123), f.x),
                               lerp(frac(sin(n + 270.0) * 43758.5453123),
                                   frac(sin(n + 271.0) * 43758.5453123), f.x), f.y), f.z);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Create plasma effect using noise and time
                float3 pos = i.worldPos * _NoiseScale * 0.1;
                float n = noise(pos + _Time.y);
                
                // Add pulsing effect
                float pulse = (sin(_Time.y * _PulseSpeed) + 1.0) * 0.5;
                
                // Combine noise and pulse
                float plasma = n * pulse;
                
                // Create final color
                fixed4 col = lerp(_MainColor, _GlowColor, plasma);
                col.rgb *= _GlowIntensity;
                
                // Add edge glow
                float edge = 1.0 - length(i.uv - 0.5) * 2;
                edge = pow(edge, 3);
                
                col.a = col.a * edge;
                
                return col;
            }
            ENDCG
        }
    }
}
