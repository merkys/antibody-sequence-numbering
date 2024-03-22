# Directories
CURRENT_DIR = .
SCRIPTS = ${CURRENT_DIR}/scripts
DATA = ${CURRENT_DIR}/data
LOGS = ${CURRENT_DIR}/logs
SCRIPTS_OUT = ${CURRENT_DIR}/scripts_out
HEAVY_LIGHT = ${SCRIPTS_OUT}/heavy_and_light_chains

# Output files's extensions
CLUSTER = clstr
IDS_FILE = txt
PDB = pdb
GZ = gz

# Scripts
PDB_DOWNLOAD = ${SCRIPTS}/byLinkDownload
READ_FRAGMENT = ${SCRIPTS}/read_fragment

# Files
SORTED_IDS_FILE = ${SCRIPTS_OUT}/sorted_ids.${IDS_FILE}
DATA_FILE_NAMES = $(addsuffix .${PDB}.${GZ}, $(shell cat ${SORTED_IDS_FILE}))
DATA_FILES = $(addprefix ${DATA}/, ${DATA_FILE_NAMES})
LIGHT_CHAINS = ${HEAVY_LIGHT}/light_chains.${IDS_FILE}
HEAVY_CHAINS = ${HEAVY_LIGHT}/heavy_chains.${IDS_FILE}
# Link
PDB_LINK = http://www.rcsb.org/pdb/files

all: ${HEAVY_CHAINS} ${LIGHT_CHAINS}

	
${HEAVY_CHAINS} ${LIGHT_CHAINS}: ${DATA_FILES}
	./${READ_FRAGMENT} ${DATA} ${HEAVY_LIGHT}

${DATA}/%.${PDB}.${GZ}:
	./${PDB_DOWNLOAD} ${DATA} ${LOGS} ${PDB_LINK} $(notdir $@)
	

