//
//  Button.m
//  FloppyPlane
//
//  Created by Donald Lawrence on 2/15/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "Button.h"

@implementation Button

- (id)initWithImageNamed:(NSString *)name function:(SEL)function {
    if (self = [super initWithImageNamed:name]) {
        self.name = name;
        self.texture.filteringMode = SKTextureFilteringNearest;
        self.userInteractionEnabled = YES;
        self.zPosition = 999;
        self.anchorPoint = CGPointMake(.5, .5);
        self.shouldGrow = YES;
        
        self.selector = function;
        self.originalSize = CGSizeMake(self.size.width, self.size.height);

        NSLog(@"%f %f", self.frame.size.width, self.frame.size.height);
    }
    return self;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.hidden) {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInNode:self];
            if (location.x > -(self.frame.size.width/2) && location.x < self.frame.size.width/2 && location.y > -(self.frame.size.height/2) && location.y < self.frame.size.height/2) {
                if (self.shouldGrow) {
                    self.size = CGSizeMake(self.size.width*1.5, self.size.height*1.5);
                }
            }
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.hidden) {
        
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInNode:self];
            
            if (self.shouldGrow) {
                self.size = self.originalSize;
                if (location.x > -(self.frame.size.width/2) && location.x < self.frame.size.width/2 && location.y > -(self.frame.size.height/2) && location.y < self.frame.size.height/2) {
                    [self.parent performSelector:self.selector withObject:nil];
                }
            } else {
                [self.parent performSelector:self.selector withObject:nil];
            }
            
        }
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (location.x < -(self.frame.size.width/2) || location.x > self.frame.size.width/2 || location.y < -(self.frame.size.height/2) || location.y > self.frame.size.height/2) {
            if (self.shouldGrow) {
                self.size = self.originalSize;
            }
        }
    }
}
- (NSString *)convertImage:(NSString *)fileName {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        fileName = [NSString stringWithFormat:@"%@-ipad", fileName];
    } else {
        fileName = fileName;
    }
    return fileName;
}

- (CGSize)convertSize:(CGSize)size {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGSizeMake(size.width*2, size.height*2);
    } else {
        return size;
    }
}
@end
