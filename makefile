SHELL := /bin/bash
CURRENT_DIR := $(shell pwd)
PERL5LIB := ${CURRENT_DIR}/modules/
export PERL5LIB
# Dirs ###
DATA = data
LOG  = logs
MODULES = modules
SCRIPTS = scripts
SCRIPTS_OUTPUT = scripts_out

${COMBINED_L}:
# Prepare Data-------------------------------------------------------------------------------------------------------------------
## DIRS
DATA_PREPARATION = ${SCRIPTS_OUTPUT}/dataPreparation
PDB_DATA_PREPARATION = ${DATA_PREPARATION}/PDB
FASTA_DATA_PREPARATION = ${DATA_PREPARATION}/fasta
ID_DATA_PREPARATION = ${DATA_PREPARATION}/id
HMM_HITS_DATA_PREPARATION = ${DATA_PREPARATION}/hmm_hits
SCRIPTS_DATA_PREPARATION = ${SCRIPTS}/dataPreparation
ALIGMENTS_DATA_PREPARATION = ${DATA_PREPARATION}/aligments
## Links
PDB_LINK = http://www.rcsb.org/pdb/files
SEQ_FROM_PDB_LINK = https://files.wwpdb.org/pub/pdb/derived_data
ANOTATION_FILE_LINK = https://opig.stats.ox.ac.uk/webapps/sabdab-sabpred/sabdab/summary/20241204_0717218/
## Files
PDB_SEQ_FILE = ${PDB_DATA_PREPARATION}/pdb_seqres.txt.gz
ANTIBODIES_ID = ${PDB_DATA_PREPARATION}/PDB_antibodies.id
ANOTATION_FILE = ${PDB_DATA_PREPARATION}/SAbDab_anotation.tsv

RAW_HEAVY_CHAINS_ID = ${ID_DATA_PREPARATION}/raw_heavy.id
RAW_LIGHT_CHAINS_ID = ${ID_DATA_PREPARATION}/raw_light.id
SHARED_IDS = ${ID_DATA_PREPARATION}/shared.id
HEAVY_CHAINS_ID = ${ID_DATA_PREPARATION}/heavy_chains.id
LIGHT_CHAINS_ID = ${ID_DATA_PREPARATION}/light_chains.id

EXTRACTED_HEAVY_CHAINS = ${FASTA_DATA_PREPARATION}/heavy_chains.fasta
EXTRACTED_LIGHT_CHAINS = ${FASTA_DATA_PREPARATION}/light_chains.fasta

HITS_TO_TRIM_HEAVY = ${HMM_HITS_DATA_PREPARATION}/hits_heavy.txt
HITS_TO_TRIM_LIGHT = ${HMM_HITS_DATA_PREPARATION}/hits_light.txt

TRIMMED_J_HEAVY_CHAINS = ${FASTA_DATA_PREPARATION}/heavy_chains_trimmed_j.fasta
TRIMMED_J_LIGHT_CHAINS = ${FASTA_DATA_PREPARATION}/light_chains_trimmed_j.fasta
## Scripts
FIND_ANTIBODIES_SEQ = ${SCRIPTS_DATA_PREPARATION}/findAntibodies
DOWNLOAD_FILE = ${SCRIPTS_DATA_PREPARATION}/byLinkDownload
SORT_BY_CHAIN_TYPE = ${SCRIPTS_DATA_PREPARATION}/sortByChainType
TRIM_SHARED_IDS = ${SCRIPTS_DATA_PREPARATION}/trimSharedIds
TRIM_BY_HITS = ${SCRIPTS_DATA_PREPARATION}/trimSeqByHits

prepare_data: ${TRIMMED_J_HEAVY_CHAINS}

${TRIMMED_J_HEAVY_CHAINS}: ${EXTRACTED_HEAVY_CHAINS} ${HITS_TO_TRIM_HEAVY}
	./${TRIM_BY_HITS} $<  $(word 2,$^) > $@

${HITS_TO_TRIM_HEAVY}: ${EXTRACTED_HEAVY_CHAINS}
	hmmsearch -T 1 --domtblout $@ ${IGHJ_HMM} $<

${EXTRACTED_HEAVY_CHAINS}: ${HEAVY_CHAINS_ID}
	./${FIND_ANTIBODIES_SEQ} ${PDB_SEQ_FILE} $< >$@

${EXTRACTED_LIGHT_CHAINS}: ${LIGHT_CHAINS_ID}
	./${FIND_ANTIBODIES_SEQ} ${PDB_SEQ_FILE} $< >$@

${HEAVY_CHAINS_ID}: ${SHARED_IDS} ${RAW_HEAVY_CHAINS_ID}
	./${TRIM_SHARED_IDS} $(word 2,$^) $< > $@

${LIGHT_CHAINS_ID}: ${SHARED_IDS} ${RAW_LIGHT_CHAINS_ID}
	./${TRIM_SHARED_IDS} $(word 2,$^) $< > $@

${SHARED_IDS}: ${RAW_HEAVY_CHAINS_ID} ${RAW_LIGHT_CHAINS_ID}
	 comm -12 <(sort $<) <(sort $(word 2,$^)) > $@

${RAW_HEAVY_CHAINS_ID}: ${ANOTATION_FILE}
	./${SORT_BY_CHAIN_TYPE} $< "heavy" > $@
	
${RAW_LIGHT_CHAINS_ID}: ${ANOTATION_FILE}
	./${SORT_BY_CHAIN_TYPE} $< "light" > $@

${EXTRACTED_ANTIBODIES}: ${PDB_SEQ_FILE} ${ANTIBODIES_ID}
	./${FIND_ANTIBODIES_SEQ} ${PDB_SEQ_FILE} ${ANTIBODIES_ID} > $@

${PDB_SEQ_FILE}:
	./${DOWNLOAD_FILE} ${PDB_DATA_PREPARATION} ${PDB_DATA_PREPARATION} ${SEQ_FROM_PDB_LINK} $(@F)

${ANOTATION_FILE}:
	wget -o $@.log -O $@ --content-disposition ${ANOTATION_FILE_LINK}

# Prepare dirs -------------------------------------------------------------------------------------------------------------
DIRS = $(DATA) $(LOG) $(MODULES) $(SCRIPTS) $(SCRIPTS_OUTPUT) ${DATA_PREPARATION} ${PDB_DATA_PREPARATION} ${FASTA_DATA_PREPARATION} ${ID_DATA_PREPARATION} ${HMM_HITS_DATA_PREPARATION} ${ALIGMENTS_DATA_PREPARATION} ${HMM_DIRS}

prepare_dirs:
	mkdir -p ${DIRS}


# Prepare hmms
## Dirs ------------------------------------------------------------------------------------------------------------
HMM_DIRS = ${VARIABLE} ${JOINING} ${FASTA_JOININGS} ${FASTA_VARIABLE} ${PROT_FASTA_JOININGS} ${NUC_FASTA_JOININGS} ${PROT_FASTA_VARIABLE} ${NUC_FASTA_VARIABLE} ${VARIABLE_HMMS} ${JOINING_HMMS} ${SCRIPTS_HMM_PREPARE} ${SCRIPTS_OUT_HMM_PREPARE} ${COMBINED_DIR} ${TRANSLATE_INFO_J_DIR} ${TRANSLATE_INFO_V_DIR} ${STOCKHOLM_DIR} ${HMMS_DIR}


SCRIPTS_HMM_PREPARE = ${SCRIPTS}/hmms_prepare
SCRIPTS_OUT_HMM_PREPARE = ${SCRIPTS_OUTPUT}/hmms_prepare
COMBINED_DIR = ${SCRIPTS_OUT_HMM_PREPARE}/combined

VARIABLE = ${SCRIPTS_OUT_HMM_PREPARE}/variable
JOINING = ${SCRIPTS_OUT_HMM_PREPARE}/joinings

STOCKHOLM_DIR = ${SCRIPTS_OUT_HMM_PREPARE}/stockholm
HMMS_DIR = hmms
## Links----------------------------------------------------------------------------------------------------------
OGRDB_H = https://ogrdb.airr-community.org/api/germline/set/Human/IGH_VDJ/published/gapped_ex
OGRDB_K = https://ogrdb.airr-community.org/api/germline/set/Human/IGKappa_VJ/published/gapped_ex
OGRDB_L = https://ogrdb.airr-community.org/api/germline/set/Human/IGLambda_VJ/published/gapped_ex
## Fasta files----------------------------------------------------------------------------------------------------
FASTA_JOININGS = ${JOINING}/fasta
FASTA_VARIABLE = ${VARIABLE}/fasta
TRANSLATE_INFO_J_DIR = ${FASTA_JOININGS}/translate_info
TRANSLATE_INFO_V_DIR = ${FASTA_VARIABLE}/translate_info
PROT_FASTA_JOININGS = ${FASTA_JOININGS}/prot
NUC_FASTA_JOININGS = ${FASTA_JOININGS}/nuc

PROT_FASTA_VARIABLE = ${FASTA_VARIABLE}/prot
NUC_FASTA_VARIABLE = ${FASTA_VARIABLE}/nuc

IGHV_NUC_FASTA = ${NUC_FASTA_VARIABLE}/IGH.fasta
IGHJ_NUC_FASTA = ${NUC_FASTA_JOININGS}/IGH.fasta

IGLV_NUC_FASTA = ${NUC_FASTA_VARIABLE}/IGL.fasta
IGLJ_NUC_FASTA = ${NUC_FASTA_JOININGS}/IGL.fasta

IGKV_NUC_FASTA = ${NUC_FASTA_VARIABLE}/IGK.fasta
IGKJ_NUC_FASTA = ${NUC_FASTA_JOININGS}/IGK.fasta

IGJ_NUC_FILES = ${IGHJ_NUC_FASTA} ${IGLJ_NUC_FASTA} ${IGKJ_NUC_FASTA}
IGV_NUC_FILES = ${IGHV_NUC_FASTA} ${IGLV_NUC_FASTA} ${IGKV_NUC_FASTA}

PROT_IGJ = $(patsubst ${NUC_FASTA_JOININGS}/%.fasta,${PROT_FASTA_JOININGS}/%.fasta,${IGJ_NUC_FILES})
PROT_IGV = $(patsubst ${NUC_FASTA_VARIABLE}/%.fasta,${PROT_FASTA_VARIABLE}/%.fasta,${IGV_NUC_FILES})

## Combined Files ------------------------------------------------------------------------------------------
COMBINED_H = ${COMBINED_DIR}/IGH.fasta
COMBINED_K = ${COMBINED_DIR}/IGK.fasta
COMBINED_L = ${COMBINED_DIR}/IGL.fasta
COMBINED_FILES = ${COMBINED_L} ${COMBINED_K} ${COMBINED_H}

##  Stockholm Files ----------------------------------------------------------------------------------------
STOCKHOLM_FILES = $(patsubst ${COMBINED_DIR}/%.fasta, ${STOCKHOLM_DIR}/%.stockholm,${COMBINED_FILES})

## HMMs ----------------------------------------------------------------------------------------------------
HMMS = $(patsubst ${STOCKHOLM_DIR}/%.stockholm, ${HMMS_DIR}/%.hmm,${STOCKHOLM_FILES})
COMBINED_HMM = ${HMMS_DIR}/IG_combined.hmm
### Scripts
COMBINE = ${SCRIPTS_HMM_PREPARE}/combine_VJ
TRANSLATE = ${SCRIPTS_HMM_PREPARE}/translateGenes
CONVERT_TO_STOCKHOLM = ${SCRIPTS_HMM_PREPARE}/stockholmConverter

update_hmms: ${COMBINED_HMM} ${HMMS}
	

${COMBINED_HMM}: ${HMMS}
	cat $^ > $@; \
	hmmpress $@;

${HMMS_DIR}/%.hmm: ${STOCKHOLM_DIR}/%.stockholm
	hmmbuild --hand $@ $<

${STOCKHOLM_DIR}/%.stockholm: ${COMBINED_DIR}/%.fasta
	./${CONVERT_TO_STOCKHOLM} $< >$@

${COMBINED_DIR}/%.fasta: ${PROT_FASTA_VARIABLE}/%.fasta ${PROT_FASTA_JOININGS}/%.fasta
	./${COMBINE} $< $(word 2,$^) >$@


${PROT_FASTA_VARIABLE}/%.fasta: ${NUC_FASTA_VARIABLE}/%.fasta ${TRANSLATE_INFO_V_DIR}/%.info
	./${TRANSLATE} $< $(word 2,$^) > $@

${PROT_FASTA_JOININGS}/%.fasta: ${NUC_FASTA_JOININGS}/%.fasta ${TRANSLATE_INFO_J_DIR}/%.info
	./${TRANSLATE} $< $(word 2,$^) > $@



${STOCKHOLM_FILES}: ${COMBINED_FILES}
	
${COMBINED_FILES}: ${PROT_IGV} ${PROT_IGJ}

${IGHV_NUC_FASTA}:
	curl -s ${OGRDB_H} | grep -A 6 '^>IGHV' > $@
	
${IGHJ_NUC_FASTA}:
	curl -s ${OGRDB_H} | grep -A 2 '^>IGHJ' > $@
	
${IGLV_NUC_FASTA}:
	curl -s ${OGRDB_L} | grep -A 6 '^>IGLV' > $@
	
${IGLJ_NUC_FASTA}:
	curl -s ${OGRDB_L} | grep -A 1 '^>IGLJ' > $@

${IGKV_NUC_FASTA}:
	curl -s ${OGRDB_K} | grep -A 6 '^>IGKV' > $@
	
${IGKJ_NUC_FASTA}:
	curl -s ${OGRDB_K} | grep -A 1 '^>IGKJ' > $@

#--------------------------------------------------------------------------------------------------------


