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
    before do
      stub_request(
        :get, "https://api.github.com/repos/rails/rails/events"
      ).with(
        headers: { "User-Agent"=>"http.rb/0.9.7" }
      ).to_return(
        status: 200, body: File.open("spec/fixtures/events.json")
      )
    end

    it "prints from API" do
      feed = GithubFeed.new("rails/rails")

      expected =
        <<-COMMENT
27 Sep 2015
sgrif made a comment on Issue #21785
at https://github.com/rails/rails/pull/21785#issuecomment-143571730
        COMMENT

      expect(feed.recent_comments).to match expected
    end
  end
end
