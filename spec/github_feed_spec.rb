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
    let(:event_1) { spy(:event) }
    let(:event_2) { spy(:event) }
    let(:fake_events) { [ event_1, event_2 ] }

    before do
      expect(GithubEvent).to receive(:all)
        .with("rails/rails", only: "IssueCommentEvent") { fake_events }
    end

    it "prints from API" do
      feed = GithubFeed.new("rails/rails")
      feed.recent_comments

      expect(event_1).to have_received(:render)
      expect(event_2).to have_received(:render)
    end
  end
end

RSpec.describe GithubEvent do
  let(:fake_json) { File.read("spec/fixtures/events.json") }

  describe ".all" do
    context "webmock" do
      before do
        stub_request(
          :get, "https://api.github.com/repos/rails/rails/events"
        ).with(
          headers: { "User-Agent" => "http.rb/0.9.7" }
        ).to_return(
          status: 200, body: fake_json
        )
      end

      it "returns results from API" do
        events = GithubEvent.all("rails/rails")

        expect(events.count).to eq 30
        expect(events.first).to be_an_instance_of(GithubEvent)
        expect(events.first.raw_data).to eq JSON.parse(fake_json).first
      end
    end

    context "doubles" do
      before do
        allow(HTTP).to receive(:get) { HTTP }
      end

      it "filters results" do
        fake_events = double(:events)
        expect(JSON).to receive(:parse) { fake_events }
        allow(fake_events).to receive_message_chain(:map, :select) { fake_events }

        events = GithubEvent.all("rails/rails", only: "IssueCommentEvent")

        expect(events).to eq fake_events
      end
    end
  end

  describe "#to_s" do
    let(:event) { GithubEvent.new(JSON.parse(fake_json).first) }

    it "formats data" do
      expected = "27 Sep 2015\ntimbreitkreutz made a comment on Issue #20602\nat https://github.com/rails/rails/issues/20602#issuecomment-143573857"

      expect(event.render).to eq expected
    end
  end
end
