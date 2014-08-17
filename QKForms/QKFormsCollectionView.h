//
//  QKFormsCollectionView.h
//
//  Created by Eric Webster on 2014-08-16.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QKFormsOptions.h"

@interface QKFormsCollectionView : UICollectionView<UIGestureRecognizerDelegate>

// Options, which can be found in the QKFormsOptions class.
@property (nonatomic) QKFormsOptions *options;

// Navigates to the next field, based on vertical position.
- (IBAction)nextField;

// Navigates to the previous field, based on vertical position.
- (IBAction)previousField;

- (IBAction)dismissKeyboard;
- (void)dismissKeyboardWithCompletion:(void (^)(void))completion;

@end
