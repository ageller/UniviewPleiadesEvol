layout(triangles) in;
layout(triangle_strip, max_vertices = 4) out;

uniform mat4 uv_modelViewProjectionMatrix;
uniform mat4 uv_modelViewInverseMatrix;
uniform mat4 uv_projectionMatrix;
uniform mat4 uv_modelViewMatrix;
uniform vec3 incolor = vec3(1);
uniform float uv_fade;
uniform int uv_simulationtimeDays;
uniform float uv_simulationtimeSeconds;
uniform float animationPeriod = 90.0;

uniform float centerL = 2.; //log(luminosity) for center of HR diagram
uniform float centerT = 3.6; //log(Teff) for center of HR diagram
uniform float Tscale = 5.0; //scale for log(Teff) in HR diagram
uniform float Lscale = 1.0; // scale for log(L) in HR diagram

uniform float tinyL = 0.0001;//
uniform float logRfac = 1.; //add this onto the logR for plotting, so that I can see stars down to 0.1 RSun 
uniform float prec = 1000.;//1000.;//1./precision in my files for unpacking radii and luminosities 
uniform float maxmin = 9.;//20.;//maximum log(value) for radius and luminosity (and minimum = -1*maxmin)
uniform float minlogL = -6.5;//force this to be the minimum logL (in the files logL > -9)
uniform float minrad = 0.1;//force this to be the minimum rad for plotting trails 
uniform float betaR = 1.0; //exponent in radius scale factor

uniform float dTime;

uniform float doAll;
uniform float doBH;
uniform float doNS;
uniform float doWD;
uniform float doSNe;
uniform float doBSS;
uniform float doECS;

uniform float showAll;
uniform float showBH;
uniform float BHrad;
uniform float showNS;
uniform float NSrad;
uniform float showWD;
uniform float WDrad;
uniform float showSNe;
uniform float SNerad;
uniform float showHRd;
uniform float allRadfac;
uniform float maxRadius;
uniform float minRadius;
uniform float dologRad;
uniform float showBSS;
uniform float BSSrad;
uniform float showECS;
uniform float ECSrad;
uniform float trailLength;
uniform float mixz;
uniform float exagColors;
uniform float zlength;
uniform float zknee;

out vec4 color;
out vec2 texcoord;


// axis should be normalized
mat3 rotationMatrix(vec3 axis, float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}

void drawSprite(vec4 position, float radius, float rotation)
{
    vec3 objectSpaceUp = vec3(0, 0, 1);
    vec3 objectSpaceCamera = (uv_modelViewInverseMatrix * vec4(0, 0, 0, 1)).xyz;
    vec3 cameraDirection = normalize(objectSpaceCamera - position.xyz);
    vec3 orthogonalUp = normalize(objectSpaceUp - cameraDirection * dot(cameraDirection, objectSpaceUp));
    vec3 rotatedUp = rotationMatrix(cameraDirection, rotation) * orthogonalUp;
    vec3 side = cross(rotatedUp, cameraDirection);
    texcoord = vec2(0, 1);
	gl_Position = uv_modelViewProjectionMatrix * vec4(position.xyz + radius * (-side + rotatedUp), 1);
	EmitVertex();
    texcoord = vec2(0, 0);
	gl_Position = uv_modelViewProjectionMatrix * vec4(position.xyz + radius * (-side - rotatedUp), 1);
	EmitVertex();
    texcoord = vec2(1, 1);
	gl_Position = uv_modelViewProjectionMatrix * vec4(position.xyz + radius * (side + rotatedUp), 1);
	EmitVertex();
    texcoord = vec2(1, 0);
	gl_Position = uv_modelViewProjectionMatrix * vec4(position.xyz + radius * (side - rotatedUp), 1);
	EmitVertex();
	EndPrimitive();
}

void drawLine(vec4 position0, vec4 position1, float width)
{
    vec3 viewPosition0 = (uv_modelViewMatrix * position0).xyz;
    vec3 viewPosition1 = (uv_modelViewMatrix * position1).xyz;
    vec3 side = normalize(cross(viewPosition0, viewPosition1 - viewPosition0)) * width;
    vec3 side0 = side * length(viewPosition0);
    vec3 side1 = side * length(viewPosition1);

    gl_Position = uv_projectionMatrix * vec4(viewPosition0 - side0, 1);
    EmitVertex();
    gl_Position = uv_projectionMatrix * vec4(viewPosition0 + side1, 1);
    EmitVertex();

    gl_Position = uv_projectionMatrix * vec4(viewPosition1 - side1, 1);
    EmitVertex();
    gl_Position = uv_projectionMatrix * vec4(viewPosition1 + side1, 1);
    EmitVertex();
}


void main()
{
	float rotation = 0.;
	
	float drawAll = showAll * doAll;
	float drawBH = showBH * doBH;
	float drawNS = showNS * doNS;
	float drawWD = showWD * doWD;
	float drawSNe = showSNe * doSNe;
	float drawBSS = showBSS * doBSS;
	float drawECS = showECS * doECS;


//////////////////////////////////////////////////////////////
//define the time (sim will run from year 0 to year 100, each year representing one Myr)
	float dayfract = uv_simulationtimeSeconds/(24.0*3600.0);//0.5*2.0*3.14*(time)/(sqrt(a.x*a.x*a.x/3347937656.835192));
    float years_0 = (uv_simulationtimeDays + dayfract)/365.2425 + 1970.;
    float cosmoTime = clamp(years_0,0.0,99.9);     
	float simTime = gl_in[2].gl_Position.z;
	float usedT = dTime;

	if (simTime >= cosmoTime-trailLength && simTime < (cosmoTime + 1.01*usedT ) && trailLength > 0){

//////////////////////////////////////////////////////////////
//define the particle radii and temperatures 
		float logR = gl_in[2].gl_Position.x;
		float logL = gl_in[2].gl_Position.y;
		float type = 0.;
		float btype = 0.;
		float etype = 0.;	
		


//define the radius for plotting
		float rad = 0.;
		float r = pow(10., logR);
		rad = (maxRadius - minRadius)*pow(r, betaR) / (pow(r, betaR) + allRadfac) + minRadius;
//		rad = allRadfac*pow(10.,logR);
		if (dologRad == 1){
			rad = clamp(allRadfac*(logR + logRfac), 0., maxRadius);
		}
		rad = clamp(rad, minRadius, maxRadius);
		if (pow(10.,logL) <= tinyL){
			rad = tinyL;
		}

		
		
//calculate the temperature
		float logT = 3.762 + 0.25*logL - 0.5*logR;
		float Teff = pow(10.,logT);
		
/////////////////////////////////////////////////////////
//define the color

//to be safe
		color = vec4(0., 0., 0., 0.);
//choose the color by the blackbody temperature
		if (drawAll > 0){	
//exagerated color scheme
			vec3 cmap_exag[9]; //Blackbody Colors 0 = 2000 deg, 8 = 10000 deg
			cmap_exag[0]=vec3(1.000, 0.139, 0.074 ); //2000
			cmap_exag[1]=vec3(1.000, 0.207, 0.074 ); //3000
			cmap_exag[2]=vec3(1.000, 0.520, 0.441 ); //4000
			cmap_exag[3]=vec3(1.000, 0.695, 0.509 ); //5000
			cmap_exag[4]=vec3(1.000, 0.953, 0.938 ); //6000
			cmap_exag[5]=vec3(0.861, 0.953,  1.0 ); //7000
			cmap_exag[6]=vec3(0.691, 0.714, 1.0 ); //8000
			cmap_exag[7]=vec3(0.440, 0.583, 1.0 ); //9000
			cmap_exag[8]=vec3(0.201, 0.359, 1.0 ); //10000
//more realistic color scheme
			vec3 cmap_norm[9]; //Blackbody Colors 0 = 2000 deg, 8 = 10000 deg
			cmap_norm[0]=vec3(1.000, 0.539, 0.074 ); //2000
			cmap_norm[1]=vec3(1.000, 0.707, 0.422 ); //3000
			cmap_norm[2]=vec3(1.000, 0.820, 0.641 ); //4000
			cmap_norm[3]=vec3(1.000, 0.895, 0.809 ); //5000
			cmap_norm[4]=vec3(1.000, 0.953, 0.938 ); //6000
			cmap_norm[5]=vec3(0.961, 0.953,  1.0 ); //7000
			cmap_norm[6]=vec3(0.891, 0.914, 1.0 ); //8000
			cmap_norm[7]=vec3(0.840, 0.883, 1.0 ); //9000
			cmap_norm[8]=vec3(0.801, 0.859, 1.0 ); //10000			
//user determined color scheme 
			vec3 cmap[9]; //Blackbody Colors 0 = 2000 deg, 8 = 10000 deg
			for (int i=0; i < 9; i++){
				cmap[i]=vec3(mix(cmap_norm[i], cmap_exag[i], exagColors)); 
			}
//linearly interpolate along this cmap
			float cval = Teff/1000. - 2.;
			int I1 = int(clamp(floor(cval),0 ,8));
			int I2 = int(clamp(ceil(cval),0 ,8));
			color = vec4(mix(cmap[I1], cmap[I2], clamp(cval-I1, 0.0, 1.0)), 1.0);
		}
		
//redefine colors and radii for special stars	
		if (drawAll == 0 && drawBSS == 0 && drawECS == 0){
			rad = 0.;
		}
		
//make BHs green	
		if (drawBH > 0){
			color = vec4(0., 1., 0., 1.);
			rad = BHrad;
			rotation = mod(years_0, 1.)*2.*3.1416;
		} 
	
//make NSs magenta	
		if (drawNS > 0){
			color = vec4(1., 0., 1., 1.);	
			rad = NSrad;
			rotation = -1.*mod(years_0, 1.)*2.*3.1416;
		} 
	
//make WDs cyan	
		if (drawWD > 0){
			color = vec4(0., 1., 1., 1.);
			rad = WDrad;
			rotation = -mod(years_0, 2.)/2.*2.*3.1416;

		} 
	
//make SNe yellow	
		if (drawSNe > 0){
			color = vec4(1., 1., 0., 1.);
			rad = SNerad;
		} 
// for these two, I'd like to have always draw the star on the inside	
//make BSS light slate blue	
		if (drawBSS > 0){
			color = vec4(0.518, 0.478, 1., 1.);
			float trad = 2.*rad;
			if (trad > minRadius){
				rad = trad; 
			} else {
				rad = BSSrad;
			}
		}
		
//make ECS orange	
		if (drawECS > 0){
			color = vec4(1., 0.55, 0., 1.);
			float trad = 2.*rad;
			if (trad > minRadius){
				rad = trad; 
			} else {
				rad = ECSrad;
			}
		} 	

//quick way to ID BHs and NSs and draw different lines
		color.a = 1.0;
		if (logL < -8.9 && logR < -4.) {
			color = vec4(0.2, 1., 0.5, 1.);
			rad = 0.4;
		} else if (logR < -4.){
			color = vec4(1., 0.5, 1., 1.);	
			rad = 0.4;
		} else {
			color.a *= showAll;
		}
		
		logL = max(logL, minlogL);
		rad = max(rad, minrad);
		
//////////////////////////////////////////////////////////////
//define particle positions	
//interpolate xyz positions to the current cosmoTime 
        vec4 posOC = mix(gl_in[0].gl_Position, gl_in[1].gl_Position, (cosmoTime-simTime)/usedT);	
		
//HR diagram	
		vec4 posHR = vec4(Tscale*(logT - centerT), Lscale*(logL - centerL), 0., 1);

//for the transition between xyz positions and HR diagram		
        vec4 pos1 = mix(gl_in[0].gl_Position, posHR, showHRd);
        vec4 pos2 = mix(gl_in[1].gl_Position, posHR, showHRd);
		
//////////////////////////////////////////////////////////////	
//draw the particles

		vec3 viewPosition1 = (uv_modelViewMatrix * pos1).xyz;
		if (drawAll > 0 ){
			color.a =  mix(color.a,0.0,(cosmoTime-simTime)/trailLength);
//			color.a *= clamp(( (1. - mixz) + (-1.*zlength)/viewPosition1.z), 0.0, 1.0);
			color.a *= clamp( (1. - mixz) + exp((viewPosition1.z + zlength)/zknee), 0.0, 1.0);

//			float alpha = mix(1.0,0.0,(cosmoTime-simTime)/trailLength);
//			drawLine(pos1,pos2,.003*sqrt(rad));
			drawLine(pos1,pos2,.007*rad);
		}	
	} 
}
