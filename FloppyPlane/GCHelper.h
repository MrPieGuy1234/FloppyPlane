//
//  GCHelper.h
//  FloppyPlane
//
//  Created by Donny on 2/16/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GCHelper : NSObject {
    BOOL gameCenterAvailable;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property BOOL userAuthenticated;
@property (nonatomic) NSArray *leaderboards;
+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser:(UIViewController *)viewController;
- (void)showLeaderboard:(UIViewController *)viewController;
- (void)reportScore:(int64_t)score forLeaderboardID:(NSString*)identifier;
@end
