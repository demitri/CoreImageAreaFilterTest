//
//  AppDelegate.h
//  Area Core Image Filter Test
//
//  Created by Demitri Muna on 10/27/15.
//  Copyright © 2015 Demitri Muna. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) CIImage *image;
@property (nonatomic, strong) CIVector *imageExtent;

@end

