#!/usr/bin/env Rscript
# make_plot.R: one big, honest, X-ready infographic:
#   "Claude Sonnet 5 vs GLM 5.2 capability & economy"
# Data-driven; no cherry-picking. Every number traces to data/*.csv + sources/.

suppressMessages({
  library(tidyverse)
  library(scales)
  library(ggtext)
  library(patchwork)
  library(ggrepel)
})

setwd("/home/ieqr/Desktop/research/sonnet5-vs-glm52")
source("scripts/theme_bench.R")

bench <- read_csv("data/benchmarks.csv", show_col_types = FALSE)
econ  <- read_csv("data/economy.csv",   show_col_types = FALSE)

lab_color <- function(m) model_colors[m]

# ============================================================ PANEL A
# Capability vs cost frontier: AA Intelligence Index vs output $/M (log)
frA <- econ %>%
  filter(model %in% c("Claude Sonnet 5", "GLM 5.2", "Claude Opus 4.8")) %>%
  transmute(model,
            price = output_price_per_mtok,
            index = intelligence_index,
            open  = weights == "open")

pA <- ggplot(frA, aes(price, index, color = model)) +
  # guide line connecting the three to suggest the "frontier"
  geom_path(aes(group = 1), color = pal$grid, linewidth = 1.1,
            data = frA %>% arrange(price)) +
  geom_point(size = 7) +
  geom_point(data = filter(frA, open), shape = 21, size = 11, stroke = 1.4,
             fill = NA, color = pal$glm52_d) +
  geom_richtext(aes(label = paste0("**", model, "**<br>",
                                   "Index ", index, ", $", sprintf('%.2f', price), "/M out",
                                   ifelse(open, "<br><span style='color:#0E6B5C'>open weights (MIT)</span>", ""))),
                fill = NA, label.color = NA, family = "Inter",
                size = 3.5, hjust = 0, nudge_x = 0.03, lineheight = 1.15,
                show.legend = FALSE) +
  scale_color_manual(values = model_colors) +
  scale_x_log10(labels = label_dollar(suffix = "/M"),
                breaks = c(4.4, 15, 25), expand = expansion(mult = c(0.08, 0.42))) +
  scale_y_continuous(limits = c(48, 60), breaks = seq(48, 60, 4)) +
  labs(title = "Same league, very different price tag",
       subtitle = "Artificial Analysis Intelligence Index v4.1 vs. output price (log scale). Free, open <span style='color:#1B9E8A'>**GLM 5.2**</span> lands within **2 index points** of <span style='color:#D6603D'>**Sonnet 5**</span>, at a **third** of the price.",
       x = "Output price (USD per million tokens, log scale)",
       y = "Intelligence Index (v4.1)") +
  theme_bench(12) + theme(legend.position = "none",
                          plot.subtitle = element_textbox_simple(
                            family = "Inter", size = 11, color = pal$subink,
                            lineheight = 1.3, width = unit(1, "npc"),
                            margin = margin(b = 8)))

# ============================================================ PANEL B
# Head-to-head: Sonnet 5 vs GLM 5.2 on shared % benchmarks (dumbbell)
shared <- c("SWE-bench Pro", "Terminal-Bench 2.1",
            "Humanity's Last Exam (no tools)", "Humanity's Last Exam (with tools)")
hb <- bench %>%
  filter(benchmark %in% shared, model %in% c("Claude Sonnet 5", "GLM 5.2"), unit == "pct") %>%
  select(model, benchmark, score) %>%
  pivot_wider(names_from = model, values_from = score) %>%
  rename(s5 = `Claude Sonnet 5`, glm = `GLM 5.2`) %>%
  mutate(gap = s5 - glm,
         benchmark = fct_reorder(benchmark, s5))

hb_long <- hb %>% pivot_longer(c(s5, glm), names_to = "which", values_to = "score") %>%
  mutate(model = if_else(which == "s5", "Claude Sonnet 5", "GLM 5.2"))

pB <- ggplot(hb) +
  geom_segment(aes(y = benchmark, yend = benchmark, x = glm, xend = s5),
               color = pal$grid, linewidth = 2.2) +
  geom_point(data = hb_long, aes(score, benchmark, color = model), size = 5.5) +
  geom_text(aes(x = pmax(s5, glm), y = benchmark, label = sprintf("+%.1f", gap)),
            hjust = -0.4, family = "Inter SemiBold", size = 3.4, color = pal$subink) +
  scale_color_manual(values = model_colors) +
  scale_y_discrete(labels = label_wrap(22)) +
  scale_x_continuous(labels = label_percent(scale = 1),
                     breaks = seq(40, 80, 20),
                     expand = expansion(mult = c(0.05, 0.14))) +
  labs(title = "Agentic coding & reasoning: a near-tie with GLM 5.2",
       subtitle = "<span style='color:#D6603D'>**Sonnet 5**</span> vs <span style='color:#1B9E8A'>**GLM 5.2**</span> on shared public benchmarks, with Sonnet 5's edge labelled",
       x = NULL, y = NULL) +
  theme_bench(12) + theme(legend.position = "none",
                          plot.subtitle = element_markdown(size = 11),
                          panel.grid.major.y = element_blank())

# ============================================================ PANEL C
# Sonnet 5 vs its OWN Opus 4.8: it doesn't surpass the flagship
vs_opus <- c("SWE-bench Verified", "SWE-bench Pro", "USAMO 2026",
             "Toolathlon (Pass@1)", "CursorBench")
oc <- bench %>%
  filter(benchmark %in% vs_opus, model %in% c("Claude Sonnet 5", "Claude Opus 4.8"), unit == "pct") %>%
  select(model, benchmark, score) %>%
  pivot_wider(names_from = model, values_from = score) %>%
  rename(s5 = `Claude Sonnet 5`, opus = `Claude Opus 4.8`) %>%
  mutate(gap = opus - s5, benchmark = fct_reorder(benchmark, -gap))

oc_long <- oc %>% pivot_longer(c(s5, opus), names_to = "which", values_to = "score") %>%
  mutate(model = if_else(which == "s5", "Claude Sonnet 5", "Claude Opus 4.8"))

pC <- ggplot(oc) +
  geom_segment(aes(y = benchmark, yend = benchmark, x = s5, xend = opus),
               color = pal$grid, linewidth = 2.2) +
  geom_point(data = oc_long, aes(score, benchmark, color = model), size = 5.5) +
  geom_text(aes(x = opus, y = benchmark, label = sprintf("−%.1f", gap)),
            hjust = -0.4, family = "Inter SemiBold", size = 3.4, color = pal$warn) +
  scale_color_manual(values = model_colors) +
  scale_y_discrete(labels = label_wrap(20)) +
  scale_x_continuous(labels = label_percent(scale = 1),
                     breaks = seq(60, 100, 20),
                     expand = expansion(mult = c(0.05, 0.14))) +
  labs(title = "Still a step behind Anthropic's own Opus 4.8",
       subtitle = "<span style='color:#D6603D'>**Sonnet 5**</span> trails <span style='color:#6B6B6B'>**Opus 4.8**</span> on the hard coding, math and tool evals, with the deficit labelled",
       x = NULL, y = NULL) +
  theme_bench(12) + theme(legend.position = "none",
                          plot.subtitle = element_markdown(size = 11),
                          panel.grid.major.y = element_blank())

# ============================================================ PANEL D
# Price bars (output $/M)
pr <- econ %>% filter(model %in% c("GLM 5.2", "Claude Sonnet 5", "Claude Opus 4.8")) %>%
  mutate(model = fct_reorder(model, output_price_per_mtok))

pD <- ggplot(pr, aes(output_price_per_mtok, model, fill = model)) +
  geom_col(width = 0.62) +
  geom_text(aes(label = label_dollar()(output_price_per_mtok)),
            hjust = -0.18, family = "Inter Black", size = 4, color = pal$ink) +
  scale_fill_manual(values = model_colors) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.18))) +
  labs(title = "The economics: 3.4× cheaper output",
       subtitle = "Output price, USD per million tokens",
       x = NULL, y = NULL) +
  theme_bench(12) + theme(legend.position = "none",
                          panel.grid.major.y = element_blank(),
                          axis.text.x = element_blank(),
                          panel.grid.major.x = element_blank())

# ============================================================ ASSEMBLE
title_block <- ggplot() + theme_void() +
  labs(title = "Claude Sonnet 5 didn't move the frontier",
       subtitle = paste0(
         "A real step up from Sonnet 4.6, but Anthropic's **Sonnet 5** (Jun 30 2026) stays a step behind its own **Opus 4.8** on the hardest work, and an ",
         "**open-weight, 3× cheaper** model, Zhipu's **GLM 5.2**, matches it on the agentic-coding work people actually buy Sonnet for.")) +
  theme(plot.title = element_markdown(family = "Inter Black", size = 25, color = pal$ink,
                                      lineheight = 1.02, margin = margin(b = 7)),
        plot.subtitle = element_textbox_simple(family = "Inter", size = 12.5, color = pal$subink,
                                               lineheight = 1.4, width = unit(1, "npc")),
        plot.margin = margin(6, 12, 2, 12))

caption_block <- ggplot() + theme_void() +
  labs(title = paste0(
    "<span style='color:#8a8178'>Sources: Anthropic Claude Sonnet 5 system card and news (Jun 2026), Zhipu/Z.ai GLM 5.2 model card, Artificial Analysis Intelligence Index v4.1, ",
    "Semgrep, llm-stats. Where vendor self-reports differ from independent runs, the independent (Artificial Analysis) figure is shown. ",
    "Index v4.1 is a composite; GDPval/Elo metrics are excluded from the percentage panels. Built with R and the tidyverse.</span>")) +
  theme(plot.title = element_textbox_simple(family = "Inter", size = 8.6, lineheight = 1.35,
                                            width = unit(1, "npc"), margin = margin(t = 4)),
        plot.margin = margin(2, 12, 6, 12))

final <- title_block / pA / pB / pC / pD / caption_block +
  plot_layout(heights = c(0.72, 2.05, 1.45, 1.45, 1.05, 0.30)) +
  plot_annotation(theme = theme(plot.background = element_rect(fill = pal$paper, color = NA),
                                plot.margin = margin(18, 18, 10, 18)))

ggsave("plots/sonnet5_vs_glm52.png", final, width = 10.5, height = 16.5, dpi = 200,
       bg = pal$paper, limitsize = FALSE)
message("Wrote plots/sonnet5_vs_glm52.png")
