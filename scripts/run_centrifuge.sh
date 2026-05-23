#!/bin/bash
source ~/miniconda3/etc/profile.d/conda.sh
conda activate tfm_microbioma

SAMPLES="DRR318379 DRR318380 DRR318381 DRR318382 DRR318383"
INDIR="/mnt/d/tfm_data/results/dehosting"
OUTDIR="/mnt/d/tfm_data/results/centrifuge"
DB="/mnt/d/tfm_data/data/db/centrifuge/p_compressed+h+v"

mkdir -p $OUTDIR

for sample in $SAMPLES; do
    echo "=========================================="
    echo "Processing $sample - $(date)"
    echo "=========================================="

    centrifuge \
      -x $DB \
      -1 $INDIR/${sample}_microbial_1.fastq.gz \
      -2 $INDIR/${sample}_microbial_2.fastq.gz \
      --report-file $OUTDIR/${sample}_centrifuge_report.txt \
      -S $OUTDIR/${sample}_centrifuge_output.txt \
      -p 4

    # convert to kraken2 format
    centrifuge-kreport \
      -x $DB \
      $OUTDIR/${sample}_centrifuge_output.txt \
      > $OUTDIR/${sample}_centrifuge_kreport.txt

    echo "$sample done - $(date)"
    echo ""
done

echo "=========================================="
echo "All Centrifuge analyses complete"
echo "=========================================="
