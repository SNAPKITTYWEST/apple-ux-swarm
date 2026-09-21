# SPDX-License-Identifier: GPL-3.0-or-later AND Apache-2.0
# SPDX-FileCopyrightText: 2026 SNAPKITTYWEST

defmodule Swarm.TcpListener do
  @moduledoc """
  TCP listener for Dylan-framed agent connections.

  Listens on the configured port (default 4488) with uint32 BE length-prefix
  framing (`:gen_tcp` `packet: 4`), TCP_NODELAY enabled, no JSON.
  """

  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    port = Application.get_env(:swarm, :tcp_port, 4488)

    tcp_opts = [
      :binary,
      active: false,
      reuseaddr: true,
      nodelay: true,
      packet: 4
    ]

    case :gen_tcp.listen(port, tcp_opts) do
      {:ok, listen_socket} ->
        Logger.info("Swarm TCP listener started on port #{port}")
        spawn_accept_loop(listen_socket)
        {:ok, %{listen_socket: listen_socket, port: port}}

      {:error, reason} ->
        {:stop, {:listen_failed, reason}}
    end
  end

  @impl true
  def handle_info({:accept_loop_crashed, reason}, state) do
    Logger.error("Accept loop crashed: #{inspect(reason)}, restarting")
    spawn_accept_loop(state.listen_socket)
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp spawn_accept_loop(listen_socket) do
    parent = self()

    spawn_link(fn ->
      accept_loop(listen_socket, parent)
    end)
  end

  defp accept_loop(listen_socket, parent) do
    case :gen_tcp.accept(listen_socket) do
      {:ok, client_socket} ->
        spawn(fn -> handle_connection(client_socket) end)
        accept_loop(listen_socket, parent)

      {:error, :closed} ->
        Logger.info("Listen socket closed, accept loop exiting")

      {:error, reason} ->
        send(parent, {:accept_loop_crashed, reason})
    end
  end

  defp handle_connection(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, frame_data} ->
        case Swarm.DylanCodec.decode(frame_data) do
          {:ok, frame} ->
            dispatch(frame, socket)

          {:error, reason} ->
            Logger.warning("Dylan decode error: #{inspect(reason)}")
        end

        handle_connection(socket)

      {:error, :closed} ->
        :ok

      {:error, reason} ->
        Logger.warning("TCP recv error: #{inspect(reason)}")
    end
  end

  defp dispatch(frame, _socket) do
    Logger.debug(
      "Dispatching frame op=#{frame.op} seq=#{frame.seq} " <>
        "agent_id=#{Base.encode16(frame.agent_id, case: :lower)}"
    )

    # TODO: route to agent processes via AgentSupervisor
    :ok
  end
end
