QKForms
=======

Automatically handles moving text fields and text views out of the way of the keyboard. Also handles expanding text views to fit their text. Device orientation agnostic.

##Usage

Here is a step by step guide to using QKForms using interface builder. The demo these steps refer to is included in QKFormsDemo.

###Step 1
Create a scroll view (or table view, or collection view) and add the `QKFormsScrollView` class to it.

![](https://raw.githubusercontent.com/QuantumKing/QKForms/master/QKFormsDemo/screenshots/step1.png)

###Step 2
If you want a text view which expands and moves out of the way of the keyboard as you type, then add the `QKAutoExpandingTextView` class to your text view.

![](https://raw.githubusercontent.com/QuantumKing/QKForms/master/QKFormsDemo/screenshots/step2.png)

###Step 3
Add any number of text fields, searchbars, all inside another view, whatever!

![](https://raw.githubusercontent.com/QuantumKing/QKForms/master/QKFormsDemo/screenshots/step3.png)

###That's it!
Everything is handled automatically after you've designed your form. Any text view with the class `QKAutoExpandingTextView` will expand as you type:

![](https://raw.githubusercontent.com/QuantumKing/QKForms/master/QKFormsDemo/screenshots/textview.png)

and the class `QKFormsScrollView` handles moving its text fields and text views out of the way of the keyboard. It also handles hiding the keyboard whenever it receives a tap gesture.

![](https://raw.githubusercontent.com/QuantumKing/QKForms/master/QKFormsDemo/screenshots/field5.png)

##Options

Each of `QKFormsScrollView`, `QKFormsTableView` and `QKFormsCollectionView` comes with the following interface:

``` obj-c
// Options, which can be found in the QKFormsOptions class.
@property (nonatomic) QKFormsOptions *options;

// An optional property which will be sent the TouchUpInside event
// when return is pressed while editing the last field in the form.
// The property returnShouldMoveToNextField must be set to YES in order
// to use this.
@property (nonatomic, weak) IBOutlet UIButton *submitButton;

// Navigates to the next field, based on vertical position.
- (IBAction)nextField;

// Navigates to the previous field, based on vertical position.
- (IBAction)previousField;

- (IBAction)dismissKeyboard;
- (void)dismissKeyboardWithCompletion:(void (^)(void))completion;
```

There are a few options that you may set through `QKFormsOptions`:

``` obj-c
// Whether return navigates to the next field or not.
@property (nonatomic, assign) BOOL returnShouldMoveToNextField;

// The margin between the keyboard and the field being edited.
@property (nonatomic, assign) CGFloat keyboardTopMargin;

// Whether the form view displays a shadow when its content overflows.
// In order for this to work, this view must have a superview with the same bounds.
@property (nonatomic, assign) BOOL showsShadow;

// This will force the field to be pulled down towards the keyboard, even
// if it is already above the keyboard.
@property (nonatomic, assign) BOOL shouldFocusFields;
```
QKForms provides a subclass of `UITextView` called `QKAutoExpandingTextView` which handles automatically expanding itself to fit the text its given. It can also have a maximum height set:

``` obj-c
// If maxHeight is a number other than 0, this view will not expand beyond maxHeight.
@property (nonatomic, assign) CGFloat maxHeight;
```
Another useful view called `QKPlaceholderTextView`, which is a subclass of `QKAutoExpandingTextView`, allows for placeholder text to be set on a text view.

##Installation via Cocoapods

Add `pod 'QKForms', '~> 0.0'` to your `Podfile` and run `pod` to install.
