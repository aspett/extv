defmodule ExTV do
  @moduledoc """
  An Elixir API client for theTVDB.com

  All calls to theTVDB.com API require an API key; sign up and get one there.
  To configure ExTV to use the API key, add the following to your application's
  config.exs:

      config :extv, tvdb_api_key: "<your api key>"

  Please see `ExTV.Series` as a starting point for getting about TV series.
  """

  use Application

  alias ExTV.{Streamable}

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(ExTV.Credentials, []),
    ]

    opts = [strategy: :one_for_one, name: ExTV.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def api_key do
    Application.get_env(:extv, :tvdb_api_key) ||
      System.get_env("TVDB_API_KEY")
  end

  def stream({fetch_fn, opts}) do
    raise_on_error = fetch_opt(opts, :raise_on_error, false)
    Streamable.stream(fetch_fn, &Streamable.default_extract/1, &Streamable.default_next_page/2, [raise: raise_on_error])
  end

  def fetch({fetch_fn, _opts}, page) do
    fetch_fn.(page)
  end

  defp fetch_opt([_ | _] = opts, opt, default) do
    case Keyword.fetch(opts, opt) do
      :error -> default
      value -> value
    end
  end
end
