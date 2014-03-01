//
//  Laser.h
//  FloppyPlane
//
//  Created by Donald Lawrence on 2/14/14.
//  Copyright (c) 2014 ; Itterheim. All rights reserved.
//

#import "KKNode.h"

@interface Laser : KKNode

@property (nonatomic, strong) KKSpriteNode *leftWall;
@property (nonatomic, strong) KKSpriteNode *rightWall;
@property (nonatomic, strong) KKSpriteNode *leftLaser;
@property (nonatomic, strong) KKSpriteNode *rightLaser;
@property (nonatomic, strong) KKAction *moveDown;
@property (nonatomic, strong) SKSpriteNode *scoreBody;

@property (nonatomic) float screenWidth;
@property (nonatomic) float screenHeight;

- (id)initWithScreenWidth:(float)width screenHeight:(float)height;

@end
