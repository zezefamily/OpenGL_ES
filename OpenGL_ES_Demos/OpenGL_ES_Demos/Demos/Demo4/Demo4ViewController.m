//
//  Demo4ViewController.m
//  OpenGL_ES_Demos
//
//  Created by 泽泽 on 2020/8/4.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import "Demo4ViewController.h"
#import "Demo4View.h"
@interface Demo4ViewController ()

@end

@implementation Demo4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    Demo4View *view4 = [[Demo4View alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:view4];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
