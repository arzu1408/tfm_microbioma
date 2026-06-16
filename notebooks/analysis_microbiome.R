# ============================================
# TFM Microbioma - R Analysis Script
# Paula Arzuza Jaimes
# Universidad Alfonso X el Sabio
# ============================================

library(phyloseq)
library(vegan)
library(ggplot2)

# ============================================
# 1. LOAD DATA
# ============================================

# Sample metadata
metadata <- read.csv("/home/paula/tfm_microbioma/config/sample_metadata.csv", 
                     row.names = 1)
metadata$condition <- factor(metadata$condition, 
                             levels = c("wildtype_Col0", "phr1phl1_mutant"))

cat("Metadata loaded:", nrow(metadata), "samples\n")

# ============================================
# 2. LOAD METAPHLAN4 RESULTS
# ============================================

metaphlan <- read.table(
  "/mnt/d/tfm_data/results/metaphlan4/merged_metaphlan4_table.txt",
  header = TRUE,
  sep = "\t",
  skip = 1,
  row.names = 1
)

# fix column names
colnames(metaphlan) <- gsub("_metaphlan4", "", colnames(metaphlan))

cat("MetaPhlAn4 table loaded:", nrow(metaphlan), "taxa\n")

# filter to species level only
metaphlan_species <- metaphlan[grepl("s__", rownames(metaphlan)) & 
                                !grepl("t__", rownames(metaphlan)), ]

cat("Species level taxa:", nrow(metaphlan_species), "\n")

# ============================================
# 3. CREATE PHYLOSEQ OBJECT
# ============================================

# abundance table
otu_mat <- as.matrix(metaphlan_species)

# taxonomy table
tax_mat <- do.call(rbind, strsplit(rownames(metaphlan_species), "\\|"))
colnames(tax_mat) <- c("Kingdom", "Phylum", "Class", "Order", 
                        "Family", "Genus", "Species")[1:ncol(tax_mat)]
rownames(tax_mat) <- rownames(metaphlan_species)

# create phyloseq object
ps <- phyloseq(
  otu_table(otu_mat, taxa_are_rows = TRUE),
  tax_table(tax_mat),
  sample_data(metadata[colnames(otu_mat), ])
)

cat("Phyloseq object created\n")
cat("Samples:", nsamples(ps), "\n")
cat("Taxa:", ntaxa(ps), "\n")

# ============================================
# 4. ALPHA DIVERSITY
# ============================================

alpha_div <- estimate_richness(ps, measures = c("Shannon"))
alpha_div$condition <- sample_data(ps)$condition
alpha_div$sample <- rownames(alpha_div)

cat("\nAlpha diversity summary:\n")
print(aggregate(Shannon ~ condition, data = alpha_div, FUN = mean))

# Wilcoxon test
wilcox_shannon <- wilcox.test(Shannon ~ condition, data = alpha_div)
cat("\nWilcoxon test Shannon p-value:", wilcox_shannon$p.value, "\n")

# Plot alpha diversity
p_alpha <- ggplot(alpha_div, aes(x = condition, y = Shannon, 
                                  fill = condition)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.1, size = 3) +
  scale_fill_manual(values = c("wildtype_Col0" = "#2196F3", 
                                "phr1phl1_mutant" = "#F44336")) +
  labs(title = "Alpha Diversity (Shannon Index)",
       x = "Condition", y = "Shannon Index") +
  theme_bw() +
  theme(legend.position = "none")

ggsave("/mnt/d/tfm_data/results/diversity/alpha_diversity_shannon.png",
       p_alpha, width = 6, height = 5, dpi = 300)

cat("Alpha diversity plot saved\n")

# ============================================
# 5. BETA DIVERSITY
# ============================================

# Bray-Curtis distance
bray_dist <- distance(ps, method = "bray")

# PCoA
pcoa <- ordinate(ps, method = "PCoA", distance = bray_dist)

# Plot PCoA
p_pcoa <- plot_ordination(ps, pcoa, color = "condition") +
  geom_point(size = 5) +
  scale_color_manual(values = c("wildtype_Col0" = "#2196F3", 
                                 "phr1phl1_mutant" = "#F44336")) +
  labs(title = "Beta Diversity - PCoA (Bray-Curtis)",
       color = "Condition") +
  theme_bw()

ggsave("/mnt/d/tfm_data/results/diversity/beta_diversity_pcoa.png",
       p_pcoa, width = 7, height = 5, dpi = 300)

cat("PCoA plot saved\n")

# PERMANOVA
sample_df <- data.frame(condition = sample_data(ps)$condition)
rownames(sample_df) <- sample_names(ps)
permanova <- adonis2(bray_dist ~ condition, 
                     data = sample_df,
                     permutations = 999)
cat("\nPERMANOVA results:\n")
print(permanova)

# ============================================
# 6. TAXONOMIC COMPOSITION
# ============================================

# Phylum level
ps_phylum <- tax_glom(ps, taxrank = "Phylum")
ps_phylum_rel <- transform_sample_counts(ps_phylum, function(x) x/sum(x) * 100)

phylum_df <- psmelt(ps_phylum_rel)

p_phylum <- ggplot(phylum_df, aes(x = Sample, y = Abundance, fill = Phylum)) +
  geom_bar(stat = "identity") +
  facet_wrap(~condition, scales = "free_x") +
  labs(title = "Taxonomic Composition at Phylum Level",
       x = "Sample", y = "Relative Abundance (%)") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("/mnt/d/tfm_data/results/diversity/taxonomic_composition_phylum.png",
       p_phylum, width = 10, height = 6, dpi = 300)

cat("Taxonomic composition plot saved\n")
cat("\nAnalysis complete!\n")
