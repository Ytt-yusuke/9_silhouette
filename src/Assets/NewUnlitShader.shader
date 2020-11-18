Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Thickness("Thickness", Range(0,01)) = 0.01
        _OutlineColor("Outline Color", COlor) = (1,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue" = "transparent"}
        LOD 100

        Blend One OneMinusSrcAlpha

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                
                float a = 
                    max(tex2D(_MainTex, i.uv + float2(-_Thickness, 0)).a,
                    max(tex2D(_MainTex, i.uv + float2(+_Thickness, 0)).a,
                    max(tex2D(_MainTex, i.uv + float2(0, -_Thickness)).a,
                    max(tex2D(_MainTex, i.uv + float2(0, +_Thickness)).a,
                    col.a))))* _OutlineColor.a;

                col.rgb = col.a * col.rgb + (1 - col.a) * a * _OutlineColor.rgb;
                col.a = 1.0 - (1.0 - a) * (1.0 - col.a);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
