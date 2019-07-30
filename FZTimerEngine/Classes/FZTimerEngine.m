//
//  FZTimerEngine.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/7/30.
//

#import "FZTimerEngine.h" 

NS_ASSUME_NONNULL_BEGIN

@interface FZTimeNode : NSObject

/** id */
@property(nonatomic,strong) NSString * name;
/** 执行频率 max 60/s */
@property(nonatomic,assign) NSUInteger frequency;
/** 回调block */
@property(nonatomic,copy) void(^callback)(NSTimeInterval timeinterval);
/** 有效性 */
@property(nonatomic,assign) BOOL isValid;

@end

@implementation FZTimeNode

@end

NS_ASSUME_NONNULL_END

@interface FZTimerEngine ()

@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,strong) NSMutableDictionary *actions;
@property (nonatomic,assign) NSInteger count;

@end

@implementation FZTimerEngine
+(instancetype)sharedTimer{
    static FZTimerEngine * sharedTimer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTimer = [[self alloc] init];
    });
    return sharedTimer;
}


-(void)registerAction:(void (^)(NSTimeInterval timeinterval))action frequency:(NSUInteger)frequency name:(NSString *)name {
    FZTimeNode * node = [[FZTimeNode alloc]init];
    node.callback = action;
    node.frequency = frequency;
    node.isValid = YES;
    node.name = name;
    for (NSString *key in self.actions.allKeys) {
        NSAssert([name isEqualToString:key], @"The action name already exists");
    }
    self.actions[name] = node;
    if (self.actions.count) {
        [self timer];
    }
}

-(void)removeActionForName:(NSString *)name{
    [self.actions removeObjectForKey:name];
    if (self.actions.count == 0) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)setValid:(BOOL)isvalid toName:(NSString *)name{
    [self.actions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        FZTimeNode * node = (FZTimeNode *)obj;
        if ([node.name isEqualToString:name]) {
            node.isValid = isvalid;
            *stop = YES;
        }
    }];
}
-(void)updateFrequency:(NSUInteger)frequency ForName:(NSString *)name{
    [self.actions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        FZTimeNode * node = (FZTimeNode *)obj;
        if ([node.name isEqualToString:name]) {
            node.frequency = frequency;
            *stop = YES;
        }
    }];
}
-(void)endAllAction{
    [self.actions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        FZTimeNode * node = (FZTimeNode *)obj;
        if (node.isValid == true) {
            node.isValid = false;
        }
    }];
}
-(void)beginAllAction{
    [self.actions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        FZTimeNode * node = (FZTimeNode *)obj;
        if (node.isValid == false) {
            node.isValid = true;
        }
    }];
}

-(void)timerAction {
    __weak __typeof(self) weakSelf = self;
    [self.actions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        FZTimeNode *node = (FZTimeNode *)obj;
        NSAssert((60 % node.frequency) == 0, @"the timer must been devisible to 60");
        if (node.isValid && (weakSelf.count % (60/node.frequency)) == 0) {
            NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970 * 1000;
            node.callback(timeInterval);
        }
    }];
    self.count++;
    if (self.count > 59) self.count = 0;
}

#pragma mark -- Lazy Func --

-(NSMutableDictionary *)actions{
    if (_actions == nil) {
        _actions = [NSMutableDictionary dictionary];
    }
    return _actions;
}

-(NSTimer *)timer{
    if (_timer == nil) {
        self.count = 0;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
    return _timer;
}

@end
