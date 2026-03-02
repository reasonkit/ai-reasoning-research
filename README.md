# The Science of Structured Reasoning

**A Comprehensive Review of LLM Reasoning Research (2022-2025)**

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![Status: v1.0](https://img.shields.io/badge/Status-v1.0-blue.svg)](https://github.com/reasonkit/ai-reasoning-research)

## Overview

This repository contains the research report "The Science of Structured Reasoning" — a comprehensive review of advances in LLM reasoning from Chain-of-Thought (2022) through Extended Thinking and DeepSeek R1 (2025).

## Repository Structure

```
├── report/
│   └── structured-reasoning-research-2025.md    # Main research report
├── supplementary/
│   ├── real-world-case-studies.md               # Production deployment examples
│   ├── CLAIMS_REGISTER.md                       # 22 verified claims with sources
│   ├── STATISTICAL_VALIDITY_RECOMMENDATIONS.md  # Statistical rigor guidance
│   ├── STATISTICAL_TESTS_QUICK_REFERENCE.md     # Quick reference for tests
│   └── IMPLEMENTATION_CHECKLIST.md              # Implementation action items
├── templates/                                    # LaTeX templates for PDF generation
├── filters/                                      # Pandoc Lua filters
├── generated-visuals/                            # SVG figures
└── Makefile                                      # Build system
```

## Building the Report

### Requirements

- pandoc 3.x
- pandoc-crossref
- LuaLaTeX (texlive-full or equivalent)
- rsvg-convert (librsvg2-bin)

### Build Commands

```bash
# Build both PDF and HTML
make all

# Build PDF only
make pdf

# Build HTML only
make html

# Clean build artifacts
make clean
```

## Key Findings

| Method            | Improvement      | Benchmark  |
| ----------------- | ---------------- | ---------- |
| Tree-of-Thoughts  | 4% → 74% (+70pp) | Game of 24 |
| Self-Consistency  | +17.9pp          | GSM8K      |
| Extended Thinking | +21.3pp          | SWE-bench  |
| o3 (high compute) | 87.5%            | ARC-AGI    |

## Report Quality

- **22 claims verified** with 3+ independent sources (triangulation)
- **Statistical significance section** with confidence intervals and effect sizes
- **Methods taxonomy matrix** comparing 7 reasoning approaches
- **Use-case recommendation table** for production deployment

## Citation

```bibtex
@techreport{reasonkit2026structured,
  title={The Science of Structured Reasoning: A Comprehensive Review of LLM Reasoning Research (2022-2025)},
  author={{ReasonKit}},
  year={2026},
  institution={ReasonKit},
  url={https://reasonkit.sh/research/}
}
```

## License

This work is licensed under [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/).

---

_Maintained by [ReasonKit](https://reasonkit.sh) — Turn Prompts into Protocols_
