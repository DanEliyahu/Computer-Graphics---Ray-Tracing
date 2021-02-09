// Implements an adjusted version of the Blinn-Phong lighting model
float3 blinnPhong(float3 n, float3 v, float3 l, float shininess, float3 albedo)
{
    float3 h = normalize(l + v);
    float3 diffuse = max(0, dot(n, l)) * albedo;
    float3 specular = float3(pow(max(0, dot(n, h)), shininess) * 0.4, pow(max(0, dot(n, h)), shininess) * 0.4, pow(max(0, dot(n, h)), shininess) * 0.4);
    return diffuse+specular;
}

// Reflects the given ray from the given hit point
void reflectRay(inout Ray ray, RayHit hit)
{
    // v is minus ray direction
    float3 r = 2*(dot(-ray.direction,hit.normal))*hit.normal + ray.direction;
    ray.direction = r;
    ray.origin = hit.position + EPS*hit.normal; // prevent acne
    ray.energy = ray.energy * hit.material.specular;
}

// Refracts the given ray from the given hit point
void refractRay(inout Ray ray, RayHit hit)
{
    float3 i = ray.direction;
    float eta1 = 1;
    float eta2 = hit.material.refractiveIndex;
    float3 n = hit.normal;
    if(dot(n,i) > 0)
    {
        eta1 = eta2;
        eta2 = 1;
        n = -n;
    }
    
    float c1 = abs(dot(n,i));
    float eta = eta1 / eta2;
    float c2 = sqrt(1 - (eta * eta) * (1 - c1 * c1));
    float3 t = normalize(eta*i + (eta*c1 - c2) * n);
    
    ray.origin = hit.position - n*EPS;  // covers both cases of coming in and out
    ray.direction = t;
}

// Samples the _SkyboxTexture at a given direction vector
float3 sampleSkybox(float3 direction)
{
    float theta = acos(direction.y) / -PI;
    float phi = atan2(direction.x, -direction.z) / -PI * 0.5f;
    return _SkyboxTexture.SampleLevel(sampler_SkyboxTexture, float2(phi, theta), 0).xyz;
}