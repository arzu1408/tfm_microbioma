#!/bin/bash
# Download and convert all 6 tomato samples (PRJNA766489 - Healthy vs Diseased)

SAMPLES="SRR16079617 SRR16079618 SRR16079619 SRR16079614 SRR16079615 SRR16079616"
OUTDIR="/mnt/d/tfm_data/data/raw_tomato"

for sample in $SAMPLES; do
    echo "=========================================="
    echo "Processing $sample - $(date)"
    echo "=========================================="

    echo "Downloading $sample..."
    prefetch $sample --output-directory $OUTDIR

    echo "Converting $sample..."
    fastq-dump $OUTDIR/$sample/$sample.sra \
        --outdir $OUTDIR \
        --split-files \
        --gzip

    echo "Cleaning up $sample..."
    rm -rf $OUTDIR/$sample/

    echo "$sample done - $(date)"
    echo ""
done

echo "=========================================="
echo "All tomato samples downloaded and converted"
echo "=========================================="
