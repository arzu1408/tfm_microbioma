# ============================================
# Rule: kraken2 - taxonomic classification
# ============================================

rule kraken2:
    input:
        r1 = os.path.join(config["results_dir"],
            "dehosting_{species}", "{sample}_microbial_1.fastq.gz"),
        r2 = os.path.join(config["results_dir"],
            "dehosting_{species}", "{sample}_microbial_2.fastq.gz")
    output:
        report = os.path.join(config["results_dir"],
            "kraken2_{species}", "{sample}_kraken2_report.txt"),
        output = os.path.join(config["results_dir"],
            "kraken2_{species}", "{sample}_kraken2_output.txt")
    params:
        db = config["kraken2_db"],
        confidence = config["kraken2_confidence"]
    threads: 4
    log:
        os.path.join(config["results_dir"],
            "logs", "kraken2_{species}", "{sample}.log")
    shell:
        """
        kraken2 \
          --db {params.db} \
          --paired {input.r1} {input.r2} \
          --output {output.output} \
          --report {output.report} \
          --confidence {params.confidence} \
          --threads {threads} \
          --gzip-compressed \
          2> {log}
        """

rule bracken_species:
    input:
        report = os.path.join(config["results_dir"],
            "kraken2_{species}", "{sample}_kraken2_report.txt")
    output:
        bracken = os.path.join(config["results_dir"],
            "kraken2_{species}", "{sample}_bracken_species.txt"),
        report = os.path.join(config["results_dir"],
            "kraken2_{species}", "{sample}_bracken_species_report.txt")
    params:
        db = config["kraken2_db"],
        read_len = config["bracken_read_length"],
        threshold = config["bracken_threshold"]
    shell:
        """
        bracken \
          -d {params.db} \
          -i {input.report} \
          -o {output.bracken} \
          -w {output.report} \
          -r {params.read_len} \
          -l S \
          -t {params.threshold}
        """

rule bracken_genus:
    input:
        report = os.path.join(config["results_dir"],
            "kraken2_{species}", "{sample}_kraken2_report.txt")
    output:
        bracken = os.path.join(config["results_dir"],
            "kraken2_{species}", "{sample}_bracken_genus.txt"),
        report = os.path.join(config["results_dir"],
            "kraken2_{species}", "{sample}_bracken_genus_report.txt")
    params:
        db = config["kraken2_db"],
        read_len = config["bracken_read_length"],
        threshold = config["bracken_threshold"]
    shell:
        """
        bracken \
          -d {params.db} \
          -i {input.report} \
          -o {output.bracken} \
          -w {output.report} \
          -r {params.read_len} \
          -l G \
          -t {params.threshold}
        """
