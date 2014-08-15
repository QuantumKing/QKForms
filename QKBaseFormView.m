//
//  QKBaseFormViewController.m
//
//  Created by Eric Webster on 2/12/2014.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "QKBaseFormView.h"
#import "QKKeyboardStateListener.h"
#import "QKAutoExpandingTextView.h"

@interface UIView (QKForms)

- (NSArray *)formFields;

@end

@implementation UIView (QKForms)

- (NSArray *)formFields
{
    NSMutableArray *results = [NSMutableArray array];
    [self _findFormFields:results];
    return [results copy];
}

- (void)_findFormFields:(NSMutableArray *)results
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
        [s _findFormFields:results];
    }
}

@end

@interface QKBaseFormView ()

@property (nonatomic) UIView *shadowView;
@property (nonatomic) NSValue *contentOffsetDiff;
@property (nonatomic) UIView *currentField;
@property (nonatomic) NSArray *fields;

@end

@implementation QKBaseFormView

- (void)setup
{
    // Start up an instance of the keyboard listener.
    [QKKeyboardStateListener sharedInstance];
    
    self.returnShouldMoveToNextField = YES;

    self.delegate = self;
    
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    recog.cancelsTouchesInView = NO;
    recog.delegate = self;
    [self addGestureRecognizer:recog];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];

    [defaultCenter addObserver:self selector:@selector(textDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(textDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (id)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)slideToOffset:(CGPoint)offset animated:(BOOL)animated userInfo:(NSDictionary *)userInfo
{
    if (animated) {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
        UIViewAnimationCurve animationCurve;
        
        if (self.animationOptions) {
            options |= self.animationOptions;
        }
        else {
            NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
            animationCurve = curveValue.intValue;
            options |= (animationCurve << 16);
        }
        
        NSTimeInterval duration = self.animationDuration;
        if (duration == 0) {
            NSNumber *number = userInfo[UIKeyboardAnimationDurationUserInfoKey];
            duration = [number doubleValue];
        }
                
        [UIView animateWithDuration:duration delay:self.animationDelay options:options animations:^{
            [super setContentOffset:offset];
        } completion:nil];
    }
    else {
        [super setContentOffset:offset];
    }
}

- (void)dismissKeyboardWithCompletion:(void (^)(void))completion
{
    if (self.contentOffsetDiff) {
        QKKeyboardStateListener *listener = [QKKeyboardStateListener sharedInstance];
        
        if ([listener isVisible] && ![listener isAnimating]) {
            __weak typeof(self) weakSelf = self;
            __block __weak id willHideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
                [[NSNotificationCenter defaultCenter] removeObserver:willHideObserver];
                
                CGPoint offset = [weakSelf.contentOffsetDiff CGPointValue];
                offset.y += weakSelf.contentOffset.y;
                if (offset.y < 0 || weakSelf.contentSize.height < CGRectGetHeight(weakSelf.bounds)) {
                    offset.y = 0;
                }
                NSDictionary *info = [notification userInfo];
                [weakSelf slideToOffset:offset animated:YES userInfo:info];
                weakSelf.contentOffsetDiff = nil;
            }];

            if (![self.currentField resignFirstResponder]) {
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

- (IBAction)dismissKeyboard
{
    [self dismissKeyboardWithCompletion:nil];
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    // Hack to prevent contentOffset being reset whenever contentSize changes while editing.
    if (![self.currentField isFirstResponder]) {
        [super setContentOffset:contentOffset];
    }
}

- (void)slideUpToField:(UIView *)field animated:(BOOL)animated
{
    __block __weak id observer;
    __weak typeof(self) weakSelf = self;

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
        
        CGFloat defaultMargin = UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? 44 : 11;
        CGPoint offset = weakSelf.contentOffset;
        CGFloat dy = floorf(CGRectGetMaxY(fieldFrame) - CGRectGetMinY(keyboardFrame) + weakSelf.keyboardTopMargin + defaultMargin);
        
        if (dy > 0 || self.shouldFocusFields) {
            offset.y += dy;
            weakSelf.contentOffsetDiff = [NSValue valueWithCGPoint:CGPointMake(0, -dy)];
            [weakSelf slideToOffset:offset animated:animated userInfo:info];
        }
        else {
            UIView *firstField = [weakSelf.fields firstObject];
            CGFloat y = CGRectGetMinY([firstField convertRect:firstField.bounds toView:weakSelf]);
            
            if (weakSelf.contentSize.height < CGRectGetHeight(weakSelf.bounds) && offset.y > 0) {
                offset.y += MAX(dy, -offset.y);
                weakSelf.contentOffsetDiff = [NSValue valueWithCGPoint:CGPointZero];
                [weakSelf slideToOffset:offset animated:animated userInfo:info];
            }
            else if (y < offset.y) {
                offset.y += dy;
                weakSelf.contentOffsetDiff = [NSValue valueWithCGPoint:CGPointZero];
                [weakSelf slideToOffset:offset animated:animated userInfo:info];
            }
            else if (offset.y + dy < 0) {
                offset.y = 0;
                weakSelf.contentOffsetDiff = [NSValue valueWithCGPoint:CGPointZero];
                [weakSelf slideToOffset:offset animated:animated userInfo:info];
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

- (void)slideUpToField:(UIView *)field
{
    [self slideUpToField:field animated:YES];
}

- (void)orientationDidChange:(NSNotification *)notification
{
    if (![self.currentField isFirstResponder]) {
        return;
    }
    
    QKKeyboardStateListener *listener = [QKKeyboardStateListener sharedInstance];
    if ([listener isVisible] || [listener isAnimating]) {
        [self slideUpToField:self.currentField];
    }
}

- (void)textDidBeginEditing:(NSNotification *)notification
{
    id firstResponder = notification.object;
    if (firstResponder == self.currentField) {
        return;
    }
    
    self.fields = [self formFields];
    if (![self.fields containsObject:firstResponder]) {
        return;
    }
    self.fields = [self.fields sortedArrayUsingComparator:^NSComparisonResult(UIView *v1, UIView *v2){
        CGFloat y1 = CGRectGetMinY([v1 convertRect:v1.bounds toView:self]);
        CGFloat y2 = CGRectGetMinY([v2 convertRect:v2.bounds toView:self]);
        return y1 > y2 ? NSOrderedDescending : NSOrderedAscending;
    }];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];

    if ([firstResponder isKindOfClass:[UITextView class]]) {
        [defaultCenter addObserver:self selector:@selector(textDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:firstResponder];
        
        if (self.returnShouldMoveToNextField) {
            [defaultCenter addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:firstResponder];
        }
        
        if ([firstResponder isKindOfClass:[QKAutoExpandingTextView class]]) {
            [defaultCenter addObserver:self selector:@selector(autoSizeTextViewDidChangeHeight:) name:QKAutoExpandingTextViewDidChangeHeight object:firstResponder];
        }
        
        // Hack to get the correct cursor position upon editing.
        [self performSelectorOnMainThread:@selector(slideUpToField:) withObject:firstResponder waitUntilDone:NO];
    }
    else if ([firstResponder isKindOfClass:[UITextField class]]) {
        [self slideUpToField:firstResponder];
        [defaultCenter addObserver:self selector:@selector(textDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:firstResponder];
        
        if (self.returnShouldMoveToNextField) {
            [firstResponder addTarget:self action:@selector(nextField) forControlEvents:UIControlEventEditingDidEndOnExit];
        }
    }
    
    self.currentField = firstResponder;
}

- (void)textDidEndEditing:(NSNotification *)notification
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    [defaultCenter removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
    [defaultCenter removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [defaultCenter removeObserver:self name:QKAutoExpandingTextViewDidChangeHeight object:nil];
    
    self.currentField = nil;
}

- (void)textDidChange:(NSNotification *)notification
{
    id textResponder = notification.object;
    NSString *text = [textResponder text];
    NSRange range = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    
    if (range.location != NSNotFound) {
        // User has pressed return button.
        [textResponder setText:[text stringByReplacingCharactersInRange:range withString:@""]];
        [self nextField];
    }
}

- (void)nextField
{
    NSUInteger idx = [self.fields indexOfObject:self.currentField];
    if (++idx < [self.fields count]) {
        UIView *field = self.fields[idx];
        if ([field canBecomeFirstResponder]) {
            [self.fields[idx] becomeFirstResponder];
        }
        else {
            [self nextField];
        }
    }
    else {
        // At the last field. Submit!
        [self dismissKeyboardWithCompletion:^{
            // Press the submit button.
            [self.submitButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }];
    }
}

- (void)previousField
{
    NSUInteger idx = [self.fields indexOfObject:self.currentField];
    if (--idx > 0) {
        UIView *field = self.fields[idx];
        if ([field canBecomeFirstResponder]) {
            [self.fields[idx] becomeFirstResponder];
        }
        else {
            [self previousField];
        }
    }
}

#pragma mark - QKAutoExpandingTextViewDelegate methods

- (void)autoSizeTextViewDidChangeHeight:(NSNotification *)notification
{
    QKAutoExpandingTextView *autoExpandingTextView = notification.object;
    if ([autoExpandingTextView isFirstResponder]) {
        [self slideUpToField:autoExpandingTextView animated:NO];
    }
}

#pragma mark - UIScrollView bottom shadow

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.shadowView.hidden = scrollView.contentOffset.y >= (scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds) - 10);
}

- (void)layoutSubviews
{
    if (self.contentOffset.y < (self.contentSize.height - CGRectGetHeight(self.bounds) - 10)) {
        
        if (!self.shadowView) {
            self.superview.clipsToBounds = YES;
            
            self.shadowView = [[UIView alloc] init];
            self.shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
            self.shadowView.layer.shadowOpacity = 1.0;
            self.shadowView.layer.shadowRadius = 8.0;
            self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.shadowView.bounds].CGPath;
            
            // TODO: If no superview exists, add one.
            [self.superview addSubview:self.shadowView];
            [self setShadowViewConstraints];
            [self.shadowView layoutIfNeeded];
        }
        
        self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.shadowView.bounds].CGPath;
    }
    else {
        self.shadowView.hidden = YES;
    }

    [super layoutSubviews];
}

- (void)setShadowViewConstraints
{
    self.shadowView.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *cb = [NSLayoutConstraint constraintWithItem:self.superview
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.shadowView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-4];
    
    NSLayoutConstraint *cl = [NSLayoutConstraint constraintWithItem:self.superview
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.shadowView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0];
    
    NSLayoutConstraint *ct = [NSLayoutConstraint constraintWithItem:self.superview
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.shadowView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0];
    
    NSLayoutConstraint *ch = [NSLayoutConstraint constraintWithItem:self.shadowView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:0
                                                           constant:4];
    
    [self.superview addConstraints:@[cb,cl,ct]];
    [self.shadowView addConstraint:ch];
}

@end

