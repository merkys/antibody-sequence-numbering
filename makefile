
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

# Output files's names
EXTRACTED_SEQ = extracted
CLUSTERED_SEQ = ${EXTRACTED_SEQ}Clustered
PFAM_SCAN_NAME = pfam_scan

# Output files
EXTRACTED_FASTA = ${EXTRACTED_SEQ}.${FASTA}
CLUSTERED_FASTA = ${CLUSTERED_SEQ}.${FASTA}
CLUSTER_FILE = ${CLUSTERED_FASTA}.${CLUSTERED}
ID_FILTER_NAME = id_list
PFAM_SCAN_OUTPUT = ${PFAM_SCAN_NAME}.${PFAM_OUT}

# Scripts
EXTRACT = ${SCRIPTS}/extractEnCluster
ID_FILTER = ${SCRIPTS}/idFilter
PFAM_SCAN = ${PFAM_DIR}/pfam_scan.pl


all: ${PFAM_SCAN_OUTPUT} 


${PFAM_SCAN_OUTPUT}: ${EXTRACTED_FASTA}
	${PFAM_SCAN} -fasta $< -dir ${PFAM_SCAN_DATA} -outfile $@

${EXTRACTED_FASTA}: ${PDB_SEQ_FILE} ${PDB_ID_FILE}
	./${EXTRACT} ${PDB_ID_FILE} ${PDB_SEQ_FILE} $@

${CLUSTERED_FASTA}: ${EXTRACTED_FASTA}

${CLUSTER_FILE}: ${CLUSTERED_FASTA}






