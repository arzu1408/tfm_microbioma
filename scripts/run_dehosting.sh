#!/bin/bash
# Dehosting remaining 5 Arabidopsis samples with Bowtie2 --sensitive

SAMPLES="DRR318379 DRR318380 DRR318381 DRR318382 DRR318383"
TRIMDIR="/mnt/d/tfm_data/results/trimming"
OUTDIR="/mnt/d/tfm_data/results/dehosting"
INDEX="/mnt/d/tfm_data/data/ref/tair10/tair10_index"

mkdir -p $OUTDIR

for sample in $SAMPLES; do
    echo "=========================================="
    echo "Dehosting $sample - $(date)"
    echo "=========================================="

    bowtie2 \
      -x $INDEX \
      -1 $TRIMDIR/${sample}_1_clean.fastq.gz \
      -2 $TRIMDIR/${sample}_2_clean.fastq.gz \
      --sensitive \
      --no-unal \
      -S /dev/null \
      --un-conc-gz $OUTDIR/${sample}_microbial_%.fastq.gz \
      --threads 4 \
      2> $OUTDIR/${sample}_bowtie2_stats.txt

    echo "$sample done - $(date)"
    echo ""
done

echo "=========================================="
echo "All samples dehosted complete"
echo "=========================================="
