# Claude Sonnet 5 vs. GLM 5.2: an honest benchmark comparison

A data-driven, **honest** look at Anthropic's **Claude Sonnet 5** (released 2026‑06‑30) versus
Zhipu/Z.ai's open‑weight **GLM 5.2** (released 2026‑06‑13), with Anthropic's own **Opus 4.8** and
**Sonnet 4.6** as reference points. Capability *and* economy.

![Sonnet 5 vs GLM 5.2](plots/sonnet5_vs_glm52.png)

> The headline plot (`plots/sonnet5_vs_glm52.png`) is built for sharing. Everything in it
> traces to the CSVs in `data/` and the primary sources archived in `sources/`.

## TL;DR: what the data actually says

1. **Sonnet 5 is a genuine upgrade over Sonnet 4.6.** Every official benchmark improves: SWE‑bench Pro
   58.1 → 63.2, Terminal‑Bench 2.1 67.0 → 80.4, OSWorld‑Verified 78.5 → 81.2, HLE‑with‑tools 46.8 → 57.4,
   USAMO 2026 55.0 → 79.5, GDPval‑AA v2 1381 → 1618. This is not a bad model.

2. **It does not move the frontier.** Sonnet 5 stays a step behind Anthropic's own **Opus 4.8** on the hard
   evals: SWE‑bench Verified 85.2 vs 88.6, SWE‑bench Pro 63.2 vs 69.2, Toolathlon 54.3 vs 59.9,
   CursorBench 61.2 vs 63.8, USAMO 79.5 vs 96.7, and the composite Artificial Analysis Intelligence Index
   53 vs 56. (It does narrowly edge Opus on GDPval knowledge‑work Elo and ~ties HLE‑with‑tools.)

3. **The real story is the open‑source squeeze.** Open‑weight **GLM 5.2** (MIT licence) essentially
   *matches* Sonnet 5 on the agentic‑coding work people actually buy Sonnet for: SWE‑bench Pro 62.1 vs
   63.2, Terminal‑Bench 2.1 78 vs 80.4, and sits within **2 points** of it on the Artificial Analysis
   Intelligence Index (51 vs 53)…

4. **…at roughly a third of the price, with open weights.** Output is **$4.40/M (GLM 5.2)** vs
   **$15/M (Sonnet 5 standard)**, a **3.4×** gap; input is $1.40 vs $3.00. GLM 5.2 also ships a 1M‑token
   context and downloadable MIT weights.

5. **Reality check on the hype.** The viral *"92.4% SWE‑bench Verified"* and *"96.2% GPQA Diamond"*
   numbers that circulated on launch day are **fabricated/misattributed**: per the system card, 92.4% is
   Sonnet 5's **malicious‑request refusal rate** and 96.2% is another refusal metric, while the
   *"84.7% ARC‑AGI‑2"* claim is actually its **BrowseComp** score. The real, defensible numbers are the
   ones in this repo.

**Bottom line:** Sonnet 5 isn't a *bad* model; it's a solid, cheaper‑than‑Opus agentic Sonnet. The
"letdown" is relative: it doesn't beat Opus 4.8, and in mid‑2026 a free, open, 3× cheaper model has
caught up to it on coding. The moat narrowed.

## Repository layout

```
data/
  benchmarks.csv   # tidy: model, benchmark, category, score, unit, higher_better, credibility, source, notes
  economy.csv      # pricing, context, licence, weights, intelligence index per model
plots/
  sonnet5_vs_glm52.png   # the headline infographic (R + tidyverse)
scripts/
  theme_bench.R    # shared visual identity (Inter font, palette, theme)
  make_plot.R      # builds the infographic from data/*.csv
sources/
  official_anthropic_notes.md         # numbers read from the official benchmark image (playwright + vision)
  anthropic_sonnet5_benchmark_table.png
  anthropic_sonnet5_cost_performance_browsecomp.png
  glm52_research_notes.md             # GLM 5.2 findings + credibility flags
  artificialanalysis_glm52.png
```

## Methodology & honesty notes

- **Sourcing.** Numbers are tagged `official` (vendor system card / model card), `independent_leaderboard`
  (Artificial Analysis, ARC Prize, etc.), or `third_party_blog` (e.g. Semgrep). Where a vendor self‑report
  and an independent re‑measurement disagree, the **independent** figure is plotted (e.g. GLM 5.2
  Terminal‑Bench 78 [AA] over the 81.0 self‑report).
- **Apples‑to‑apples.** The head‑to‑head panels only use benchmarks where *both* models have a comparable
  public number. Elo‑style metrics (GDPval) are kept out of the percentage panels because they're a
  different scale.
- **No cherry‑picking, no fabrication.** Several widely‑shared launch‑day numbers were fabricated; they are
  explicitly excluded and flagged above. Every plotted value is in `data/` with a source.
- **Known caveats.** Sonnet 5 launched the same day this was built, so independent leaderboards are still
  thin (it isn't on LMArena yet). The AA Intelligence Index flags Sonnet 5 as unusually verbose
  (~300M tokens vs ~37M average), which inflates token cost in real use. GLM 5.2's "beats Claude" cyber
  result (Semgrep IDOR) is harness‑dependent. Treat single‑source rows accordingly.

## Reproduce

```bash
Rscript scripts/make_plot.R      # writes plots/sonnet5_vs_glm52.png
```

Requires R (≥4.5) with `tidyverse`, `ggtext`, `patchwork`, `ggrepel`, `showtext`, and the Inter font.

---

*Built 2026‑06‑30 with playwright‑cli (data capture) and R + tidyverse (plots). Figures are reported as
found; this is analysis, not endorsement, of either vendor.*
