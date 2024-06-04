library(stats)

path2data = '/Volumes/server/Projects/attentionpRF/derivatives/amplitude_data'
#path2data = '/Users/ekintuncok/Desktop'
data_tbl = read.csv(paste(path2data, "amplitude_data_for_ANOVA.csv", sep = '/'))
data_tbl$id <- as.factor(data_tbl$id)
data_tbl$ROI <- as.factor(data_tbl$ROI)
data_tbl$Location <- as.factor(data_tbl$Location)
data_tbl$AttCondition <- as.factor(data_tbl$AttCondition)
data_tbl$BOLD <- as.numeric(data_tbl$BOLD)

anovares <- ezPerm(data = data_tbl, dv = .(BOLD), wid = id, within = .(ROI, Location, AttCondition))

res.aov <- anova_test(
  data = data_tbl, dv = BOLD, wid = id,
  within = c(ROI, Location, AttCondition)
)
get_anova_table(res.aov)

# repeated measures ANOVA showed a two-way interaction effect so the rest of the script 
# executes simple main effect tests to compare this interaction between ROIs:
# Fit pairwise comparisons
pwc <- data_tbl %>%
  group_by(Location, AttCondition) %>%
  pairwise_t_test(BOLD ~ ROI, p.adjust.method = "bonferroni") %>%
  select(-p, -p.signif) 

