Extension { #name : #RBBlockNode }

{ #category : #'*Sindarin' }
RBBlockNode >> parentOfIdenticalSubtree: subtree [

	^ self allChildren reversed
		  detect: [ :e | e == subtree ]
		  ifFound: [ :e | e parent ]
		  ifNone: [ nil ]
]
