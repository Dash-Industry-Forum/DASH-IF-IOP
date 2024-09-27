.SECONDEXPANSION:
# We do not want any implicit deletion of outputs
.SECONDARY:

# We collect all the spec names from the folders in the
# specs directory
SPECS = $(patsubst %.bs, %, $(shell if [ -d "specs" ]; then ls specs; fi))

# This is our target folder
OUT = dist

# DIAGRAM_IMAGES = $(subst $(OUT),$(OUT),$(patsubst %.wsd, %.png, $(shell find specs/ -type f -iname '*.wsd')))
DIAGRAMS_SPEC = $(patsubst %.wsd, %, $(shell if [ -d "Diagrams" ]; then ls Diagrams/*.wsd; fi))

DIAGRAMS_SPEC_SOURCES := $(wildcard Diagrams/*.wsd)
DIAGRAMS_SPEC_IMAGES := $(addprefix $(OUT)/, $(DIAGRAMS_SPEC_SOURCES:.wsd=.png))

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

# This helper is used to find all the plantuml diagrams per spec
# and transforms the results to the target files that should match that
spec-diagrams = $(patsubst specs/%,$(OUT)/%,$(patsubst %.wsd,%.png,$(shell find specs/$*/ -type f -iname \*.wsd)))

# This helper finds the spec files for a single spec and then transforms them to
# the respective output path
single-spec-diagrams = $(addprefix ${OUT}/,$(patsubst %.wsd, %.png, $(shell if [ -d "Diagrams" ]; then ls Diagrams/*.wsd; fi)))

# This is a helper that we use in the prerequisits with SECONDEXPANSION
# to extract the name of the spec folder
spec-name = $(shell echo "$*" | cut -d/ -f1 )

# This is a helper that we use in the prerequisits with SECONDEXPANSION
# to find the spec file
spec-file = $(shell find specs/$*/ -type f -iname \*.bs | head -n 1)

# This is a helper that we use in the prerequisits with SECONDEXPANSION
# to find all diagram files
#spec-diagram-source = $(subst $(OUT),specs,$*).wsd

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
$(OUT)/%/index.html: $${spec-file} $${spec-sources} $(OUT)/%/Images $${spec-diagrams}
	@echo "Compile $< -> $(OUT)/$*/index.html"
	@[ -d $(OUT)/$* ] || mkdir -p $(OUT)/$*
	@bikeshed --no-update --allow-nonlocal-files spec $< $@

.PHONY: $(OUT)/%-watch
$(OUT)/%-watch: $${spec-file} $${spec-sources} $(OUT)/%/Images
	@echo "Watch $< -> $(OUT)/$*/index.html. Deps $^"
	@[ -d $(OUT)/$* ] || mkdir -p $(OUT)/$*
	@bikeshed --no-update --allow-nonlocal-files watch $< $(OUT)/$*/index.html

# Run chromium to create a PDF from the already generated html page
$(OUT)/%.pdf: $(OUT)/$${spec-name}/index.html
	@echo "Compile $< -> $@"
	@chromium  \
		--no-sandbox \
		--headless=new \
		--disable-gpu \
		--disable-sync \
		--print-to-pdf=$@ \
		--no-margine \
		--run-all-compositor-stages-before-draw \
		--no-pdf-header-footer \
		--virtual-time-budget=20000 \
		$< 2>&1 | grep -v "bus.cc"

# Target that compiles the plantuml diagrams on a per spec bases
$(OUT)/%.png: specs/%.wsd
	@echo "Compile $< -> $@"
	@[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	@plantuml $< -o $(shell pwd)/$(shell dirname $@);

# This one could maybe be done in a different way, but for now
# we are linking the Images folder to the outout folder
$(OUT)/%/Images:
	@[ -d $(OUT)/$* ] || mkdir -p $(OUT)/$*
	@if [ -d "specs/$*/Images" ]; then \
		echo "Copy specs/$*/Images -> $(OUT)/$*/Images"; \
		cp -r specs/$*/Images $(OUT)/$*/Images; \
	fi

SRC =
NAME=

.PHONY: spec
spec: spec.html spec.pdf

.PHONY: spec.html
spec.html: ${OUT}/index.html

.PHONY: spec.pdf
spec.pdf: ${OUT}/${NAME}.pdf

$(OUT)/index.html: ${SRC} ${OUT}/Images $${single-spec-diagrams}
	@echo "Compile $< -> $(OUT)/index.html"
	@[ -d $(OUT) ] || mkdir -p $(OUT)
	@bikeshed --no-update --allow-nonlocal-files spec $< $@

$(OUT)/Images: Images/
	@[ -d $(OUT) ] || mkdir -p $(OUT)
	@if [ -d "Images" ]; then \
		echo "Copy Images -> $(OUT)/Images"; \
		cp -r Images $(OUT)/Images; \
	fi

# Target to create the diagrams from plantUML files for a single
# spec that resides in the root folder.
$(OUT)/Diagrams/%.png: Diagrams/%.wsd
	@echo "Compile $< -> $@"
	@[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	@plantuml $< -o $(shell pwd)/$(shell dirname $@);

$(OUT)/${NAME}.pdf: $(OUT)/index.html
	@echo "Compile $< -> $@"
	@chromium  \
		--no-sandbox \
		--headless=new \
		--disable-gpu \
		--disable-sync \
		--print-to-pdf=$@ \
		--no-margine \
		--run-all-compositor-stages-before-draw \
		--no-pdf-header-footer \
		--virtual-time-budget=20000 \
		$< 2>&1 | grep -v "bus.cc"

.PHONY: spec-watch
spec-watch: ${SRC} $(OUT)/Images
	@[ -d $(OUT) ] || mkdir -p $(OUT)
	@bikeshed --no-update --allow-nonlocal-files watch $< $(OUT)/index.html

.PHONY: spec-serve
spec-serve: ${SRC} $(OUT)/Images
	@[ -d $(OUT) ] || mkdir -p $(OUT)
	@bikeshed --no-update --allow-nonlocal-files serve $< $(OUT)/index.html

# Helper to clean up
.PHONY: clean
clean:
	@echo "Removing $(OUT)"
	@rm -rf $(OUT)

.PHONY: help
help:
	@echo "Bikeshed build script"
	@echo ""
	@echo "This makefile is looking for a specs folder and provides"
	@echo "build tasks for each subfolder there."
	@echo ""
	@echo "In addition, you can also run this for a spec that is hosted"
	@echo "as a single source file in the repo. For this, make sure you"
	@echo "set the SRC and NAME variables correctly. Then use the spec"
	@echo "targets."
	@echo ""
	@echo "The following make targets are available"
	@echo
	@echo "help				This help message"
	@echo "all				Build all specs in this folder as both html and pdf. This is the default target"
	@for s in $(SPECS) ; do \
		echo "$${s}			Build $$s in all variants"; \
		echo "$${s}.html			Build $$s as html"; \
		echo "$${s}.pdf			Build $$s as pdf"; \
		echo "$${s}-watch			Build $$s as html and keep watching for changes"; \
	done
	@echo ""
	@echo "spec				Build a single spec from SRC. Make sure you set the source file with SRC and provide a NAME that will be used for the PDF, i.e. make spec SRC=myspec.bs NAME=myspec"
	@echo "spec.html			Build a single spec HTML from SRC. See above how to set SRC and NAME."
	@echo "spec.pdf			Build a single spec HTML from SRC. See above how to set SRC and NAME."
	@echo "spec-watch			Watch a single spec HTML from SRC. See above how to set SRC and NAME."
	@echo "spec-serve			Watch and serve a single spec HTML from SRC. See above how to set SRC and NAME."

