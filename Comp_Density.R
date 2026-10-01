library(dplyr)
library(nlme)
library(car)
library(ggplot2)

source("Functions.R")

cd = read.csv(file.path("data", "comp_density.csv")) |> 
  mutate(PropUn = 1 - Un_gud/Un_init,
         PropOx = 1 - Ox_gud/Ox_init,
         PropUnLogit = boot::logit(PropUn),
         PropOxLogit = boot::logit(PropOx),
         SelectivityUn = selectivity(Un_gud, Un_init, Ox_gud, Ox_init))

cd_mod_un = lme(PropUnLogit ~ Oxalate*Density, random = ~ 1|Station, data = cd)
Anova(cd_mod_un)

cd_mod_ox = lme(PropOxLogit ~ Oxalate*Density, random = ~ 1|Station, data = cd)
Anova(cd_mod_ox)

cd_nd = tidyr::crossing(Oxalate = c("low", "high"),
                        Density = c("low", "high"))

cd_un_fit_se = AICcmodavg::predictSE.lme(cd_mod_un, newdata = cd_nd, level = 0)
cd_ox_fit_se = AICcmodavg::predictSE.lme(cd_mod_ox, newdata = cd_nd, level = 0)

cd_pred = cbind(cd_nd, data.frame(Fit = cd_ox_fit_se$fit, SE = cd_ox_fit_se$se.fit)) |> 
  mutate(Food = "Oxalate") |> 
  bind_rows(cbind(cd_nd, data.frame(Fit = cd_un_fit_se$fit, SE = cd_un_fit_se$se.fit)) |> 
              mutate(Food = "Untreated"))|> 
  mutate(Oxalate = factor(Oxalate, levels = c("low", "high")),
         Density = factor(Density, levels = c("low", "high")),
         Food = factor(Food, levels = c("Untreated", "Oxalate")),
         FitProp = boot::inv.logit(Fit),
         Lwr = boot::inv.logit(Fit - SE),
         Upr = boot::inv.logit(Fit + SE))

ggplot(cd_pred, aes(x = Oxalate, y = FitProp, color = Density)) +
  geom_pointrange(aes(ymin = Lwr, ymax = Upr), position = position_dodge2(width = 0.5)) +
  scale_color_manual(name = "Total density", values = c("#999999", "#000000")) +
  scale_x_discrete(labels = c("25%", "75%")) +
  labs(x = "Initial percent oxalate", y = "Proportion harvested") +
  facet_wrap(~Food) +
  theme_minimal() +
  theme(plot.background = element_rect(colour = "white"),
        legend.position = "inside",
        legend.position.inside = c(0.85, 0.85))
ggsave(file.path("figures", "CompDensity.png"), width = 6, height = 3.5)
