//
//  QKFormsScrollView.h
//
//  Created by Eric Webster on 2/12/2014.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

@class QKFormsOptions;

@interface QKFormsScrollView : UIScrollView<UIGestureRecognizerDelegate>

// Options, which can be found in the QKFormsOptions class.
@property (nonatomic) QKFormsOptions *options;

// Navigates to the next field, based on vertical position.
- (IBAction)nextField;

// Navigates to the previous field, based on vertical position.
- (IBAction)previousField;

- (IBAction)dismissKeyboard;
- (void)dismissKeyboardWithCompletion:(void (^)(void))completion;


@end