Shader"ENTI/O4_Outlines" {
    Properties{
        _Thickness("Thickness", Range(0, 0.1)) = 0.3 // The amount to extrude the outline mesh
        _Color("Color", Color) = (1, 1, 1, 1) // The outline color
    }
    SubShader{
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass {
            Cull Front

            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x            

            
            #pragma vertex ver
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 positionOS : POSITION; // Position in object space
                float3 normalOS : NORMAL; // Normal vector in object space
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION; // Position in clip space
            };

            
            float _Thickness;
            float4 _Color;

            v2f ver(appdata input)
            {
                v2f output = (v2f) 0;

                float3 normalOS = input.normalOS;

                // Extrude the object space position along a normal vector
                float3 posOS = input.positionOS.xyz + normalOS * _Thickness;
                // Convert this position to world and clip space
                output.positionCS = GetVertexPositionInputs(posOS).positionCS;

                return output;
            }

            float4 frag(v2f input) : SV_Target
            {
                return _Color;
            }
            
            ENDHLSL
        }
    }
}