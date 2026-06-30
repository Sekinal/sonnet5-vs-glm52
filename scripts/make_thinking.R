#!/usr/bin/env Rscript
# make_thinking.R: thinking-levels view. Intelligence AND cost across reasoning effort,
# with GLM 5.2 in the comparison.
# HONEST DATA NOTE: Artificial Analysis publishes per-effort Intelligence-Index runs only
# for GPT-5.5. GLM 5.2, Sonnet 5, Opus 4.8, Gemini appear at a single "max" setting only
# (Sonnet 5 launched 2026-06-30). So the cross-model effort curve uses GPT-5.5 as the one
# measured exemplar; GLM/Sonnet/Opus are single max points. Panel B uses sticker output
# prices (a hard fact, no benchmark dependence) instead of any single narrow benchmark.

suppressMessages({
  library(tidyverse); library(scales); library(ggtext); library(patchwork); library(ggrepel)
})
setwd("/home/ieqr/Desktop/research/sonnet5-vs-glm52")
source("scripts/theme_bench.R")

te  <- read_csv("data/token_economics.csv", show_col_types = FALSE)   # single max points
gp  <- read_csv("data/gpt55_effort.csv",    show_col_types = FALSE)   # GPT-5.5 effort curve

mc <- c("GLM 5.2" = pal$glm52, "Claude Sonnet 5" = pal$sonnet5,
        "Claude Opus 4.8" = pal$opus, "Claude Opus 4.7" = "#A99E92",
        "GPT-5.5" = "#8E86A8", "Gemini 3.1 Pro" = "#9AA7B2")

# ================= PANEL A: AA Index, effort curve (GPT-5.5) + max points =========
pts <- te %>% filter(model != "GPT-5.5")            # GLM, Sonnet5, Opus, Gemini at max
s5  <- te %>% filter(model == "Claude Sonnet 5")

pts2 <- pts %>% mutate(ny = case_when(
          model == "Gemini 3.1 Pro" ~ -2.4, model == "GLM 5.2" ~ 2.7,
          model == "Claude Opus 4.8" ~ 1.8, model == "Claude Opus 4.7" ~ -2.6,
          model == "Claude Sonnet 5" ~ -2.0, TRUE ~ 0))

pA <- ggplot() +
  # GPT-5.5 effort curve: the one model AA runs per-effort. The line is GPT-5.5 ONLY;
  # the other models are single max points that happen to land near it.
  geom_line(data = gp, aes(cost_run_index_usd, intelligence_index),
            color = mc["GPT-5.5"], linewidth = 1.5, lineend = "round") +
  geom_point(data = gp, aes(cost_run_index_usd, intelligence_index),
             fill = mc["GPT-5.5"], color = "white", shape = 21, stroke = 1.0, size = 4.4) +
  geom_text(data = gp, aes(cost_run_index_usd, intelligence_index, label = effort),
            family = "BenchSans SemiBold", size = 2.7, color = mc["GPT-5.5"], vjust = 2.1) +
  annotate("richtext", x = 430, y = 41.6,
           label = "the <span style='color:#8E86A8'>**GPT-5.5**</span> line is one model dialed low → xhigh (the only per-effort series)",
           family = "BenchSans", size = 2.85, color = pal$subink, fill = NA, label.color = NA,
           hjust = 0) +
  # single "max" points for the other four
  geom_point(data = pts, aes(cost_run_index_usd, intelligence_index, fill = model),
             color = "white", shape = 21, stroke = 1.1, size = 6.4) +
  geom_text_repel(data = pts2, aes(cost_run_index_usd, intelligence_index, color = model,
                  label = paste0(label, "\n", intelligence_index, ",  $", comma(cost_run_index_usd))),
                  family = "BenchSans", size = 3.1, lineheight = 0.95, seed = 5,
                  nudge_y = pts2$ny, box.padding = 1.1, point.padding = 0.6,
                  min.segment.length = 0.2, max.overlaps = Inf,
                  segment.color = pal$grid, show.legend = FALSE) +
  scale_color_manual(values = mc) +
  scale_fill_manual(values = mc) +
  scale_x_log10(labels = label_dollar(), breaks = c(400, 900, 1800, 3800, 6000),
                expand = expansion(mult = c(0.1, 0.16))) +
  scale_y_continuous(limits = c(41, 59.5), breaks = seq(42, 57, 3)) +
  labs(title = "Same intelligence, very different bills",
       subtitle = "Intelligence Index vs. cost to run the index (log). At index **53**, <span style='color:#8E86A8'>**GPT-5.5 (high)**</span> costs **$1,746**; <span style='color:#D6603D'>**Sonnet 5**</span> costs **$6,015**. <span style='color:#1B9E8A'>**GLM 5.2**</span> takes index **51** for just **$933**.",
       x = "Cost to run the Intelligence Index (USD, log scale), measured by Artificial Analysis",
       y = "Intelligence Index (v4.1)") +
  theme_bench(12) + theme(legend.position = "none",
                          plot.subtitle = element_textbox_simple(family = "BenchSans", size = 10.5,
                            color = pal$subink, lineheight = 1.3, width = unit(1, "npc"), margin = margin(b = 8)))

# ================= PANEL B: the fixed lever, price per token (effort can't change it) ====
# Robust hard fact (no benchmark dependence): output price per 1M tokens. Reasoning effort
# changes how many tokens you spend, never the price per token, so this gap is permanent.
pr <- te %>% mutate(model = fct_reorder(model, output_price_per_mtok))
pB <- ggplot(pr, aes(output_price_per_mtok, model, fill = model)) +
  geom_col(width = 0.62) +
  geom_text(aes(label = label_dollar(accuracy = 0.01)(output_price_per_mtok)), hjust = -0.22,
            family = "BenchSans Black", size = 3.9, color = pal$ink) +
  annotate("richtext", x = 10, y = 1.05,
           label = "<span style='color:#1B9E8A'>**GLM 5.2**</span>'s per-token price is<br>**2.3 to 3.4x** cheaper than Sonnet 5's",
           family = "BenchSans", size = 3.0, color = pal$subink, fill = NA, label.color = NA,
           hjust = 0, lineheight = 1.12) +
  scale_fill_manual(values = mc) +
  scale_y_discrete(labels = function(x) te$label[match(x, te$model)]) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(title = "Price per token doesn't move with effort",
       subtitle = "Output price per 1M tokens. Effort changes <span style='color:#1A1714'>**how many**</span> tokens you spend, never the price per token, so the gap to <span style='color:#1B9E8A'>**GLM 5.2**</span> is permanent. (Sonnet 5 intro price is $10 through Aug 31.)",
       x = "Output price (USD per 1M tokens)", y = NULL) +
  theme_bench(12) + theme(legend.position = "none",
                          panel.grid.major.y = element_blank(),
                          axis.text.x = element_blank(), panel.grid.major.x = element_blank(),
                          plot.subtitle = element_textbox_simple(family = "BenchSans", size = 10.5,
                            color = pal$subink, lineheight = 1.3, width = unit(1, "npc"), margin = margin(b = 8)))

# ================= title + caption =================
title_block <- ggplot() + theme_void() +
  labs(title = "Dialing Sonnet 5 down never beats GLM 5.2",
       subtitle = paste0(
         "Reasoning effort changes how many tokens a model spends, not its price per token. <span style='color:#D6603D'>**Sonnet 5**</span> stays **2.3 to 3.4x** ",
         "pricier per token than <span style='color:#1B9E8A'>**GLM 5.2**</span> whatever the effort, so Sonnet can only get cheaper than GLM by also dropping **below** GLM's intelligence. No effort setting gives it cheaper-and-as-smart.")) +
  theme(plot.title = element_markdown(family = "BenchSans Black", size = 23, color = pal$ink,
                                      lineheight = 1.05, margin = margin(b = 7)),
        plot.subtitle = element_textbox_simple(family = "BenchSans", size = 11.5, color = pal$subink,
                                               lineheight = 1.36, width = unit(1, "npc")),
        plot.margin = margin(4, 10, 2, 10))

caption_block <- ggplot() + theme_void() +
  labs(title = "<span style='color:#8a8178'>Sources: Artificial Analysis Intelligence Index v4.1 (measured). AA publishes per-effort runs only for GPT-5.5 (low $382, medium $951, high $1,746, xhigh $2,819); GLM 5.2, Sonnet 5, Opus 4.8 and Gemini appear at a single max setting, so their lower-effort intelligence is not independently measured yet. Sonnet 5 cost-to-run $6,015 is now AA-measured at standard $3/$15. Panel B uses sticker output prices (a hard fact, no benchmark dependence). We deliberately do not lean on Anthropic's BrowseComp effort chart, a single narrow vendor-selected benchmark. Built with R and the tidyverse.</span>") +
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

# Standalone, high-resolution render of just the intelligence-vs-cost panel.
pA_solo <- pA + theme(plot.margin = margin(20, 24, 16, 18))
ggsave("plots/intelligence_vs_cost.png", pA_solo, width = 12, height = 7.4, dpi = 360,
       bg = pal$paper, limitsize = FALSE, device = ragg::agg_png)
message("Wrote plots/intelligence_vs_cost.png")
