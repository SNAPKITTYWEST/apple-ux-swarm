# SPDX-License-Identifier: GPL-3.0-or-later AND Apache-2.0
# SPDX-FileCopyrightText: 2026 SNAPKITTYWEST

defmodule Swarm.Application do
  @moduledoc """
  OTP Application for the Swarm agent mesh.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Swarm.Backpressure, []},
      {Swarm.AgentSupervisor, []},
      {Swarm.TcpListener, []}
    ]

    opts = [strategy: :one_for_one, name: Swarm.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
