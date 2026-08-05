# ============================================
# Rule: fastp - adapter trimming and QC
# ============================================

rule fastp:
    input:
        r1 = lambda wildcards: os.path.join(
            config["raw_data_dir"],
            f"{wildcards.sample}_1.fastq.gz"
        ),
        r2 = lambda wildcards: os.path.join(
            config["raw_data_dir"],
            f"{wildcards.sample}_2.fastq.gz"
        )
    output:
        r1 = os.path.join(config["results_dir"],
            "trimming_{species}", "{sample}_1_clean.fastq.gz"),
        r2 = os.path.join(config["results_dir"],
            "trimming_{species}", "{sample}_2_clean.fastq.gz"),
        json = os.path.join(config["results_dir"],
            "trimming_{species}", "{sample}_fastp.json"),
        html = os.path.join(config["results_dir"],
            "trimming_{species}", "{sample}_fastp.html")
    params:
        adapter_r1 = config["adapters"]["r1"],
        adapter_r2 = config["adapters"]["r2"],
        trim_front = config["trim_front"],
        quality = config["quality_phred"],
        min_len = config["min_length"]
    threads: 4
    log:
        os.path.join(config["results_dir"],
            "logs", "fastp_{species}", "{sample}.log")
    shell:
        """
        fastp \
          -i {input.r1} -I {input.r2} \
          -o {output.r1} -O {output.r2} \
          --json {output.json} --html {output.html} \
          --adapter_sequence {params.adapter_r1} \
          --adapter_sequence_r2 {params.adapter_r2} \
          --trim_front1 {params.trim_front} \
          --trim_front2 {params.trim_front} \
          --qualified_quality_phred {params.quality} \
          --unqualified_percent_limit 40 \
          --length_required {params.min_len} \
          --thread {threads} \
          2> {log}
        """
