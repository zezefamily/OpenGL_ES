//
//  Demo3ViewController.m
//  OpenGL_ES_Demos
//
//  Created by wenmei on 2020/8/2.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import "Demo3ViewController.h"
#import "ZZView.h"
@interface Demo3ViewController ()
@property (nonatomic,strong) ZZView *zzView;
@end

@implementation Demo3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    self.zzView = [[ZZView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.zzView];
}


@end
