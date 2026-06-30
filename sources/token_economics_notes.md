# Token efficiency vs intelligence vs cost — "is GLM truly cheaper?"

Source: Artificial Analysis model pages (read via playwright innerText), 2026-06-30.
Both models evaluated at "max" reasoning effort on the SAME AA Intelligence Index v4.1
(9 evals: GDPval-AA v2, τ³-Banking, Terminal-Bench v2.1, SciCode, HLE, GPQA Diamond,
CritPt, AA-Omniscience, AA-LCR).

## Measured by Artificial Analysis (verbatim)
- Claude Sonnet 5 (Adaptive Reasoning, Max Effort): Index **53**; "When evaluating the
  Intelligence Index, it generated **300M tokens**, which is very verbose in comparison
  to the average of 37M." Verbosity **4/4** (max).
- GLM 5.2 (max): Index **51**; "it generated **140M tokens**, which is very verbose in
  comparison to the average of 96M." Verbosity **4/4** (max). Also flagged "particularly
  expensive when comparing to other open weight models of similar size... notably fast,
  however very verbose."

Key fact: Sonnet 5 emits **~2.1× more output tokens** (300M vs 140M) than GLM 5.2 to
complete the identical eval suite. Both are verbose; Sonnet 5 is the bigger overthinker.

## Sticker price (per 1M tokens)
| Model | input | output |
|---|---|---|
| Claude Sonnet 5 (standard) | $3.00 | $15.00 |
| Claude Sonnet 5 (intro, ->Aug 31) | $2.00 | $10.00 |
| GLM 5.2 | $1.40 | $4.40 |
| Claude Opus 4.8 | $5.00 | $25.00 |

## Output tokens to run the index (AA measured, all at max effort)
| Model | Index | Output tokens | Verbosity |
|---|---|---|---|
| GLM 5.2 | 51 | 140M | 4/4 |
| Claude Opus 4.8 | 56 | **120M** | (very verbose vs avg 87M) |
| Claude Sonnet 5 | 53 | **300M** | 4/4, "very verbose" |
Sonnet 5 uses MORE tokens than both GLM (2.1x) and even its bigger sibling Opus 4.8 (2.5x).
Opus 4.8 is the most token-efficient AND highest-scoring of the three.

## Effective OUTPUT cost to run the whole Intelligence Index (tokens x output price)
(Output dominates cost for verbose reasoning models; input/eval prompts are ~equal across
models so they don't change the ranking.)
- GLM 5.2:        140M x $4.40  = ~$616
- Opus 4.8:       120M x $25.00 = ~$3,000
- Sonnet 5 (intro):300M x $10.00 = ~$3,000  -> ~4.9x GLM
- Sonnet 5 (std): 300M x $15.00 = ~$4,500   -> ~7.3x GLM

## THE KICKER: Sonnet 5 costs MORE to run than Opus 4.8
At standard pricing Sonnet 5 (~$4,500) costs ~1.5x Opus 4.8 (~$3,000) to run the same
index — even though Sonnet's sticker price is only 60% of Opus's. Sonnet 5's 2.5x token
verbosity overwhelms its 0.6x per-token price. Opus is smarter (56 vs 53) AND cheaper in
practice. So Sonnet 5 is beaten on real $/intelligence by BOTH the cheap open model (GLM)
AND its own flagship.

## Cost per Intelligence-Index point (effective output $ to run index / index score)
- GLM 5.2:         $616 / 51  = ~$12 per point   (best value by far)
- Opus 4.8:      $3,000 / 56  = ~$54 per point
- Sonnet 5 intro:$3,000 / 53  = ~$57 per point
- Sonnet 5 std:  $4,500 / 53  = ~$85 per point   (worst value of the four)

## The compounding effect (why sticker price understates it)
- Per output token, Sonnet 5 is ~3.4x GLM ($15 vs $4.40).
- Sonnet 5 also uses ~2.1x more tokens per task (overthinks).
- These COMPOUND: per actual task, Sonnet 5 costs ~3.4 x 2.1 ≈ **7x** more on output,
  for only **+2** Intelligence Index points (53 vs 51).

## Answers
1. Is GLM truly cheaper? YES — and by MORE than the sticker (~3.4x) suggests. Once you
   price the verbosity, it's ~5x (Sonnet intro) to ~7x (Sonnet standard) cheaper to run.
2. Does GLM "overthink so much it's the worse model"? No. The bigger overthinker is
   SONNET 5 (300M vs GLM's 140M). GLM is verbose too (4/4), but cheaper per token AND
   leaner, so it wins on value. Sonnet 5's overthinking erodes its price premium.

## Honest caveats
- Both measured at "max" effort. At lower reasoning effort, token use AND cost drop for
  both; real-world usage varies by how hard you push reasoning.
- AA's own "Cost per Intelligence Index Task" (blended input+cache+reasoning+output) is
  the cleanest single "true cost" figure — fetching exact per-model values (TODO: confirm
  via agent; Opus 4.8 token count still needed).
- Sonnet 5 still leads on specific agentic-coding tasks (SWE-bench Pro/Terminal-Bench) that
  some buyers care about more than index points; value != fit for every workload.
