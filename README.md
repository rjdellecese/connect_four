# Connect Four [![CircleCI](https://img.shields.io/circleci/build/github/rjdellecese/connect_four)](https://circleci.com/gh/rjdellecese/connect_four) [![Coverage Status](https://coveralls.io/repos/github/rjdellecese/connect_four/badge.svg?branch=master)](https://coveralls.io/github/rjdellecese/connect_four?branch=master) [![Hex.pm](https://img.shields.io/hexpm/v/connect_four)](https://hex.pm/packages/connect_four) [![Hex.pm](https://img.shields.io/hexpm/l/connect_four)](https://github.com/rjdellecese/connect_four/blob/master/LICENSE)

A fast, tiny Connect Four game engine.

Also provides a GenServer implementation, which could easily form the foundation
of a Connect Four platform.

The `ConnectFour.Game` module provides the game logic, and the
`ConnectFour.GameServer` module contains the GenServer implementation.

Read the documentation [here](https://hexdocs.pm/connect_four).

## Implementation

Connect Four games are stored as bitboards, with a tiny bit of metadata. This
allows for move validation to be as fast as a few bitwise operations.

For a walkthrough of how it works, see
[this excellent guide](https://tromp.github.io/c4/Connect4.java). You can also
view the original Java implementation that this is based on
[here](https://tromp.github.io/c4/Connect4.java).

## Installation

Add to the dependencies in your `mix.exs` file.

```elixir
def deps do
  [
    {:connect_four, "~> 1.0.0"}
  ]
end
```
