library(tidyverse)
library(readxl)
library("janitor")
library(patchwork)
install.packages("patchwork")
library(patchwork)

# Load embryo data
Embryo_data <- read_excel("~/All Analysis.xlsx", sheet = "All Human embryos", skip = 1)
Embryo_data <- clean_names(Embryo_data)

# Ensure categorical variables are factors
Embryo_data$outcome <- factor(Embryo_data$outcome, levels = c("Unsuccessful", "Successful"))
Embryo_data$stage <- factor(Embryo_data$stage, levels = c("Z", "EARLY CLEAVAGE", "MORULA", "CAVITATION", "BLASTOCYST"))

# Select nuclear features for trend analysis
features <- c("average_diameter", "circularity")

# Pivot longer to analyze both features in one loop
long_data <- Embryo_data %>%
  pivot_longer(cols = all_of(features), names_to = "feature", values_to = "value")

# Summary: mean + SE for each group
trend_summary <- long_data %>%
  group_by(stage, outcome, feature) %>%
  summarise(
    mean_value = mean(value, na.rm = TRUE),
    se = sd(value, na.rm = TRUE)/sqrt(n()),
    .groups = "drop"
  )

# ANOVA for nuclear diameter
anova_diameter <- aov(average_diameter ~ stage * outcome, data = Embryo_data)
p_diameter <- summary(anova_diameter)[[1]]["stage:outcome", "Pr(>F)"]
subtitle_diam <- ifelse(p_diameter < 0.001, "p < 0.001 (significant)",
                        paste("Trend Line p-value =", signif(p_diameter, 3)))

# ANOVA for nuclear circularity
anova_circularity <- aov(circularity ~ stage * outcome, data = Embryo_data)
p_circ <- summary(anova_circularity)[[1]]["stage:outcome", "Pr(>F)"]
subtitle_circ <- ifelse(p_circ < 0.001, "p < 0.001 (significant)",
                        paste("Trend Line p-value =", signif(p_circ, 3)))

# Plot 1: Nuclear Diameter
plot_diameter <- ggplot(Embryo_data, aes(x = stage, y = average_diameter, color = outcome, group = outcome)) +
  stat_summary(fun = mean, geom = "line", size = 1.2) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.15) +
  stat_summary(fun = mean, geom = "point", size = 2) +
  labs(title = "Nuclear Diameter Across Stages",
       subtitle = subtitle_diam,
       x = "Developmental Stage", y = "Diameter (μm)", color = "Outcome") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top")

# Plot 2: Nuclear Circularity
plot_circularity <- ggplot(Embryo_data, aes(x = stage, y = circularity, color = outcome, group = outcome)) +
  stat_summary(fun = mean, geom = "line", size = 1.2) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.15) +
  stat_summary(fun = mean, geom = "point", size = 2) +
  labs(title = "Nuclear Circularity Across Stages",
       subtitle = subtitle_circ,
       x = "Developmental Stage", y = "Circularity", color = "Outcome") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top")

combined_plot <- plot_diameter + plot_circularity + plot_layout(ncol = 2)
combined_plot
