uniform float cANIM;
uniform float cPHASE;

float hash(float h) {
	return fract(sin(h) * 43758.5453123);
}



float noise3d(vec3 x) {
	vec3 p = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);

	float n = p.x + p.y * 157.0 + 113.0 * p.z;
	return mix(
			mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
					mix(hash(n + 157.0), hash(n + 158.0), f.x), f.y),
			mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
					mix(hash(n + 270.0), hash(n + 271.0), f.x), f.y), f.z);
}

vec2 hash22(vec2 p) {

    // Faster, but probably doesn't disperse things as nicely as other ways.
    float n = sin(dot(p,vec2(41, 289)));
    p = fract(vec2(8.0*n, n)*262144.);
    return sin(p*6.2831853 + cANIM);
}

float Voronoi3Tap(vec2 p){

	// Simplex grid stuff.
    //
    vec2 s = floor(p + (p.x+p.y)*0.3660254); // Skew the current point.
    p -= s - (s.x+s.y)*0.2113249; // Use it to attain the vector to the base vertice (from p).

    // Determine which triangle we're in. Much easier to visualize than the 3D version.
    float i = step(0.0, p.x-p.y);

    // Vectors to the other two triangle vertices.
    vec2 p1 = p - vec2(i, 1.0-i) + 0.2113249, p2 = p - 0.5773502;

    // Add some random gradient offsets to the three vectors above.
    p += hash22(s)*0.125;
    p1 += hash22(s +  vec2(i, 1.0-i))*0.125;
    p2 += hash22(s + 1.0)*0.125;

    // Determine the minimum Euclidean distance. You could try other distance metrics,
    // if you wanted.
    float d = min(min(dot(p, p), dot(p1, p1)), dot(p2, p2))/0.425;

    // That's all there is to it.
    return sqrt(d); // Take the square root, if you want, but it's not mandatory.

}

float apo(vec3 pos)
{
  float dist;
  vec3 CSize = vec3(1., 1., 1.3);
  vec3 p = pos.xzy;
  float scale = 1.0;

  float r2 = 0.;
  float k = 0.;
  float uggg = 0.;
  for( int i=0; i < 9;i++ )
  {
      p = 2.0*clamp(p, -CSize, CSize) - p;
      r2 = dot(p,p);
      //float r2 = dot(p,p+sin(p.z*.3)); //Alternate fractal
      k = max((2.0)/(r2), .0274); //.378888 //.13345 max((2.6)/(r2), .03211); //max((1.8)/(r2), .0018);
      p     *= k;
      scale *= k;
      uggg += r2;
  }
  float l = length(p.xy);
  float rxy = l - 4.0;
  float n = 1.0 * p.z;
  rxy = max(rxy, -(n) / 4.);
  dist = (rxy) / abs(scale);
  return dist;
}

float kali(vec3 p) {

	//p.y = mod(p.y + 1.2, 2.4) - 1.2;
	vec4 q = vec4(p, 1);
	float orb = 10000.0;
	for(int i = 0; i < 12; i++) {
        // 3D Kaliset formula
		q = 5.0*abs(q)/dot(q.xyz, q.xyz) - vec4(2.5, 1.2, 2.5, 0);

        // some random orbit trap.  Based on sqaure cosine.
		orb = min(orb, sin(abs(q.x*q.y)));
	}

	return (length(q.xyz))/q.w - 0.01;
}

float sdSphere( vec3 p, float s )
{
    return length(p)-s;
}

vec3 pointRepetition(vec3 point, vec3 c)
{
	point.x = mod(point.x, c.x) - 0.5*c.x;
	point.z = mod(point.z, c.z) - 0.5*c.z;
	return point;
}

float sdfmap(vec3 pos)
{
	float vtime = cANIM;
	float dist = 10000.;
	#ifndef LV2
	  vec3 npos = pos;
	  npos.y += vtime;
	  npos.xz *= 0.6;
		float ftime =  min(vtime * 0.01,1.);
	  float noise = noise3d(npos * 0.1) * 10.;

		vec3 apopos = pointRepetition(pos,vec3(500.,0,500.));

	  float apodist = 0.1 * (7+pos.y) - apo(apopos * 0.5) * 2.  * ftime;
	  dist = 0.2  * pos.y + noise * pow(min(vtime * 0.05,1.),2.2);
	  dist = min(mix(pos.y,noise,ftime) -(apodist),dist+apodist);
	#else
		float v = Voronoi3Tap(pos.xz * 0.01) * 10.;
		vec3 kpos = pointRepetition(pos ,vec3(500.,0,500.));
		float k = kali(kpos * 0.02) * 10.;
		dist = pos.y + 15.;
		float sph = sdSphere(vec3(2.+2.*v, pos.y,2.+2.*v),20.);
		dist = min(max(sph,  0.7 - 1. * k),dist + k *0.5);
		dist = min(dist, max(-pos.y * 0.2 + 10.+ 2. * (1. -v) , k));
	#endif
  return dist;
}
