//
//  NSView+Extension.h
//  NSViewMouseHandle
//
//  Created by 黄训瑜 on 2017/8/20.
//  Copyright © 2017年 TTC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Extension)

@property (nonatomic, strong) NSTrackingArea *trackingArea;

@property (nonatomic, copy) void (^mouseEntered)();
@property (nonatomic, copy) void (^mouseExited)();

- (BOOL)mouseInView;

@end
