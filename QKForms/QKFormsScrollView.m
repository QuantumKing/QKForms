//
//  QKBaseFormViewController.m
//
//  Created by Eric Webster on 2/12/2014.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "QKFormsScrollView.h"

@interface UIScrollView (QKFormsPrivate)

- (void)QKForms_setup;
- (void)QKForms_dismissKeyboardWithCompletion:(void (^)(void))completion;
- (void)QKForms_dismissKeyboard;

- (void)QKForms_nextField;
- (void)QKForms_previousField;

- (void)QKForms_setContentOffset:(CGPoint)contentOffset;

- (QKFormsOptions *)QKForms_formOptions;

@end

@implementation QKFormsScrollView

- (QKFormsOptions *)options
{
    return [super QKForms_formOptions];
}

- (void)QKForms_setup
{
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    recog.cancelsTouchesInView = NO;
    recog.delegate = self;
    [self addGestureRecognizer:recog];
    
    [super QKForms_setup];
}

- (void)dismissKeyboardWithCompletion:(void (^)(void))completion
{
    [super QKForms_dismissKeyboardWithCompletion:completion];
}

- (void)dismissKeyboard
{
    [super QKForms_dismissKeyboard];
}

- (void)nextField
{
    [super QKForms_nextField];
}

- (void)previousField
{
    [super QKForms_previousField];
}

- (id)init
{
    if (self = [super init]) {
        [self QKForms_setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self QKForms_setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self QKForms_setup];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super QKForms_setContentOffset:contentOffset];
}

- (void)QKForms_forceSetContentOffset:(CGPoint)contentOffset
{
    // Hack to prevent contentOffset being reset whenever contentSize changes while editing.
    [super setContentOffset:contentOffset];
}

@end

