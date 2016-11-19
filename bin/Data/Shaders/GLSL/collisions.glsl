#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"
#include "fractal.glsl"

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    //vTexCoord = GetQuadTexCoord(gl_Position);
    //vScreenPos = GetScreenPosPreDiv(gl_Position);
}


vec3 calcNormal( in vec3 pos)
{
	vec3 eps = vec3( 0.1,  0.0, 0.0 );
	vec3 nor = vec3(
	    sdfmap(pos+eps.xyy) - sdfmap(pos-eps.xyy),
	    sdfmap(pos+eps.yxy) - sdfmap(pos-eps.yxy),
	    sdfmap(pos+eps.yyx) - sdfmap(pos-eps.yyx) );
	return normalize(nor);
}
void PS()
{
  float dist = sdfmap(cCameraPosPS);
  vec3 normal = calcNormal(cCameraPosPS);
  gl_FragColor = vec4(normal,dist);
}
