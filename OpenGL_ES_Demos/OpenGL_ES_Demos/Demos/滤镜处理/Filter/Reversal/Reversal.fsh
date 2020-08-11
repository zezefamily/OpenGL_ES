precision highp float;
uniform sampler2D Texture;
varying vec2 TextureCoordsVarying;

void main()
{
    vec4 mask = texture2D(Texture,vec2(1.0 - TextureCoordsVarying.x,TextureCoordsVarying.y));
    gl_FragColor = vec4(mask.rgb,1.0);
}
