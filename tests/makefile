DATA_DIR = data
HEAVY_DIR = ${DATA_DIR}/heavy
LIGHT_DIR = ${DATA_DIR}/light
MASTER_FASTA_DIR = ${DATA_DIR}/masterFasta
SCRIPTS = scripts
TSV_DIR = tsvTestingResults
ANARCI_OUTPUT = outputsAnacri
HEAVY_ANARCI_OUTPUT = ${ANARCI_OUTPUT}/heavy
HEAVY_TSV = ${TSV_DIR}/heavy
ESSENTIAL_FILES_FOR_NUMBERING_DIR = seq_by_numbering_scheme_link
TSV_MASTER_FILES = tsvTestingMaster
TSV_MASTER_HEAVY = ${TSV_MASTER_FILES}/heavy

MASTER_FASTA = sequence.fasta
HEAVY_FASTA_FILES = $(wildcard ${HEAVY_DIR}/*.fasta)
HEAVY_OUTPUT_FILES = $(patsubst ${HEAVY_DIR}/%.fasta,${HEAVY_ANARCI_OUTPUT}/%.out,${HEAVY_FASTA_FILES})
HEAVY_TSV_FILES = $(patsubst ${HEAVY_DIR}/%.fasta,${HEAVY_TSV}/%.tsv,${HEAVY_FASTA_FILES})
MODYFIE_ANARI_OUT = ${SCRIPTS}/modifyAnarciOutput
NUMBER_ANTIBODY = numberAntibodySeq
TEST_SCRIPT = ${SCRIPTS}/testMyNumberingOutput
SPLIT_MASTER_FASTA = ${SCRIPTS}/splitBigFastaFile
GET_OPTIMAL_CLUSTERS = ${SCRIPTS}/getOptimalClusters
TSV_KABAT_HEAVY_MASTER = ${TSV_MASTER_HEAVY}/kabat_master.tsv

all: ${TSV_KABAT_HEAVY_MASTER}
	
${HEAVY_ANARCI_OUTPUT}/%.out: ${HEAVY_DIR}/%.fasta
	ANARCI -i $< --scheme "kabat" | \
	./${MODYFIE_ANARI_OUT} > $@


${HEAVY_TSV}/%.tsv: ${HEAVY_DIR}/%.fasta ${HEAVY_ANARCI_OUTPUT}/%.out
	./${NUMBER_ANTIBODY} ${ESSENTIAL_FILES_FOR_NUMBERING_DIR} $< |\
	./${TEST_SCRIPT} -of "tsv" -rf ${HEAVY_ANARCI_OUTPUT}/$*.out > $@
	
${TSV_KABAT_HEAVY_MASTER}: ${HEAVY_TSV_FILES}
	> $@
	head -n 1 $(firstword ${HEAVY_TSV_FILES}) | head -n 1 >> $@
	for f in ${HEAVY_TSV_FILES}; do \
		if [ "$$f" != "${HEAVY_TSV_FILES[0]}" ]; then \
			tail -n +2 "$$f" >> $@; \
		fi; \
	done
#-----------------------------------------------------------------------------------------
generateData: ${MASTER_FASTA}
	./${GET_OPTIMAL_CLUSTERS} $< 500 ${MASTER_FASTA_DIR}
	./${SPLIT_MASTER_FASTA} "${MASTER_FASTA_DIR}/optimalClusters.fasta" ${HEAVY_DIR}



