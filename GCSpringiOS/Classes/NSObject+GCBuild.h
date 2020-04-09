//
//  NSObject+GCBuild.h
//  GCSpringiOS
//
//  Created by apple on 2020/4/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GCBuildProxy;
@interface NSObject (GCBuild)

@property (nonatomic, strong) GCBuildProxy *myBuildProxy;

- (void)addAdapte:(NSObject *)tagert selName:(NSString *)selName adapterSelName:(NSString *)adapterSelName;

@end

NS_ASSUME_NONNULL_END
