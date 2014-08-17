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
        frame.size.height -= topBottomPadding;
        
        NSString *textToMeasure = self.text;
        unichar lastChar = [textToMeasure characterAtIndex:[textToMeasure length]-1];
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastChar]) {
            textToMeasure = [textToMeasure stringByAppendingString:@"-"];
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSDictionary *attributes = @{ NSFontAttributeName: self.font, NSParagraphStyleAttributeName : paragraphStyle };
        
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
        
        CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        return measuredHeight;
    }
    else {
        return self.contentSize.height;
    }
}

@end
