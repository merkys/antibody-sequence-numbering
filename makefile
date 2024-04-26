# Directories
## Essentail directories
CURRENT_DIR = .
SCRIPTS = ${CURRENT_DIR}/scripts
DATA = ${CURRENT_DIR}/data
LOGS = ${CURRENT_DIR}/logs
SCRIPTS_OUT = ${CURRENT_DIR}/scripts_out

## Antybody seq analize directories
HEAVY_LIGHT = ${SCRIPTS_OUT}/heavy_and_light_chains
HEAVY_LIGHT_ID = ${HEAVY_LIGHT}/id
HEAVY_LIGHT_FASTA = ${HEAVY_LIGHT}/fasta
HEAVY_LIGHT_ALIGMENTS = ${HEAVY_LIGHT}/aligments
HEAVY_LIGHT_COMPARE = ${HEAVY_LIGHT}/pdb_clusters_compare

## Id sort directories #
PFAM_DIR = ${ROOT_DIR}/PfamScan
PFAM_SCAN_DATA = pfam_data

# Output files's extensions #
## Essential extensions ##
IDS_FILE = txt
PDB = pdb
GZ = gz

## Antybody seq analize extensions ##
CLUSTER = clstr
FASTA = fasta

# Scripts #
## Antybody seq analize scripts ##
READ_FRAGMENT = ${SCRIPTS}/read_fragment
READ_CLUSTER = ${SCRIPTS}/readCluster
MAKE_FASTA =${SCRIPTS}/makeFasta
COMPARE_NUMBERING= ${SCRIPTS}/compareNumberingPdbCluster
ALIGNER = muscle
EXCLUDE_FILE = ${SCRIPTS}/excludeNoNNumbering
## Id sort scripts ##
EXTRACT = ${SCRIPTS}/extractEnCluster
ID_FILTER = ${SCRIPTS}/idFilter
PFAM_SCAN = ${PFAM_DIR}/pfam_scan.pl
DOWNLOAD_FILE = ${SCRIPTS}/byLinkDownload
TRIM_EXTACTED = ${SCRIPTS}/trimExtracted

# Files #
## Id sort files ##
PDB_SEQ_FILE = pdb_seqres.txt.gz
PDB_ID_FILE = rcsb_pdb_ids_20240228040928.txt
PFAM_DATA_FILES := $(addprefix $(PFAM_SCAN_DATA)/, Pfam-A.hmm.h3i Pfam-A.hmm.h3p Pfam-A.hmm.h3f Pfam-A.hmm.h3m)
ACTIVE_SITE_NAME = active_site.dat
ACTIVE_SITE := $(PFAM_SCAN_DATA)/${ACTIVE_SITE_NAME}
HMM_NAME := Pfam-A.hmm
HMM := $(PFAM_SCAN_DATA)/${HMM_NAME}
HMM_DAT_NAME := Pfam-A.hmm.dat
HMM_DAT := $(PFAM_SCAN_DATA)/${HMM_DAT_NAME}
EXTRACTED_FASTA = ${SCRIPTS_OUT}/${EXTRACTED_SEQ}.${FASTA}
## Antybody seq analize files ##
IDS_WITH_NUMBERING = ${SCRIPTS_OUT}/idsWithNumbering.${IDS_FILE}
SORTED_IDS_FILE = ${SCRIPTS_OUT}/sorted_ids.${IDS_FILE}
DATA_FILE_NAMES = $(addsuffix .${PDB}.${GZ}, $(shell cat ${SORTED_IDS_FILE}))
DATA_FILES = $(addprefix ${DATA}/, ${DATA_FILE_NAMES})
LIGHT_CHAINS_ID = ${HEAVY_LIGHT_ID}/light_chains.${IDS_FILE}
HEAVY_CHAINS_ID = ${HEAVY_LIGHT_ID}/heavy_chains.${IDS_FILE}
HEAVY_CHAINS_FASTA = ${HEAVY_LIGHT_FASTA}/heavy_chains.${FASTA}
LIGHT_CHAINS_FASTA = ${HEAVY_LIGHT_FASTA}/light_chains.${FASTA}
HEAVY_CHAINS_FASTA_CLUSTERS = ${HEAVY_LIGHT_FASTA}/heavy_chainsClustered.${FASTA}
LIGHT_CHAINS_FASTA_CLUSTERS = ${HEAVY_LIGHT_FASTA}/light_chainsClustered.${FASTA}
HEAVY_CHAINS_CLUSTERS = ${HEAVY_LIGHT_FASTA}/heavy_chainsClustered.${FASTA}.${CLUSTER}
LIGHT_CHAINS_CLUSTERS = ${HEAVY_LIGHT_FASTA}/light_chainsClustered.${FASTA}.${CLUSTER}
CLUSTERS_FOR_ALIGMENT = $(shell ls ${HEAVY_LIGHT_ALIGMENTS})
CLUSTERS_COMPARE_NAMES = $(addsuffix .out,$(CLUSTERS_FOR_ALIGMENT))
CLUSTERS_COMPARE = $(addprefix ${HEAVY_LIGHT_COMPARE}/,$(CLUSTERS_COMPARE_NAMES))

# Links
PDB_LINK = http://www.rcsb.org/pdb/files
SEQ_FROM_PDB_LINK = https://files.wwpdb.org/pub/pdb/derived_data
PFAM_DATA_LINK = https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release

all: ${CLUSTERS_COMPARE}

## Antybody seq analize
${HEAVY_LIGHT_COMPARE}/%.afa.out: ${HEAVY_LIGHT_ALIGMENTS}/%.afa
	./${COMPARE_NUMBERING} $< ${DATA} ${HEAVY_LIGHT_COMPARE}

${CLUSTERS_FOR_ALIGMENT}: regenerateClusters

regenerateClusters: ${LIGHT_CHAINS_FASTA_CLUSTERS} ${HEAVY_CHAINS_FASTA_CLUSTERS} ${LIGHT_CHAINS_FASTA} ${HEAVY_CHAINS_FASTA}
	./${READ_CLUSTER} ${LIGHT_CHAINS_FASTA} ${LIGHT_CHAINS_CLUSTERS} ${HEAVY_LIGHT_ALIGMENTS} "light"
	./${READ_CLUSTER} ${HEAVY_CHAINS_FASTA} ${HEAVY_CHAINS_CLUSTERS} ${HEAVY_LIGHT_ALIGMENTS} "heavy"

${LIGHT_CHAINS_FASTA_CLUSTERS}: ${LIGHT_CHAINS_FASTA}
	cd-hit -i $< -o $@

${HEAVY_CHAINS_FASTA_CLUSTERS}: ${HEAVY_CHAINS_FASTA}
	cd-hit -i $< -o $@

${HEAVY_CHAINS_FASTA}: ${HEAVY_CHAINS_ID}
	./${MAKE_FASTA} $@ $< ${DATA}

${LIGHT_CHAINS_FASTA}: ${LIGHT_CHAINS_ID}
	./${MAKE_FASTA} $@ $< ${DATA}

${IDS_WITH_NUMBERING}: ${DATA_FILES}
	./${EXCLUDE_FILE} ${DATA} ${SCRIPTS_OUT}

${HEAVY_CHAINS_ID} ${LIGHT_CHAINS_ID}: ${IDS_WITH_NUMBERING}
	./${READ_FRAGMENT} ${IDS_WITH_NUMBERING} ${HEAVY_LIGHT_ID}

${DATA}/%.${PDB}.${GZ}: 
	./${DOWNLOAD_FILE} ${DATA} ${LOGS} ${PDB_LINK} $(notdir $@)
	

## Id sort
update_id_file: ${EXTRACTED_FASTA}

${EXTRACTED_FASTA}: ${PDB_SEQ_FILE} ${PDB_ID_FILE}
	./${EXTRACT} ${PDB_ID_FILE} ${PDB_SEQ_FILE} $@

${PDB_SEQ_FILE}:
	./${DOWNLOAD_FILE} ${CURRENT_DIR} ${CURRENT_DIR} ${SEQ_FROM_PDB_LINK} $(@F)
	
${PFAM_DATA_FILES}: ${ACTIVE_SITE} ${HMM} ${HMM_DAT}
	hmmpress ${HMM}

${ACTIVE_SITE}:
	./${DOWNLOAD_FILE} ${PFAM_SCAN_DATA} ${PFAM_SCAN_DATA} ${PFAM_DATA_LINK} ${ACTIVE_SITE_NAME}.${GZ}
	gunzip ${ACTIVE_SITE}.${GZ}

${HMM}:
	./${DOWNLOAD_FILE} ${PFAM_SCAN_DATA} ${PFAM_SCAN_DATA} ${PFAM_DATA_LINK} ${HMM_NAME}.${GZ}
	gunzip ${HMM}.${GZ}

${HMM_DAT}:
	./${DOWNLOAD_FILE} ${PFAM_SCAN_DATA} ${PFAM_SCAN_DATA} ${PFAM_DATA_LINK} ${HMM_DAT_NAME}.${GZ}
	gunzip ${HMM_DAT}.${GZ}


