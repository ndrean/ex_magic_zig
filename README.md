# ExMagicZig

[![Zig support](https://img.shields.io/badge/Zig-0.15.1-color?logo=zig&color=%23f3ab20)](http://github.com/ndrean/z-html)
![Static Badge](https://img.shields.io/badge/zigler-0.15.1.dev)


Minimal Elixir bindings to `libmagic` powered by the wonderful [Zigler](https://hexdocs.pm/zigler/readme.html) library with Zig v0.15.1.

`libmagic` is a library that identifies file types and formats by analyzing file content and structure rather than relying on file extensions.

It's the engine behind the Unix file command and examines the actual bytes, headers, and internal structure of files to determine what type of data they contain (MIME types, file formats, encoding, etc.).

[libmagic]((https://man7.org/linux/man-pages/man3/libmagic.3.html#LIBRARY)): copyright (c) Ian F. Darwin 1986-1995.
License: BSD-2-Clause (see LICENSE-libmagic).

## Requirements

> [!WARNING]
> Works on linux and OSX.
> Requires `Zig`  **0.15.1**

`libmagic` must be installed:

- macOS: `brew install libmagic`
- Ubuntu/Debian: `apt install libmagic-dev`
- Fedora: `dnf install file-devel`
  
## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_magic_zig` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_magic_zig, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_magic_zig>.

## Tests

```sh
mix test --trace
```

## Usage

```elixir
{:ok, magic} = ExMagicZig.up()

{:ok, mime} = ExMagicZig.from_path(magic, "my_img.png")
# {:ok, "image/png"}

{:ok, binary} = File.read("my_img.jpg")
{:ok, mime} = ExMagicZig.from_binary(magic, binary)
#{:ok, "image/jpeg"}
```
