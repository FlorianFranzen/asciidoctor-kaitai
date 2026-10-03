Gem::Specification.new do |s|
  s.name        = 'asciidoctor-kaitai'
  s.version     = '0.1.0'
  s.summary     = 'Embed Kaitai Struct definitions in AsciiDoc and render them as diagrams'
  s.description = <<~DESC
    An Asciidoctor extension that adds a `kaitai` block for inline Kaitai Struct
    (.ksy) definitions. Blocks can import external definitions and depend on
    each other out of order. Each block is compiled with the Kaitai Struct
    compiler, rendered with Graphviz and embedded as an inline SVG. A `kaitai`
    backend exports the merged definitions as standalone .ksy files.
  DESC
  s.authors     = ['Florian Franzen']
  s.email       = ['Florian.Franzen@gmail.com']
  s.homepage    = 'https://github.com/FlorianFranzen/asciidoctor-kaitai'
  s.license     = 'GPL-3.0-or-later'
  s.files       = Dir['lib/**/*.rb'] + %w[README.md LICENSE]
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.7'

  s.add_runtime_dependency 'asciidoctor', '~> 2.0'

  s.requirements << 'kaitai-struct-compiler (ksc) on PATH'
  s.requirements << 'graphviz (dot) on PATH'
end
