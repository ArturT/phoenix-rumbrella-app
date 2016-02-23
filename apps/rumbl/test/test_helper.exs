defmodule InfoSys.Test.HTTPClient do
  def request(_url) do
    {:ok, {[], [], "<queryresult></queryresult>"}}
  end
end

ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Rumbl.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Rumbl.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Rumbl.Repo)

