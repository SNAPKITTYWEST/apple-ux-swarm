# SPDX-License-Identifier: GPL-3.0-or-later AND Apache-2.0
# SPDX-FileCopyrightText: 2026 SNAPKITTYWEST

defmodule Swarm.Backpressure do
  @moduledoc """
  GenServer implementing flow-control backpressure with high/low watermarks.

  State transitions:
  - `:flowing`  when count < high_watermark
  - `:blocked`  when count >= high_watermark
  - Back to `:flowing` when count drops below low_watermark
  """

  use GenServer

  @default_high_watermark 1000
  @default_low_watermark 200

  defstruct count: 0,
            high_watermark: @default_high_watermark,
            low_watermark: @default_low_watermark,
            state: :flowing

  ## Public API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc "Increment the in-flight counter by 1."
  @spec increment() :: :ok
  def increment do
    GenServer.call(__MODULE__, :increment)
  end

  @doc "Decrement the in-flight counter by 1."
  @spec decrement() :: :ok
  def decrement do
    GenServer.call(__MODULE__, :decrement)
  end

  @doc "Returns true if the system is accepting new work (count < high_watermark)."
  @spec allow?() :: boolean()
  def allow? do
    GenServer.call(__MODULE__, :allow?)
  end

  ## GenServer callbacks

  @impl true
  def init(_opts) do
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_call(:increment, _from, %__MODULE__{} = s) do
    new_count = s.count + 1
    new_state = if new_count >= s.high_watermark, do: :blocked, else: s.state
    {:reply, :ok, %{s | count: new_count, state: new_state}}
  end

  def handle_call(:decrement, _from, %__MODULE__{} = s) do
    new_count = max(s.count - 1, 0)

    new_state =
      cond do
        s.state == :blocked and new_count < s.low_watermark -> :flowing
        new_count >= s.high_watermark -> :blocked
        true -> s.state
      end

    {:reply, :ok, %{s | count: new_count, state: new_state}}
  end

  def handle_call(:allow?, _from, %__MODULE__{} = s) do
    {:reply, s.count < s.high_watermark, s}
  end
end
