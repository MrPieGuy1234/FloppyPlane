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
#import "GCHelper.h"
#import "ViewController.h"
#import "RemoveAdsIAPHelper.h"
#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568 ) < DBL_EPSILON)
@implementation GameScene

static const uint32_t shipCategory = 0x1 << 0;
static const uint32_t laserCategory = 0x1 << 1;
static const uint32_t wallCategory = 0x1 << 2;
static const uint32_t oldLaserCategory = 0x1 << 3;
static const uint32_t scoreBodyCategory = 0x1 << 4;

- (id)initWithSize:(CGSize)size andView:(ViewController *)view {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:.7 blue:1 alpha:1];
        self.physicsWorld.contactDelegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
        
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
        
        self.removeAdsButton = [[Button alloc] initWithImageNamed:[self convertImage:@"removeAdsButton"] function:@selector(removeAds)];
        self.removeAdsButton.position = [self convertPoint:CGPointMake(160, 90)];
        
        self.restorePurchasesButton = [[Button alloc] initWithImageNamed:@"restorePurchases" function:@selector(restorePurchases)];
        self.restorePurchasesButton.position = [self convertPoint:CGPointMake(70, 15)];
        self.restorePurchasesButton.shouldGrow = NO;
        self.restorePurchasesButton.userInteractionEnabled = YES;
        
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura Condensed ExtraBold"];
        self.scoreLabel.hidden = YES;
        self.scoreLabel.zPosition = 999;
        self.scoreLabel.position = [self convertPoint:CGPointMake(160, 400)];
        
        self.endScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier Bold"];
        self.endScoreLabel.text = [NSString stringWithFormat:@"Score: %li", (long)self.score];
        self.endScoreLabel.position = [self convertPoint:CGPointMake(160, 270)];
        self.endScoreLabel.hidden = YES;
        
        self.touchRightSprite = [SKSpriteNode spriteNodeWithImageNamed:[self convertImage:@"touchRight"]];
        self.touchRightSprite.position = [self convertPoint:CGPointMake(250, 160)];
        self.touchRightSprite.texture.filteringMode = SKTextureFilteringNearest;
        self.touchRightSprite.hidden = YES;
        self.touchLeftSprite = [SKSpriteNode spriteNodeWithImageNamed:[self convertImage:@"touchLeft"]];
        self.touchLeftSprite.position = [self convertPoint:CGPointMake(70, 160)];
        self.touchLeftSprite.texture.filteringMode = SKTextureFilteringNearest;
        self.touchLeftSprite.hidden = YES;
        self.adCooldown = 0;
        
        self.coinSound = [SKAction playSoundFileNamed:@"coin.wav"];
        self.dieSound = [SKAction playSoundFileNamed:@"explosion.wav"];
        
        self.parentView = view;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.scoreLabel setScale:4];
            [self.endScoreLabel setScale:2];
            [self.restorePurchasesButton setScale:0.4];
            
        } else {
            [self.scoreLabel setScale:2];
            [self.restorePurchasesButton setScale:0.2];
            // [self.endScoreLabel setScale:.5];
        }
        
        [self addChild:self.playButton];
        [self addChild:self.gameOver];
        [self addChild:self.rateButton];
        [self addChild:self.leaderboardButton];
        [self addChild:self.scoreLabel];
        [self addChild:self.logo];
        [self addChild:self.endScoreLabel];
        [self addChild:self.cloud1];
        [self addChild:self.cloud2];
        [self addChild:self.cloud3];
        [self addChild:self.removeAdsButton];
        [self addChild:self.restorePurchasesButton];
        [self addChild:self.touchLeftSprite];
        [self addChild:self.touchRightSprite];
        
        if ([[RemoveAdsIAPHelper sharedInstance] productPurchased:@"removeAds"]) {
            [self.removeAdsButton removeFromParent];
            self.parentView.banner.hidden = YES;
            self.restorePurchasesButton.hidden = YES;
            self.parentView.iadBanner.hidden = YES;
            self.removeAdsPurchased = YES;
        } else {
            [view createBannerBottomAd];
            [view createInterstitialAd];
        }
    }
    return self;
}
- (void)removeAds {
    NSLog(@"Removing ads...");
    [[RemoveAdsIAPHelper sharedInstance] buyProduct:self.parentView.products[0]];
    if ([[RemoveAdsIAPHelper sharedInstance] productPurchased:@"removeAds"]) {
        [self.removeAdsButton removeFromParent];
    }
}
- (void)restorePurchases {
    [[RemoveAdsIAPHelper sharedInstance] restoreCompletedTransactions];
}
- (void)productPurchased:(NSNotification *)notifiction {
    self.removeAdsButton.hidden = YES;
    self.restorePurchasesButton.hidden = YES;
    self.parentView.banner.hidden = YES;
    self.parentView.iadBanner.hidden = YES;
    self.removeAdsPurchased = YES;
}
- (void)update:(NSTimeInterval)currentTime {
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > .5) {
        timeSinceLast = 0;
        self.touchRight = NO;
        self.touchLeft = NO;
    }
    [self.cloud1 update:currentTime];
    [self.cloud2 update:currentTime];
    [self.cloud3 update:currentTime];
    self.timeSinceLastScore += timeSinceLast;
    
    if (self.gameHasStarted) {
        self.timeSinceLastLaser += timeSinceLast;
        if (self.firstTouchReceieved) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                if (self.timeSinceLastLaser >= .9) {
                    self.timeSinceLastLaser = 0;
                    [self generateLaser];
                }
            } else if (IS_WIDESCREEN) {
                if (self.timeSinceLastLaser >= .9) {
                    self.timeSinceLastLaser = 0;
                    [self generateLaser];
                }
            } else {
                if (self.timeSinceLastLaser >=1) {
                    self.timeSinceLastLaser = 0;
                    [self generateLaser];
                }
            }
        }
        if (self.touchRight && self.rightLastTouched) {
            self.timeSinceLastLift += timeSinceLast;
            if (self.plane.physicsBody.velocity.dx > self.plane.maxVelocity) {
                self.plane.physicsBody.velocity = CGVectorMake(self.plane.maxVelocity, 0);
            }
            [self.plane.physicsBody applyForce:CGVectorMake(self.timeSinceLastLift*self.plane.velMultiplier, 0)];
        }
        if (self.touchLeft && !self.rightLastTouched) {
            self.timeSinceLastLift += timeSinceLast;
            if (self.plane.physicsBody.velocity.dx < -self.plane.maxVelocity) {
                self.plane.physicsBody.velocity = CGVectorMake(-self.plane.maxVelocity, 0);
            }
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
        if (!self.touchLeftSprite.hidden || !self.touchRightSprite.hidden) {
            self.touchLeftSprite.hidden = YES;
            self.touchRightSprite.hidden = YES;
            self.firstTouchReceieved = YES;
        }
        if (location.x >= self.frame.size.width/2) {
            self.touchRight = YES;
            self.rightLastTouched = YES;
            [self.plane runAction:self.plane.rotatePlaneRight];
        } else {
            self.touchLeft = YES;
            self.rightLastTouched = NO;
            [self.plane runAction:self.plane.rotatePlaneLeft];
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (self.gameHasStarted) {
            if (location.x >= self.frame.size.width/2) {
                self.touchRight = NO;
            } else {
                self.touchLeft = NO;
            }
            if (!self.touchLeft && !self.touchRight) {
                [self.plane runAction:self.plane.rotatePlaneNormal];
            }
        }
    }
}
- (void)startGame {
    NSLog(@"Game started!");
    self.parentView.banner.hidden = YES;
    self.parentView.iadBanner.hidden = YES;
    self.firstTouchReceieved = NO;
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
    self.restorePurchasesButton.hidden = YES;
    self.removeAdsButton.hidden = YES;
    
    self.scoreLabel.hidden = NO;
    self.touchLeftSprite.hidden = NO;
    self.touchRightSprite.hidden = NO;
    self.score = 0;
    self.scoreLabel.text = [NSString stringWithFormat:@"%li", (long)self.score];
    
    self.touchLeft = NO;
    self.touchRight = NO;
    
    self.playButton.userInteractionEnabled = NO;
    self.rateButton.userInteractionEnabled = NO;
    self.leaderboardButton.userInteractionEnabled = NO;
    self.removeAdsButton.userInteractionEnabled = NO;
    self.restorePurchasesButton.userInteractionEnabled = NO;
    
    self.gameHasStarted = YES;
    
    
}
- (void)rate {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id823235103"]];
}
- (void)displayLeaderboard {
    
    [[GCHelper sharedInstance] showLeaderboard:self.view.window.rootViewController];
}
- (void)generateLaser {
    if (self.gameHasStarted && !self.view.paused) {
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
    
    [self runAction:self.dieSound];
    if (!self.removeAdsPurchased) {
        self.parentView.banner.hidden = NO;
        self.parentView.iadBanner.hidden = NO;
        self.removeAdsButton.hidden = NO;
        self.restorePurchasesButton.hidden = NO;
    }
    self.gameHasStarted = NO;
    self.plane.smoke.hidden = NO;
    
    self.gameOver.hidden = NO;
    self.playButton.hidden = NO;
    self.rateButton.hidden = NO;
    self.leaderboardButton.hidden = NO;
    
    self.endScoreLabel.hidden = NO;
    
    self.playButton.userInteractionEnabled = YES;
    self.rateButton.userInteractionEnabled = YES;
    self.leaderboardButton.userInteractionEnabled = YES;
    self.scoreLabel.hidden = YES;
    self.removeAdsButton.userInteractionEnabled = YES;
    self.restorePurchasesButton.userInteractionEnabled = YES;
    
    self.gameOver.alpha = 0.0F;
    self.playButton.alpha = 0.0F;
    self.rateButton.alpha = 0.0F;
    self.leaderboardButton.alpha = 0.0F;
    self.removeAdsButton.alpha = 0.0F;
    
    self.timeSinceLastLift = 0;
    self.timeSinceLastLaser = 0;
    
    KKAction *gameOverFadeIn = [KKAction fadeAlphaTo:1 duration:.5];
    KKAction *fadePlaneOut = [KKAction fadeAlphaTo:0 duration:1.5];
    KKAction *resetPlane = [KKAction performSelector:@selector(resetPlane) onTarget:self];
    
    [self.endScoreLabel setText:[NSString stringWithFormat:@"Score: %li", (long)self.score]];
    
    [self.gameOver runAction:gameOverFadeIn];
    [self.playButton runAction:gameOverFadeIn];
    [self.rateButton runAction:gameOverFadeIn];
    [self.leaderboardButton runAction:gameOverFadeIn];
    [self.removeAdsButton runAction:gameOverFadeIn];
    [self.plane runAction:[SKAction sequence:@[fadePlaneOut, resetPlane]]];
    
    [self runAction:[SKAction waitForDuration:.2] completion:^{
        if (self.adCooldown == 5 && !self.removeAdsPurchased) {
            [self.parentView presentInterstitial];
            [self.parentView createInterstitialAd];
            self.adCooldown = 1;
        }
        
    }];
    
    [self enumerateChildNodesWithName:@"laser" usingBlock:^(SKNode *node, BOOL *stop) {
        [node runAction:fadePlaneOut];
        [node removeFromParent];
        // Laser *laser = (Laser *)node;
        // laser.leftLaser.physicsBody.contactTestBitMask = oldLaserCategory;
        // laser.rightLaser.physicsBody.contactTestBitMask = oldLaserCategory;
    }];
    
    [[GCHelper sharedInstance] reportScore:self.score forLeaderboardID:@"highScores"];
    
    self.adCooldown += 1;
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
        if (self.gameHasStarted && self.timeSinceLastScore > .5) {
            [self runAction:self.coinSound];
            self.score += 1;
            self.timeSinceLastScore = 0;
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
