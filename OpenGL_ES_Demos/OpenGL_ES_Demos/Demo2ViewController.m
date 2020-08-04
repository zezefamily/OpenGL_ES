//
//  Demo2ViewController.m
//  OpenGL_ES_Demos
//
//  Created by wenmei on 2020/7/28.
//  Copyright © 2020 zezefamily. All rights reserved.
//

#import "Demo2ViewController.h"
#import "Demo3ViewController.h"
#import "Demo4ViewController.h"
@interface Demo2ViewController ()

@end

@implementation Demo2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)btnClick:(UIButton *)sender {
    
//    Demo3ViewController *demo3 = [[Demo3ViewController alloc]init];
//    demo3.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:demo3 animated:YES completion:nil];
    Demo4ViewController *demo4 = [[Demo4ViewController alloc]init];
    demo4.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:demo4 animated:YES completion:nil];
    
    
}
- (IBAction)btn1Click:(UIButton *)sender {
    
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
