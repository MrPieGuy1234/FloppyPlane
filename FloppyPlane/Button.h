//
//  Button.h
//  FloppyPlane
//
//  Created by Donald Lawrence on 2/15/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "KKSpriteNode.h"

@interface Button : KKSpriteNode

@property (nonatomic) CGSize originalSize;
@property (nonatomic) SEL selector;

- (id)initWithImageNamed:(NSString *)name function:(SEL)function;
- (void)buttonPressed;
@end