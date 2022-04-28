#!/bin/sh

# This script runs the QC process using PLINK on the merged file generated in 
# partB-merge-files-dxfuse.sh as described in the 

# Requirements: 
# (0-4). Please see readme.md
# 5. Must have executed partB-merge-files-dx-fuse.sh

# How to Run:
# Run this shell script using: 
# sh partC-step1-qc-filter.sh 
# on the command line on your machine

# Outputs: 
# - /Data/WES_array_snps_qc_pass.snplist - Used as input for part D 
# - /Data/WES_array_snps_qc_pass.log
# - /Data/WES_array_snps_qc_pass.id

#set output directory (also location of merged files)
data_file_dir="/Data/"

# set the data_field
data_field="22418"

run_plink_qc="plink2 --bfile ukb${data_field}_c1_22_v2_merged\
 --keep diabetes_summaryICD_wes_450k.phe --autosome\
 --maf 0.01 --mac 20 --geno 0.1 --hwe 1e-15\
 --mind 0.1 --write-snplist --write-samples\
 --no-id-header --out  WES_array_snps_qc_pass"

dx run swiss-army-knife -iin="${data_file_dir}ukb${data_field}_c1_22_v2_merged.bed" \
   -iin="${data_file_dir}ukb${data_field}_c1_22_v2_merged.bim" \
   -iin="${data_file_dir}ukb${data_field}_c1_22_v2_merged.fam"\
   -iin="${data_file_dir}diabetes_summaryICD_wes_450k.phe" \
   -icmd="${run_plink_qc}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16"\
   --destination="${data_file_dir}" --brief --yes
