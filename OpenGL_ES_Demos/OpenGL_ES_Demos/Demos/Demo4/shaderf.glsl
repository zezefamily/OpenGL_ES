precision highp float;

varying lowp vec4 varyColor;
varying lowp vec2 vTextCoor;
uniform sampler2D colorMap;

void main()
{
    vec4 waakMask = texture2D(colorMap,vTextCoor);
    vec4 mask = varyColor;
    float alpha = 0.5;
    vec4 tempColor = mask * (1.0 - alpha) + waakMask * alpha;
    gl_FragColor = tempColor;
}
