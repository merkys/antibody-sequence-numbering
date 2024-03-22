# Directories
SCRIPTS = .
ROOT_DIR=..
DATA = ${ROOT_DIR}/data
LOGS = ${ROOT_DIR}/logs
PFAM_DIR = ${ROOT_DIR}/PfamScan
PFAM_SCAN_DATA = ${PFAM_DIR}/pfam_data
SCRIPTS_OUT = ${ROOT_DIR}/scripts_out
# Essential files
PDB_SEQ_FILE = ${ROOT_DIR}/pdb_seqres.txt.gz
PDB_ID_FILE = ${ROOT_DIR}/rcsb_pdb_ids_20240228040928.txt

PFAM_DATA_FILES := $(addprefix $(PFAM_SCAN_DATA)/, Pfam-A.hmm.h3i Pfam-A.hmm.h3p Pfam-A.hmm.h3f Pfam-A.hmm.h3m)
ACTIVE_SITE_NAME = active_site.dat
HMM_NAME := Pfam-A.hmm
HMM_DAT_NAME := Pfam-A.hmm.dat
ACTIVE_SITE := $(PFAM_SCAN_DATA)/${ACTIVE_SITE_NAME}
HMM := $(PFAM_SCAN_DATA)/${HMM_NAME}
HMM_DAT := $(PFAM_SCAN_DATA)/${HMM_DAT_NAME}

# Output files's extensions
FASTA = fasta
CLUSTER = clstr
PFAM_OUT = out
SORTED_IDS = txt
PDB = pdb
GZ = gz

# Output files's names
EXTRACTED_SEQ = extracted
CLUSTERED_SEQ = ${EXTRACTED_SEQ}Clustered
PFAM_SCAN_NAME = pfam_scan
ID_FILTER_NAME = sorted_ids

# Output files
EXTRACTED_FASTA = ${SCRIPTS_OUT}/${EXTRACTED_SEQ}.${FASTA}
CLUSTERED_FASTA = ${SCRIPTS_OUT}/${CLUSTERED_SEQ}.${FASTA}
CLUSTER_FILE = ${SCRIPTS_OUT}/${CLUSTERED_FASTA}.${CLUSTERED}
FILTERED_IDS_FILE = ${SCRIPTS_OUT}/${ID_FILTER_NAME}.${SORTED_IDS}
PFAM_SCAN_OUTPUT = ${SCRIPTS_OUT}/${PFAM_SCAN_NAME}.${PFAM_OUT}

# Scripts
EXTRACT = ${SCRIPTS}/extractEnCluster
ID_FILTER = ${SCRIPTS}/idFilter
PFAM_SCAN = ${PFAM_DIR}/pfam_scan.pl
FTP_DOWNLOAD = ${SCRIPTS}/byLinkDownload

# FTP links
SEQ_FROM_PDB_LINK = https://files.wwpdb.org/pub/pdb/derived_data
PFAM_DATA_LINK = https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release

# PFAM DATA


all: ${FILTERED_IDS_FILE}

${FILTERED_IDS_FILE}: ${PFAM_SCAN_OUTPUT}
	./${ID_FILTER} ${PDB_ID_FILE} $< $@

${PFAM_SCAN_OUTPUT}: ${EXTRACTED_FASTA} ${PFAM_DATA_FILES}
	${PFAM_SCAN} -fasta $< -dir ${PFAM_SCAN_DATA} -outfile $@

${EXTRACTED_FASTA}: ${PDB_SEQ_FILE} ${PDB_ID_FILE}
	./${EXTRACT} ${PDB_ID_FILE} ${PDB_SEQ_FILE} $@

${CLUSTERED_FASTA}: ${EXTRACTED_FASTA}

${CLUSTER_FILE}: ${CLUSTERED_FASTA}

${PDB_SEQ_FILE}:
	./${FTP_DOWNLOAD} ${ROOT_DIR} ${ROOT_DIR} ${SEQ_FROM_PDB_LINK} $@
	
${PFAM_DATA_FILES}: ${ACTIVE_SITE} ${HMM} ${HMM_DAT}
	hmmpress ${HMM}

${ACTIVE_SITE}:
	./${FTP_DOWNLOAD} ${PFAM_SCAN_DATA} ${PFAM_SCAN_DATA} ${PFAM_DATA_LINK} ${ACTIVE_SITE_NAME}.${GZ}
	gunzip ${ACTIVE_SITE}.${GZ}

${HMM}:
	./${FTP_DOWNLOAD} ${PFAM_SCAN_DATA} ${PFAM_SCAN_DATA} ${PFAM_DATA_LINK} ${HMM_NAME}.${GZ}
	gunzip ${HMM}.${GZ}

${HMM_DAT}:
	./${FTP_DOWNLOAD} ${PFAM_SCAN_DATA} ${PFAM_SCAN_DATA} ${PFAM_DATA_LINK} ${HMM_DAT_NAME}.${GZ}
	gunzip ${HMM_DAT}.${GZ}



