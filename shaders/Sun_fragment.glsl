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
//limb darkening for Sun at 550 nm (from Wikipedia, but cited to Cox 2000)
//a0 = 1. - a1 - a2 = 0.3
//a1 = 0.93
//a2 = -0.23
//I(psi) = I(0)*(a0 + a1*cos(psi) + a2*cos(psi)^2. 
//Allen's Astrophysical Quantities:
// I(theta) = I(0)*(1 - u2 - v2 + u2*cos(theta) + v2*(cos(theta))^2.
// 550nm : u2 = 0.93, v2 = -0.23
// theta == angle between the Sun's radius vector and the line of sight 
// cos(theta) = r/sqrt(d^2. + r^2.)? set d=RSun?, I think this is not correct -- see PDF that I saved on my laptop
// Chapter that I found online astro222.phys.uvic.ca/~tatum/stellatm/atm6.pdf
// I(r) = I(0)*(1- u*(1-((Rstar**2. - r**2)/Rstar**2.)**0.5))
// where Rstar is the star's radius and r is the distance from the center
// u = 0.56 at 600nm
	float u = 0.56;
	float Rstar2 = 1.0;
	fragColor *= (1. - u*(1. - sqrt((Rstar2 - r2)/Rstar2)));
	fragColor.a = uv_fade;
	if (r2 > 1){
		fragColor = vec4(0.0,0.0,0.0,0.0);
		discard;
	}
}
