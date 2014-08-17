//
//  QKPlaceholderTextView.m
//
//  Created by Eric Webster on 2014-03-08.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "QKPlaceholderTextView.h"

@interface QKPlaceholderTextView ()

@property (nonatomic) UILabel *placeholderLabel;

@end

@interface QKAutoExpandingTextView ()

- (void)textChanged:(NSNotification *)notification;

@end

@implementation QKPlaceholderTextView

@synthesize placeholderColor = _placeholderColor;

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self addOrRemovePlaceholder];
}

- (void)addOrRemovePlaceholder
{
    if ([self.placeholder length] == 0) {
        return;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        if([self.text length] == 0) {
            self.placeholderLabel.alpha = 1;
        }
        else {
            self.placeholderLabel.alpha = 0;
        }
    }];
}

- (void)textChanged:(NSNotification *)notification
{
    if ([super respondsToSelector:@selector(textChanged:)]) {
        [super textChanged:notification];
    }
    [self addOrRemovePlaceholder];
}

- (UIColor *)placeholderColor
{
    if (_placeholderColor == nil) {
        _placeholderColor = [UIColor lightGrayColor];
    }
    return _placeholderColor;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    self.placeholderLabel.textColor = placeholderColor;
    _placeholderColor = placeholderColor;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;

    if([self.placeholder length] > 0 && !self.placeholderLabel) {
        self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,9,0,0)];
        self.placeholderLabel.alpha = [self.text length] == 0 ? 1 : 0;
        self.placeholderLabel.lineBreakMode = NSLineBreakByClipping;
        self.placeholderLabel.numberOfLines = 1;
        self.placeholderLabel.font = self.font;
        self.placeholderLabel.backgroundColor = [UIColor clearColor];
        self.placeholderLabel.textColor = self.placeholderColor;
        [self addSubview:self.placeholderLabel];
        [self sendSubviewToBack:self.placeholderLabel];
    }
    
    self.placeholderLabel.text = self.placeholder;
    
    CGRect frame = self.placeholderLabel.frame;
    frame.size.width = self.bounds.size.width;
    self.placeholderLabel.frame = frame;
    [self.placeholderLabel sizeToFit];
}

@end
