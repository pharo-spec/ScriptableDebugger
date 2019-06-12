Class {
	#name : #BaselineOfScriptableDebugger,
	#superclass : #BaselineOf,
	#category : #BaselineOfScriptableDebugger
}

{ #category : #baselines }
BaselineOfScriptableDebugger >> baseline: spec [
	<baseline>
	spec
		for: #common		
		do: [		
			"Packages"
			spec
				package: 'ScriptableDebugger';
				package: 'ScriptableDebugger-Tests'.
		 ]

]
