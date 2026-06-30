# Official Anthropic — Claude Sonnet 5 (read from benchmark image via playwright + vision)

Source: https://www.anthropic.com/news/claude-sonnet-5 (figure "Claude Sonnet 5 benchmark table")
Captured: 2026-06-30. Image saved: anthropic_sonnet5_benchmark_table.png

Comparison vs Sonnet 4.6 and Opus 4.8 (reference). All numbers verbatim from the official figure.

| Capability | Benchmark | Sonnet 5 | Sonnet 4.6 | Opus 4.8 |
|---|---|---|---|---|
| Agentic coding | SWE-bench Pro | 63.2% | 58.1% | 69.2% |
| Agentic coding | Terminal-Bench 2.1 | 80.4% | 67.0% | 82.7% |
| Multidisciplinary reasoning | Humanity's Last Exam (no tools) | 43.2% | 34.6% | 49.8% |
| Multidisciplinary reasoning | Humanity's Last Exam (with tools) | 57.4% | 46.8% | 57.9% |
| Computer use | OSWorld-Verified | 81.2% | 78.5% | 83.4% |
| Knowledge work | GDPval-AA v2 (Elo-like score) | 1618 | 1395 | 1615 |

## Cost-performance (BrowseComp, agentic search) — image anthropic_sonnet5_cost_performance_browsecomp.png
- Sonnet 5 effort curve: low ≈ 52% @ ~$2.10/task, med ≈ 62% @ ~$4.5, high ≈ 65% @ ~$7, xhigh ≈ 69.5% @ ~$8.
- Opus 4.8: low ≈ 67.8% @ ~$5, med ≈ 69% , high ≈ 70%, xhigh ≈ 72%, max ≈ 76% @ ~$10/task.
- Sonnet 4.6: low ≈ 62%, med ≈ 63%, high ≈ 63% (clustered ~$7-9, flat).
- Official note: Sonnet 5 and Opus 4.8 now "cover a single range"; Sonnet 5 = impressive capability at lower cost, Opus 4.8 = greater accuracy at higher price.

## Pricing (official)
- Sonnet 5 introductory (through Aug 31 2026): $2/MTok input, $10/MTok output.
- Sonnet 5 standard: $3/MTok input, $15/MTok output.
- Opus 4.8: $5/MTok input, $25/MTok output.

## Safety note (official text)
- Sonnet 5 shows overall lower rate of undesirable behaviors than Sonnet 4.6; "much lower ability to perform cybersecurity tasks than our current Opus models." (Relevant context for the Semgrep cyber-bench where GLM 5.2 beats Claude.)

## KEY INTEGRITY NOTE
Web SEO-spam blogs claimed Sonnet 5 hits "92.4% SWE-bench Verified" and "96.2% GPQA Diamond". The OFFICIAL figure is SWE-bench **Pro** 63.2% — the 92.4% claim is fabricated/conflated. Do NOT use the spam numbers in the dataset.
