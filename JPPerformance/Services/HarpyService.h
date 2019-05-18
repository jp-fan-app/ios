//
//  HarpyService.h
//  MultiStopwatch
//
//  Created by Christoph Pageler on 05.01.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HarpyServiceDelegate

- (void)harpyServiceDid:(NSString *)event;

@end


@interface HarpyService : NSObject

@property (strong, nonatomic) UIViewController *presentingViewController;
@property (weak, nonatomic) id<HarpyServiceDelegate> delegate;

- (void)prepare;
- (void)checkVersion;
- (void)checkVersionDaily;

@end
