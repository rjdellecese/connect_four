defmodule ConnectFour.Game do
  @moduledoc """
  A Connect Four game.

  Players are distinguished by game piece color (yellow and red). Moves are
  represented by the columns in which they are made.

  To create a new game, create an empty `ConnectFour.Game.t()` struct
  (`%ConnectFour.Game{}`).

  Yellow moves first.
  """

  import Bitwise

  alias ConnectFour.Game

  defstruct(
    bitboards: %{yellow: 0, red: 0},
    column_heights: %{0 => 0, 1 => 7, 2 => 14, 3 => 21, 4 => 28, 5 => 35, 6 => 42},
    moves: [],
    plies: 0,
    result: nil
  )

  @typedoc """
  The representation of a Connect Four game. The struct contains five fields,
  three of which should be considered read-only, and two which should be
  considered private. None should ever be modified manually.

  The read-only fields are:

    - `moves`
    - `plies`
    - `result`

  And the private fields are:

    - `bitbords`
    - `column_heights`
  """
  @type t :: %Game{
          bitboards: %{required(:yellow) => bitboard(), required(:red) => bitboard()},
          column_heights: column_heights(),
          moves: moves(),
          plies: non_neg_integer(),
          result: result()
        }

  @typedoc """
  One of seven Connect Four game columns, zero-indexed.
  """
  @type column :: 0..6

  @typedoc """
  A list of Connect Four moves, describing a game. Yellow always moves first, so
  the first move in the list will always be yellow's.
  """
  @type moves :: [column()]

  @typedoc """
  A Connect Four player (yellow always moves first).
  """
  @type player :: :yellow | :red

  @typedoc """
  A ply is one move completed by one player. Plies are thus the total number of
  moves completed in the game so far.

  For example, if a game starts and yellow takes their turn (by "dropping" a
  game piece into a column) and then red does the same, that game has two plies.
  """
  @type plies :: non_neg_integer()

  @typedoc """
  A Connect Four game result. `nil` means that the game has not yet ended.
  `:draw`s occur when all columns are full and no player has connected four.
  """
  @type result :: :yellow_wins | :red_wins | :draw | nil

  @typep bitboard :: non_neg_integer()

  @typep column_height :: non_neg_integer()
  @typep column_heights :: %{
           required(0) => column_height(),
           required(1) => column_height(),
           required(2) => column_height(),
           required(3) => column_height(),
           required(4) => column_height(),
           required(5) => column_height(),
           required(6) => column_height()
         }

  @doc """
  Submit a move for whomever's turn it currently is by specifying a column (0
  through 6).

  ## Examples

      iex> alias ConnectFour.Game
      iex> {:ok, updated_game} = %Game{} |> Game.move(0)
      iex> updated_game.moves
      [0]

  Make multiple moves at once by passing a list of moves.

  ## Examples

      iex> alias ConnectFour.Game
      iex> {:ok, updated_game} = %Game{} |> Game.move([0, 1, 0])
      iex> updated_game.moves
      [0, 1, 0]

  """
  @spec move(Game.t(), column() | moves()) :: {:ok, Game.t()} | {:error, String.t()}
  def move(game = %Game{}, column) when is_integer(column) do
    cond do
      !is_nil(game.result) ->
        {:error, "Game is over"}

      legal_move?(column, game.column_heights) ->
        {:ok, make_move(game, column)}

      true ->
        {:error, "Illegal move"}
    end
  end

  def move(game = %Game{}, moves) when is_list(moves), do: make_many_moves(game, moves)

  @doc """
  Get a list of all the legal moves for a game. Returns an empty list if the
  game is over.

  ## Examples

      iex> alias ConnectFour.Game
      iex> %Game{} |> Game.legal_moves()
      [0, 1, 2, 3, 4, 5, 6]

  """
  @spec legal_moves(Game.t()) :: moves()
  def legal_moves(game = %Game{}), do: list_legal_moves(game.column_heights)

  @spec make_move(Game.t(), column()) :: Game.t()
  defp make_move(game = %Game{}, column) do
    {old_column_height, new_column_heights} =
      Map.get_and_update!(game.column_heights, column, fn column_height ->
        {column_height, column_height + 1}
      end)

    bitboard_color = color_to_move(game)
    old_bitboard = Map.get(game.bitboards, bitboard_color)
    new_moves = game.moves ++ [column]
    new_bitboard = old_bitboard ^^^ (1 <<< old_column_height)
    new_plies = game.plies + 1

    updated_game = %{
      game
      | :moves => new_moves,
        :plies => new_plies,
        :bitboards => %{game.bitboards | bitboard_color => new_bitboard},
        :column_heights => new_column_heights
    }

    set_result(updated_game)
  end

  @spec set_result(Game.t()) :: Game.t()
  defp set_result(updated_game = %Game{}) do
    cond do
      connected_four?(updated_game) ->
        %{updated_game | result: winning_color(updated_game)}

      updated_game.plies == 42 ->
        %{updated_game | result: :draw}

      true ->
        updated_game
    end
  end

  @spec color_to_move(Game.t()) :: player()
  defp color_to_move(%Game{plies: plies}) do
    case plies &&& 1 do
      0 -> :yellow
      1 -> :red
    end
  end

  @spec color_last_moved(Game.t()) :: player()
  defp color_last_moved(%Game{plies: plies}) do
    case plies &&& 1 do
      1 -> :yellow
      0 -> :red
    end
  end

  @spec make_many_moves(Game.t(), moves()) :: {:ok, Game.t()} | {:error, String.t()}
  defp make_many_moves(game = %Game{}, [next_move | remaining_moves]) do
    if legal_move?(next_move, game.column_heights) do
      updated_game = make_move(game, next_move)
      make_many_moves(updated_game, remaining_moves)
    else
      {:error, "One or more invalid moves"}
    end
  end

  defp make_many_moves(game = %Game{}, []) do
    {:ok, game}
  end

  @spec legal_move?(column(), column_heights()) :: boolean()
  defp legal_move?(column, column_heights) do
    Enum.member?(list_legal_moves(column_heights), column)
  end

  @spec connected_four?(Game.t()) :: boolean()
  defp connected_four?(game = %Game{}) do
    bitboard = Map.get(game.bitboards, color_last_moved(game))

    direction_offsets = [1, 7, 6, 8]

    Enum.any?(direction_offsets, fn direction_offset ->
      intermediate_bitboard = bitboard &&& bitboard >>> direction_offset
      (intermediate_bitboard &&& intermediate_bitboard >>> (2 * direction_offset)) != 0
    end)
  end

  defp winning_color(%Game{plies: plies}) do
    case plies &&& 1 do
      1 -> :yellow_wins
      0 -> :red_wins
    end
  end

  @spec list_legal_moves(column_heights()) :: [integer()]
  defp list_legal_moves(column_heights) do
    full_top = 0b1000000_1000000_1000000_1000000_1000000_1000000_1000000

    Enum.reduce(0..6, [], fn column, legal_moves_ ->
      if (full_top &&& 1 <<< column_heights[column]) == 0 do
        legal_moves_ ++ [column]
      else
        legal_moves_
      end
    end)
  end
end
