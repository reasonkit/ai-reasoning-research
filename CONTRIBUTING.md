# Contributing to The Science of Structured Reasoning

Thank you for your interest in contributing to this research! This document outlines how you can help improve this comprehensive review of LLM reasoning research.

## Ways to Contribute

### 🐛 Report Errors
- Typos, factual errors, or broken links
- Open an Issue with the label `correction`

### 📝 Suggest Updates
- New research papers (2025+)
- Updated benchmarks or statistics
- Open an Issue with the label `enhancement`

### 🔬 Add Case Studies
- Real-world production deployments
- Industry use cases
- Open a Discussion or PR

### 📊 Verify Claims
- All claims must be verified with 3+ independent sources
- See [CLAIMS_REGISTER.md](supplementary/CLAIMS_REGISTER.md) for details

## Citation Format

When citing this research, use APA 7th Edition:

```bibtex
@techreport{reasonkit2026structured,
  title={The Science of Structured Reasoning: A Comprehensive Review of LLM Reasoning Research (2022-2025)},
  author={{ReasonKit}},
  year={2026},
  institution={ReasonKit},
  url={https://github.com/reasonkit/ai-reasoning-research}
}
```

## Building the Report

```bash
# Install dependencies (macOS)
brew install pandoc pandoc-crossref librsvg

# Build PDF
make pdf

# Build HTML
make html

# Build both
make all
```

## License

This work is licensed under [CC BY 4.0](LICENSE). By contributing, you agree to your contributions being licensed under this license.

## Code of Conduct

Be respectful, constructive, and focused on the science. We welcome diverse perspectives from all backgrounds.

---

**Questions?** Open a Discussion or email hello@reasonkit.sh
