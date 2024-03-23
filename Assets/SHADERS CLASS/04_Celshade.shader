Shader"ENTI/04_Celshade"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {} // Nueva propiedad para la textura principal
        _Strength ("Strength", Range(0,1)) = 0.5 
        _Color ("Color", Color) = (1,1,1,1)
        _Detail ("Detail", Range(0.001,1)) = 0.3 
        _AmbientLightColor ("Ambient Light Color", Color) = (1,1,1,1)
        _AmbientLightIntensity ("Ambient Light Intensity", Range(0,1)) = 1.0
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _Shininess ("Shininess", Range(0.01, 1)) = 0.078125
        _SpecularPower ("Specular Power", Range(0.01, 128)) = 16.0
        _SpecularIntensity ("Specular Intensity", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags {"RenderPipeline" = "UniversalPipeline" "LightMode"="UniversalForward" }
        Lighting On
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0 
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0; // Coordenadas de textura
                float3 normal : NORMAL; // Coordenadas de textura
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                            UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                half3 worldNormal : NORMAL;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Strength;
            float4 _Color;
            float _Detail;
            float4 _AmbientLightColor;
            float _AmbientLightIntensity;
            float4 _SpecularColor;
            float _Shininess;
            float _SpecularPower;
            float _SpecularIntensity;
    
            float Toon(float3 normal, float3 lightDir, float3 viewDir)
            {
                float NdotL = max(0.0, dot(normalize(normal), normalize(lightDir)));
                float3 halfDir = normalize(lightDir + viewDir);
                float NdotH = max(0.0, dot(normal, halfDir));
                float specular = pow(NdotH, _SpecularPower) * _Shininess;
                float toon = (NdotL / _Detail);
                return toon + specular;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.color = _LightColor0 * _AmbientLightColor * _AmbientLightIntensity;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex.xyz);
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                col *= Toon(i.worldNormal, lightDir, viewDir) * _Strength * _Color + _AmbientLightIntensity * i.color;
                float3 specularColor = _SpecularColor.rgb * _LightColor0.rgb;
                col.rgb += specularColor * _SpecularIntensity;
                return col;
            }
            ENDCG
        }
        
        Pass
        {
            Tags { "LightMode"="ShadowCaster" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

                return o;
            }
            
            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i);
            }
            
            ENDCG
        }
    }
}
