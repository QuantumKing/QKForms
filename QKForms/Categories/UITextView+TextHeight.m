//
//  UITextView+TextHeight.m
//
//  Created by Eric Webster on 1/29/2014.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "UITextView+TextHeight.h"

@implementation UITextView (TextHeight)

- (CGFloat)textHeight
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        
        CGRect frame = self.bounds;
        
        UIEdgeInsets textContainerInsets = self.textContainerInset;
        UIEdgeInsets contentInsets = self.contentInset;
        
        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + self.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
        
        frame.size.width -= leftRightPadding;
        
        NSMutableAttributedString *textToMeasure = [self.attributedText mutableCopy];
        if ([textToMeasure length] > 0) {
            unichar lastChar = [textToMeasure.string characterAtIndex:[textToMeasure length]-1];
            if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastChar]) {
                NSAttributedString *temp = [[NSAttributedString alloc] initWithString:@"-"];
                [textToMeasure appendAttributedString:temp];
            }
            
            CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                      context:nil];
            
            CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding) + 2;
            return measuredHeight;
        }
        else {
            return ceilf(self.font.lineHeight + topBottomPadding) + 2;
        }
    }
    else {
        return self.contentSize.height + 2;
    }
}

@end
