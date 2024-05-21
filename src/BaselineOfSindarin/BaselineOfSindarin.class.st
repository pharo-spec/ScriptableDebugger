Class {
	#name : 'BaselineOfSindarin',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfSindarin',
	#package : 'BaselineOfSindarin'
}

{ #category : 'baselines' }
BaselineOfSindarin >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec postLoadDoIt: #postloadWithLoader:withPackageSpec:.

		spec
			package: 'Sindarin';
			package: 'Sindarin-Tests';
			package: 'Sindarin-Experiments' ].

	spec
		group: 'default' with: #( 'Sindarin' 'Sindarin-Tests' );
		group: 'experiments' with: #( 'default' 'Sindarin-Experiments' )
]

{ #category : 'baselines' }
BaselineOfSindarin >> postloadWithLoader: loader withPackageSpec: spec [

	InstructionStream compiledMethodAt: #willJumpIfFalse ifAbsent: [
		Smalltalk compiler
			source: 'willJumpIfFalse
	"Answer whether the next bytecode is a jump-if-false."

	^ self method encoderClass isBranchIfFalseAt: pc in: self method';
			class: InstructionStream;
			compile;
			install ]
]
