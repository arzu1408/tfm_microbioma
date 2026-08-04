#!/bin/bash
# Run MetaPhlAn4 on all 6 tomato samples

source ~/miniconda3/etc/profile.d/conda.sh
conda activate tfm_microbioma

SAMPLES="SRR16079617 SRR16079618 SRR16079619 SRR16079614 SRR16079615 SRR16079616"
INDIR="/mnt/d/tfm_data/results/dehosting_tomato"
OUTDIR="/mnt/d/tfm_data/results/metaphlan4_tomato"
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
      --nproc 2 \
      --output_file $OUTDIR/${sample}_metaphlan4.txt

    echo "$sample done - $(date)"
    echo ""
done

# merge all results
echo "Merging all samples..."
merge_metaphlan_tables.py $OUTDIR/*_metaphlan4.txt \
  -o $OUTDIR/merged_metaphlan4_tomato.txt

echo "=========================================="
echo "All MetaPhlAn4 analyses complete"
echo "=========================================="
