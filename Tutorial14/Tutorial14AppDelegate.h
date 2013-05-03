//
//  Tutorial14AppDelegate.h
//  Tutorial14
//
//  Created by Mike Daley on 20/03/2011.
//  Copyright 2011 Personal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tutorial14ViewController;

@interface Tutorial14AppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet Tutorial14ViewController *viewController;

@end
