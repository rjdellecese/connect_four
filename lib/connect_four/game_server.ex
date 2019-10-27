defmodule ConnectFour.GameServer do
  @moduledoc """
  A Connect Four game, stored in a GenServer.
  """

  use GenServer

  alias ConnectFour.{Game, GameServer}

  @type moves_and_result() :: %{moves: Game.moves(), result: Game.result()}

  ############
  # Public API
  ############

  @doc """
  Start a GenServer process for a Connect Four game.

  ## Examples

      iex> {:ok, pid} = GameServer.start_link()
      iex> Process.alive?(pid)
      true

  """
  @spec start_link() :: GenServer.on_start()
  def start_link(), do: GenServer.start_link(GameServer, nil)

  @doc """
  Make a move. If any of the moves are invalid, none (including any valid ones
  preceding the invalid one) will be played.

  ## Examples

      iex> {:ok, pid} = GameServer.start_link()
      iex> GameServer.move(pid, 4)
      {:ok, %{moves: [4], result: nil}}
      iex> GameServer.move(pid, 5)
      {:ok, %{moves: [4, 5], result: nil}}

      iex> {:ok, pid} = GameServer.start_link()
      iex> GameServer.move(pid, [4, 5])
      {:ok, %{moves: [4, 5], result: nil}}

      iex> {:ok, pid} = GameServer.start_link()
      iex> GameServer.move(pid, [4, 7])
      {:error, "One or more invalid moves"}

      iex> {:ok, pid} = GameServer.start_link()
      iex> GameServer.move(pid, [1, 1, 2, 2, 3, 3, 4])
      {:ok, %{moves: [1, 1, 2, 2, 3, 3, 4], result: :yellow_wins}}
      iex> GameServer.move(pid, 4)
      {:error, "Game is over"}

  """
  @spec move(pid(), Game.column() | Game.moves()) ::
          {:ok, moves_and_result()} | {:error, String.t()}
  def move(pid, move_or_moves), do: GenServer.call(pid, {:move, move_or_moves})

  @doc """
  Get a list of legal moves for the current position.

  ## Examples

      iex> {:ok, pid} = GameServer.start_link()
      iex> GameServer.legal_moves(pid)
      {:ok, [0, 1, 2, 3, 4, 5, 6]}

      iex> {:ok, pid} = GameServer.start_link()
      iex> GameServer.move(pid, [3, 3, 3, 3, 3, 3])
      {:ok, %{moves: [3, 3, 3, 3, 3, 3], result: nil}}
      iex> GameServer.legal_moves(pid)
      {:ok, [0, 1, 2, 4, 5, 6]}

  """
  @spec legal_moves(pid()) :: {:ok, Game.moves()}
  def legal_moves(pid), do: GenServer.call(pid, :legal_moves)

  @doc """
  Look at the state of the game.

  ## Examples

      iex> {:ok, pid} = GameServer.start_link()
      iex> GameServer.move(pid, [4, 5, 4])
      {:ok, %{moves: [4, 5, 4], result: nil}}
      iex> GameServer.look(pid)
      {:ok, %{moves: [4, 5, 4], result: nil}}

  Works for finished games, too.

  ## Examples

      iex> {:ok, pid} = GameServer.start_link()
      iex> GameServer.move(pid, [4, 5, 4, 5, 4, 5])
      {:ok, %{moves: [4, 5, 4, 5, 4, 5], result: nil}}
      iex> GameServer.move(pid, 4)
      {:ok, %{moves: [4, 5, 4, 5, 4, 5, 4], result: :yellow_wins}}
      iex> GameServer.look(pid)
      {:ok, %{moves: [4, 5, 4, 5, 4, 5, 4], result: :yellow_wins}}

  """
  @spec look(pid()) :: {:ok, moves_and_result()}
  def look(pid), do: GenServer.call(pid, :look)

  @doc """
  Restart the game. The game does **not** need to have a result to be restarted.

  ## Examples

      iex> {:ok, pid} = GameServer.start_link()
      iex> GameServer.move(pid, 4)
      {:ok, %{moves: [4], result: nil}}
      iex> GameServer.restart(pid)
      :ok
      iex> GameServer.move(pid, 4)
      {:ok, %{moves: [4], result: nil}}

  """
  @spec restart(pid()) :: :ok
  def restart(pid), do: GenServer.call(pid, :restart)

  ##################
  # Server callbacks
  ##################

  @impl true
  @spec init(nil) :: {:ok, Game.t()}
  def init(_init_arg), do: {:ok, %Game{}}

  @impl true
  @spec handle_call({:move, Game.column() | Game.moves()}, GenServer.from(), Game.t()) ::
          {:reply, {:ok, moves_and_result(), Game.t()} | {:error, String.t()}, Game.t()}
  def handle_call({:move, column}, _from, game = %Game{}) do
    case Game.move(game, column) do
      {:ok, updated_game} ->
        {:reply, {:ok, %{moves: updated_game.moves, result: updated_game.result}}, updated_game}

      {:error, msg} ->
        {:reply, {:error, msg}, game}
    end
  end

  @impl true
  @spec handle_call(:legal_moves, GenServer.from(), Game.t()) ::
          {:reply, {:ok, Game.moves()}, Game.t()}
  def handle_call(:legal_moves, _from, game = %Game{}) do
    {:reply, {:ok, Game.legal_moves(game)}, game}
  end

  @impl true
  @spec handle_call(:look, GenServer.from(), Game.t()) ::
          {:reply, :ok, moves_and_result()}
  def handle_call(:look, _from, game = %Game{}) do
    {:reply, {:ok, %{moves: game.moves, result: game.result}}, game}
  end

  @impl true
  @spec handle_call(:restart, GenServer.from(), Game.t()) :: {:reply, :ok, Game.t()}
  def handle_call(:restart, _from, _game) do
    {:reply, :ok, %Game{}}
  end
end
