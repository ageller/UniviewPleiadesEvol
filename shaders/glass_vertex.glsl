in vec3 uv_vertexAttrib;
in vec3 uv_normalAttrib;

uniform mat4 uv_modelViewProjectionMatrix;
uniform mat4 uv_modelViewInverseMatrix;

out vec3 normal;
out vec3 viewDirection;

void main(void)
{
    normal = uv_normalAttrib;
    viewDirection = uv_vertexAttrib - (uv_modelViewInverseMatrix * vec4(0, 0, 0, 1)).xyz;

    gl_Position = uv_modelViewProjectionMatrix * vec4(uv_vertexAttrib, 1);
}
