## Roor Dirs
DATA_DIR = data
ANARCI_OUTPUT_DIR = outputsAnarci
DIFFS_DIR = diffs
SCRIPTS = scripts
RAW_DATA_DIR = raw_data

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


test_all: test_homo test_mus


distclean_all:
	$(MAKE) clean_all_diffs
	$(MAKE) clean_all_out


clean_all_diffs:
	$(MAKE) clean_homo_diffs
	$(MAKE) clean_mus_diffs


clean_all_out:
	$(MAKE) clean_homo_out
	$(MAKE) clean_mus_out

.PRECIOUS:${HOMO_KAPPA_ANARCI_OUT_DIR}/%.out ${HOMO_LAMBDA_ANARCI_OUT_DIR}/%.out ${HOMO_HEAVY_ANARCI_OUT_DIR}/%.out


test_homo: ${HOMO_HEAVY_DIFF_FILES} ${HOMO_LAMBDA_DIFF_FILES} ${HOMO_KAPPA_DIFF_FILES}
	@echo "-------------------------"
	@echo "Kabat convertation, homo|"
	@echo "-------------------------"
	@echo "Total diff files: $(shell find diffs/homo_sapiense -type f -name "*.diff" | wc -l)"
	@echo "Empty diff files: $(shell find diffs/homo_sapiense -type f -name "*.diff" -empty | wc -l)"
	

${HOMO_HEAVY_DIFF_DIR}/%.diff: ${HOMO_HEAVY_ANARCI_OUT_DIR}/%.out ${HOMO_HEAVY_FASTA_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) --scheme 'kabat' | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@
	

${HOMO_LAMBDA_DIFF_DIR}/%.diff: ${HOMO_LAMBDA_ANARCI_OUT_DIR}/%.out ${HOMO_LAMBDA_FASTA_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) --scheme 'kabat' | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@


${HOMO_KAPPA_DIFF_DIR}/%.diff: ${HOMO_KAPPA_ANARCI_OUT_DIR}/%.out ${HOMO_KAPPA_FASTA_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) --scheme 'kabat' | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@


${HOMO_LAMBDA_ANARCI_OUT_DIR}/%.out: ${HOMO_LAMBDA_FASTA_DIR}/%.fasta
	ANARCI --scheme kabat -i $< | ./${MODYFIE_ANARI_OUT} >$@


${HOMO_HEAVY_ANARCI_OUT_DIR}/%.out: ${HOMO_HEAVY_FASTA_DIR}/%.fasta
	ANARCI --scheme kabat -i $< | ./${MODYFIE_ANARI_OUT} >$@


${HOMO_KAPPA_ANARCI_OUT_DIR}/%.out: ${HOMO_KAPPA_FASTA_DIR}/%.fasta
	ANARCI --scheme kabat -i $< | ./${MODYFIE_ANARI_OUT} >$@


distclean_homo:
	$(MAKE) clean_homo_out
	$(MAKE) clean_homo_diffs


clean_homo_out:
	rm -rf ${HOMO_HEAVY_ANARCI_OUT_DIR}/*.out
	rm -rf ${HOMO_LAMBDA_ANARCI_OUT_DIR}/*.out
	rm -rf ${HOMO_KAPPA_ANARCI_OUT_DIR}/*.out


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
	@echo "-------------------------"
	@echo "Kabat convertation, mus |"
	@echo "-------------------------"
	@echo "Total diff files: $(shell find diffs/mus_musculus -type f -name "*.diff" | wc -l)"
	@echo "Empty diff files: $(shell find diffs/mus_musculus -type f -name "*.diff" -empty | wc -l)"

${MUS_HEAVY_DIFF_DIR}/%.diff: ${MUS_HEAVY_ANARCI_OUT_DIR}/%.out ${MUS_HEAVY_FASTA_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) --scheme 'kabat' | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@
	

${MUS_KAPPA_DIFF_DIR}/%.diff: ${MUS_KAPPA_ANARCI_OUT_DIR}/%.out ${MUS_KAPPA_FASTA_DIR}/%.fasta
	-./numberAntibodySeq -i $(word 2,$^) --scheme 'kabat' | tail -n +4 | head -n -1 | diff -w -y --suppress-common-lines - $< > $@


${MUS_HEAVY_ANARCI_OUT_DIR}/%.out: ${MUS_HEAVY_FASTA_DIR}/%.fasta
	ANARCI -i $< --scheme 'kabat' | ./${MODYFIE_ANARI_OUT} >$@


${MUS_KAPPA_ANARCI_OUT_DIR}/%.out: ${MUS_KAPPA_FASTA_DIR}/%.fasta
	ANARCI -i $< --scheme 'kabat' | ./${MODYFIE_ANARI_OUT} >$@


distclean_mus:
	$(MAKE) clean_mus_out
	$(MAKE) clean_mus_diffs


clean_mus_out:
	rm -rf ${MUS_HEAVY_ANARCI_OUT_DIR}/*.out
	rm -rf ${MUS_KAPPA_ANARCI_OUT_DIR}/*.out


clean_mus_diffs:
	rm -rf ${MUS_HEAVY_DIFF_DIR}/*.diff
	rm -rf ${MUS_KAPPA_DIFF_DIR}/*.diff	

