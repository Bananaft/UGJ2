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

void PS()
{
  gl_FragColor = vec4(sdfmap(cCameraPosPS).w, 0. , 0. , 0. );
}
