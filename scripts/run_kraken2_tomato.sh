#!/bin/bash
# Run Kraken2 + Bracken on all 6 tomato samples

source ~/miniconda3/etc/profile.d/conda.sh
conda activate tfm_microbioma

SAMPLES="SRR16079617 SRR16079618 SRR16079619 SRR16079614 SRR16079615 SRR16079616"
INDIR="/mnt/d/tfm_data/results/dehosting_tomato"
OUTDIR="/mnt/d/tfm_data/results/kraken2_tomato"
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

    # Bracken species level
    bracken \
      -d $DB \
      -i $OUTDIR/${sample}_kraken2_report.txt \
      -o $OUTDIR/${sample}_bracken_species.txt \
      -w $OUTDIR/${sample}_bracken_species_report.txt \
      -r 150 \
      -l S \
      -t 10

    # Bracken genus level
    bracken \
      -d $DB \
      -i $OUTDIR/${sample}_kraken2_report.txt \
      -o $OUTDIR/${sample}_bracken_genus.txt \
      -w $OUTDIR/${sample}_bracken_genus_report.txt \
      -r 150 \
      -l G \
      -t 10

    echo "$sample done - $(date)"
    echo ""
done

echo "=========================================="
echo "All Kraken2 + Bracken analyses complete"
echo "=========================================="
