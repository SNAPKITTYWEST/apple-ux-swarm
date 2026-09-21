# SPDX-License-Identifier: GPL-3.0-or-later AND Apache-2.0
# SPDX-FileCopyrightText: 2026 SNAPKITTYWEST

defmodule Swarm.AgentSupervisor do
  @moduledoc """
  DynamicSupervisor for agent processes.
  """

  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Start a child agent under this supervisor.
  `child_spec` is a valid child specification.
  """
  def start_agent(child_spec) do
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @doc """
  Stop a running agent by its pid.
  """
  def stop_agent(pid) when is_pid(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end
end
