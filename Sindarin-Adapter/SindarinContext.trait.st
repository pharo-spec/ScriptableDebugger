Trait {
	#name : #SindarinContext,
	#category : #'Sindarin-Adapter'
}

{ #category : #accessing }
SindarinContext >> method [
	"() -> (SindarinMethod)
	Return the method @self is an invocation of"
	self subclassResponsibility
]

{ #category : #'operand-stack' }
SindarinContext >> operandStackAt: anInteger [
	"index (Integer) -> (Object)
	Return element number @index of the operand stack of @self.
	The operand stack of a context is the stack that is used to store intermediate values during the execution of a method. For example, if the next operation is this assignment: 'a := 2'. The first step is to push 2 on the operand stack, then the assignment itself will pop this value and store it where the value of the 'a' variable is stored."
	self subclassResponsibility
]

{ #category : #'operand-stack' }
SindarinContext >> operandStackPop [
	"() -> (Object)
	Remove the top element of the operand stack of @self. Return this element."
	self subclassResponsibility
]

{ #category : #'operand-stack' }
SindarinContext >> operandStackPush: aValue [
	"value (Object) -> ()
	Push @value on the operand stack of @self."
	self subclassResponsibility
]

{ #category : #accessing }
SindarinContext >> receiver [
	"() -> (Object)
	Returns the receiver of the method invocation @self represents."
	self subclassResponsibility
]

{ #category : #accessing }
SindarinContext >> sender [
	"() -> (SindarinContext)
	Return the context that sent the message that created @self. It is also the context @self will return to when the execution of @self is complete."
	self subclassResponsibility
]

{ #category : #private }
SindarinContext >> subclassResponsibility [
	"This message sets up a framework for the behavior of the class' subclasses.
	Announce that the subclass should have implemented this message."

	SubclassResponsibility signalFor: thisContext sender selector
]

{ #category : #accessing }
SindarinContext >> temporaries [
	"() -> (Dictionary)
	Return a dictionary of the temporaries of @self. This dictionary is of the form: <nameOfTheTemp> (ByteSymbol) -> <valueOfTheTemp> (Object). This dictionary contains the arguments and the variables defined between | | of the method @self is an invocation of. Modifying this dictionary does NOT modify @self, but the value objects are the same as those in @self, so modifying them directly does modify the corresponding temporary values from @self."
	self subclassResponsibility
]
