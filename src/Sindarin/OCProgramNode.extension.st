Extension { #name : 'OCProgramNode' }

{ #category : '*Sindarin' }
OCProgramNode >> allChildrenPostOrder [

	| children |
	children := OrderedCollection new.
	self children do: [ :each | 
		each allChildrenPostOrder do: [ :child | children addLast: child ] ].
	children addLast: self.
	^ children
]

{ #category : '*Sindarin' }
OCProgramNode >> skipWithDebugger: aSindarinDebugger [

	aSindarinDebugger step
]
