class GithubFeed
  attr_reader :repo_name

  def initialize(repo_name)
    @repo_name = repo_name
  end

  def recent_comments
    "made a comment on Issue"
  end
end
