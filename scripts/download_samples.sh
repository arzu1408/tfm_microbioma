#!/bin/bash
# Download and convert Arabidopsis samples (DRR318378 already done)

SAMPLES="DRR318379 DRR318380 DRR318381 DRR318382 DRR318383"
OUTDIR="data/raw"

for sample in $SAMPLES; do
    echo "=========================================="
    echo "Processing $sample - $(date)"
    echo "=========================================="
    
    # Download
    echo "Downloading $sample..."
    prefetch $sample --output-directory $OUTDIR
    
    # Convert to fastq.gz
    echo "Converting $sample..."
    fastq-dump $OUTDIR/$sample/$sample.sra \
        --outdir $OUTDIR \
        --split-files \
        --gzip
    
    # Remove sra file to save space
    echo "Cleaning up $sample..."
    rm -rf $OUTDIR/$sample/
    
    echo "$sample done - $(date)"
    echo ""
done

echo "=========================================="
echo "All samples downloaded and converted"
echo "=========================================="
