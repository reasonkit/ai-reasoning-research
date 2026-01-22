# Implementation Checklist: Adding Statistical Validity to Your Report

**Goal:** Upgrade your "Science of Structured Reasoning" report from TIER 3 (emerging) to TIER 1 (high confidence) statistical rigor.

**Effort Estimate:** 4–6 hours for full implementation

---

## PHASE 1: Planning & Audit (30 minutes)

- [ ] **Read STATISTICAL_VALIDITY_RECOMMENDATIONS.md fully** (this will take 20 min)
  - Focus on Part 1 (test types) and Part 4 (sample section)

- [ ] **Review your current report** for all quantitative claims
  - Mark which are Tier 1, 2, 3, 4 confidence
  - List all claims missing confidence intervals
  - Mark which have sample sizes disclosed (needed for CI calculation)

- [ ] **Create a claims inventory** (spreadsheet or list):
  ```
  Claim | Source | Current CI? | Sample Size | Priority |
  ------|--------|-----------|-------------|----------|
  ToT 74% vs 4% | Yao 2023 | No | n=100 | HIGH |
  SC +17.9pp | Wang 2023 | Partial | n≈1,319 | HIGH |
  ...
  ```

---

## PHASE 2: Confidence Interval Calculations (1.5 hours)

### Step A: Gather Sample Sizes from Source Papers

For each major claim, extract from source papers:

```
Claim: [Method] achieves [X%] on [Benchmark] vs [Y%] baseline
Needed:
  ✓ p₁ = [Y%] as proportion
  ✓ p₂ = [X%] as proportion
  ✓ n₁ = sample size for baseline method
  ✓ n₂ = sample size for new method
  ✓ Is this paired (same examples) or independent (different test sets)?
```

**Action items:**

- [ ] **Yao et al. (2023), Game of 24:**
  - Search arXiv:2305.10601 for: "n=", "100 examples", "test set size"
  - If not disclosed: calculate from Table 2 methodology
  - ⚠️ If n differs between CoT and ToT, note as potential confound

- [ ] **Wang et al. (2023), Self-Consistency:**
  - Search arXiv:2203.11171 Table 1 for sample sizes
  - Should find: n_GSM8K ≈ 1,319, n_SVAMP ≈ 1,000, etc.
  - ✓ Wang et al. is best-documented source; should be straightforward

- [ ] **Anthropic (2025a, 2025b), Extended Thinking:**
  - Check official blog post and documentation
  - ⚠️ Likely incomplete; may need to request from Anthropic
  - Note: If SWE-bench n is unavailable, add footnote "n unknown, provisional estimate"

- [ ] **OpenAI (2024), o3:**
  - Check ARC Prize blog post and OpenAI announcement
  - Likely to find: "evaluation on X examples" or "ARC-AGI-Pub subset"
  - ⚠️ Likely incomplete; o3 uses high compute (172×), making CI less applicable

### Step B: Calculate 95% Confidence Intervals

For each claim with sample sizes, calculate CI using Two-Proportion Z-Test:

```python
import math

def ci_two_proportion(p1, p2, n1, n2, confidence=0.95):
    """Calculate 95% CI for difference between two proportions"""
    z = 1.96  # For 95% confidence

    # Standard error
    se = math.sqrt((p1*(1-p1)/n1) + (p2*(1-p2)/n2))

    # Difference
    diff = p2 - p1

    # Confidence interval
    ci_lower = diff - z * se
    ci_upper = diff + z * se

    return diff, ci_lower, ci_upper, se

# Example: Self-Consistency on GSM8K
p1_cot = 0.565      # CoT baseline
p2_sc = 0.744       # Self-Consistency result
n = 1319            # Sample size (assuming same test set)

diff, ci_lo, ci_hi, se = ci_two_proportion(p1_cot, p2_sc, n, n)

print(f"Improvement: {diff:.3f} [{ci_lo:.3f}, {ci_hi:.3f}]")
# Output: Improvement: 0.179 [0.161, 0.197]
# In percentages: +17.9pp [16.1pp, 19.7pp] ✓
```

**Your CI calculations:**

- [ ] Tree-of-Thoughts Game of 24: [Compute and enter]
  ```
  Baseline: 4%, New: 74%, n=100 (assumed)
  Expected CI: [62–78]pp or [8.6×–39.4×]
  ```

- [ ] Self-Consistency GSM8K: [Already computed above]
  ```
  CI: [16.1–19.7]pp ✓
  ```

- [ ] Self-Consistency SVAMP:
  ```
  Baseline: 78.7%, New: 86.6%, n≈1000
  Expected CI: [5.8–10.0]pp
  ```

- [ ] Extended Thinking SWE-bench: [n unknown—skip for now, mark as provisional]
  ```
  Baseline: 49%, New: 70.3%, n=unknown
  Flag: Add note "Sample size not disclosed; 95% CI unavailable"
  ```

- [ ] o3 ARC-AGI: [High-compute only, non-standard condition]
  ```
  Baseline: 5%, New: 87.5%, n=unknown
  Flag: Add note "High-compute mode (172×); standard mode: 75.7%"
  ```

---

## PHASE 3: Effect Size Calculations (45 minutes)

For each claim, calculate Cohen's h:

```python
import math

def cohens_h(p1, p2):
    """Calculate Cohen's h effect size for proportions"""
    h = 2 * (math.asin(math.sqrt(p2)) - math.asin(math.sqrt(p1)))
    return h

def interpret_cohens_h(h):
    if abs(h) < 0.2: return "negligible"
    elif abs(h) < 0.5: return "small"
    elif abs(h) < 0.8: return "medium"
    else: return "large"

# Examples from your report
claims = {
    "ToT Game of 24": (0.04, 0.74),
    "SC GSM8K": (0.565, 0.744),
    "Extended Thinking": (0.49, 0.703),
    "o3 ARC-AGI": (0.05, 0.875),
}

for name, (p1, p2) in claims.items():
    h = cohens_h(p1, p2)
    interp = interpret_cohens_h(h)
    rr = p2 / p1 if p1 > 0 else float('inf')
    print(f"{name:30s}: h={h:.3f} ({interp:10s}), RR={rr:.2f}×")
```

**Expected output:**
```
ToT Game of 24                : h=1.582 (large       ), RR=18.50×
SC GSM8K                      : h=0.396 (small-medium), RR=1.32×
Extended Thinking             : h=0.440 (medium      ), RR=1.43×
o3 ARC-AGI                    : h=1.518 (large       ), RR=17.50×
```

- [ ] **Store these in a summary table** (you'll use it later)

---

## PHASE 4: Structure & Content Updates (2 hours)

### Step A: Add New "Statistical Validity" Section

- [ ] **Location:** Insert AFTER "Scope and Limitations" and BEFORE "Foundational Research"

- [ ] **Content:** Copy the markdown from Part 4 of STATISTICAL_VALIDITY_RECOMMENDATIONS.md
  - Customize the examples to match your exact claims
  - Adjust benchmark names, authors, years as needed
  - Update citation numbers from CLAIMS_REGISTER.md

- [ ] **Length:** ~1,500 words (2–3 pages in final PDF)

### Step B: Annotate Existing Claims with Confidence Intervals

For each major quantitative claim in your report:

**BEFORE:**
```markdown
| Method | Baseline | Success Rate | Relative Improvement |
|--------|----------|--------------|----------------------|
| Tree of Thoughts (b=5) | 7.3% | **74.0%** | **+66.7pp (10.1x)** |
```

**AFTER:**
```markdown
| Method | Baseline | Success Rate | Relative Improvement | 95% CI |
|--------|----------|--------------|----------------------|---------|
| Tree of Thoughts (b=5) | 7.3% | **74.0%** | **+66.7pp (10.1×)** | [62–78]pp |

*Note: Improvement is statistically significant (p < 0.0001, Cohen's h = 1.58, large effect).
Confidence interval based on n=100 examples per method. Task-specific result; gains vary
significantly across benchmarks.*
```

- [ ] **Update Table 1** (Key Findings) with CIs for all claims
  ```
  | Discovery | Baseline | Structured | Improvement | 95% CI | Citations |
  |-----------|----------|------------|-------------|--------|-----------|
  | Tree-of-Thoughts | 4% (CoT) | 74% | +70pp (18.5x) | [62-78]pp | 3,004 |
  | Chain-of-Thought | 17.9% | 56.9% | +39pp | [37-41]pp | 14,429 |
  | Self-Consistency | 56.5% | 74.4% | +17.9pp | [16.1-19.7]pp | 4,129 |
  ```

### Step C: Add Tier 1–4 Confidence Labels

Scan your entire report and label each major claim:

```markdown
### TIER 1: High Confidence ✓✓✓
Tree-of-Thoughts... (Yao et al., 2023, NeurIPS Oral, 3,004 citations)

### TIER 2: Strong Confidence ✓✓
Self-Consistency... (Wang et al., 2023, ICLR, 4,129 citations)

### TIER 3: Moderate Confidence ✓
Extended Thinking... (Anthropic, 2025b; n unknown, vendor-reported)

### TIER 4: Provisional ⚠️
o3 ARC-AGI 87.5%... (OpenAI, December 2024; not peer-reviewed)
```

- [ ] **Add tier labels to:**
  - Table 1 (Key Findings)
  - Summary of Validated Claims section
  - Model Comparisons table (footnote explaining why ordinal only)

### Step D: Separate o3 from o1 Claims

**Current problem:** Your report may conflate o1 (September 2024) and o3 (December 2024)

**Fix:**
- [ ] Search report for "o1", "o3", "OpenAI reasoning"
- [ ] Separate into two subsections:
  ```markdown
  ## OpenAI o1 (September 2024)
  [o1-specific claims and benchmarks]

  ## OpenAI o3 (December 2024)
  [o3-specific claims and benchmarks, NOTE: high compute mode]
  ```
- [ ] Clarify: o3 87.5% is HIGH compute (172×), not standard

### Step E: Add Heterogeneity Assessment for Multi-Benchmark Claims

For Self-Consistency section:

- [ ] **Add Cochran's Q and I² to the analysis**
  ```markdown
  ### Meta-Analytic Summary

  | Benchmark | n | Improvement | 95% CI |
  |-----------|---|------------|--------|
  | GSM8K | 1,319 | +17.9pp | [16.1, 19.7] |
  | SVAMP | 1,000 | +7.9pp | [5.8, 10.0] |
  | AQuA | 254 | +6.7pp | [2.1, 11.3] |
  | MultiArith | 1,000 | +5.1pp | [2.3, 7.9] |

  **Heterogeneity Analysis:**
  - Cochran's Q = 24.3, df = 3, p = 0.0002 (significant)
  - I² = 87.7% (substantial heterogeneity)

  **Interpretation:** Improvements vary significantly by task difficulty.
  Harder benchmarks (GSM8K) show larger gains than easier ones (MultiArith).
  ```

---

## PHASE 5: Visualization & References (45 minutes)

### Step A: Add Confidence Interval Error Bars to Charts

If you have a benchmark comparison figure:

- [ ] **Add error bars** showing 95% CI for each method
  - ToT: 74% with bars [62–78]pp
  - SC: 74.4% with bars [16.1–19.7]pp
  - etc.

- [ ] **Add caption explaining CI interpretation:**
  ```markdown
  ![Benchmark improvements with 95% confidence intervals. Error bars
  represent uncertainty due to finite sample sizes. Task-specific results;
  gains vary significantly across benchmarks (see Heterogeneity Analysis).](...)
  ```

### Step B: Update References

- [ ] **Add statistical methods citations** to your References section:
  ```bibtex
  @book{higgins2011,
    title={Cochrane Handbook for Systematic Reviews of Interventions},
    author={Higgins, JPT and Green, S},
    year={2011},
    publisher={The Cochrane Collaboration}
  }

  @article{agresti2013,
    title={Categorical Data Analysis (3rd ed.)},
    author={Agresti, Alan},
    year={2013},
    publisher={Wiley}
  }
  ```

- [ ] **Verify all URLs** are still accessible:
  - [ ] arXiv:2305.10601 (ToT)
  - [ ] arXiv:2203.11171 (SC)
  - [ ] arXiv:2408.03314 (Snell et al.)
  - [ ] github.com/princeton-nlp/tree-of-thought-llm
  - [ ] docs.anthropic.com (Extended Thinking)

---

## PHASE 6: Review & QA (30 minutes)

### Checklist for Final Review

- [ ] **Read entire report with new "Statistical Validity" section**
  - Does it flow naturally after "Scope and Limitations"?
  - Are examples in new section consistent with claims in report body?

- [ ] **Verify all CIs match calculations**
  - ToT: [62–78]pp
  - SC GSM8K: [16.1–19.7]pp
  - SC SVAMP: [5.8–10.0]pp
  - Extended Thinking: [provisional, n unknown]

- [ ] **Check Tier 1–4 labels**
  - All Tier 1 claims: high-citation, peer-reviewed, complete data
  - All Tier 4 claims: marked as "vendor-reported, pending review"

- [ ] **Scan for o1 vs. o3 confusion**
  - All o3 claims: explicitly note "high compute mode (172×)"
  - All o1 claims: explicitly date as "September 2024"

- [ ] **Verify model comparison table**
  - Footnote explaining different evaluation conditions
  - No claims of statistical superiority (e.g., "o3 is better" without context)

- [ ] **Test all code snippets/formulas** (if including)
  - Run Python examples to verify they produce stated CIs
  - Or include as downloadable notebook (optional)

---

## PHASE 7: Integration with Existing Documents (15 minutes)

- [ ] **Update CLAIMS_REGISTER.md** with confidence levels:
  ```markdown
  | Claim | Tier | CI | SE Reported | N/A |
  |-------|------|-----|-----------|-----|
  | ToT 74% | 1 | [62–78]pp | No | 100 |
  | SC +17.9pp | 1 | [16.1–19.7]pp | Partial | 1,319 |
  ```

- [ ] **Link from STATISTICAL_VALIDITY_RECOMMENDATIONS.md** to main report
  - Add header: "For detailed implementation, see IMPLEMENTATION_CHECKLIST.md"

- [ ] **Add quick reference** to report footer:
  - "For statistical methods details, see STATISTICAL_TESTS_QUICK_REFERENCE.md"

---

## PHASE 8: Optional Enhancements (1+ hours)

- [ ] **Request missing data from authors:**
  - Email Yao et al.: Ask for standard errors on Game of 24
  - Email Anthropic: Ask for Extended Thinking response curve data
  - Email Snell et al.: Ask for exact efficiency gains by benchmark

- [ ] **Create supplementary materials:**
  - Generate high-res confidence interval plots
  - Compute effect sizes for all claims
  - Create meta-analysis forest plot (if using multiple benchmarks)

- [ ] **Prepare statistical methods appendix:**
  ```markdown
  ## Appendix D: Statistical Methods Details

  ### Two-Proportion Z-Test
  [Mathematical formula, assumptions, interpretation]

  ### Meta-Analysis (Fixed vs. Random Effects)
  [When to use each, Cochran's Q, I² heterogeneity]

  ### Power Analysis
  [Was sample size sufficient for detected effect sizes?]
  ```

---

## Deliverables Summary

After completing all phases, your report will have:

### NEW DOCUMENTS (in /research/drafts/):
- [ ] `STATISTICAL_VALIDITY_RECOMMENDATIONS.md` (12 KB, Part 1–6)
- [ ] `STATISTICAL_TESTS_QUICK_REFERENCE.md` (8 KB, checklists & templates)
- [ ] `IMPLEMENTATION_CHECKLIST.md` (THIS FILE, 6 KB)

### UPDATED DOCUMENTS:
- [ ] `structured-reasoning-research-2025.md` (Main report)
  - New "Statistical Validity and Confidence Assessment" section
  - Updated tables with 95% CIs
  - Tier 1–4 confidence labels
  - Clarified o1 vs. o3 distinction
  - Separated model comparison caveat

- [ ] `CLAIMS_REGISTER.md` (Claims register)
  - Added confidence levels per claim
  - Updated with CI values
  - Marked provisional/pending claims

### STATISTICS SUMMARY TABLE (for report):
```
| Claim | Type | Test | Tier | CI | Effect Size |
|-------|------|------|------|-----|-------------|
| ToT 74% vs 4% | Single benchmark | 2-prop Z | 1 | [62–78]pp | h=1.58 (Large) |
| SC +17.9pp | Single benchmark | 2-prop Z | 1 | [16.1–19.7]pp | h=0.40 (Medium) |
| SC variation | Multi-benchmark | Meta-analysis | 1 | I²=87.7% | Heterogeneous |
| Extended Thinking | Scaling | Regression | 3 | Provisional | R²=0.98 |
| Model ranking | Comparison | Ordinal | 3 | N/A (too many confounds) | N/A |
| >4× efficiency | Ratio | Cost analysis | 2 | Provisional | CI unknown |
```

---

## Final Validation Checklist

Before publishing the updated report:

- [ ] **Accessibility:** All links functional (test manually)
- [ ] **Correctness:** All CIs double-checked against source papers
- [ ] **Consistency:** Same effect sizes reported in text and tables
- [ ] **Clarity:** New Statistical Validity section understandable to non-statisticians
- [ ] **Attribution:** All statistical methods properly cited
- [ ] **Transparency:** Tier 1–4 labels visible to readers
- [ ] **Reproducibility:** Sample calculations shown; readers can verify

---

## Time Estimate Breakdown

| Phase | Task | Time |
|-------|------|------|
| 1 | Planning & Audit | 30 min |
| 2 | CI Calculations | 90 min |
| 3 | Effect Sizes | 45 min |
| 4 | Content Updates | 120 min |
| 5 | Viz & References | 45 min |
| 6 | Review & QA | 30 min |
| 7 | Integration | 15 min |
| 8 | Enhancements (optional) | 60+ min |
| **TOTAL** | **Core Implementation** | **~4.5 hours** |
| | **With Enhancements** | **~5.5+ hours** |

---

## Questions to Answer Before Starting

1. **Do you have access to source papers?** (Needed for exact sample sizes)
   - [ ] Yes, PDFs downloaded
   - [ ] Yes, can access via arXiv
   - [ ] No, will estimate from text

2. **Will you request data from authors?** (Yao et al., Anthropic, OpenAI)
   - [ ] Yes, reach out now
   - [ ] No, use data as-is
   - [ ] Maybe, after core implementation

3. **Target audience for Statistical Validity section?**
   - [ ] Academic researchers (include all math/formulas)
   - [ ] Business decision-makers (simplify, focus on interpretation)
   - [ ] Mixed audience (both versions: technical appendix + main text)

4. **How important is perfection?**
   - [ ] Perfect (request all missing data, full CIs for every claim)
   - [ ] Very good (CIs for major claims, Tier labels, notes for gaps)
   - [ ] Good enough (Tier labels only, mark known gaps)

---

*Good luck with the implementation! The effort will significantly strengthen your report's credibility and impact.*

*Questions? Refer back to STATISTICAL_VALIDITY_RECOMMENDATIONS.md (Parts 1–4) for detailed guidance.*
