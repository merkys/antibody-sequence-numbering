## Roor Dirs
DATA_DIR = data
ANARCI_OUTPUT_DIR = outputsAnarci
DIFFS_DIR = diffs
SCRIPTS = scripts
RAW_DATA_DIR = raw_data

## Dir Names Sets
RAW_DATA_DIRS_NAMES = fasta sampled_fasta
SPECIES = homo_sapiense mus_musculus
CHAINS = heavy kappa lambda

## Dirs in dirs generators
CHAINS_DATA_DIRS = $(foreach chain, $(CHAINS), $(foreach sp, $(SPECIES), $(DATA_DIR)/$(sp)/$(chain)))
CHAINS_ANARCI_OUTPUT_DIRS = $(foreach chain, $(CHAINS), $(foreach sp, $(SPECIES), $(ANARCI_OUTPUT_DIR)/$(sp)/$(chain)))
CHAINS_DIFFS_DIRS = $(foreach chain, $(CHAINS), $(foreach sp, $(SPECIES), $(DIFFS_DIR)/$(sp)/$(chain)))
CHAINS_RAW_DATA_DIRS = $(foreach dir_name, $(RAW_DATA_DIRS_NAMES), $(foreach sp, $(SPECIES), $(RAW_DATA_DIR)/$(sp)/$(dir_name)))

ALL_DIRS = ${DATA_DIR} ${ANARCI_OUTPUT_DIR} ${CHAINS_DATA_DIRS} ${CHAINS_ANARCI_OUTPUT_DIRS} ${CHAINS_DIFFS_DIRS} ${CHAINS_RAW_DATA_DIRS}

generate_dirs:
	mkdir -p ${ALL_DIRS}

#---------------------------------------------------------------------------------------------------------------------------------
## External File links 
SEQ_FROM_PDB_LINK = https://files.wwpdb.org/pub/pdb/derived_data/pdb_seqres.txt.gz

## External Files
ALL_SEQ_FILE = ${RAW_DATA_DIR}/pdb_seqres.txt.gz
SUMMARY_FILES = $(foreach sp, $(SPECIES), ${RAW_DATA_DIR}/$(sp)/anotation_file.tsv)

## Scripts
GREP_ANTOBODIES = ${SCRIPTS}/data_preparation/grepAntibodies
SPLIT_FASTA = ${SCRIPTS}/data_preparation/splitBigFastaFile
## Sorted Fasta Files
SORTED_FASTA_FILES_NAMES = IGL IGK IGH
HOMO_SORTED_FASTA_FILES = $(foreach file_name, $(SORTED_FASTA_FILES_NAMES), $(RAW_DATA_DIR)/homo_sapiense/fasta/$(file_name).fasta)
MUS_SORTED_FASTA_FILES = $(foreach file_name, $(SORTED_FASTA_FILES_NAMES), $(RAW_DATA_DIR)/mus_musculus/fasta/$(file_name).fasta)
SORTED_FASTA_FILES = ${HOMO_SORTED_FASTA_FILES} ${MUS_SORTED_FASTA_FILES}

HOMO_SAMPLED_FASTA_FILES = $(foreach file_name, $(SORTED_FASTA_FILES_NAMES), $(RAW_DATA_DIR)/homo_sapiense/sampled_fasta/$(file_name).fasta)
MUS_SAMPLED_FASTA_FILES = $(foreach file_name, $(SORTED_FASTA_FILES_NAMES), $(RAW_DATA_DIR)/mus_musculus/sampled_fasta/$(file_name).fasta)
SAMPLED_FASTA_FILES = ${HOMO_SAMPLED_FASTA_FILES} ${MUS_SAMPLED_FASTA_FILES}


prepare_data: ${SAMPLED_FASTA_FILES}
	@for sp in $(SPECIES); do \
	    ./${SPLIT_FASTA} $(RAW_DATA_DIR)/$$sp/sampled_fasta/IGH.fasta $(DATA_DIR)/$$sp/heavy; \
	    ./${SPLIT_FASTA} $(RAW_DATA_DIR)/$$sp/sampled_fasta/IGL.fasta $(DATA_DIR)/$$sp/lambda; \
	    ./${SPLIT_FASTA} $(RAW_DATA_DIR)/$$sp/sampled_fasta/IGK.fasta $(DATA_DIR)/$$sp/kappa; \
	done

$(RAW_DATA_DIR)/homo_sapiense/sampled_fasta/%.fasta: $(RAW_DATA_DIR)/homo_sapiense/fasta/%.fasta
	seqkit sample -n 200 -w 0 -o $@ $<

$(RAW_DATA_DIR)/mus_musculus/sampled_fasta/%.fasta: $(RAW_DATA_DIR)/mus_musculus/fasta/%.fasta
	seqkit sample -n 200 -w 0 -o $@ $<


${HOMO_SORTED_FASTA_FILES}: ${ALL_SEQ_FILE}
	./${GREP_ANTOBODIES} ${RAW_DATA_DIR}/homo_sapiense/anotation_file.tsv ${ALL_SEQ_FILE} ${RAW_DATA_DIR}/homo_sapiense/fasta
	
${MUS_SORTED_FASTA_FILES}: ${ALL_SEQ_FILE}
	./${GREP_ANTOBODIES} ${RAW_DATA_DIR}/mus_musculus/anotation_file.tsv ${ALL_SEQ_FILE} ${RAW_DATA_DIR}/mus_musculus/fasta


clean_data:
	rm -rf $(DATA_DIR)/homo_sapiense/heavy/*
	rm -rf $(DATA_DIR)/homo_sapiense/lambda/*
	rm -rf $(DATA_DIR)/homo_sapiense/kappa/*
	rm -rf $(DATA_DIR)/mus_musculus/heavy/*
	rm -rf $(DATA_DIR)/mus_musculus/lambda/*
	rm -rf $(DATA_DIR)/mus_musculus/kappa/*

${ALL_SEQ_FILE}:
	wget -O $@ ${SEQ_FROM_PDB_LINK}
#---------------------------------------------------------------------------------------------------------------------------------
HOMO_HEAVY_FASTA_DIR = ${DATA_DIR}/homo_sapiense/heavy
HOMO_LAMBDA_FASTA_DIR = ${DATA_DIR}/homo_sapiense/lambda
HOMO_KAPPA_FASTA_DIR = ${DATA_DIR}/homo_sapiense/kappa

HOMO_HEAVY_FASTA_FILES = $(wildcard ${HOMO_HEAVY_FASTA_DIR}/*.fasta)
HOMO_LAMBDA_FASTA_FILES = $(wildcard ${HOMO_LAMBDA_FASTA_DIR}/*.fasta)
HOMO_KAPPA_FASTA_FILES = $(wildcard ${HOMO_KAPPA_FASTA_DIR}/*.fasta)


HOMO_HEAVY_ANARCI_OUT_DIR = ${ANARCI_OUTPUT_DIR}/homo_sapiense/heavy
HOMO_LAMBDA_ANARCI_OUT_DIR = ${ANARCI_OUTPUT_DIR}/homo_sapiense/lambda
HOMO_KAPPA_ANARCI_OUT_DIR = ${ANARCI_OUTPUT_DIR}/homo_sapiense/kappa

HOMO_HEAVY_OUTPUT_FILES = $(patsubst ${HOMO_HEAVY_FASTA_DIR}/%.fasta,${HOMO_HEAVY_ANARCI_OUT_DIR}/%.out,${HOMO_HEAVY_FASTA_FILES})
HOMO_LAMBDA_OUTPUT_FILES = $(patsubst ${HOMO_LAMBDA_FASTA_DIR}/%.fasta,${HOMO_LAMBDA_ANARCI_OUT_DIR}/%.out,${HOMO_LAMBDA_FASTA_FILES})
HOMO_KAPPA_OUTPUT_FILES = $(patsubst ${HOMO_KAPPA_FASTA_DIR}/%.fasta,${HOMO_KAPPA_ANARCI_OUT_DIR}/%.out,${HOMO_KAPPA_FASTA_FILES})


HOMO_HEAVY_DIFF_DIR = ${DIFFS_DIR}/homo_sapiense/heavy
HOMO_LAMBDA_DIFF_DIR = ${DIFFS_DIR}/homo_sapiense/lambda
HOMO_KAPPA_DIFF_DIR = ${DIFFS_DIR}/homo_sapiense/kappa

HOMO_HEAVY_DIFF_FILES = $(patsubst ${HOMO_HEAVY_FASTA_DIR}/%.fasta, ${HOMO_HEAVY_DIFF_DIR}/%.diff,${HOMO_HEAVY_FASTA_FILES})
HOMO_LAMBDA_DIFF_FILES = $(patsubst ${HOMO_LAMBDA_FASTA_DIR}/%.fasta, ${HOMO_LAMBDA_DIFF_DIR}/%.diff,${HOMO_LAMBDA_FASTA_FILES})
HOMO_KAPPA_DIFF_FILES = $(patsubst ${HOMO_KAPPA_FASTA_DIR}/%.fasta, ${HOMO_KAPPA_DIFF_DIR}/%.diff,${HOMO_KAPPA_FASTA_FILES})


MODYFIE_ANARI_OUT = ${SCRIPTS}/modifyAnarciOutput
NUMBER_ANTIBODY = numberAntibodySeq



.PRECIOUS:${HOMO_KAPPA_ANARCI_OUT_DIR}/%.out ${HOMO_LAMBDA_ANARCI_OUT_DIR}/%.out ${HOMO_HEAVY_ANARCI_OUT_DIR}/%.out


test_homo: ${HOMO_HEAVY_DIFF_FILES} ${HOMO_LAMBDA_DIFF_FILES} ${HOMO_KAPPA_DIFF_FILES}
	@echo "Total diff files: $(shell find diffs/homo_sapiense -type f -name "*.diff" | wc -l)"
	@echo "Empty diff files: $(shell find diffs/homo_sapiense -type f -name "*.diff" -empty | wc -l)"

${HOMO_HEAVY_DIFF_DIR}/%.diff: ${HOMO_HEAVY_ANARCI_OUT_DIR}/%.out ${HOMO_HEAVY_FASTA_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@
	

${HOMO_LAMBDA_DIFF_DIR}/%.diff: ${HOMO_LAMBDA_ANARCI_OUT_DIR}/%.out ${HOMO_LAMBDA_FASTA_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@


${HOMO_KAPPA_DIFF_DIR}/%.diff: ${HOMO_KAPPA_ANARCI_OUT_DIR}/%.out ${HOMO_KAPPA_FASTA_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@


${HOMO_LAMBDA_ANARCI_OUT_DIR}/%.out: ${HOMO_LAMBDA_FASTA_DIR}/%.fasta
	ANARCI -i $< | ./${MODYFIE_ANARI_OUT} >$@


${HOMO_HEAVY_ANARCI_OUT_DIR}/%.out: ${HOMO_HEAVY_FASTA_DIR}/%.fasta
	ANARCI -i $< | ./${MODYFIE_ANARI_OUT} >$@


${HOMO_KAPPA_ANARCI_OUT_DIR}/%.out: ${HOMO_KAPPA_FASTA_DIR}/%.fasta
	ANARCI -i $< | ./${MODYFIE_ANARI_OUT} >$@




clean_homo_out:
	rm -rf ${HOMO_HEAVY_ANARCI_OUT_DIR}/*.diff
	rm -rf ${HOMO_LAMBDA_ANARCI_OUT_DIR}/*.diff
	rm -rf ${HOMO_KAPPA_ANARCI_OUT_DIR}/*.diff


clean_homo_diffs:
	rm -rf ${HOMO_HEAVY_DIFF_DIR}/*.diff
	rm -rf ${HOMO_LAMBDA_DIFF_DIR}/*.diff
	rm -rf ${HOMO_KAPPA_DIFF_DIR}/*.diff
	
#---------------------------------------------------------------------------------------------------	
	
MUS_HEAVY_FASTA_DIR = ${DATA_DIR}/mus_musculus/heavy
MUS_KAPPA_FASTA_DIR = ${DATA_DIR}/mus_musculus/kappa

MUS_HEAVY_FASTA_FILES = $(wildcard ${MUS_HEAVY_FASTA_DIR}/*.fasta)
MUS_KAPPA_FASTA_FILES = $(wildcard ${MUS_KAPPA_FASTA_DIR}/*.fasta)


MUS_HEAVY_ANARCI_OUT_DIR = ${ANARCI_OUTPUT_DIR}/mus_musculus/heavy
MUS_KAPPA_ANARCI_OUT_DIR = ${ANARCI_OUTPUT_DIR}/mus_musculus/kappa

MUS_HEAVY_OUTPUT_FILES = $(patsubst ${MUS_HEAVY_FASTA_DIR}/%.fasta,${MUS_HEAVY_ANARCI_OUT_DIR}/%.out,${MUS_HEAVY_FASTA_FILES})
MUS_KAPPA_OUTPUT_FILES = $(patsubst ${MUS_KAPPA_FASTA_DIR}/%.fasta,${MUS_KAPPA_ANARCI_OUT_DIR}/%.out,${MUS_KAPPA_FASTA_FILES})


MUS_HEAVY_DIFF_DIR = ${DIFFS_DIR}/mus_musculus/heavy
MUS_KAPPA_DIFF_DIR = ${DIFFS_DIR}/mus_musculus/kappa

MUS_HEAVY_DIFF_FILES = $(patsubst ${MUS_HEAVY_FASTA_DIR}/%.fasta, ${MUS_HEAVY_DIFF_DIR}/%.diff,${MUS_HEAVY_FASTA_FILES})
MUS_KAPPA_DIFF_FILES = $(patsubst ${MUS_KAPPA_FASTA_DIR}/%.fasta, ${MUS_KAPPA_DIFF_DIR}/%.diff,${MUS_KAPPA_FASTA_FILES})


.PRECIOUS:${MUS_KAPPA_ANARCI_OUT_DIR}/%.out ${MUS_HEAVY_ANARCI_OUT_DIR}/%.out


test_mus: ${MUS_HEAVY_DIFF_FILES} ${MUS_KAPPA_DIFF_FILES}
	@echo "Total diff files: $(shell find diffs/mus_musculus -type f -name "*.diff" | wc -l)"
	@echo "Empty diff files: $(shell find diffs/mus_musculus -type f -name "*.diff" -empty | wc -l)"

${MUS_HEAVY_DIFF_DIR}/%.diff: ${MUS_HEAVY_ANARCI_OUT_DIR}/%.out ${MUS_HEAVY_FASTA_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@
	

${MUS_KAPPA_DIFF_DIR}/%.diff: ${MUS_KAPPA_ANARCI_OUT_DIR}/%.out ${MUS_KAPPA_FASTA_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@


${MUS_HEAVY_ANARCI_OUT_DIR}/%.out: ${MUS_HEAVY_FASTA_DIR}/%.fasta
	ANARCI -i $< | ./${MODYFIE_ANARI_OUT} >$@


${MUS_KAPPA_ANARCI_OUT_DIR}/%.out: ${MUS_KAPPA_FASTA_DIR}/%.fasta
	ANARCI -i $< | ./${MODYFIE_ANARI_OUT} >$@


clean_mus_out:
	rm -rf ${MUS_HEAVY_ANARCI_OUT_DIR}/*.diff
	rm -rf ${MUS_KAPPA_ANARCI_OUT_DIR}/*.diff


clean_mus_diffs:
	rm -rf ${MUS_HEAVY_DIFF_DIR}/*.diff
	rm -rf ${MUS_KAPPA_DIFF_DIR}/*.diff	


