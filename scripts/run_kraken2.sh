#!/bin/bash
# Run Kraken2 on all 6 Arabidopsis samples

SAMPLES="DRR318379 DRR318380 DRR318381 DRR318382 DRR318383"
INDIR="/mnt/d/tfm_data/results/dehosting"
OUTDIR="/mnt/d/tfm_data/results/kraken2"
DB="/mnt/d/tfm_data/data/db/kraken2"

mkdir -p $OUTDIR

for sample in $SAMPLES; do
    echo "=========================================="
    echo "Processing $sample - $(date)"
    echo "=========================================="

    kraken2 \
      --db $DB \
      --paired \
      $INDIR/${sample}_microbial_1.fastq.gz \
      $INDIR/${sample}_microbial_2.fastq.gz \
      --output $OUTDIR/${sample}_kraken2_output.txt \
      --report $OUTDIR/${sample}_kraken2_report.txt \
      --confidence 0.1 \
      --threads 4 \
      --gzip-compressed

    echo "$sample done - $(date)"
    echo ""
done

echo "=========================================="
echo "All samples classified"
echo "=========================================="
