# MoonBit Snake WASM

一个用 MoonBit 编写游戏规则、编译成 WebAssembly，再由浏览器 Canvas 渲染的贪吃蛇 demo。

## Prerequisites

- MoonBit toolchain
- Python 3, or any static file server

Make sure `moon` is available in your `PATH`.

## 运行

先编译 wasm：

```sh
moon build --target wasm
```

再从项目根目录启动静态服务器：

```sh
python3 -m http.server 8017
```

打开：

```text
http://localhost:8017/web/
```

## 测试

```sh
moon test
```

## 结构

- `snake_wasm.mbt`: MoonBit 游戏状态和规则，导出 wasm API
- `moon.pkg`: wasm link 配置和导出函数列表
- `web/index.html`: 页面结构
- `web/app.js`: 加载 wasm、处理输入、驱动 Canvas 渲染
- `web/styles.css`: 页面样式
