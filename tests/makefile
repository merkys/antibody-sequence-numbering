DATA_DIR = data
HEAVY_DIR = ${DATA_DIR}/heavy
LIGHT_DIR = ${DATA_DIR}/light
FASTA_HEAVY= ${DATA_DIR}/heavy_chains.fasta
LIGHT_FASTA= ${DATA_DIR}/light_chains.fasta
SCRIPTS = scripts
ANARCI_OUTPUT = outputsAnacri
HEAVY_ANARCI_OUTPUT = ${ANARCI_OUTPUT}/heavy
LIGHT_ANARCI_OUTPUT = ${ANARCI_OUTPUT}/light

DIFFS_HEAVY_DIR = diffs/heavy
DIFFS_LIGHT_DIR = diffs/light

HEAVY_FASTA_FILES = $(wildcard ${HEAVY_DIR}/*.fasta)
LIGHT_FASTA_FILES = $(wildcard ${LIGHT_DIR}/*.fasta)
HEAVY_OUTPUT_FILES = $(patsubst ${HEAVY_DIR}/%.fasta,${HEAVY_ANARCI_OUTPUT}/%.out,${HEAVY_FASTA_FILES})
LIGHT_OUTPUT_FILES = $(patsubst ${LIGHT_DIR}/%.fasta,${LIGHT_ANARCI_OUTPUT}/%.out,${LIGHT_FASTA_FILES})

HEAVY_DIFF_FILES = $(patsubst ${HEAVY_DIR}/%.fasta,${DIFFS_HEAVY_DIR}/%.diff,${HEAVY_FASTA_FILES})
LIGHT_DIFF_FILES = $(patsubst ${LIGHT_DIR}/%.fasta,${DIFFS_LIGHT_DIR}/%.diff,${LIGHT_FASTA_FILES})

MODYFIE_ANARI_OUT = ${SCRIPTS}/modifyAnarciOutput
NUMBER_ANTIBODY = numberAntibodySeq

.PRECIOUS:${HEAVY_ANARCI_OUTPUT}/%.out


all: ${HEAVY_DIFF_FILES} ${LIGHT_DIFF_FILES} 


${DIFFS_HEAVY_DIR}/%.diff: ${HEAVY_ANARCI_OUTPUT}/%.out ${HEAVY_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@
	

${DIFFS_LIGHT_DIR}/%.diff: ${LIGHT_ANARCI_OUTPUT}/%.out ${LIGHT_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@


${LIGHT_ANARCI_OUTPUT}/%.out: ${LIGHT_DIR}/%.fasta
	ANARCI -i $< | ./${MODYFIE_ANARI_OUT} >$@


${HEAVY_ANARCI_OUTPUT}/%.out: ${HEAVY_DIR}/%.fasta
	ANARCI -i $< | ./${MODYFIE_ANARI_OUT} >$@


clean:
	rm ${DIFFS_HEAVY_DIR}/*.diff
	rm ${DIFFS_LIGHT_DIR}/*.diff

