//
//  QKAutoExpandingTextView.m
//
//  Created by Eric Webster on 1/29/2014.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "QKAutoExpandingTextView.h"
#import "UITextView+TextHeight.h"

NSString *const QKAutoExpandingTextViewDidChangeHeight = @"qk_aetv_change_height";

@interface QKAutoExpandingTextView ()

@property (nonatomic, weak) id<QKAutoExpandingTextViewDelegate> delegate;
@property (nonatomic, assign) CGFloat previousHeight;

@end

@implementation QKAutoExpandingTextView {
    NSLayoutConstraint *_textViewHeightConstraint;
    NSLayoutConstraint *_textViewMaxHeightConstraint;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDelegate:(id<QKAutoExpandingTextViewDelegate>)delegate
{
    [super setDelegate:delegate];
}

- (id<QKAutoExpandingTextViewDelegate>)delegate
{
    return (id<QKAutoExpandingTextViewDelegate>)[super delegate];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsLayout];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [self setHeightConstraint];
    [super layoutSubviews];
    [self performSelectorOnMainThread:@selector(sendResizeEventIfNeeded) withObject:nil waitUntilDone:NO];
}

- (void)sendResizeEventIfNeeded
{
    CGFloat height = CGRectGetHeight(self.bounds);
    if (fabs(height - self.previousHeight) > 0) {
        if ([self.delegate respondsToSelector:@selector(autoExpandingTextView:didChangeHeight:)]) {
            [self.delegate autoExpandingTextView:self didChangeHeight:height];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:QKAutoExpandingTextViewDidChangeHeight object:self];
        self.previousHeight = height;
    }
}

- (void)textChanged:(NSNotification *)notification
{
    [self setHeightConstraint];
}

- (void)setMaxHeight:(CGFloat)maxHeight
{
    _maxHeight = maxHeight;
    [self setMaxHeightConstraint];
    [self setNeedsLayout];
}

- (void)setMaxHeightConstraint
{
    if (self.maxHeight) {
        if (_textViewMaxHeightConstraint) {
            _textViewMaxHeightConstraint.constant = self.maxHeight;
        }
        else {
            for (NSLayoutConstraint *constraint in self.constraints) {
                if (constraint.firstAttribute == NSLayoutAttributeHeight && constraint.relation == NSLayoutRelationLessThanOrEqual) {
                    constraint.constant = self.maxHeight;
                    _textViewMaxHeightConstraint = constraint;
                    return;
                }
            }

            _textViewMaxHeightConstraint =
            [NSLayoutConstraint constraintWithItem:self
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:0
                                          constant:self.maxHeight];
            
            _textViewMaxHeightConstraint.priority = UILayoutPriorityDefaultHigh;
            [self addConstraint:_textViewMaxHeightConstraint];
        }
    }
}

- (void)setHeightConstraint
{
    CGFloat textHeight = [self textHeight];
    
    if (_textViewHeightConstraint) {
        _textViewHeightConstraint.constant = textHeight;
    }
    else {
        for (NSLayoutConstraint *constraint in self.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight && constraint.relation == NSLayoutRelationEqual) {
                constraint.constant = textHeight;
                _textViewHeightConstraint = constraint;
                return;
            }
        }
        
        _textViewHeightConstraint =
        [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:0
                                      constant:textHeight];
        
        _textViewHeightConstraint.priority = UILayoutPriorityDefaultLow;
        [self addConstraint:_textViewHeightConstraint];
    }
}

@end
