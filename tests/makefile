MAKEFLAGS += --no-print-directory
## Roor Dirs
DATA_DIR = data
ANARCI_OUTPUT_DIR = outputsAnarci
DIFFS_DIR = diffs
SCRIPTS = scripts
RAW_DATA_DIR = raw_data
TEST_CASES_DIR = test_cases
## Dir Names Sets
RAW_DATA_DIRS_NAMES = fasta sampled_fasta
SPECIES = homo_sapiens mus_musculus
CHAINS = heavy kappa lambda
TEST_CASES = imgt_numbering kabat_convertation chothia_convertation
## Dirs in dirs generators
CHAINS_DATA_DIRS = $(foreach chain, $(CHAINS), $(foreach sp, $(SPECIES), $(DATA_DIR)/$(sp)/$(chain)))
CHAINS_ANARCI_OUTPUT_DIRS = $(foreach test_case,$(TEST_CASES), $(foreach chain, $(CHAINS), $(foreach sp, $(SPECIES), $(TEST_CASES_DIR)/$(test_case)/$(ANARCI_OUTPUT_DIR)/$(sp)/$(chain))))
CHAINS_DIFFS_DIRS = $(foreach test_case,$(TEST_CASES), $(foreach chain, $(CHAINS), $(foreach sp, $(SPECIES), $(TEST_CASES_DIR)/$(test_case)/$(DIFFS_DIR)/$(sp)/$(chain))))
CHAINS_RAW_DATA_DIRS = $(foreach dir_name, $(RAW_DATA_DIRS_NAMES), $(foreach sp, $(SPECIES), $(RAW_DATA_DIR)/$(sp)/$(dir_name)))

ALL_DIRS = ${DATA_DIR} ${CHAINS_DATA_DIRS} ${CHAINS_ANARCI_OUTPUT_DIRS} ${CHAINS_DIFFS_DIRS} ${CHAINS_RAW_DATA_DIRS}

generate_dirs:
	mkdir -p ${ALL_DIRS}

#---------------------------------------------------------------------------------------------------------------------------------
## Constants
SEQ_N = 500

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
HOMO_SORTED_FASTA_FILES = $(foreach file_name, $(SORTED_FASTA_FILES_NAMES), $(RAW_DATA_DIR)/homo_sapiens/fasta/$(file_name).fasta)
MUS_SORTED_FASTA_FILES = $(foreach file_name, $(SORTED_FASTA_FILES_NAMES), $(RAW_DATA_DIR)/mus_musculus/fasta/$(file_name).fasta)
SORTED_FASTA_FILES = ${HOMO_SORTED_FASTA_FILES} ${MUS_SORTED_FASTA_FILES}

HOMO_SAMPLED_FASTA_FILES = $(foreach file_name, $(SORTED_FASTA_FILES_NAMES), $(RAW_DATA_DIR)/homo_sapiens/sampled_fasta/$(file_name).fasta)
MUS_SAMPLED_FASTA_FILES = $(foreach file_name, $(SORTED_FASTA_FILES_NAMES), $(RAW_DATA_DIR)/mus_musculus/sampled_fasta/$(file_name).fasta)
SAMPLED_FASTA_FILES = ${HOMO_SAMPLED_FASTA_FILES} ${MUS_SAMPLED_FASTA_FILES}


prepare_data: ${SAMPLED_FASTA_FILES}
	@for sp in $(SPECIES); do \
	    ./${SPLIT_FASTA} $(RAW_DATA_DIR)/$$sp/sampled_fasta/IGH.fasta $(DATA_DIR)/$$sp/heavy; \
	    ./${SPLIT_FASTA} $(RAW_DATA_DIR)/$$sp/sampled_fasta/IGL.fasta $(DATA_DIR)/$$sp/lambda; \
	    ./${SPLIT_FASTA} $(RAW_DATA_DIR)/$$sp/sampled_fasta/IGK.fasta $(DATA_DIR)/$$sp/kappa; \
	done

$(RAW_DATA_DIR)/homo_sapiens/sampled_fasta/%.fasta: $(RAW_DATA_DIR)/homo_sapiens/fasta/%.fasta
	seqkit sample -n ${SEQ_N} -w 0 -o $@ $<

$(RAW_DATA_DIR)/mus_musculus/sampled_fasta/%.fasta: $(RAW_DATA_DIR)/mus_musculus/fasta/%.fasta
	seqkit sample -n ${SEQ_N} -w 0 -o $@ $<


${HOMO_SORTED_FASTA_FILES}: ${ALL_SEQ_FILE}
	./${GREP_ANTOBODIES} ${RAW_DATA_DIR}/homo_sapiens/anotation_file.tsv ${ALL_SEQ_FILE} ${RAW_DATA_DIR}/homo_sapiens/fasta
	
${MUS_SORTED_FASTA_FILES}: ${ALL_SEQ_FILE}
	./${GREP_ANTOBODIES} ${RAW_DATA_DIR}/mus_musculus/anotation_file.tsv ${ALL_SEQ_FILE} ${RAW_DATA_DIR}/mus_musculus/fasta


clean_sampled_fasta:
	rm -rf $(RAW_DATA_DIR)/mus_musculus/sampled_fasta/*
	rm -rf $(RAW_DATA_DIR)/homo_sapiens/sampled_fasta/*

clean_data:
	rm -rf $(DATA_DIR)/homo_sapiens/heavy/*
	rm -rf $(DATA_DIR)/homo_sapiens/lambda/*
	rm -rf $(DATA_DIR)/homo_sapiens/kappa/*
	rm -rf $(DATA_DIR)/mus_musculus/heavy/*
	rm -rf $(DATA_DIR)/mus_musculus/lambda/*
	rm -rf $(DATA_DIR)/mus_musculus/kappa/*

${ALL_SEQ_FILE}:
	wget -O $@ ${SEQ_FROM_PDB_LINK}
#---------------------------------------------------------------------------------------------------------------------------------
.PHONY: test_all


clean_all_diffs:
	@$(MAKE) -C test_cases/imgt_numbering clean_all_diffs
	@$(MAKE) -C test_cases/kabat_convertation clean_all_diffs
	@$(MAKE) -C test_cases/chothia_convertation clean_all_diffs

distclean_all:
	@$(MAKE) -C test_cases/imgt_numbering distclean_homo
	@$(MAKE) -C test_cases/imgt_numbering distclean_mus
	@$(MAKE) -C test_cases/kabat_convertation distclean_homo
	@$(MAKE) -C test_cases/kabat_convertation distclean_mus
	@$(MAKE) -C test_cases/chothia_convertation distclean_homo
	@$(MAKE) -C test_cases/chothia_convertation distclean_mus

test_all:
	@$(MAKE) -C test_cases/imgt_numbering test_all
	@$(MAKE) -C test_cases/kabat_convertation test_all
	@$(MAKE) -C test_cases/chothia_convertation test_all



