defprotocol Issuer.Survey do
  @doc """
    Performs a survey, asking questions and collection answers.
  """
  def survey!(data)
end
