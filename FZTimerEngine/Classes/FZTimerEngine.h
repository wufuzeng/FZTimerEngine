//
//  FZTimerEngine.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/7/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FZTimerEngine : NSObject

/** 单例 */
+(instancetype)sharedTimer;

/**
 * 注册一个定时回调
 * @param action 回调Block
 * @param frequency 频率 0~60
 * @param name name
 */
-(void)registerAction:(void (^)(NSTimeInterval timeinterval))action
            frequency:(NSUInteger)frequency
                 name:(NSString *)name;

/**
 * 移除指定定时回调
 * @param name name
 */
-(void)removeActionForName:(NSString *)name;

/**
 * 控制指定定时回调有效性
 * @param isvalid isvalid
 * @param name name
 */
-(void)setValid:(BOOL)isvalid toName:(NSString *)name;

/**
 * 更新指定定时回调执行频率
 * @param frequency frequency
 * @param name name
 */
-(void)updateFrequency:(NSUInteger)frequency ForName:(NSString *)name;
/** 启动所有回调 */
-(void)beginAllAction;
/** 结束所有回调 */
-(void)endAllAction;

@end

NS_ASSUME_NONNULL_END
