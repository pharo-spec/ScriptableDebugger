Class {
	#name : 'RBBlockDefinitionSearchingVisitor',
	#superclass : 'RBProgramNodeVisitor',
	#instVars : [
		'blockToSearch',
		'isBlockFound'
	],
	#category : 'Sindarin-Base',
	#package : 'Sindarin',
	#tag : 'Base'
}

{ #category : 'instance creation' }
RBBlockDefinitionSearchingVisitor class >> newToSearch: aBlockNode [

	^ self new
		  blockToSearch: aBlockNode;
		  yourself
]

{ #category : 'accessing' }
RBBlockDefinitionSearchingVisitor >> blockToSearch: aBlockNode [

	blockToSearch := aBlockNode.
	isBlockFound := false
]

{ #category : 'initialization' }
RBBlockDefinitionSearchingVisitor >> initialize [

	isBlockFound := false
]

{ #category : 'accessing' }
RBBlockDefinitionSearchingVisitor >> isBlockFound [

	^ isBlockFound
]

{ #category : 'visiting' }
RBBlockDefinitionSearchingVisitor >> visitNode: aNode [

	super visitNode: aNode.
	aNode = blockToSearch ifTrue: [ isBlockFound := true ].
	^ isBlockFound 
]
