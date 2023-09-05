#version 330 core

in vec2 v_texCoord;

out vec4 fragColor;

uniform float u_time;
uniform float u_morph1;
uniform float u_morph2;
 
void main() {

    // modified from the original here https://www.shadertoy.com/view/XsXXDn	

	vec3 c;
	vec2 uv;
	float l;
	float t = u_time;	
	
	for(int i = 0; i < 3; i++) {
	    t += 0.5;
		vec2 p = v_texCoord;
		uv = p;
		p -= 0.5;	
		l = length(p);
		uv += p / l * (sin(t*u_morph1) + 1.0) * abs(sin(l * u_morph1 - t));
		c[i] = 0.0075 / length(mod(uv, 1.0) - 0.5);
		c[i] = c[i] < 0.015 ? u_morph2 : c[i];
	}
	
	fragColor = vec4(c/l, 1.0);	
}

