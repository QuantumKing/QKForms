//
//  QKFormsOptions.h
//
//  Created by Eric Webster on 2014-08-16.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QKFormsOptions : NSObject

// Whether return navigates to the next field or not.
@property (nonatomic, assign) BOOL returnShouldMoveToNextField;

// An optional property which will be sent the TouchUpInside event
// when return is pressed while editing the last field in the form.
// The property returnShouldMoveToNextField must be set to YES in order
// to use this.
@property (nonatomic, weak) UIButton *submitButton;

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