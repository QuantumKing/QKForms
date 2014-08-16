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

###Installation via Cocoapods

Add `pod 'QKForms', '~> 0.0'` to your `Podfile` and run `pod` to install.
