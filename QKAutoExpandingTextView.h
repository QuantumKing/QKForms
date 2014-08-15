//
//  QKAutoExpandingTextView.h
//
//  Created by Eric Webster on 1/29/2014.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

extern NSString *const QKAutoExpandingTextViewDidChangeHeight;

@class QKAutoExpandingTextView;

@protocol QKAutoExpandingTextViewDelegate <UITextViewDelegate>

@optional
- (void)autoExpandingTextView:(QKAutoExpandingTextView *)autoExpandingTextView didChangeHeight:(CGFloat)height;

@end

@interface QKAutoExpandingTextView : UITextView

@property (nonatomic, assign) CGFloat maxHeight;

- (void)setDelegate:(id<QKAutoExpandingTextViewDelegate>)delegate;
- (id<QKAutoExpandingTextViewDelegate>)delegate;

@end
