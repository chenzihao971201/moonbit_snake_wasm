///|
let grid_size : Int = 18

///|
let max_cells : Int = grid_size * grid_size

///|
priv struct GameState {
  mut snake_length : Int
  mut food_x : Int
  mut food_y : Int
  mut direction : Int
  mut pending_direction : Int
  mut score : Int
  mut game_over : Bool
  mut seed_state : Int
}

///|
let snake_x : Array[Int] = Array::make(max_cells, 0)

///|
let snake_y : Array[Int] = Array::make(max_cells, 0)

///|
let state : GameState = {
  snake_length: 4,
  food_x: 12,
  food_y: 9,
  direction: 1,
  pending_direction: 1,
  score: 0,
  game_over: false,
  seed_state: 1,
}

///|
fn abs_seed(seed : Int) -> Int {
  if seed < 0 {
    0 - seed
  } else {
    seed
  }
}

///|
fn next_rand(limit : Int) -> Int {
  state.seed_state = (state.seed_state * 73 + 41) % 9973
  state.seed_state % limit
}

///|
fn same_cell(a_x : Int, a_y : Int, b_x : Int, b_y : Int) -> Bool {
  a_x == b_x && a_y == b_y
}

///|
fn contains_snake_cell(x : Int, y : Int) -> Bool {
  for i in 0..<state.snake_length {
    if same_cell(snake_x[i], snake_y[i], x, y) {
      return true
    }
  }
  false
}

///|
fn place_food() -> Unit {
  if state.snake_length >= max_cells {
    state.game_over = true
    return
  }

  let mut candidate = next_rand(max_cells)
  let mut attempts = 0
  while attempts < max_cells {
    let x = candidate % grid_size
    let y = candidate / grid_size
    if !contains_snake_cell(x, y) {
      state.food_x = x
      state.food_y = y
      return
    }
    candidate = (candidate + 1) % max_cells
    attempts = attempts + 1
  }
}

///|
fn is_reverse(next : Int) -> Bool {
  (state.direction == 0 && next == 2) ||
  (state.direction == 2 && next == 0) ||
  (state.direction == 1 && next == 3) ||
  (state.direction == 3 && next == 1)
}

///|
pub fn reset(seed : Int) -> Unit {
  state.seed_state = abs_seed(seed) % 9973 + 1
  state.snake_length = 4
  state.direction = 1
  state.pending_direction = 1
  state.score = 0
  state.game_over = false

  let start_x = grid_size / 2
  let start_y = grid_size / 2
  for i in 0..<state.snake_length {
    snake_x[i] = start_x - i
    snake_y[i] = start_y
  }
  place_food()
}

///|
pub fn set_direction(next : Int) -> Unit {
  if next >= 0 && next <= 3 && !is_reverse(next) {
    state.pending_direction = next
  }
}

///|
pub fn tick() -> Int {
  if state.game_over {
    return 0
  }

  state.direction = state.pending_direction
  let mut next_x = snake_x[0]
  let mut next_y = snake_y[0]
  if state.direction == 0 {
    next_y = next_y - 1
  } else if state.direction == 1 {
    next_x = next_x + 1
  } else if state.direction == 2 {
    next_y = next_y + 1
  } else {
    next_x = next_x - 1
  }

  if next_x < 0 || next_x >= grid_size || next_y < 0 || next_y >= grid_size {
    state.game_over = true
    return 0
  }

  let ate_food = same_cell(next_x, next_y, state.food_x, state.food_y)
  let collision_limit = if ate_food {
    state.snake_length
  } else {
    state.snake_length - 1
  }
  for i in 0..<collision_limit {
    if same_cell(snake_x[i], snake_y[i], next_x, next_y) {
      state.game_over = true
      return 0
    }
  }

  let mut i = state.snake_length
  if !ate_food {
    i = state.snake_length - 1
  }
  while i > 0 {
    snake_x[i] = snake_x[i - 1]
    snake_y[i] = snake_y[i - 1]
    i = i - 1
  }
  snake_x[0] = next_x
  snake_y[0] = next_y

  if ate_food {
    state.snake_length = state.snake_length + 1
    state.score = state.score + 10
    place_food()
  }

  1
}

///|
pub fn get_grid_size() -> Int {
  grid_size
}

///|
pub fn get_snake_length() -> Int {
  state.snake_length
}

///|
pub fn get_snake_x(index : Int) -> Int {
  snake_x[index]
}

///|
pub fn get_snake_y(index : Int) -> Int {
  snake_y[index]
}

///|
pub fn get_food_x() -> Int {
  state.food_x
}

///|
pub fn get_food_y() -> Int {
  state.food_y
}

///|
pub fn get_score() -> Int {
  state.score
}

///|
pub fn is_game_over() -> Bool {
  state.game_over
}
