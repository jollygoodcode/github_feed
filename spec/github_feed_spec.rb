require_relative "../github_feed"

RSpec.describe GithubFeed do
  describe "#initialization" do
    it "works" do
      feed = GithubFeed.new("rails/rails")

      expect(feed).to be_an_instance_of GithubFeed
      expect(feed.repo_name).to eq "rails/rails"
    end
  end

  describe "#recent_comments" do
    it "prints from API" do
      feed = GithubFeed.new("rails/rails")

      expect(feed.recent_comments).to match "made a comment on Issue"
    end
  end
end
