// Position as input variable for shader. Attribute is only available in the vertex shader.
attribute vec4 position;
attribute mediump vec4 textureCoordinate;
varying mediump vec2 coordinate;
// Vertex shader
void main()
{
	gl_Position = position * vec4(1,-1,1,1);
	coordinate = textureCoordinate.xy;
}
