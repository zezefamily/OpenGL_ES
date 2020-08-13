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
#import "FliterViewController.h"
@interface Demo2ViewController ()

@end

@implementation Demo2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self changeN:5 startNum:100 endNum:1000];
//    [self test];
    
}
- (void)changeN:(int)n startNum:(int)start endNum:(int)end
{
    for(int i = start;i<500;i++){
        NSLog(@"result == %d",i % n);
    }
}

- (void)test
{
    static double radius = 0;
    if(radius <= 720.0){
        double result = sin([self angleToRadian:radius]);
        NSLog(@"sin(%f) == %f",radius,result);
        radius = radius + 45.0;
        [self test];
    }
}

//角度转弧度 角度：angle 弧度：radian
- (double)angleToRadian:(double)angle
{
    return angle * (M_PI / 180.0);
}
//弧度转角度
- (double)radianToAngle:(double)radian
{
    return radian * (180.0 / M_PI);
}



- (IBAction)btnClick:(UIButton *)sender {
    
//    Demo3ViewController *demo3 = [[Demo3ViewController alloc]init];
//    demo3.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:demo3 animated:YES completion:nil];
//    Demo4ViewController *demo4 = [[Demo4ViewController alloc]init];
//    demo4.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:demo4 animated:YES completion:nil];
    FliterViewController *fliterVC = [[FliterViewController alloc]init];
    fliterVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:fliterVC animated:YES completion:nil];
    
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
