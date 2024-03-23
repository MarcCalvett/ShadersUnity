Shader"ENTI/Triplanar"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
_MainTex ("Albedo (RGB)", 2D) = "white" {}
_SecondaryTex ("SecondaryTex (RGB)", 2D) = "white" {}
_Roughness ("Roughness", Range(0,1)) = 0.5
_RoughnessMap ("Roughness Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
#pragma target 3.0
sampler2D _MainTex;
sampler2D _SecondaryTex;
sampler2D _RoughnessMap;

struct Input
{
    float2 uv_MainTex;
    float2 uv_RoughnessMap; // Nueva
    float3 worldNormal;
    float3 worldPos;
};

half _Roughness;
fixed4 _Color;
        
UNITY_INSTANCING_BUFFER_START(PROPS)
UNITY_INSTANCING_BUFFER_END(PROPS)

void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
{
    Rotation = Rotation * (3.1415926f / 180.0f);
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix * 2 - 1;
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;
    Out = UV;
}

void surf(Input IN, inout SurfaceOutputStandard o)
{
    float2 yz_proj = 0;
    Unity_Rotate_Degrees_float(IN.worldPos.yz, .5, 270, yz_proj);
    fixed4 tp = tex2D(_MainTex, IN.worldPos.xz * .1);
    fixed4 bt = tex2D(_SecondaryTex, IN.worldPos.xz * .1);
    fixed4 lr = tex2D(_SecondaryTex, yz_proj * .1);
    fixed4 fb = tex2D(_SecondaryTex, IN.worldPos.xy * .1);
    
    fixed4 up_col = max(0, smoothstep(IN.worldNormal.y, IN.worldNormal.y - 0.1, 0.5) * tp);
    fixed4 lo_col = max(0, smoothstep(-IN.worldNormal.y, -IN.worldNormal.y - 0.8, 0.5) * bt);
    fixed4 si_col = IN.worldNormal.x * lr;
    fixed4 fr_col = IN.worldNormal.z * fb;
    
    // Calcula el valor de roughness utilizando el mapa de roughness
    half roughnessValue = tex2D(_RoughnessMap, IN.uv_RoughnessMap).r;
    
    // Aplica roughness solo en la dirección Y del triplanar
    o.Smoothness = lerp(1 - _Roughness, roughnessValue, IN.worldNormal.y);
    
    fixed4 c = (up_col + lo_col + abs(si_col) + abs(fr_col)) * _Color;
    o.Albedo = c.rgb;
    o.Metallic = 0;
    o.Alpha = c.a;
}

            ENDCG
        }
    
}