//
//  NSObject+GCBuild.m
//  GCSpringiOS
//
//  Created by apple on 2020/4/7.
//

#import "NSObject+GCBuild.h"
#import "Objc/runtime.h"
#import "GCBuildProxy.h"
#import "GCBuildProxyProtocol.h"

@implementation NSObject (GCBuild)

- (GCBuildProxy *)myBuildProxy {
    GCBuildProxy *poxy = objc_getAssociatedObject(self, @selector(myBuildProxy));
    return poxy;
}

- (void)setMyBuildProxy:(GCBuildProxy *)myBuildProxy {
    objc_setAssociatedObject(self, @selector(myBuildProxy), myBuildProxy, OBJC_ASSOCIATION_ASSIGN);
}

- (void)addAdapte:(NSObject *)tagert selName:(NSString *)selName adapterSelName:(NSString *)adapterSelName {
    if ([self.class conformsToProtocol:@protocol(GCBuildProxyProtocol)]) {
        [GCBuildProxy addAdapte:self.myBuildProxy adaptedName:selName adapter:tagert adapteName:adapterSelName type:around];
    }else {
        NSLog(@"%@ 被适应失败，请遵守 GCBuildProxyProtocol 协议", [tagert class]);
    }
}

@end
