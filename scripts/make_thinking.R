#!/usr/bin/env Rscript
# make_thinking.R: thinking-levels view. Intelligence AND cost across reasoning effort,
# with GLM 5.2 in the comparison.
# HONEST DATA NOTE: Artificial Analysis publishes per-effort Intelligence-Index runs only
# for GPT-5.5. GLM 5.2, Sonnet 5, Opus 4.8, Gemini appear at a single "max" setting only
# (Sonnet 5 launched 2026-06-30). So the cross-model effort curve uses GPT-5.5 as the one
# measured exemplar; GLM/Sonnet/Opus are single max points. Panel B uses Anthropic's OWN
# effort curves (BrowseComp), read approximately from their chart image (no GLM there).

suppressMessages({
  library(tidyverse); library(scales); library(ggtext); library(patchwork); library(ggrepel)
})
setwd("/home/ieqr/Desktop/research/sonnet5-vs-glm52")
source("scripts/theme_bench.R")

te  <- read_csv("data/token_economics.csv", show_col_types = FALSE)   # single max points
gp  <- read_csv("data/gpt55_effort.csv",    show_col_types = FALSE)   # GPT-5.5 effort curve
el  <- read_csv("data/effort_levels.csv",   show_col_types = FALSE)   # Anthropic BrowseComp

mc <- c("GLM 5.2" = pal$glm52, "Claude Sonnet 5" = pal$sonnet5,
        "Claude Opus 4.8" = pal$opus, "GPT-5.5" = "#8E86A8", "Gemini 3.1 Pro" = "#9AA7B2")

# ================= PANEL A: AA Index, effort curve (GPT-5.5) + max points =========
pts <- te %>% filter(model != "GPT-5.5")            # GLM, Sonnet5, Opus, Gemini at max
s5  <- te %>% filter(model == "Claude Sonnet 5")

pA <- ggplot() +
  # Sonnet 5 cost estimate range (intro -> standard)
  geom_segment(data = s5, aes(x = cost_low, xend = cost_high,
                              y = intelligence_index, yend = intelligence_index),
               color = pal$sonnet5, linewidth = 1.2, alpha = 0.5, lineend = "round") +
  # GPT-5.5 effort curve (the only measured per-effort series)
  geom_line(data = gp, aes(cost_run_index_usd, intelligence_index),
            color = mc["GPT-5.5"], linewidth = 1.5, lineend = "round") +
  geom_point(data = gp, aes(cost_run_index_usd, intelligence_index),
             fill = mc["GPT-5.5"], color = "white", shape = 21, stroke = 1.0, size = 4.7) +
  geom_text(data = gp, aes(cost_run_index_usd, intelligence_index, label = effort),
            family = "BenchSans SemiBold", size = 2.9, color = mc["GPT-5.5"],
            vjust = 2.0) +
  # single "max" points for the other four
  geom_point(data = pts, aes(cost_run_index_usd, intelligence_index, fill = model),
             color = "white", shape = 21, stroke = 1.1, size = 6.4) +
  geom_text_repel(data = pts, aes(cost_run_index_usd, intelligence_index, color = model,
                  label = paste0(label, "\n", intelligence_index, ",  $", comma(cost_run_index_usd),
                                 ifelse(measured, "", "*"))),
                  family = "BenchSans", size = 3.1, lineheight = 0.95, seed = 5,
                  box.padding = 1.0, point.padding = 0.6, min.segment.length = 0.3,
                  segment.color = pal$grid, show.legend = FALSE) +
  annotate("richtext", x = 360, y = 57.4, label = "<span style='color:#8E86A8'>**GPT-5.5**</span> is the only model AA runs per-effort (low → xhigh)",
           family = "BenchSans", size = 2.95, color = pal$subink, fill = NA, label.color = NA,
           hjust = 0, lineheight = 1.12) +
  scale_color_manual(values = mc) +
  scale_fill_manual(values = mc) +
  scale_x_log10(labels = label_dollar(), breaks = c(400, 900, 1800, 3800, 5600),
                expand = expansion(mult = c(0.1, 0.16))) +
  scale_y_continuous(limits = c(41, 58), breaks = seq(42, 57, 3)) +
  labs(title = "Same intelligence, very different bills",
       subtitle = "Intelligence Index vs. cost to run the index (log). At index **53**, <span style='color:#8E86A8'>**GPT-5.5 (high)**</span> costs **$1,746**; <span style='color:#D6603D'>**Sonnet 5**</span> costs **~$5,600**. <span style='color:#1B9E8A'>**GLM 5.2**</span> takes index **51** for just **$933**.",
       x = "Cost to run the Intelligence Index (USD, log scale).   * = derived, AA hasn't published Sonnet 5",
       y = "Intelligence Index (v4.1)") +
  theme_bench(12) + theme(legend.position = "none",
                          plot.subtitle = element_textbox_simple(family = "BenchSans", size = 10.5,
                            color = pal$subink, lineheight = 1.3, width = unit(1, "npc"), margin = margin(b = 8)))

# ================= PANEL B: Anthropic's OWN effort curves (BrowseComp) =============
elx <- el %>% filter(model %in% c("Claude Sonnet 5", "Claude Opus 4.8")) %>%
  mutate(effort = factor(effort, levels = c("low","med","high","xhigh","max")))
pB <- ggplot(elx, aes(cost_per_task_usd, browsecomp_pass, color = model, group = model)) +
  geom_line(linewidth = 1.4, lineend = "round") +
  geom_point(size = 4.4) +
  geom_text(aes(label = effort), family = "BenchSans SemiBold", size = 2.8, vjust = -1.1,
            show.legend = FALSE) +
  geom_text(data = elx %>% group_by(model) %>% slice_max(cost_per_task_usd, n = 1),
            aes(label = model), hjust = 0, nudge_x = 0.03, family = "BenchSans SemiBold",
            size = 3.1, show.legend = FALSE) +
  scale_color_manual(values = mc) +
  scale_x_log10(labels = label_dollar(), breaks = c(2, 3, 5, 8),
                expand = expansion(mult = c(0.08, 0.30))) +
  scale_y_continuous(labels = label_percent(scale = 1), limits = c(50, 78)) +
  labs(title = "Sonnet 5's own effort curve sits under Opus 4.8",
       subtitle = "Anthropic's BrowseComp chart, read approximately. Pass rate vs cost per task by effort. <span style='color:#6B6B6B'>**Opus 4.8**</span> beats <span style='color:#D6603D'>**Sonnet 5**</span> at nearly every matched cost. (Anthropic doesn't chart GLM 5.2.)",
       x = "Cost per task (USD, log scale)", y = "BrowseComp pass rate") +
  theme_bench(12) + theme(legend.position = "none",
                          plot.subtitle = element_textbox_simple(family = "BenchSans", size = 10.5,
                            color = pal$subink, lineheight = 1.3, width = unit(1, "npc"), margin = margin(b = 8)))

# ================= title + caption =================
title_block <- ggplot() + theme_void() +
  labs(title = "Dialing Sonnet 5 down never beats GLM 5.2",
       subtitle = paste0(
         "Reasoning effort changes how many tokens a model spends, not its price per token. <span style='color:#D6603D'>**Sonnet 5**</span> stays **2.3 to 3.4x** ",
         "pricier per token than <span style='color:#1B9E8A'>**GLM 5.2**</span> at every setting, so Sonnet can only get cheaper than GLM by also dropping **below** GLM's intelligence. No effort level gives it cheaper-and-as-smart.")) +
  theme(plot.title = element_markdown(family = "BenchSans Black", size = 23, color = pal$ink,
                                      lineheight = 1.05, margin = margin(b = 7)),
        plot.subtitle = element_textbox_simple(family = "BenchSans", size = 11.5, color = pal$subink,
                                               lineheight = 1.36, width = unit(1, "npc")),
        plot.margin = margin(4, 10, 2, 10))

caption_block <- ggplot() + theme_void() +
  labs(title = "<span style='color:#8a8178'>Sources: Artificial Analysis Intelligence Index v4.1. AA publishes per-effort runs only for GPT-5.5 (low $382, medium $951, high $1,746, xhigh $2,819); GLM 5.2, Sonnet 5, Opus 4.8, Gemini appear at a single max setting only, so their lower-effort points are not independently measured yet. *Sonnet 5 cost-to-run is derived (AA page renders $0.00). Panel B is read approximately from Anthropic's BrowseComp effort chart; GLM 5.2 is not on it. Built with R and the tidyverse.</span>") +
  theme(plot.title = element_textbox_simple(family = "BenchSans", size = 7.3, lineheight = 1.32,
                                            width = unit(1, "npc"), margin = margin(t = 3)),
        plot.margin = margin(2, 10, 4, 10))

final <- title_block / pA / pB / caption_block +
  plot_layout(heights = c(0.74, 1.5, 1.18, 0.32)) +
  plot_annotation(theme = theme(plot.background = element_rect(fill = pal$paper, color = NA),
                                plot.margin = margin(16, 16, 10, 16)))

ggsave("plots/thinking_levels.png", final, width = 9, height = 11.25, dpi = 200,
       bg = pal$paper, limitsize = FALSE, device = ragg::agg_png)
message("Wrote plots/thinking_levels.png")
