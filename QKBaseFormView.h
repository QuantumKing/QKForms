//
//  QKBaseFormView.h
//
//  Created by Eric Webster on 2/12/2014.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

@interface QKBaseFormView : UIScrollView<UIGestureRecognizerDelegate,UIScrollViewDelegate>

- (IBAction)previousField;
- (IBAction)nextField;
- (IBAction)dismissKeyboard;

- (void)dismissKeyboardWithCompletion:(void (^)(void))completion;

@property (nonatomic, weak) IBOutlet UIButton *submitButton;
@property (nonatomic, assign) CGFloat keyboardTopMargin;

// Sliding animation
@property (nonatomic, assign) UIViewAnimationOptions animationOptions;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) NSTimeInterval animationDelay;

@property (nonatomic, assign) BOOL shouldFocusFields;
@property (nonatomic, assign) BOOL returnShouldMoveToNextField;

@end