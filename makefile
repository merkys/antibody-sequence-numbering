# Directories
SCRIPTS = scripts
DATA = data
LOGS = logs
PFAM_DIR = ~/src/PfamScan

# Essential files
PDB_SEQ_FILE = pdb_seqres.txt.gz
PDB_ID_FILE = rcsb_pdb_ids_20240228040928.txt
PFAM_SCAN_DATA = ${PFAM_DIR}/pfam_data_files

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
EXTRACTED_FASTA = ${EXTRACTED_SEQ}.${FASTA}
CLUSTERED_FASTA = ${CLUSTERED_SEQ}.${FASTA}
CLUSTER_FILE = ${CLUSTERED_FASTA}.${CLUSTERED}
FILTERED_IDS_FILE = ${ID_FILTER_NAME}.${SORTED_IDS}
PFAM_SCAN_OUTPUT = ${PFAM_SCAN_NAME}.${PFAM_OUT}

# Scripts
EXTRACT = ${SCRIPTS}/extractEnCluster
ID_FILTER = ${SCRIPTS}/idFilter
PFAM_SCAN = ${PFAM_DIR}/pfam_scan.pl
PDB_SEQ_DOWNLOAD = ${SCRIPTS}/pdbSeqDownload
PDB_DATA_DOWNLOAD = ${SCRIPTS}/downloadPdbFiles


all: ${FILTERED_IDS_FILE}
	./${PDB_DATA_DOWNLOAD} $< ${DATA} ${LOGS} ${PDB}.${GZ}


${FILTERED_IDS_FILE}: ${PFAM_SCAN_OUTPUT}
	./${ID_FILTER} ${PDB_ID_FILE} $< $@

${PFAM_SCAN_OUTPUT}: ${EXTRACTED_FASTA}
	${PFAM_SCAN} -fasta $< -dir ${PFAM_SCAN_DATA} -outfile $@

${EXTRACTED_FASTA}: ${PDB_SEQ_FILE} ${PDB_ID_FILE}
	./${EXTRACT} ${PDB_ID_FILE} ${PDB_SEQ_FILE} $@

${CLUSTERED_FASTA}: ${EXTRACTED_FASTA}

${CLUSTER_FILE}: ${CLUSTERED_FASTA}

${PDB_SEQ_FILE}:
	./${PDB_SEQ_DOWNLOAD} .




