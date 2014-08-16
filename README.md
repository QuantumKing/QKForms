QKForms
=======

Automatically handles moving text fields and text views out of the way of the keyboard. Also handles expanding text views to fit their text. Device orientation agnostic.

##Usage

Here is a step by step guide to using QKForms using interface builder. The demo these steps refer to is included in `QKFormsDemo`.

###Step 1
![](https://raw.githubusercontent.com/QuantumKing/QKForms/master/QKFormsDemo/screenshots/step1.png)

###Step 2
![](https://raw.githubusercontent.com/QuantumKing/QKForms/master/QKFormsDemo/screenshots/step2.png)

###Step 3
![](https://raw.githubusercontent.com/QuantumKing/QKForms/master/QKFormsDemo/screenshots/step4.png)

###That's it!
Everything is handled automatically after you've designed your form. Any text view with the class `QKAutoExpandingTextView` will expand as you type:

![](https://raw.githubusercontent.com/QuantumKing/QKForms/master/QKFormsDemo/screenshots/textview.png)

and the class `QKBaseFormView` handles moving its text fields and text views out of the way of the keyboard. It also handles hiding the keyboard whenever it receives a tap gesture.

##Options

There are a few options and functions you may use on your `QKBaseFormView`:

``` obj-c
// Navigates to the next field, based on vertical position.
- (IBAction)nextField;

// Navigates to the previous field, based on vertical position.
- (IBAction)previousField;

- (IBAction)dismissKeyboard;
- (void)dismissKeyboardWithCompletion:(void (^)(void))completion;

// An optional property which will be sent the TouchUpInside event
// when return is pressed while editing the last field in the form.
// The property returnShouldMoveToNextField must be set to YES in order
// to use this.
@property (nonatomic, weak) IBOutlet UIButton *submitButton;

// The margin between the keyboard and the field being edited.
@property (nonatomic, assign) CGFloat keyboardTopMargin;

// Sliding animation customization. TODO: Doesn't quite work as expected.
@property (nonatomic, assign) UIViewAnimationOptions animationOptions;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) NSTimeInterval animationDelay;

// Whether the form view displays a shadow when its content overflows.
// In order for this to work, this view must have a superview with the same bounds.
@property (nonatomic, assign) BOOL showsShadow;

// This will force the field to be pulled down towards the keyboard, even
// if it is already above the keyboard.
@property (nonatomic, assign) BOOL shouldFocusFields;
```

##Installation via Cocoapods

Add `pod 'QKForms', '~> 0.0'` to your `Podfile` and run `pod` to install.
