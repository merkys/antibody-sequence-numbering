The numbering program code has been completely rewritten. Additionally, the file and directory structure has been slightly improved, which should make navigating the project significantly easier. In the Makefile, there are three rules: prepare_data, prepare_dirs, and update_hmms.

- prepare_data downloads and sorts PDB files with antibodies. Currently, this doesn't have much purpose, as these data are not being used yet. All related scripts and data will be located in the scripts/prepareData and scripts_out/prepareData directories.
- prepare_dirs creates all the necessary directories.
- update_hmms updates the HMM files. However, it currently works inconsistently because, for some reason, make tries to create HMM files from Stockholm files before the Stockholm files themselves are created. I haven't been able to identify the issue yet, so for now, I will upload all files to the repository.

Regarding the operation of the numbering program, it is located in the scripts directory and must be executed from the project's root folder. Otherwise, you will need to update the path to the HMM files, which are located in the root folder under the hmms directory. Additionally, for the program to work, you need to add modules/ to per5lib. Technically, the Makefile should handle this automatically when using the update_hmms rule, but as I mentioned, the rule sometimes works incorrectly. Therefore, I recommend adding the path manually.

As for the program's parameters, only two are currently implemented: --input and --output.
- --input accepts a FASTA file, which can contain any number of sequences.
- --output specifies the output file. This parameter is optional; if the output file is not specified, the results will be printed to stdout.
