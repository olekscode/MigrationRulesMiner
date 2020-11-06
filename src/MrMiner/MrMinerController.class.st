Class {
	#name : #MrMinerController,
	#superclass : #Object,
	#instVars : [
		'settings',
		'projectHistory',
		'model',
		'repository',
		'refrain',
		'clio'
	],
	#category : #'MrMiner-Controllers'
}

{ #category : #'as yet unclassified' }
MrMinerController >> candidateCommitsForNewVersion [
	| commits |
	
	commits := projectHistory commits values.
	
	projectHistory commits
		at: settings oldCommitSha
		ifPresent: [ :oldCommit |
			commits := commits select: [ :commit |
				commit date > model oldVersionCommit date or: [ 
					commit date = model oldVersionCommit date and: [ 
						commit time > model oldVersionCommit time ] ] ] ].
	^ commits
]

{ #category : #'as yet unclassified' }
MrMinerController >> candidateCommitsForOldVersion [
	^ projectHistory commits values
]

{ #category : #'as yet unclassified' }
MrMinerController >> extractAllCommitsFromRepository [
	projectHistory commits removeAll.
	
	refrain commits do: [ :commit |
		projectHistory at: commit sha put: commit ].
]

{ #category : #'as yet unclassified' }
MrMinerController >> getGitHubRepository: aRepositoryName by: anOwnerName [
	[ ^ IceGitHubAPI new
		beAnonymous;
		getRepository: anOwnerName project: aRepositoryName ]
		on: LGitNoCredentialsProvided
		do: [ ^ nil ]
]

{ #category : #'as yet unclassified' }
MrMinerController >> loadAddedMethods [
	model addedMethods: clio addedMethods asArray.
]

{ #category : #'as yet unclassified' }
MrMinerController >> loadChanges [
	refrain := Refrain
		repository: repository
		firstCommit: settings oldCommitSha
		lastCommit: settings newCommitSha.
		
	clio := Clio
		forRepository: repository
		between: settings oldCommitSha
		and: settings newCommitSha.
		
	projectHistory commits: refrain commitDictionary.
		
	self loadOldVersion.
	self loadNewVersion.
	self loadDeletedMethods.
	self loadAddedMethods.
	self loadOldDeprecatedMethods.
	self loadNewDeprecatedMethods.
	self loadUnchangedDeprecatedMethods.
	
	refrain loadMethodChanges.
]

{ #category : #'as yet unclassified' }
MrMinerController >> loadDeletedMethods [
	model deletedMethods: clio deletedMethods asArray.
]

{ #category : #'as yet unclassified' }
MrMinerController >> loadNewDeprecatedMethods [
	model newDeprecatedMethods: (model newMethods select: [ :method | method isDeprecated ]).
]

{ #category : #'as yet unclassified' }
MrMinerController >> loadNewVersion [
	model newMethods: clio newMethods asArray.
]

{ #category : #'as yet unclassified' }
MrMinerController >> loadOldDeprecatedMethods [
	model oldDeprecatedMethods: (model oldMethods select: [ :method | method isDeprecated ]).
]

{ #category : #'as yet unclassified' }
MrMinerController >> loadOldVersion [
	model oldMethods: clio oldMethods asArray.
]

{ #category : #'as yet unclassified' }
MrMinerController >> loadProject: aProjectName by: anOwnerName [
	"Load a project from GitHub or select the existing one"
	
	repository := IceRepository registry
		detect: [ :repo |
			repo isValid and: [
				repo location path parent basename = anOwnerName and: [
					repo name = aProjectName ] ] ]
		ifFound: [ :repo | repo ]
		ifNone: [ self getGitHubRepository: aProjectName by: anOwnerName ].
]

{ #category : #'as yet unclassified' }
MrMinerController >> loadUnchangedDeprecatedMethods [
	model unchangedDeprecatedMethods: (clio unchangedMethods select: [ :method | method isDeprecated ]) asArray.
]

{ #category : #'as yet unclassified' }
MrMinerController >> mineRules [
	| methodCallCollector |
	
	methodCallCollector := MrMinerSelectorCollector new
		oldSelectors: (clio oldMethods collect: [ :method | method selector ]);
		newSelectors: (clio newMethods collect: [ :method | method selector ]);
		yourself.
		
	refrain entityCollector: methodCallCollector.
	^ refrain mineRepetitiveChanges.
]

{ #category : #'as yet unclassified' }
MrMinerController >> mineRulesWithMinCount: aMinCount minConfidence: aMinConfidence [
	refrain minNumberOfRepetitions: aMinCount.
	refrain mineRules.
	
	model rules: (refrain rules select: [ :rule | rule confidence >= aMinConfidence ]).
]

{ #category : #accessing }
MrMinerController >> model: anObject [
	model := anObject
]

{ #category : #accessing }
MrMinerController >> projectHistory: anObject [
	projectHistory := anObject
]

{ #category : #accessing }
MrMinerController >> settings: anObject [
	settings := anObject
]