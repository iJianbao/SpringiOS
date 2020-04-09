//
//  GANCAOAViewController.m
//  GCSpringiOS_Example
//
//  Created by apple on 2020/3/9.
//  Copyright © 2020 506227061@qq.com. All rights reserved.
//

#import "AViewController.h"

@interface AViewController ()

@end

@implementation AViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:UIColor.greenColor];
    NSLog(@"viewDidLoad");
    [_testViewModel testRun];
    [_testViewModel testRun2:@"11111"];
    [_testViewModel testRun2:@"22222" withObj2:@"33333"];
}

- (void)dealloc {
    NSLog(@"%@ --- %s", self, __FUNCTION__);
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
