#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"


varying vec2 vTexCoord;
varying vec4 vWorldPos;
;
#ifdef VERTEXCOLOR
    varying vec4 vColor;
#endif

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    vWorldPos = vec4(worldPos, GetDepth(gl_Position));


    vTexCoord = GetTexCoord(iTexCoord);

}

void PS()
{

	vec4 col = texture2D(sDiffMap, vTexCoord.xy);
	//vec4 heightmap = texture2D(sDiffMap, vTexCoord.xy);
	vec3 diffColor = col.xyz;
  float y = vWorldPos.y;
  vec3 glowCol = vec3(0.2+fract(y*0.3312 + cElapsedTimePS*2.),0.2+fract(y*0.977 + cElapsedTimePS*3.1),0.2+fract(y*1.137943 + cElapsedTimePS*3.33));
  glowCol = normalize(glowCol) * 2.;
  //glowCol *= col.a;




    #if defined(PREPASS)
        // Fill light pre-pass G-Buffer
        gl_FragData[0] = vec4(0.5, 0.5, 0.5, 1.0);
        gl_FragData[1] = vec4(EncodeDepth(vWorldPos.w), 0.0);
    #elif defined(DEFERRED)
        gl_FragData[0] = vec4(mix(diffColor,glowCol, col.a),0.0);
        gl_FragData[1] = vec4(diffColor.rgb, 0.0); //diffColor.rgb
        gl_FragData[2] = vec4(0.0);
        gl_FragData[3] = vec4(EncodeDepth(vWorldPos.w), 0.0);
    #else
        gl_FragColor = vec4(diffColor.rgb, diffColor.a);
    #endif
}
