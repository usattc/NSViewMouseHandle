//
//  ViewController.m
//  NSViewMouseHandle
//
//  Created by 黄训瑜 on 2017/8/20.
//  Copyright © 2017年 TTC. All rights reserved.
//

#import "ViewController.h"
#import "NSView+Extension.h"

@interface ViewController ()

@property (weak) IBOutlet NSButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    __weak typeof(self) weakSelf = self;
    [self.button setMouseExited:^{
        weakSelf.button.wantsLayer = YES;
        weakSelf.button.layer.backgroundColor = [NSColor redColor].CGColor;
        weakSelf.button.title = @"Exited";
    }];
    
    [self.button setMouseEntered:^{
        weakSelf.button.wantsLayer = YES;
        weakSelf.button.layer.backgroundColor = [NSColor grayColor].CGColor;
        weakSelf.button.title = @"Entered";
    }];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
