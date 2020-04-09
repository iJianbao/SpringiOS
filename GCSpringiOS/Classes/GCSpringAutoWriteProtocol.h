//
//  GCSpringAutoWriteProtocol.h
//  GCSpringiOS
//
//  Created by apple on 2020/4/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 自动注入协议
 * 实现此协议，会自动从 ApplicationContext 上下文中查找 bean
 * 例如：@property (nonatomic, strong) TestViewModel<GC_AutoWrite> *testViewModel;
 */
@protocol GCAutoWriteProtocol
@end

NS_ASSUME_NONNULL_END
