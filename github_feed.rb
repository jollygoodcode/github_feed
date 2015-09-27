require "http"

class GithubFeed
  attr_reader :repo_name

  def initialize(repo_name)
    @repo_name = repo_name
  end

  def recent_comments
    events = GithubEvent.all(@repo_name, only: "IssueCommentEvent")
    events.map { |event| event.to_s }.join("\n")
  end
end

class GithubEvent
  attr_reader :raw_data

  def initialize(raw_data)
    @raw_data = raw_data
  end

  def self.all(repo_name, only: nil)
    events =
      JSON.parse(HTTP.get("https://api.github.com/repos/#{repo_name}/events"))
    events.map!    { |event| GithubEvent.new(event) }
    events.select! { |event| event.type == only } if only
    events
  end

  def type
    raw_data["type"]
  end

  def to_s
    "#{Date.parse(raw_data['created_at']).strftime("%d %b %Y")}\n" \
    "#{raw_data['actor']['login']} made a comment on Issue ##{raw_data['payload']['issue']['number']}\n" \
    "at #{raw_data['payload']['comment']['html_url']}"
  end
end
