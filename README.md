# Pipeline bioinformático para caracterización taxonómica de microbiomas de plantas

TFM — Máster en Bioinformática
Universidad: UAX
Autora: Paula Arzuza
Año: 2026

## Descripción

Pipeline bioinformático automatizado y reproducible para la caracterización
taxonómica de comunidades microbianas asociadas a Arabidopsis thaliana y
Solanum lycopersicum mediante secuenciación shotgun.

Integra control de calidad, eliminación de ADN del hospedador y clasificación
taxonómica con tres herramientas (Kraken2, MetaPhlAn4, Centrifuge).

## Organismos y genomas de referencia

| Organismo              | Referencia | Fuente         |
|------------------------|------------|----------------|
| Arabidopsis thaliana   | TAIR10     | Ensembl Plants |
| Solanum lycopersicum   | ITAG4.0    | Sol Genomics   |

## Herramientas principales

| Herramienta  | Uso                          |
|--------------|------------------------------|
| fastp        | Control de calidad y trimming|
| Bowtie2      | Eliminación del hospedador   |
| Kraken2      | Clasificación taxonómica     |
| MetaPhlAn4   | Clasificación taxonómica     |
| Centrifuge   | Clasificación taxonómica     |
| Bracken      | Estimación de abundancias    |
| Snakemake    | Automatización del pipeline  |

## Requisitos del sistema

- RAM: mínimo 64GB (bases de datos de Kraken2 requieren ~42-70GB)
- Almacenamiento: mínimo 300GB libres
- CPU: recomendado 8+ cores
- Sistema operativo: Linux (probado en Ubuntu 22.04)

## Instalación

### 1. Clonar el repositorio

git clone https://github.com/tu_usuario/tfm_microbioma.git
cd tfm_microbioma

### 2. Crear el entorno conda

conda env create -f environment.yml
conda activate tfm_microbioma

### 3. Descargar bases de datos

Ver instrucciones detalladas en docs/database_setup.md

## Datos utilizados

Datasets públicos descargados de NCBI SRA:

| Proyecto    | Organismo             | Tipo de muestra |
|-------------|-----------------------|-----------------|
| PRJNA434928 | Arabidopsis thaliana  | Rizobioma       |
| PRJNA415347 | Solanum lycopersicum  | Rizosfera       |

## Ejecución

### Dry-run (verificar sin ejecutar)

snakemake --use-conda --configfile config/config.yaml -n

### Ejecutar pipeline completo

snakemake --use-conda --cores 8 --configfile config/config.yaml

### Ejecutar solo hasta dehosting

snakemake --use-conda --cores 8 --until dehost_bowtie2

## Estructura del repositorio

tfm_microbioma/
├── environment.yml        # entorno conda
├── environment_locked.yml # versiones exactas resueltas por conda
├── README.md
├── config/
│   └── config.yaml        # parámetros del pipeline
├── workflow/
│   ├── Snakefile          # pipeline maestro
│   └── rules/             # reglas modulares
├── scripts/               # scripts R y Python
├── notebooks/             # análisis exploratorios
├── docs/                  # documentación adicional
├── results/               # resultados (no versionados en Git)
└── data/                  # datos (no versionados en Git)

## Resultados principales


