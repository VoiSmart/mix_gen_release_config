defmodule Mix.Tasks.Gen.Release.Config do
  use Mix.Task

  alias Config.Reader

  @release_config_path "config/releases.exs"
  @config_filter_path "config/config_filter.exs"

  @shortdoc """
  Mix task to generate a release config in an umbrella project from apps config files.
  """

  @moduledoc """
  Mix task to generate a release config in an umbrella project from apps config files.
  """

  @impl true
  def run([config_file]) do
    {config, _paths} = Reader.read_imports!(config_file)
    content = rebuild_config(config)
    :ok = File.write!(@release_config_path, content)

    maybe_format(@release_config_path)
  end

  defp maybe_format(path) do
    if Mix.Task.get("format") do
      Mix.Task.run("format", [path])
    end
  end

  defp rebuild_config(config) do
    config
    |> Enum.reduce(
      "import Config\n\n",
      fn {root_key, v}, str_config ->
        str_config <> handle_value(root_key, v) <> "\n"
      end
    )
  end

  defp handle_value(root_key, keywords) when is_list(keywords) do
    true = Keyword.keyword?(keywords)
    filter = load_config_filter()

    keywords
    |> Enum.map(fn {k, v} ->
      case {root_key, k} in filter do
        true -> nil
        _ -> "config :#{root_key}, #{maybe_module(k)}, #{inspect(v)}\n"
      end
    end)
    |> Enum.join("\n")
  end

  defp maybe_module(module) when is_atom(module), do: maybe_module(Atom.to_string(module))
  defp maybe_module("Elixir." <> rest), do: rest
  defp maybe_module(name), do: ":#{name}"

  defp load_config_filter do
    if File.exists?(@config_filter_path) do
      require_filter_file()
    else
      []
    end
  end

  defp require_filter_file do
    Code.require_file(@config_filter_path)

    if :erlang.function_exported(Filters, :get, 0) do
      case Filters.get() do
        l when is_list(l) -> l
        _ -> []
      end
    else
      []
    end
  end
end
