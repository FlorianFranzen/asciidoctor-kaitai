# asciidoctor-kaitai

[![CI](https://github.com/FlorianFranzen/asciidoctor-kaitai/actions/workflows/ci.yml/badge.svg)](https://github.com/FlorianFranzen/asciidoctor-kaitai/actions/workflows/ci.yml)

An [Asciidoctor](https://asciidoctor.org) extension that lets you write
[Kaitai Struct](https://kaitai.io) binary format definitions directly inside an
AsciiDoc document. Each definition is compiled with the Kaitai Struct compiler,
rendered with Graphviz and embedded as an inline SVG diagram. The same
definitions can be exported again as standalone `.ksy` files, so the document
stays the single source of truth for a machine-readable format description.

The extension was written for the
[Polkadot Protocol Specification](https://github.com/w3f/polkadot-spec), where
it documented the SCALE codec, runtime metadata and block formats until the
spec moved to a different toolchain in 2023. This repository preserves its
history and makes it usable on its own.

## Requirements

- Ruby 2.7 or later with the `asciidoctor` gem
- `ksc` (the Kaitai Struct compiler) on `PATH`
- `dot` (Graphviz) on `PATH`

With Nix, `nix develop` provides all of the above.

## Usage

Load the extension when invoking Asciidoctor:

```sh
asciidoctor -r ./lib/asciidoctor-kaitai.rb document.adoc
```

A `kaitai` block holds the `seq`, `types`, `enums` and `instances` sections of
a `.ksy` file as YAML. The block id becomes the Kaitai `meta.id`, the block
title becomes the caption.

```asciidoc
.A simple record
[kaitai#record]
++++
seq:
  - id: hello
    type: u4
  - id: kind
    type: u1
    enum: kind
enums:
  kind:
    0: none
    1: some
++++
```

### Imports

External `.ksy` files placed next to the document can be imported with the
`kaitai-imports` attribute, either on the document or on a single block. Their
types are then available with the usual `file::type` syntax. The example
document imports `scale.ksy` this way.

```asciidoc
:kaitai-imports: scale

[kaitai#payload]
++++
seq:
  - id: length
    type: scale::compact_int
++++
```

### Dependencies between blocks

Blocks can reference other blocks in the same document through
`kaitai-dependencies`. Order does not matter: a block is rendered as soon as
all of its dependencies have been parsed. In the rendered diagram, nodes that
belong to a dependency are drawn as a single node linking to that block's
anchor instead of repeating its contents.

```asciidoc
[kaitai#container,kaitai-dependencies="record,payload"]
++++
seq:
  - id: records
    type: record
    repeat: eos
  - id: payload
    type: payload
++++
```

### Modes

The `kaitai-mode` attribute controls how dependencies are passed to the
compiler:

| Mode | Behaviour |
| --- | --- |
| `individual` (default) | Each dependency is compiled as a separate `.ksy` import. |
| `hierachical` | All dependencies are merged into one `dependencies.ksy` with nested types, preserving the dependency tree. |
| `standalone` | Dependencies are inlined as subtypes of the block. Used by the export backend. |

### Exporting definitions

The extension registers a `kaitai` backend. Converting a document with it
writes the standalone definition of one block, selected by the output file
name:

```sh
asciidoctor -r ./lib/asciidoctor-kaitai.rb -b kaitai -o container.ksy document.adoc
```

This produces `container.ksy` with all dependencies inlined as subtypes, ready
to be compiled to any Kaitai target language.

### Styling

Asciidoctor's default stylesheet sets a fixed size on images. To let the
inline SVGs scale, add:

```css
.imageblock .content svg {
  width: auto;
  height: auto;
}
```

## Example

`examples/example.adoc` demonstrates imports, dependencies and the export
backend. Build it with:

```sh
make all test
```

This renders `examples/example.html`, exports the three definitions to
`examples/exports/` and compiles the exports to verify they are self-contained.
The same steps run under `nix build` and `nix flake check`.

## License

GPL-3.0-or-later, matching the repository the extension was extracted from.
