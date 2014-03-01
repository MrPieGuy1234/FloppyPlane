//
//  GameScene.h
//  FloppyPlane
//
//  Created by Donald Lawrence on 2/14/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "KKScene.h"
#import "Cloud.h"
#import "Plane.h"
#import "Button.h"
#import "BMGlyphLabel.h"
#import "ViewController.h"
@interface GameScene : KKScene

@property (nonatomic, strong) Cloud *cloud1;
@property (nonatomic, strong) Cloud *cloud2;
@property (nonatomic, strong) Cloud *cloud3;
@property (nonatomic, strong) Plane *plane;
@property (nonatomic, strong) SKSpriteNode *logo;
@property (nonatomic, strong) SKSpriteNode *gameOver;
@property (nonatomic, strong) Button *playButton;
@property (nonatomic, strong) Button *rateButton;
@property (nonatomic, strong) Button *leaderboardButton;
@property (nonatomic, strong) Button *removeAdsButton;
@property (nonatomic, strong) Button *restorePurchasesButton;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval timeSinceLastLaser;
@property (nonatomic) NSTimeInterval timeSinceLastLift;
@property (nonatomic) BOOL lastGenOnRight;
@property (nonatomic) BOOL touchLeft;
@property (nonatomic) BOOL touchRight;
@property (nonatomic) BOOL gameHasStarted;
@property (nonatomic) BOOL removeAdsPurchased;
@property (nonatomic) NSInteger score;
@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) SKLabelNode *endScoreLabel;
@property (nonatomic) ViewController *parentView;
@property (nonatomic, strong) SKAction *coinSound;
@property (nonatomic, strong) SKAction *dieSound;
@property (nonatomic) NSInteger adCooldown;


- (void)startGame;
- (void)rate;

- (id)initWithSize:(CGSize)size andView:(ViewController *)view;
@end
