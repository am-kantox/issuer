defprotocol Issuer.CLI.Question do
  @doc """
    Makes a question (`{title, choices, chosen}` tuple) to be asked via `Issuer.CLI.IO`
  """
  def to_question(data)
end
