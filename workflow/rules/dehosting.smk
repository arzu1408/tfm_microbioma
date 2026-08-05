# ============================================
# Rule: dehosting - remove host DNA with Bowtie2
# ============================================

rule dehosting:
    input:
        r1 = os.path.join(config["results_dir"],
            "trimming_{species}", "{sample}_1_clean.fastq.gz"),
        r2 = os.path.join(config["results_dir"],
            "trimming_{species}", "{sample}_2_clean.fastq.gz")
    output:
        r1 = os.path.join(config["results_dir"],
            "dehosting_{species}", "{sample}_microbial_1.fastq.gz"),
        r2 = os.path.join(config["results_dir"],
            "dehosting_{species}", "{sample}_microbial_2.fastq.gz"),
        stats = os.path.join(config["results_dir"],
            "dehosting_{species}", "{sample}_bowtie2_stats.txt")
    params:
        index = config["bowtie2_index"],
        mode = config["bowtie2_mode"]
    threads: 4
    log:
        os.path.join(config["results_dir"],
            "logs", "dehosting_{species}", "{sample}.log")
    shell:
        """
        bowtie2 \
          -x {params.index} \
          -1 {input.r1} -2 {input.r2} \
          {params.mode} \
          --no-unal \
          -S /dev/null \
          --un-conc-gz {config[results_dir]}/dehosting_{wildcards.species}/{wildcards.sample}_microbial_%.fastq.gz \
          --threads {threads} \
          2> {output.stats}
        """
