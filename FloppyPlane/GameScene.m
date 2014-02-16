//
//  GameScene.m
//  FloppyPlane
//
//  Created by Donald Lawrence on 2/14/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "GameScene.h"
#import "Cloud.h"
#import "Laser.h"
#import "Plane.h"
#import "Button.h"
#import "BMGlyphLabel.h"
#import "BMGlyphFont.h"
#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568 ) < DBL_EPSILON)
@implementation GameScene

static const uint32_t shipCategory = 0x1 << 0;
static const uint32_t laserCategory = 0x1 << 1;
static const uint32_t wallCategory = 0x1 << 2;
static const uint32_t oldLaserCategory = 0x1 << 3;
static const uint32_t scoreBodyCategory = 0x1 << 4;

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:.7 blue:1 alpha:1];
        self.physicsWorld.contactDelegate = self;
        
        self.cloud1 = [[Cloud alloc] initWithImageNamed:[self convertImage:@"cloud60"] sceneWidth:self.frame.size.width sceneHeight:self.frame.size.height];
        self.cloud2 = [[Cloud alloc] initWithImageNamed:[self convertImage:@"cloud60"] sceneWidth:self.frame.size.width sceneHeight:self.frame.size.height];
        self.cloud3 = [[Cloud alloc] initWithImageNamed:[self convertImage:@"cloud60"] sceneWidth:self.frame.size.width sceneHeight:self.frame.size.height];
        
        self.logo = [SKSpriteNode spriteNodeWithImageNamed:[self convertImage:@"tempLogo"]];
        self.logo.zPosition = 999;
        self.logo.texture.filteringMode = SKTextureFilteringNearest;
        self.logo.size = CGSizeMake(self.logo.size.width*1.5, self.logo.size.height*1.5);
        self.logo.position = [self convertPoint:CGPointMake(160, 350)];
        
        self.gameOver = [SKSpriteNode spriteNodeWithImageNamed:[self convertImage:@"gameover"]];
        self.gameOver.zPosition = 999;
        self.gameOver.texture.filteringMode = SKTextureFilteringNearest;
        self.gameOver.size = CGSizeMake(self.gameOver.size.width*1.5, self.gameOver.size.height*1.5);
        self.gameOver.position = [self convertPoint:CGPointMake(160, 350)];
        self.gameOver.hidden = YES;
        
        self.playButton = [[Button alloc] initWithImageNamed:[self convertImage:@"playButton"] function:@selector(startGame)];
        self.playButton.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        self.rateButton = [[Button alloc] initWithImageNamed:[self convertImage:@"rateButton"] function:@selector(rate)];
        self.rateButton.position = [self convertPoint:CGPointMake(160, 190)];
        
        self.leaderboardButton = [[Button alloc] initWithImageNamed:[self convertImage:@"leaderboardButton"] function:@selector(displayLeaderboard)];
        self.leaderboardButton.position = [self convertPoint:CGPointMake(160, 140)];
        
        BMGlyphFont *gabsFont = [BMGlyphFont fontWithName:@"gabsPixel"];
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura Condensed ExtraBold"];
        self.scoreLabel.hidden = YES;
        self.scoreLabel.zPosition = 999;
        self.scoreLabel.position = [self convertPoint:CGPointMake(160, 400)];
        
        self.endScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
        self.endScoreLabel.text = [NSString stringWithFormat:@"Score: %li", (long)self.score];
        self.endScoreLabel.position = [self convertPoint:CGPointMake(100, 270)];
        self.endScoreLabel.hidden = YES;
        
        self.highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
        self.highScoreLabel.text = [NSString stringWithFormat:@"High Score: %li", (long)self.highScore];
        self.highScoreLabel.position = [self convertPoint:CGPointMake(200, 270)];
        self.highScoreLabel.hidden = YES;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.scoreLabel setScale:4];
        } else {
            [self.scoreLabel setScale:2];
        }
        
        [self addChild:self.playButton];
        [self addChild:self.gameOver];
        [self addChild:self.rateButton];
        [self addChild:self.leaderboardButton];
        [self addChild:self.scoreLabel];
        [self addChild:self.highScoreLabel];
        [self addChild:self.logo];
        [self addChild:self.endScoreLabel];
        [self addChild:self.cloud1];
        [self addChild:self.cloud2];
        [self addChild:self.cloud3];
    }
    return self;
}
- (void)update:(NSTimeInterval)currentTime {
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    [self.cloud1 update:currentTime];
    [self.cloud2 update:currentTime];
    [self.cloud3 update:currentTime];
    
    if (self.gameHasStarted) {
        self.timeSinceLastLaser += timeSinceLast;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (self.timeSinceLastLaser >= 1.25) {
                self.timeSinceLastLaser = 0;
                [self generateLaser];
            }
        } else {
            if (self.timeSinceLastLaser >= .9) {
                self.timeSinceLastLaser = 0;
                [self generateLaser];
            }
        }
        if (self.touchRight) {
            self.timeSinceLastLift += timeSinceLast;
            if (self.plane.physicsBody.velocity.dx > self.plane.maxVelocity) {
                self.plane.physicsBody.velocity = CGVectorMake(self.plane.maxVelocity, 0);
            }
            NSLog(@"Right!");
            [self.plane.physicsBody applyForce:CGVectorMake(self.timeSinceLastLift*self.plane.velMultiplier, 0)];
        }
        if (self.touchLeft) {
            self.timeSinceLastLift += timeSinceLast;
            if (self.plane.physicsBody.velocity.dx < -self.plane.maxVelocity) {
                self.plane.physicsBody.velocity = CGVectorMake(-self.plane.maxVelocity, 0);
            }
            NSLog(@"Left!");
            [self.plane.physicsBody applyForce:CGVectorMake(self.timeSinceLastLift*-self.plane.velMultiplier, 0)];
        }
        if (self.plane.position.x <= 0) {
            self.plane.position = CGPointMake(self.frame.size.width-1, self.plane.position.y);
        }
        if (self.plane.position.x >= self.frame.size.width) {
            self.plane.position = CGPointMake(1, self.plane.position.y);
        }
    }
    
    [self enumerateChildNodesWithName:@"laser" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y <= -100) {
            [node removeAllActions];
            [node removeFromParent];
        }
    }];
    
    [super update:currentTime];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.timeSinceLastLift = 0;
    CGPoint location = [touch locationInNode:self];
    if (self.gameHasStarted) {
        if (!self.touchLeft && !self.touchRight) {
            if (location.x >= self.frame.size.width/2) {
                self.touchRight = YES;
                [self.plane runAction:self.plane.rotatePlaneRight];
            } else {
                self.touchLeft = YES;
                [self.plane runAction:self.plane.rotatePlaneLeft];
            }
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (self.gameHasStarted) {
            if (self.touchLeft != self.touchRight) {
                self.touchRight = NO;
                self.touchLeft = NO;
                [self.plane runAction:self.plane.rotatePlaneNormal];
            }
        }
    }
}
- (void)startGame {
    NSLog(@"Game started!");
    
    if (self.plane != nil) {
        [self.plane removeFromParent];
        self.plane = nil;
    }
    self.plane = [[Plane alloc] init];
    self.plane.position = [self convertPoint:CGPointMake(160, 80)];
    self.plane.physicsBody.categoryBitMask = shipCategory;
    self.plane.physicsBody.contactTestBitMask = laserCategory | wallCategory | scoreBodyCategory;
    self.plane.physicsBody.collisionBitMask = 0x0;
    self.plane.name = @"plane";
    [self addChild:self.plane];
    
    self.logo.hidden = YES;
    self.playButton.hidden = YES;
    self.rateButton.hidden = YES;
    self.leaderboardButton.hidden = YES;
    self.gameOver.hidden = YES;
    self.endScoreLabel.hidden = YES;
    self.highScoreLabel.hidden = YES;
    
    self.scoreLabel.hidden = NO;
    self.score = 0;
    self.scoreLabel.text = [NSString stringWithFormat:@"%li", (long)self.score];
    
    
    self.touchLeft = NO;
    self.touchRight = NO;
    
    self.playButton.userInteractionEnabled = NO;
    self.rateButton.userInteractionEnabled = NO;
    self.leaderboardButton.userInteractionEnabled = NO;
    
    self.gameHasStarted = YES;
}
- (void)rate {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://apple.com"]];
}
- (void)displayLeaderboard {
    
}
- (void)generateLaser {
    if (self.gameHasStarted) {
        if (self.lastGenOnRight) {
            NSInteger randX = (int)(self.frame.size.width/(5+(1/3))) + arc4random() % (int)((self.frame.size.width/2 - self.frame.size.width/(5+(1/3)) + 1));
            self.lastGenOnRight = NO;
            Laser *laser = [[Laser alloc] initWithScreenWidth:self.frame.size.width screenHeight:self.frame.size.height];
            laser.position =  CGPointMake(randX, self.frame.size.height+100);
            laser.name = @"laser";
            laser.leftLaser.physicsBody.contactTestBitMask = shipCategory;
            laser.rightLaser.physicsBody.contactTestBitMask = shipCategory;
            laser.leftWall.physicsBody.contactTestBitMask = 0;
            laser.rightWall.physicsBody.contactTestBitMask = 0;
            laser.scoreBody.physicsBody.categoryBitMask = scoreBodyCategory;
            [self addChild:laser];
        } else {
            NSInteger randX = (int)(self.frame.size.width/2) + arc4random() % (int)((self.frame.size.width/1.2307 - self.frame.size.width/2 + 1));
            self.lastGenOnRight = YES;
            Laser *laser = [[Laser alloc] initWithScreenWidth:self.frame.size.width screenHeight:self.frame.size.height];
            laser.position =  CGPointMake(randX, self.frame.size.height+100);
            laser.name = @"laser";
            laser.leftLaser.physicsBody.contactTestBitMask = shipCategory;
            laser.rightLaser.physicsBody.contactTestBitMask = shipCategory;
            laser.leftWall.physicsBody.contactTestBitMask = 0;
            laser.rightWall.physicsBody.contactTestBitMask = 0;
            laser.scoreBody.physicsBody.categoryBitMask = scoreBodyCategory;
            [self addChild:laser];
        }
    }
}
- (void)endGame {
    self.gameHasStarted = NO;
    self.plane.smoke.hidden = NO;
    
    self.gameOver.hidden = NO;
    self.playButton.hidden = NO;
    self.rateButton.hidden = NO;
    self.leaderboardButton.hidden = NO;
    
    self.highScoreLabel.hidden = NO;
    self.endScoreLabel.hidden = NO;
    
    self.playButton.userInteractionEnabled = YES;
    self.rateButton.userInteractionEnabled = YES;
    self.leaderboardButton.userInteractionEnabled = YES;
    self.scoreLabel.hidden = YES;
    
    self.gameOver.alpha = 0.0F;
    self.playButton.alpha = 0.0F;
    self.rateButton.alpha = 0.0F;
    self.leaderboardButton.alpha = 0.0F;
    
    self.timeSinceLastLift = 0;
    self.timeSinceLastLaser = 0;
    
    KKAction *gameOverFadeIn = [KKAction fadeAlphaTo:1 duration:.5];
    KKAction *fadePlaneOut = [KKAction fadeAlphaTo:0 duration:1.5];
    KKAction *resetPlane = [KKAction performSelector:@selector(resetPlane) onTarget:self];
    
    [self.endScoreLabel setText:[NSString stringWithFormat:@"Score: %li", (long)self.score]];
    [self.highScoreLabel setText:[NSString stringWithFormat:@"High Score: %li", (long)self.highScore]];
    
    [self.gameOver runAction:gameOverFadeIn];
    [self.playButton runAction:gameOverFadeIn];
    [self.rateButton runAction:gameOverFadeIn];
    [self.leaderboardButton runAction:gameOverFadeIn];
    [self.plane runAction:[SKAction sequence:@[fadePlaneOut, resetPlane]]];
    
    [self enumerateChildNodesWithName:@"laser" usingBlock:^(SKNode *node, BOOL *stop) {
        [node runAction:fadePlaneOut];
        [node removeFromParent];
        // Laser *laser = (Laser *)node;
        // laser.leftLaser.physicsBody.contactTestBitMask = oldLaserCategory;
        // laser.rightLaser.physicsBody.contactTestBitMask = oldLaserCategory;
    }];
    
}
- (void)resetPlane {
    /*
    self.plane.position = [self convertPoint:CGPointMake(160, 80)];
    self.plane.physicsBody.velocity = CGVectorMake(0, 0);
    self.timeSinceLastLift = 0;
    */
    [self.plane removeFromParent];
    self.plane = nil;
}
- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if ((firstBody.categoryBitMask & shipCategory) != 0 && (secondBody.categoryBitMask & laserCategory) !=0) {
        if (self.gameHasStarted) {
            [self endGame];
        }
    }
    if ((firstBody.categoryBitMask & shipCategory) != 0 && (secondBody.categoryBitMask & scoreBodyCategory) !=0) {
        if (self.gameHasStarted) {
            self.score += 1;
            [self.scoreLabel setText:[NSString stringWithFormat:@"%li", (long)self.score]];
        }
    }
}
- (CGPoint)convertPoint:(CGPoint)point {
    float newX = self.frame.size.width/(320/point.x);
    float newY = self.frame.size.height/(480/point.y);
    return CGPointMake(newX, newY);
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
