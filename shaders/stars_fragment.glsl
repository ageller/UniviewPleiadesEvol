uniform float uv_fade;

in vec4 color;
in vec2 texcoord;

out vec4 fragColor;

uniform float Allalpha;

uniform int markerType;
uniform sampler2D BHimg;

void main()
{
    fragColor = color;
    fragColor.a *= uv_fade*Allalpha;
    vec2 fromCenter = texcoord * 2 - vec2(1);
	float r2 = dot(fromCenter,fromCenter);
	int pMarker = int(markerType); 
	
	switch(pMarker) {
		case 0: //limb darkening
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
			//fragColor.a = uv_fade;
			if (r2 > 1){
				fragColor = vec4(0.0,0.0,0.0,0.0);
				discard;
			}
			break;
	
		case 1: //Gaussian Marker
			fragColor.a*=exp(-0.5*r2/0.1);
			if (r2 > 1.0) {
				discard;
			}				
			break;
			
		case 2: //Hard outlined circle with center dot
			if (r2 >1.0) {
				discard;
			} else if (r2<0.8 && r2 >0.05) {
				fragColor.a*=0.3;
			} 
			break;
			
		case 3: //Soft circle with center dot
			if (r2 > 1.0){		
				discard;
			} else if (r2 > 0.05){
				fragColor.a *= 0.3;
			}
			break;
			
		case 4: //Ring
			fragColor.a*=(2*sin(3.1415*dot(fromCenter,fromCenter)) -1.0);
			break;
			
		case 5: //Hard Circle
			if (r2 > 1.0) {
				discard;				
			break;
			}
			
		case 6: //plus sign
			if (!(abs(fromCenter[0])<0.1 || abs(fromCenter[1])<0.1)){
				discard;
			} 
			break;
			
		case 7: //Hard Square Outline
			if ((fromCenter.x > -0.8 && fromCenter.x < 0.8 && fromCenter.y > -0.8 && fromCenter.y < 0.8)){
				fragColor.a = 0.0;
			}
			break;
			
		case 8: //Soft Square Outline
			if ((fromCenter.x > -0.8 && fromCenter.x < 0.8 && fromCenter.y > -0.8 && fromCenter.y < 0.8)){
				fragColor.a *= 0.3;
			}
			break;
			
		case 9: //Soft Square Outline and center square
			if (fromCenter.x < -.2 || fromCenter.x > .2 || fromCenter.y < -.2 || fromCenter.y > .2 ){
			if (fromCenter.x > -0.8 && fromCenter.x < 0.8 && fromCenter.y > -0.8 && fromCenter.y < 0.8 ){ //r2 > .05){
				fragColor.a *= 0.3;
			}}
			break;
			
		case 10: //cross
			if ((abs(fromCenter.x - fromCenter.y) > .15 && abs(fromCenter.x + fromCenter.y) > .15) || r2 > 1.4){
				discard;
			}
			break;
			
		case 11: //hard triangle
			if ( abs(fromCenter.x) >  (1/sqrt(3.))*(1-fromCenter.y) || fromCenter.y < -1./2){
				discard;
			}
			break;
			
		case 12: //hard triangle v2
			if ( abs(fromCenter.x) >  (1/sqrt(3.))*(1-fromCenter.y) || fromCenter.y < -1./2.){
				discard;
			}
			if ( abs(fromCenter.x) <  (1/sqrt(3.))*(1-fromCenter.y)-.15 && fromCenter.y > -1./2.+.15*sqrt(3.)/2.){
				fragColor.a *= .3;
			}
			break;
			
		case 13: //hard triangle with center triangle
			if ( abs(fromCenter.x) >  (1/sqrt(3.))*(1-fromCenter.y) || fromCenter.y < -1./2.){
				discard;
			}
			if ( abs(fromCenter.x) >  (1/sqrt(3.))*(1-fromCenter.y)-.45 || fromCenter.y < -1./2.+.45*sqrt(3.)/2.){
			if ( abs(fromCenter.x) <  (1/sqrt(3.))*(1-fromCenter.y)-.15 && fromCenter.y > -1./2.+.15*sqrt(3.)/2.){// && r2 > .05){
				fragColor.a *= .3;
			}}
			break;
			
		case 14: // hard Ring
			if (r2 < 0.6 || r2 > 1){
				discard;
			}
			break;	
			
		case 15: //hourglass with circle
			if ( (abs(fromCenter.x) >  0.6*abs(fromCenter.y) || abs(fromCenter.y) > 0.7) && r2 < 0.8){
//				discard;
				fragColor.a *= .3;
			} else if (r2 > 1){
				discard;
			}
			break;

		case 16: //BH from png image
			if (texture(BHimg, texcoord).a < 0.5){
				discard;
			}
			break;
		case 17: //fuzzy ball
			float brightness = 0.0;
			float alpha = 0.0;
			float dist = length(fromCenter);
			if (dist < 1){
				brightness = 1. - dist;
				fragColor.a  *= (1. - pow(dist, 3.));
			} else {
				discard;
			}
			vec3 uCo = vec3(mix(vec3(1.0, 1.0, 1.0), fragColor.xyz, clamp(1.1 - brightness, 0.0, 1.0)));
			fragColor.xyz = uCo;
	}

}
