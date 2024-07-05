.SECONDEXPANSION:
# We do not want any implicit deletion of outputs
.SECONDARY:

# We collect all the spec names from the folders in the
# specs directory
SPECS = $(patsubst %.bs, %, $(shell ls specs))

# This is our target folder
OUT = dist

# default target to build everything
all: $(SPECS)

# Build an individual spec as both html and pdf
# i.e make live2vod
.PHONY: $(SPECS)
$(SPECS): %: $(OUT)/%/index.html $(OUT)/%.pdf

# Build an individual spec as html
# i.e make live2vod.html
.PHONY: $(SPECS:%=%.html)
$(SPECS:%=%.html): %: $(OUT)/$$(subst .html,,%)/index.html

# Watch an individual spec as html
# i.e make live2vod-watch
.PHONY: $(SPECS:%=%-watch)
$(SPECS:%=%-watch): %: $(OUT)/%

# Build an individual spec as pdf
# i.e make live2vod.pdf
.PHONY: $(SPECS:%=%.pdf)
$(SPECS:%=%.pdf): %: $(OUT)/%

# This is a helper that we use in the prerequisits with SECONDEXPANSION
# to find _all_ the source dependencies for a spec.
# This assumes that $* evaluates to the name of the spec
spec-sources = $(shell find specs/$*/ -type f -iname \*.md)

# This is a helper that we use in the prerequisits with SECONDEXPANSION
# to extract the name of the spec folder
spec-name = $(shell echo "$*" | cut -d/ -f1 )

# This is a helper that we use in the prerequisits with SECONDEXPANSION
# to find the spec file
spec-file = $(shell find specs/$*/ -type f -iname \*.bs | head -n 1)

# Run bikeshed to generate html outout
# We need to use SECONDEXPANSION because we are not only depending
# on the .bs file, but also on all the .inc.md files that belong to this
# spec. To do this, we need a second expansion so we can use $* for the
# wildcard (and everything needs to be double escaped)
#
# This ensure that when we build a html page, we depend on:
#
#  - the Images are available in the output folder (order matters)
#  - the .bs file that we pass to bikeshed
#  - all .inc.md files that belong to this spec
$(OUT)/%/index.html: $${spec-file} $${spec-sources} $(OUT)/%/Images
	@echo "Compile $< -> $(OUT)/$*/index.html. Deps $^ to $@"
	@[ -d $(OUT)/$* ] || mkdir -p $(OUT)/$*
	bikeshed --allow-nonlocal-files spec $< $@

.PHONY: $(OUT)/%-watch
$(OUT)/%-watch: $${spec-file} $${spec-sources} $(OUT)/%/Images
	@echo "Watch $< -> $(OUT)/$*/index.html. Deps $^"
	@[ -d $(OUT)/$* ] || mkdir -p $(OUT)/$*
	bikeshed --allow-nonlocal-files watch $< $(OUT)/$*/index.html

# Run wkhtmltopdf to create a PDF from the already generated html page
$(OUT)/%.pdf: $(OUT)/$${spec-name}/index.html
	@echo "Compile $< -> $@"
	@chromium  \
		--no-sandbox \
		--headless=new \
		--disable-gpu \
		--print-to-pdf=$@ \
		--no-margine \
		--run-all-compositor-stages-before-draw \
		--no-pdf-header-footer \
		--virtual-time-budget=20000 \
		$< 2>&1 | grep -v "bus.cc"

# This one could maybe be done in a different way, but for now
# we are linking the Images folder to the outout folder
$(OUT)/%/Images:
	@[ -d $(OUT)/$* ] || mkdir -p $(OUT)/$*
	@if [ -d "specs/$*/Images" ]; then \
		echo "Copy specs/$*/Images -> $(OUT)/$*/Images"; \
		cp -r specs/$*/Images $(OUT)/$*/Images; \
	fi

# Helper to clean up
.PHONY: clean
clean:
	@echo "Removing $(OUT)"
	@rm -rf $(OUT)

.PHONY: help
help:
	@echo "Bikeshed build script"
	@echo "The following make targets are available"
	@echo
	@echo "help\t\t\tThis help message"
	@echo "all\t\t\tBuild all specs in this folder as both html and pdf. This is the default target"
	@for s in $(SPECS) ; do \
  	echo "$${s}\t\tBuild $$s in all variants"; \
		echo "$${s}.html\t\tBuild $$s as html"; \
		echo "$${s}.pdf\t\tBuild $$s as pdf"; \
		echo "$${s}-watch\t\tBuild $$s as html and keep watching for changes"; \
	done
