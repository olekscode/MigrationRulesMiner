Class {
	#name : #MrExperimentManager,
	#superclass : #Object,
	#instVars : [
		'repository',
		'branch',
		'experiment',
		'methodChanges'
	],
	#category : #'MigrationRulesMiner-Controllers'
}

{ #category : #accessing }
MrExperimentManager >> branch: aBranch [
	branch := aBranch.
	experiment branchName: branch name.
]

{ #category : #accessing }
MrExperimentManager >> experiment [
	^ experiment
]

{ #category : #initialization }
MrExperimentManager >> initialize [
	super initialize.
	experiment := MrExperiment new.
]

{ #category : #'as yet unclassified' }
MrExperimentManager >> loadAllCommits [
	| commits |
	commits := branch commits collect: [ :each | each asMrCommit ].
	
	repository tags do: [ :tag |
		commits
			detect: [ :commit | commit sha = tag commit id ]
			ifFound: [ :commit | commit tags add: tag name ] ].
	
	^ commits
]

{ #category : #'as yet unclassified' }
MrExperimentManager >> loadMethodChangesFromCommit: aFromCommit toCommit: aToCommit [
	| methodChangeCollector methodCallCollector |
	
	experiment
		fromCommit: aFromCommit;
		toCommit: aToCommit.
	
	methodChangeCollector := MrMethodChangeCollector
		forRepository: repository
		branch: branch.
	
	methodChanges := methodChangeCollector
		collectMethodChangesFromCommit: experiment fromCommit
		toCommit: experiment toCommit.
		
	experiment numberOfTransactions: methodChanges size.
		
	methodCallCollector := MrMethodCallCollector new.
	
	methodChanges do: [ :change |
		methodCallCollector extractAddedAndDeletedMethodCallsFrom: change ].
]

{ #category : #'as yet unclassified' }
MrExperimentManager >> mineRulesWithMinCount: aMinCount minConfidence: aMinConfidence [
	| aprioriMiner mapper rules |
	
	experiment minCount: aMinCount.
	experiment minConfidence: aMinConfidence.

	aprioriMiner := MrAprioriMiner new.
	
	rules := aprioriMiner
		mineRulesFromMethodChanges: methodChanges
		withMinCount: experiment minCount.
		
	rules := rules select: [ :rule |
		rule confidence >= experiment minConfidence ].
		
	mapper := MrRuleMethodChangeMapper new.
	mapper mapRules: rules toMethodChanges: methodChanges.
	
	experiment rules: rules.
]

{ #category : #accessing }
MrExperimentManager >> repository: aRepository [
	repository := aRepository.
	
	experiment
		repositoryName: repository name;
		repositoryUrl: repository origin httpsUrl.
]