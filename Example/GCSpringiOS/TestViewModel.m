//
//  TestViewModel.m
//  GanCao
//
//  Created by apple on 2020/3/5.
//  Copyright © 2020 apple. All rights reserved.
//

#import "TestViewModel.h"
#import "TestAdapte.h"
@interface TestViewModel()

@property (nonatomic, strong) NSArray *data;

@end

@implementation TestViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
//        [self addAdapte:[[TestAdapte alloc] init] selName:@"testRun" adapterSelName:@"printTime"];
//        [self addAdapte:[[TestAdapte alloc] init] selName:@"testRun2:" adapterSelName:@"printTime2:"];
//        [self addAdapte:[[TestAdapte alloc] init] selName:@"testRun2:withObj2:" adapterSelName:@"printTime2:withObjc2:"];
        
//        [_test22ViewModel testRun];
    }
    return self;
}

- (void)testRun {
    NSLog(@"%s - %@", __func__, self);
}

- (void)testRun2:(id)obj {
    NSLog(@"%s - %@ - %@", __func__, self, obj);
}

- (void)testRun2:(id)obj withObj2:(id)obj2 {
    NSLog(@"%s - %@ - %@ - %@", __func__, self, obj, obj2);
}


- (void)dealloc {
    NSLog(@"%s - %@ - 2222222222222", __func__, self);
}

@end
