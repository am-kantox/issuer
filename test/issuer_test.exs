defmodule IssuerTest do
  use ExUnit.Case
  doctest Issuer

  test "the truth" do
    Mix.Tasks.Issuer.run ["Aleksie"]
  end
end
