//
//  GANCAOViewController.m
//  GCSpringiOS
//
//  Created by 506227061@qq.com on 03/05/2020.
//  Copyright (c) 2020 506227061@qq.com. All rights reserved.
//

#import "ViewController.h"
#import "GCSpringiOS.h"
#import "AViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}
- (IBAction)btnAction:(id)sender {
    AViewController *vc = [[AViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
