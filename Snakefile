# ============================================
# Snakefile - TFM Microbiome Pipeline
# Paula Arzuza Jaimes - Universidad Alfonso X el Sabio
# Reproducible pipeline for taxonomic characterization
# of plant-associated microbiomes
# Usage:
#   snakemake --configfile config/config_arabidopsis.yaml --cores 4
#   snakemake --configfile config/config_tomato.yaml --cores 4
# ============================================

import os

# Load rules
include: "workflow/rules/fastp.smk"
include: "workflow/rules/dehosting.smk"
include: "workflow/rules/kraken2.smk"
include: "workflow/rules/metaphlan4.smk"
include: "workflow/rules/centrifuge.smk"

# Convenience variables
SAMPLES = list(config["samples"].keys())
SPECIES = config["species"]
RESULTS = config["results_dir"]

def get_all_outputs():
    outputs = []

    # fastp outputs
    outputs.extend(
        expand(os.path.join(RESULTS, f"trimming_{SPECIES}",
               "{sample}_1_clean.fastq.gz"), sample=SAMPLES)
    )

    # dehosting outputs
    outputs.extend(
        expand(os.path.join(RESULTS, f"dehosting_{SPECIES}",
               "{sample}_microbial_1.fastq.gz"), sample=SAMPLES)
    )

    # Kraken2 + Bracken outputs
    outputs.extend(
        expand(os.path.join(RESULTS, f"kraken2_{SPECIES}",
               "{sample}_kraken2_report.txt"), sample=SAMPLES)
    )
    outputs.extend(
        expand(os.path.join(RESULTS, f"kraken2_{SPECIES}",
               "{sample}_bracken_species.txt"), sample=SAMPLES)
    )
    outputs.extend(
        expand(os.path.join(RESULTS, f"kraken2_{SPECIES}",
               "{sample}_bracken_genus.txt"), sample=SAMPLES)
    )

    # MetaPhlAn4 outputs
    outputs.append(
        os.path.join(RESULTS, f"metaphlan4_{SPECIES}",
                     f"merged_metaphlan4_{SPECIES}.txt")
    )

    # Centrifuge outputs
    outputs.extend(
        expand(os.path.join(RESULTS, f"centrifuge_{SPECIES}",
               "{sample}_centrifuge_kreport.txt"), sample=SAMPLES)
    )

    # Optional R analysis
    if config.get("run_r_analysis", False):
        outputs.extend([
            os.path.join(RESULTS, f"diversity_{SPECIES}",
                         f"alpha_diversity_shannon_{SPECIES}.png"),
            os.path.join(RESULTS, f"diversity_{SPECIES}",
                         f"classifier_performance_summary_{SPECIES}.csv"),
        ])

    return outputs

rule all:
    input:
        get_all_outputs()

# Optional R analysis rules
if config.get("run_r_analysis", False):
    rule r_analysis:
        input:
            merged = os.path.join(RESULTS, f"metaphlan4_{SPECIES}",
                                   f"merged_metaphlan4_{SPECIES}.txt"),
            kraken_done = expand(os.path.join(RESULTS, f"kraken2_{SPECIES}",
                                  "{sample}_bracken_genus.txt"), sample=SAMPLES),
            centrifuge_done = expand(os.path.join(RESULTS, f"centrifuge_{SPECIES}",
                                      "{sample}_centrifuge_kreport.txt"), sample=SAMPLES)
        output:
            alpha = os.path.join(RESULTS, f"diversity_{SPECIES}",
                                  f"alpha_diversity_shannon_{SPECIES}.png"),
            perf = os.path.join(RESULTS, f"diversity_{SPECIES}",
                                 f"classifier_performance_summary_{SPECIES}.csv")
        params:
            species = SPECIES
        shell:
            """
            mkdir -p {RESULTS}/diversity_{params.species}
            Rscript ~/tfm_microbioma/notebooks/analysis_microbiome_{params.species}.R
            Rscript ~/tfm_microbioma/notebooks/comparison_classifiers_{params.species}.R
            Rscript ~/tfm_microbioma/notebooks/taxonomy_analysis_{params.species}.R
            Rscript ~/tfm_microbioma/notebooks/classifier_performance_{params.species}.R
            """
