.SECONDEXPANSION:

# We collect all the spec names from their .bs files, i.e live2vod.bs is
# found and turned into live2vods
SPECS = $(patsubst %.bs, %, $(shell ls *.bs))

# This is our target folder
OUT = dist

# default target to build everything
all: html pdf

# Build all specs as html
.PHONY: html
html: $(foreach src, $(SPECS), $(OUT)/$(src).html)

# Build all specs as pdf
.PHONY: pdf
pdf: $(foreach src, $(SPECS), $(OUT)/$(src).pdf)

# Build an individual spec as both html and pdf
# i.e make live2vod
.PHONY: $(SPECS)
$(SPECS): %: $(OUT)/%.html $(OUT)/%.pdf

# Build an individual spec as html
# i.e make live2vod.html
.PHONY: $(SPECS:%=%.html)
$(SPECS:%=%.html): %: $(OUT)/%

# Build an individual spec as pdf
# i.e make live2vod.pdf
.PHONY: $(SPECS:%=%.pdf)
$(SPECS:%=%.pdf): %: $(OUT)/%

# This is a helper that we use in the prerequisits with SECONDEXPANSION
# to find _all_ the source dependencies for a spec.
# This assumes that $* evaluates to the name of the spec
spec-sources = $(shell find . -type f -iname \*-$*.inc.md)

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
$(OUT)/%.html: $(OUT)/Images %.bs $${spec-sources}
	@echo "Compile $*.bs -> $(OUT)/$*.html. Deps $^"
	@bikeshed spec $*.bs $(OUT)/$*.html

# Run wkhtmltopdf to create a PDF from the already generated html page
$(OUT)/%.pdf: $(OUT)/%.html
	@echo "Compile $(OUT)/$*.html -> $(OUT)/$*.pdf"
	@wkhtmltopdf --enable-local-file-access $(OUT)/$*.html $(OUT)/$*.pdf

# This one could maybe be done in a different way, but for now
# we are linking the Images folder to the outout folder
$(OUT)/Images:
	@[ -d $(OUT) ] || mkdir -p $(OUT)
	@echo "Linking Images -> $(OUT)/Images"
	@ln -sf ../Images $@

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
	@echo "html\t\t\tBuild all specs in this folder as html"
	@echo "pdf\t\t\tBuild all specs in this folder as pdf"
	@for s in $(SPECS) ; do \
  	echo "$${s}\t\tBuild $$s in all variants"; \
		echo "$${s}.html\t\tBuild $$s as html"; \
		echo "$${s}.pdf\t\tBuild $$s as pdf"; \
	done
