//
//  QKBaseFormView.h
//
//  Created by Eric Webster on 2/12/2014.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

@interface QKBaseFormView : UIScrollView<UIGestureRecognizerDelegate,UIScrollViewDelegate>

// Whether return navigates to the next field or not.
@property (nonatomic, assign) BOOL returnShouldMoveToNextField;

// Navigates to the next field, based on vertical position.
- (IBAction)nextField;

// Navigates to the previous field, based on vertical position.
- (IBAction)previousField;

- (IBAction)dismissKeyboard;
- (void)dismissKeyboardWithCompletion:(void (^)(void))completion;

// An optional property which will be sent the TouchUpInside event
// when return is pressed while editing the last field in the form.
// The property returnShouldMoveToNextField must be set to YES in order
// to use this.
@property (nonatomic, weak) IBOutlet UIButton *submitButton;

// The margin between the keyboard and the field being edited.
@property (nonatomic, assign) CGFloat keyboardTopMargin;

// Sliding animation customization. TODO: Doesn't quite work as expected.
@property (nonatomic, assign) UIViewAnimationOptions animationOptions;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) NSTimeInterval animationDelay;

// Whether the form view displays a shadow when its content overflows.
// In order for this to work, this view must have a superview with the same bounds.
@property (nonatomic, assign) BOOL showsShadow;

// This will force the field to be pulled down towards the keyboard, even
// if it is already above the keyboard.
@property (nonatomic, assign) BOOL shouldFocusFields;

@end