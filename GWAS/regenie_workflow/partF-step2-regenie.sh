#!/bin/bash

# Requirements: 
# 0-4 - please refer to readme.md
# 5. Must have executed: 
# - partB-merge-files-dx-fuse.sh 
# - partC-step1-qc-filter.sh
# - partD-step1-regenie.sh
# - partE-step2-qc-filter.sh

# How to Run:
# Run this shell script using: 
#   sh partF-step2-regenie.sh 
# on the command line on your own machine

# Inputs:
# Note that you can adjust the output directory by setting the data_file_dir variable
# - /Data/diabetes_summaryICD_wes_450k.phe - from part A (please refer to notebook & slides)
# - /Data/diabetes_results_1.loco.gz - from part D
# - /Data/diabetes_results_pred.list - from part D

# Additional inputs
# for each chromosome, you will run a separate worker
# - /{exome_file_dir}/ukb23149_c1_b0_v1.bed - Chr1 file for 450k release
# - /{exome_file_dir}/ukb23149_c1_b0_v1.bim 
# - /{exome_file_dir}/ukb23149_c1_b0_v1.bam 
# - /Data/450K_WES_c1_snps_qc_pass.snplist - from Part E

# Outputs (for each chromosome):
# - /Data/assoc.c1_diabetes_cc.regenie.gz - regenie results for chromosome 1 
# note that if you have multiple phenotypes, you will have a .regenie.gz for each phenotype
# - /Data/assoc.c1.log  - regenie log for chromosome 1

#change exome_file_dir and data_field for the newest release
exome_file_dir="/Bulk/Exome sequences/Population level exome OQFE variants, PLINK format - interim 450k release/"

data_field="23149"

data_file_dir="/Data/"

for chr in {1..22}; do
  run_regenie_cmd="regenie --step 2 --bed ukb${data_field}_c${chr}_b0_v1 --out assoc.c${chr}\
    --phenoFile diabetes_summaryICD_wes_450k.phe --covarFile diabetes_summaryICD_wes_450k.phe\
    --bt --approx --firth-se --firth --extract 450K_WES_c${chr}_snps_qc_pass.snplist\
    --phenoCol diabetes_cc --covarCol age --covarCol sex --covarCol ethnic_group --covarCol ever_smoked \
    --pred diabetes_results_pred.list --bsize 200\
    --pThresh 0.05 --minMAC 3 --threads 16 --gz"

  dx run swiss-army-knife -iin="${exome_file_dir}ukb${data_field}_c${chr}_b0_v1.bed" \ #bed file for chromosome
   -iin="${exome_file_dir}ukb${data_field}_c${chr}_b0_v1.bim" \ #bim file for chromosome
   -iin="${exome_file_dir}ukb${data_field}_c${chr}_b0_v1.fam"\ #fam file for chromosome
   -iin="${data_file_dir}450K_WES_c${chr}_snps_qc_pass.snplist"\ #individual QC snplist produced with partE-step2-qc-filter.sh
   -iin="${data_file_dir}diabetes_summaryICD_wes_450k.phe" \  #phenotype results
   -iin="${data_file_dir}diabetes_results_pred.list" \ #Merged results produced from 03-step1-regenie.sh
   -iin="${data_file_dir}diabetes_results_1.loco.gz" \ #Merged results produced from 03-step1-regenie.sh
   -icmd="${run_regenie_cmd}" --tag="Step2" --instance-type "mem1_ssd1_v2_x16"\
   --destination="${data_file_dir}" --brief --yes
done
