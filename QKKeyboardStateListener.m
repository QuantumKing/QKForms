//
//  QKKeyboardStateListener.m
//
//  Created by Eric Webster on 2014-08-08.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "QKKeyboardStateListener.h"

@implementation QKKeyboardStateListener

@synthesize visible = _visible;
@synthesize userInfo = _userInfo;
@synthesize animating = _animating;

+ (instancetype)sharedInstance
{
    static QKKeyboardStateListener *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)willShow
{
    _visible = NO;
    _animating = YES;
}

- (void)didShow
{
    _visible = YES;
    _animating = NO;
}

- (void)willHide
{
    _visible = YES;
    _animating = YES;
}

- (void)didHide
{
    _visible = NO;
    _animating = NO;
    _userInfo = nil;
}

- (void)willChange:(NSNotification *)notification
{
    _userInfo = [notification userInfo];
}

- (id)init
{
    if ((self = [super init])) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(willShow) name:UIKeyboardWillShowNotification object:nil];
        [center addObserver:self selector:@selector(didShow) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(willHide) name:UIKeyboardWillHideNotification object:nil];
        [center addObserver:self selector:@selector(didHide) name:UIKeyboardDidHideNotification object:nil];
        [center addObserver:self selector:@selector(willChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
