defprotocol Issuer.Vcs do
  @doc """
    Returns a diff against given revision/tag.
  """
  def diff(data, label \\ nil)

  @doc """
    Performs a local commit.
  """
  def commit(data, message)

  @doc """
    Lists tags for the repository given.
  """
  def tags(data)

  @doc """
    Adds a tag to the repo.
  """
  def tag!(data, tag)

  @doc """
    Performs a push to origin.
  """
  def push(data)
end
