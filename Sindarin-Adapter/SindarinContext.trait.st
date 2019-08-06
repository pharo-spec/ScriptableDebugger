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

{ #category : #accessing }
SindarinContext >> node [
	"() -> (RBProgramNode)
	Return the ast node that this context is about to execute"
	self subclassResponsibility
]

{ #category : #'operand-stack' }
SindarinContext >> operandStackAt: anInteger [
	"index (Integer) -> (Object)
	Return element number @index of the operand stack of @self. Elements are counted from the bottom (number 1) to the top of the stack (last number).
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
	"value (Object) -> (Object)
	Push @value on the operand stack of @self.
	Return @value."
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
SindarinContext >> temporaryNamed: temporaryName [
	"temporaryName (Symbol) -> (Object)
	Return the value of the temporary (argument + temporary variable) named @temporaryName of @self if it has one. If no temporary has this name, return nil. If the returned object is modified, these modifications must impact the value of the temporary in the execution."
	self subclassResponsibility
]

{ #category : #accessing }
SindarinContext >> temporaryNamed: temporaryName put: newValue [
	"temporaryName (Symbol) -> newValue (Object) -> ()
	Change the value of the temporary named @temporaryName of @self into @newValue. If @self does not have this temporary, do nothing."
	self subclassResponsibility
]

{ #category : #accessing }
SindarinContext >> temporaryNames [
	"() -> (OrderedCollection<Symbol>)
	Return a list containing the names of all the temporaries of @self (arguments + temporary variables)."
	self subclassResponsibility.
]
