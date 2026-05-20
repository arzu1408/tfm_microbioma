#!/bin/bash
source ~/miniconda3/etc/profile.d/conda.sh
conda activate tfm_microbioma

SAMPLES="DRR318378 DRR318379 DRR318380 DRR318381 DRR318382 DRR318383"
INDIR="/mnt/d/tfm_data/results/dehosting"
OUTDIR="/mnt/d/tfm_data/results/metaphlan4"
DB="/mnt/d/tfm_data/data/db/metaphlan4"
INDEX="mpa_vOct22_CHOCOPhlAnSGB_202403"

mkdir -p $OUTDIR

for sample in $SAMPLES; do
    echo "=========================================="
    echo "Processing $sample - $(date)"
    echo "=========================================="

    metaphlan \
      $INDIR/${sample}_microbial_1.fastq.gz,$INDIR/${sample}_microbial_2.fastq.gz \
      --input_type fastq \
      --bowtie2db $DB \
      --index $INDEX \
      --bowtie2out $OUTDIR/${sample}_bowtie2.bz2 \
      --nproc 4 \
      --output_file $OUTDIR/${sample}_metaphlan4.txt

    echo "$sample done - $(date)"
    echo ""
done

# merge all results into one table
echo "Merging all samples..."
merge_metaphlan_tables.py $OUTDIR/*_metaphlan4.txt \
  -o $OUTDIR/merged_metaphlan4_table.txt

echo "=========================================="
echo "All MetaPhlAn4 analyses complete"
echo "=========================================="
