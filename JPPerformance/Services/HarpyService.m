//
//  HarpyService.m
//  MultiStopwatch
//
//  Created by Christoph Pageler on 05.01.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//

#import "HarpyService.h"
#import <Harpy/Harpy.h>

@interface HarpyService() <HarpyDelegate>
@end

@implementation HarpyService

- (void)prepare {
    [[Harpy sharedInstance] setPresentingViewController:_presentingViewController];
    [[Harpy sharedInstance] setDelegate:self];
}

- (void)checkVersion {
    [[Harpy sharedInstance] checkVersion];
}

- (void)checkVersionDaily {
    [[Harpy sharedInstance] checkVersionDaily];
}

#pragma mark - HarpyDelegate

- (void)harpyDidShowUpdateDialog {
    [_delegate harpyServiceDid:@"showUpdateDialog"];
}

- (void)harpyUserDidCancel {
    [_delegate harpyServiceDid:@"cancel"];
}

- (void)harpyUserDidSkipVersion {
    [_delegate harpyServiceDid:@"skipVersion"];
}

- (void)harpyUserDidLaunchAppStore {
    [_delegate harpyServiceDid:@"launchAppStore"];
}

@end
