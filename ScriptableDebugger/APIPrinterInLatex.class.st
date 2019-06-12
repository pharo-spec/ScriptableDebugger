Class {
	#name : #APIPrinterInLatex,
	#superclass : #Object,
	#category : #ScriptableDebugger
}

{ #category : #printing }
APIPrinterInLatex class >> printAPIInLatexOfClass: aClass [
	"In latex format for the paper. You have to escape characters like \ and # yourself if they appear in comments. Does not print methods in the 'initialize' protocol, or in a protocol ending with 'private'"
| protocolToMethodList rws |
protocolToMethodList := Dictionary new.
aClass methodDictionary valuesDo: [ :cmpMethod |
	|prot|
	prot := cmpMethod protocol.
	(protocolToMethodList includesKey: prot) ifFalse: [ protocolToMethodList at: prot put: LinkedList new ].
	(protocolToMethodList at: prot) add: cmpMethod.
].
rws := ReadWriteStream with: LinkedList new.
"Sort the protocols alphabetically"
(protocolToMethodList associations sort: [ :asso1 :asso2 | (asso1 key) <= (asso2 key) ]) do: [ :assoc |
	|prot cmpMethodList|
	prot := assoc key. cmpMethodList := assoc value.
	((prot endsWith: 'private') or: [prot = 'initialization']) ifFalse: [ 
		rws nextPutAll: '\subsubsection{', prot, '}', Character cr asString.
		cmpMethodList do: [ :cmpMethod |
			|fullSelector comment|
			fullSelector := cmpMethod selector.
			(cmpMethod ast arguments size >= 1) ifTrue: [ 
				fullSelector := ''.
				(cmpMethod selector substrings: ':') with: (cmpMethod ast arguments) do: [:selecPart :rbArg|
					fullSelector := fullSelector, selecPart, ': ', rbArg name, ' '.
				].	
			].
			comment := ''.
			(cmpMethod comment) ifNotNil: [ comment := cmpMethod comment, Character cr asString ].
			rws nextPutAll: '\begin{lstlisting}', Character cr asString, fullSelector, '\end{lstlisting}', Character cr asString, comment, Character cr asString.
		].
	].
].
^ rws contents inject: '' into: [ :acc :char | acc , char asString].
	
]
