//
//  GCBuildProxy.h
//  GCSpringiOS
//
//  Created by apple on 2020/3/18.
//

#import <Foundation/Foundation.h>
#import "GCBuildProxyProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GCBuildProxy : NSProxy

/// 传入当前的对象，返回一个对象的代理对象
/// @param delegate 传入的当前对象
+ (instancetype)buildProxy:(id)delegate;

/// 为某个对象提供适应方法
/// @param tagert 被适应的对象
/// @param adaptedName 被适应的方法名称
/// @param adapter 适应对象
/// @param adapteName 适应的方法名称
/// @param type 适应类型
+ (void)addAdapte:(id)tagert adaptedName:(NSString *)adaptedName adapter:(id)adapter adapteName:(NSString *)adapteName type:(AdapteType)type;

@end

NS_ASSUME_NONNULL_END
