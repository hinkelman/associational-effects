# AR and SD experiments were separated by a month so analyzing them separately
library(dplyr)
library(lme4)
library(car)
library(ggplot2)

source("Functions.R")

ar = read.csv(file.path("data", "AR.csv")) |> 
  mutate(Prop = 1 - Sun_gud/Sun_init,
         PropLogit = boot::logit(Prop),
         SelectivitySun = selectivity(Sun_gud, Sun_init, Ox_gud, Ox_init))

ar_supp = read.csv(file.path("data", "AR_ox_supp.csv")) |> 
  mutate(Prop = 1 - Sun_gud/Sun_init,
         PropLogit = boot::logit(Prop),
         SelectivitySun = selectivity(Sun_gud, Sun_init, Ox_gud, Ox_init))

sd = read.csv(file.path("data", "SD.csv")) |> 
  mutate(Prop = 1 - Ox_gud/Ox_init,
         PropLogit = boot::logit(Prop),
         SelectivitySun = selectivity(Sun_gud, Sun_init, Ox_gud, Ox_init))

ar_mod = lmer(PropLogit ~ Trt + (1|Station) + (1|Day), data = ar)
Anova(ar_mod)

# providing the supplement lend to a trend in the right direction
# but not statistically significant so not taking farther
ar_mod_supp = lmer(PropLogit ~ Trt + (1|Station) + (1|Day), data = ar_supp)
Anova(ar_mod_supp)

sd_mod = lmer(PropLogit ~ Trt + (1|Station) + (1|Day), data = sd)
Anova(sd_mod)

ar_sd_nd = data.frame(Trt = c("I", "II", "III", "IV"))

ar_fit_se = AICcmodavg::predictSE(ar_mod, newdata = ar_sd_nd, level = 0)
sd_fit_se = AICcmodavg::predictSE(sd_mod, newdata = ar_sd_nd, level = 0)

ar_sd_pred = cbind(ar_sd_nd, data.frame(Fit = ar_fit_se$fit, SE = ar_fit_se$se.fit)) |> 
  mutate(Background = "Untreated") |> 
  bind_rows(cbind(ar_sd_nd, data.frame(Fit = sd_fit_se$fit, SE = sd_fit_se$se.fit)) |> 
              mutate(Background = "Oxalate")) |> 
  mutate(FitProp = boot::inv.logit(Fit),
         Lwr = boot::inv.logit(Fit - SE),
         Upr = boot::inv.logit(Fit + SE))

ggplot(ar_sd_pred, aes(x = Trt, y = FitProp, color = Background)) +
  geom_pointrange(aes(ymin = Lwr, ymax = Upr), position = position_dodge2(width = 0.5)) +
  scale_color_manual(name = "Background Food", values = c("#e41a1c", "#377eb8")) +
  scale_x_discrete(labels = as.character(seq(0, 6, 2))) +
  labs(x = "Initial associational food amount (g)", y = "Proportion harvested") +
  theme_minimal() +
  theme(plot.background = element_rect(colour = "white"),
        legend.position = "inside",
        legend.position.inside = c(0.2, 0.88))
ggsave(file.path("figures", "AR_SD.png"), width = 4, height = 3.5)
