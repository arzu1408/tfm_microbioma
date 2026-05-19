#!/bin/bash
source ~/miniconda3/etc/profile.d/conda.sh
conda activate tfm_microbioma

SAMPLES="DRR318378 DRR318379 DRR318380 DRR318381 DRR318382 DRR318383"
INDIR="/mnt/d/tfm_data/results/kraken2"
OUTDIR="/mnt/d/tfm_data/results/kraken2"
DB="/mnt/d/tfm_data/data/db/kraken2"

for sample in $SAMPLES; do
    echo "=========================================="
    echo "Processing $sample - $(date)"
    echo "=========================================="

    # Species level
    bracken \
      -d $DB \
      -i $INDIR/${sample}_kraken2_report.txt \
      -o $OUTDIR/${sample}_bracken_species.txt \
      -w $OUTDIR/${sample}_bracken_species_report.txt \
      -r 150 \
      -l S \
      -t 10

    # Genus level
    bracken \
      -d $DB \
      -i $INDIR/${sample}_kraken2_report.txt \
      -o $OUTDIR/${sample}_bracken_genus.txt \
      -w $OUTDIR/${sample}_bracken_genus_report.txt \
      -r 150 \
      -l G \
      -t 10

    echo "$sample done - $(date)"
done

echo "=========================================="
echo "All Bracken estimations complete"
echo "=========================================="
