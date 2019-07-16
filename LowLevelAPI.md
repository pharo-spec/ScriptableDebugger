Legend:
<Class>>>#<selector>
	<nameOfArgument1> (<typeOfArgument1>) -> <nameOfArgument2> (<typeOfArgument2>) ... -> <nameOfArgumentN> (<typeOfArgumentN>) -> (<typeOfReturnValue>)
	<Description>

Legend for methods with no arguments:
<Class>>>#<selector>
	() -> (<typeOfReturnValue>)
	<Description>

If a method returns nothing (i.e. it automatically return its receiver in pharo), the type of its return value is denoted ().

In the descriptions, an @ prefixes the names of the method arguments and "self". @self refers to the receiver of the method. 

Method>>#sourceNodeForPC:
	programCounter (Integer) -> (RBProgramNode)
	Among @self's AST nodes, return the one corresponding to @programCounter.
Method>>#selector
	() -> (ByteSymbol)
	Return the selector of @self (the name of the method).
Method>>#sourceCode
	() -> (ByteString)
	Return the source code of @self.



Context>>#arguments
	() -> (Array)
	Return the value of the arguments of the method invocation @self represents. If the method does not take arguments, return an empty array.
Context>>#operandStackAt:
	ADDED with the removal of #at:
	index (Integer) -> (Object)
	Return element number @index of the operand stack of @self.
	The operand stack of a context is the stack that is used to store intermediate values during the execution of a method. For example, if the next operation is this assignment: "a := 2". The first step is to push 2 on the operand stack, then the assignment itself will pop this value and store it where the value of the "a" variable is stored.
%Context>>#basicSize
	REMOVED with the removal of #at:
Context>>#hasSender:
	context (Context) -> (Boolean)
	Return whether @context is the sender of @self, or the sender of the sender of @self, or the sender of the sender of the sender of @self, or...
Context>>#method
	() -> (Method)
	Return the method @self is an invocation of
Context>>#pc
	() -> (SmallInteger)
	Return the program counter of @self
Context>>#pc:
	anInteger (Integer) -> ()
	Sets the program counter of @self
%Context>>#pop
	REMOVED with the removal of #at:
Context>>#operandStackPop
	ADDED with the removal of #at:
	() -> (Object)
	Remove the top element of the operand stack of @self. Return this element.
%Context>>#push:
	REMOVED with the removal of #at:
Context>>#operandStackPush:
	ADDED with the removal of #at:
	value (Object) -> ()
	Push @value on the operand stack of @self.
Context>>#receiver
	() -> (Object)
	Returns the receiver of the method invocation @self represents.
Context>>#selector
	() -> (ByteSymbol)
	Return the selector of the method @self is an invocation of.
Context>>#sender
	() -> (Context)
	Return the context that sent the message that created @self. It is also the context @self will return to when the execution of @self is complete.
Context>>#temporaries
	() -> (Dictionary)
	Return a dictionary of the temporaries of @self. This dictionary is of the form: <nameOfTheTemp> (ByteSymbol) -> <valueOfTheTemp> (Object). This dictionary contains the arguments and the variables defined between | | of the method @self is an invocation of. Modifying this dictionary does NOT modify @self, but the value objects are the same as those in @self, so modifying them directly does modify the corresponding temporary values from @self.

DebugSession>>#interruptedContext
	() -> (Context)
	Return the top context of the context stack i.e. the context where the debugged execution is at.
DebugSession>>#stack
	() -> (OrderedCollection)
	Return the context stack as an ordered collection. The first context is the top context i.e. the context where the debugged execution is at.
DebugSession>>#stepInto
	() -> ()
	Steps the execution once. This is the smaller step the debugged execution can make.
DebugSession>>#stepToFirstInterestingBytecodeIn:
	aProcess (Process) -> (Context)
	Keep stepping the debugged execution until it is about to either: - send a message, - return, - perform an assignment or create a block.
	Return the context reached.
DebugSession>>#isProcessTerminating
	() -> (Boolean)
	Return whether the debugged execution is finished.

RBMessageNode>>#arguments
	() -> (OrderedCollection)
	Return a colection containing instances of RBArgumentNode corresponding to the arguments of @self.
RBMessageNode>>#selector
	() -> (ByteSymbol)
	Return the selector of the message-send @self represents.
RBProgramNode>>#isAssignment
	() -> (Boolean)
	Return whether @self is an AST node representing an assignment (typically an RBAssignmentNode)
RBProgramNode>>#isMessage
	() -> (Boolean)
	Return whether @self is an AST node representing a message send (typically an RBMessageNode)
RBAssignmentNode>>#variable
	() -> (RBVariableNode)
	Return the AST node representing the variable of which @self represent an assignment to.
RBVariableNode>>#name
	() -> (ByteSymbol)
	Return the name of the variable @self represents