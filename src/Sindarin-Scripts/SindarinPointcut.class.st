Class {
	#name : 'SindarinPointcut',
	#superclass : 'Object',
	#instVars : [
		'ast',
		'metalink'
	],
	#classVars : [
		'Pointcuts'
	],
	#category : 'Sindarin-Scripts-core',
	#package : 'Sindarin-Scripts',
	#tag : 'core'
}

{ #category : 'adding' }
SindarinPointcut class >> addPointcut: aSindarinPointcut [
	self pointcuts add: aSindarinPointcut
]

{ #category : 'accessing' }
SindarinPointcut class >> pointcuts [

	^ Pointcuts ifNil: [ Pointcuts := Set new ]
]

{ #category : 'adding' }
SindarinPointcut class >> removePointcut: aSindarinPointcut [
	aSindarinPointcut uninstall.
	self pointcuts remove: aSindarinPointcut
]

{ #category : 'accessing' }
SindarinPointcut class >> target: anAst [

	^ self new
		  ast: anAst;
		  install
]

{ #category : 'accessing' }
SindarinPointcut >> ast: anObject [
	ast := anObject
]

{ #category : 'actions' }
SindarinPointcut >> install [
	self class addPointcut: self.
	ast link: self link
]

{ #category : 'building' }
SindarinPointcut >> link [
	metalink ifNotNil: [ metalink uninstall ].
	metalink := MetaLink new.
	metalink control: #before.
	metalink metaObject: SindarinPointcutException.
	metalink selector: #debug.
	^metalink
]

{ #category : 'installing' }
SindarinPointcut >> uninstall [
	metalink uninstall
]
