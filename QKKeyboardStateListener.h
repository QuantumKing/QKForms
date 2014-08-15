//
//  QKKeyboardStateListener.h
//
//  Created by Eric Webster on 2014-08-08.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QKKeyboardStateListener : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, readonly, getter = isVisible) BOOL visible;
@property (nonatomic, readonly, getter = isAnimating) BOOL animating;
@property (nonatomic, readonly) NSDictionary *userInfo;

@end
