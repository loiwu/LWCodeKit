//
//  YYLabel+tap.m
//  Spec
//
//  Created by Loi Wu on 7/26/16.
//  Copyright © 2016 Vipshop Holdings Limited. All rights reserved.
//

#import "YYLabel+tap.h"
#import <objc/runtime.h>

@interface YYLabel()

@property (nonatomic, assign) BOOL isIgnoreEvent;

@end

@implementation YYLabel (tap)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selA = @selector(touchesEnded:withEvent:);
        SEL selB = @selector(myTouchesEnded:withEvent:);
        Method methodA =   class_getInstanceMethod(self,selA);
        Method methodB = class_getInstanceMethod(self, selB);
        BOOL isAdd = class_addMethod(self, selA, method_getImplementation(methodB), method_getTypeEncoding(methodB));
        if (isAdd) {
            class_replaceMethod(self, selB, method_getImplementation(methodA), method_getTypeEncoding(methodA));
        }else{
            method_exchangeImplementations(methodA, methodB);
        }
    });
}
- (NSTimeInterval)timeInterval
{
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    objc_setAssociatedObject(self, @selector(timeInterval), @(timeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)myTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([NSStringFromClass(self.class) isEqualToString:@"YYLabel"]) {
        
        self.timeInterval =self.timeInterval ==0 ?0.5:self.timeInterval;
        if (self.isIgnoreEvent){
            return;
        }else if (self.timeInterval > 0){
            [self performSelector:@selector(resetState) withObject:nil afterDelay:self.timeInterval];
        }
    }
    self.isIgnoreEvent = YES;
    [self myTouchesEnded:touches withEvent:event];
}

- (void)setIsIgnoreEvent:(BOOL)isIgnoreEvent
{
    objc_setAssociatedObject(self, @selector(isIgnoreEvent), @(isIgnoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isIgnoreEvent
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)resetState
{
    [self setIsIgnoreEvent:NO];
}

@end
