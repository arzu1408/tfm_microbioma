# ============================================
# Rule: metaphlan4 - marker-based classification
# ============================================

rule metaphlan4:
    input:
        r1 = os.path.join(config["results_dir"],
            "dehosting_{species}", "{sample}_microbial_1.fastq.gz"),
        r2 = os.path.join(config["results_dir"],
            "dehosting_{species}", "{sample}_microbial_2.fastq.gz")
    output:
        profile = os.path.join(config["results_dir"],
            "metaphlan4_{species}", "{sample}_metaphlan4.txt"),
        bowtie2 = os.path.join(config["results_dir"],
            "metaphlan4_{species}", "{sample}_bowtie2.bz2")
    params:
        db = config["metaphlan4_db"],
        index = config["metaphlan4_index"]
    threads: 2
    log:
        os.path.join(config["results_dir"],
            "logs", "metaphlan4_{species}", "{sample}.log")
    shell:
        """
        metaphlan \
          {input.r1},{input.r2} \
          --input_type fastq \
          --bowtie2db {params.db} \
          --index {params.index} \
          --bowtie2out {output.bowtie2} \
          --nproc {threads} \
          --output_file {output.profile} \
          2> {log}
        """

rule merge_metaphlan4:
    input:
        expand(os.path.join(config["results_dir"],
            "metaphlan4_{{species}}", "{sample}_metaphlan4.txt"),
            sample=config["samples"])
    output:
        os.path.join(config["results_dir"],
            "metaphlan4_{species}", "merged_metaphlan4_{species}.txt")
    shell:
        """
        merge_metaphlan_tables.py {input} -o {output}
        """
