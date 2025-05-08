## Roor Dirs
DATA_DIR = data
SCRIPTS = scripts
RAW_DATA_DIR = raw_data
DIFF_DIR = diffs
PDB_NUMBERING_DIR = pdb_numbering
ANARCI_DIFF_DIR = anarci_diff
## Dir Names Sets
SPECIES = homo_sapiens mus_musculus
CHAINS = heavy light
NUMBERING_SCHEMES = kabat chothia unknown
RAW_DATA_DIR_TYPES = id pdb
CHAINS_RAW_DATA_DIRS = $(foreach sp, $(SPECIES), $(foreach dir, $(RAW_DATA_DIR_TYPES), $(RAW_DATA_DIR)/$(sp)/$(dir)/))
CHAINS_DATA_DIRS = $(foreach sh, $(NUMBERING_SCHEMES), $(foreach chain, $(CHAINS), $(foreach sp, $(SPECIES), $(DATA_DIR)/$(sp)/$(sh)/$(chain))))
CHAINS_DIFF_DIRS = $(foreach sh, $(NUMBERING_SCHEMES), $(foreach chain, $(CHAINS), $(foreach sp, $(SPECIES), $(DIFF_DIR)/$(sp)/$(sh)/$(chain))))
CHAINS_PDB_NUMBERING_DIRS = $(foreach sh, $(NUMBERING_SCHEMES), $(foreach chain, $(CHAINS), $(foreach sp, $(SPECIES), $(PDB_NUMBERING_DIR)/$(sp)/$(sh)/$(chain))))

ANACRI_DIFF_DIRS = $(foreach sh, $(NUMBERING_SCHEMES), $(foreach chain, $(CHAINS), $(foreach sp, $(SPECIES), $(ANARCI_DIFF_DIR)/$(sp)/$(sh)/$(chain))))

ALL_DIRS = ${DATA_DIR} ${CHAINS_DATA_DIRS} ${DIFF_DIR} ${CHAINS_DIFF_DIRS} ${RAW_DATA_DIR} ${SCRIPTS} ${CHAINS_RAW_DATA_DIRS} ${PDB_NUMBERING_DIR} ${CHAINS_PDB_NUMBERING_DIRS} ${ANARCI_DIFF_DIR} ${ANACRI_DIFF_DIRS}

generate_dirs:
	mkdir -p ${ALL_DIRS}
	

#-------------------------------------------------------------------------------------------------------------------------------------------------
## Scripts
PDB_SELECTOR = ${SCRIPTS}/pdbSelector
PDB_DOWNLOADER = ${SCRIPTS}/PDB_downloader
SHEME_SORT = ${SCRIPTS}/schemeSort
NUMBERING_2_FASTA = ${SCRIPTS}/numbering2fasta

#-------------------------------------------------------------------------------------------------------------------------
## Id Files Number
SEQ_N = 2000

## Annotation Files
HOMO_ANNOTATION = ${RAW_DATA_DIR}/homo_sapiens/anotation_file.tsv
MUS_ANNOTATION = ${RAW_DATA_DIR}/mus_musculus/anotation_file.tsv

## ID Dirs 
HOMO_ID_DIR = ${RAW_DATA_DIR}/homo_sapiens/id
MUS_ID_DIR = ${RAW_DATA_DIR}/mus_musculus/id

# ID Files
HOMO_IDS := $(wildcard ${HOMO_ID_DIR}/*.id)
MUS_IDS := $(wildcard ${MUS_ID_DIR}/*.id)

generate_raw_data_ids:
	./${PDB_SELECTOR} -i ${MUS_ANNOTATION} -n ${SEQ_N} -o ${MUS_ID_DIR}
	./${PDB_SELECTOR} -i ${HOMO_ANNOTATION} -n ${SEQ_N} -o ${HOMO_ID_DIR}


clean_ids:
	rm -rf ${HOMO_ID_DIR}/*
	rm -rf ${MUS_ID_DIR}/*


#--------------------------------------------------------------------------------------------------------------------------
# PDB dirs
HOMO_PDB_DIR = ${RAW_DATA_DIR}/homo_sapiens/pdb
MUS_PDB_DIR = ${RAW_DATA_DIR}/mus_musculus/pdb
# PDB Files
HOMO_PDB = $(patsubst ${HOMO_ID_DIR}/%.id, ${HOMO_PDB_DIR}/%.pdb.gz, ${HOMO_IDS})
MUS_PDB = $(patsubst ${MUS_ID_DIR}/%.id, ${MUS_PDB_DIR}/%.pdb.gz, ${MUS_IDS})

prepare_raw_data: ${HOMO_PDB} ${MUS_PDB}


${HOMO_PDB_DIR}/%.pdb.gz: ${HOMO_ID_DIR}/%.id
	./${PDB_DOWNLOADER} $< ${HOMO_PDB_DIR}


${MUS_PDB_DIR}/%.pdb.gz: ${MUS_ID_DIR}/%.id
	./${PDB_DOWNLOADER} $< ${MUS_PDB_DIR}

#----------------------------------------------------------------------------------------------------------------------------------------
# Numbering Dirs
HOMO_NUMBERING_KABAT_DIR = ${PDB_NUMBERING_DIR}/homo_sapiens/kabat
HOMO_NUMBERING_UNKNOWN_DIR = ${PDB_NUMBERING_DIR}/homo_sapiens/unknown
# PDB numbering
HOMO_NUMBERING_KABAT_LIGHT = $(wildcard ${HOMO_NUMBERING_KABAT_DIR}/light/*.out)
HOMO_NUMBERING_KABAT_HEAVY = $(wildcard ${HOMO_NUMBERING_KABAT_DIR}/heavy/*.out)
HOMO_NUMBERING_UNKNOWN_LIGHT = $(wildcard ${HOMO_NUMBERING_UNKNOWN_DIR}/light/*.out)
HOMO_NUMBERING_UNKNOWN_HEAVY = $(wildcard ${HOMO_NUMBERING_UNKNOWN_DIR}/heavy/*.out)
NUBERING_FILES = ${HOMO_NUMBERING_KABAT_LIGHT}, ${HOMO_NUMBERING_KABAT_HEAVY}, ${HOMO_NUMBERING_UNKNOWN_LIGHT}, ${HOMO_NUMBERING_UNKNOWN_HEAVY}
prepare_numbering: prepare_numbering_mus prepare_numbering_homo
	

prepare_numbering_homo:
	@ls -1 $(HOMO_PDB_DIR) | while read pdb; do \
	  id_name=$$(basename $$pdb .pdb.gz).id; \
	  id_file=$(HOMO_ID_DIR)/$$id_name; \
	  echo "Processing $$pdb and $$id_file"; \
	  ./${SHEME_SORT} --id_file $$id_file -i $(HOMO_PDB_DIR)/$$pdb --out_dir ${PDB_NUMBERING_DIR}/homo_sapiens; \
	done

prepare_numbering_mus:
	@ls -1 $(MUS_PDB_DIR) | while read pdb; do \
	  id_name=$$(basename $$pdb .pdb.gz).id; \
	  id_file=$(MUS_ID_DIR)/$$id_name; \
	  echo "Processing $$pdb and $$id_file"; \
	  ./${SHEME_SORT} --id_file $$id_file -i $(MUS_PDB_DIR)/$$pdb --out_dir ${PDB_NUMBERING_DIR}/mus_musculus; \
	done

clean_numbering:
	rm -rf ${NUBERING_FILES}
#------------------------------------------------------------------------------------------------------------------------------------------------------------
#Fasta Dirs
HOMO_FASTA_KABAT_DIR = ${DATA_DIR}/homo_sapiens/kabat
HOMO_FASTA_UNKNOWN_DIR = ${DATA_DIR}/homo_sapiens/unknown

# Fasta Files
HOMO_FASTA_KABAT_LIGHT = $(patsubst ${HOMO_NUMBERING_KABAT_DIR}/light/%.out, ${HOMO_FASTA_KABAT_DIR}/light/%.fasta, ${HOMO_NUMBERING_KABAT_LIGHT})
HOMO_FASTA_KABAT_HEAVY = $(patsubst ${HOMO_NUMBERING_KABAT_DIR}/heavy/%.out, ${HOMO_FASTA_KABAT_DIR}/heavy/%.fasta, ${HOMO_NUMBERING_KABAT_HEAVY})
HOMO_FASTA_UNKNOWN_LIGHT = $(patsubst ${HOMO_NUMBERING_UNKNOWN_DIR}/light/%.out, ${HOMO_FASTA_UNKNOWN_DIR}/light/%.fasta, ${HOMO_NUMBERING_UNKNOWN_LIGHT})
HOMO_FASTA_UNKNOWN_HEAVY = $(patsubst ${HOMO_NUMBERING_UNKNOWN_DIR}/heavy/%.out, ${HOMO_FASTA_UNKNOWN_DIR}/heavy/%.fasta, ${HOMO_NUMBERING_UNKNOWN_HEAVY})
FASTA_FILES = ${HOMO_FASTA_KABAT_LIGHT} ${HOMO_FASTA_KABAT_HEAVY} ${HOMO_FASTA_UNKNOWN_LIGHT} ${HOMO_FASTA_UNKNOWN_HEAVY}

prepare_fasta: ${FASTA_FILES}
	

${HOMO_FASTA_KABAT_DIR}/light/%.fasta: ${HOMO_NUMBERING_KABAT_DIR}/light/%.out
	./${NUMBERING_2_FASTA} $< >$@

${HOMO_FASTA_KABAT_DIR}/heavy/%.fasta: ${HOMO_NUMBERING_KABAT_DIR}/heavy/%.out
	./${NUMBERING_2_FASTA} $< >$@

${HOMO_FASTA_UNKNOWN_DIR}/light/%.fasta: ${HOMO_NUMBERING_UNKNOWN_DIR}/light/%.out
	./${NUMBERING_2_FASTA} $< >$@
	
${HOMO_FASTA_UNKNOWN_DIR}/heavy/%.fasta: ${HOMO_NUMBERING_UNKNOWN_DIR}/heavy/%.out
	./${NUMBERING_2_FASTA} $< >$@

clean_fasta:
	rm -rf ${FASTA_FILES}

#----------------------------------------------------------------------------------------------------------------------------------------------------------------
#Dif Dirs
HOMO_DIFF_KABAT_DIR = ${DIFF_DIR}/homo_sapiens/kabat
HOMO_DIFF_UNKNOWN_DIR = ${DIFF_DIR}/homo_sapiens/unknown

#Dif Files
HOMO_DIFF_KABAT_LIGHT = $(patsubst ${HOMO_FASTA_KABAT_DIR}/light/%.fasta, ${HOMO_DIFF_KABAT_DIR}/light/%.diff, ${HOMO_FASTA_KABAT_LIGHT})
HOMO_DIFF_KABAT_HEAVY = $(patsubst ${HOMO_FASTA_KABAT_DIR}/heavy/%.fasta, ${HOMO_DIFF_KABAT_DIR}/heavy/%.diff, ${HOMO_FASTA_KABAT_HEAVY})
HOMO_DIFF_UNKNOWN_LIGHT = $(patsubst ${HOMO_FASTA_UNKNOWN_DIR}/light/%.fasta, ${HOMO_DIFF_UNKNOWN_DIR}/light/%.diff, ${HOMO_FASTA_UNKNOWN_LIGHT})
HOMO_DIFF_UNKNOWN_HEAVY = $(patsubst ${HOMO_FASTA_UNKNOWN_DIR}/heavy/%.fasta, ${HOMO_DIFF_UNKNOWN_DIR}/heavy/%.diff, ${HOMO_FASTA_UNKNOWN_HEAVY})
HOMO_DIFF_FILES = ${HOMO_DIFF_KABAT_LIGHT} ${HOMO_DIFF_KABAT_HEAVY} ${HOMO_DIFF_UNKNOWN_LIGHT} ${HOMO_DIFF_UNKNOWN_HEAVY}


test_homo: ${HOMO_DIFF_KABAT_LIGHT} ${HOMO_DIFF_KABAT_HEAVY} ${HOMO_DIFF_UNKNOWN_LIGHT} ${HOMO_DIFF_UNKNOWN_HEAVY}
	@echo "-------------------------"
	@echo "Pdb diffs, homo	       |"
	@echo "-------------------------"
	@echo "Total diff files: $(shell find diffs/homo_sapiens -type f -name "*.diff" | wc -l)"
	@echo "Empty diff files: $(shell find diffs/homo_sapiens -type f -name "*.diff" -empty | wc -l)"

${HOMO_DIFF_KABAT_DIR}/light/%.diff: ${HOMO_NUMBERING_KABAT_DIR}/light/%.out ${HOMO_FASTA_KABAT_DIR}/light/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) --scheme 'kabat' --filterGaps 1 | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@


${HOMO_DIFF_KABAT_DIR}/heavy/%.diff: ${HOMO_NUMBERING_KABAT_DIR}/heavy/%.out ${HOMO_FASTA_KABAT_DIR}/heavy/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) --scheme 'kabat' --filterGaps 1 | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@


${HOMO_DIFF_UNKNOWN_DIR}/light/%.diff: ${HOMO_NUMBERING_UNKNOWN_DIR}/light/%.out ${HOMO_FASTA_UNKNOWN_DIR}/light/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) --scheme 'kabat' --filterGaps 1 | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@


${HOMO_DIFF_UNKNOWN_DIR}/heavy/%.diff: ${HOMO_NUMBERING_UNKNOWN_DIR}/heavy/%.out ${HOMO_FASTA_UNKNOWN_DIR}/heavy/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) --scheme 'kabat' --filterGaps 1 | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@


clean_diffs:
	rm -rf ${HOMO_DIFF_FILES}
	
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
#Dif Dirs
ANARCI_HOMO_DIFF_KABAT_DIR = ${ANARCI_DIFF_DIR}/homo_sapiens/kabat
ANARCI_HOMO_DIFF_UNKNOWN_DIR = ${ANARCI_DIFF_DIR}/homo_sapiens/unknown

# Scripts
MODYFIE_ANARCI_OUT = ${SCRIPTS}/modifyAnarciOutput
#Dif Files
ANARCI_HOMO_DIFF_KABAT_LIGHT = $(patsubst ${HOMO_FASTA_KABAT_DIR}/light/%.fasta, ${ANARCI_HOMO_DIFF_KABAT_DIR}/light/%.diff, ${HOMO_FASTA_KABAT_LIGHT})
ANARCI_HOMO_DIFF_KABAT_HEAVY = $(patsubst ${HOMO_FASTA_KABAT_DIR}/heavy/%.fasta, ${ANARCI_HOMO_DIFF_KABAT_DIR}/heavy/%.diff, ${HOMO_FASTA_KABAT_HEAVY})
ANARCI_HOMO_DIFF_UNKNOWN_LIGHT = $(patsubst ${HOMO_FASTA_UNKNOWN_DIR}/light/%.fasta, ${ANARCI_HOMO_DIFF_UNKNOWN_DIR}/light/%.diff, ${HOMO_FASTA_UNKNOWN_LIGHT})
ANARCI_HOMO_DIFF_UNKNOWN_HEAVY = $(patsubst ${HOMO_FASTA_UNKNOWN_DIR}/heavy/%.fasta, ${ANARCI_HOMO_DIFF_UNKNOWN_DIR}/heavy/%.diff, ${HOMO_FASTA_UNKNOWN_HEAVY})
ANARCI_HOMO_DIFF_FILES = ${ANARCI_HOMO_DIFF_KABAT_LIGHT} ${ANARCI_HOMO_DIFF_KABAT_HEAVY} ${ANARCI_HOMO_DIFF_UNKNOWN_LIGHT} ${ANARCI_HOMO_DIFF_UNKNOWN_HEAVY}


test_ANARCI_homo: ${ANARCI_HOMO_DIFF_KABAT_LIGHT} ${ANARCI_HOMO_DIFF_KABAT_HEAVY} ${ANARCI_HOMO_DIFF_UNKNOWN_LIGHT} ${ANARCI_HOMO_DIFF_UNKNOWN_HEAVY}
	@echo "-------------------------"
	@echo "Pdb diffs, ANARCI_homo	|"
	@echo "-------------------------"
	@echo "Total diff files: $(shell find anarci_diff/homo_sapiens -type f -name "*.diff" | wc -l)"
	@echo "Empty diff files: $(shell find anarci_diff/homo_sapiens -type f -name "*.diff" -empty | wc -l)"

${ANARCI_HOMO_DIFF_KABAT_DIR}/light/%.diff: ${HOMO_NUMBERING_KABAT_DIR}/light/%.out ${HOMO_FASTA_KABAT_DIR}/light/%.fasta
	-ANARCI --scheme kabat -i $(word 2,$^)  | ./${MODYFIE_ANARCI_OUT} | diff -w -y --suppress-common-lines - $< > $@


${ANARCI_HOMO_DIFF_KABAT_DIR}/heavy/%.diff: ${HOMO_NUMBERING_KABAT_DIR}/heavy/%.out ${HOMO_FASTA_KABAT_DIR}/heavy/%.fasta
	-ANARCI --scheme kabat -i $(word 2,$^)  | ./${MODYFIE_ANARCI_OUT} | diff -w -y --suppress-common-lines - $< > $@


${ANARCI_HOMO_DIFF_UNKNOWN_DIR}/light/%.diff: ${HOMO_NUMBERING_UNKNOWN_DIR}/light/%.out ${HOMO_FASTA_UNKNOWN_DIR}/light/%.fasta
	-ANARCI --scheme kabat -i $(word 2,$^)  | ./${MODYFIE_ANARCI_OUT} | diff -w -y --suppress-common-lines - $< > $@


${ANARCI_HOMO_DIFF_UNKNOWN_DIR}/heavy/%.diff: ${HOMO_NUMBERING_UNKNOWN_DIR}/heavy/%.out ${HOMO_FASTA_UNKNOWN_DIR}/heavy/%.fasta
	-ANARCI --scheme kabat -i $(word 2,$^)  | ./${MODYFIE_ANARCI_OUT} | diff -w -y --suppress-common-lines - $< > $@


clean_ANARCI_diffs:
	rm -rf ${HOMO_DIFF_FILES}



.PHONY: print_ids

print_ids:
	@echo ${HOMO_PDB}

