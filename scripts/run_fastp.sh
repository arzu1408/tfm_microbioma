#!/bin/bash
# Run fastp trimming on all 6 Arabidopsis samples

SAMPLES="DRR318379 DRR318380 DRR318381 DRR318382 DRR318383"
INDIR="/mnt/d/tfm_data/data/raw"
OUTDIR="/mnt/d/tfm_data/results/trimming"

mkdir -p $OUTDIR

for sample in $SAMPLES; do
    echo "=========================================="
    echo "Processing $sample - $(date)"
    echo "=========================================="

    fastp \
      -i $INDIR/${sample}_1.fastq.gz \
      -I $INDIR/${sample}_2.fastq.gz \
      -o $OUTDIR/${sample}_1_clean.fastq.gz \
      -O $OUTDIR/${sample}_2_clean.fastq.gz \
      --json $OUTDIR/${sample}_fastp.json \
      --html $OUTDIR/${sample}_fastp.html \
      --adapter_sequence TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG \
      --adapter_sequence_r2 GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAG \
      --trim_front1 15 \
      --trim_front2 15 \
      --qualified_quality_phred 26 \
      --unqualified_percent_limit 40 \
      --length_required 50 \
      --thread 4

    echo "$sample done - $(date)"
    echo ""
done

echo "=========================================="
echo "All samples trimmed successfully"
echo "=========================================="
