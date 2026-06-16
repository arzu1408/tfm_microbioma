# ============================================
# Script 3 - Taxonomy Analysis + LEfSe
# Paula Arzuza Jaimes
# ============================================

library(phyloseq)
library(ggplot2)
library(vegan)

# ============================================
# 1. RELOAD PHYLOSEQ OBJECT
# ============================================

metadata <- read.csv("/home/paula/tfm_microbioma/config/sample_metadata.csv",
                     row.names = 1)
metadata$condition <- factor(metadata$condition,
                             levels = c("wildtype_Col0", "phr1phl1_mutant"))

metaphlan <- read.table(
  "/mnt/d/tfm_data/results/metaphlan4/merged_metaphlan4_table.txt",
  header = TRUE, sep = "\t", skip = 1, row.names = 1)

colnames(metaphlan) <- gsub("_metaphlan4", "", colnames(metaphlan))

# phylum level
metaphlan_phylum <- metaphlan[grepl("p__", rownames(metaphlan)) &
                               !grepl("c__", rownames(metaphlan)), ]

# genus level
metaphlan_genus <- metaphlan[grepl("g__", rownames(metaphlan)) &
                              !grepl("s__", rownames(metaphlan)), ]

# species level
metaphlan_species <- metaphlan[grepl("s__", rownames(metaphlan)) &
                                !grepl("t__", rownames(metaphlan)), ]

cat("Phyla detected:", nrow(metaphlan_phylum), "\n")
cat("Genera detected:", nrow(metaphlan_genus), "\n")
cat("Species detected:", nrow(metaphlan_species), "\n")

# ============================================
# 2. TOP 10 PHYLA
# ============================================

phylum_means <- rowMeans(metaphlan_phylum)
top10_phyla <- names(sort(phylum_means, decreasing=TRUE)[1:min(10, length(phylum_means))])

phylum_top <- metaphlan_phylum[top10_phyla, ]

# clean names
clean_names <- gsub(".*p__", "", rownames(phylum_top))
rownames(phylum_top) <- clean_names

phylum_df <- data.frame(
  phylum = rownames(phylum_top),
  wildtype = rowMeans(phylum_top[, 1:3]),
  mutant = rowMeans(phylum_top[, 4:6])
)

phylum_melt <- reshape(phylum_df, 
                        varying = c("wildtype", "mutant"),
                        v.names = "abundance",
                        timevar = "condition",
                        times = c("Wildtype Col-0", "phr1phl1 mutant"),
                        direction = "long")

p_phylum <- ggplot(phylum_melt, aes(x = reorder(phylum, -abundance), 
                                     y = abundance, fill = condition)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Wildtype Col-0" = "#2196F3",
                                "phr1phl1 mutant" = "#F44336")) +
  labs(title = "Top Phyla - Mean Relative Abundance",
       x = "Phylum", y = "Mean Relative Abundance (%)",
       fill = "Condition") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("/mnt/d/tfm_data/results/diversity/top_phyla.png",
       p_phylum, width = 10, height = 6, dpi = 300)
cat("Top phyla plot saved\n")

# ============================================
# 3. TOP 20 GENERA
# ============================================

genus_means <- rowMeans(metaphlan_genus)
top20_genera <- names(sort(genus_means, decreasing=TRUE)[1:min(20, length(genus_means))])

genus_top <- metaphlan_genus[top20_genera, ]
clean_genus <- gsub(".*g__", "", rownames(genus_top))
rownames(genus_top) <- clean_genus

genus_df <- data.frame(
  genus = rownames(genus_top),
  wildtype = rowMeans(genus_top[, 1:3]),
  mutant = rowMeans(genus_top[, 4:6])
)

genus_melt <- reshape(genus_df,
                       varying = c("wildtype", "mutant"),
                       v.names = "abundance",
                       timevar = "condition",
                       times = c("Wildtype Col-0", "phr1phl1 mutant"),
                       direction = "long")

p_genus <- ggplot(genus_melt, aes(x = reorder(genus, -abundance),
                                   y = abundance, fill = condition)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Wildtype Col-0" = "#2196F3",
                                "phr1phl1 mutant" = "#F44336")) +
  labs(title = "Top 20 Genera - Mean Relative Abundance",
       x = "Genus", y = "Mean Relative Abundance (%)",
       fill = "Condition") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, face = "italic"))

ggsave("/mnt/d/tfm_data/results/diversity/top_genera.png",
       p_genus, width = 12, height = 6, dpi = 300)
cat("Top genera plot saved\n")

# ============================================
# 4. LEFSE - DIFFERENTIAL ABUNDANCE
# ============================================


cat("\nDifferential abundance analysis (Wilcoxon test):\n")

pvalues <- apply(metaphlan_species, 1, function(x) {
  tryCatch(
    wilcox.test(as.numeric(x[1:3]), as.numeric(x[4:6]))$p.value,
    error = function(e) NA
  )
})

fc <- apply(metaphlan_species, 1, function(x) {
  wt_mean <- mean(as.numeric(x[1:3])) + 0.0001
  mut_mean <- mean(as.numeric(x[4:6])) + 0.0001
  log2(mut_mean / wt_mean)
})

diff_results <- data.frame(
  species = gsub(".*s__", "", rownames(metaphlan_species)),
  log2FC = round(fc, 3),
  pvalue = round(pvalues, 4),
  wildtype_mean = round(rowMeans(metaphlan_species[, 1:3]), 4),
  mutant_mean = round(rowMeans(metaphlan_species[, 4:6]), 4)
)

diff_results <- diff_results[order(diff_results$pvalue), ]
diff_results <- diff_results[!is.na(diff_results$pvalue), ]

cat("Top 10 differentially abundant species:\n")
print(head(diff_results, 10))

diff_results$significant <- diff_results$pvalue < 0.05

p_volcano <- ggplot(diff_results, aes(x = log2FC, y = -log10(pvalue),
                                       color = significant)) +
  geom_point(size = 2, alpha = 0.7) +
  scale_color_manual(values = c("FALSE" = "grey", "TRUE" = "#F44336")) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "grey50") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey50") +
  labs(title = "Differential Abundance - Wildtype vs phr1phl1",
       x = "Log2 Fold Change (mutant/wildtype)",
       y = "-log10(p-value)",
       color = "p < 0.05") +
  theme_bw()

ggsave("/mnt/d/tfm_data/results/diversity/differential_abundance.png",
       p_volcano, width = 8, height = 6, dpi = 300)

cat("Differential abundance plot saved\n")

write.csv(diff_results,
          "/mnt/d/tfm_data/results/diversity/differential_abundance_results.csv",
          row.names = FALSE)

cat("Results table saved\n")
cat("\nScript 3 complete!\n")
