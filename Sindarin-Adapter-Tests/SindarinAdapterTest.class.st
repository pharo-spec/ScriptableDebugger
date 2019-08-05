Class {
	#name : #SindarinAdapterTest,
	#superclass : #TestCase,
	#instVars : [
		'adapterClasses'
	],
	#category : #'Sindarin-Adapter-Tests'
}

{ #category : #running }
SindarinAdapterTest >> setUp [
	"List all subclasses of SindarinAdapter"
	adapterClasses := OrderedCollection new.
	SindarinAdapter allSubclassesDo: [ :subClass | adapterClasses add: subClass ].
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
SindarinAdapterTest >> testContext [
	self testAllAdapterClassesOnExecution: [ |a| a := Point new. ^ 42 ] testing: [ :adapter |
		adapter context isKindOf: SindarinContext.
	]
]
