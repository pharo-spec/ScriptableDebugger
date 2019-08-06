Class {
	#name : #SindarinAdapterTest,
	#superclass : #TestCase,
	#instVars : [
		'adapterClasses'
	],
	#category : #'Sindarin-Adapter-Tests'
}

{ #category : #tests }
SindarinAdapterTest >> executionBlock1 [
	^ [ |a| a := Point new. ^ 42 ]
]

{ #category : #tests }
SindarinAdapterTest >> executionBlock2 [
	^ [ |a| a := Point new. ^ 42 ]
]

{ #category : #tests }
SindarinAdapterTest >> executionBlock3 [
	^ [ |a| a := Point new. ^ 42 ]
]

{ #category : #tests }
SindarinAdapterTest >> executionBlock4 [
	^ [ Point new ]
]

{ #category : #running }
SindarinAdapterTest >> setUp [
	"List all subclasses of SindarinAdapter"
	adapterClasses := OrderedCollection new.
	SindarinAdapter allSubclassesDo: [ :subClass | adapterClasses add: subClass ].
]

{ #category : #'as yet unclassified' }
SindarinAdapterTest >> stepAdapterUntilOnDifferentNode: anAdapter [
	| originNode |
	originNode := anAdapter context node.
	[anAdapter context node = originNode] whileTrue: [ anAdapter step ]
]

{ #category : #tests }
SindarinAdapterTest >> testAllAdapterClassesOnExecution: executionBlock testing: testBlock [
	"Lists all concrete subclasses of SindarinAdapter.
	For each, instanciate them (with #debug:) on an execution of @executionBlock, and evaluate @testBlock on the instance. Also checks that the instance is indeed an instance of the subclass.
	If there are no concrete subclass, skip this test."
	| adapter |
	adapterClasses ifEmpty: [ self skip: 'No concrete subclass of SindarinAdapter to test' ].
	adapterClasses do: [:concreteSubclass | adapter := concreteSubclass debug: executionBlock. self assert: (adapter isKindOf: concreteSubclass). testBlock value: adapter. ].
]

{ #category : #tests }
SindarinAdapterTest >> testContextChangesWhenSteppingOnAMessageSendNode [
	| originContext |
	self testAllAdapterClassesOnExecution: (self executionBlock4) testing: [ :adapter |
		originContext := adapter context.
		self assert: (adapter context node isKindOf: RBVariableNode). "Execution is about to push Point on the operand stack"
		adapter step.
		self assert: (adapter context node isKindOf: RBMessageNode). "Execution is about to send #new to Point"
		adapter step.
		self assert: adapter context ~= originContext.
	]
]

{ #category : #tests }
SindarinAdapterTest >> testContextNode [

	| executedBlockAST |
	executedBlockAST := (self class >> #executionBlock3) ast body children first children first.
	self testAllAdapterClassesOnExecution: (self executionBlock3) testing: [ :adapter |
		self assert: (adapter context node) equals: executedBlockAST.
	]
]

{ #category : #tests }
SindarinAdapterTest >> testMethodAST [
	| executedMethodAST |
	executedMethodAST := (self class >> #executionBlock1) ast.
	self testAllAdapterClassesOnExecution: (self executionBlock1) testing: [ :adapter |
		self assert: (adapter context method ast) equals: executedMethodAST.
	]
]
