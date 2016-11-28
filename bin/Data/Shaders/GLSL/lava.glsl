#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

uniform vec3 cFOGCOL;

varying vec2 vTexCoord;
varying vec4 vWorldPos;

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

	vec3 col = texture2D(sDiffMap,vWorldPos.xz * 0.01117 + vec2(sin(cElapsedTimePS * 0.2) * 0.01,cos(cElapsedTimePS * 0.311) * 0.01)).xyz;
	//vec4 heightmap = texture2D(sDiffMap, vTexCoord.xy);
	vec3 col2 = texture2D(sDiffMap,vWorldPos.xz * 0.04912 + col.xy * 2.1 + vec2(sin(cElapsedTimePS * 0.57) * 0.4,cos(cElapsedTimePS * 0.531) * 0.4)).xyz;
	//vec3 diffColor = col.xyz;
  
  float y = col2.z * 1. + col.z * 4.;
  vec3 cls = mix(vec3(0.9,0.1,0.01),vec3(0.8,0.7,0.1),abs(2.*(fract(y*0.977 + cElapsedTimePS*0.2)-0.5)));
  vec3 glowCol = cls * (0.02 + 2. * abs(fract(y*2 + cElapsedTimePS*1.33)-0.5));
  //glowCol = normalize(glowCol) * 2.;
  //glowCol *= col.a;
  float fog = min(pow(length(vWorldPos.xyz-cCameraPosPS)/cFarClipPS,1.2),1.);//

    vec3 color = mix(glowCol,cFOGCOL,fog);
    //color = mix(color,glowCol, col.a);

    #if defined(PREPASS)
        // Fill light pre-pass G-Buffer
        gl_FragData[0] = vec4(0.5, 0.5, 0.5, 1.0);
        gl_FragData[1] = vec4(EncodeDepth(vWorldPos.w), 0.0);
    #elif defined(DEFERRED)
        gl_FragData[0] = vec4(color,0.0);
        gl_FragData[1] = vec4(color.rgb, 0.0); //diffColor.rgb
        gl_FragData[2] = vec4(0.0);
        gl_FragData[3] = vec4(EncodeDepth(vWorldPos.w), 0.0);
    #else
        gl_FragColor = vec4(diffColor.rgb, diffColor.a);
    #endif
}
