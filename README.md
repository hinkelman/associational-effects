# Associational effects in a seed-tray foraging system

Unpublished data and R code from a series of foraging experiments I ran during graduate school at Texas Tech (October 2006 – April 2007). The experiments asked whether a food item's survival depends on its neighbors: does a palatable seed survive better when it is surrounded by unpalatable seeds (*associational refuge*), and does an unpalatable seed fare worse when surrounded by palatable seeds (*shared doom*)?

I never wrote these results up for a journal (see [Caveats](#caveats)), but there is a reasonably coherent story in them, which I've tried to tell here.

## Background

Experimental food patches were plastic trays of sand with a known mass of seeds mixed in. After a day of foraging, the sand was sieved and the remaining seeds weighed to get the giving-up density (GUD). Seeds were either *untreated* sunflower seeds (palatable) or sunflower seeds soaked in oxalic acid (*oxalate*; less palatable). One pair of experiments used oats in place of oxalate seeds.

Both cottontail rabbits and hispid cotton rats foraged from trays at the site. The cotton rats did not seem to forage far from their burrows, so trays for these experiments were placed away from rat burrows, and I believe rabbits were the main foragers. See [Caveats](#caveats).

The design closely follows [Emerson et al. (2012)](https://doi.org/10.1007/s00442-011-2144-4), who ran similar experiments with fox and gray squirrels in Illinois. My graduate advisor, Ken Schmidt, is a co-author on that paper. Comparing their squirrels with my rabbits is part of what makes these data interesting.

The response variable throughout is the proportion of seeds harvested (1 − GUD / initial amount), analyzed on the logit scale with a random effect of station. Within-patch selectivity uses Manly's index (`Functions.R`): 0.5 means that seeds were taken in proportion to their availability, and values above 0.5 mean that untreated seeds were preferred.

## The story

**Bad neighbors are contagious; good neighbors aren't very protective.**

### 1. Shared doom, but no associational refuge

Each tray had 10 g of a background food and 0, 2, 4, or 6 g of an associational food.

- Adding untreated seeds to oxalate trays increased harvest of the oxalate seeds from about 0.49 to 0.63 (p < 0.001). That is shared doom.
- Adding oxalate seeds to untreated trays had no effect on harvest of the untreated seeds, which stayed near 0.41 (p = 0.53). That is no refuge.
- Offering a dish of 12 g of extra oxalate seeds at each station nudged the refuge effect in the predicted direction, but not significantly (p = 0.49).

![](figures/AR_SD.png)

This is the same asymmetry that Emerson et al. found among patches in their Experiment 2 with squirrels: shared doom for less palatable seeds, no refuge for palatable ones.

### 2. Why the asymmetry: rabbits track the density of good food, not bad food

In trays with a single food type at 8–20 g, the proportion of untreated seeds harvested rose with initial amount (about 0.51 → 0.62). The proportion of oxalate seeds harvested stayed flat (about 0.27–0.32) (food × amount interaction, p = 0.07).

![](figures/PatchAssessment.png)

If the rabbits judge a patch by how much good food it holds, the asymmetry follows. Adding untreated seeds makes a patch worth working longer, and the oxalate seeds are caught up in that extra effort. Adding oxalate seeds doesn't make the patch any less worth working, so the untreated seeds gain nothing.

The composition × density experiment points the same way. Doubling total density increased harvest when 25% of the seeds were oxalate, but not when 75% were oxalate. The interaction is not significant, so treat it as suggestive.

![](figures/CompDensity.png)

When the second food is also valuable (oats instead of oxalate seeds), adding it increased harvest of an oat background (p < 0.001). The trend was similar but not significant for a sunflower background (p = 0.14).

![](figures/AC.png)

### 3. Rabbits can't select within a mixed patch, but they can when the foods are separated

Within mixed trays, rabbits were barely selective: Manly's index was 0.52–0.58 across experiments. The scale experiment (`Scale.R`) put 10 g of each food in a tray, either mixed together or confined to separate halves:

| Arrangement | Untreated harvested | Oxalate harvested | Selectivity |
|---|---|---|---|
| Alone (single food) | 0.73 | 0.40 | — |
| Mixed | 0.64 | 0.61 | 0.53 |
| Separated halves | 0.87 | 0.45 | 0.76 |

Mixing the foods pushes their fates together: some refuge for the untreated seeds and shared doom for the oxalate seeds. Separating them lets the rabbits sort the food themselves, and both associational effects disappear.

![](figures/Scale.png)

Emerson et al. predicted that dividing patches into micropatches would increase selectivity. Their squirrels showed this only weakly, while these rabbits show it strongly.

### 4. A design lesson: additive vs. replacement experiments

The experiments above are *additive* designs: the focal food is held constant and the neighbor is added, so total density rises. The replacement series instead held the total at 16 g and varied the oxalate share from 0 to 100%.

In the replacement series, untreated harvest fell from 0.78 to 0.52 as the oxalate share rose, which looks like a strong associational refuge. Oxalate harvest rose from 0.43 alone to 0.68 when oxalate made up only 25% of the seeds, which looks like shared doom. Both trends were significant (p < 0.001).

![](figures/Replacement.png)

Hambäck et al. (2014) show that the two designs mix up different things. In an additive design, the neighbor's relative frequency changes along with total density. In a replacement design, it changes along with the focal food's own density. Results from one design therefore can't be compared directly with results from the other. Their models, built for insect herbivores, predict that additive designs tend to show associational resistance. More plants in a patch spread the herbivores more thinly, an effect called *resource dilution*.

A forager that depletes patches doesn't seem to work that way. In the patch assessment experiment, rabbits harvested a *larger* proportion of untreated seeds from richer patches, which is concentration rather than dilution. The proportion harvested didn't change with the amount of oxalate seed. Two consequences follow:

- **Additive design:** adding oxalate neighbors didn't thin out the harvest of untreated seeds, so there was no refuge. Adding untreated neighbors made the patch worth working harder, so there was shared doom.
- **Replacement design:** raising the oxalate share also cuts the untreated amount from 16 g to 4 g. Rabbits harvest a smaller proportion from poorer untreated patches, so much of the apparent refuge could come from the focal food's own density rather than from its neighbors.

The replacement series also shows the pattern Hambäck et al. identify as the most common outcome: the palatable food appears to gain a refuge while the less palatable food suffers shared doom.

## Caveats

These are the reasons I never pursued publication:

1. **Unnatural system.** Seed trays are a standard tool for measuring giving-up densities, but cottontail rabbits harvesting sunflower seeds from sand is not a natural interaction.
2. **Forager identity.** Hispid cotton rats also foraged from trays at the site. They seemed to stay close to their burrows, so I placed these trays away from rat burrows. I believe rabbits were the main foragers, but I'm no longer working in this system and can't provide more evidence to support that. If some trays were mostly visited by rats, between-station variation would partly reflect forager species.
3. **Sub-optimal foraging claims.** Any claim that rabbits forage sub-optimally (e.g., non-selectively within patches) runs straight back into caveat 1.
4. **Not a cohesive program.** These were my last experiments at Texas Tech, and I was trying many things to see if the system was viable. Sample sizes are modest (4–8 days × 8 stations per experiment), the experiments ran in different seasons, and comparisons across experiments (e.g., replacement vs. patch assessment) are informal.

## Repository contents

An earlier round of associational refuge and shared doom tests (data not included) found shared doom but no refuge. That raised the question of whether the rabbits were foraging in a density-dependent way at all, which led to the apparent competition and patch assessment experiments. The AR and SD tests in this repository were run again after the apparent competition experiment.

| Experiment | Dates | Data | Script | Figure |
|---|---|---|---|---|
| Apparent competition (oat / sunflower) | Oct–Nov 2006 | `AC_oat_back.csv`, `AC_sun_back.csv` | `ApparentCompetition.R` | `AC.png` |
| Associational refuge | Nov 2006 | `AR.csv` | `AR_SD.R` | `AR_SD.png` |
| Associational refuge + oxalate supplement | Dec 2006 | `AR_ox_supp.csv` | `AR_SD.R` | — |
| Shared doom | Dec 2006 | `SD.csv` | `AR_SD.R` | `AR_SD.png` |
| Scale (mixed vs. separated) | Jan–Feb 2007 | `scale.csv` | `Scale.R` | `Scale.png` |
| Replacement series | Feb 2007 | `replacement.csv` | `Replacement.R` | `Replacement.png` |
| Composition × density | Mar 2007 | `comp_density.csv` | `Comp_Density.R` | `CompDensity.png` |
| Patch assessment | Apr 2007 | `patch_assess.csv` | `PatchAssessment.R` | `PatchAssessment.png` |

`Metadata.pdf` diagrams each experimental design. Scripts are run from the repository root and require `dplyr`, `nlme`, `car`, `ggplot2`, `boot`, `tidyr`, and `AICcmodavg`. The CSV files use old Mac (CR) line endings; `read.csv` handles them fine.

## References

- Emerson SE, Brown JS, Whelan CJ, Schmidt KA (2012) Scale-dependent neighborhood effects: shared doom and associational refuge. *Oecologia* 168:659–670. https://doi.org/10.1007/s00442-011-2144-4
- Hambäck PA, Inouye BD, Andersson P, Underwood N (2014) Effects of plant neighborhoods on plant–herbivore interactions: resource dilution and associational effects. *Ecology* 95:1370–1383.
- Underwood N, Inouye BD, Hambäck PA (2014) A conceptual framework for associational effects: when do neighbors matter and how would we know? *Quarterly Review of Biology* 89:1–19.
