#!/bin/bash
OUTDIR="data/raw"

for sample in DRR318382 DRR318383; do
    echo "=========================================="
    echo "Redownloading $sample - $(date)"
    echo "=========================================="
    
    # Remove incomplete files
    rm -f $OUTDIR/${sample}_1.fastq.gz
    rm -f $OUTDIR/${sample}_2.fastq.gz
    rm -rf $OUTDIR/$sample/
    
    # Download
    prefetch $sample --output-directory $OUTDIR
    
    # Convert
    fastq-dump $OUTDIR/$sample/$sample.sra \
        --outdir $OUTDIR \
        --split-files \
        --gzip
    
    # Cleanup
    rm -rf $OUTDIR/$sample/
    
    echo "$sample done - $(date)"
done

echo "All done"
