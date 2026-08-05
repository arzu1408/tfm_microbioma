# ============================================
# Script 3 - Tomato Taxonomy Analysis
# Paula Arzuza Jaimes
# ============================================

library(ggplot2)
library(reshape2)

merged_file <- "/mnt/d/tfm_data/results/metaphlan4_tomato/merged_metaphlan4_tomato.txt"

metaphlan_raw <- read.table(merged_file,
                             header = TRUE,
                             sep = "\t",
                             skip = 1,
                             comment.char = "",
                             quote = "")
colnames(metaphlan_raw)[1] <- "clade_name"

# ============================================
# 1. TOP PHYLA
# ============================================

metaphlan_phylum <- metaphlan_raw[grepl("p__", metaphlan_raw$clade_name) &
                                    !grepl("c__", metaphlan_raw$clade_name), ]
rownames(metaphlan_phylum) <- gsub(".*p__", "", metaphlan_phylum$clade_name)
metaphlan_phylum <- metaphlan_phylum[, -1]

phylum_means <- rowMeans(metaphlan_phylum)
top_phyla <- sort(phylum_means, decreasing = TRUE)[1:min(10, length(phylum_means))]

top_phyla_df <- data.frame(
  phylum = names(top_phyla),
  Healthy = rowMeans(metaphlan_phylum[names(top_phyla),
                     c("SRR16079617_metaphlan4", "SRR16079618_metaphlan4",
                       "SRR16079619_metaphlan4")]),
  Diseased = rowMeans(metaphlan_phylum[names(top_phyla),
                      c("SRR16079614_metaphlan4", "SRR16079615_metaphlan4",
                        "SRR16079616_metaphlan4")])
)

top_phyla_melt <- melt(top_phyla_df, id.vars = "phylum",
                        variable.name = "condition", value.name = "abundance")

p_phyla <- ggplot(top_phyla_melt, aes(x = reorder(phylum, -abundance),
                                       y = abundance, fill = condition)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Healthy" = "#4CAF50", "Diseased" = "#F44336")) +
  labs(title = "Top Phyla - Tomato Rhizosphere (Healthy vs Diseased)",
       x = "Phylum", y = "Mean Relative Abundance (%)", fill = "Condition") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("/mnt/d/tfm_data/results/diversity_tomato/top_phyla_tomato.png",
       p_phyla, width = 10, height = 6, dpi = 300)
cat("Top phyla plot saved\n")

# ============================================
# 2. TOP GENERA
# ============================================

metaphlan_genus <- metaphlan_raw[grepl("g__", metaphlan_raw$clade_name) &
                                   !grepl("s__", metaphlan_raw$clade_name), ]
rownames(metaphlan_genus) <- gsub(".*g__", "", metaphlan_genus$clade_name)
metaphlan_genus <- metaphlan_genus[, -1]

genus_means <- rowMeans(metaphlan_genus)
top_genera <- sort(genus_means, decreasing = TRUE)[1:min(20, length(genus_means))]

top_genera_df <- data.frame(
  genus = names(top_genera),
  Healthy = rowMeans(metaphlan_genus[names(top_genera),
                     c("SRR16079617_metaphlan4", "SRR16079618_metaphlan4",
                       "SRR16079619_metaphlan4")]),
  Diseased = rowMeans(metaphlan_genus[names(top_genera),
                      c("SRR16079614_metaphlan4", "SRR16079615_metaphlan4",
                        "SRR16079616_metaphlan4")])
)

top_genera_melt <- melt(top_genera_df, id.vars = "genus",
                         variable.name = "condition", value.name = "abundance")

p_genus <- ggplot(top_genera_melt, aes(x = reorder(genus, -abundance),
                                        y = abundance, fill = condition)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Healthy" = "#4CAF50", "Diseased" = "#F44336")) +
  labs(title = "Top 20 Genera - Tomato Rhizosphere (Healthy vs Diseased)",
       x = "Genus", y = "Mean Relative Abundance (%)", fill = "Condition") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, face = "italic"))

ggsave("/mnt/d/tfm_data/results/diversity_tomato/top_genera_tomato.png",
       p_genus, width = 12, height = 6, dpi = 300)
cat("Top genera plot saved\n")

# ============================================
# 3. DIFFERENTIAL ABUNDANCE - Wilcoxon
# ============================================

metaphlan_species <- metaphlan_raw[grepl("s__", metaphlan_raw$clade_name) &
                                     !grepl("t__", metaphlan_raw$clade_name), ]
rownames(metaphlan_species) <- metaphlan_species$clade_name
metaphlan_species <- metaphlan_species[, -1]

healthy_cols <- c("SRR16079617_metaphlan4", "SRR16079618_metaphlan4", "SRR16079619_metaphlan4")
diseased_cols <- c("SRR16079614_metaphlan4", "SRR16079615_metaphlan4", "SRR16079616_metaphlan4")

cat("\nDifferential abundance analysis (Wilcoxon test):\n")

pvalues <- apply(metaphlan_species, 1, function(x) {
  tryCatch(
    wilcox.test(as.numeric(x[healthy_cols]),
                as.numeric(x[diseased_cols]))$p.value,
    error = function(e) NA
  )
})

fc <- apply(metaphlan_species, 1, function(x) {
  healthy_mean <- mean(as.numeric(x[healthy_cols])) + 0.0001
  diseased_mean <- mean(as.numeric(x[diseased_cols])) + 0.0001
  log2(diseased_mean / healthy_mean)
})

diff_results <- data.frame(
  species = gsub(".*s__", "", rownames(metaphlan_species)),
  log2FC = round(fc, 3),
  pvalue = round(pvalues, 4),
  healthy_mean = round(rowMeans(metaphlan_species[, healthy_cols]), 4),
  diseased_mean = round(rowMeans(metaphlan_species[, diseased_cols]), 4)
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
  labs(title = "Differential Abundance - Healthy vs Diseased Tomato Rhizosphere",
       x = "Log2 Fold Change (Diseased/Healthy)",
       y = "-log10(p-value)",
       color = "p < 0.05") +
  theme_bw()

ggsave("/mnt/d/tfm_data/results/diversity_tomato/differential_abundance_tomato.png",
       p_volcano, width = 8, height = 6, dpi = 300)
cat("Differential abundance plot saved\n")

write.csv(diff_results,
          "/mnt/d/tfm_data/results/diversity_tomato/differential_abundance_results_tomato.csv",
          row.names = FALSE)
cat("Results table saved\n")
cat("\nScript 3 complete!\n")
