#!/usr/bin/env bash
set -euxo pipefail

### get data ###
# download zip for
# T2D GWAS meta-analysis - Unadjusted for BMI
# Published in in Mahajan et al (2018b)
# from http://diagram-consortium.org/downloads.html & unzip

g="data/Mahajan.NatGenet2018b.T2D.European.txt"
f="/data/db/human/gatk/2.8/b37/human_g1k_v37.fasta"
v="data/Mahajan.NatGenet2018b.T2D.European.vcf"

# make VCF
/Users/ml/GitLab/gwas_harmonisation/venv/bin/python /Users/ml/GitLab/gwas_harmonisation/main.py \
-o "$v" \
-g "$g" \
-f "$f" \
-s 1 \
-chrom_field 1 \
-pos_field 2 \
-ea_field 3 \
-nea_field 4 \
-ea_af_field 5 \
-effect_field 6 \
-se_field 7 \
-pval_field 8

# sort vcf
/share/apps/bedtools-distros/bedtools-2.26.0/bin/bedtools sort \
-i "$v" \
-faidx "$f".fai \
-header > $(echo "$v" | sed 's/.vcf/.sorted.vcf/g')

# validate vcf
java -Xmx2g -jar /share/apps/GATK-distros/GATK_3.7.0/GenomeAnalysisTK.jar \
-T ValidateVariants \
-R "$f" \
-V $(echo "$v" | sed 's/.vcf/.sorted.vcf/g')

# combine multi allelics & output bcf
/share/apps/bcftools-distros/bcftools-1.3.1/bcftools norm \
--check-ref e \
-f "$f" \
-m +any \
-Ob \
-o $(echo "$v" | sed 's/.vcf/.bcf/g') \
$(echo "$v" | sed 's/.vcf/.sorted.vcf/g')

# index bcf
/share/apps/bcftools-distros/bcftools-1.3.1/bcftools index $(echo "$v" | sed 's/.vcf/.bcf/g')