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
    
    # Download and verify
    echo "Downloading $sample..."
    prefetch $sample \
        --output-directory $OUTDIR \
        --verify yes \
        --progress
    
    # Check download size
    echo "SRA file size:"
    ls -lh $OUTDIR/$sample/$sample.sra
    
    # Convert only if sra file is complete
    echo "Converting $sample..."
    fastq-dump $OUTDIR/$sample/$sample.sra \
        --outdir $OUTDIR \
        --split-files \
        --gzip
    
    # Verify output
    echo "Output sizes:"
    ls -lh $OUTDIR/${sample}_*.fastq.gz
    
    # Cleanup
    rm -rf $OUTDIR/$sample/
    
    echo "$sample done - $(date)"
done

echo "All done"
