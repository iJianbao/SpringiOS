//
//  GCAutoWriteManager.h
//  GCSpringiOS
//
//  Created by apple on 2020/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCAutoWriteModel : NSObject
// 当前对象
@property (nonatomic, weak) id currentObjc;
// 当前对象归属于对象
@property (nonatomic, weak) id ascriptionObjc;
// 当前对象类遵守的协议
@property (nonatomic, strong) Protocol *protocol;
// 是否已经执行过初始化方法
@property (nonatomic, assign) BOOL isFinishInit;
@end

@interface GCAutoWriteManager : NSObject
// 回调
@property (nonatomic, copy) void(^gcCreatePrototypeBlock)(GCAutoWriteModel *model);
@property (nonatomic, copy) NSMapTable *(^gcCreateCopyBlock)(void);
@property (nonatomic, copy) NSMapTable *(^gcCreateSingletonBlock)(GCAutoWriteModel * _Nullable model);
- (void)readProperty:(id)tagert;

@end

NS_ASSUME_NONNULL_END
