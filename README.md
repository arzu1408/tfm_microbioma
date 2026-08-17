# Pipeline bioinformático para caracterización taxonómica de microbiomas de plantas

TFM — Máster en Bioinformática
Universidad: UAX (Universidad Alfonso X el Sabio)
Autora: Paula Arzuza Jaimes
Año: 2026

## Descripción

Pipeline bioinformático automatizado y reproducible para la caracterización
taxonómica de comunidades microbianas asociadas a Arabidopsis thaliana y
Solanum lycopersicum mediante secuenciación metagenómica shotgun.

Integra control de calidad, eliminación de ADN del hospedador y clasificación
taxonómica comparativa con tres herramientas independientes (Kraken2/Bracken,
MetaPhlAn4 y Centrifuge), con automatización mediante Snakemake.

## Organismos y genomas de referencia

| Organismo              | Referencia | Accesión NCBI       | Tamaño  |
|------------------------|------------|---------------------|---------|
| Arabidopsis thaliana   | TAIR10.1   | GCF_000001735.4     | ~135 Mb |
| Solanum lycopersicum   | SLM_r2.1   | GCF_036512215.1     | ~844 Mb |

## Datasets utilizados

| Proyecto     | Organismo             | Condiciones                                      | Muestras |
|--------------|-----------------------|--------------------------------------------------|----------|
| PRJDB12268   | Arabidopsis thaliana  | Wildtype Col-0 vs phr1phl1 mutant                | 6        |
| PRJNA766489  | Solanum lycopersicum  | Healthy vs Diseased rhizosphere (powdery mildew) | 6        |

## Herramientas principales

| Herramienta  | Uso                           |
|--------------|-------------------------------|
| FastQC       | Evaluación de calidad         |
| fastp        | Trimming y preprocesamiento   |
| MultiQC      | Agregación de informes QC     |
| Bowtie2      | Eliminación del hospedador    |
| Kraken2      | Clasificación taxonómica      |
| Bracken      | Estimación de abundancias     |
| MetaPhlAn4   | Clasificación taxonómica      |
| Centrifuge   | Clasificación taxonómica      |
| Snakemake    | Automatización del pipeline   |
| R            | Análisis estadístico          |

## Requisitos del sistema

- RAM: mínimo 16GB (WSL2 configurado a 14GB; base de datos Standard-8 requiere ~8GB)
- Almacenamiento: mínimo 200GB libres en disco externo
- CPU: recomendado 4+ cores
- Sistema operativo: Linux / WSL2 Ubuntu 22.04+

## Instalación

### 1. Clonar el repositorio

git clone https://github.com/arzu1408/tfm_microbioma.git
cd tfm_microbioma

### 2. Crear el entorno conda

conda env create -f environment.yml
conda activate tfm_microbioma

### 3. Descargar bases de datos y genomas de referencia

Ver instrucciones detalladas en docs/RUNBOOK.md

## Ejecución

### Dry-run (verificar sin ejecutar)

snakemake --configfile config/config_arabidopsis.yaml --cores 4 --dry-run
snakemake --configfile config/config_tomato.yaml --cores 4 --dry-run

### Ejecutar pipeline completo

# Arabidopsis thaliana
snakemake --configfile config/config_arabidopsis.yaml --cores 4

# Solanum lycopersicum
snakemake --configfile config/config_tomato.yaml --cores 4

## Resultados principales

| Métrica                            | A. thaliana             | S. lycopersicum         |
|------------------------------------|-------------------------|-------------------------|
| ADN hospedador eliminado (media)   | 73.66%                  | 0.11%                   |
| Clasificación Kraken2 (media)      | 0.81%                   | 0.37%                   |
| Clasificación Centrifuge (media)   | 33.59%                  | 28.96%                  |
| Phylum dominante (MetaPhlAn4)      | Proteobacteria (94.75%) | Actinobacteria (81.93%) |
| PERMANOVA R²                       | 0.1496                  | 0.7352                  |
| Spearman r (Kraken2 vs Centrifuge) | 0.598                   | 0.689                   |

## Estructura del repositorio

tfm_microbioma/
├── environment.yml              # entorno conda
├── environment_locked.yml       # versiones exactas resueltas por conda
├── README.md
├── Snakefile                    # pipeline principal
├── config/
│   ├── config_arabidopsis.yaml  # parámetros para A. thaliana
│   └── config_tomato.yaml       # parámetros para S. lycopersicum
├── workflow/
│   └── rules/                   # reglas Snakemake modulares
├── scripts/                     # scripts bash del pipeline
├── notebooks/                   # scripts R de análisis estadístico
├── docs/
│   └── RUNBOOK.md               # instrucciones detalladas de ejecución
├── LICENSE                      # MIT License
└── .gitignore

## Documentación

Ver docs/RUNBOOK.md para instrucciones detalladas de instalación, configuración
de bases de datos, ejecución del pipeline y resolución de problemas.

## Licencia

MIT License — ver LICENSE para más detalles.

## Referencia

Paula Arzuza Jaimes (2026). Desarrollo y evaluación de un pipeline bioinformático
reproducible para la caracterización taxonómica de microbiomas asociados a
Arabidopsis thaliana y Solanum lycopersicum mediante secuenciación shotgun.
TFM, Máster en Bioinformática, Universidad Alfonso X el Sabio.
