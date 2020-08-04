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

- (void)addParticleAtPosition:(GLKVector3)aPosition velocity:(GLKVector3)aVelocity force:(GLKVector3)aForce size:(float)aSize lifeSpanSeconds:(NSTimeInterval)aSpan fadeDurationSeconds:(NSTimeInterval)aDuration
{
    
}

/// 准备绘制
- (void)prepareToDraw
{
    
}

/// 绘制
- (void)draw
{
    
}


@end
