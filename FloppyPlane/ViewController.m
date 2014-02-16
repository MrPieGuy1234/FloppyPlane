/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <KoboldKit.h>
#import "ViewController.h"
#import "GameScene.h"

@implementation ViewController

-(void) presentFirstScene
{
	NSLog(@"%@", koboldKitCommunityVersion());
	NSLog(@"%@", koboldKitProVersion());

	// create and present first scene
	GameScene* scene = [GameScene sceneWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
	[self.kkView presentScene:scene];
}
- (BOOL)shouldAutorotate {
    return NO;
}
@end
