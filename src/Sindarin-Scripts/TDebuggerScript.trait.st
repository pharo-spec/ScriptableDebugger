Trait {
	#name : 'TDebuggerScript',
	#category : 'Sindarin-Scripts-core',
	#package : 'Sindarin-Scripts',
	#tag : 'core'
}

{ #category : 'executing' }
TDebuggerScript classSide >> defaultArguments [
	^OrderedCollection new
]

{ #category : 'executing' }
TDebuggerScript classSide >> defaultHooks [
	^OrderedCollection new
]

{ #category : 'executing' }
TDebuggerScript classSide >> defaultPredicates [
	^OrderedCollection new
]

{ #category : 'executing' }
TDebuggerScript >> arguments [ 
	^self class defaultArguments
]

{ #category : 'executing' }
TDebuggerScript >> execute [

	<debuggerCompleteToSender>
	^ SindarinPointcutException signalWith: self
]

{ #category : 'executing' }
TDebuggerScript >> executeWith: aDebugger [
	^self
]

{ #category : 'executing' }
TDebuggerScript >> hooks [
	^self class defaultHooks 
]

{ #category : 'executing' }
TDebuggerScript >> predicates [ 
	^self class defaultPredicates 
]

{ #category : 'executing' }
TDebuggerScript >> shouldExecute [
	^self predicates allSatisfy: [ :p| p evaluate ]
]
