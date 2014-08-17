//
//  QKFormsScrollView.h
//
//  Created by Eric Webster on 2/12/2014.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "QKFormsOptions.h"

@interface QKFormsScrollView : UIScrollView<UIGestureRecognizerDelegate>

// Options, which can be found in the QKFormsOptions class.
@property (nonatomic, readonly) QKFormsOptions *options;

// An optional property which will be sent the TouchUpInside event
// when return is pressed while editing the last field in the form.
// The property returnShouldMoveToNextField must be set to YES in order
// to use this.
@property (nonatomic, weak) IBOutlet UIButton *submitButton;

// Navigates to the next field, based on vertical position.
- (IBAction)nextField;

// Navigates to the previous field, based on vertical position.
- (IBAction)previousField;

- (IBAction)dismissKeyboard;
- (void)dismissKeyboardWithCompletion:(void (^)(void))completion;


@end