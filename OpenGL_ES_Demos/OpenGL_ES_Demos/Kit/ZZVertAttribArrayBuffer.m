//
//  ZZVertAttribArrayBuffer.m
//  OpenGL_ES_Demos
//
//  Created by wenmei on 2020/8/4.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import "ZZVertAttribArrayBuffer.h"

@implementation ZZVertAttribArrayBuffer

/// 初始化方法
/// @param stride 步长
/// @param count 顶点个数
/// @param dataPtr 数据指针
/// @param usage 绘制方式
- (instancetype)initWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage
{
    if(self == [super init]){
        _stride = stride;
        _bufferSizeBytes = _stride * count;
        
        glGenBuffers(1, &_name);
        glBindBuffer(GL_ARRAY_BUFFER, self.name);
        
        glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, dataPtr, usage);
    }
    return self;
}

/// 准备绘制
/// @param index 属性/标识
/// @param count 顶点个数
/// @param offset 偏移量
/// @param shouldEnable 是否可用
- (void)prepareToDrawWithAtrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable
{
    glBindBuffer(GL_ARRAY_BUFFER, self.name);
    if(shouldEnable){
        glEnableVertexAttribArray(index);
    }
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, (int)self.stride, (GLfloat *)NULL + offset);
}

/// 绘制
/// @param mode 模式(图元装配方式)
/// @param first 起始点
/// @param count 顶点个数
- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count
{
    glDrawArrays(mode, first, count);
}
//
/// 接收数据
/// @param stride 步长
/// @param count 顶点个数
/// @param dataPtr 数据指针
- (void)reInitWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr
{
    _stride = stride;
    _bufferSizeBytes = stride * count;
    glBindBuffer(GL_ARRAY_BUFFER, self.name);
    glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, dataPtr, GL_DYNAMIC_DRAW);
}

/// 根据模式绘制已经准备好的数据
/// @param mode 连接方式
/// @param first 起始点
/// @param count 顶点个数
+ (void)drawPerparedArraysWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count
{
    glDrawArrays(mode, first, count);
}

@end
