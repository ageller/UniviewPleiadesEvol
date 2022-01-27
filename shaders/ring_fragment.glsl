uniform float uv_fade;

in vec4 color;
in vec2 texcoord;

out vec4 fragColor;

void main()
{
    fragColor = color;
    fragColor.a *= uv_fade;
    vec2 fromCenter = texcoord * 2 - vec2(1);
	float r2 = dot(fromCenter,fromCenter);
	float Rin = 0.6;
	float Rout = 1.0;
	fragColor.a = 1.0;
	if (r2 < Rin || r2 > Rout ){
		fragColor.a = 0.0;
	}
	
//	fragColor.a*=exp(-0.5*dot(fromCenter,fromCenter)/0.1);
//    fragColor.a *= smoothstep(-1.5, -0.5, -length(fwidth(texcoord.xy)));
    //fragColor.a *= pow(max(0, 1 - dot(fromCenter, fromCenter)), 2);
}
