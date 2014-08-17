//
//  UIScrollView+QKForms.m
//
//  Created by Eric Webster on 2014-08-16.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "UIScrollView+QKForms.h"
#import "QKKeyboardStateListener.h"
#import "QKFormsOptions.h"
#import <objc/runtime.h>

NSString *const QKFormsWillSendSubmitEvent = @"QKForms_will_send_submit_event";

@interface UIView (QKForms)

- (NSArray *)QKForms_fields;

@end

@implementation UIView (QKForms)

- (NSArray *)QKForms_fields
{
    NSMutableArray *results = [NSMutableArray array];
    [self QKForms_findFormFields:results];
    return [results copy];
}

- (void)QKForms_findFormFields:(NSMutableArray *)results
{
    for (UIView *s in self.subviews) {
        if ([s isKindOfClass:[UITextField class]]) {
            [results addObject:s];
        }
        else if ([s isKindOfClass:[UITextView class]]) {
            if ([(UITextView *)s isEditable]) {
                [results addObject:s];
            }
        }
        [s QKForms_findFormFields:results];
    }
}

@end

@interface QKFormsPrivateData : NSObject

@property (nonatomic) UIView *shadowView;
@property (nonatomic) NSValue *contentOffsetDiff;
@property (nonatomic) UIView *currentField;
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;
@property (nonatomic) NSArray *fields;

@end

@implementation UIScrollView (QKForms)

static const int kFormOptionsKey;
static const int kFormPrivateDataKey;

- (void)QKForms_setup
{
    // Start up an instance of the keyboard listener.
    [QKKeyboardStateListener sharedInstance];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self selector:@selector(QKForms_textDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(QKForms_textDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(QKForms_orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (QKFormsOptions *)QKForms_formOptions
{
    QKFormsOptions *options = objc_getAssociatedObject(self, &kFormOptionsKey);
    if (options == nil) {
        options = [[QKFormsOptions alloc] init];
        options.showsShadow = YES;
        options.returnShouldMoveToNextField = YES;
        options.keyboardTopMargin =  20;
        objc_setAssociatedObject(self, &kFormOptionsKey, options, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return options;
}

- (QKFormsPrivateData *)QKForms_privateData
{
    QKFormsPrivateData *data = objc_getAssociatedObject(self, &kFormPrivateDataKey);
    if (data == nil) {
        data = [[QKFormsPrivateData alloc] init];
        data.currentOrientation = [UIDevice currentDevice].orientation;
        objc_setAssociatedObject(self, &kFormPrivateDataKey, data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return data;
}

- (void)QKForms_setContentSize:(CGSize)contentSize
{
    QKFormsPrivateData *data = self.QKForms_privateData;
    
    if ([data.currentField isFirstResponder]) {
        [self performSelectorOnMainThread:@selector(QKForms_slideUpToField:) withObject:data.currentField waitUntilDone:NO];
    }
    else {
        [self QKForms_updateShadow];
    }
}

- (void)QKForms_setContentOffset:(CGPoint)contentOffset
{
    QKFormsPrivateData *data = self.QKForms_privateData;
    
    if (![data.currentField isFirstResponder]) {
        [self QKForms_forceSetContentOffset:contentOffset];
        [self QKForms_updateShadow];
    }
}

- (void)QKForms_forceSetContentOffset:(CGPoint)contentOffset
{
    // Override in subclasses.
    return;
}

- (void)QKForms_slideToOffset:(CGPoint)offset animated:(BOOL)animated userInfo:(NSDictionary *)userInfo
{
    QKFormsOptions *options = self.QKForms_formOptions;
    
    if (animated) {
        UIViewAnimationOptions animationOptions = UIViewAnimationOptionBeginFromCurrentState;
        UIViewAnimationCurve animationCurve;
        
        if (options.animationOptions) {
            animationOptions |= options.animationOptions;
        }
        else {
            NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
            animationCurve = curveValue.intValue;
            animationOptions |= (animationCurve << 16);
        }
        
        NSTimeInterval duration = options.animationDuration;
        if (duration == 0) {
            NSNumber *number = userInfo[UIKeyboardAnimationDurationUserInfoKey];
            duration = [number doubleValue];
        }
        
        [UIView animateWithDuration:duration delay:options.animationDelay options:animationOptions animations:^{
            [self QKForms_forceSetContentOffset:offset];
        } completion:nil];
    }
    else {
        [self QKForms_forceSetContentOffset:offset];
    }
}

- (void)QKForms_dismissKeyboardWithCompletion:(void (^)(void))completion
{
    __weak QKFormsPrivateData *data = self.QKForms_privateData;
    
    if (data.contentOffsetDiff) {
        QKKeyboardStateListener *listener = [QKKeyboardStateListener sharedInstance];
        
        if ([listener isVisible] && ![listener isAnimating]) {
            __weak typeof(self) weakSelf = self;
            __block __weak id willHideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
                [[NSNotificationCenter defaultCenter] removeObserver:willHideObserver];
                
                CGPoint offset = [data.contentOffsetDiff CGPointValue];
                offset.y += weakSelf.contentOffset.y;
                if (offset.y < 0 || weakSelf.contentSize.height < CGRectGetHeight(weakSelf.bounds)) {
                    offset.y = 0;
                }
                else if (weakSelf.contentSize.height < CGRectGetHeight(weakSelf.bounds) + weakSelf.contentOffset.y) {
                    offset.y = weakSelf.contentSize.height - CGRectGetHeight(weakSelf.bounds);
                }
                NSDictionary *info = [notification userInfo];
                [weakSelf QKForms_slideToOffset:offset animated:YES userInfo:info];
                data.contentOffsetDiff = nil;
            }];
            
            if (![data.currentField resignFirstResponder]) {
                [[NSNotificationCenter defaultCenter] removeObserver:willHideObserver];
            }
            else if (completion) {
                __block __weak id didHideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
                    [[NSNotificationCenter defaultCenter] removeObserver:didHideObserver];
                    completion();
                }];
            }
        }
    }
    else if (completion) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:completion];
    }
}

- (void)QKForms_dismissKeyboard
{
    [self QKForms_dismissKeyboardWithCompletion:nil];
}

- (void)QKForms_slideUpToField:(UIView *)field animated:(BOOL)animated
{
    __block __weak id observer;
    __weak typeof(self) weakSelf = self;
    __weak QKFormsOptions *options = self.QKForms_formOptions;
    __weak QKFormsPrivateData *data = self.QKForms_privateData;
    
    void (^callback)(id notification) = ^(id notification){
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
        
        NSDictionary *info = [notification userInfo];
        NSValue *rectValue = info[UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrame = [weakSelf convertRect:[rectValue CGRectValue] fromView:nil];
        CGRect fieldFrame;
        
        if ([field isKindOfClass:[UITextView class]]) {
            // If field is a text view, then slide to the caret frame.
            UITextPosition *pos = [(UITextView *)field selectedTextRange].start;
            fieldFrame = [(UITextView *)field caretRectForPosition:pos];
        }
        else {
            fieldFrame = field.bounds;
        }
        fieldFrame = [field convertRect:fieldFrame toView:weakSelf];
        
        CGPoint offset = weakSelf.contentOffset;
        CGFloat dy = floorf(CGRectGetMaxY(fieldFrame) - CGRectGetMinY(keyboardFrame) + options.keyboardTopMargin);
        
        if (dy > 0 || options.shouldFocusFields) {
            offset.y += dy;
            data.contentOffsetDiff = [NSValue valueWithCGPoint:CGPointMake(0, -dy)];
            [weakSelf QKForms_slideToOffset:offset animated:animated userInfo:info];
        }
        else {
            UIView *firstField = [data.fields firstObject];
            CGFloat y = CGRectGetMinY([firstField convertRect:firstField.bounds toView:weakSelf]);
            
            if (weakSelf.contentSize.height < CGRectGetHeight(weakSelf.bounds) && offset.y > 0) {
                offset.y += MAX(dy, -offset.y);
                data.contentOffsetDiff = [NSValue valueWithCGPoint:CGPointZero];
                [weakSelf QKForms_slideToOffset:offset animated:animated userInfo:info];
            }
            else if (y < offset.y) {
                offset.y += dy;
                data.contentOffsetDiff = [NSValue valueWithCGPoint:CGPointZero];
                [weakSelf QKForms_slideToOffset:offset animated:animated userInfo:info];
            }
            else if (offset.y + dy < 0) {
                offset.y = 0;
                data.contentOffsetDiff = [NSValue valueWithCGPoint:CGPointZero];
                [weakSelf QKForms_slideToOffset:offset animated:animated userInfo:info];
            }
        }
    };
    
    QKKeyboardStateListener *listener = [QKKeyboardStateListener sharedInstance];
    
    if ([listener isVisible] || [listener isAnimating]) {
        callback(listener);
    }
    else {
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:callback];
    }
}

- (void)QKForms_slideUpToField:(UIView *)field
{
    [self QKForms_slideUpToField:field animated:YES];
}

- (void)QKForms_orientationDidChange:(NSNotification *)notification
{
    UIDeviceOrientation o = [UIDevice currentDevice].orientation;
    switch (o) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            break;
            
        default:
            return;
    }
    
    QKFormsPrivateData *data = self.QKForms_privateData;
    
    if (![data.currentField isFirstResponder] || data.currentOrientation == o) {
        return;
    }
    data.currentOrientation = o;
    
    QKKeyboardStateListener *listener = [QKKeyboardStateListener sharedInstance];
    if ([listener isVisible] || [listener isAnimating]) {
        [self performSelectorOnMainThread:@selector(QKForms_slideUpToField:) withObject:data.currentField waitUntilDone:NO];
    }
}

- (void)QKForms_textDidBeginEditing:(NSNotification *)notification
{
    QKFormsPrivateData *data = self.QKForms_privateData;
    
    id firstResponder = notification.object;
    if (firstResponder == data.currentField) {
        return;
    }
    
    data.fields = [self QKForms_fields];
    if (![data.fields containsObject:firstResponder]) {
        return;
    }
    data.fields = [data.fields sortedArrayUsingComparator:^NSComparisonResult(UIView *v1, UIView *v2){
        CGFloat y1 = CGRectGetMinY([v1 convertRect:v1.bounds toView:self]);
        CGFloat y2 = CGRectGetMinY([v2 convertRect:v2.bounds toView:self]);
        return y1 > y2 ? NSOrderedDescending : NSOrderedAscending;
    }];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    if ([firstResponder isKindOfClass:[UITextView class]]) {
        [defaultCenter addObserver:self selector:@selector(QKForms_textDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:firstResponder];
        
        [defaultCenter addObserver:self selector:@selector(QKForms_textDidChange:) name:UITextViewTextDidChangeNotification object:firstResponder];
        
        // Hack to get the correct cursor position upon editing.
        [self performSelectorOnMainThread:@selector(QKForms_slideUpToField:) withObject:firstResponder waitUntilDone:NO];
    }
    else if ([firstResponder isKindOfClass:[UITextField class]]) {
        [self QKForms_slideUpToField:firstResponder];
        [defaultCenter addObserver:self selector:@selector(QKForms_textDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:firstResponder];
        
        [firstResponder addTarget:self action:@selector(QKForms_editingDidEndOnExit) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    
    data.currentField = firstResponder;
}

- (void)QKForms_textDidEndEditing:(NSNotification *)notification
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    [defaultCenter removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
    [defaultCenter removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    
    QKFormsPrivateData *data = self.QKForms_privateData;
    data.currentField = nil;
}

- (void)QKForms_editingDidEndOnExit
{
    QKFormsOptions *options = self.QKForms_formOptions;
    if (options.returnShouldMoveToNextField) {
        [self QKForms_nextField];
    }
}

- (void)QKForms_textDidChange:(NSNotification *)notification
{
    QKFormsOptions *options = self.QKForms_formOptions;
    if (options.returnShouldInsertNewline) {
        return;
    }
    else if (options.returnShouldMoveToNextField) {
        id textResponder = notification.object;
        NSString *text = [textResponder text];
        NSRange range = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
        
        if (range.location != NSNotFound) {
            // User has pressed return.
            [textResponder setText:[text stringByReplacingCharactersInRange:range withString:@""]];
            [self QKForms_nextField];
        }
    }
}

- (void)QKForms_nextField
{
    QKFormsPrivateData *data = self.QKForms_privateData;
    
    NSUInteger idx = [data.fields indexOfObject:data.currentField];
    if (++idx < [data.fields count]) {
        UIView *field = data.fields[idx];
        if ([field canBecomeFirstResponder]) {
            [data.fields[idx] becomeFirstResponder];
        }
        else {
            [self QKForms_nextField];
        }
    }
    else {
        __weak typeof(self) weakSelf = self;
        // At the last field. Submit!
        [self QKForms_dismissKeyboardWithCompletion:^{
            // Send a submit notification.
            [[NSNotificationCenter defaultCenter] postNotificationName:QKFormsWillSendSubmitEvent object:weakSelf];
        }];
    }
}

- (void)QKForms_previousField
{
    QKFormsPrivateData *data = self.QKForms_privateData;
    
    NSUInteger idx = [data.fields indexOfObject:data.currentField];
    if (--idx > 0) {
        UIView *field = data.fields[idx];
        if ([field canBecomeFirstResponder]) {
            [data.fields[idx] becomeFirstResponder];
        }
        else {
            [self QKForms_previousField];
        }
    }
}

#pragma mark - Overflow shadow

- (void)QKForms_updateShadow
{
    QKFormsPrivateData *data = self.QKForms_privateData;
    QKFormsOptions *options = self.QKForms_formOptions;
    
    if (!options.showsShadow) {
        data.shadowView.hidden = YES;
        return;
    }
    
    if (self.contentOffset.y < (self.contentSize.height - CGRectGetHeight(self.bounds) - 10)) {
        
        if (data.shadowView == nil) {
            self.superview.clipsToBounds = YES;
            
            UIView *shadowView = [[UIView alloc] init];;
            shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
            shadowView.layer.shadowOpacity = 1.0;
            shadowView.layer.shadowRadius = 8.0;
            shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowView.bounds].CGPath;
            
            // TODO: If no superview exists, add one.
            [self.superview addSubview:shadowView];
            [self QKForms_setShadowViewConstraints:shadowView];
            [shadowView layoutIfNeeded];
            data.shadowView = shadowView;
        }
        
        data.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:data.shadowView.bounds].CGPath;
        data.shadowView.hidden = NO;
    }
    else {
        data.shadowView.hidden = YES;
    }
}

- (void)QKForms_setShadowViewConstraints:(UIView *)shadowView
{
    shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *cb = [NSLayoutConstraint constraintWithItem:self.superview
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:shadowView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-4];
    
    NSLayoutConstraint *cl = [NSLayoutConstraint constraintWithItem:self.superview
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:shadowView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0];
    
    NSLayoutConstraint *ct = [NSLayoutConstraint constraintWithItem:self.superview
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:shadowView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0];
    
    NSLayoutConstraint *ch = [NSLayoutConstraint constraintWithItem:shadowView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:0
                                                           constant:4];
    
    [self.superview addConstraints:@[cb,cl,ct]];
    [shadowView addConstraint:ch];
}

@end

@implementation QKFormsPrivateData
@end
