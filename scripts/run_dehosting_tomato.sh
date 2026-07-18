#!/bin/bash
# Dehosting tomato samples against SLM_r2.1 with Bowtie2 --sensitive

source ~/miniconda3/etc/profile.d/conda.sh
conda activate tfm_microbioma

SAMPLES="SRR16079617 SRR16079618 SRR16079619 SRR16079614 SRR16079615 SRR16079616"
TRIMDIR="/mnt/d/tfm_data/results/trimming_tomato"
OUTDIR="/mnt/d/tfm_data/results/dehosting_tomato"
INDEX="/mnt/d/tfm_data/data/ref/slm_r2/slm_r2_index"

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
echo "All tomato samples dehosted"
echo "=========================================="
