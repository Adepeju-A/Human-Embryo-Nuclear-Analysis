library(readxl)
library(tidyverse)
library(ggpubr)
library(pROC)
library(dplyr)
library(knitr)
install.packages("gt")
library(gt)

# Load embryo data
Embryo_data <- read_excel("~/All Analysis.xlsx", sheet = "All Human embryos", skip = 1)

# Rename columns for consistency
colnames(Embryo_data) <- c("stage", "nuclear_diameter", "circularity", "outcome")

# Drop rows with missing values
Embryo_data <- na.omit(Embryo_data)

# Outcome as factor
Embryo_data$outcome <- factor(Embryo_data$outcome, levels = c("Unsuccessful", "Successful"))

# Stages as factor
Embryo_data$stage <- factor(Embryo_data$stage, levels = c("Z", "EARLY CLEAVAGE", "MORULA", "CAVITATION", "BLASTOCYST"))

#Inferential statistics
# T-test for nuclear diameter
t_test_results <- Embryo_data %>%
  group_by(stage) %>%
  summarise(
    t_test = list(t.test(nuclear_diameter ~ outcome)),
    .groups = "drop"
  ) %>%
  mutate(
    stage = as.character(stage),
    t_statistic = sapply(t_test, function(x) x$statistic),
    p_value = sapply(t_test, function(x) x$p.value),
    mean_successful = sapply(t_test, function(x) x$estimate["mean in group Successful"]),
    mean_unsuccessful = sapply(t_test, function(x) x$estimate["mean in group Unsuccessful"]),
    conf_low = sapply(t_test, function(x) x$conf.int[1]),
    conf_high = sapply(t_test, function(x) x$conf.int[2])
  ) %>%
  select(stage, t_statistic, p_value, mean_successful, mean_unsuccessful, conf_low, conf_high)

print(t_test_results)

# Boxplot of nuclear diameter by outcome, faceted by stage
ggplot(Embryo_data, aes(x = outcome, y = nuclear_diameter, fill = outcome)) +
  geom_boxplot() +
  facet_wrap(~ stage, scales = "free") +
  stat_compare_means(method = "t.test", label = "p.format") +
  labs(title = "Nuclear Diameter by Outcome Across Stages",
       x = "Outcome", y = "Nuclear Diameter") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Boxplot of circularity by outcome, faceted by stage
ggplot(Embryo_data, aes(x = outcome, y = circularity, fill = outcome)) +
  geom_boxplot() +
  facet_wrap(~ stage, scales = "free") +
  stat_compare_means(method = "t.test", label = "p.format") +
  labs(title = "Circularity by Outcome Across Stages",
       x = "Outcome", y = "Circularity") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Embryo Table
kable(t_test_results, caption = "T-test results for Nuclear Diameter by Developmental Stage")

