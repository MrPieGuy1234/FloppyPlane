//
//  Plane.h
//  FloppyPlane
//
//  Created by Donald Lawrence on 2/14/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteNode.h"

@interface Plane : KKSpriteNode

@property (nonatomic) KKAction *rotatePlaneRight;
@property (nonatomic) KKAction *rotatePlaneLeft;
@property (nonatomic) KKAction *rotatePlaneNormal;

@property (nonatomic) float velMultiplier;
@property (nonatomic) float maxVelocity;

@property (nonatomic) SKEmitterNode *smoke;
@end
