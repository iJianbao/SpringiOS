//
//  TestAdapte.m
//  GanCao
//
//  Created by apple on 2020/3/21.
//  Copyright © 2020 apple. All rights reserved.
//

#import "TestAdapte.h"

@implementation TestAdapte

- (void)printTime {
    NSLog(@"时间 = %f", [[NSDate date] timeIntervalSince1970]);
}

- (void)printTime2:(id)obj {
    NSLog(@"时间 = %f, %@", [[NSDate date] timeIntervalSince1970], obj);
}

- (void)printTime2:(id)obj1 withObjc2:(id)obj2 {
    NSLog(@"时间 = %f, %@, %@", [[NSDate date] timeIntervalSince1970], obj1, obj2);
}

- (void)dealloc {
    NSLog(@"%@ --- %s", self, __FUNCTION__);
}

@end
