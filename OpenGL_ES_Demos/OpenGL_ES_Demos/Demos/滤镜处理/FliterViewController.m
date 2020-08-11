//
//  FliterViewController.m
//  OpenGL_ES_Demos
//
//  Created by wenmei on 2020/8/8.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import "FliterViewController.h"
#import "ZZSegmentControl.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 positionCoord;   //(X,Y,Z)
    GLKVector2 textureCoord;    //(u,v)
}SenceVertix;


@interface FliterViewController ()<ZZSegmentControlDelegate>
//顶点数据
@property (nonatomic,assign) SenceVertix *vertices;
//上下文
@property (nonatomic,strong) EAGLContext *context;
//定时器
@property (nonatomic,strong) CADisplayLink *displayLink;
//开始时间戳
@property (nonatomic,assign) NSTimeInterval startTimeInterval;
//着色器程序
@property (nonatomic,assign) GLuint program;
//顶点缓冲区
@property (nonatomic,assign) GLuint vertixBuffer;
//纹理ID
@property (nonatomic,assign) GLuint textureID;


@end

@implementation FliterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化GL环境,滤镜
    [self loadGLAndFliter];
    //开始一个动画
//    [self startFliterAnimation];
    [self render];
    
    [self loadUI];
}

- (void)render
{
    //使用program
    glUseProgram(self.program);
    //绑定buffer
    glBindBuffer(GL_ARRAY_BUFFER, self.vertixBuffer);
    //清除画布
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1, 1, 1, 1);
    //重绘
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    //渲染到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
- (void)startFliterAnimation
{
    if(self.displayLink){
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    self.startTimeInterval = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeAction)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)timeAction
{
//    if(self.startTimeInterval == 0){
//        self.startTimeInterval = self.displayLink.timestamp;
//    }
    //使用program
    glUseProgram(self.program);
    //绑定buffer
    glBindBuffer(GL_ARRAY_BUFFER, self.vertixBuffer);
//    //传入时间
//    GLfloat currentTime = self.displayLink.timestamp - self.startTimeInterval;
//    GLuint time = glGetUniformLocation(self.program, "Time");
//    glUniform1f(time, currentTime);
    //清除画布
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1, 1, 1, 1);
    //重绘
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    //渲染到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)loadGLAndFliter
{
    //上下文
    self.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    //顶点数据(顶点坐标+纹理坐标)
    self.vertices = malloc(sizeof(SenceVertix) *4);
    self.vertices[0] = (SenceVertix){{-1,1,0},{0,1}};
    self.vertices[1] = (SenceVertix){{-1,-1,0},{0,0}};
    self.vertices[2] = (SenceVertix){{1,1,0},{1,1}};
    self.vertices[3] = (SenceVertix){{1,-1,0},{1,0}};
    
    //载入纹理
    NSString *imgPath = [[NSBundle mainBundle]pathForResource:@"jj" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
    CGImageRef imgRef = image.CGImage;
    float width = CGImageGetWidth(imgRef);
    float height = CGImageGetHeight(imgRef);
    float scaleWH = width/height;
    float layerW = self.view.frame.size.width - 220;
    float layerH = layerW/(scaleWH);
    //CAEAGLLayer
    CAEAGLLayer *layer = [CAEAGLLayer layer];
    layer.frame = CGRectMake((self.view.frame.size.width - layerW)/2, 30, layerW,layerH);
    layer.backgroundColor = [UIColor greenColor].CGColor;
    layer.contentsScale = [UIScreen mainScreen].scale;
    [self.view.layer addSublayer:layer];
    //绑定缓冲区到layer
    [self bindRenderLayer:layer];
    
    //将jpg 转为 纹理
    GLuint textureID = [self createTextureWithImage:image];
    self.textureID = textureID;
    //设置视口
    GLint drawableWidth = [self drawalbeWidth];
    GLint drawableHeight = [self drawalbeHeight];
    glViewport(0, 0,drawableWidth, drawableHeight);
    //设置顶点缓存区
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertix) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);
    //载入默认着色器
    [self setupNormalShaderProgram];
    //保存顶点数据，退出时释放
    self.vertixBuffer = vertexBuffer;
}
//绑定渲染缓冲区和帧缓冲区
- (void)bindRenderLayer:(CALayer <EAGLDrawable> *)layer
{
    //申请缓冲区
    GLuint renderBuffer;
    GLuint frameBuffer;
    //开辟，绑定 渲染缓冲区
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    //开辟，绑定 帧缓冲区
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
}
//image -> texture
- (GLuint)createTextureWithImage:(UIImage *)image
{
    CGImageRef imageRef = image.CGImage;
    if(!imageRef){
        NSLog(@"imageRef == null ");
        return 0;
    }
    CGFloat width = CGImageGetWidth(imageRef);
    CGFloat height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGRect rect = CGRectMake(0, 0, width, height);
    //图片解压后的数据指针
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    //图片翻转
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    
    CGContextDrawImage(context, rect, imageRef);
    //纹理载入
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    //设置过滤和环绕方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, 0);
    //释放上下文
    CGContextRelease(context);
    free(imageData);
    
    return textureID;
}

- (GLint)drawalbeWidth
{
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return backingWidth;
}
- (GLint)drawalbeHeight
{
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return backingHeight;
}

- (void)setupNormalShaderProgram
{
    [self setupShaderProgramWithName:@"Normal"];
}

//初始化着色器
- (void)setupShaderProgramWithName:(NSString *)name
{
    if([name isEqualToString:@""]){
        return;
    }
    //获取 着色器 program
    GLuint program = [self programWithShaderName:name];
    //使用program
    glUseProgram(program);
    //数据绑定
    GLuint positionSlot = glGetAttribLocation(program, "Position");
    GLuint textureSlot = glGetUniformLocation(program, "Texture");
    GLuint textureCoordsSlot = glGetAttribLocation(program, "TextureCoords");
    //激活纹理，绑定纹理ID
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    //纹理
    glUniform1i(textureSlot, 0);
    //打开Position通道，设置读取方式
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertix), NULL + offsetof(SenceVertix, positionCoord));
    //打开TextureCoords通道，设置读取方式
    glEnableVertexAttribArray(textureCoordsSlot);
    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertix), NULL + offsetof(SenceVertix, textureCoord));
    //保存progrem
    self.program = program;
}
// 创建program 并附着对应着色器
- (GLuint)programWithShaderName:(NSString *)shaderName
{
    GLuint vertexShader = [self compileShaderName:shaderName type:GL_VERTEX_SHADER];
    GLuint fragShader = [self compileShaderName:shaderName type:GL_FRAGMENT_SHADER];
    //将顶点和片元 附着到program上
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragShader);
    //link
    glLinkProgram(program);
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if(linkSuccess == GL_FALSE){
        GLchar message[512];
        glGetProgramInfoLog(program, sizeof(message), 0, &message[0]);
        NSLog(@"program link failed ! error:%s",message);
        exit(1);
    }
    return program;
}

//创建着色器
- (GLuint)compileShaderName:(NSString *)shaderName type:(GLenum)type
{
    NSString *shaderPath = [[NSBundle mainBundle]pathForResource:shaderName ofType:type == GL_VERTEX_SHADER? @"vsh":@"fsh"];
    NSError *error = nil;
    NSString *shaderStr = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if(error){
        NSLog(@"shader 读取失败！error:%@",error);
        exit(1);
    }
    //创建shader
    GLuint shader = glCreateShader(type);
    //给shader 添加source
    const char *shaderStringUTF8 = [shaderStr UTF8String];
    int shaderStrLength = (int)[shaderStr length];
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStrLength);
    //编译
    glCompileShader(shader);
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if(compileSuccess == GL_FALSE){
        GLchar message[512];
        glGetShaderInfoLog(shader, sizeof(message), 0, &message[0]);
        NSLog(@"shader compile failed ! error:%s",message);
        exit(1);
    }
    return shader;
}

- (void)loadUI
{
    self.view.backgroundColor = [UIColor blackColor];
    ZZSegmentControl *segmentControl = [[ZZSegmentControl alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width, 80) actions:@[@"原始图",@"二分图",@"三分图",@"四分图",@"六分图",@"九分图",@"灰度",@"翻转",@"马赛克1"]];
    segmentControl.delegate = self;
    [self.view addSubview:segmentControl];
}
- (void)itemDidSelectedWithIndex:(NSInteger)index
{
    NSLog(@"index == %ld",index);
    NSArray *filterArr = @[@"Normal",@"Filter_02",@"Filter_03",@"Filter_04",@"Filter_06",@"Filter_09",@"Gray_filter",@"Reversal",@"Mosaic"];
    [self setupShaderProgramWithName:filterArr[index]];
    [self render];
}


@end
