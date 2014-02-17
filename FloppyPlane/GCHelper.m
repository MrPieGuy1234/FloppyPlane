//
//  GCHelper.m
//  FloppyPlane
//
//  Created by Donny on 2/16/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "GCHelper.h"
#import "ViewController.h"

@implementation GCHelper
@synthesize gameCenterAvailable;
static GCHelper *sharedHelper = nil;
+ (GCHelper *)sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}
- (BOOL)isGameCenterAvailable {
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}
- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
        }
    }
    return self;
}
- (void)authenticationChanged {
    if ([GKLocalPlayer localPlayer].isAuthenticated && !self.userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated");
        self.userAuthenticated = TRUE;
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && self.userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        self.userAuthenticated = FALSE;
    }
}
- (void)authenticateLocalUser:(UIViewController *)view {
    if (!gameCenterAvailable) return;
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    NSLog(@"Authenticating local user...");
    [localPlayer setAuthenticateHandler:^(UIViewController * viewController, NSError * error) {
        if (viewController != nil) {
            [view presentViewController:viewController animated:NO completion:nil];
        } else if (localPlayer.isAuthenticated) {
            return;
        }
    }];
    [self loadLeaderboardInfo];
}
- (void)loadLeaderboardInfo {
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
        self.leaderboards = leaderboards;
        NSLog(@"Loaded leaderboard info!");
    }];
    
}
- (void)reportScore:(int64_t)score forLeaderboardID:(NSString*)identifier {
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    NSArray *scores = @[scoreReporter];
    [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
        NSLog(@"%@", error);
        NSLog(@"Sent score: %lli", score);
    }];
    
}
- (void)showLeaderboard:(ViewController *)viewController {
    GKGameCenterViewController *gcController = [[GKGameCenterViewController alloc] init];
    if (gcController != nil) {
        gcController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcController.gameCenterDelegate = viewController;
        [viewController presentViewController:gcController animated:YES completion:nil];
    }
}
@end
