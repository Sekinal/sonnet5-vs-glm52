# GLM 5.2 (Zhipu / Z.ai): research agent findings, 2026-06-30

Launched 2026-06-13. Open weights (MIT), HF zai-org/GLM-5.2. MoE 753B total / ~40B active, 1M context.

## Benchmarks (with credibility)
| benchmark | score | unit | source cred | notes |
|---|---|---|---|---|
| HLE (no tools) | 40.5 | % | official | AA measured ~40 (consistent) |
| HLE (with tools) | 54.7 | % | official | |
| SWE-bench Pro | 62.1 | % | official | OpenHands harness; consistent across sources |
| Terminal-Bench 2.1 | 81.0 | % | official | AA measured 78 |
| Terminal-Bench 2.1 (best harness) | 82.7 | % | official | cherry-picked harness |
| GPQA Diamond | 91.2 | % | official | AA measured 89 |
| GPQA Diamond | 89 | % | independent (AA) | use this for honest compare |
| AIME 2026 | 99.2 | % | official | GPT-5.5 judge; AIME 2026 not 2025 |
| AA Intelligence Index v4.1 | 51 | score | independent (AA) | #1 open-weight; 4th overall (Fable5 60, Opus4.8 56, GPT5.5 55) |
| SciCode | 50 | % | independent (AA) | |
| tau3-Banking | 27 | % | independent (AA) | agentic tool-use, weak |
| AA-LCR long context | 71 | % | independent (AA) | |
| CritPt | 21 | % | independent (AA) | |
| GDPval-AA v2 | 1524 | score | independent (AA) | vs Sonnet 5 1618 |
| ARC-AGI-1 | 77.0 | % | independent (ARC Prize via OfficeChai) | $0.19/task; highest open |
| ARC-AGI-2 | 22.8 | % | independent (ARC Prize via OfficeChai) | $0.25/task; highest open |
| IDOR detection F1 | 39 | % | third_party (Semgrep) | beat Claude Code(Opus4.8) 28%; harness-dependent |
| FrontierSWE Dominance | 74.4 | score | official | trails Opus 4.8 ~1% |
| MCP-Atlas (public) | 76.8 | % | official | agentic |
| Tool-Decathlon | 48.2 | % | official | below several closed models |

## Pricing / specs
- Input $1.40/M, Output $4.40/M, cached input $0.26/M (official docs.z.ai).
- Context 1,000,000; max output ~128K.
- License MIT, open weights.

## Skeptic flags
- Official self-reported ~2-3 pts above AA independent (use AA for honest compare).
- No official SWE-bench Verified (only Pro). Don't conflate.
- AIME is 2026 set, not directly comparable to others' 2025.
- Design/Code Arena Elo (1360/1595) only via aggregated search: not locked in.
- Semgrep "beats Claude" is agent-vs-agent minimal scaffolding; custom harness GPT5.5/Opus4.8 score higher.
- Params 753B official vs 744B AA.
