DATA_DIR = data
HEAVY_DIR = ${DATA_DIR}/heavy
LIGHT_DIR = ${DATA_DIR}/light
FASTA_HEAVY= ${DATA_DIR}/heavy_chains.fasta
LIGHT_FASTA= ${DATA_DIR}/light_chains.fasta
SCRIPTS = scripts
TSV_DIR = tsvTestingResults
ANARCI_OUTPUT = outputsAnacri
HEAVY_ANARCI_OUTPUT = ${ANARCI_OUTPUT}/heavy
LIGHT_ANARCI_OUTPUT = ${ANARCI_OUTPUT}/light
HEAVY_TSV = ${TSV_DIR}/heavy
ESSENTIAL_FILES_FOR_NUMBERING_DIR = seq_by_numbering_scheme_link
TSV_MASTER_FILES = tsvTestingMaster
TSV_MASTER_HEAVY = ${TSV_MASTER_FILES}/heavy

DIFFS_HEAVY_DIR = diffs/heavy
DIFFS_LIGHT_DIR = diffs/light

MASTER_FASTA = sequence.fasta
HEAVY_FASTA_FILES = $(wildcard ${HEAVY_DIR}/*.fasta)
LIGHT_FASTA_FILES = $(wildcard ${LIGHT_DIR}/*.fasta)
HEAVY_OUTPUT_FILES = $(patsubst ${HEAVY_DIR}/%.fasta,${HEAVY_ANARCI_OUTPUT}/%.out,${HEAVY_FASTA_FILES})
LIGHT_OUTPUT_FILES = $(patsubst ${LIGHT_DIR}/%.fasta,${LIGHT_ANARCI_OUTPUT}/%.out,${LIGHT_FASTA_FILES})

HEAVY_DIFF_FILES = $(patsubst ${HEAVY_DIR}/%.fasta,${DIFFS_HEAVY_DIR}/%.diff,${HEAVY_FASTA_FILES})
LIGHT_DIFF_FILES = $(patsubst ${LIGHT_DIR}/%.fasta,${DIFFS_LIGHT_DIR}/%.diff,${LIGHT_FASTA_FILES})

HEAVY_TSV_FILES = $(patsubst ${HEAVY_DIR}/%.fasta,${HEAVY_TSV}/%.tsv,${HEAVY_FASTA_FILES})
MODYFIE_ANARI_OUT = ${SCRIPTS}/modifyAnarciOutput
NUMBER_ANTIBODY = numberAntibodySeq
TEST_SCRIPT = ${SCRIPTS}/testMyNumberingOutput
SPLIT_MASTER_FASTA = ${SCRIPTS}/splitBigFastaFile
GET_OPTIMAL_CLUSTERS = ${SCRIPTS}/getOptimalClusters
TSV_KABAT_HEAVY_MASTER = ${TSV_MASTER_HEAVY}/kabat_master.tsv

.PRECIOUS:${HEAVY_ANARCI_OUTPUT}/%.out

#  ${HEAVY_OUTPUT_FILES} ${LIGHT_OUTPUT_FILES} 

all: ${HEAVY_DIFF_FILES} ${LIGHT_DIFF_FILES} 


${DIFFS_HEAVY_DIR}/%.diff: ${HEAVY_ANARCI_OUTPUT}/%.out ${HEAVY_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) | tail -n +3 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@
	

${DIFFS_LIGHT_DIR}/%.diff: ${LIGHT_ANARCI_OUTPUT}/%.out ${LIGHT_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) | tail -n +3 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@


${LIGHT_ANARCI_OUTPUT}/%.out: ${LIGHT_DIR}/%.fasta
	ANARCI -i $< | ./${MODYFIE_ANARI_OUT} >$@


${HEAVY_ANARCI_OUTPUT}/%.out: ${HEAVY_DIR}/%.fasta
	ANARCI -i $< | ./${MODYFIE_ANARI_OUT} >$@


clean:
	rm ${DIFFS_HEAVY_DIR}/*.diff
	rm ${DIFFS_LIGHT_DIR}/*.diff

