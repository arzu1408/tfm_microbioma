#!/bin/bash
# Run Centrifuge on all 6 tomato samples

source ~/miniconda3/etc/profile.d/conda.sh
conda activate tfm_microbioma

SAMPLES="SRR16079617 SRR16079618 SRR16079619 SRR16079614 SRR16079615 SRR16079616"
INDIR="/mnt/d/tfm_data/results/dehosting_tomato"
OUTDIR="/mnt/d/tfm_data/results/centrifuge_tomato"
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
      -S $OUTDIR/${sample}_centrifuge_output.txt \
      --report-file $OUTDIR/${sample}_centrifuge_report.txt \
      -p 4 \
      --mm

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
