//
//  ZZSegmentControl.m
//  OpenGL_ES_Demos
//
//  Created by wenmei on 2020/8/8.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import "ZZSegmentControl.h"

@implementation ZZSegmentControl

- (instancetype)initWithFrame:(CGRect)frame actions:(NSArray<NSString *> *)actions
{
    if(self == [super initWithFrame:frame]){
        [self loadSegmentWithActions:actions];
    }
    return self;
}

- (void)loadSegmentWithActions:(NSArray<NSString *> *)actions
{
    CGFloat height = self.frame.size.height - 10;
    CGFloat width = height;
    UIScrollView *_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _scrollView.contentSize = CGSizeMake(10+(width+10)*actions.count, height);
    [self addSubview:_scrollView];
    for(int i = 0;i<actions.count;i++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitle:actions[i] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor whiteColor];
        btn.frame = CGRectMake(10 + (width+10)*i, 5, width, height);
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:btn];
        btn.tag = i + 600;
    }
}

- (void)btnClick:(UIButton *)sender
{
    NSInteger index = sender.tag - 600;
    if([self.delegate respondsToSelector:@selector(itemDidSelectedWithIndex:)]){
        [self.delegate itemDidSelectedWithIndex:index];
    }
}

@end
