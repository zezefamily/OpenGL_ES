//
//  ViewController.m
//  OpenGL_ES_Demos
//
//  Created by wenmei on 2020/7/22.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
@interface ViewController ()
{
    EAGLContext *context;       //gl上下文(状态机)
    GLKBaseEffect *effect;      //效果
//    GLKView *glView;            //gl渲染窗口
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"hello_openGL");
    [self configAndLoadOpenGL_ES];
    [self loadVertexData];
    [self loadTextureData];
}

#pragma mark - 初始化OpenGL ES
- (void)configAndLoadOpenGL_ES
{
    //1.初始化上下文
    context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if(!context){
        NSLog(@"上下文创建失败");
        return;
    }
    //设置上下文
    [EAGLContext setCurrentContext:context];
    //2.创建并添加gl渲染窗口View
    GLKView *glView = (GLKView *)self.view;
    glView.context = context;
    //配置渲染缓冲区
    //GLKViewDrawableColorFormatRGBA8888 (r(8bit),g(8bit),b(8bit),a(8bit)) (An RGBA8888 format.)
    glView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    //深度测试精度为24(A 24-bit depth entry for each pixel.)
    glView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    //3.设置背景颜色176,196,222
    glClearColor(176/255.0, 196/255.0, 222/255.0, 1.0);
}

- (void)loadVertexData
{
    //1.设置定点和纹理数据
    // x,y,z,s,t  顶点范围[-1,1]  纹理范围[0,1]
    GLfloat vertexData[] = {
        0.25, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.25, 0.5,  0.0f,    1.0f, 1.0f, //右上
        -0.25, 0.5, 0.0f,    0.0f, 1.0f, //左上
        0.25, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.25, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.25, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    //2.开辟定点缓冲区
    //创建顶点缓冲区标识ID
    GLuint bufferID;
    glGenBuffers(1, &bufferID);
    //绑定顶点缓冲区
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    //将顶点数据copy到顶点缓冲区(CPU->GPU)
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    //3.打开读取通道
    //打开顶点读取通道并设置读取方式
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    //打开纹理读取通道并设置读取方式
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
}

- (void)loadTextureData
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"jj" ofType:@"jpg"];
    NSDictionary *options = @{
        //转换图像数据以匹配OpenGL的左下方向规范
        GLKTextureLoaderOriginBottomLeft:@(YES)
    };
    NSError *error = nil;
    //1.获取纹理信息
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if(error){
        NSLog(@"error == %@",error);
    }
    //2.GLKit提供GLKBaseEffect 完成着色器工作(顶点/片元)。最多可加载2个纹理
    effect = [[GLKBaseEffect alloc]init];
    effect.texture2d0.enabled = GL_TRUE;
    effect.texture2d0.name = textureInfo.name;
}

#pragma mark -- GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    printf("%s",__func__);
    //清空颜色缓冲区
    glClear(GL_COLOR_BUFFER_BIT);
    //准备绘制
    [effect prepareToDraw];
    //设置图元装配方式,起点,长度
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
