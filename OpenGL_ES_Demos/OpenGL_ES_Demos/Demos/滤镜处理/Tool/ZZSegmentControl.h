//
//  ZZSegmentControl.h
//  OpenGL_ES_Demos
//
//  Created by wenmei on 2020/8/8.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZZSegmentControlDelegate <NSObject>

- (void)itemDidSelectedWithIndex:(NSInteger)index;

@end

@interface ZZSegmentControl : UIView

- (instancetype)initWithFrame:(CGRect)frame actions:(NSArray<NSString *> *)actions;

@property (nonatomic,weak) id<ZZSegmentControlDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
