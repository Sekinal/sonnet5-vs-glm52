# theme_bench.R: shared visual identity for the Sonnet 5 vs GLM 5.2 plots
# A clean, modern, "X-ready" look: Inter font, soft dark-on-light, restrained palette.

suppressMessages({
  library(ggplot2)
  library(showtext)
  library(sysfonts)
  library(ggtext)
})

# --- Fonts ---------------------------------------------------------------
# Inter is installed locally; register weights we use.
inter_dir <- "/home/ieqr/.local/share/fonts/static"
if (dir.exists(inter_dir)) {
  font_add(
    family  = "Inter",
    regular = file.path(inter_dir, "Inter_18pt-Regular.ttf"),
    bold    = file.path(inter_dir, "Inter_18pt-Bold.ttf"),
    italic  = file.path(inter_dir, "Inter_18pt-Italic.ttf")
  )
  font_add(family = "Inter Black",     regular = file.path(inter_dir, "Inter_18pt-Black.ttf"))
  font_add(family = "Inter SemiBold",  regular = file.path(inter_dir, "Inter_18pt-SemiBold.ttf"))
  font_add(family = "Inter Medium",    regular = file.path(inter_dir, "Inter_18pt-Medium.ttf"))
}
showtext_auto()
# IMPORTANT: keep this equal to the ggsave() dpi or text renders mis-scaled.
showtext_opts(dpi = 200)

# --- Palette -------------------------------------------------------------
# Sonnet 5 in Anthropic "clay/coral", GLM 5.2 in a deep teal; refs muted.
pal <- list(
  sonnet5   = "#D6603D",  # Anthropic coral/clay
  sonnet5_d = "#B23A1E",
  glm52     = "#1B9E8A",  # Zhipu-ish teal
  glm52_d   = "#0E6B5C",
  opus      = "#6B6B6B",  # reference grey
  sonnet46  = "#B8B2A8",  # reference warm grey
  ink       = "#1A1714",  # near-black warm
  subink    = "#5C544C",
  paper     = "#FBF9F5",  # warm off-white
  panel     = "#FFFFFF",
  grid      = "#E7E2D9",
  good      = "#1B9E8A",
  warn      = "#D6603D"
)

model_colors <- c(
  "Claude Sonnet 5" = pal$sonnet5,
  "GLM 5.2"         = pal$glm52,
  "Claude Opus 4.8" = pal$opus,
  "Claude Sonnet 4.6" = pal$sonnet46
)

# --- Theme ---------------------------------------------------------------
theme_bench <- function(base_size = 11) {
  theme_minimal(base_family = "Inter", base_size = base_size) +
    theme(
      plot.background  = element_rect(fill = pal$paper, color = NA),
      panel.background = element_rect(fill = pal$paper, color = NA),
      panel.grid.major = element_line(color = pal$grid, linewidth = 0.35),
      panel.grid.minor = element_blank(),
      axis.text   = element_text(color = pal$subink, size = base_size * 0.92),
      axis.title  = element_text(color = pal$subink, size = base_size * 0.95),
      plot.title  = element_markdown(family = "Inter Black", color = pal$ink,
                                     size = base_size * 2.0, lineheight = 1.05),
      plot.subtitle = element_markdown(family = "Inter", color = pal$subink,
                                       size = base_size * 1.05, lineheight = 1.2),
      plot.caption  = element_markdown(family = "Inter", color = pal$subink,
                                       size = base_size * 0.72, hjust = 0, lineheight = 1.2),
      legend.position = "top",
      legend.title = element_blank(),
      legend.text  = element_text(color = pal$ink, family = "Inter SemiBold",
                                  size = base_size * 0.95),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.margin = margin(22, 26, 16, 22)
    )
}

message("theme_bench.R loaded")
