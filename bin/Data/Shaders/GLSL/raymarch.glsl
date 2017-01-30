#include "Uniforms.glsl"
#include "Samplers.glsl"
//#define DEFERRED;
#include "Transform.glsl"
#include "ScreenPos.glsl"
#include "fractal.glsl"
//out vec4 fragData[4];
//#define gl_FragData fragData

uniform float cRAY_STEPS;
uniform vec3 cFOGCOL;

varying vec2 vScreenPos;
//varying vec3 direction;
varying mat4 cViewProjPS;
varying float fov;
varying vec3 FrustumSizePS;
varying mat4 ViewPS;



void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);
    vec2 pos = GetScreenPosPreDiv(gl_Position);
    pos = pos;

    vScreenPos = pos;
    //cViewProjPS = cViewProj;
    vec3 pos3 = vec3(pos,1.0) * cFrustumSize;
    fov = atan(cFrustumSize.y/cFrustumSize.z);
    FrustumSizePS = cFrustumSize;
    ViewPS = cView;


}


float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
    float t = mint;
    for( int i=0; i<8; i++ )
    {
		float h = sdfmap( ro + rd*t );
        res = min( res, 3.0*h/t );
        t += clamp( h, 0.02, 20. );
        if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );

}


void PS()
{
  vec3 locDir = normalize(vec3(vScreenPos * 2.0 -1.0,1.0) * FrustumSizePS);
  vec3 direction = (mat3(ViewPS) * locDir  );
  vec3 origin = cCameraPosPS;
  vec3 normal;
  vec3 intersection;
  //vec3 direction = camMat * normalize( vec3(uv.xy,2.0) );
  float PREdepth =  texture2D(sSpecMap, vScreenPos).r;

  float distance = 0.;
  float totalDistance = PREdepth;// * cFarClipPS;
  float lfog = 0.;
  float pxsz = fov * cGBufferInvSize.y;


  float distTrsh = 0.002;
  int stps = 0;

  for(int i =0 ;  i < cRAY_STEPS; ++i) ////// Rendering main scene
   {
       intersection = origin + direction * totalDistance;

       distance = sdfmap(intersection);
      totalDistance += distance;
       #ifdef PREMARCH
          distTrsh = pxsz * totalDistance * 1.4142;
          if(distance <= distTrsh || totalDistance >= cFarClipPS) break;
          totalDistance += distTrsh * 0.6;
        #else
          if(distance <= 0.002 || totalDistance >= cFarClipPS) break;
       #endif



      // stps = i;
   }

   #ifndef PREMARCH

     //vec4 clpp = vec4(intersection,1.0) * cViewProjPS;
     float fdepth = (totalDistance*locDir.z)/cFarClipPS; //clpp.z /(cFarClipPS);

      //vec3 diffColor = normalize(vec3(pow(distance.r,-0.6),abs(1.7- distance.g),abs(1.7- distance.b)));
      vec3 diffColor = vec3(0.5);

      vec3 ambient = diffColor.rgb;

      float depth = DecodeDepth(texture2D(sDepthBuffer, vScreenPos).rgb);

      if (fdepth>depth) discard;

      vec3 txt = texture2D(sDiffMap,vec2(intersection.x * 0.1,intersection.z* 0.1) ).rgb;
      vec3 col = texture2D(sNormalMap, vec2(txt.g,intersection.y*0.07 + txt.r * 0.015)).rgb;
      //vec3 col = txt;
      vec3 lightVec = normalize(vec3(0.3,0.4,0.2));
      float shad = softshadow(intersection, lightVec, 0.1,250.);

      col*=0.3 + shad;

      float fog = min(pow(totalDistance/cFarClipPS,1.2),1.);//

      if (totalDistance<0.1){
         col *= vec3(1.0,0.2,0.2);
         fog = 0.;
       }

  #endif



  //gl_FragColor = vec4(ambient , 1.0);
  #ifndef PREMARCH
    gl_FragData[0] = vec4(mix(col,cFOGCOL,fog),0.);//vec4(vec3(0.3) * (1.-fog),1.0); //distance.r * 0.2
    gl_FragData[1] = vec4(1.5);
    //gl_FragData[0] = vec4(float(stps)/256,0.,0.,0.);//vec4(float(stps)/cRAY_STEPS,0.,0.,0.);//vec4(mimus , plus,0.,0.); //vec4(vec3(0.3) * (1.-fog),1.0);
    //gl_FragData[1] = vec4(0.);//vec4(diffColor.rgb * fog, 1.7 );



    gl_FragData[2] = vec4(0.0,1.,0.,0.);// * 0.5 + 0.5
    gl_FragData[3] = vec4(EncodeDepth(fdepth), 0.0);//
  #else
    gl_FragColor =  vec4(totalDistance ,0. , 0. , 0.);
  #endif
}
