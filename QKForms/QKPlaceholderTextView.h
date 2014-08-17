//
//  QKPlaceholderTextView.h
//
//  Created by Eric Webster on 2014-03-08.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "QKAutoExpandingTextView.h"

@interface QKPlaceholderTextView : QKAutoExpandingTextView

@property (nonatomic) NSString *placeholder;
@property (nonatomic) UIColor *placeholderColor;

@end
