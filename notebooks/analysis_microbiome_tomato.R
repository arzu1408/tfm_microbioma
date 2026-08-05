# ============================================
# Script 1 - Tomato Alpha/Beta Diversity
# Paula Arzuza Jaimes
# PRJNA766489 - Healthy vs Diseased rhizosphere
# ============================================

library(phyloseq)
library(ggplot2)
library(vegan)

# ============================================
# 1. LOAD DATA
# ============================================

merged_file <- "/mnt/d/tfm_data/results/metaphlan4_tomato/merged_metaphlan4_tomato.txt"

metaphlan_raw <- read.table(merged_file,
                             header = TRUE,
                             sep = "\t",
                             skip = 1,
                             comment.char = "",
                             quote = "")

colnames(metaphlan_raw)[1] <- "clade_name"

# species level only
metaphlan_species <- metaphlan_raw[grepl("s__", metaphlan_raw$clade_name) &
                                     !grepl("t__", metaphlan_raw$clade_name), ]
rownames(metaphlan_species) <- metaphlan_species$clade_name
metaphlan_species <- metaphlan_species[, -1]

cat("Species detected:", nrow(metaphlan_species), "\n")

# fix column order: Diseased first (614,615,616), Healthy (617,618,619)
# reorder to: Healthy first then Diseased for consistency with Arabidopsis
metaphlan_species <- metaphlan_species[, c(
  "SRR16079617_metaphlan4",
  "SRR16079618_metaphlan4",
  "SRR16079619_metaphlan4",
  "SRR16079614_metaphlan4",
  "SRR16079615_metaphlan4",
  "SRR16079616_metaphlan4"
)]

# ============================================
# 2. BUILD PHYLOSEQ OBJECT
# ============================================

otu_mat <- as.matrix(metaphlan_species)

sample_data_df <- data.frame(
  sample = c("SRR16079617_metaphlan4", "SRR16079618_metaphlan4", "SRR16079619_metaphlan4",
             "SRR16079614_metaphlan4", "SRR16079615_metaphlan4", "SRR16079616_metaphlan4"),
  condition = c("Healthy", "Healthy", "Healthy",
                "Diseased", "Diseased", "Diseased"),
  row.names = c("SRR16079617_metaphlan4", "SRR16079618_metaphlan4", "SRR16079619_metaphlan4",
                "SRR16079614_metaphlan4", "SRR16079615_metaphlan4", "SRR16079616_metaphlan4")
)

OTU <- otu_table(otu_mat, taxa_are_rows = TRUE)
SAMP <- sample_data(sample_data_df)
physeq <- phyloseq(OTU, SAMP)

cat("Phyloseq object created\n")

# ============================================
# 3. ALPHA DIVERSITY - Shannon
# ============================================

alpha_div <- estimate_richness(physeq, measures = c("Shannon"))
alpha_div$condition <- sample_data_df$condition
alpha_div$sample <- rownames(alpha_div)

cat("\nAlpha diversity (Shannon):\n")
print(alpha_div[, c("sample", "condition", "Shannon")])

cat("\nMean Shannon by condition:\n")
print(tapply(alpha_div$Shannon, alpha_div$condition, mean))

# Wilcoxon test
wilcox_result <- wilcox.test(
  alpha_div$Shannon[alpha_div$condition == "Healthy"],
  alpha_div$Shannon[alpha_div$condition == "Diseased"]
)
cat("\nWilcoxon test p-value:", wilcox_result$p.value, "\n")

# Plot
p_alpha <- ggplot(alpha_div, aes(x = condition, y = Shannon, fill = condition)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.1, size = 3) +
  scale_fill_manual(values = c("Healthy" = "#4CAF50", "Diseased" = "#F44336")) +
  labs(title = "Alpha Diversity (Shannon) - Tomato Rhizosphere",
       x = "Condition", y = "Shannon Index") +
  theme_bw() +
  theme(legend.position = "none")

ggsave("/mnt/d/tfm_data/results/diversity_tomato/alpha_diversity_shannon_tomato.png",
       p_alpha, width = 6, height = 5, dpi = 300)
cat("Alpha diversity plot saved\n")

# ============================================
# 4. BETA DIVERSITY - Bray-Curtis PCoA
# ============================================

bray_dist <- distance(physeq, method = "bray")
pcoa_result <- ordinate(physeq, method = "PCoA", distance = bray_dist)

p_beta <- plot_ordination(physeq, pcoa_result, color = "condition") +
  geom_point(size = 5) +
  scale_color_manual(values = c("Healthy" = "#4CAF50", "Diseased" = "#F44336")) +
  labs(title = "Beta Diversity (Bray-Curtis PCoA) - Tomato Rhizosphere") +
  theme_bw()

ggsave("/mnt/d/tfm_data/results/diversity_tomato/beta_diversity_pcoa_tomato.png",
       p_beta, width = 8, height = 6, dpi = 300)
cat("Beta diversity plot saved\n")

# ============================================
# 5. PERMANOVA
# ============================================

otu_df <- as.data.frame(t(otu_mat))
permanova_result <- adonis2(otu_df ~ condition,
                             data = sample_data_df,
                             permutations = 999,
                             method = "bray")

cat("\nPERMANOVA results:\n")
print(permanova_result)

# ============================================
# 6. TAXONOMIC COMPOSITION PHYLUM
# ============================================

metaphlan_phylum <- metaphlan_raw[grepl("p__", metaphlan_raw$clade_name) &
                                    !grepl("c__", metaphlan_raw$clade_name), ]
rownames(metaphlan_phylum) <- gsub(".*p__", "", metaphlan_phylum$clade_name)
metaphlan_phylum <- metaphlan_phylum[, -1]

phylum_means <- data.frame(
  phylum = rownames(metaphlan_phylum),
  Healthy = rowMeans(metaphlan_phylum[, c("SRR16079617_metaphlan4",
                                           "SRR16079618_metaphlan4",
                                           "SRR16079619_metaphlan4")]),
  Diseased = rowMeans(metaphlan_phylum[, c("SRR16079614_metaphlan4",
                                            "SRR16079615_metaphlan4",
                                            "SRR16079616_metaphlan4")])
)

library(reshape2)
phylum_melt <- melt(phylum_means, id.vars = "phylum",
                     variable.name = "condition", value.name = "abundance")
phylum_melt <- phylum_melt[phylum_melt$abundance > 0.1, ]

p_phylum <- ggplot(phylum_melt, aes(x = reorder(phylum, -abundance),
                                     y = abundance, fill = condition)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Healthy" = "#4CAF50", "Diseased" = "#F44336")) +
  labs(title = "Phylum Composition - Tomato Rhizosphere",
       x = "Phylum", y = "Mean Relative Abundance (%)",
       fill = "Condition") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("/mnt/d/tfm_data/results/diversity_tomato/taxonomic_composition_phylum_tomato.png",
       p_phylum, width = 10, height = 6, dpi = 300)
cat("Phylum composition plot saved\n")

cat("\nScript 1 complete!\n")
