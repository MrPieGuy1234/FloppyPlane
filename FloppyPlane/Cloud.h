//
//  Cloud.h
//  FloppyPlane
//
//  Created by Donald Lawrence on 2/14/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteNode.h"

@interface Cloud : KKSpriteNode

@property (nonatomic, strong) KKAction *moveDown;

@property (nonatomic) float sceneWidth;
@property (nonatomic) float sceneHeight;

- (id)initWithImageNamed:(NSString *)name sceneWidth:(float)width sceneHeight:(float)height;

@end
