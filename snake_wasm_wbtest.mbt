///|
test "reset places the snake at the board center" {
  reset(7)
  inspect(get_grid_size(), content="18")
  inspect(get_snake_length(), content="4")
  inspect(get_snake_x(0), content="9")
  inspect(get_snake_y(0), content="9")
  inspect(get_score(), content="0")
  inspect(is_game_over(), content="false")
}

///|
test "reverse direction input is ignored" {
  reset(7)
  set_direction(3)
  ignore(tick())
  inspect(get_snake_x(0), content="10")
  inspect(get_snake_y(0), content="9")
  inspect(is_game_over(), content="false")
}
