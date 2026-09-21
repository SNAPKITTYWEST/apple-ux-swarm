# SPDX-License-Identifier: GPL-3.0-or-later AND Apache-2.0
# SPDX-FileCopyrightText: 2026 SNAPKITTYWEST

defmodule Swarm.Auth.SamlHandler do
  @moduledoc """
  SAML authentication handler using the Samly library.

  Reads the IdP metadata URL from application config (`:swarm`, `:saml_idp_metadata_url`).
  Provides the ACS callback handler and SP metadata endpoint.
  """

  require Logger

  @doc """
  Returns the Samly IdP provider configuration derived from application config.
  """
  def idp_config do
    metadata_url = Application.get_env(:swarm, :saml_idp_metadata_url)

    %Samly.IdpData{
      id: "swarm_idp",
      metadata_url: metadata_url
    }
  end

  @doc """
  Samly pipeline configuration for use in a Plug router.

  Example:

      forward "/sso", to: Samly.Router, init_opts: Swarm.Auth.SamlHandler.samly_opts()
  """
  def samly_opts do
    [
      idp_id: "swarm_idp",
      certfile: Application.get_env(:swarm, :saml_certfile, "priv/cert/saml.pem"),
      keyfile: Application.get_env(:swarm, :saml_keyfile, "priv/cert/saml_key.pem")
    ]
  end

  @doc """
  Handle the SAML ACS (Assertion Consumer Service) callback.

  Receives the Samly assertion after a successful IdP authentication and
  returns a map of user attributes.
  """
  @spec handle_callback(Samly.Assertion.t()) :: {:ok, map()} | {:error, atom()}
  def handle_callback(%Samly.Assertion{} = assertion) do
    attrs = Samly.Assertion.attributes(assertion)
    name_id = Samly.Assertion.name_id(assertion)

    Logger.info("SAML auth success for #{name_id}")

    {:ok,
     %{
       name_id: name_id,
       attributes: attrs
     }}
  end

  def handle_callback(_invalid) do
    {:error, :invalid_assertion}
  end

  @doc """
  Returns the SP metadata XML for registration with the IdP.
  """
  @spec metadata() :: binary()
  def metadata do
    Samly.SPData.metadata_xml()
  end
end
