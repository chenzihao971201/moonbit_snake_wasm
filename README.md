# MoonBit Snake WASM

A browser Snake game demo with gameplay logic written in MoonBit, compiled to WebAssembly, and rendered with Canvas.

## Prerequisites

- MoonBit toolchain
- Python 3, or any static file server

Make sure `moon` is available in your `PATH`.

## Run

Build the WASM module:

```sh
moon build --target wasm
```

Start a static file server from the project root:

```sh
python3 -m http.server 8017
```

Open:

```text
http://localhost:8017/web/
```

## Test

```sh
moon test
```

## Project Structure

- `snake_wasm.mbt`: MoonBit game state, rules, and exported WASM API
- `moon.pkg`: WASM link configuration and exported function list
- `web/index.html`: Page markup
- `web/app.js`: WASM loading, input handling, and Canvas rendering
- `web/styles.css`: Page styles
