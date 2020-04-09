//
//  GCSpringiOSProtocol.h
//  GCSpringiOS_Example
//
//  Created by apple on 2020/3/5.
//  Copyright © 2020 506227061@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 扫描到此协议，自动为 viewModel 创建一个新的实例
 * 例如：@ interface TestViewModel : NSObject<GC_Prototype>
 */
@protocol GCSpringPrototypeProtocol
@end

/**
 * 扫描到此协议，单例模式， viewModel 存在则引用，不存在则创建
 * 例如：@ interface TestViewModel : NSObject<GC_Singleton>
*/
@protocol GCSpringSingletonProtocol
@end

/**
 * 扫描到此协议，引用前面已经创建的实列，viewModel 从前面找，找到一个类型一样的实列，没有找到，则报错
 * 例如：@ interface TestViewModel : NSObject<GC_Copy>
*/
@protocol GCSpringCopyProtocol
@end


NS_ASSUME_NONNULL_END
