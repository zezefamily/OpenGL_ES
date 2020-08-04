//
//  Demo4View.m
//  OpenGL_ES_Demos
//
//  Created by 泽泽 on 2020/8/4.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import "Demo4View.h"
#import <OpenGLES/ES2/gl.h>
#import "GLESMath.h"
#import "GLESUtils.h"
@interface Demo4View ()
{
    float xDegree;
    float yDegree;
    float zDegree;
    BOOL bX;
    BOOL bY;
    BOOL bZ;
    NSTimer *_myTimer;
}
@property (nonatomic,strong) CAEAGLLayer *myEaglLayer;
@property (nonatomic,strong) EAGLContext *myContext;

@property (nonatomic,assign) GLuint myColorRenderBuffer;
@property (nonatomic,assign) GLuint myColorFrameBuffer;

@property (nonatomic,assign) GLuint myProgram;
@property (nonatomic,assign) GLuint myVertices;

@end
@implementation Demo4View

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self == [super initWithFrame:frame]){
        [self loadUI];
    }
    return self;;
}
- (void)loadUI
{
    [self loadLayer];
    [self loadContext];
    [self clearBuffers];
    [self loadRenderBuffer];
    [self loadFrameBuffer];
//    [self reanderTexture];
//    [self reDegree];
    [self startDisplayLink];
}

- (void)startDisplayLink
{
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(reDegree)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)loadLayer
{
    //1.初始化layer 2.设置layer比例 3.设置绘制属性
    self.myEaglLayer = (CAEAGLLayer *)self.layer;
    self.myEaglLayer.contentsScale = [UIScreen mainScreen].scale;
    self.myEaglLayer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking:@(NO),
        kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8
    };
}
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}
- (void)loadContext
{
    //1.初始化上下文 2.设置当前上下文
    self.myContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if(!self.myContext){
        NSLog(@"context 初始化出错");
        return;
    }
    BOOL success = [EAGLContext setCurrentContext:self.myContext];
    if(!success){
        NSLog(@"设置 上下文发生错误");
        return;
    }
}
- (void)clearBuffers
{
    glDeleteBuffers(1, &_myColorRenderBuffer);
    _myColorRenderBuffer = 0;
    glDeleteBuffers(1, &_myColorFrameBuffer);
    _myColorFrameBuffer = 0;
}
- (void)loadRenderBuffer
{
    //1.申请渲染缓冲区 2.绑定渲染缓冲区 3.建立上下文关系
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.myColorRenderBuffer = buffer;
    
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEaglLayer];
}
- (void)loadFrameBuffer
{
    //1.申请帧缓冲区 2.绑定帧缓冲区 3.建立帧缓存区和渲染缓存区的关系
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    self.myColorFrameBuffer = buffer;
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    
    //??????不是很理解
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}

- (void)reanderTexture
{
    //清屏
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    //设置视口
    CGFloat scale = [UIScreen mainScreen].scale;
    glViewport(0, 0, self.frame.size.width * scale, self.frame.size.height * scale);
    //获取着色器文件路径
    NSString *vertFile = [[NSBundle mainBundle]pathForResource:@"shaderv" ofType:@"glsl"];
    NSString *fragFile = [[NSBundle mainBundle]pathForResource:@"shaderf" ofType:@"glsl"];
    //清空program,这个东西主要是用于管理着色器
    if(self.myProgram){
        glDeleteProgram(self.myProgram);
        self.myProgram = 0;
    }
    //把glsl文件加载到myProgram
    self.myProgram = [self loadShader:vertFile frag:fragFile];
    //开始链接 myProgram
    glLinkProgram(self.myProgram);
    //获取链接状态
    GLint linkState;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkState);
    if(linkState ==  GL_FALSE){
        GLchar message[512];
        glGetProgramInfoLog(self.myProgram, sizeof(message), 0, &message[0]);
        NSString *messageStr = [NSString stringWithUTF8String:message];
        NSLog(@"errorInfo = %@",messageStr);
        return;
    }
    NSLog(@"link success");
    //使用myProgram
    glUseProgram(self.myProgram);
    
    //构造顶点数据(x,y,z,r,g,b)
//    GLfloat attrArr[] =
//    {
//        -0.5f, 0.5f, 0.0f,      1.0f, 0.0f, 1.0f, //左上0
//        0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 1.0f, //右上1
//        -0.5f, -0.5f, 0.0f,     1.0f, 1.0f, 1.0f, //左下2
//        0.5f, -0.5f, 0.0f,      1.0f, 1.0f, 1.0f, //右下3
//        0.0f, 0.0f, 1.0f,       0.0f, 1.0f, 0.0f, //顶点4
//    };
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       0.0f, 1.0f,//左上
        0.5f, 0.5f, 0.0f,       0.0f, 0.5f, 0.0f,       1.0f, 1.0f,//右上
        -0.5f, -0.5f, 0.0f,     0.5f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
        0.5f, -0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       1.0f, 0.0f,//右下
        0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
    };
    
    //(2).索引数组
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
     //顶点数据
    //开辟 绑定 顶点缓冲区 copy数据 开启 设置读取方式
    if(self.myVertices == 0){
        glGenBuffers(1, &_myVertices);
    }
    glBindBuffer(GL_ARRAY_BUFFER, _myVertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    //这里是自定义的着色器 所以取自己着色器的标识(其实就是在setValueForKey)
    //上面已经把所有数据都载入到了显存，这个给着色器中每个key设置读取数据的方式
    //获取Key
    //position
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    //打开key通道
    glEnableVertexAttribArray(position);
    //设置读取方式
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, NULL);
    
    //positionColor
    GLuint positionColor = glGetAttribLocation(self.myProgram, "positionColor");
    glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (float *)NULL + 3);
    
    //textCoor
    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoor");
    glEnableVertexAttribArray(textCoor);
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (float *)NULL + 6);
    
    //载入一个纹理
    NSString *path = [[NSBundle mainBundle]pathForResource:@"jj" ofType:@"jpg"];
    [self loadTexture:path];
    //colorMap
    GLint colorMap = glGetUniformLocation(self.myProgram, "colorMap");
    glUniform1i(colorMap, 0);
    
    //projectionMatrix
    GLuint projectionMatrix = glGetUniformLocation(self.myProgram, "projectionMatrix");
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    float aspect = width / height;
    KSMatrix4 _projectionMat4;
    ksMatrixLoadIdentity(&_projectionMat4);
    ksPerspective(&_projectionMat4, 30.0, aspect, 5.0f, 20.0f);
    //赋值
    glUniformMatrix4fv(projectionMatrix, 1, GL_FALSE,(GLfloat *)&_projectionMat4.m[0][0]);
    
    //modelViewMatrix
    GLuint modelViewMatrix = glGetUniformLocation(self.myProgram, "modelViewMatrix");
    //创建一个模型视图矩阵
    KSMatrix4 _modelViewMat4;
    ksMatrixLoadIdentity(&_modelViewMat4);
    //平移
    ksTranslate(&_modelViewMat4, 0.0,0.0 , -10.0);
    //创建一个旋转矩阵
    KSMatrix4 _rotateMat4;
    ksMatrixLoadIdentity(&_rotateMat4);
    //旋转
    ksRotate(&_rotateMat4, xDegree, 1.0, 0.0, 0.0);
    ksRotate(&_rotateMat4, yDegree, 0.0, 1.0, 0.0);
    ksRotate(&_rotateMat4, zDegree, 0.0, 0.0, 1.0);
    //相乘
    ksMatrixMultiply(&_modelViewMat4, &_rotateMat4, &_modelViewMat4);
    //赋值
    glUniformMatrix4fv(modelViewMatrix, 1, GL_FALSE, (GLfloat *)&_modelViewMat4.m[0][0]);
    
    //开启正背面消除
    glEnable(GL_CULL_FACE);
    
    //使用索引绘图
    //glDrawElements (GLenum mode, GLsizei count, GLenum type, const GLvoid* indices)
    //mode 图元方式 count 绘图个数
    //type 每个元素的数据类型
    //indices 数据
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(GLuint), GL_UNSIGNED_INT, indices);
    
    //显示到layer
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
    
    
}
- (GLuint)loadShader:(NSString *)vert frag:(NSString *)frag
{
    GLuint vertShader = 0;
    GLuint fragShader = 0;
    //创建程序
    GLuint program = glCreateProgram();
    //TODO...
    //链接文件(将glsl 文件 跟 shader对象 关联起来)
    [self compileShader:&vertShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    //将shader对象 附着到program
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    //附着完成后，清理shader
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);
    return program;
}
//链接shader文件
- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
   //读取着色器文件内容
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
    if(error){
        NSLog(@"error:\n%@读取失败",file);
    }
    const GLchar *source = [content UTF8String];
    //创建着色器
    *shader = glCreateShader(type);
    //将内容添加到着色器
    glShaderSource(*shader, 1, &source, NULL);
    //链接
    glCompileShader(*shader);
}

- (GLuint)loadTexture:(NSString *)fileName
{
    CGImageRef refImg = [UIImage imageWithContentsOfFile:fileName].CGImage;
    if(!refImg){
        NSLog(@"failed to load image %@",fileName);
        return -1;
    }
    size_t width = CGImageGetWidth(refImg);
    size_t height = CGImageGetHeight(refImg);
    CGColorSpaceRef colorSpace =  CGImageGetColorSpace(refImg);
    //获取图片字节数
    GLubyte *refImgData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    //创建上下文
    CGContextRef context = CGBitmapContextCreate(refImgData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), refImg);
    CGContextRelease(context);
    
    //绑定纹理ID
    glBindTexture(GL_TEXTURE_2D, 0);
    //设置纹理过滤方式和环绕方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //载入纹理
    float fw = width,fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, refImgData);
    
    //释放
    free(refImgData);
    
    return 0;
}


-(void)reDegree
{
    //如果停止X轴旋转，X = 0则度数就停留在暂停前的度数.
    //更新度数
    xDegree += 0.25;
    yDegree += 0.35;
    zDegree += 0.45;
    //重新渲染
    [self reanderTexture];
    
}

@end
