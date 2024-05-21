"
- Start demo
dbg := SindarinDebugger debug: [ SindarinDemo_SkipNextException new start ].

-  Demo Script
[dbg node isMessage and:
	[(dbg messageSelector = #signal:) and:
		[Exception allSubclasses includes: dbg messageReceiver]]]
		whileFalse: [dbg step].
dbg skip.
"
Class {
	#name : 'SindarinDemo_SkipNextException',
	#superclass : 'Object',
	#category : 'Sindarin-Demo',
	#package : 'Sindarin-Demo'
}

{ #category : 'accessing' }
SindarinDemo_SkipNextException >> method1 [
	self halt.
	self method2.
]

{ #category : 'accessing' }
SindarinDemo_SkipNextException >> method2 [
	self method3.
]

{ #category : 'accessing' }
SindarinDemo_SkipNextException >> method3 [
	self method4.
]

{ #category : 'accessing' }
SindarinDemo_SkipNextException >> method4 [
	self method5.
]

{ #category : 'accessing' }
SindarinDemo_SkipNextException >> method5 [
	Error signal: 'Something truly unexpected happened :)'.
	self method6.
]

{ #category : 'accessing' }
SindarinDemo_SkipNextException >> method6 [
	self method7.
]

{ #category : 'accessing' }
SindarinDemo_SkipNextException >> method7 [
	^ 42
]

{ #category : 'accessing' }
SindarinDemo_SkipNextException >> start [
	self method1
]
