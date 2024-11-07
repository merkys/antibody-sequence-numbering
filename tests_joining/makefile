DATA_DIR = data
HEAVY_DIR = ${DATA_DIR}/heavy
PROT_DIR = prot_fasta
ALIGNMENTS = aligment
HMMS = hmms
SCRIPTS = scripts
ANARCI_OUTPUT = anarci_modified_out
TEST_RESULT = result_test
TEST_RESULT_HEAVY = ${TEST_RESULT}/heavy
HEAVY_ANARCI_OUTPUT = ${ANARCI_OUTPUT}/heavy
MASTER_PROT = ${PROT_DIR}/masterProtein.fa
ALIGNEMNT_IGHJ = ${ALIGNMENTS}/IGHJ.afa
HMM_IGHJ = ${HMMS}/IGHJ.hmm

HEAVY_FASTA_FILES = $(wildcard ${HEAVY_DIR}/*.fasta)
HEAVY_OUTPUT_FILES = $(patsubst ${HEAVY_DIR}/%.fasta,${HEAVY_ANARCI_OUTPUT}/%.out,${HEAVY_FASTA_FILES})

HEAVY_TEST_FILES = $(patsubst ${HEAVY_DIR}/%.fasta,${TEST_RESULT_HEAVY}/%.test,${HEAVY_FASTA_FILES})

MODYFIE_ANARCI_OUT = ${SCRIPTS}/modifyAnarciOutput
TEST_JOINING = ${SCRIPTS}/testJoiningHmm

OUTPUT_TSV = results_summary.tsv

.PRECIOUS:${HEAVY_ANARCI_OUTPUT}/%.out

all: ${OUTPUT_TSV}

${OUTPUT_TSV}: ${HEAVY_TEST_FILES}
	echo "Filename\tResult\t" > $@
	@for file in $^; do \
		result=$$(cat $$file); \
		filename=$$(basename $$file); \
		echo "$$filename\t$$result" >> $@; \
	done


${TEST_RESULT_HEAVY}/%.test: ${HEAVY_ANARCI_OUTPUT}/%.out ${HEAVY_DIR}/%.fasta
	./${TEST_JOINING} ${HMM_IGHJ} $< ${HEAVY_DIR}/$*.fasta > $@


${HEAVY_ANARCI_OUTPUT}/%.out: ${HEAVY_DIR}/%.fasta
	ANARCI -i $< --scheme "kabat" | \
	./${MODYFIE_ANARCI_OUT} > $@

#----------------------------------------------------------
MASTER_FASTA = fasta/heavy_chains.fasta
SPLIT_MASTER_FASTA = ${SCRIPTS}/splitBigFastaFile

prepareData: ${MASTER_FASTA}
	./${SPLIT_MASTER_FASTA} ${MASTER_FASTA} ${HEAVY_DIR}


#-------------------------------------------
generateHMM: ${HMM_IGHJ}

${ALIGNEMNT_IGHJ}: ${MASTER_PROT}
	@mafft --auto $< > $@

${HMM_IGHJ}: ${ALIGNEMNT_IGHJ}
	hmmbuild $@ $<
