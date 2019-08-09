Extension { #name : #SindarinDebugger }

{ #category : #'*Sindarin-Tools' }
SindarinDebugger >> sindarinDebuggerInspection [
	<inspectorPresentationOrder: -10 title: 'Sindarin'>

	^ StSindarinDebuggerPresenter on: self
]
