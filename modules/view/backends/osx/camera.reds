Red/System [
	Title:	"macOS Camera widget"
	Author: "Xie Qingtian"
	File: 	%camera.reds
	Tabs: 	4
	Notes:  {
		For 10.9+, use AVFoundation, iOS would also use it.
		For 10.0 ~ 10.8, use QTKit.
	}
	References: {
		https://developer.apple.com/library/ios/samplecode/AVCam/Listings/AVCam_AAPLCameraViewController_m.html#//apple_ref/doc/uid/DTS40010112-AVCam_AAPLCameraViewController_m-DontLinkElementID_6
		https://opensource.apple.com/source/libclosure/libclosure-38/BlockImplementation.txt
	}
	Rights: "Copyright (C) 2016 Qingtian Xie. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

RedCameraSessionKey:	4000FFF0h
RedCameraDevicesKey:	4000FFF1h
RedCameraDevInputKey:	4000FFF2h
RedCameraImageKey:		4000FFF3h

AVMediaTypeVideo:		0
AVVideoCodecKey:		0
AVVideoCodecJPEG:		0

init-camera: func [
	camera	[integer!]
	rc		[NSRect!]
	data	[red-block!]
	/local
		devices	[integer!]
		session	[integer!]
		preview	[integer!]
		layer	[integer!]
		av-lib	[integer!]
		p-int	[int-ptr!]
		n		[integer!]
		cnt		[integer!]
		dev		[integer!]
		name	[integer!]
		size	[integer!]
		str		[red-string!]
		cstr	[c-string!]
		img-out [integer!]
		setting [integer!]
][
	rc/x: as float32! 0.0
	rc/y: as float32! 0.0
	if zero? AVMediaTypeVideo [
		av-lib: red/platform/dlopen "/System/Library/Frameworks/AVFoundation.framework/Versions/Current/AVFoundation" RTLD_LAZY
		p-int: red/platform/dlsym av-lib "AVMediaTypeVideo"
		AVMediaTypeVideo: p-int/value
		p-int: red/platform/dlsym av-lib "AVVideoCodecKey"
		AVVideoCodecKey: p-int/value
		p-int: red/platform/dlsym av-lib "AVVideoCodecJPEG"
		AVVideoCodecJPEG: p-int/value
	]

	;-- get all devices name
	devices: objc_msgSend [objc_getClass "AVCaptureDevice" sel_getUid "devicesWithMediaType:" AVMediaTypeVideo]
	cnt: objc_msgSend [devices sel_getUid "count"]
	if TYPE_OF(data) <> TYPE_BLOCK [
		block/make-at data cnt
	]
	n: 0
	while [n < cnt] [
		dev: objc_msgSend [devices sel_getUid "objectAtIndex:" n]
		name: objc_msgSend [dev sel_getUid "localizedName"]
		size: objc_msgSend [name sel_getUid "lengthOfBytesUsingEncoding:" NSUTF8StringEncoding]
		cstr: as c-string! objc_msgSend [name sel_getUid "UTF8String"]
		str: string/make-at ALLOC_TAIL(data) size Latin1
		unicode/load-utf8-stream cstr size str null
		n: n + 1
	]

	session: objc_msgSend [objc_getClass "AVCaptureSession" sel_getUid "alloc"]
	session: objc_msgSend [session sel_getUid "init"]

	objc_msgSend [session sel_getUid "beginConfiguration"]
	img-out: objc_msgSend [objc_getClass "AVCaptureStillImageOutput" sel_getUid "alloc"]
	img-out: objc_msgSend [img-out sel_getUid "init"]
	setting: objc_msgSend [objc_getClass "NSDictionary" sel_getUid "alloc"]
	setting: objc_msgSend [setting sel_getUid "initWithObjectsAndKeys:" AVVideoCodecJPEG AVVideoCodecKey 0]
	objc_msgSend [img-out sel_getUid "setOutputSettings:" setting]
	objc_msgSend [session sel_getUid "addOutput:" img-out]
	objc_msgSend [session sel_getUid "commitConfiguration"]

	objc_setAssociatedObject camera RedCameraSessionKey session OBJC_ASSOCIATION_ASSIGN
	objc_setAssociatedObject camera RedCameraDevicesKey devices OBJC_ASSOCIATION_RETAIN
	objc_setAssociatedObject camera RedCameraImageKey   img-out OBJC_ASSOCIATION_ASSIGN

	preview: objc_msgSend [objc_getClass "AVCaptureVideoPreviewLayer" sel_getUid "layerWithSession:" session]
	objc_msgSend [preview sel_getUid "setFrame:" rc/x rc/y rc/w rc/h]
	layer: objc_msgSend [camera sel_getUid "setWantsLayer:" yes]
	layer: objc_msgSend [camera sel_getUid "layer"]
	objc_msgSend [layer sel_getUid "addSublayer:" preview]
]

select-camera: func [
	camera		[integer!]
	idx			[integer!]
	/local
		session [integer!]
		devices [integer!]
		dev		[integer!]
		dev-in	[integer!]
		cur-dev	[integer!]
][
	session: objc_getAssociatedObject camera RedCameraSessionKey
	devices: objc_getAssociatedObject camera RedCameraDevicesKey
	cur-dev: objc_getAssociatedObject camera RedCameraDevInputKey		;-- current device input

	dev: objc_msgSend [devices sel_getUid "objectAtIndex:" idx]
	dev-in: objc_msgSend [objc_getClass "AVCaptureDeviceInput" sel_getUid "deviceInputWithDevice:error:" dev 0]
	if zero? dev-in [exit]

	objc_msgSend [session sel_getUid "beginConfiguration"]
	if cur-dev <> 0 [
		objc_msgSend [session sel_getUid "removeInput:" cur-dev]
		objc_setAssociatedObject camera RedCameraDevInputKey 0 OBJC_ASSOCIATION_ASSIGN
	]
	objc_msgSend [session sel_getUid "addInput:" dev-in]
	objc_setAssociatedObject camera RedCameraDevInputKey dev-in OBJC_ASSOCIATION_ASSIGN
	objc_msgSend [session sel_getUid "commitConfiguration"]
]

toggle-preview: func [
	camera		[integer!]
	enable?		[logic!]
	/local
		session [integer!]
][
	session: objc_getAssociatedObject camera RedCameraSessionKey
	either enable? [
		objc_msgSend [session sel_getUid "startRunning"]
	][
		objc_msgSend [session sel_getUid "stopRunning"]
	]
]

still-image-handler: func [
	[cdecl]
	block	[int-ptr!]
	buffer	[integer!]
	error	[integer!]
	/local
		values	[red-value!]
		data	[integer!]
][
	values: as red-value! block/6
	data: objc_msgSend [
		objc_getClass "AVCaptureStillImageOutput"
		sel_getUid "jpegStillImageNSDataRepresentation:"
		buffer
	]
	image/init-image
		as red-image! values + FACE_OBJ_IMAGE
		OS-image/load-nsdata data no
]

snap-camera: func [				;-- capture an image of current preview window
	camera		[integer!]
	/local
		values		[integer!]
		descriptor	[integer!]
		invoke		[integer!]
		reserved	[integer!]
		flags		[integer!]
		isa			[integer!]
		image		[integer!]
		connection	[integer!]
		layer		[integer!]
		orientation [integer!]
][
	objc_block_descriptor/reserved: 0
	objc_block_descriptor/size: 4 * 6

	isa: &_NSConcreteStackBlock
	flags: 1 << 29				;-- BLOCK_HAS_DESCRIPTOR, no copy and dispose helpers
	reserved: 0
	invoke: as-integer :still-image-handler
	descriptor: as-integer objc_block_descriptor
	values: as-integer get-face-values camera
	image: objc_getAssociatedObject camera RedCameraImageKey
	connection: objc_msgSend [image sel_getUid "connectionWithMediaType:" AVMediaTypeVideo]

	;-- Update the orientation on the still image output video connection before capturing
	;layer: objc_msgSend [camera sel_getUid "layer"]
	;orientation: objc_msgSend [layer sel_getUid "connection"]
	;orientation: objc_msgSend [orientation sel_getUid "videoOrientation"]
	;objc_msgSend [connection sel_getUid "setVideoOrientation:" orientation]

	objc_msgSend [
		image
		sel_getUid "captureStillImageAsynchronouslyFromConnection:completionHandler:"
		connection
		:isa
	]
]