require "http"

class GithubFeed
  attr_reader :repo_name

  def initialize(repo_name)
    @repo_name = repo_name
  end

  def recent_comments
    events = GithubEvent.all(@repo_name)

    comments =
      events.map do |event|
        # next if event["type"] != "IssueCommentEvent"

        # comment = "#{Date.parse(event['created_at']).strftime("%d %b %Y")}\n"
        # comment += "#{event['actor']['login']} made a comment on Issue ##{event['payload']['issue']['number']}\n"
        # comment += "at #{event['payload']['comment']['html_url']}"

        event.to_s
      end

    comments.compact.join("\n")
  end
end

class GithubEvent
  def self.all(repo_name)
    JSON.parse(HTTP.get("https://api.github.com/repos/#{repo_name}/events"))
  end
end
