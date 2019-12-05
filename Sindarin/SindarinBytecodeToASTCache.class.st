"
I cache a mapping between possible bytecode offsets and the AST nodes they correspond to for a given compiled method.

Instanciate me using my class method generateForCompiledMethod: and give me as parameter a compiled method.

Use me through the node access API method nodeForPC: and give me a program counter as parameter.

I store: 
- firstBcOffset: The first bytecode pc. If you try to access a pc below that first pc, I return the method node.
- lastBcOffset: The last bytecode pc. If you try to access a pc after this last pc, I return the node associated with the last pc.
- bcToASTMap: A map associating each possible pc between firstBcOffset and lastBcOffset and the corresponding ast node.
- the methode node.
"
Class {
	#name : #SindarinBytecodeToASTCache,
	#superclass : #Object,
	#instVars : [
		'firstBcOffset',
		'lastBcOffset',
		'bcToASTMap',
		'methodNode'
	],
	#category : #Sindarin
}

{ #category : #initialization }
SindarinBytecodeToASTCache class >> generateForCompiledMethod: compiledMethod [
	^self new generateForCompiledMethod: compiledMethod
]

{ #category : #accessing }
SindarinBytecodeToASTCache >> bcToASTMap [
	^ bcToASTMap
]

{ #category : #accessing }
SindarinBytecodeToASTCache >> firstBcOffset [
	^ firstBcOffset
]

{ #category : #initialization }
SindarinBytecodeToASTCache >> generateForCompiledMethod: compiledMethod [
	| methodIR currentBcOffset |
	methodNode := compiledMethod ast.
	methodIR := methodNode ir.
	bcToASTMap := Dictionary new.
	firstBcOffset := methodIR startSequence withAllSuccessors first first
		                 bytecodeOffset.
	currentBcOffset := firstBcOffset.
	methodIR startSequence withAllSuccessors do: [ :seq | 
		seq do: [ :ir | 
			ir ifNotNil: [ 
				currentBcOffset to: ir bytecodeOffset do: [ :i | 
				bcToASTMap at: i put: ir sourceNode ].
				currentBcOffset := ir bytecodeOffset + 1 ] ] ].
	lastBcOffset := currentBcOffset - 1
]

{ #category : #accessing }
SindarinBytecodeToASTCache >> lastBcOffset [
	^ lastBcOffset
]

{ #category : #accessing }
SindarinBytecodeToASTCache >> methodNode [
	^ methodNode
]

{ #category : #'node access' }
SindarinBytecodeToASTCache >> nodeForPC: pc [
	pc < firstBcOffset ifTrue: [ ^ methodNode ].
	pc > lastBcOffset ifTrue: [ ^ bcToASTMap at: lastBcOffset ].
	^ bcToASTMap at: pc
]
