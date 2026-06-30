#!/usr/bin/env Rscript
# make_tokens.R: deeper analysis, token efficiency vs intelligence vs TRUE cost.
# Q: "Is GLM 5.2 truly cheaper, or does over-thinking flip it?"
# Token counts + cost-to-run measured by Artificial Analysis (Intelligence Index v4.1,
# max effort). Sonnet 5 cost-to-run is DERIVED (AA page shows $0.00, day-one bug).

suppressMessages({
  library(tidyverse); library(scales); library(ggtext); library(patchwork); library(ggrepel)
})
setwd("/home/ieqr/Desktop/research/sonnet5-vs-glm52")
source("scripts/theme_bench.R")

te <- read_csv("data/token_economics.csv", show_col_types = FALSE)

mc <- c(
  "GLM 5.2"          = pal$glm52,
  "Claude Sonnet 5"  = pal$sonnet5,
  "Claude Opus 4.8"  = pal$opus,
  "GPT-5.5"          = "#8E86A8",
  "Gemini 3.1 Pro"   = "#9AA7B2"
)
avg_tokens <- 37

# ---------- PANEL A: the value frontier, intelligence vs TRUE cost ----------
fr <- te %>% filter(frontier) %>% arrange(cost_run_index_usd)
s5 <- te %>% filter(model == "Claude Sonnet 5")

pA <- ggplot(te, aes(cost_run_index_usd, intelligence_index)) +
  geom_line(data = fr, color = pal$connector, linewidth = 1.4, lineend = "round") +
  geom_segment(data = s5, aes(x = cost_low, xend = cost_high,
                              y = intelligence_index, yend = intelligence_index),
               color = pal$sonnet5, linewidth = 1.2, alpha = 0.5, lineend = "round") +
  geom_point(aes(color = model), size = 6.5) +
  geom_text_repel(aes(label = paste0(label, "\n", intelligence_index, ",  $",
                                     comma(cost_run_index_usd), ifelse(measured, "", "*")),
                      color = model),
                  family = "BenchSans", size = 3.2, lineheight = 0.95,
                  seed = 4, box.padding = 0.9, point.padding = 0.5,
                  min.segment.length = 0.3, segment.color = pal$grid, show.legend = FALSE) +
  annotate("richtext", x = 1020, y = 47.8, label = "best value lives here",
           family = "BenchSans", size = 3.0, color = pal$glm52_d, fill = NA, label.color = NA, hjust = 0) +
  scale_color_manual(values = mc) +
  scale_x_log10(labels = label_dollar(), breaks = c(800, 1500, 3000, 6000),
                expand = expansion(mult = c(0.13, 0.18))) +
  scale_y_continuous(limits = c(45, 59), breaks = seq(46, 58, 3)) +
  labs(title = "The value frontier, and Sonnet 5 sits off it",
       subtitle = "Intelligence Index vs. <span style='color:#1A1714'>**measured cost to run the whole index**</span> (log scale). <span style='color:#D6603D'>**Sonnet 5**</span> is the only model below the line: both Opus 4.8 and GPT-5.5 score higher for less money.",
       x = "Cost to run the Intelligence Index (USD, log scale), measured by Artificial Analysis",
       y = "Intelligence Index (v4.1)") +
  theme_bench(12) + theme(legend.position = "none",
                          plot.subtitle = element_textbox_simple(family = "BenchSans", size = 10.5,
                            color = pal$subink, lineheight = 1.3, width = unit(1, "npc"),
                            margin = margin(b = 8)))

# ---------- PANEL B: the driver, output tokens to run the index ----------
tb <- te %>% mutate(model = fct_reorder(model, output_tokens_M))
pB <- ggplot(tb, aes(output_tokens_M, model, fill = model)) +
  geom_col(width = 0.62) +
  geom_vline(xintercept = avg_tokens, linetype = "22", color = pal$subink, linewidth = 0.5) +
  annotate("richtext", x = avg_tokens, y = 5.7, label = "field avg ~37M",
           family = "BenchSans", size = 3.0, color = pal$subink, fill = NA, label.color = NA, hjust = -0.04) +
  geom_text(aes(label = paste0(output_tokens_M, "M")), hjust = -0.25,
            family = "BenchSans Black", size = 3.8, color = pal$ink) +
  scale_fill_manual(values = mc) +
  scale_y_discrete(labels = function(x) te$label[match(x, te$model)]) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.16))) +
  labs(title = "Why: Sonnet 5 over-thinks the most",
       subtitle = "Output tokens to complete the <span style='color:#1A1714'>**same**</span> 9-eval suite. Sonnet 5 burns **2.1x GLM 5.2** and **2.5x its own Opus 4.8**, the highest in the field.",
       x = "Output tokens to run the index (millions)", y = NULL) +
  theme_bench(12) + theme(legend.position = "none",
                          panel.grid.major.y = element_blank(),
                          plot.subtitle = element_textbox_simple(family = "BenchSans", size = 10.5,
                            color = pal$subink, lineheight = 1.3, width = unit(1, "npc"),
                            margin = margin(b = 6)),
                          axis.text.x = element_blank(), panel.grid.major.x = element_blank())

# ---------- title + caption ----------
title_block <- ggplot() + theme_void() +
  labs(title = "Is GLM 5.2 really cheaper? Yes, the sticker undersells it",
       subtitle = paste0(
         "Per token, <span style='color:#D6603D'>**Sonnet 5**</span> costs about 3.4x <span style='color:#1B9E8A'>**GLM 5.2**</span>. But it also emits **2.1x more tokens** per task, so the same workload costs **4 to 6x more**, ",
         "for **+2** index points. The over-thinker is Sonnet 5, not GLM: it even costs more to run than its own smarter **Opus 4.8**.")) +
  theme(plot.title = element_textbox_simple(family = "BenchSans Black", size = 22, color = pal$ink,
                                      lineheight = 1.06, width = unit(1, "npc"), margin = margin(b = 6)),
        plot.subtitle = element_textbox_simple(family = "BenchSans", size = 11.5, color = pal$subink,
                                               lineheight = 1.36, width = unit(1, "npc")),
        plot.margin = margin(4, 10, 2, 10))

caption_block <- ggplot() + theme_void() +
  labs(title = "<span style='color:#8a8178'>Source: Artificial Analysis, output tokens and measured cost to run Intelligence Index v4.1 at max reasoning effort (Sonnet 5 $6,015, Opus 4.8 $3,753, GPT-5.5 $2,819, GLM 5.2 $933, Gemini 3.1 Pro $815; field-avg ~37M tokens). Sonnet 5 measured at standard $3/$15; the faint bar back to ~$4,010 marks intro pricing ($2/$10 through Aug 31). Sticker output prices per 1M: Sonnet 5 $15, GLM 5.2 $4.40, Opus 4.8 $25. Built with R and the tidyverse.</span>") +
  theme(plot.title = element_textbox_simple(family = "BenchSans", size = 7.4, lineheight = 1.32,
                                            width = unit(1, "npc"), margin = margin(t = 3)),
        plot.margin = margin(2, 10, 4, 10))

final <- title_block / pA / pB / caption_block +
  plot_layout(heights = c(0.66, 1.6, 1.12, 0.30)) +
  plot_annotation(theme = theme(plot.background = element_rect(fill = pal$paper, color = NA),
                                plot.margin = margin(16, 16, 10, 16)))

ggsave("plots/token_economics.png", final, width = 9, height = 11.25, dpi = 200,
       bg = pal$paper, limitsize = FALSE, device = ragg::agg_png)
message("Wrote plots/token_economics.png")
