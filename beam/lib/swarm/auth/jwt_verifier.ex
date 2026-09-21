# SPDX-License-Identifier: GPL-3.0-or-later AND Apache-2.0
# SPDX-FileCopyrightText: 2026 SNAPKITTYWEST

defmodule Swarm.Auth.JwtVerifier do
  @moduledoc """
  Plug that verifies JWT Bearer tokens from the Authorization header.

  On success, assigns `:current_user` to the connection.
  On failure, responds with 401 Unauthorized.
  """

  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    with {:ok, token} <- extract_bearer(conn),
         {:ok, claims} <- verify_token(token) do
      assign(conn, :current_user, claims)
    else
      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{error: "unauthorized", reason: to_string(reason)}))
        |> halt()
    end
  end

  defp extract_bearer(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, String.trim(token)}
      _ -> {:error, :missing_bearer_token}
    end
  end

  defp verify_token(token) do
    secret = Application.get_env(:swarm, :jwt_secret, "changeme")
    signer = Joken.Signer.create("HS256", secret)

    case Joken.verify(token, signer) do
      {:ok, claims} -> {:ok, claims}
      {:error, reason} -> {:error, reason}
    end
  end
end
