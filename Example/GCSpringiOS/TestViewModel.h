//
//  TestViewModel.h
//  GanCao
//
//  Created by apple on 2020/3/5.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCSpringiOS.h"
#import "Test22ViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestViewModel : NSObject<GCSpringPrototypeProtocol, GCBuildProxyProtocol>

@property (nonatomic, strong) Test22ViewModel<GCAutoWriteProtocol> *test22ViewModel;

- (void)testRun;
- (void)testRun2:(id)obj;
- (void)testRun2:(id)obj withObj2:(id)obj2;
@end

NS_ASSUME_NONNULL_END
