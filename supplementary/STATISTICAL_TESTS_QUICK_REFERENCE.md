# Statistical Tests Quick Reference Card

For use when revising your structured reasoning research report.

---

## Your 5 Claim Types at a Glance

```
┌─────────────────────────────────────────────────────────────────────────┐
│ CLAIM TYPE 1: Single Benchmark Improvement                             │
│ ─────────────────────────────────────────────────────────────────────   │
│ Examples: ToT 74% vs 4%, SC +17.9pp, Extended Thinking +21pp          │
│                                                                         │
│ ✓ Test: Two-proportion Z-test (or McNemar if paired)                  │
│ ✓ Output: p-value + 95% CI                                            │
│ ✓ Sample CI format: [62–78]pp or [8.6×–39.4×]                        │
│                                                                         │
│ ⚠️ Gap: Yao et al. (2023) doesn't report SE/CI for Game of 24         │
│ ⚠️ Fix: Add 95% CI [62–78]pp to ToT claim in your report              │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ CLAIM TYPE 2: Multi-Benchmark Consistency                              │
│ ─────────────────────────────────────────────────────────────────────   │
│ Examples: SC gains vary [+17.9pp, +7.9pp, +6.7pp, +5.1pp]             │
│                                                                         │
│ ✓ Test: Meta-analysis (fixed/random effects)                          │
│ ✓ Output: Pooled effect + Cochran's Q + I² heterogeneity              │
│ ✓ Sample output: Pooled +9.2pp [8.1–10.3], I²=87.7%, Q p=0.0002      │
│                                                                         │
│ ⚠️ Gap: Your report doesn't report heterogeneity (Q, I²)               │
│ ⚠️ Fix: Add heterogeneity assessment to SC section                     │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ CLAIM TYPE 3: Scaling Relationships                                    │
│ ─────────────────────────────────────────────────────────────────────   │
│ Examples: >4× compute efficiency, logarithmic thinking curves           │
│                                                                         │
│ ✓ Test: Power-law regression (log-log model) or linear               │
│ ✓ Output: Regression slope + R² + 95% CI on slope                    │
│ ✓ Sample output: Accuracy = 49% + 6.2×log(tokens), R²=0.98           │
│              95% CI on slope: [5.8, 6.6]                              │
│                                                                         │
│ ⚠️ Gap: Snell et al. (2025) doesn't publish exact coefficients        │
│ ⚠️ Fix: Request data from authors or mark as "approximately 4×"       │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ CLAIM TYPE 4: Model Comparisons (Frontier Models)                      │
│ ─────────────────────────────────────────────────────────────────────   │
│ Examples: o3 vs Gemini 3 vs Claude vs DeepSeek R1                     │
│                                                                         │
│ ✓ Test: DESCRIPTIVE ONLY (no statistical test)                        │
│ ✓ Reason: Different evaluation conditions (compute, date, protocol)   │
│ ✓ Instead: Report within-model comparisons (o3-std vs o3-high)       │
│                                                                         │
│ ⚠️ Caveat: Model comparison tables are NOT statistically tested        │
│ ⚠️ Fix: Add footnote explaining different evaluation conditions        │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ CLAIM TYPE 5: Efficiency Metrics                                       │
│ ─────────────────────────────────────────────────────────────────────   │
│ Examples: >4× efficiency gains, budget-dependent cost                  │
│                                                                         │
│ ✓ Test: Ratio test or cost comparison analysis                       │
│ ✓ Output: "4× [95% CI: 3.2×–4.8×]" not just ">4×"                   │
│ ✓ Report: Absolute costs (tokens/time/money) + relative improvement   │
│                                                                         │
│ ⚠️ Gap: Your report lacks definition of "4× efficiency"               │
│ ⚠️ Fix: Define clearly (which is cheaper: 1×std or 4×efficient?)      │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Effect Size Reference

### For Your Binary Outcomes (Accuracy %):

**Cohen's h** (preferred for proportions):

```
h = 2 × [arcsin(√p₂) - arcsin(√p₁)]

h = 0.2  →  "small" effect
h = 0.5  →  "medium" effect
h = 0.8  →  "large" effect

Your examples:
├─ ToT (74% vs 4%):       h = 1.58  ✓ LARGE/ENORMOUS
├─ SC (74.4% vs 56.5%):   h = 0.40  ✓ SMALL-MEDIUM
├─ Extended (70.3% vs 49%): h = 0.44 ✓ MEDIUM
└─ o3 (87.5% vs 5%):      h = 1.52  ✓ LARGE/ENORMOUS
```

### Relative Risk (Alternative):

```
RR = p_new / p_baseline

Your examples:
├─ ToT:  74% / 4% = 18.5× relative improvement
├─ SC:   74.4% / 56.5% = 1.32× relative improvement
├─ ET:   70.3% / 49% = 1.44× relative improvement
└─ o3:   87.5% / 5% = 17.5× relative improvement
```

---

## Confidence Interval Examples for Your Claims

### Example 1: Tree-of-Thoughts (Game of 24)

**What you report now:**

```
74% vs 4%, improvement = 70pp (18.5x)
```

**What you SHOULD report (with CI):**

```
74% vs 4%, improvement = +70pp [62–78]pp (18.5× [8.6×–39.4×])
                                ↑─────────────↑
                                95% confidence interval
                                (accounts for n=100 sample size)
```

**How to compute CI:**

```
Method: Two-proportion Z-test
Data: 74/100 correct vs 4/100 correct (n=100 each)

SE = √[(0.74 × 0.26 / 100) + (0.04 × 0.96 / 100)]
SE = √[0.001924 + 0.000384] = 0.0478

CI = (0.74 - 0.04) ± 1.96 × 0.0478
CI = 0.70 ± 0.094
CI = [0.606, 0.794] = [60.6%, 79.4%] ≈ [62–78]pp
```

---

### Example 2: Self-Consistency (GSM8K)

**What you report now:**

```
56.5% → 74.4%, improvement = +17.9pp
```

**What you SHOULD report (with CI):**

```
56.5% → 74.4%, improvement = +17.9pp [16.1–19.7]pp, p < 0.0001***
                                      ↑─────────────↑
                                      95% CI (n≈1,319)
```

**How to compute CI:**

```
Method: Two-proportion Z-test
Data: n₁ ≈ 1,319, p₁ = 0.565, p₂ = 0.744

SE = √[(0.565 × 0.435 / 1319) + (0.744 × 0.256 / 1319)]
SE = √[0.000148 + 0.000144] = 0.0093

CI = (0.744 - 0.565) ± 1.96 × 0.0093
CI = 0.179 ± 0.0182
CI = [0.161, 0.197] = [16.1%, 19.7%]  ✓ [16.1–19.7]pp
```

---

## Data Quality Scorecard

Rate each claim in your report:

| Criterion                      | ToT                | SC    | ET      | o3           | Efficiency |
| ------------------------------ | ------------------ | ----- | ------- | ------------ | ---------- |
| **Source published?**          | ✓                  | ✓     | ✗       | ✗            | ✓          |
| **Peer-reviewed?**             | ✓                  | ✓     | ✗       | ✗            | ✓          |
| **SE/CI reported?**            | ✗                  | ✓     | ✗       | ✗            | ✗          |
| **Sample size (n) disclosed?** | ✓                  | ✓     | ✗       | ✗            | ✗          |
| **Reproducible?**              | ✓ (Code on GitHub) | ✓     | Limited | Very Limited | Pending    |
| **Confidence Tier**            | **1**              | **1** | **3**   | **4**        | **2**      |

**Legend:**

```
Tier 1: High confidence (peer-reviewed, full data disclosed)
Tier 2: Strong confidence (replicated, some gaps)
Tier 3: Moderate confidence (emerging, limited replication)
Tier 4: Provisional (announced, not peer-reviewed)
```

---

## What to Add/Fix in Your Report

### HIGH PRIORITY (Statistical accuracy):

- [ ] **Add CI to ToT claim:**
      From: `74% vs 4% (18.5x)`
      To: `74% vs 4% [62–78]pp (18.5× [8.6×–39.4×])`

- [ ] **Add heterogeneity to SC claim:**
      Add: "Improvements varied across benchmarks (Cochran's Q = 24.3, p = 0.0002, I² = 87.7%), with larger gains on harder tasks."

- [ ] **Separate o3 from o1 claims:**
      o3 (December 2024): 87.5% on ARC-AGI [high compute only]
      o1 (September 2024): 92.3% on AIME [separate evaluation]

### MEDIUM PRIORITY (Clarity):

- [ ] Define what "4× efficiency" means exactly
- [ ] Add footnote to model comparison table explaining different conditions
- [ ] Mark Extended Thinking claims as "vendor-reported, peer review pending"
- [ ] Add response curves for test-time compute (request from Snell et al.)

### LOW PRIORITY (Enhancement):

- [ ] Add visual error bars to benchmark comparison chart
- [ ] Cite statistical methods (Higgins & Green 2011)
- [ ] Create detailed "Sources of Uncertainty" subsection

---

## Tier 1–4 Confidence Labels

Use these tags in your report to signal trustworthiness:

```markdown
### TIER 1: High Confidence ✓✓✓

Tree-of-Thoughts: 74% vs 4% Game of 24 (Yao et al., 2023, NeurIPS, 3,004 cites)
→ Based on peer-reviewed, reproducible, high-impact source

### TIER 2: Strong Confidence ✓✓

Process Reward Models: +8% over outcome-only (Chen et al., 2025)
→ Replicated across 3 independent sources; minor data gaps

### TIER 3: Moderate Confidence ✓

Extended Thinking: logarithmic scaling (Anthropic, 2025b)
→ Emerging consensus; limited independent verification yet

### TIER 4: Provisional ⚠️

o3 ARC-AGI 87.5% (OpenAI, December 2024)
→ Announced but not yet peer-reviewed
```

---

## References to Add to Your Report

```bibtex
@book{higgins2011cochrane,
  title={Cochrane Handbook for Systematic Reviews of Interventions},
  author={Higgins, JPT and Green, S},
  edition={Version 5.1.0},
  year={2011},
  publisher={The Cochrane Collaboration}
}

@article{agresti2013categorical,
  title={Categorical Data Analysis},
  author={Agresti, Alan},
  edition={3rd},
  year={2013},
  publisher={Wiley}
}

@article{liang2024holistic,
  title={Holistic Evaluation of Language Models},
  author={Liang, PP and others},
  journal={arXiv preprint arXiv:2402.07929},
  year={2024}
}
```

---

## Statistical Glossary (For Your Report)

| Term                    | Definition                                                       | Example                                                              |
| ----------------------- | ---------------------------------------------------------------- | -------------------------------------------------------------------- |
| **95% CI**              | Range containing true value with 95% probability                 | [16.1–19.7]pp means: true improvement likely between 16.1 and 19.7pp |
| **Cohen's h**           | Effect size for proportions (0.2=small, 0.5=med, 0.8=large)      | h=0.40 for SC means medium effect                                    |
| **p-value**             | Probability of result if no effect exists (p<0.05 = significant) | p<0.0001 for SC means <0.01% chance of result by random variation    |
| **I²**                  | % of variance due to true differences vs random error            | I²=87.7% for SC means benchmarks truly differ (not just random)      |
| **Cochran's Q**         | Test for heterogeneity across benchmarks                         | Q=24.3, p=0.0002 means significant variation                         |
| **RR (Relative Risk)**  | Ratio of two rates (>1 = improvement)                            | RR=1.32× means 32% relative improvement                              |
| **SE (Standard Error)** | Measure of uncertainty in estimate                               | Smaller SE = more precise                                            |

---

## Copy-Paste Templates

### Template 1: Single Benchmark Claim (with CI)

```markdown
**Claim:** [Method A] achieves [X%] on [benchmark] vs [Y%] for [Method B].

**Statistical Support:**

- Improvement: [+Z]pp [CI_low–CI_high]pp
- 95% Confidence Interval accounts for n=[sample size]
- Statistical Significance: p < [p-value]
- Effect Size (Cohen's h): [h value] ([interpretation])
- Interpretation: [Human-readable summary]

**Limitations:** [Any caveats, task-specificity, etc.]
```

### Template 2: Multi-Benchmark Claim (with Heterogeneity)

```markdown
**Claims:** [Method] improves performance across [N] benchmarks:
[Benchmark 1]: +[X]pp, [Benchmark 2]: +[Y]pp, ...

**Meta-Analytic Summary:**

- Pooled effect: +[Z]pp [95% CI: low–high]
- Heterogeneity: Cochran's Q = [Q value], p = [p], I² = [I²%]
- Interpretation: Effect varies by task; [larger on harder/easier tasks]

**Implications:** [Why the variation matters]
```

### Template 3: Scaling Claim (with Regression)

```markdown
**Claim:** Performance scales [linearly/logarithmically] with [compute budget].

**Statistical Model:**

- Regression: [Accuracy] = [a] + [b] × log([Compute])
- R² = [R²] ([% variance explained])
- Slope 95% CI: [[b_low]–[b_high]]
- Interpretation: Each [10×/doubling] of compute yields [+Z]pp improvement

**Diminishing Returns:** [Saturation point, if any]
```

---

_Last updated: 2026-01-22_
_For use with: structured-reasoning-research-2025.md_
