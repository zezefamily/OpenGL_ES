//
//  ZZVertAttribArrayBuffer.h
//  OpenGL_ES_Demos
//
//  Created by wenmei on 2020/8/4.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef enum {
    ZZVertexAttribPosition = GLKVertexAttribPosition, //位置
    ZZVertexAttribNormal = GLKVertexAttribNormal,       //光照
    ZZVertexAttribColor = GLKVertexAttribColor,         //颜色
    ZZVertexAttribTexCoord0 = GLKVertexAttribTexCoord0, //纹理1
    ZZVertexAttribTexCoord1 = GLKVertexAttribTexCoord1, //纹理2
}ZZVertexAttrib;

NS_ASSUME_NONNULL_BEGIN

@interface ZZVertAttribArrayBuffer : NSObject

@property (nonatomic,readonly) GLuint name; //缓冲区名字

@property (nonatomic,readonly) GLsizeiptr bufferSizeBytes; //缓冲区字节数

@property (nonatomic,readonly) GLsizeiptr stride;  //步长

/// 初始化方法
/// @param stride 步长
/// @param count 顶点个数
/// @param dataPtr 数据指针
/// @param usage 绘制方式
- (instancetype)initWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage;

/// 准备绘制
/// @param index 属性/标识
/// @param count 顶点个数
/// @param offset 偏移量
/// @param shouldEnable 是否可用
- (void)prepareToDrawWithAtrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable;

/// 绘制
/// @param mode 模式(图元装配方式)
/// @param first 起始点
/// @param count 顶点个数
- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count;

/// 接收数据
/// @param stride 步长
/// @param count 顶点个数
/// @param dataPtr 数据指针
- (void)reInitWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr;

/// 根据模式绘制已经准备好的数据
/// @param mode 连接方式
/// @param first 起始点
/// @param count 顶点个数
+ (void)drawPerparedArraysWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count;

@end

NS_ASSUME_NONNULL_END
