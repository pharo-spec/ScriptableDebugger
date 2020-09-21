# Sindarin Interpreter API: API that needs to be provided to Sindarin by the execution model

Method template:

+ *{class}*>>#*{methodName}*  
	+ (*{inputType}*) -> (*{outputType}*)  
	+ *{Description of the method}*



- () stands for the unit type.  
- Some arguments are named. These names are placed before the type of the argument. Example: "value (Object) -> ()".  
- When a description refers to a named argument, the name is prefixed with @. Example: "Multiply @value by 2".
- @self is used in descriptions to refer to the object having the method being described.
- // indicate comments. Scrapped pieces of text that may come in helpful later or explain why a particular method was removed.


## Sindarin Adapter

+ SindarinAdapter class>>#debug:  
	+ (BlockClosure) -> (SindarinAdapter)
	+ Initialise @self (newly created instance) to be a debug session on the execution of the provided block closure. Return @self. Note that using a BlockClosure referencing elements that are not accessible globally (like self, variables...) will prevent the DASTInterpreter from running it properly (because it converts the BlockClosure into source code and parse it to get the AST nodes it actually executes)
+ SindarinAdapter>>#context
	+ () -> (SindarinContext)
	+ Current context of the execution
+ SindarinAdapter>>#step
	+ () -> ()
	+ Steps the execution once. This is the smallest step the debugged execution can make.
	This must signal an exception if the execution signalled an exception that it did not handle. The former exception must contain the latter. TODO: need more detail as to which exception exactly is to be signalled.
+ SindarinAdapter>>#isTerminated
	+ () -> (Boolean)
	+ Returns whether the debuged execution is finished.
+ SindarinAdapter>>#skipNodeWith:
	+ value (Object) -> ()
	+ Skip the execution of the current node of the current context. If it should have returned a value, put @value on the operand stack.

## SindarinContext

+ SindarinContext>>#method
	+ () -> (SindarinMethod)
	+ Return the method @self is an invocation of
+ SindarinContext>>#node
	+ () -> (RBProgramNode)
	+ Return the ast node that this context is about to execute
+ SindarinContext>>#operandStackAt:
	+ index (Integer) -> (Object)
	+ Return element number @index of the operand stack of @self. Elements are counted from the bottom (number 1) to the top of the stack (last number).
	The operand stack of a context is the stack that is used to store intermediate values during the execution of a method. For example, if the next operation is this assignment: 'a := 2'. The first step is to push 2 on the operand stack, then the assignment itself will pop this value and store it where the value of the 'a' variable is stored.
+ SindarinContext>>#operandStackPop
	+ () -> (Object)
	+ Remove the top element of the operand stack of @self. Return this element.
+ SindarinContext>>#operandStackPush:
	+ value (Object) -> (Object)
	+ Push @value on the operand stack of @self.
	Return @value.
+ SindarinContext>>#receiver
	+ () -> (Object)
	+ Returns the receiver of the method invocation @self represents.
+ SindarinContext>>#sender
	+ () -> (SindarinContext)
	+ Return the context that sent the message that created @self. It is also the context @self will return to when the execution of @self is complete.
+ //SindarinContext>>#temporaries
	+ //() -> (Dictionary)
	+ // Return a dictionary of the temporaries of @self. This dictionary is of the form: <nameOfTheTemp> (ByteSymbol) -> <valueOfTheTemp> (Object). This dictionary contains the arguments and the variables defined between | | of the method @self is an invocation of. Modifying this dictionary does NOT modify @self, but the value objects are the same as those in @self, so modifying them directly does modify the corresponding temporary values from @self.  
	// Replaced with #temporaryNames, #temporaryNamed: and #temporaryNamed:put: to avoid forcing execution model that do not have such a dictionary to make one whose content syncs with their own internal storage for temp values.
+ SindarinContext>>#temporaryNames
	+ () -> (OrderedCollection<Symbol>)
	+ Return a list containing the names of all the temporaries of @self (arguments + temporary variables).
+ SindarinContext>>#temporaryNamed:
	+ temporaryName (Symbol) -> (Object)
	+ Return the value of the temporary (argument + temporary variable) named @temporaryName of @self if it has one. If no temporary has this name, return nil. If the returned object is modified, these modifications must impact the value of the temporary in the execution.
+ SindarinContext>>#temporaryNamed:put:
	+ temporaryName (Symbol) -> newValue (Object) -> ()
	+ Change the value of the temporary named @temporaryName of @self into @newValue. If @self does not have this temporary, do nothing.

## SindarinMethod

+ SindarinMethod>>#selector
	+ () -> (ByteSymbol)
	+ Return the selector of @self (the name of the method).
+ SindarinMethod>>#sourceCode
	+ () -> (ByteString)
	+ Return the source code of @self.
+ SindarinMethod>>#ast
	+ () -> (RBProgramNode)
	+ Return the root ast node of @self
+ //SindarinMethod>>#astNodeForPC:
	+ //(Integer) -> (RBProgramNode)
	+ // Do not use pc, instead ask for a skipNode operation to be implemented. Because DAST doesn't really have a pc, and it works differently from Bytecode's pc anyway.

## The RBProgramNode hierarchy

The one from pharo
