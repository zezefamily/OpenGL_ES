//
//  ZZPointParticleEffect.h
//  OpenGL_ES_Demos
//
//  Created by wenmei on 2020/8/4.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
NS_ASSUME_NONNULL_BEGIN

extern const GLKVector3 ZZDefaultGravity;

@interface ZZPointParticleEffect : NSObject
//重力
@property (nonatomic,assign) GLKVector3 gravity;
//耗时
@property (nonatomic,assign) GLfloat elapsedSeconds;
//纹理
@property (nonatomic,strong,readonly) GLKEffectPropertyTexture *texture2D0;
//变换
@property (nonatomic,strong,readonly) GLKEffectPropertyTransform *transform;

/// 添加粒子
/// @param aPosition 位置
/// @param aVelocity 速度
/// @param aForce 重力
/// @param aSize 大小
/// @param aSpan 跨度
/// @param aDuration 时长
- (void)addParticleAtPosition:(GLKVector3)aPosition velocity:(GLKVector3)aVelocity force:(GLKVector3)aForce size:(float)aSize lifeSpanSeconds:(NSTimeInterval)aSpan fadeDurationSeconds:(NSTimeInterval)aDuration;

/// 准备绘制
- (void)prepareToDraw;

/// 绘制
- (void)draw;

@end

NS_ASSUME_NONNULL_END
