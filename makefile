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
HMMS_DIR = hmms
SCRIPTS_HMM_PREPARE = ${SCRIPTS}/hmms_prepare
SCRIPTS_OUT_HMM_PREPARE = ${SCRIPTS_OUTPUT}/hmms_prepare
COMBINED_HMM = ${HMMS_DIR}/IG_combined.hmm

AVAILABLE_ORGANISMS = homo_sapiens  mus_muluscus

prepare_hmm_data_base: ${COMBINED_HMM}


${COMBINED_HMM}: prepare_homo_sapiens_hmm prepare_mus_muluscus_hmm
	cat $(foreach org, $(AVAILABLE_ORGANISMS), $(HMMS_DIR)/$(org)/*) > $@; \
	hmmpress $@;


clean_combined_hmm:
	rm ${COMBINED_HMM}*
	

distclean_all_hmm:
	$(MAKE) clean_combined_hmm
	$(MAKE) distclean_homo
	$(MAKE) distclean_mus

### Scripts
COMBINE = ${SCRIPTS_HMM_PREPARE}/combine_VJ
TRANSLATE = ${SCRIPTS_HMM_PREPARE}/translateGenes
CONVERT_TO_STOCKHOLM = ${SCRIPTS_HMM_PREPARE}/stockholmConverter

HMM_DIRS = ${HMMS_DIR} ${SCRIPTS_OUT_HMM_PREPARE} ${SCRIPTS_HMM_PREPARE} ${HMM_HOMO_DIRS} ${HMM_MUS_DIRS}


HMM_HOMO_DIRS = ${VARIABLE_HOMO} ${JOINING_HOMO} ${PROT_FASTA_VARIABLE_HOMO} ${NUC_FASTA_VARIABLE_HOMO} ${NUC_FASTA_JOININGS_HOMO} ${PROT_FASTA_JOININGS_HOMO} ${COMBINED_DIR_HOMO} ${TRANSLATE_INFO_J_DIR_HOMO} ${TRANSLATE_INFO_V_DIR_HOMO} ${STOCKHOLM_DIR_HOMO} ${HMM_HOMO_DIR} ${HMMS_DIR_HOMO}

HMMS_DIR_HOMO = ${HMMS_DIR}/homo_sapiens
HMM_HOMO_DIR = ${SCRIPTS_OUT_HMM_PREPARE}/homo_sapiens
COMBINED_DIR_HOMO = ${HMM_HOMO_DIR}/combined

VARIABLE_HOMO = ${HMM_HOMO_DIR}/variable
JOINING_HOMO = ${HMM_HOMO_DIR}/joinings

STOCKHOLM_DIR_HOMO = ${HMM_HOMO_DIR}/stockholm

## Links----------------------------------------------------------------------------------------------------------
OGRDB_H_HOMO = https://ogrdb.airr-community.org/api/germline/set/Human/IGH_VDJ/published/gapped_ex
OGRDB_K_HOMO = https://ogrdb.airr-community.org/api/germline/set/Human/IGKappa_VJ/published/gapped_ex
OGRDB_L_HOMO = https://ogrdb.airr-community.org/api/germline/set/Human/IGLambda_VJ/published/gapped_ex
## Fasta files----------------------------------------------------------------------------------------------------
TRANSLATE_INFO_J_DIR_HOMO = ${JOINING_HOMO}/translate_info
TRANSLATE_INFO_V_DIR_HOMO = ${VARIABLE_HOMO}/translate_info

PROT_FASTA_JOININGS_HOMO = ${JOINING_HOMO}/prot
NUC_FASTA_JOININGS_HOMO = ${JOINING_HOMO}/nuc

PROT_FASTA_VARIABLE_HOMO = ${VARIABLE_HOMO}/prot
NUC_FASTA_VARIABLE_HOMO = ${VARIABLE_HOMO}/nuc

IGHV_NUC_FASTA_HOMO = ${NUC_FASTA_VARIABLE_HOMO}/IGH.fasta
IGHJ_NUC_FASTA_HOMO = ${NUC_FASTA_JOININGS_HOMO}/IGH.fasta

IGLV_NUC_FASTA_HOMO = ${NUC_FASTA_VARIABLE_HOMO}/IGL.fasta
IGLJ_NUC_FASTA_HOMO = ${NUC_FASTA_JOININGS_HOMO}/IGL.fasta

IGKV_NUC_FASTA_HOMO = ${NUC_FASTA_VARIABLE_HOMO}/IGK.fasta
IGKJ_NUC_FASTA_HOMO = ${NUC_FASTA_JOININGS_HOMO}/IGK.fasta

IGJ_NUC_FILES_HOMO = ${IGHJ_NUC_FASTA_HOMO} ${IGLJ_NUC_FASTA_HOMO} ${IGKJ_NUC_FASTA_HOMO}
IGV_NUC_FILES_HOMO = ${IGHV_NUC_FASTA_HOMO} ${IGLV_NUC_FASTA_HOMO} ${IGKV_NUC_FASTA_HOMO}

PROT_IGJ_HOMO = $(patsubst ${NUC_FASTA_JOININGS_HOMO}/%.fasta,${PROT_FASTA_JOININGS_HOMO}/%.fasta,${IGJ_NUC_FILES_HOMO})
PROT_IGV_HOMO = $(patsubst ${NUC_FASTA_VARIABLE_HOMO}/%.fasta,${PROT_FASTA_VARIABLE_HOMO}/%.fasta,${IGV_NUC_FILES_HOMO})

## Combined Files ------------------------------------------------------------------------------------------
COMBINED_H_HOMO = ${COMBINED_DIR_HOMO}/IGH.fasta
COMBINED_K_HOMO = ${COMBINED_DIR_HOMO}/IGK.fasta
COMBINED_L_HOMO = ${COMBINED_DIR_HOMO}/IGL.fasta
COMBINED_FILES_HOMO = ${COMBINED_L_HOMO} ${COMBINED_K_HOMO} ${COMBINED_H_HOMO}

##  Stockholm Files ----------------------------------------------------------------------------------------
STOCKHOLM_FILES_HOMO = $(patsubst ${COMBINED_DIR_HOMO}/%.fasta, ${STOCKHOLM_DIR_HOMO}/%.stockholm,${COMBINED_FILES_HOMO})
## HMMs ----------------------------------------------------------------------------------------------------
HMMS_HOMO = $(patsubst ${STOCKHOLM_DIR_HOMO}/%.stockholm, ${HMMS_DIR_HOMO}/%.hmm,${STOCKHOLM_FILES_HOMO})

prepare_homo_sapiens_hmm: ${HMMS_HOMO}
	

${HMMS_DIR_HOMO}/%.hmm: ${STOCKHOLM_DIR_HOMO}/%.stockholm
	hmmbuild -n homo_sapiens_$* --hand $@ $<

${STOCKHOLM_DIR_HOMO}/%.stockholm: ${COMBINED_DIR_HOMO}/%.fasta
	./${CONVERT_TO_STOCKHOLM} $< >$@

${COMBINED_DIR_HOMO}/%.fasta: ${PROT_FASTA_VARIABLE_HOMO}/%.fasta ${PROT_FASTA_JOININGS_HOMO}/%.fasta
	./${COMBINE} $< $(word 2,$^) >$@


${PROT_FASTA_VARIABLE_HOMO}/%.fasta: ${NUC_FASTA_VARIABLE_HOMO}/%.fasta ${TRANSLATE_INFO_V_DIR_HOMO}/%.info
	./${TRANSLATE} $< $(word 2,$^) > $@

${PROT_FASTA_JOININGS_HOMO}/%.fasta: ${NUC_FASTA_JOININGS_HOMO}/%.fasta ${TRANSLATE_INFO_J_DIR_HOMO}/%.info
	./${TRANSLATE} $< $(word 2,$^) > $@



${STOCKHOLM_FILES_HOMO}: ${COMBINED_FILES_HOMO}

${COMBINED_FILES_HOMO}: ${PROT_IGV_HOMO} ${PROT_IGJ_HOMO}

${IGHV_NUC_FASTA_HOMO}:
	curl -s ${OGRDB_H_HOMO} | grep -A 6 '^>IGHV' > $@
	
${IGHJ_NUC_FASTA_HOMO}:
	curl -s ${OGRDB_H_HOMO} | grep -A 2 '^>IGHJ' > $@
	
${IGLV_NUC_FASTA_HOMO}:
	curl -s ${OGRDB_L_HOMO} | grep -A 6 '^>IGLV' > $@
	
${IGLJ_NUC_FASTA_HOMO}:
	curl -s ${OGRDB_L_HOMO} | grep -A 1 '^>IGLJ' > $@

${IGKV_NUC_FASTA_HOMO}:
	curl -s ${OGRDB_K_HOMO} | grep -A 6 '^>IGKV' > $@
	
${IGKJ_NUC_FASTA_HOMO}:
	curl -s ${OGRDB_K_HOMO} | grep -A 1 '^>IGKJ' > $@


clean_homo_port:
	rm -rf ${PROT_IGV_HOMO} ${PROT_IGJ_HOMO}


clean_homo_combined:
	rm -rf ${COMBINED_FILES_HOMO}


clean_homo_stockholm:
	rm -rf ${STOCKHOLM_FILES_HOMO}


clean_homo_hmms:
	rm -rf ${HMMS_HOMO}
	

distclean_homo:
	$(MAKE) clean_homo_port
	$(MAKE) clean_homo_combined
	$(MAKE) clean_homo_stockholm
	$(MAKE) clean_homo_hmms

#--------------------------------------------------------------------------------------------------------

HMM_MUS_DIRS = ${VARIABLE_MUS} ${JOINING_MUS} ${PROT_FASTA_VARIABLE_MUS} ${NUC_FASTA_VARIABLE_MUS} ${PROT_FASTA_JOININGS_MUS} ${NUC_FASTA_JOININGS_MUS} ${COMBINED_DIR_MUS} ${TRANSLATE_INFO_J_DIR_MUS} ${TRANSLATE_INFO_V_DIR_MUS} ${STOCKHOLM_DIR_MUS} ${HMM_OUT_MUS} ${HMMS_DIR_MUS}

VARIABLE_MUS = ${HMM_OUT_MUS}/variable
JOINING_MUS = ${HMM_OUT_MUS}/joinings

STOCKHOLM_DIR_MUS= ${HMM_OUT_MUS}/stockholm

HMMS_DIR_MUS = ${HMMS_DIR}/mus_muluscus
HMM_OUT_MUS = ${SCRIPTS_OUT_HMM_PREPARE}/mus_muluscus
COMBINED_DIR_MUS = ${HMM_OUT_MUS}/combined

TRANSLATE_INFO_J_DIR_MUS = ${JOINING_MUS}/translate_info
TRANSLATE_INFO_V_DIR_MUS = ${VARIABLE_MUS}/translate_info

PROT_FASTA_JOININGS_MUS = ${JOINING_MUS}/prot
NUC_FASTA_JOININGS_MUS = ${JOINING_MUS}/nuc

PROT_FASTA_VARIABLE_MUS = ${VARIABLE_MUS}/prot
NUC_FASTA_VARIABLE_MUS = ${VARIABLE_MUS}/nuc

IGHV_NUC_FASTA_MUS = ${NUC_FASTA_VARIABLE_MUS}/IGH.fasta
IGHJ_NUC_FASTA_MUS = ${NUC_FASTA_JOININGS_MUS}/IGH.fasta

IGLV_NUC_FASTA_MUS = ${NUC_FASTA_VARIABLE_MUS}/IGL.fasta
IGLJ_NUC_FASTA_MUS = ${NUC_FASTA_JOININGS_MUS}/IGL.fasta

IGKV_NUC_FASTA_MUS = ${NUC_FASTA_VARIABLE_MUS}/IGK.fasta
IGKJ_NUC_FASTA_MUS = ${NUC_FASTA_JOININGS_MUS}/IGK.fasta

IGJ_NUC_FILES_MUS = ${IGHJ_NUC_FASTA_MUS} ${IGKJ_NUC_FASTA_MUS}
IGV_NUC_FILES_MUS = ${IGHV_NUC_FASTA_MUS} ${IGKV_NUC_FASTA_MUS}

PROT_IGJ_MUS = $(patsubst ${NUC_FASTA_JOININGS_MUS}/%.fasta,${PROT_FASTA_JOININGS_MUS}/%.fasta,${IGJ_NUC_FILES_MUS})
PROT_IGV_MUS = $(patsubst ${NUC_FASTA_VARIABLE_MUS}/%.fasta,${PROT_FASTA_VARIABLE_MUS}/%.fasta,${IGV_NUC_FILES_MUS})

COMBINED_H_MUS = ${COMBINED_DIR_MUS}/IGH.fasta
COMBINED_K_MUS = ${COMBINED_DIR_MUS}/IGK.fasta
COMBINED_L_MUS = ${COMBINED_DIR_MUS}/IGL.fasta
COMBINED_FILES_MUS = ${COMBINED_K_MUS} ${COMBINED_H_MUS}

##  Stockholm Files ----------------------------------------------------------------------------------------
STOCKHOLM_FILES_MUS = $(patsubst ${COMBINED_DIR_MUS}/%.fasta, ${STOCKHOLM_DIR_MUS}/%.stockholm,${COMBINED_FILES_MUS})
## HMMs ----------------------------------------------------------------------------------------------------
HMMS_MUS = $(patsubst ${STOCKHOLM_DIR_MUS}/%.stockholm, ${HMMS_DIR_MUS}/%.hmm,${STOCKHOLM_FILES_MUS})


prepare_mus_muluscus_hmm: ${HMMS_MUS}


${HMMS_DIR_MUS}/%.hmm: ${STOCKHOLM_DIR_MUS}/%.stockholm
	hmmbuild --hand -n mus_muluscus_$* $@ $<


${STOCKHOLM_DIR_MUS}/%.stockholm: ${COMBINED_DIR_MUS}/%.fasta
	./${CONVERT_TO_STOCKHOLM} $< >$@


${COMBINED_DIR_MUS}/%.fasta: ${PROT_FASTA_VARIABLE_MUS}/%.fasta ${PROT_FASTA_JOININGS_MUS}/%.fasta
	./${COMBINE} $< $(word 2,$^) >$@


${PROT_FASTA_VARIABLE_MUS}/%.fasta: ${NUC_FASTA_VARIABLE_MUS}/%.fasta ${TRANSLATE_INFO_V_DIR_MUS}/%.info
	./${TRANSLATE} $< $(word 2,$^) > $@


${PROT_FASTA_JOININGS_MUS}/%.fasta: ${NUC_FASTA_JOININGS_MUS}/%.fasta ${TRANSLATE_INFO_J_DIR_MUS}/%.info
	./${TRANSLATE} $< $(word 2,$^) > $@


${STOCKHOLM_FILES_MUS}: ${COMBINED_FILES_MUS}


${COMBINED_FILES_MUS}: ${PROT_IGV_MUS} ${PROT_IGJ_MUS}


clean_mus_port:
	rm -rf ${PROT_IGV_MUS} ${PROT_IGJ_MUS}


clean_mus_combined:
	rm -rf ${COMBINED_FILES_MUS}


clean_mus_stockholm:
	rm -rf ${STOCKHOLM_FILES_MUS}


clean_mus_hmms:
	rm -rf ${HMMS_MUS}
	

distclean_mus:
	$(MAKE) clean_mus_port
	$(MAKE) clean_mus_combined
	$(MAKE) clean_mus_stockholm
	$(MAKE) clean_mus_hmms
	

