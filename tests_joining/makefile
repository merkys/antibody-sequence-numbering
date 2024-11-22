# Test Data Files-----------------------------------------------------------------------------------------------
DATA_DIR = data
HEAVY_DIR = ${DATA_DIR}/heavy
HEAVY_FASTA_FILES = $(wildcard ${HEAVY_DIR}/*.fasta)

# Fasta Files----------------------------------------------------------------------------------------------------
PROT_DIR = prot_fasta
PROT_JOININGS = ${PROT_DIR}/joinings
PROT_VARIABLE = ${PROT_DIR}/variable

FASTA_IGJ_FILES = $(wildcard ${PROT_JOININGS}/*.fasta)
FASTA_IGV_FILES = $(wildcard ${PROT_VARIABLE}/*.fasta)

# Aligments------------------------------------------------------------------------------------------------------
ALIGNMENTS = aligment
ALIGN_JOININGS = ${ALIGNMENTS}/joinings
ALIGN_VARIABLE = ${ALIGNMENTS}/variable

ALIGMENTS_IGJ = $(patsubst ${PROT_JOININGS}/%.fasta,${ALIGN_JOININGS}/%.afa,${FASTA_IGJ_FILES})
ALIGMENTS_IGV = $(patsubst ${PROT_VARIABLE}/%.fasta,${ALIGN_VARIABLE}/%.afa,${FASTA_IGV_FILES})

# HMMS-----------------------------------------------------------------------------------------------------------
HMMS = hmms
HMMS_JOININGS = ${HMMS}/joinings
HMMS_VARIABLE = ${HMMS}/variable

HMMS_IGJ = $(patsubst ${PROT_JOININGS}/%.fasta,${HMMS_JOININGS}/%.hmm,${FASTA_IGJ_FILES})
HMMS_IGV = $(patsubst ${PROT_VARIABLE}/%.fasta,${HMMS_VARIABLE}/%.hmm,${FASTA_IGV_FILES})

COMBINED_IGJ = ${HMMS_JOININGS}/combined_IGJ.hmm
COMBINED_IGV = ${HMMS_VARIABLE}/combined_IGV.hmm

# ANARCI TESTING ------------------------------------------------------------------
ANARCI_OUTPUT = anarci_modified_out
TEST_RESULT = result_test
TEST_RESULT_HEAVY = ${TEST_RESULT}/heavy
HEAVY_ANARCI_OUTPUT = ${ANARCI_OUTPUT}/heavy

HEAVY_OUTPUT_FILES = $(patsubst ${HEAVY_DIR}/%.fasta,${HEAVY_ANARCI_OUTPUT}/%.out,${HEAVY_FASTA_FILES})
HEAVY_TEST_FILES = $(patsubst ${HEAVY_DIR}/%.fasta,${TEST_RESULT_HEAVY}/%.test,${HEAVY_FASTA_FILES})

MODYFIE_ANARCI_OUT = ${SCRIPTS}/modifyAnarciOutput
TEST_JOINING = ${SCRIPTS}/testJoiningHmm

OUTPUT_TSV = results_summary.tsv
SCRIPTS = scripts

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
generateHMM: ${COMBINED_IGJ} ${COMBINED_IGV}

${COMBINED_IGJ}: ${HMMS_IGJ}
	cat $^ > $@; \
	hmmpress $@;

${COMBINED_IGV}: ${HMMS_IGV}
	cat $^ > $@; \
	hmmpress $@;

${ALIGN_JOININGS}/%.afa: ${PROT_JOININGS}/%.fasta
	@mafft --auto $< > $@

${ALIGN_VARIABLE}/%.afa: ${PROT_VARIABLE}/%.fasta
	@mafft --auto $< > $@

${HMMS_JOININGS}/%.hmm: ${ALIGN_JOININGS}/%.afa
	hmmbuild $@ $<
	
${HMMS_VARIABLE}/%.hmm: ${ALIGN_VARIABLE}/%.afa
	hmmbuild $@ $<
	
${ALIGMENTS_IGJ}: ${FASTA_IGJ_FILES}

${ALIGMENTS_IGV}: ${FASTA_IGV_FILES}

${HMMS_IGJ}:${ALIGMENTS_IGJ}

${HMMS_IGV}:${ALIGMENTS_IGV}

