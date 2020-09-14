Extension { #name : #Context }

{ #category : #'*Sindarin' }
Context >> currentNode [
	^ self method sourceNodeForPC: self pc
]
