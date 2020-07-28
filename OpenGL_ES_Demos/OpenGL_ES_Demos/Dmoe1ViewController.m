
//
//  Dmoe1ViewController.m
//  OpenGL_ES_Demos
//
//  Created by wenmei on 2020/7/27.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import "Dmoe1ViewController.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 positionCoord; //顶点坐标
    GLKVector2 textureCoord;  //纹理坐标
    GLKVector3 normal;        //法线
}ZZVertex;
//顶点数
static NSInteger const kCoorCount = 36;

@interface Dmoe1ViewController ()<GLKViewDelegate>

@property (nonatomic,strong) GLKView *glkView;
@property (nonatomic,strong) GLKBaseEffect *baseEffect;
@property (nonatomic,assign) ZZVertex *vertices;

@property (nonatomic,strong) CADisplayLink *displayLink;
@property (nonatomic,assign) NSInteger angle;
@property (nonatomic,assign) GLuint vertexBuffer;

@end

@implementation Dmoe1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor yellowColor];
    [self loadEGL];
    [self addDisplayLink];
}

- (void)addDisplayLink
{
    self.angle = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

}
- (void)loadEGL
{
    //创建上下文
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
    //设置上下文
    [EAGLContext setCurrentContext:context];
    
    //创建视图
    self.glkView = [[GLKView alloc]initWithFrame:self.view.bounds context:context];
    self.glkView.backgroundColor = [UIColor yellowColor];
    self.glkView.delegate = self;
    //使用深度测试
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glDepthRangef(1, 0);
    [self.view addSubview:self.glkView];
    
    //获取纹理图片
    NSString *imgPath = [[NSBundle mainBundle]pathForResource:@"jj" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
    //获取纹理信息
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft:@(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:options error:nil];
    
    //使用baseEffect
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
    //开启光照
    self.baseEffect.light0.enabled = YES;
    //设置漫反射颜色
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1);
    //光源位置
    self.baseEffect.light0.position = GLKVector4Make(-0.5, -0.5, 5, 1);
    
    //构造顶点数据
    self.vertices = malloc(sizeof(ZZVertex) * kCoorCount);
    
    // 前面
    self.vertices[0] = (ZZVertex){{-0.5, 0.5, 0.5}, {0, 1}, {0, 0, 1}};
    self.vertices[1] = (ZZVertex){{-0.5, -0.5, 0.5}, {0, 0}, {0, 0, 1}};
    self.vertices[2] = (ZZVertex){{0.5, 0.5, 0.5}, {1, 1}, {0, 0, 1}};
    self.vertices[3] = (ZZVertex){{-0.5, -0.5, 0.5}, {0, 0}, {0, 0, 1}};
    self.vertices[4] = (ZZVertex){{0.5, 0.5, 0.5}, {1, 1}, {0, 0, 1}};
    self.vertices[5] = (ZZVertex){{0.5, -0.5, 0.5}, {1, 0}, {0, 0, 1}};
    
    // 上面
    self.vertices[6] = (ZZVertex){{0.5, 0.5, 0.5}, {1, 1}, {0, 1, 0}};
    self.vertices[7] = (ZZVertex){{-0.5, 0.5, 0.5}, {0, 1}, {0, 1, 0}};
    self.vertices[8] = (ZZVertex){{0.5, 0.5, -0.5}, {1, 0}, {0, 1, 0}};
    self.vertices[9] = (ZZVertex){{-0.5, 0.5, 0.5}, {0, 1}, {0, 1, 0}};
    self.vertices[10] = (ZZVertex){{0.5, 0.5, -0.5}, {1, 0}, {0, 1, 0}};
    self.vertices[11] = (ZZVertex){{-0.5, 0.5, -0.5}, {0, 0}, {0, 1, 0}};
    
    // 下面
    self.vertices[12] = (ZZVertex){{0.5, -0.5, 0.5}, {1, 1}, {0, -1, 0}};
    self.vertices[13] = (ZZVertex){{-0.5, -0.5, 0.5}, {0, 1}, {0, -1, 0}};
    self.vertices[14] = (ZZVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, -1, 0}};
    self.vertices[15] = (ZZVertex){{-0.5, -0.5, 0.5}, {0, 1}, {0, -1, 0}};
    self.vertices[16] = (ZZVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, -1, 0}};
    self.vertices[17] = (ZZVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, -1, 0}};
    
    // 左面
    self.vertices[18] = (ZZVertex){{-0.5, 0.5, 0.5}, {1, 1}, {-1, 0, 0}};
    self.vertices[19] = (ZZVertex){{-0.5, -0.5, 0.5}, {0, 1}, {-1, 0, 0}};
    self.vertices[20] = (ZZVertex){{-0.5, 0.5, -0.5}, {1, 0}, {-1, 0, 0}};
    self.vertices[21] = (ZZVertex){{-0.5, -0.5, 0.5}, {0, 1}, {-1, 0, 0}};
    self.vertices[22] = (ZZVertex){{-0.5, 0.5, -0.5}, {1, 0}, {-1, 0, 0}};
    self.vertices[23] = (ZZVertex){{-0.5, -0.5, -0.5}, {0, 0}, {-1, 0, 0}};
    
    // 右面
    self.vertices[24] = (ZZVertex){{0.5, 0.5, 0.5}, {1, 1}, {1, 0, 0}};
    self.vertices[25] = (ZZVertex){{0.5, -0.5, 0.5}, {0, 1}, {1, 0, 0}};
    self.vertices[26] = (ZZVertex){{0.5, 0.5, -0.5}, {1, 0}, {1, 0, 0}};
    self.vertices[27] = (ZZVertex){{0.5, -0.5, 0.5}, {0, 1}, {1, 0, 0}};
    self.vertices[28] = (ZZVertex){{0.5, 0.5, -0.5}, {1, 0}, {1, 0, 0}};
    self.vertices[29] = (ZZVertex){{0.5, -0.5, -0.5}, {0, 0}, {1, 0, 0}};
    
    // 后面
    self.vertices[30] = (ZZVertex){{-0.5, 0.5, -0.5}, {0, 1}, {0, 0, -1}};
    self.vertices[31] = (ZZVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, 0, -1}};
    self.vertices[32] = (ZZVertex){{0.5, 0.5, -0.5}, {1, 1}, {0, 0, -1}};
    self.vertices[33] = (ZZVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, 0, -1}};
    self.vertices[34] = (ZZVertex){{0.5, 0.5, -0.5}, {1, 1}, {0, 0, -1}};
    self.vertices[35] = (ZZVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, 0, -1}};
    
    
    //开辟顶点缓冲区
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    GLsizeiptr butterSizeBytes = sizeof(ZZVertex) *kCoorCount;
    glBufferData(GL_ARRAY_BUFFER, butterSizeBytes, self.vertices, GL_STATIC_DRAW);
    
    //顶点数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(ZZVertex), NULL + offsetof(ZZVertex,positionCoord));
    
    //纹理数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(ZZVertex), NULL + offsetof(ZZVertex,textureCoord));
    //法线数据
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(ZZVertex), NULL + offsetof(ZZVertex,normal));
    
}


- (void)glkView:(nonnull GLKView *)view drawInRect:(CGRect)rect
{
    //开启深度测试
    glEnable(GL_DEPTH_TEST);
    //清空颜色缓冲区和深度缓冲区
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    //准备绘制
    [self.baseEffect prepareToDraw];
    //绘制
    glDrawArrays(GL_TRIANGLES, 0, kCoorCount);
}

- (void)update
{
    self.angle = (self.angle + 1) % 360;
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(self.angle), 0.3, 1, 0.7);
    [self.glkView display];
}
@end
