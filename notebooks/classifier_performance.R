# ============================================
# Script 4 - Classifier Performance Metrics
# Paula Arzuza Jaimes
# ============================================

samples <- c("DRR318378", "DRR318379", "DRR318380",
             "DRR318381", "DRR318382", "DRR318383")
condition <- c("Wildtype", "Wildtype", "Wildtype",
               "phr1phl1", "phr1phl1", "phr1phl1")

# ============================================
# 1. KRAKEN2 - extract classification stats
# ============================================

get_kraken_stats <- function(sample) {
  f <- paste0("/mnt/d/tfm_data/results/kraken2/", sample, "_kraken2_report.txt")
  df <- read.table(f, header = FALSE, sep = "\t", quote = "")
  colnames(df) <- c("pct", "reads", "direct", "rank", "taxid", "name")
  unclassified_pct <- df[df$rank == "U", "pct"][1]
  total_reads <- df[df$rank == "U", "reads"][1] / (unclassified_pct/100)
  classified_pct <- 100 - unclassified_pct
  data.frame(sample = sample, total_reads = round(total_reads),
             classified_pct = round(classified_pct, 2))
}

kraken_stats <- do.call(rbind, lapply(samples, get_kraken_stats))
cat("Kraken2 stats:\n")
print(kraken_stats)

# ============================================
# 2. CENTRIFUGE - extract classification stats
# ============================================

get_centrifuge_stats <- function(sample) {
  f <- paste0("/mnt/d/tfm_data/results/centrifuge/", sample, "_centrifuge_kreport.txt")
  df <- read.table(f, header = FALSE, sep = "\t", quote = "")
  colnames(df) <- c("pct", "reads", "direct", "rank", "taxid", "name")
  unclassified_pct <- df[df$rank == "U", "pct"][1]
  classified_pct <- 100 - unclassified_pct
  data.frame(sample = sample, classified_pct = round(classified_pct, 2))
}

centrifuge_stats <- do.call(rbind, lapply(samples, get_centrifuge_stats))
cat("\nCentrifuge stats:\n")
print(centrifuge_stats)

# ============================================
# 3. BUILD SUMMARY TABLE
# ============================================

summary_table <- data.frame(
  sample = samples,
  condition = condition,
  kraken2_pct = kraken_stats$classified_pct,
  centrifuge_pct = centrifuge_stats$classified_pct
)

cat("\n=== FINAL SUMMARY TABLE ===\n")
print(summary_table)

cat("\nMean classification rates:\n")
cat("Kraken2:", round(mean(summary_table$kraken2_pct), 2), "%\n")
cat("Centrifuge:", round(mean(summary_table$centrifuge_pct), 2), "%\n")

write.csv(summary_table,
          "/mnt/d/tfm_data/results/diversity/classifier_performance_summary.csv",
          row.names = FALSE)

cat("\nSummary table saved\n")
cat("Script 4 complete!\n")
