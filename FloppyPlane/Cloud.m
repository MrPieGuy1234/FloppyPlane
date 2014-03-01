//
//  Cloud.m
//  FloppyPlane
//
//  Created by Donald Lawrence on 2/14/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "Cloud.h"

@implementation Cloud

- (id)initWithImageNamed:(NSString *)name sceneWidth:(float)width sceneHeight:(float)height {
    if (self = [super initWithImageNamed:name]) {
        self.texture.filteringMode = SKTextureFilteringNearest;
        self.position = CGPointMake(arc4random() % (int)width, height+200);
        self.moveDown = [KKAction moveByX:0 y:-(height+450) duration:(3 + arc4random() % (7 - 3 + 1))];
        [self runAction:self.moveDown];
        
        self.sceneWidth = width;
        self.sceneHeight = height;
    }
    return self;
}
- (void)update:(NSTimeInterval)currentTime {
    if (self.position.y <= -200) {
        [self removeAllActions];
        self.position = CGPointMake(arc4random() % (int)self.sceneWidth, self.sceneHeight+200);
        [self runAction:self.moveDown];
    }
    
}

@end
