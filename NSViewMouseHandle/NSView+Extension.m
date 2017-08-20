//
//  NSView+Extension.m
//  NSViewMouseHandle
//
//  Created by 黄训瑜 on 2017/8/20.
//  Copyright © 2017年 TTC. All rights reserved.
//

#import "NSView+Extension.h"
#import <objc/runtime.h>

static void *trackingAreaKey = &trackingAreaKey;
static void *mouseEnteredKey = &mouseEnteredKey;
static void *mouseExitedKey = &mouseExitedKey;

@implementation NSView (Extension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 交换方法实现: Categories不能重写父类方法, 使得swizz_开头的方法与父类方法交换实现
        SEL selectors[] = {
            @selector(viewDidHide),
            @selector(viewDidUnhide),
            @selector(updateTrackingAreas),
            @selector(viewDidMoveToWindow),
            @selector(mouseEntered:),
            @selector(mouseExited:),
        };
        
        for (NSUInteger i = 0; i < sizeof(selectors) / sizeof(SEL); i++) {
            SEL originalSel = selectors[i];
            SEL swizzSel = NSSelectorFromString([@"swizz_" stringByAppendingString:NSStringFromSelector(originalSel)]);
            
            Method originalMethod = class_getInstanceMethod([self class], originalSel);
            Method swizzMethod = class_getInstanceMethod([self class], swizzSel);
            
            BOOL isAdd = class_addMethod(self, originalSel, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod));
            if (isAdd) {
                // 如果成功, 说明类中不存在这个方法的实现
                // 将被交换方法的实现替换到这个并不存在的实现
                class_replaceMethod(self, swizzSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            } else {
                //否则, 交换两个方法的实现
                method_exchangeImplementations(originalMethod, swizzMethod);
            }
        }
    });
}

#pragma mark - Mouse Entered/Exited Methods

// 去掉[self mouseEntered:nil]和 [self mouseExited:nil] 的nil警告. 这2个方法参数都不能传[NSEvent new], 会crash
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

// self 或者 superView 隐藏或显示
- (void)swizz_viewDidHide {
    // 已经交换过方法, 调的是系统的viewDidHide, 此处不死循环, 其它方法同理
    [self swizz_viewDidHide];
    
    [self mouseExited:nil];
}

- (void)swizz_viewDidUnhide {
    [self swizz_viewDidUnhide];
    
    if ([self mouseInView]) {
        // 已经交换过实现, 此处调的是swizz_mouseEntered:方法. [self mouseExited:nil];同理
        [self mouseEntered:nil];
    }
}

// self 或者 superView frame改变时均会调用此方法
- (void)swizz_updateTrackingAreas {
    [self swizz_updateTrackingAreas];
    
    if ([self mouseInView]) {
        [self mouseEntered:nil];
    } else {
        [self mouseExited:nil];
    }
    
    [self removeTrackingArea:self.trackingArea];
    NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways|NSTrackingAssumeInside;
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                     options:options
                                                       owner:self
                                                    userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

// self从superView或Window添加或移除
- (void)swizz_viewDidMoveToWindow {
    [self swizz_viewDidMoveToWindow];
    
    if (self.window) {
        if ([self mouseInView]) {
            [self mouseEntered:nil];
        }
    } else {
        [self mouseExited:nil];
    }
}

#pragma clang diagnostic pop

- (void)swizz_mouseEntered:(NSEvent *)event {
    // 此处不调super是因为调了super后block会回调2次
    
    if (self.mouseEntered) {
        self.mouseEntered();
    }
}

- (void)swizz_mouseExited:(NSEvent *)event {
    // 此处不调super是因为调了super后block会回调2次
    
    if (self.mouseExited) {
        self.mouseExited();
    }
}

// 判断鼠标是否在当前视图内
- (BOOL)mouseInView {
    if (!self.window) {
        return NO;
    }
    
    if (self.isHidden) {
        return NO;
    }
    
    NSPoint point = [NSEvent mouseLocation];
    point = [self.window convertRectFromScreen:NSMakeRect(point.x, point.y, 0, 0)].origin;
    point = [self convertPoint:point fromView:nil];
    
    return NSPointInRect(point, self.visibleRect);
}

- (void)setTrackingArea:(NSTrackingArea *)trackingArea {
    objc_setAssociatedObject(self, trackingAreaKey, trackingArea, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTrackingArea *)trackingArea {
    return objc_getAssociatedObject(self, trackingAreaKey);
}

- (void)setMouseEntered:(void (^)())mouseEntered {
    objc_setAssociatedObject(self, mouseEnteredKey, mouseEntered, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)())mouseEntered {
    return objc_getAssociatedObject(self, mouseEnteredKey);
}

- (void)setMouseExited:(void (^)())mouseExited {
    objc_setAssociatedObject(self, mouseExitedKey, mouseExited, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)())mouseExited {
    return objc_getAssociatedObject(self, mouseExitedKey);
}


@end
