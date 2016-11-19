#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"
#include "fractal.glsl"

varying float vtime;

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);
    vtime = cElapsedTime;
    //vTexCoord = GetQuadTexCoord(gl_Position);
    //vScreenPos = GetScreenPosPreDiv(gl_Position);
}


vec3 calcNormal( in vec3 pos , float vtime )
{
	vec3 eps = vec3( 0.1,  0.0, 0.0 );
	vec3 nor = vec3(
	    sdfmap(pos+eps.xyy,vtime).w - sdfmap(pos-eps.xyy,vtime).w,
	    sdfmap(pos+eps.yxy,vtime).w - sdfmap(pos-eps.yxy,vtime).w,
	    sdfmap(pos+eps.yyx,vtime).w - sdfmap(pos-eps.yyx,vtime).w );
	return normalize(nor);
}
void PS()
{
  float dist = sdfmap(cCameraPosPS,vtime).w;
  vec3 normal = calcNormal(cCameraPosPS, vtime);
  gl_FragColor = vec4(normal,dist);
}
