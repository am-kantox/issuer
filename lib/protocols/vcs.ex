defprotocol Issuer.Vcs do
  @doc """
    Returns a status of current git repository
  """
  def status(data)

  @doc """
    Lists tags for the repository given.
  """
  def tags(data)

  @doc """
    Adds a tag to the repo.
  """
  def tag!(data, tag)

  # @doc """
  #   Performs commit.
  # """
  def commit!(data, message)
end
