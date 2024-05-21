Extension { #name : 'RBProgramNode' }

{ #category : '*Sindarin' }
RBProgramNode >> allChildrenPostOrder [

	| children |
	children := OrderedCollection new.
	self children do: [ :each | 
		each allChildrenPostOrder do: [ :child | children addLast: child ] ].
	children addLast: self.
	^ children
]

{ #category : '*Sindarin' }
RBProgramNode >> skipWithDebugger: aSindarinDebugger [

	aSindarinDebugger step
]
