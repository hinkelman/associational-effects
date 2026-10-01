library(dplyr)
library(nlme)
library(car)
library(ggplot2)

source("Functions.R")

replace = read.csv(file.path("data", "replacement.csv")) |> 
  mutate(PropSun = 1 - Sun_gud/Sun_init,
         PropOx = 1 - Ox_gud/Ox_init,
         PropSunLogit = boot::logit(PropSun),
         PropOxLogit = boot::logit(PropOx),
         SelectivitySun = selectivity(Sun_gud, Sun_init, Ox_gud, Ox_init))


replace_mod_sun = lme(PropSunLogit ~ Trt, random = ~ 1|Station, data = filter(replace, !is.na(PropSunLogit)))
Anova(replace_mod_sun)

replace_mod_ox = lme(PropOxLogit ~ Trt, random = ~ 1|Station, data = filter(replace, !is.na(PropOxLogit)))
Anova(replace_mod_ox)

replace_nd_sun = expand.grid(Trt = c("I", "II", "III", "IV"))
replace_nd_ox = expand.grid(Trt = c("II", "III", "IV", "V"))

replace_sun_fit_se = AICcmodavg::predictSE.lme(replace_mod_sun, newdata = replace_nd_sun, level = 0)
replace_ox_fit_se = AICcmodavg::predictSE.lme(replace_mod_ox, newdata = replace_nd_ox, level = 0)

replace_pred = cbind(replace_nd_ox, data.frame(Fit = replace_ox_fit_se$fit, SE = replace_ox_fit_se$se.fit)) |> 
  mutate(Food = "Oxalate") |> 
  bind_rows(cbind(replace_nd_sun, data.frame(Fit = replace_sun_fit_se$fit, SE = replace_sun_fit_se$se.fit)) |> 
              mutate(Food = "Untreated"))|> 
  mutate(Trt = factor(Trt, levels = c("I", "II", "III", "IV", "V")),
         Food = factor(Food, levels = c("Untreated", "Oxalate")),
         FitProp = boot::inv.logit(Fit),
         Lwr = boot::inv.logit(Fit - SE),
         Upr = boot::inv.logit(Fit + SE))

ggplot(replace_pred, aes(x = Trt, y = FitProp, color = Food)) +
  geom_pointrange(aes(ymin = Lwr, ymax = Upr), position = position_dodge2(width = 0.5)) +
  scale_color_manual(name = "", values = c("#377eb8", "#e41a1c")) +
  scale_x_discrete(labels = as.character(seq(0, 100, 25))) +
  labs(x = "Initial Percent Oxalate", y = "Proportion harvested") +
  theme_minimal() +
  theme(plot.background = element_rect(colour = "white"),
        legend.position = "inside",
        legend.position.inside = c(0.8, 0.88))
ggsave(file.path("figures", "Replacement.png"), width = 4, height = 3.5)
