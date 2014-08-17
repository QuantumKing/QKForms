//
//  QKFormsOptions.h
//
//  Created by Eric Webster on 2014-08-16.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QKFormsOptions : NSObject

// Whether return navigates to the next field or not.
// Default: YES
@property (nonatomic, assign) BOOL returnShouldMoveToNextField;

// In text views, whether return should insert a newline character.
// This overrides returnShouldMoveToNextField for text views.
// Default: NO
@property (nonatomic, assign) BOOL returnShouldInsertNewline;

// The margin between the keyboard and the field being edited.
// Default: 20
@property (nonatomic, assign) CGFloat keyboardTopMargin;

// Sliding animation customization. TODO: Doesn't quite work as expected.
@property (nonatomic, assign) UIViewAnimationOptions animationOptions;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) NSTimeInterval animationDelay;

// Whether the form view displays a shadow when its content overflows.
// In order for this to work, this view must have a superview with the same bounds.
// Default: YES
@property (nonatomic, assign) BOOL showsShadow;

// This will force the field to be pulled down towards the keyboard, even
// if it is already above the keyboard.
// Default: NO
@property (nonatomic, assign) BOOL shouldFocusFields;

@end