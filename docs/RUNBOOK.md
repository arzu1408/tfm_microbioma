# RUNBOOK — TFM Microbiome Pipeline
**Paula Arzuza Jaimes — Universidad Alfonso X el Sabio**  
**Máster en Bioinformática — 2026**

Pipeline bioinformático reproducible para la caracterización taxonómica de microbiomas asociados a *Arabidopsis thaliana* y *Solanum lycopersicum* mediante secuenciación shotgun.

---

## 1. Requisitos del sistema

| Componente | Mínimo recomendado |
|---|---|
| RAM | 16GB (WSL2 configurado a 14GB) |
| Almacenamiento | ~200GB libres en disco externo |
| SO | Ubuntu 22.04+ / WSL2 |
| Python | ≥3.8 |
| R | ≥4.2 |

### Configuración WSL2 (Windows)
Archivo `C:\Users\<usuario>\.wslconfig`:
```ini
[wsl2]
memory=14GB
swap=8GB
processors=4
```

---

## 2. Instalación del entorno

```bash
# Clonar repositorio
git clone https://github.com/arzu1408/tfm_microbioma.git
cd tfm_microbioma

# Crear entorno conda
conda env create -f environment.yml
conda activate tfm_microbioma
```

---

## 3. Bases de datos requeridas

Las bases de datos deben descargarse manualmente antes de ejecutar el pipeline.

| Base de datos | Herramienta | Tamaño | Ruta esperada |
|---|---|---|---|
| k2_standard_08_GB_20260226 | Kraken2/Bracken | ~5.5GB | `/mnt/d/tfm_data/data/db/kraken2/` |
| mpa_vOct22_CHOCOPhlAnSGB_202403 | MetaPhlAn4 | ~18GB | `/mnt/d/tfm_data/data/db/metaphlan4/` |
| p_compressed+h+v | Centrifuge | ~5.7GB | `/mnt/d/tfm_data/data/db/centrifuge/` |

### Descarga Kraken2:
```bash
kraken2-build --download-library bacteria \
  --db /mnt/d/tfm_data/data/db/kraken2
```

### Descarga MetaPhlAn4:
```bash
metaphlan --install \
  --bowtie2db /mnt/d/tfm_data/data/db/metaphlan4 \
  --index mpa_vOct22_CHOCOPhlAnSGB_202403
```

### Descarga Centrifuge:
```bash
wget https://genome-idx.s3.amazonaws.com/centrifuge/p_compressed+h+v.tar.gz
tar -xvzf p_compressed+h+v.tar.gz -C /mnt/d/tfm_data/data/db/centrifuge/
```

---

## 4. Genomas de referencia

### Arabidopsis thaliana (TAIR10.1):
```bash
mkdir -p /mnt/d/tfm_data/data/ref/tair10
cd /mnt/d/tfm_data/data/ref/tair10
wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/735/GCF_000001735.4_TAIR10.1/GCF_000001735.4_TAIR10.1_genomic.fna.gz"
gunzip GCF_000001735.4_TAIR10.1_genomic.fna.gz
mv GCF_000001735.4_TAIR10.1_genomic.fna TAIR10_genome.fna

bowtie2-build TAIR10_genome.fna tair10_index --threads 4
```

### Solanum lycopersicum (SLM_r2.1):
```bash
mkdir -p /mnt/d/tfm_data/data/ref/slm_r2
cd /mnt/d/tfm_data/data/ref/slm_r2
wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/036/512/215/GCF_036512215.1_SLM_r2.1/GCF_036512215.1_SLM_r2.1_genomic.fna.gz"
gunzip GCF_036512215.1_SLM_r2.1_genomic.fna.gz
mv GCF_036512215.1_SLM_r2.1_genomic.fna SLM_r2.1_genome.fna

bowtie2-build SLM_r2.1_genome.fna slm_r2_index --threads 4
```

---

## 5. Descarga de muestras

### Arabidopsis thaliana (PRJDB12268):
```bash
bash scripts/download_samples.sh
```

Muestras: DRR318378–DRR318383 (Wildtype Col-0 n=3, phr1phl1 mutant n=3)

### Solanum lycopersicum (PRJNA766489):
```bash
bash scripts/download_tomato_samples.sh
```

Muestras: SRR16079614–SRR16079616 (Diseased n=3), SRR16079617–SRR16079619 (Healthy n=3)

---

## 6. Ejecución del pipeline

### Mediante Snakemake (recomendado):

```bash
# Arabidopsis
snakemake --configfile config/config_arabidopsis.yaml \
          --cores 4

# Solanum lycopersicum
snakemake --configfile config/config_tomato.yaml \
          --cores 4
```

### Validación previa sin ejecutar (dry-run):
```bash
snakemake --configfile config/config_tomato.yaml \
          --cores 4 \
          --dry-run
```

### Análisis R opcional (si run_r_analysis: false en config):
```bash
# Arabidopsis
Rscript notebooks/analysis_microbiome.R
Rscript notebooks/comparison_classifiers.R
Rscript notebooks/taxonomy_analysis.R
Rscript notebooks/classifier_performance.R

# Tomato
Rscript notebooks/analysis_microbiome_tomato.R
Rscript notebooks/comparison_classifiers_tomato.R
Rscript notebooks/taxonomy_analysis_tomato.R
Rscript notebooks/classifier_performance_tomato.R
```

---

## 7. Tiempos de ejecución aproximados

Registrados en entorno WSL2 (Intel 13th gen, 14GB RAM):

| Paso | Arabidopsis (6 muestras) | Tomate (6 muestras) |
|---|---|---|
| fastp | ~2h | ~30min |
| Bowtie2 dehosting | ~3h | ~45min |
| Kraken2 + Bracken | ~1h | ~20min |
| MetaPhlAn4 | ~12h | ~10h |
| Centrifuge | ~1h | ~3.5h |
| R analysis | ~5min | ~5min |
| **Total** | **~20h** | **~15h** |

> Nota: Las diferencias de tiempo reflejan la mayor profundidad de secuenciación de las muestras de *Arabidopsis* (~8.65-10.52G bases/muestra) respecto a las de tomate (~2.0-2.7G bases/muestra), no diferencias en el tamaño del genoma de referencia.

---

## 8. Estructura de resultados
/mnt/d/tfm_data/results/
├── trimming_arabidopsis/ # fastp outputs Arabidopsis
├── trimming_tomato/ # fastp outputs Tomato
├── dehosting_arabidopsis/ # Bowtie2 outputs Arabidopsis
├── dehosting_tomato/ # Bowtie2 outputs Tomato
├── kraken2_arabidopsis/ # Kraken2 + Bracken Arabidopsis
├── kraken2_tomato/ # Kraken2 + Bracken Tomato
├── metaphlan4_arabidopsis/ # MetaPhlAn4 Arabidopsis
├── metaphlan4_tomato/ # MetaPhlAn4 Tomato
├── centrifuge_arabidopsis/ # Centrifuge Arabidopsis
├── centrifuge_tomato/ # Centrifuge Tomato
├── diversity/ # R analysis outputs Arabidopsis
└── diversity_tomato/ # R analysis outputs Tomato

## 9. Problemas conocidos y soluciones

| Problema | Causa | Solución |
|---|---|---|
| `gzip: Operation not permitted` | Permisos WSL2 en disco externo NTFS | Ignorar — el archivo se descomprime correctamente a pesar del mensaje |
| `Failed to launch x86-64-v3 version` | CPU no soporta instrucciones AVX-512 | Ignorar — Bowtie2/MetaPhlAn4 usa versión por defecto sin efecto en resultados |
| MetaPhlAn4 se detiene a mitad | RAM insuficiente o screen session perdida | Verificar `memory=14GB` en `.wslconfig`; usar siempre screen para procesos largos |
| Screen session perdida | Terminal cerrada accidentalmente | Usar siempre `screen -S nombre`; verificar con `screen -ls` antes de asumir que falló |
| Git push pide credenciales | Token GitHub expirado | `git config --global credential.helper store` + generar nuevo token en GitHub Settings |
| `utime: Operation not permitted` durante descarga | Permisos NTFS en disco externo WSL2 | Ignorar — advertencia de metadatos, el archivo se descarga correctamente |
| `MultiQC shutil.Error: Operation not permitted` | MultiQC intenta escribir temporales en disco externo | `export TMPDIR=/tmp` antes de ejecutar MultiQC; output a `~/multiqc_output/` y luego copiar al disco externo |
| `fasterq-dump: disk-limit exceeded` | fasterq-dump necesita espacio temporal (~3x tamaño SRA) en disco interno | Usar `fastq-dump --gzip` — no necesita espacio temporal y escribe comprimido directamente |
| Descargas corruptas o incompletas | Script ejecutado dos veces simultáneamente o pérdida de conexión | Verificar tamaño con `ls -lh` y líneas con `zcat file.fastq.gz \| wc -l`; re-descargar solo muestras afectadas borrando archivos incompletos primero |
| `_bowtie2_stats.txt` de 0 bytes | Bowtie2 se interrumpió por cierre de terminal sin screen | Re-ejecutar solo la muestra afectada; verificar siempre con `grep "overall alignment rate"` |
| `microbiomeMarker` no instalable en R | Conflictos Bioconductor + conda | Reemplazar LEfSe con Wilcoxon + log2FC + volcano plot — resultados equivalentes para n=3 |
| Base de datos Kraken2 PlusPF (~80GB RAM) no viable | RAM insuficiente — sistema tiene 16GB | Usar Standard-8 (`k2_standard_08_GB_20260226`, ~8GB RAM); documentar como limitación en sección 3.4.1 |
| Disco externo no montado al iniciar screen | WSL2 no monta `/mnt/d` automáticamente en nuevas sesiones | Verificar con `ls /mnt/d/` antes de ejecutar scripts; montar con `sudo mount /mnt/d` si es necesario |
| Script completado sin crear archivos | Disco externo no montado cuando se inició el screen | Matar screen, verificar montaje del disco, reiniciar en nuevo screen |
| R: warning sobre singletons en estimate_richness | MetaPhlAn4 produce abundancias relativas, no conteos enteros | Usar solo Shannon (no Chao1); documentar en Metodología 4.5 |
| Wilcoxon p-value mínimo = 0.1 con n=3 vs n=3 | Solo 20 combinaciones posibles de rangos | Reportar como tendencias exploratorias; p=0.0636 en tomate indica separación perfecta entre grupos |
| `git tag already exists` | Tag ya creado en commit anterior | Ignorar si el tag ya apunta al commit correcto; usar `git tag -f` solo si necesitas moverlo |
| Conda no activada dentro de screen | Script sin `source conda.sh` al inicio | Añadir siempre `source ~/miniconda3/etc/profile.d/conda.sh` y `conda activate tfm_microbioma` al inicio de cada script |

## 10. Control de versiones

| Tag | Contenido |
|---|---|
| v0.1 | Descarga muestras Arabidopsis |
| v0.2 | FastQC + fastp Arabidopsis |
| v0.3 | Dehosting Arabidopsis |
| v0.4 | Kraken2 + Bracken Arabidopsis |
| v0.5 | MetaPhlAn4 Arabidopsis |
| v0.6 | Centrifuge Arabidopsis |
| v0.7 | R analysis completo Arabidopsis |
| v0.8 | Descarga + referencia Tomato |
| v0.9 | Pipeline completo + R analysis Tomato |
| v0.10 | Snakemake automation |
| v0.11 | Runbook |
