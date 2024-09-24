Extension { #name : 'ASTProgramNode' }

{ #category : '*Sindarin' }
ASTProgramNode >> allChildrenPostOrder [

	| children |
	children := OrderedCollection new.
	self children do: [ :each | 
		each allChildrenPostOrder do: [ :child | children addLast: child ] ].
	children addLast: self.
	^ children
]

{ #category : '*Sindarin' }
ASTProgramNode >> skipWithDebugger: aSindarinDebugger [

	aSindarinDebugger step
]
