# Makefile for Research Report Compilation
# Supports dual-output: PDF (via LuaLaTeX) and HTML

REPORT := structured-reasoning-research-2025
VISUALS_DIR := generated-visuals
FILTER_DIR := filters

# Template
TEMPLATE := templates/reasonkit-lualatex-premium.tex

# Pandoc options
PANDOC_OPTS := --standalone --toc --filter pandoc-crossref
LUA_FILTER := --lua-filter=$(FILTER_DIR)/svg-pdf-swap.lua
PDF_OPTS := --template=$(TEMPLATE)

# Output files
PDF_OUTPUT := $(REPORT).pdf
HTML_OUTPUT := $(REPORT).html

.PHONY: all pdf html clean svgs help

all: pdf html

# Convert all SVGs to PDFs (required for LaTeX)
svgs:
	@echo "Converting SVGs to PDFs..."
	@for svg in $(VISUALS_DIR)/*.svg; do \
		pdf="$${svg%.svg}.pdf"; \
		if [ "$$svg" -nt "$$pdf" ] || [ ! -f "$$pdf" ]; then \
			echo "  Converting $$svg -> $$pdf"; \
			rsvg-convert "$$svg" -f pdf --dpi-x 72 --dpi-y 72 -o "$$pdf"; \
		fi \
	done
	@echo "SVG conversion complete."

# Build PDF via LuaLaTeX
pdf: svgs
	@echo "Building PDF..."
	pandoc $(REPORT).md $(PANDOC_OPTS) $(LUA_FILTER) $(PDF_OPTS) \
		--pdf-engine=lualatex \
		-o $(PDF_OUTPUT)
	@echo "PDF created: $(PDF_OUTPUT)"

# Build HTML
html:
	@echo "Building HTML..."
	pandoc $(REPORT).md $(PANDOC_OPTS) $(LUA_FILTER) \
		-o $(HTML_OUTPUT)
	@echo "HTML created: $(HTML_OUTPUT)"

# Clean generated files
clean:
	rm -f $(PDF_OUTPUT) $(HTML_OUTPUT)
	@echo "Cleaned build artifacts."

# Deep clean (also removes generated PDFs from visuals)
distclean: clean
	rm -f $(VISUALS_DIR)/*.pdf
	@echo "Cleaned all generated files including PDFs."

help:
	@echo "Research Report Build System"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build both PDF and HTML (default)"
	@echo "  pdf       - Build PDF only (requires LuaLaTeX)"
	@echo "  html      - Build HTML only"
	@echo "  svgs      - Convert SVGs to PDFs for LaTeX"
	@echo "  clean     - Remove generated PDF and HTML"
	@echo "  distclean - Remove all generated files"
	@echo "  help      - Show this message"
	@echo ""
	@echo "Requirements:"
	@echo "  - pandoc 3.x"
	@echo "  - pandoc-crossref"
	@echo "  - lualatex (texlive-full or similar)"
	@echo "  - rsvg-convert (librsvg2-bin)"
