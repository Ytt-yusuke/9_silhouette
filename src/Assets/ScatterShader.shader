Shader "Unlit/ScatterShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Thickness ("Thickness", Range(0,01)) = 0.001
        _OutlineColor ("Outline Color", COlor) = (1,0,0,1)
    }

    CGINCLUDE
    // make fog work
    #pragma multi_compile_fog

    #include "UnityCG.cginc"

    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
    };

    struct v2f
    {
        float2 uv : TEXCOORD0;
        UNITY_FOG_COORDS(1)
        float4 vertex : SV_POSITION;
    };

    sampler2D _MainTex;
    float4 _MainTex_ST;
    float _Thickness;
    fixed4 _OutlineColor;

    v2f vert_sub (appdata v, float2 offset)
    {
        v2f o;
        float depth = UnityObjectToViewPos(v.vertex).z;
        o.vertex = UnityObjectToClipPos(v.vertex + float4(offset.x, offset.y, 0, 0) * depth);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        UNITY_TRANSFER_FOG(o,o.vertex);
        return o;
    }

    fixed4 frag(v2f i) : SV_Target
    {
        // sample the texture
        fixed4 col = fixed4(_OutlineColor.rgb, tex2D(_MainTex, i.uv).a * _OutlineColor.a);
        // apply fog
        UNITY_APPLY_FOG(i.fogCoord, col);
        return col;
    }
    ENDCG

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent-1" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        Zwrite Off
        ZTest Less

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
                return vert_sub(v, float2(-_Thickness, 0));
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
                return vert_sub(v, float2(-_Thickness, 0));
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
                return vert_sub(v, float2(+_Thickness, 0));
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
                return vert_sub(v, float2(0, -_Thickness));
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
                return vert_sub(v, float2(0, +_Thickness));
            }
            ENDCG
        }
    }
}
