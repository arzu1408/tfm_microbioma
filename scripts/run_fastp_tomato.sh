#!/bin/bash
# Run fastp trimming on all 6 tomato samples (PRJNA766489)

source ~/miniconda3/etc/profile.d/conda.sh
conda activate tfm_microbioma

SAMPLES="SRR16079617 SRR16079618 SRR16079619 SRR16079614 SRR16079615 SRR16079616"
INDIR="/mnt/d/tfm_data/data/raw_tomato"
OUTDIR="/mnt/d/tfm_data/results/trimming_tomato"

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
echo "All tomato samples trimmed successfully"
echo "=========================================="
