//
//  Plane.m
//  FloppyPlane
//
//  Created by Donald Lawrence on 2/14/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "Plane.h"
#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568 ) < DBL_EPSILON)

@implementation Plane

- (id)init {
    if (self = [super initWithImageNamed:[self convertImage:@"plane"]]) {
        self.position = [self convertPoint:CGPointMake(160, 80)];
        self.zPosition = 999;
        self.size = [self convertSize:CGSizeMake(55, 55)];
        self.texture.filteringMode = SKTextureFilteringNearest;
        
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width*.4, self.frame.size.height*.4)];
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.mass = .05F;
        
        
        self.rotatePlaneRight = [KKAction rotateToAngle:-(M_PI/4) duration:.5];
        self.rotatePlaneLeft = [KKAction rotateToAngle:(M_PI/4) duration:.5];
        self.rotatePlaneNormal = [KKAction rotateToAngle:0 duration:.5];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.velMultiplier = 150;
            self.maxVelocity = 600;
        } else {
            self.velMultiplier = 75;
            self.maxVelocity = 300;
        }
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Smoke" ofType:@"sks"];
        self.smoke = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        self.smoke.hidden = YES;
        [self addChild:self.smoke];
        
        
        // self.smoke.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        
        
    }
    return self;
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
- (CGPoint)convertPoint:(CGPoint)point {
    float newX = self.frame.size.width/(320/point.x);
    if (IS_WIDESCREEN) {
        float newY = self.frame.size.height/(568/point.y);
        return CGPointMake(newX, newY);
    } else {
        float newY = self.frame.size.height/(480/point.y);
        return CGPointMake(newX, newY);
    }
    
}
@end
