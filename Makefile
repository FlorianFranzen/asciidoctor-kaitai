# Build the example document and export its Kaitai Struct definitions.
# Requires asciidoctor, kaitai-struct-compiler (ksc) and graphviz (dot).

ASCIIDOCTOR ?= asciidoctor
EXT := lib/asciidoctor-kaitai.rb

EXAMPLE := examples/example.adoc
EXPORTS := container record payload

.PHONY: all html export test clean

all: html export

html: examples/example.html

examples/example.html: $(EXAMPLE) examples/scale.ksy $(EXT)
	$(ASCIIDOCTOR) -r ./$(EXT) --failure-level=WARN -o $@ $<

# The `kaitai` backend writes the standalone definition whose id matches the
# output file name (without extension).
export: $(patsubst %,examples/exports/%.ksy,$(EXPORTS))

examples/exports/%.ksy: $(EXAMPLE) examples/scale.ksy $(EXT)
	@mkdir -p $(dir $@)
	$(ASCIIDOCTOR) -r ./$(EXT) -b kaitai --failure-level=WARN -o $@ $<

# Check that exported definitions compile on their own.
test: export
	cp examples/scale.ksy examples/exports/
	ksc --target graphviz --outdir examples/exports/out $(patsubst %,examples/exports/%.ksy,$(EXPORTS))

clean:
	rm -rf examples/example.html examples/exports
