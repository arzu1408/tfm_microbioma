# ============================================
# Rule: centrifuge - BWT-based classification
# ============================================

rule centrifuge:
    input:
        r1 = os.path.join(config["results_dir"],
            "dehosting_{species}", "{sample}_microbial_1.fastq.gz"),
        r2 = os.path.join(config["results_dir"],
            "dehosting_{species}", "{sample}_microbial_2.fastq.gz")
    output:
        output = os.path.join(config["results_dir"],
            "centrifuge_{species}", "{sample}_centrifuge_output.txt"),
        report = os.path.join(config["results_dir"],
            "centrifuge_{species}", "{sample}_centrifuge_report.txt")
    params:
        db = config["centrifuge_db"]
    threads: 4
    log:
        os.path.join(config["results_dir"],
            "logs", "centrifuge_{species}", "{sample}.log")
    shell:
        """
        centrifuge \
          -x {params.db} \
          -1 {input.r1} -2 {input.r2} \
          -S {output.output} \
          --report-file {output.report} \
          -p {threads} \
          --mm \
          2> {log}
        """

rule centrifuge_kreport:
    input:
        output = os.path.join(config["results_dir"],
            "centrifuge_{species}", "{sample}_centrifuge_output.txt")
    output:
        kreport = os.path.join(config["results_dir"],
            "centrifuge_{species}", "{sample}_centrifuge_kreport.txt")
    params:
        db = config["centrifuge_db"]
    shell:
        """
        centrifuge-kreport \
          -x {params.db} \
          {input.output} \
          > {output.kreport}
        """
