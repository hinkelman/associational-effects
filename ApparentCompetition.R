# the two AC experiments were separated by about a week so analyzing them separately

library(dplyr)
library(lme4)
library(car)
library(ggplot2)

source("Functions.R")

ac_oat = read.csv(file.path("data", "AC_oat_back.csv"), na.strings = ".") |> 
  mutate(Prop = 1 - Oat_gud/Oat_init,
         PropLogit = boot::logit(Prop),
         SelectivitySun = selectivity(Sun_gud, Sun_init, Oat_gud, Oat_init))

ac_sun = read.csv(file.path("data", "AC_sun_back.csv"), na.strings = ".") |> 
  mutate(Prop = 1 - Sun_gud/Sun_init,
         PropLogit = boot::logit(Prop),
         SelectivitySun = selectivity(Sun_gud, Sun_init, Oat_gud, Oat_init))

ac_oat_mod = lmer(PropLogit ~ Trt + (1|Station) + (1|Day), data = ac_oat)
Anova(ac_oat_mod)

ac_sun_mod = lmer(PropLogit ~ Trt + (1|Station) + (1|Day), data = ac_sun)
Anova(ac_sun_mod)

ac_nd = data.frame(Trt = c("I", "II", "III", "IV"))

ac_oat_fit_se = AICcmodavg::predictSE(ac_oat_mod, newdata = ac_nd, level = 0)
ac_sun_fit_se = AICcmodavg::predictSE(ac_sun_mod, newdata = ac_nd, level = 0)

ac_pred = cbind(ac_nd, data.frame(Fit = ac_oat_fit_se$fit, SE = ac_oat_fit_se$se.fit)) |> 
  mutate(Background = "Oat") |> 
  bind_rows(cbind(ac_nd, data.frame(Fit = ac_sun_fit_se$fit, SE = ac_sun_fit_se$se.fit)) |> 
              mutate(Background = "Sunflower"))|> 
  mutate(Background = factor(Background, levels = c("Sunflower", "Oat")),
         FitProp = boot::inv.logit(Fit),
         Lwr = boot::inv.logit(Fit - SE),
         Upr = boot::inv.logit(Fit + SE))

ggplot(ac_pred, aes(x = Trt, y = FitProp, color = Background)) +
  geom_pointrange(aes(ymin = Lwr, ymax = Upr), position = position_dodge2(width = 0.5)) +
  scale_color_manual(name = "Background Food", values = c("#377eb8", "#984ea3")) +
  scale_x_discrete(labels = as.character(seq(0, 6, 2))) +
  labs(x = "Initial associational food amount (g)", y = "Proportion harvested") +
  theme_minimal() +
  theme(plot.background = element_rect(colour = "white"),
        legend.position = "inside",
        legend.position.inside = c(0.2, 0.88))
ggsave(file.path("figures", "AC.png"), width = 4, height = 3.5)
