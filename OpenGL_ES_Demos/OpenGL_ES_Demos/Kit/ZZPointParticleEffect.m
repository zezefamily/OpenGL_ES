//
//  ZZPointParticleEffect.m
//  OpenGL_ES_Demos
//
//  Created by wenmei on 2020/8/4.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import "ZZPointParticleEffect.h"
#import "ZZVertAttribArrayBuffer.h"

//用于定义粒子属性的类型
typedef struct {
    GLKVector3 emissionPosition; //发射位置
    GLKVector3 emissionVelocity; //发射速度
    GLKVector3 emissionForce;   //发射重力
    GLKVector2 size;            //发射大小
    GLKVector2 emissionTimeAndLife; //发射时间和寿命
}ZZPointParticleAttributes;

//GLSL程序Uniform 参数
enum {
    ZZMVPMatrix,      //MVP矩阵
    ZZSamplers2D,     //Sampler2D 纹理
    ZZElapsedSeconds, //耗时
    ZZGravity,        //重力
    ZZNumUniforms     //Uniforms个数
};

typedef enum {
    ZZParticleAttribEmissionPosition = 0,   //粒子发射的位置
    ZZParticleAttribEmissionVelocity,       //粒子发射的速度
    ZZParticleAttribEmissionForce,          //粒子发射的重力
    ZZParticleAttribSize,                   //粒子发射的大小
    ZZParticleAttribEmissionTimeAndLife,    //粒子发射时间和寿命
}ZZParticleAttrib;

@interface ZZPointParticleEffect ()
{
    GLfloat elapsedSeconds;  //耗时
    GLuint program; // 程序
    GLint uniforms[ZZNumUniforms]; // uniforms 数组
}
// 顶点属性数组缓冲区
@property (nonatomic,strong) ZZVertAttribArrayBuffer *particleAttributeBuffer;
//粒子个数
@property (nonatomic,assign) NSUInteger numberOfParticles;
//粒子属性数据
@property (nonatomic,readonly) NSMutableData *particelAttributesData;
//是否更新粒子数据
@property (nonatomic,assign) BOOL particleDataWasUpdated;
@end


@implementation ZZPointParticleEffect

- (instancetype)init
{
    if(self == [super init]){
        //初始化纹理属性
        _texture2D0 = [[GLKEffectPropertyTexture alloc]init];
        _texture2D0.enabled = YES;
        _texture2D0.name = 0;
        _texture2D0.target = GLKTextureTarget2D;
        _texture2D0.envMode = GLKTextureEnvModeReplace;
        //初始化transform
        _transform = [[GLKEffectPropertyTransform alloc]init];
        //初始化重力属性
        _gravity = ZZDefaultGravity;
        //耗时
        _elapsedSeconds = 0.0f;
        //粒子属性数据
        _particelAttributesData = [NSMutableData data];
    }
    return self;
}

//获取一个粒子的属性值
- (ZZPointParticleAttributes)particleAtIndex:(NSUInteger)index
{
    const ZZPointParticleAttributes *particelsPtr = (const ZZPointParticleAttributes *)[self.particelAttributesData bytes];
    return particelsPtr[index];
}
//设置粒子的属性
- (void)setParticle:(ZZPointParticleAttributes)aParticle atIndex:(NSUInteger)index
{
    ZZPointParticleAttributes *particelsPtr = (ZZPointParticleAttributes *)[self.particelAttributesData mutableBytes];
    particelsPtr[index] = aParticle;
    //更改粒子状态 是否更新
    self.particleDataWasUpdated = YES;
}
//添加粒子
- (void)addParticleAtPosition:(GLKVector3)aPosition velocity:(GLKVector3)aVelocity force:(GLKVector3)aForce size:(float)aSize lifeSpanSeconds:(NSTimeInterval)aSpan fadeDurationSeconds:(NSTimeInterval)aDuration
{
    //创建粒子
    ZZPointParticleAttributes newParticle;
    //设置属性
    newParticle.emissionPosition = aPosition;
    newParticle.emissionForce = aForce;
    newParticle.emissionVelocity = aVelocity;
    newParticle.size = GLKVector2Make(aSize, aDuration);
    //向量(耗时，发射时长)
    newParticle.emissionTimeAndLife = GLKVector2Make(elapsedSeconds, elapsedSeconds + aSpan);
    
    BOOL foundSlot = NO;
    
    //粒子个数
    const long count = self.numberOfParticles;
    
    for(int i = 0;i<count;i++){
        ZZPointParticleAttributes oldParticle = [self particleAtIndex:i];
        if(oldParticle.emissionTimeAndLife.y < self.elapsedSeconds){
            [self setParticle:newParticle atIndex:i];
            foundSlot = YES;
        }
    }
    
    if(!foundSlot){
        [self.particelAttributesData appendBytes:&newParticle length:sizeof(newParticle)];
        self.particleDataWasUpdated = YES;
    }
    
}

- (NSUInteger)numberOfParticles
{
    long ret = [self.particelAttributesData length]/sizeof(ZZPointParticleAttributes);
    return ret;
}

/// 准备绘制
- (void)prepareToDraw
{
    if(program == 0){
        [self loadSharders];
    }else{
        //使用program
        glUseProgram(program);
        //计算MVP矩阵变化
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.transform.projectionMatrix, self.transform.modelviewMatrix);
        //赋值给着色器
        glUniformMatrix4fv(uniforms[ZZMVPMatrix], 1, 0, modelViewProjectionMatrix.m);
        
        glUniform1i(uniforms[ZZSamplers2D], 0);
        
        glUniform3fv(uniforms[ZZGravity], 1, self.gravity.v);
        
        glUniform1fv(uniforms[ZZElapsedSeconds], 1, &elapsedSeconds);
        
        if(self.particleDataWasUpdated){
            if(self.particleAttributeBuffer == nil && [self.particelAttributesData length] > 0){
                //数据大小
                GLsizeiptr size = sizeof(ZZPointParticleAttributes);
                int count = (int)[self.particelAttributesData length] / size;
                self.particleAttributeBuffer = [[ZZVertAttribArrayBuffer alloc]initWithAttribStride:size numberOfVertices:count bytes:[self.particelAttributesData bytes] usage:GL_DYNAMIC_DRAW];
            }else{
                //数据大小
                GLsizeiptr size = sizeof(ZZPointParticleAttributes);
                int count = (int)[self.particelAttributesData length] / size;
                [self.particleAttributeBuffer reInitWithAttribStride:size numberOfVertices:count bytes:[self.particelAttributesData bytes]];
            }
            self.particleDataWasUpdated = NO;
        }
        //准备数据
        [self.particleAttributeBuffer prepareToDrawWithAtrib:ZZParticleAttribEmissionPosition numberOfCoordinates:3 attribOffset:offsetof(ZZPointParticleAttributes, emissionPosition) shouldEnable:YES];
        [self.particleAttributeBuffer prepareToDrawWithAtrib:ZZParticleAttribEmissionVelocity numberOfCoordinates:3 attribOffset:offsetof(ZZPointParticleAttributes, emissionVelocity) shouldEnable:YES];
        [self.particleAttributeBuffer prepareToDrawWithAtrib:ZZParticleAttribEmissionVelocity numberOfCoordinates:3 attribOffset:offsetof(ZZPointParticleAttributes, emissionForce) shouldEnable:YES];
        [self.particleAttributeBuffer prepareToDrawWithAtrib:ZZParticleAttribEmissionVelocity numberOfCoordinates:2 attribOffset:offsetof(ZZPointParticleAttributes, size) shouldEnable:YES];
        [self.particleAttributeBuffer prepareToDrawWithAtrib:ZZParticleAttribEmissionVelocity numberOfCoordinates:2 attribOffset:offsetof(ZZPointParticleAttributes, emissionTimeAndLife) shouldEnable:YES];
        //绑定纹理
        glActiveTexture(GL_TEXTURE0);
        if(self.texture2D0.name != 0 && self.texture2D0.enabled){
            glBindTexture(GL_TEXTURE_2D, self.texture2D0.name);
        }else{
            glBindTexture(GL_TEXTURE_2D, 0);
        }
    }
}

/// 绘制
- (void)draw
{
    //禁用深度缓冲区写入
    glDepthMask(GL_FALSE);
    [self.particleAttributeBuffer drawArrayWithMode:GL_POINTS startVertexIndex:0 numberOfVertices:(int)self.numberOfParticles];
}

- (BOOL)loadSharders
{
    GLuint vertShader, fragShader;
    NSString *verShaderPathName,*fragShaderPathName;
    //创建program
    program = glCreateProgram();
    //创建并编译 顶点着色器
    verShaderPathName = [[NSBundle mainBundle]pathForResource:@"ZZPointParticleShader" ofType:@"vsh"];
    if(![self compileShader:&vertShader type:GL_VERTEX_SHADER file:verShaderPathName]){
        NSLog(@"顶点着色器编译失败");
        return NO;
    }
    //创建编译 片元着色器
    fragShaderPathName = [[NSBundle mainBundle]pathForResource:@"ZZPointParticleShader" ofType:@"fsh"];
    if(![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathName]){
        NSLog(@"编译片元着色器失败");
        return NO;
    }
    //将顶点着色器 和 片元着色器 附着 到 program
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    //绑定相关属性
    //位置
    glBindAttribLocation(program, ZZParticleAttribEmissionPosition, "a_emissionPosition");
    //速度
    glBindAttribLocation(program, ZZParticleAttribEmissionVelocity, "a_emissionVelocity");
    //重力
    glBindAttribLocation(program, ZZParticleAttribEmissionForce, "a_emissionForce");
    //大小
    glBindAttribLocation(program, ZZParticleAttribSize, "a_size");
    //持续时间
    glBindAttribLocation(program, ZZParticleAttribEmissionTimeAndLife, "a_emissionAndDeathTimes");
    
    //link 链接
    if(![self linkProgram:program]){
        NSLog(@"program link failed !!");
        if(vertShader){
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if(fragShader){
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if(program){
            glDeleteProgram(program);
            program = 0;
        }
        return NO;
    }
    //获取，绑定uniforms
    //MVP变换矩阵
    uniforms[ZZMVPMatrix] = glGetUniformLocation(program, "u_mvpMatrix");
    //纹理
    uniforms[ZZSamplers2D] = glGetUniformLocation(program, "u_samplers2D");
    //重力
    uniforms[ZZGravity] = glGetUniformLocation(program, "u_gravity");
    //持续时间，渐隐时间
    uniforms[ZZElapsedSeconds] = glGetUniformLocation(program, "u_elapsedSeconds");
    
    if(vertShader){
        glDetachShader(program, vertShader);
        glDeleteShader(vertShader);
    }
    if(fragShader){
        glDetachShader(program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)program
{
    glLinkProgram(program);
    GLint logLength;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if(logLength > 0){
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"error log: %s",log);
        return NO;
    }
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    const GLchar *source;
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil]UTF8String];
    if(!source){
        NSLog(@"Failed to load shader !!!");
        return NO;
    }
    *shader = glCreateShader(type);
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if(logLength > 0){
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"shader compile log: %s",log);
        free(log);
        return NO;
    }
    return YES;
}


@end
