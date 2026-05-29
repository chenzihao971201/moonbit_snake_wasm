const wasmPath = "../_build/wasm/debug/build/snake_wasm.wasm";

const canvas = document.querySelector("#board");
const ctx = canvas.getContext("2d");
const scoreEl = document.querySelector("#score");
const statusEl = document.querySelector("#status");
const playButton = document.querySelector("#play");
const playIcon = document.querySelector("#playIcon");
const restartButton = document.querySelector("#restart");
const speedInput = document.querySelector("#speed");
const pad = document.querySelector(".pad");

let api = null;
let gridSize = 18;
let running = false;
let timer = null;

function seed() {
  return Math.trunc(Date.now() % 100000);
}

async function loadWasm() {
  const response = await fetch(wasmPath);
  if (!response.ok) {
    throw new Error(`Unable to load wasm: ${response.status}`);
  }
  const bytes = await response.arrayBuffer();
  const { instance } = await WebAssembly.instantiate(bytes, {});
  api = instance.exports;
  gridSize = api.get_grid_size();
  api.reset(seed());
  render();
}

function setStatus(text) {
  statusEl.textContent = text;
}

function setRunning(next) {
  running = next;
  playIcon.textContent = running ? "Pause" : "Play";
  if (timer !== null) {
    clearInterval(timer);
    timer = null;
  }
  if (running) {
    timer = setInterval(step, Number(speedInput.value));
    setStatus("Running");
  } else if (!api?.is_game_over()) {
    setStatus("Paused");
  }
}

function restart() {
  api.reset(seed());
  setRunning(true);
  render();
}

function step() {
  api.tick();
  render();
  if (api.is_game_over()) {
    setRunning(false);
    setStatus("Game over");
  }
}

function directionFromKey(key) {
  switch (key) {
    case "ArrowUp":
    case "w":
    case "W":
      return 0;
    case "ArrowRight":
    case "d":
    case "D":
      return 1;
    case "ArrowDown":
    case "s":
    case "S":
      return 2;
    case "ArrowLeft":
    case "a":
    case "A":
      return 3;
    default:
      return -1;
  }
}

function setDirection(dir) {
  if (!api || dir < 0) return;
  api.set_direction(dir);
  if (!running && !api.is_game_over()) {
    setRunning(true);
  }
}

function drawBackground(cell) {
  ctx.fillStyle = "#0c0f10";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  ctx.strokeStyle = "rgba(255, 255, 255, 0.045)";
  ctx.lineWidth = 1;
  for (let i = 1; i < gridSize; i += 1) {
    const pos = Math.round(i * cell) + 0.5;
    ctx.beginPath();
    ctx.moveTo(pos, 0);
    ctx.lineTo(pos, canvas.height);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(0, pos);
    ctx.lineTo(canvas.width, pos);
    ctx.stroke();
  }
}

function drawRoundedRect(x, y, size, radius, color) {
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.roundRect(x, y, size, size, radius);
  ctx.fill();
}

function render() {
  if (!api) return;

  const scale = window.devicePixelRatio || 1;
  const rect = canvas.getBoundingClientRect();
  const size = Math.max(320, Math.floor(rect.width * scale));
  if (canvas.width !== size || canvas.height !== size) {
    canvas.width = size;
    canvas.height = size;
  }

  const cell = canvas.width / gridSize;
  drawBackground(cell);

  const inset = Math.max(3, cell * 0.12);
  const foodX = api.get_food_x() * cell + inset;
  const foodY = api.get_food_y() * cell + inset;
  drawRoundedRect(foodX, foodY, cell - inset * 2, cell * 0.32, "#ef6b5f");

  const len = api.get_snake_length();
  for (let i = len - 1; i >= 0; i -= 1) {
    const x = api.get_snake_x(i) * cell + inset;
    const y = api.get_snake_y(i) * cell + inset;
    const t = len <= 1 ? 1 : 1 - i / len;
    const color = i === 0 ? "#f3b64f" : `rgb(${Math.round(49 + 24 * t)}, ${Math.round(159 + 50 * t)}, ${Math.round(96 + 29 * t)})`;
    drawRoundedRect(x, y, cell - inset * 2, cell * 0.24, color);
  }

  scoreEl.textContent = String(api.get_score());
}

playButton.addEventListener("click", () => {
  if (!api) return;
  if (api.is_game_over()) {
    restart();
  } else {
    setRunning(!running);
  }
});

restartButton.addEventListener("click", () => {
  if (api) restart();
});

speedInput.addEventListener("input", () => {
  if (running) setRunning(true);
});

pad.addEventListener("click", (event) => {
  const button = event.target.closest("button[data-dir]");
  if (button) setDirection(Number(button.dataset.dir));
});

window.addEventListener("keydown", (event) => {
  const dir = directionFromKey(event.key);
  if (dir >= 0) {
    event.preventDefault();
    setDirection(dir);
  } else if (event.key === " " && api) {
    event.preventDefault();
    setRunning(!running);
  }
});

window.addEventListener("resize", render);

loadWasm().catch((error) => {
  setStatus("Load failed");
  console.error(error);
});
