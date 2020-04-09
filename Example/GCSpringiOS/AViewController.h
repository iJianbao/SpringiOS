//
//  GANCAOAViewController.h
//  GCSpringiOS_Example
//
//  Created by apple on 2020/3/9.
//  Copyright © 2020 506227061@qq.com. All rights reserved.
//

#import "TestViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AViewController : UIViewController

@property (nonatomic, strong) TestViewModel<GCAutoWriteProtocol> *testViewModel;
//@property (nonatomic, strong) TestViewModel<GCAutoWriteProtocol> *testViewModel2;
@end

NS_ASSUME_NONNULL_END
