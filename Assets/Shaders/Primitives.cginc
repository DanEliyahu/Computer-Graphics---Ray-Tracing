// Checks for an intersection between a ray and a sphere
// The sphere center is given by sphere.xyz and its radius is sphere.w
void intersectSphere(Ray ray, inout RayHit bestHit, Material material, float4 sphere)
{
  
    float A = 1;
    float B = 2 * dot((ray.origin - sphere.xyz), ray.direction);
    float C = dot((ray.origin - sphere.xyz), (ray.origin - sphere.xyz)) - sphere.w*sphere.w;
    float dis = B * B - 4 * A * C;
    if (dis < 0)
    {
        return;
    }
    float t1 = (-B + sqrt(dis)) / (2 * A);
    float t2 = (-B - sqrt(dis)) / (2 * A);
    float tFinal = 1.#INF;
    if (t2 > 0) // t2 will always be sameller then t1 , so if its valid solution wh will chose it 
    {
        tFinal = t2; 
        
    }
    // incase t2<=0 o
    else if (t1 > 0)
    {
        tFinal = t1;
    }
    // meaning no intersectaion
    if (isinf(tFinal))
    {
        return;
    }
    // meaning the ditance of the intersectiaon is greater then the best hit , so no need th change 
    if (tFinal >= bestHit.distance)
    {
        return;
    }
    bestHit.distance = tFinal;  /// ||o+td-o|| = ||td|| = |t|*||d||=|t| 
    bestHit.position= ray.origin + tFinal * ray.direction;
    bestHit.normal = normalize(bestHit.position - sphere.xyz); // the normal of a point in a phere is the vetor from the center toward the point  
    bestHit.material = material; 
    
    
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
void intersectPlane(Ray ray, inout RayHit bestHit, Material material, float3 c, float3 n)
{
    if (dot(n, ray.direction) == 0)
    {
        return;
    }
    float t = -(dot(ray.origin - c, n) / dot(n, ray.direction));
    if (t < 0 || t>bestHit.distance) // the palne is behind the view point or farther then the best hit 
    { 
        return;
        
    }
    bestHit.distance = t; /// ||o+td-o|| = ||td|| = |t|*||d||=|t| 
    bestHit.position = ray.origin + t * ray.direction;
    bestHit.normal = n;
    bestHit.material = material;
    
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
// The material returned is either m1 or m2 in a way that creates a checkerboard pattern 
void intersectPlaneCheckered(Ray ray, inout RayHit bestHit, Material m1, Material m2, float3 c, float3 n)
{
    if (dot(n, ray.direction) == 0)
    {
        return;
    }
    float t = -(dot(ray.origin - c, n) / dot(n, ray.direction));
    if (t < 0 || t>bestHit.distance) // the palne is behind the view point or farther then the best hit 
    { 
        return;
        
    }
    // if we hit
    bestHit.distance = t; /// ||o+td-o|| = ||td|| = |t|*||d||=|t| 
    float3 hitPoint = ray.origin + t * ray.direction;
    bestHit.position = hitPoint;
    bestHit.normal = n;
    // choosing material
    float x = hitPoint.x;
    float y = hitPoint.y;
    float z = hitPoint.z;
    // position in 2d checkerboard
    float u;
    float v;
    if(n.x != 0)
    {
        u = y;
        v = z; 
    }
    else if(n.y != 0)
    {
        u = z;
        v = x;
    }
    else
    {
        u = x;
        v = y;
    }
    float sign_u = sign(u);
    float sign_v = sign(v);
    u = abs(u);
    v = abs(v);
    float u_tag = sign_u * frac(u) - sign_u*0.5;
    float v_tag = sign_v * frac(v) - sign_v*0.5;
    if(u_tag*v_tag >=0)
    {
        bestHit.material = m1;
    }
    else
    {
        bestHit.material = m2;
    }
}


// Checks for an intersection between a ray and a triangle
// The triangle is defined by points a, b, c
void intersectTriangle(Ray ray, inout RayHit bestHit, Material material, float3 a, float3 b, float3 c)
{
    float3 v1 = a - c;
    float3 v2 = b - c;
    float3 n = normalize(cross(v1, v2));
    // calcultae intersectaion between the ray al the whole plane 
    if (dot(n, ray.direction) == 0)
    {
        return;
    }
    float t = -(dot(ray.origin - c, n) / dot(n, ray.direction));
    
    if (t < 0 || t > bestHit.distance) // the palne is behind the view point or farther then the best hit 
    {
        return;
        
    }
    // incase the point is relevant we want to find if its inside the triangle
    float3 p = ray.origin + t * ray.direction; // the hitting point 
    float3 cp = p - c;
    float3 crossv1cp = cross(v1, cp); // supposed to be in the  direction of the noraml if p in insdie the traingle 
    float3 bp = p - b; 
    float3 crossv2bp = cross(bp, v2); // supposed to be in the  direction of the noraml if p in insdie the traingle 
    float3 v3 = b - a; 
    float3 ap = p - a;
    float3 crossv3ap = cross(v3, ap); // supposed to be in the  direction of the noraml if p in insdie the traingle 
    if (dot(crossv1cp, n) >= 0 && dot(crossv2bp, n) >= 0 && dot(crossv3ap, n) >= 0) // p is inside the triangle 
    {
        bestHit.distance = t; /// ||o+td-o|| = ||td|| = |t|*||d||=|t| 
        bestHit.position = p;
        bestHit.normal = n;
        bestHit.material = material;
    }

}


// Checks for an intersection between a ray and a 2D circle
// The circle center is given by circle.xyz, its radius is circle.w and its orientation vector is n 
void intersectCircle(Ray ray, inout RayHit bestHit, Material material, float4 circle, float3 n)
{
    // check if we intersect with the circle plane
    if (dot(n, ray.direction) >= 0) // if the view direction is the same as normal we can't see the circle
    {
        return;
    }
    float t = -(dot(ray.origin - circle.xyz, n) / dot(n, ray.direction));
    if (t < 0 || t>bestHit.distance) // the palne is behind the view point or farther then the best hit 
    { 
        return;
        
    }
    // incase the point is relevant we want to find if its inside the circle
    float3 position = ray.origin + t * ray.direction;
    if(length(position - circle.xyz) > circle.w)  // outside of the circle
    {
        return;
    }
    bestHit.distance = t; /// ||o+td-o|| = ||td|| = |t|*||d||=|t|
    bestHit.position = position;
    bestHit.normal = n;
    bestHit.material = material;
}


// Checks for an intersection between a ray and a cylinder aligned with the Y axis
// The cylinder center is given by cylinder.xyz, its radius is cylinder.w and its height is h
void intersectCylinderY(Ray ray, inout RayHit bestHit, Material material, float4 cylinder, float h)
{
    intersectCircle(ray, bestHit, material, float4(cylinder.x, cylinder.y + h/2, cylinder.z,cylinder.w), float3(0,1,0));
    intersectCircle(ray, bestHit, material, float4(cylinder.x, cylinder.y - h/2, cylinder.z,cylinder.w), float3(0,-1,0));
    // from formula of infinite Y cylinder
    float A = ray.direction.x * ray.direction.x + ray.direction.z * ray.direction.z;
    float B = 2*(ray.origin.x * ray.direction.x + ray.origin.z * ray.direction.z - cylinder.x * ray.direction.x - cylinder.z * ray.direction.z);
    float C = (ray.origin.x - cylinder.x) * (ray.origin.x - cylinder.x) + (ray.origin.z - cylinder.z) * (ray.origin.z - cylinder.z) - cylinder.w * cylinder.w;
    float dis = B * B - 4 * A * C;
    if (dis < 0)
    {
        return;
    }
    float t1 = (-B + sqrt(dis)) / (2 * A);
    float t2 = (-B - sqrt(dis)) / (2 * A);
    float3 p1 = ray.origin + t1 * ray.direction;
    float3 p2 = ray.origin + t2 * ray.direction;
    float tFinal = 1.#INF;
    if (t2 > 0 && abs(p2.y - cylinder.y) <= h/2) // t2 will always be smaller then t1 , so if its valid solution wh will chose it 
    {
        tFinal = t2;   
    }
    // incase t2<=0 o
    else if (t1 > 0 && abs(p1.y - cylinder.y) <= h/2)
    {
        tFinal = t1;
    }
    // meaning no intersectaion
    if (isinf(tFinal))
    {
        return;
    }
    // meaning the ditance of the intersectiaon is greater then the best hit , so no need th change 
    if (tFinal >= bestHit.distance)
    {
        return;
    }
    bestHit.distance = tFinal;  /// ||o+td-o|| = ||td|| = |t|*||d||=|t| 
    bestHit.position= ray.origin + tFinal * ray.direction;
    bestHit.normal = normalize(bestHit.position - float3(cylinder.x, bestHit.position.y, cylinder.z)); // normal is intersection point minus center at intersection y-level 
    bestHit.material = material;     
}
