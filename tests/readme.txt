This directory is created for testing our antibody numbering program. The reference output is taken from the ANARCI program.

Dir structure:
.
├── data
│   ├── heavy
│   ├── light
│   └── masterFasta
├── makefile
├── ncbiQueryInfo.txt
├── numberAntibodySeq -> ../scripts/numberAntibodySeq
├── outputsAnacri
│   ├── heavy
│   └── light
├── readme.txt
├── scripts
│   ├── getOptimalClusters
│   ├── modifyAnarciOutput
│   ├── splitBigFastaFile
│   ├── testMyNumberingOutput
│   └── test_report_generator.R
├── seq_by_numbering_scheme_link -> ../scripts_out/seq_by_numbering_scheme
├── sequence.fasta
├── testsPlots
├── tsvTestingMaster
│   ├── heavy
│   └── light
└── tsvTestingResults
    ├── heavy
    └── light

data: stores data files
	heavy: heavy chains
	light: light chains
	masterFasta: Stores the clustered master FASTA file and log file
ncbiQueryInfo: Stores info about ncbi query
sequence.fasta: ncbi query result
outputsAnacri: stores modified ANARCI output files
	heavy: heavy chains
	light: light chains
testsPlots: stores plots
tsvTestingResults: stores ANARCI and Our programm outptus comparison results in TSV format
	heavy: heavy chains
	light: light chains
tsvTestingMaster: stores merged TSV file created from all TSV files in the directory "tsvTestingResults"
	heavy: heavy chains
	light: light chains

TSV and masterTSV format:
	SeqName: file for now
	Insertion.region: region index
	ResultS: Comparison result, start(S) | none if MismathedFlag = 1
	AnarciAcS: ANARCI amino acid code,  start(S) | none if MismathedFlag = 1
	AnarciPosS: ANARCI amino acid pos,  start(S) | none if MismathedFlag = 1
	ProgrammAcS: Our Programm amino acid code,  start(S) | none if MismathedFlag = 1
	ProgrammPoS: Our Programm amino acid pos,  start(S) | none if MismathedFlag = 1
	ResultE # the same till "MismathedFlag"
	AnarciAcE
	AnarciPosE
	ProgrammAcE
	ProgrammPosE
	ResultL
	AnarciL
	ProgrammL
		MismathedFlag: 0 or 1. 1 "Equal to 1 if any of the programs found a region that was not described by another | none if MismathedFlag = 0
	ResultM none if MismathedFlag = 0
	StartAcM none if MismathedFlag = 0
	StartPosM none if MismathedFlag = 0
	EndAcM none if MismathedFlag = 0
	EndPoSM none if MismathedFlag = 0
	LengthM none if MismathedFlag = 0
		
ANACRI modified output file format (*.out):
	1 line: length - Equal to the nominal length of the sequence (insertions are taken into account)
		For example if: seq = 35 35A 35B 36 37; then length = 37 + ins = 39
		The length value will be used to modify the sequence length output by our program,
		as the function for determining the end of variable regions is not yet ready
	2:length
		ACcode\tPos(InsCode)?

scripts:
	getOptimalClusters masterFile clustersNum outDir
		script determines the optimal identity threshold in CD-HIT for creating ${clustersNum} clusters.
		
	modifyAnarciOutput anarciOutput
		script read data from STDIN. Modifies ANARCI outputs, generate .out files
	
	splitBigFastaFile masterFile outDir
		script splits "big" fasta to N-quantity small fasta files.
		
	test_report_generator.R tsvMasterFile outDir
		generates histograms
	
	testMyNumberingOutput --outFormat|-of json|tsv(by default) --refFile|-rf refFile.out (required) data<stdin>
		script compares ANARCI and Our progamm regions numbering and generates TSV files.
		Usage esample: ./numberAntibodySeq seq_by_numbering_scheme_link data/heavy fasta.fasta |\
		 ./scripts/testMyNumberingOutput outputsAnacri/heavy/fasta.out 

	

Below are the steps to run the testing:
Generate Data: make generateData (if data/heavy do not contain any files)
Test: make | make all

