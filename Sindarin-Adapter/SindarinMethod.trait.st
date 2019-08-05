Trait {
	#name : #SindarinMethod,
	#category : #'Sindarin-Adapter'
}

{ #category : #accessing }
SindarinMethod >> ast [
	"() -> (RBProgramNode)
	Return the root ast node of @self"
	self subclassResponsibility
]

{ #category : #accessing }
SindarinMethod >> selector [
	"() -> (ByteSymbol)
	Return the selector of @self (the name of the method)."
	self subclassResponsibility
]

{ #category : #accessing }
SindarinMethod >> sourceCode [
	"() -> (ByteString)
	Return the source code of @self."
	self subclassResponsibility
]

{ #category : #private }
SindarinMethod >> subclassResponsibility [
	"This message sets up a framework for the behavior of the class' subclasses.
	Announce that the subclass should have implemented this message."

	SubclassResponsibility signalFor: thisContext sender selector
]
