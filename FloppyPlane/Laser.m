//
//  Laser.m
//  FloppyPlane
//
//  Created by Donald Lawrence on 2/14/14.
//  Copyright (c) 2014 ; Itterheim. All rights reserved.
//

#import "Laser.h"
#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568 ) < DBL_EPSILON)

@implementation Laser

- (id)initWithScreenWidth:(float)width screenHeight:(float)height {
    if (self=[super init]) {
        NSLog(@"%f", self.scene.frame.size.width);
        self.rightWall = [KKSpriteNode spriteNodeWithImageNamed:[self convertImage:@"laserRight"]];
        self.leftWall = [KKSpriteNode spriteNodeWithImageNamed:[self convertImage:@"laserLeft"]];
        self.leftLaser = [KKSpriteNode spriteNodeWithImageNamed:[self convertImage:@"laser"]];
        self.rightLaser = [KKSpriteNode spriteNodeWithImageNamed:[self convertImage:@"laser"]];

        self.leftLaser.size = [self convertSize:CGSizeMake(320, 64)];
        self.rightLaser.size = [self convertSize:CGSizeMake(320, 64)];
        
        self.rightWall.texture.filteringMode = SKTextureFilteringNearest;
        self.leftWall.texture.filteringMode = SKTextureFilteringNearest;
        self.rightLaser.texture.filteringMode = SKTextureFilteringNearest;
        self.leftLaser.texture.filteringMode = SKTextureFilteringNearest;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.leftWall.position = CGPointMake(-56, 0);
            self.rightWall.position = CGPointMake(56, 0);
            self.leftLaser.position = CGPointMake(-440, 0);
            self.rightLaser.position = CGPointMake(440, 0);
        } else {
            self.leftWall.position = CGPointMake(-28, 0);
            self.rightWall.position = CGPointMake(28, 0);
            self.leftLaser.position = CGPointMake(-220, 0);
            self.rightLaser.position = CGPointMake(220, 0);
        }
        
        self.moveDown = [KKAction moveByX:0 y:-(height+300) duration:4.25];
        
        [self addChild:self.rightWall];
        [self addChild:self.leftWall];
        [self addChild:self.rightLaser];
        [self addChild:self.leftLaser];
        [self runAction:self.moveDown];

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