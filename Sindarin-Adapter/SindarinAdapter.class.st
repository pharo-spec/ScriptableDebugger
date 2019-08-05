Class {
	#name : #SindarinAdapter,
	#superclass : #Object,
	#category : #'Sindarin-Adapter'
}

{ #category : #start }
SindarinAdapter class >> debug: aBlock [
	^ self new debug: aBlock
]

{ #category : #accessing }
SindarinAdapter >> context [
	"() -> (SindarinContext)
	Current context of the execution"
	self subclassResponsibility.
]

{ #category : #start }
SindarinAdapter >> debug: aBlock [
	"(BlockClosure) -> (DebugSession)
	Initialise self (newly created instance) to be a debug session on the execution of the provided block closure. Return self."
	self subclassResponsibility
]

{ #category : #accessing }
SindarinAdapter >> isTerminated [
	"() -> (Boolean)
	Returns whether the debuged execution is finished."
	self subclassResponsibility
]

{ #category : #stepping }
SindarinAdapter >> skipNodeWith: aValue [
	"value (Object) -> ()
	Skip the execution of the current node of the current context. If it should have returned a value, put @value on the operand stack."
	self subclassResponsibility.
]

{ #category : #stepping }
SindarinAdapter >> step [
	"() -> ()
	Steps the execution once. This is the smallest step the debugged execution can make.
	This must signal an exception if the execution signalled an exception that it did not handle. The former exception must contain the latter."
	self subclassResponsibility
]
