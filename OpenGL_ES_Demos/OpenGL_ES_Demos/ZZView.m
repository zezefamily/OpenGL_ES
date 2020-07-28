//
//  ZZView.m
//  OpenGL_ES_Demos
//
//  Created by wenmei on 2020/7/28.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import "ZZView.h"
#import <OpenGLES/ES2/gl.h>
@interface ZZView()

@property (nonatomic,strong) CAEAGLLayer *egaLayer;

@property (nonatomic,strong) EAGLContext *context;

@property (nonatomic,assign) GLuint colorRenderBuffer;

@property (nonatomic,assign) GLuint colorFrameBuffer;

@property (nonatomic,assign) GLuint programe;

@end
@implementation ZZView

- (void)layoutSubviews
{
    //1.设置图层
    [self setupLayer];
    //2.创建上下文
    [self setUpContext];
    //3.清空缓冲区
    [self deleteBuffers];
    //4.设置渲染缓冲区
    [self setupRenderBuffer];
    //5.设置帧缓冲区
    [self setupRenderBuffer];
    //6.开始绘制
    [self renderLayer];
}

-(void)renderLayer
{
    
}

- (void)setupLayer
{
    //1.创建特殊图层
    /*
     重写layerClass，将CCView返回的图层从CALayer替换成CAEAGLLayer
     */
    self.egaLayer = (CAEAGLLayer *)self.layer;
    //2.设置scale
    [self setContentScaleFactor:[[UIScreen mainScreen]scale]];
    //3.设置描述属性，这里设置不维持渲染内容以及颜色格式为RGBA8
    self.egaLayer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking:@(NO),
        kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8,
    };
}
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)setUpContext
{
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if(!context){
        return;
    }
    [EAGLContext setCurrentContext:context];
    self.context = context;
}

- (void)deleteBuffers
{
    glDeleteBuffers(1, &_colorFrameBuffer);
    self.colorFrameBuffer = 0;
    
    glDeleteBuffers(1, &_colorRenderBuffer);
    self.colorRenderBuffer = 0;
}

- (void)setupRenderBuffer
{
    //定义一个缓存区ID
    GLuint buffer;
    //申请一个缓存区标志
    glGenBuffers(1, &buffer);
    //
    self.colorRenderBuffer = buffer;
    
    glBindBuffer(GL_RENDERBUFFER, self.colorRenderBuffer);
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.egaLayer];
}

- (void)setFrameBuffer
{
    //1.定义一个缓存区ID
    GLuint buffer;
    //2.申请一个缓存区标志
    //glGenRenderbuffers(1, &buffer);
    //glGenFramebuffers(1, &buffer);
    glGenBuffers(1, &buffer);
    //3.
    self.colorFrameBuffer = buffer;
    //4.
    glBindFramebuffer(GL_FRAMEBUFFER, self.colorFrameBuffer);
    //将渲染缓存区myColorRenderBuffer 通过glFramebufferRenderbuffer函数绑定到 GL_COLOR_ATTACHMENT0上。
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderBuffer);
}
@end
