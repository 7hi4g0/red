Red/System [
	Title:	"Windows classes handling"
	Author: "Qingtian Xie"
	File: 	%classes.reds
	Tabs: 	4
	Rights: "Copyright (C) 2016 Qingtian Xie. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

#include %delegates.reds
#include %camera.reds

add-method!: alias function! [class [integer!]]

add-base-handler: func [class [integer!]][
	flipp-coord class
	class_addMethod class sel_getUid "drawRect:" as-integer :draw-rect "v@:{_NSRect=ffff}"
	class_addMethod class sel_getUid "red-menu-action:" as-integer :red-menu-action "v@:@"
	class_replaceMethod class sel_getUid "mouseDown:" as-integer :base-mouse-down "v@:@"
	class_replaceMethod class sel_getUid "mouseUp:" as-integer :base-mouse-up "v@:@"
	class_replaceMethod class sel_getUid "mouseDragged:" as-integer :base-mouse-drag "v@:@"
]

win-add-subview: func [
	[cdecl]
	self	[integer!]
	cmd		[integer!]
	view	[integer!]
][
	objc_msgSend [
		objc_msgSend [self sel_getUid "contentView"]
		sel_getUid "addSubview:" view
	]
]

win-convert-point: func [
	[cdecl]
	self	[integer!]
	cmd		[integer!]
	x		[integer!]
	y		[integer!]
	view	[integer!]
	/local
		rc	[NSRect!]
][
	x: objc_msgSend [
		objc_msgSend [self sel_getUid "contentView"]
		sel_getUid "convertPoint:fromView:" x y view
	]
	y: system/cpu/edx
	rc: as NSRect! :x
	system/cpu/edx: y
	system/cpu/eax: x
]

add-window-handler: func [class [integer!]][
	class_addMethod class sel_getUid "windowWillClose:" as-integer :win-will-close "v12@0:4@8"
	class_addMethod class sel_getUid "windowDidMove:" as-integer :win-did-move "v12@0:4@8"
	class_addMethod class sel_getUid "windowDidResize:" as-integer :win-did-resize "v12@0:4@8"
	class_addMethod class sel_getUid "windowDidEndLiveResize:" as-integer :win-live-resize "v12@0:4@8"
	;class_addMethod class sel_getUid "windowWillResize:toSize:" as-integer :win-will-resize "{_NSSize=ff}20@0:4@8{_NSSize=ff}12"
	class_addMethod class sel_getUid "red-menu-action:" as-integer :red-menu-action "v@:@"
	class_addMethod class sel_getUid "addSubview:" as-integer :win-add-subview "v12@0:4@8"
	class_addMethod class sel_getUid "convertPoint:fromView:" as-integer :win-convert-point "{_NSPoint=ff}20@0:4{_NSPoint=ff}8@16"
]

add-button-handler: func [class [integer!]][
	class_replaceMethod class sel_getUid "mouseDown:" as-integer :button-mouse-down "v@:@"
]

add-slider-handler: func [class [integer!]][
	class_addMethod class sel_getUid "slider-change:" as-integer :slider-change "v@:@"
]

add-text-field-handler: func [class [integer!]][
	class_addMethod class sel_getUid "textDidChange:" as-integer :text-did-change "v@:@"
	class_addMethod class sel_getUid "textDidEndEditing:" as-integer :text-did-end-editing "v@:@"
	class_addMethod class sel_getUid "becomeFirstResponder" as-integer :get-focus "B@:"
]

add-area-handler: func [class [integer!]][
	class_addMethod class sel_getUid "textDidChange:" as-integer :area-text-change "v@:@"
]

add-combo-box-handler: func [class [integer!]][
	class_addMethod class sel_getUid "textDidChange:" as-integer :text-did-change "v@:@"
	class_addMethod class sel_getUid "comboBoxSelectionDidChange:" as-integer :selection-change "v@:@"
]

add-table-view-handler: func [class [integer!]][
	class_addMethod class sel_getUid "numberOfRowsInTableView:" as-integer :number-of-rows "l@:@"
	class_addMethod class sel_getUid "tableView:objectValueForTableColumn:row:" as-integer :object-for-table "@20@0:4@8@12l16"
	class_addMethod class sel_getUid "tableViewSelectionDidChange:" as-integer :table-select-did-change "v@:@"
	class_addMethod class sel_getUid "tableView:shouldEditTableColumn:row:" as-integer :table-cell-edit "B@:@@l"
]

add-camera-handler: func [class [integer!]][
	0
]

add-tabview-handler: func [class [integer!]][
	class_addMethod class sel_getUid "tabView:willSelectTabViewItem:" as-integer :tabview-will-select "v16@0:4@8@12"
]

add-app-delegate: func [class [integer!]][
	class_addMethod class sel_getUid "applicationWillFinishLaunching:" as-integer :will-finish "v12@0:4@8"
	class_addMethod class sel_getUid "applicationShouldTerminateAfterLastWindowClosed:" as-integer :destroy-app "B12@0:4@8"
]

flipp-coord: func [class [integer!]][
	class_addMethod class sel_getUid "isFlipped" as-integer :is-flipped "B@:"
]

make-super-class: func [
	new		[c-string!]
	base	[c-string!]
	method	[integer!]				;-- override functions or add functions
	store?	[logic!]
	return:	[integer!]
	/local
		new-class	[integer!]
		add-method	[add-method!]
][
	new-class: objc_allocateClassPair objc_getClass base new 0
	if store? [						;-- add an instance value to store red-object!
		class_addIvar new-class IVAR_RED_FACE 16 2 "{red-face=iiii}"
		class_addMethod new-class sel-on-timer as-integer :red-timer-action "v@:@"
		class_addMethod new-class sel_getUid "mouseEntered:" as-integer :mouse-entered "v@:@"
		class_addMethod new-class sel_getUid "mouseExited:" as-integer :mouse-exited "v@:@"
		class_addMethod new-class sel_getUid "mouseMoved:" as-integer :mouse-moved "v@:@"
		class_addMethod new-class sel_getUid "mouseDown:" as-integer :mouse-down "v@:@"
		class_addMethod new-class sel_getUid "mouseUp:" as-integer :mouse-up "v@:@"
		class_addMethod new-class sel_getUid "mouseDragged:" as-integer :mouse-drag "v@:@"

		class_addMethod new-class sel_getUid "keyDown:" as-integer :on-key-down "v@:@"
		class_addMethod new-class sel_getUid "keyUp:" as-integer :on-key-up "v@:@"
	]
	unless zero? method [
		add-method: as add-method! method
		add-method new-class
	]
	objc_registerClassPair new-class
]

register-classes: does [
	make-super-class "RedAppDelegate"	"NSObject"				as-integer :add-app-delegate	no
	make-super-class "RedView"			"NSView"				as-integer :flipp-coord			no
	make-super-class "RedBase"			"NSView"				as-integer :add-base-handler	yes
	make-super-class "RedWindow"		"NSWindow"				as-integer :add-window-handler	yes
	make-super-class "RedButton"		"NSButton"				as-integer :add-button-handler	yes
	make-super-class "RedSlider"		"NSSlider"				as-integer :add-slider-handler	yes
	make-super-class "RedProgress"		"NSProgressIndicator"	0	yes
	make-super-class "RedTextField"		"NSTextField"			as-integer :add-text-field-handler yes
	make-super-class "RedTextView"		"NSTextView"			as-integer :add-area-handler yes
	make-super-class "RedComboBox"		"NSComboBox"			as-integer :add-combo-box-handler yes
	make-super-class "RedTableView"		"NSTableView"			as-integer :add-table-view-handler yes
	make-super-class "RedCamera"		"NSView"				as-integer :add-camera-handler yes
	make-super-class "RedTabView"		"NSTabView"				as-integer :add-tabview-handler yes
	make-super-class "RedScrollView"	"NSScrollView"			0	yes
	make-super-class "RedBox"			"NSBox"					0	yes
]
