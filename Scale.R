library(dplyr)
library(nlme)
library(car)
library(ggplot2)

source("Functions.R")

# I: untreated only; II: oxalate only; III: both mixed; IV: each food in separate half of patch
sc = read.csv(file.path("data", "scale.csv")) |>
  mutate(PropSun = 1 - Sun_gud/Sun_init,
         PropOx = 1 - Ox_gud/Ox_init,
         PropSunLogit = boot::logit(PropSun),
         PropOxLogit = boot::logit(PropOx),
         SelectivitySun = selectivity(Sun_gud, Sun_init, Ox_gud, Ox_init))

sc_mod_sun = lme(PropSunLogit ~ Trt, random = ~ 1|Station, data = filter(sc, !is.na(PropSunLogit)))
Anova(sc_mod_sun)

sc_mod_ox = lme(PropOxLogit ~ Trt, random = ~ 1|Station, data = filter(sc, !is.na(PropOxLogit)))
Anova(sc_mod_ox)

# rabbits are nearly non-selective when foods are mixed but selective when foods are separated
sc_mod_sel = lme(SelectivitySun ~ Trt, random = ~ 1|Station, data = filter(sc, Trt %in% c("III", "IV")))
Anova(sc_mod_sel)

sc |>
  filter(Trt %in% c("III", "IV")) |>
  group_by(Trt) |>
  summarise(Mean = mean(SelectivitySun),
            SE = sd(SelectivitySun)/sqrt(n()))

sc_nd_sun = expand.grid(Trt = c("I", "III", "IV"))
sc_nd_ox = expand.grid(Trt = c("II", "III", "IV"))

sc_sun_fit_se = AICcmodavg::predictSE.lme(sc_mod_sun, newdata = sc_nd_sun, level = 0)
sc_ox_fit_se = AICcmodavg::predictSE.lme(sc_mod_ox, newdata = sc_nd_ox, level = 0)

sc_pred = cbind(sc_nd_ox, data.frame(Fit = sc_ox_fit_se$fit, SE = sc_ox_fit_se$se.fit)) |>
  mutate(Food = "Oxalate") |>
  bind_rows(cbind(sc_nd_sun, data.frame(Fit = sc_sun_fit_se$fit, SE = sc_sun_fit_se$se.fit)) |>
              mutate(Food = "Untreated")) |>
  mutate(Patch = case_when(Trt %in% c("I", "II") ~ "Alone",
                           Trt == "III" ~ "Mixed",
                           Trt == "IV" ~ "Separated"),
         Food = factor(Food, levels = c("Untreated", "Oxalate")),
         FitProp = boot::inv.logit(Fit),
         Lwr = boot::inv.logit(Fit - SE),
         Upr = boot::inv.logit(Fit + SE))

ggplot(sc_pred, aes(x = Patch, y = FitProp, color = Food)) +
  geom_pointrange(aes(ymin = Lwr, ymax = Upr), position = position_dodge2(width = 0.5)) +
  scale_color_manual(name = "", values = c("#377eb8", "#e41a1c")) +
  labs(x = "Patch arrangement", y = "Proportion harvested") +
  theme_minimal() +
  theme(plot.background = element_rect(colour = "white"),
        legend.position = "inside",
        legend.position.inside = c(0.2, 0.88))
ggsave(file.path("figures", "Scale.png"), width = 4, height = 3.5)
