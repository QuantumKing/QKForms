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
    CGRect rect = [self.attributedText boundingRectWithSize:(CGSize){CGRectGetWidth(self.bounds) - 10.0f, CGFLOAT_MAX}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    
    if ([self.attributedText length]) {
        return floorf(rect.size.height + 20.0f);
    }
    return floorf(rect.size.height + self.font.lineHeight + 7.0f);
}

@end
