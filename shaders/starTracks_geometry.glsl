layout(triangles) in;
layout(triangle_strip, max_vertices = 4) out;

uniform mat4 uv_modelViewProjectionMatrix;
uniform mat4 uv_modelViewInverseMatrix;
uniform float alpha = 0.25;
uniform vec3 incolor = vec3(1);
uniform float uv_fade;
uniform int uv_simulationtimeDays;
uniform float uv_simulationtimeSeconds;
uniform float animationPeriod = 90.0;

uniform float centerL = 2.; //log(luminosity) for center of HR diagram
uniform float centerT = 3.6; //log(Teff) for center of HR diagram
uniform float tinyL = 0.0001;//

//uniform float drawTrails;

uniform float maxTime;
uniform float dTime;

uniform int drawAll;
uniform float showAll;
uniform int drawBH;
uniform float showBH;
uniform float BHrad;
uniform int drawNS;
uniform float showNS;
uniform float NSrad;
uniform int drawWD;
uniform float showWD;
uniform float WDrad;
uniform int drawSNe;
uniform float showSNe;
uniform float SNerad;
uniform int drawHRd;
uniform float showHRd;
uniform int drawBinaries;
uniform float showBinaries;
uniform float binaryRad;
uniform float allRadfac;
uniform float maxRadius;
uniform float dologRad;

out vec4 color;
out vec2 texcoord;

uint hash(uint val)
{
    const uint offset = 2166136261u;
    const uint prime = 16777619u;
    
    uint seed = offset;
    for(uint i = 0u; i < 32u; i += 8u)
    {
        uint byte = (val >> i) & 0xfu;
        seed *= prime;
        seed ^= byte;
    }

    return seed;
}

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

float linterp(vec2 p1, vec2 p2, float xout){
	float m = (p2[1] - p1[1])/(p2[0] - p1[0]);
	float b = p2[1] - m*p2[0];
	
	return m*xout + b;

}

void main()
{

	

//grab some values from the raw file
	float Teff1 = max(gl_in[2].gl_Position.x, tinyL);
	float logT1 = log(Teff1)/log(10.);
	
	float Lum1 = max(gl_in[2].gl_Position.y, tinyL);
	float logL1 = log(Lum1)/log(10.);	
	
/////////////////////////////////////////////////////////
//define the color

//to be safe
	color = vec4(0., 0., 0., 0.);

//make BHs green	
	if (drawBH == 1){
		color = vec4(0., 1., 0., alpha);	
	} 
	
//make NSs red	
	if (drawNS == 1){
		color = vec4(1., 0., 0., alpha);	
	} 
	
//make WDs cyan	
	if (drawWD == 1){
		color = vec4(0., 1., 1., alpha);	
	} 
	
//make SNe yellow	
	if (drawSNe == 1){
		color = vec4(1., 1., 0., alpha);	
	} 
//make binaries blue	
	if (drawBinaries == 1){
		color = vec4(0., 0., 1., alpha);	
	} 
	
//choose the color by the blackbody temperature
	if (drawAll == 1){	
		vec3 cmap[9]; //Blackbody Colors 0 = 2000 deg, 8 = 10000 deg
//    	cmap[0]=vec3(1.000, 0.339, 0.174 );
//    	cmap[1]=vec3(1.000, 0.507, 0.222 );
//    	cmap[2]=vec3(1.000, 0.720, 0.541  );
//    	cmap[3]=vec3(1.000, 0.895, 0.809  );
//    	cmap[4]=vec3(1.000, 0.953, 0.938 );
//    	cmap[5]=vec3(0.961, 0.953,  1.0 );
//    	cmap[6]=vec3(0.791, 0.814, 1.0 );
//    	cmap[7]=vec3(0.540, 0.583, 1.0 );
//    	cmap[8]=vec3(0.301, 0.359, 1.0 );
//		int colIndex = min( max(int(gl_in[2].gl_Position.x/1000. - 2.),0) ,8);
//    	color = vec4(cmap[colIndex], alpha);
//exagerated
		cmap[0]=vec3(1.000, 0.139, 0.074 ); //2000
		cmap[1]=vec3(1.000, 0.207, 0.074 ); //3000
		cmap[2]=vec3(1.000, 0.520, 0.441 ); //4000
		cmap[3]=vec3(1.000, 0.695, 0.509 ); //5000
		cmap[4]=vec3(1.000, 0.953, 0.938 ); //6000
		cmap[5]=vec3(0.861, 0.953,  1.0 ); //7000
		cmap[6]=vec3(0.691, 0.714, 1.0 ); //8000
		cmap[7]=vec3(0.440, 0.583, 1.0 ); //9000
		cmap[8]=vec3(0.201, 0.359, 1.0 ); //10000
// I want to linearly interpolate along this cmap (so that the colors don't jump from one to the other)
		float cval = Teff1/1000. - 2.;
		int I1 = int(min( max(floor(cval),0) ,8));
		int I2 = int(min( max(ceil(cval),0) ,8));
		if (I1 == I2){
			color = vec4(cmap[I1], alpha);
		} else {
			float red   = linterp(vec2(I1, cmap[I1].x), vec2(I2, cmap[I2].x), cval);
			float green = linterp(vec2(I1, cmap[I1].y), vec2(I2, cmap[I2].y), cval);
			float blue  = linterp(vec2(I1, cmap[I1].z), vec2(I2, cmap[I2].z), cval);
			color = vec4(red, green, blue, alpha);
		}
//		int colIndex = min( max(int(cval),0) ,8);
//		color = vec4(cmap[colIndex], alpha);
	}

//////////////////////////////////////////////////////////////
//define the time
	float dayfract = uv_simulationtimeSeconds/(24.0*3600.0);//0.5*2.0*3.14*(time)/(sqrt(a.x*a.x*a.x/3347937656.835192));
    float years_0 = (uv_simulationtimeDays + dayfract)/365.2425 + 1970.;
    float cosmoTime = clamp(years_0,0.0,99.9);     
	float simTime = gl_in[2].gl_Position.z;
	float usedT = dTime;
	if (drawSNe == 1){
		usedT = 1.*dTime;
	}

//////////////////////////////////////////////////////////////
//define the particle positions and radii 
	if (simTime >= cosmoTime && simTime < (cosmoTime + usedT)){
//	if ((simTime >= cosmoTime && simTime < (cosmoTime + usedT)) || drawSNe == 1){
	
//interpolate positions to the current cosmoTime (if we had more columns available, we could interpolate radii also)
		float px1 = gl_in[0].gl_Position.x;
		float py1 = gl_in[0].gl_Position.y;
		float pz1 = gl_in[0].gl_Position.z;
		float px2 = gl_in[1].gl_Position.x;
		float py2 = gl_in[1].gl_Position.y;
		float pz2 = gl_in[1].gl_Position.z;

		float px = linterp(vec2(simTime, px1), vec2(simTime+dTime, px2), cosmoTime);
		float py = linterp(vec2(simTime, py1), vec2(simTime+dTime, py2), cosmoTime);
		float pz = linterp(vec2(simTime, pz1), vec2(simTime+dTime, pz2), cosmoTime);

		vec4 posOC = vec4(px, py, pz, 1);
		
		float rad = allRadfac; //to be safe
		if (drawBH == 1){
			rad = BHrad;
		}
		if (drawNS == 1){
			rad = NSrad;
		}
		if (drawWD == 1){
			rad = WDrad;
		}		
		if (drawSNe == 1){
			rad = SNerad;
		}	
		if (drawBinaries == 1){
			rad = binaryRad;
		}
		if (drawAll == 1){
// I need to back out the radius from the temperature and luminosity (I calculated Teff from rad)
// this will introduce some error on the radius, since I'm only keeping integers in temperature
			float lograd1 = ((logT1 - 3.762 - 0.25*logL1)/(-0.5));
			float rad1 = pow(10., lograd1);
			if (dologRad == 1){
				rad1 = min(max(lograd1+1, 0.), maxRadius);
			}
			rad = min(allRadfac*rad1, maxRadius);
			if (Lum1 <= tinyL){
				rad = tinyL;
			}
		}
		
//convert this to an HR diagram?
		
		vec4 posHR = vec4(20.0*(logT1 - centerT), 2.0*(logL1 - centerL), 0., 1);
		
        vec4 pos = mix(posOC,posHR,showHRd);
//////////////////////////////////////////////////////////////	
//draw the particles
//		if ((drawAll > 0 && showAll > 0) || (drawBH > 0 && showBH > 0 && showHRd == 0) || (drawNS > 0 && showNS > 0 && showHRd == 0) || (drawWD > 0 && showWD > 0 && showHRd == 0) || (drawSNe > 0 && showSNe > 0 && showHRd == 0) || (drawBinaries > 0 && showBinaries > 0 && showHRd == 0) || (drawHRd > 0 && showHRd > 0)){
		if ((drawAll > 0 && showAll > 0) || (drawBH > 0 && showBH > 0) || (drawNS > 0 && showNS > 0) || (drawWD > 0 && showWD > 0) || (drawSNe > 0 && showSNe > 0) || (drawBinaries > 0 && showBinaries > 0) || (drawHRd > 0 && showHRd > 0)){

			drawSprite(pos, rad, 0);
		}
		

	
	} 


}
