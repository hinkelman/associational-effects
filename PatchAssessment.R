library(dplyr)
library(lme4)
library(car)
library(ggplot2)

# data was collected in same 4 day span so using single model
pa = read.csv(file.path("data", "patch_assess.csv")) |> 
  mutate(Food = ifelse(Food == "ox", "Oxalate", "Untreated"),
         Prop = 1 - GUD/Initial,
         PropLogit = boot::logit(Prop))

pa_mod = lmer(PropLogit ~ Trt * Food + (1|Station) + (1|Day), data = pa)
Anova(pa_mod)

pa_nd = tidyr::crossing(Trt = c("I", "II", "III", "IV"),
                        Food = c("Untreated", "Oxalate"))

pa_fit_se = AICcmodavg::predictSE(pa_mod, newdata = pa_nd, level = 0)
pa_pred = cbind(pa_nd, data.frame(Fit = pa_fit_se$fit, SE = pa_fit_se$se.fit)) |> 
  mutate(Food = factor(Food, levels = c("Untreated", "Oxalate")),
         FitProp = boot::inv.logit(Fit),
         Lwr = boot::inv.logit(Fit - SE),
         Upr = boot::inv.logit(Fit + SE))

ggplot(pa_pred, aes(x = Trt, y = FitProp, color = Food)) +
  geom_pointrange(aes(ymin = Lwr, ymax = Upr), position = position_dodge2(width = 0.5)) +
  scale_color_manual(name = "", values = c("#377eb8", "#e41a1c")) +
  scale_x_discrete(labels = as.character(seq(8, 20, 4))) +
  labs(x = "Initial food amount (g)", y = "Proportion harvested") +
  theme_minimal() +
  theme(plot.background = element_rect(colour = "white"),
        legend.position = "inside",
        legend.position.inside = c(0.2, 0.92))
ggsave(file.path("figures", "PatchAssessment.png"), width = 4, height = 3.5)
