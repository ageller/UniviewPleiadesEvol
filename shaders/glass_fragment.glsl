uniform vec3 edgeColor = vec3(0.6, 0.6, 0.898);
uniform vec3 centerColor = vec3(0.898, 0.435, 0.435);
uniform float brightness = 3.0;
uniform float falloffPower = 7.0;
uniform float uv_fade;

in vec3 normal;
in vec3 viewDirection;

out vec4 fragColor;

void main(void)
{
    float facing = abs(dot(normalize(normal), normalize(viewDirection)));

    float glassBrightness = pow(1. - facing, falloffPower) * smoothstep(0.05, 0.3, facing);
    glassBrightness *= brightness;
    vec3 color = mix(edgeColor, centerColor, smoothstep(0.1, 0.5, facing));
    fragColor = vec4(color * glassBrightness * uv_fade, 1.);
}
