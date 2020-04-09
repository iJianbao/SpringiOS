//
//  GCBuildProxyProtocol.h
//  GCSpringiOS
//
//  Created by apple on 2020/3/18.
//

#import <Foundation/Foundation.h>

typedef enum {
    before = 0,
    after,
    around
} AdapteType;

NS_ASSUME_NONNULL_BEGIN

/**
 * 自动转化代理类的协议（实现横向切入的功能）
 * 实现此协议后，当前类创建对象时 会被转化成 GCBuildProxy 的对象，以实现消息转发的功能
 * 如果不需要横向切入，请取消遵守此协议
 */
@protocol GCBuildProxyProtocol
@end

NS_ASSUME_NONNULL_END
