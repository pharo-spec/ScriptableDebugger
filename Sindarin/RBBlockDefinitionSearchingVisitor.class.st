Class {
	#name : #RBBlockDefinitionSearchingVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'blockToSearch',
		'isBlockFound'
	],
	#category : #Sindarin
}

{ #category : #accessing }
RBBlockDefinitionSearchingVisitor >> blockToSearch: aBlockNode [

	blockToSearch := aBlockNode.
	isBlockFound := false
]

{ #category : #initialization }
RBBlockDefinitionSearchingVisitor >> initialize [

	isBlockFound := false
]

{ #category : #accessing }
RBBlockDefinitionSearchingVisitor >> isBlockFound [

	^ isBlockFound
]

{ #category : #visiting }
RBBlockDefinitionSearchingVisitor >> visitNode: aNode [

	super visitNode: aNode.
	aNode = blockToSearch ifTrue: [ isBlockFound := true ].
	^ isBlockFound 
]
