﻿Shader "Unlit/SilhouetteShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Thickness ("Thickness", Range(0,10)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Cull Front

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float4 normal_clip = UnityObjectToClipPos(float4(v.vertex + v.normal, 1.0f));
                normal_clip.xy = normalize(normal_clip.xy / normal_clip.w - o.vertex.xy/o.vertex.w);
                normal_clip.xy = normal_clip.xy * (_ScreenParams.zw - 1) * _Thickness * o.vertex.w * 5.0f;
                o.vertex.xy += normal_clip.xy;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = fixed4((_SinTime.w + 1.0) * 0.5, (_SinTime.z + 1.0) * 0.5, (_SinTime.y + 1.0) * 0.5, 1.0);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
