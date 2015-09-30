##### 1.1 First spec.

- `spec/github_feed_spec.rb`

  ```diff
   require_relative "../github_feed"

   RSpec.describe GithubFeed do
  +  describe "#initialization" do
  +    it "works" do
  +      feed = GithubFeed.new("rails/rails")

  +      expect(feed).to be_an_instance_of GithubFeed
  +      expect(feed.repo_name).to eq "rails/rails"
  +    end
  +  end
   end
  ```

##### 1.2 Make it pass.

- `github_feed.rb`

  ```diff
   class GithubFeed
  +  attr_reader :repo_name

  +  def initialize(repo_name)
  +    @repo_name = repo_name
  +  end
   end
  ```

##### 1.3 Simple spec for GithubFeed#recent_comments.

- `spec/github_feed_spec.rb`

  ```diff
         expect(feed.repo_name).to eq "rails/rails"
       end
     end
  +
  +  describe "#recent_comments" do
  +    it "prints from API" do
  +      feed = GithubFeed.new("rails/rails")
  +
  +      expect(feed.recent_comments).to match "made a comment on Issue"
  +    end
  +  end
   end
  ```

##### 1.4 Make it pass.

- `github_feed.rb`

  ```diff
     def initialize(repo_name)
       @repo_name = repo_name
     end
  +
  +  def recent_comments
  +    "made a comment on Issue"
  +  end
   end
  ```

##### 1.5 Install HTTP gem

- `Gemfile`

  ```diff
   source "https://rubygems.org"

  +gem "http"
  +
   gem "rspec"
  ```

- `Gemfile.lock`

  ```diff
   GEM
     remote: https://rubygems.org/
     specs:
  +    addressable (2.3.8)
       diff-lcs (1.2.5)
  +    domain_name (0.5.24)
  +      unf (>= 0.0.5, < 1.0.0)
  +    http (0.9.7)
  +      addressable (~> 2.3)
  +      http-cookie (~> 1.0)
  +      http-form_data (~> 1.0.1)
  +      http_parser.rb (~> 0.6.0)
  +    http-cookie (1.0.2)
  +      domain_name (~> 0.5)
  +    http-form_data (1.0.1)
  +    http_parser.rb (0.6.0)
       rspec (3.3.0)
         rspec-core (~> 3.3.0)
         rspec-expectations (~> 3.3.0)
  @@ -15,11 +27,15 @@ GEM
         diff-lcs (>= 1.2.0, < 2.0)
         rspec-support (~> 3.3.0)
       rspec-support (3.3.0)
  +    unf (0.1.4)
  +      unf_ext
  +    unf_ext (0.0.7.1)

   PLATFORMS
     ruby

   DEPENDENCIES
  +  http
     rspec

   BUNDLED WITH
  ```

##### 1.6 Add readme.

- `README.md`

  ```diff
   feed.recent_comments


  -## Format:
  +## Format


   <date, format>
  -<name> made a comment on Issue #<issue number>
  +<name> made a comment on Issue #<issue number>
   at <link>
   > <body at length 30>


  -## Example:
  +## Example


   26 Sep 2015
   rails-bot made a comment on Issue #123456
   at https://github.com/rails/rails/pull/123456#issuecomment-123
  @@ -30,6 +33,7 @@ at https://github.com/rails/rails/pull/456789#issuecomment-123
   > lorem ipsum..

   ....


   ## API

  ```

##### 1.7 Turn off RSpec warnings

- `spec/spec_helper.rb`

  ```diff

     # This setting enables warnings. It's recommended, but in some cases may
     # be too noisy due to issues in dependencies.
  -  config.warnings = true
  +  config.warnings = false

     # Many RSpec users commonly either run the entire suite or an individual
     # file, and it's useful to allow more verbose output when running an
  ```

##### 1.8 Use HTTP gem.

- `github_feed.rb`

  ```diff
  +require "http"
  +
   class GithubFeed
     attr_reader :repo_name

  @@ -6,6 +8,8 @@ def initialize(repo_name)
     end

     def recent_comments
  +    HTTP.get("https://api.github.com/repos/rails/rails/events")
  +
       "made a comment on Issue"
     end
   end
  ```

##### 1.9 Add webmock and disable all remote connections.

- `Gemfile`

  ```diff
   gem "http"

   gem "rspec"
  +gem "webmock"
  ```

- `Gemfile.lock`

  ```diff
     remote: https://rubygems.org/
     specs:
       addressable (2.3.8)
  +    crack (0.4.2)
  +      safe_yaml (~> 1.0.0)
       diff-lcs (1.2.5)
       domain_name (0.5.24)
         unf (>= 0.0.5, < 1.0.0)
  @@ -27,9 +29,13 @@ GEM
         diff-lcs (>= 1.2.0, < 2.0)
         rspec-support (~> 3.3.0)
       rspec-support (3.3.0)
  +    safe_yaml (1.0.4)
       unf (0.1.4)
         unf_ext
       unf_ext (0.0.7.1)
  +    webmock (1.21.0)
  +      addressable (>= 2.3.6)
  +      crack (>= 0.3.2)

   PLATFORMS
     ruby
  @@ -37,6 +43,7 @@ PLATFORMS
   DEPENDENCIES
     http
     rspec
  +  webmock

   BUNDLED WITH
      1.10.6
  ```

- `spec/spec_helper.rb`

  ```diff
     Kernel.srand config.seed

   end
  +
  +require "webmock/rspec"
  +WebMock.disable_net_connect!
  ```

##### 1.10 Stub GitHub API request.

- `spec/fixtures/events.json`

- `spec/github_feed_spec.rb`

  ```diff
     end

     describe "#recent_comments" do
  +    before do
  +      stub_request(
  +        :get, "https://api.github.com/repos/rails/rails/events"
  +      ).with(
  +        headers: { "User-Agent"=>"http.rb/0.9.7" }
  +      ).to_return(
  +        status: 200, body: File.open("spec/fixtures/events.json")
  +      )
  +    end
  +
       it "prints from API" do
         feed = GithubFeed.new("rails/rails")

  ```

##### 1.11 Failing spec with real values from API response.

- `spec/github_feed_spec.rb`

  ```diff
       it "prints from API" do
         feed = GithubFeed.new("rails/rails")

  -      expect(feed.recent_comments).to match "made a comment on Issue"
  +      expect(feed.recent_comments).to match "sgrif made a comment on Issue #21785"
       end
     end
   end
  ```

##### 1.12 Add detailed spec.

- `spec/github_feed_spec.rb`

  ```diff
       it "prints from API" do
         feed = GithubFeed.new("rails/rails")

  -      expect(feed.recent_comments).to match "sgrif made a comment on Issue #21785"
  +      expected =
  +        <<-COMMENT
  +27 Sep 2015
  +sgrif made a comment on Issue #21785
  +at https://github.com/rails/rails/pull/21785#issuecomment-143571730
  +        COMMENT
  +
  +      expect(feed.recent_comments).to match expected
       end
     end
   end
  ```

##### 1.13 Make it pass.

- `github_feed.rb`

  ```diff
     end

     def recent_comments
  -    HTTP.get("https://api.github.com/repos/rails/rails/events")
  +    events = JSON.parse(
  +      HTTP.get("https://api.github.com/repos/#{repo_name}/events")
  +    )

  -    "made a comment on Issue"
  +    comments =
  +      events.map do |event|
  +        next if event["type"] != "IssueCommentEvent"
  +
  +        comment = "#{Date.parse(event['created_at']).strftime("%d %b %Y")}\n"
  +        comment += "#{event['actor']['login']} made a comment on Issue ##{event['payload']['issue']['number']}\n"
  +        comment += "at #{event['payload']['comment']['html_url']}"
  +      end
  +
  +    comments.compact.join("\n")
     end
   end
  ```

##### 1.14 Stub HTTP.get.

- `spec/github_feed_spec.rb`

  ```diff

     describe "#recent_comments" do
       before do
  -      stub_request(
  -        :get, "https://api.github.com/repos/rails/rails/events"
  -      ).with(
  -        headers: { "User-Agent"=>"http.rb/0.9.7" }
  -      ).to_return(
  -        status: 200, body: File.open("spec/fixtures/events.json")
  -      )
  +      expect(HTTP).to receive(:get) { File.read("spec/fixtures/events.json") }
       end

       it "prints from API" do
  ```

##### 1.15 Stub GithubEvent.

- `spec/github_feed_spec.rb`

  ```diff

     describe "#recent_comments" do
       before do
  -      expect(HTTP).to receive(:get) { File.read("spec/fixtures/events.json") }
  +      expect(GithubEvent).to receive(:all).with("rails/rails") { JSON.parse(File.read("spec/fixtures/events.json")) }
       end

       it "prints from API" do
  ```

##### 1.16 Make it pass.

- `github_feed.rb`

  ```diff
     end

     def recent_comments
  -    events = JSON.parse(
  -      HTTP.get("https://api.github.com/repos/#{repo_name}/events")
  -    )
  +    events = GithubEvent.all(@repo_name)

       comments =
         events.map do |event|
  @@ -24,3 +22,8 @@ def recent_comments
       comments.compact.join("\n")
     end
   end
  +
  +class GithubEvent
  +  def self.all(repo_name)
  +  end
  +end
  ```

##### 1.17 Spec out `GithubEvent.all`.

- `spec/github_feed_spec.rb`

  ```diff
       end
     end
   end
  +
  +RSpec.describe GithubEvent do
  +  let(:fake_json) { File.read("spec/fixtures/events.json") }
  +
  +  describe ".all" do
  +    before do
  +      stub_request(
  +        :get, "https://api.github.com/repos/rails/rails/events"
  +      ).with(
  +        headers: { "User-Agent" => "http.rb/0.9.7" }
  +      ).to_return(
  +        status: 200, body: fake_json
  +      )
  +    end
  +
  +    it "returns results from API" do
  +      expect(GithubEvent.all("rails/rails")).to eq JSON.parse(fake_json)
  +    end
  +  end
  +end
  ```

##### 1.18 Make it pass.

- `github_feed.rb`

  ```diff

   class GithubEvent
     def self.all(repo_name)
  +    JSON.parse(HTTP.get("https://api.github.com/repos/#{repo_name}/events"))
     end
   end
  ```

##### 1.19 Let's use doubles!

- `spec/github_feed_spec.rb`

  ```diff
     end

     describe "#recent_comments" do
  +    let(:fake_events) { [ double(:event, to_s: event_to_s) ] }
  +    let(:event_to_s) do
  +      <<-COMMENT
  +27 Sep 2015
  +sgrif made a comment on Issue #21785
  +at https://github.com/rails/rails/pull/21785#issuecomment-143571730
  +      COMMENT
  +    end
  +
       before do
  -      expect(GithubEvent).to receive(:all).with("rails/rails") { JSON.parse(File.read("spec/fixtures/events.json")) }
  +      expect(GithubEvent).to receive(:all).with("rails/rails") { fake_events }
       end

       it "prints from API" do
         feed = GithubFeed.new("rails/rails")

  -      expected =
  -        <<-COMMENT
  -27 Sep 2015
  -sgrif made a comment on Issue #21785
  -at https://github.com/rails/rails/pull/21785#issuecomment-143571730
  -        COMMENT
  -
  -      expect(feed.recent_comments).to match expected
  +      expect(feed.recent_comments).to match event_to_s
       end
     end
   end
  ```

##### 1.20 Make it pass!

- `github_feed.rb`

  ```diff

       comments =
         events.map do |event|
  -        next if event["type"] != "IssueCommentEvent"
  +        # next if event["type"] != "IssueCommentEvent"

  -        comment = "#{Date.parse(event['created_at']).strftime("%d %b %Y")}\n"
  -        comment += "#{event['actor']['login']} made a comment on Issue ##{event['payload']['issue']['number']}\n"
  -        comment += "at #{event['payload']['comment']['html_url']}"
  +        # comment = "#{Date.parse(event['created_at']).strftime("%d %b %Y")}\n"
  +        # comment += "#{event['actor']['login']} made a comment on Issue ##{event['payload']['issue']['number']}\n"
  +        # comment += "at #{event['payload']['comment']['html_url']}"
  +
  +        event.to_s
         end

       comments.compact.join("\n")
  ```

##### 1.21 Make specs even simpler.

- `spec/github_feed_spec.rb`

  ```diff
     end

     describe "#recent_comments" do
  -    let(:fake_events) { [ double(:event, to_s: event_to_s) ] }
  -    let(:event_to_s) do
  -      <<-COMMENT
  -27 Sep 2015
  -sgrif made a comment on Issue #21785
  -at https://github.com/rails/rails/pull/21785#issuecomment-143571730
  -      COMMENT
  +    let(:fake_events) do
  +      [double(:event, to_s: "abc"), double(:event, to_s: "def")]
       end

       before do
  @@ -27,7 +22,7 @@
       it "prints from API" do
         feed = GithubFeed.new("rails/rails")

  -      expect(feed.recent_comments).to match event_to_s
  +      expect(feed.recent_comments).to match "abc\ndef"
       end
     end
   end
  ```

##### 1.22 Update spec of `GithubEvent.all` to assert for GithubEvent instances.

- `spec/github_feed_spec.rb`

  ```diff
       end

       it "returns results from API" do
  -      expect(GithubEvent.all("rails/rails")).to eq JSON.parse(fake_json)
  +      events = GithubEvent.all("rails/rails")
  +
  +      expect(events.count).to eq 30
  +      expect(events.first).to be_an_instance_of(GithubEvent)
  +      expect(events.first.raw_data).to eq JSON.parse(fake_json).first
       end
     end
   end
  ```

##### 1.23 Make it pass.

- `github_feed.rb`

  ```diff
   end

   class GithubEvent
  +  attr_reader :raw_data
  +
  +  def initialize(raw_data)
  +    @raw_data = raw_data
  +  end
  +
     def self.all(repo_name)
  -    JSON.parse(HTTP.get("https://api.github.com/repos/#{repo_name}/events"))
  +    events =
  +      JSON.parse(HTTP.get("https://api.github.com/repos/#{repo_name}/events"))
  +    events.map { |event| GithubEvent.new(event) }
     end
   end
  ```

##### 1.24 Spec to_s.

- `spec/github_feed_spec.rb`

  ```diff
         expect(events.first.raw_data).to eq JSON.parse(fake_json).first
       end
     end
  +
  +  describe "#to_s" do
  +    let(:event) { GithubEvent.new(JSON.parse(fake_json).first) }
  +
  +    it "formats data" do
  +      expected = "27 Sep 2015\ntimbreitkreutz made a comment on Issue #20602\nat https://github.com/rails/rails/issues/20602#issuecomment-143573857"
  +
  +      expect(event.to_s).to eq expected
  +    end
  +  end
   end
  ```

##### 1.25 Make it pass.

- `github_feed.rb`

  ```diff
         events.map do |event|
           # next if event["type"] != "IssueCommentEvent"

  -        # comment = "#{Date.parse(event['created_at']).strftime("%d %b %Y")}\n"
  -        # comment += "#{event['actor']['login']} made a comment on Issue ##{event['payload']['issue']['number']}\n"
  -        # comment += "at #{event['payload']['comment']['html_url']}"
  -
           event.to_s
         end

  @@ -37,4 +33,10 @@ def self.all(repo_name)
         JSON.parse(HTTP.get("https://api.github.com/repos/#{repo_name}/events"))
       events.map { |event| GithubEvent.new(event) }
     end
  +
  +  def to_s
  +    "#{Date.parse(raw_data['created_at']).strftime("%d %b %Y")}\n" \
  +    "#{raw_data['actor']['login']} made a comment on Issue ##{raw_data['payload']['issue']['number']}\n" \
  +    "at #{raw_data['payload']['comment']['html_url']}"
  +  end
   end
  ```

##### 1.26 Spec for filtering of results.

- `spec/github_feed_spec.rb`

  ```diff
         expect(events.first).to be_an_instance_of(GithubEvent)
         expect(events.first.raw_data).to eq JSON.parse(fake_json).first
       end
  +
  +    it "filters results" do
  +      events = GithubEvent.all("rails/rails", only: "IssueCommentEvent")
  +
  +      expect(events.count).to eq 10
  +      expect(events.map(&:type).uniq).to eq ["IssueCommentEvent"]
  +    end
     end

     describe "#to_s" do
  ```

##### 1.27 Make it pass!

- `github_feed.rb`

  ```diff
       @raw_data = raw_data
     end

  -  def self.all(repo_name)
  +  def self.all(repo_name, only: nil)
       events =
         JSON.parse(HTTP.get("https://api.github.com/repos/#{repo_name}/events"))
  -    events.map { |event| GithubEvent.new(event) }
  +    events.map!    { |event| GithubEvent.new(event) }
  +    events.select! { |event| event.type == only } if only
  +    events
  +  end
  +
  +  def type
  +    raw_data["type"]
     end

     def to_s
  ```

##### 1.28 Simplify code.

- `github_feed.rb`

  ```diff
     end

     def recent_comments
  -    events = GithubEvent.all(@repo_name)
  -
  -    comments =
  -      events.map do |event|
  -        # next if event["type"] != "IssueCommentEvent"
  -
  -        event.to_s
  -      end
  -
  -    comments.compact.join("\n")
  +    events = GithubEvent.all(@repo_name, only: "IssueCommentEvent")
  +    events.map { |event| event.to_s }.join("\n")
     end
   end

  ```

- `spec/github_feed_spec.rb`

  ```diff
       end

       before do
  -      expect(GithubEvent).to receive(:all).with("rails/rails") { fake_events }
  +      expect(GithubEvent).to receive(:all)
  +        .with("rails/rails", only: "IssueCommentEvent") { fake_events }
       end

       it "prints from API" do
  ```

##### 1.29 Example 2 of using spies.

- `github_feed.rb`

  ```diff

     def recent_comments
       events = GithubEvent.all(@repo_name, only: "IssueCommentEvent")
  -    events.map { |event| event.to_s }.join("\n")
  +    events.map { |event| event.render }.join("\n")
     end
   end

  @@ -32,7 +32,7 @@ def type
       raw_data["type"]
     end

  -  def to_s
  +  def render
       "#{Date.parse(raw_data['created_at']).strftime("%d %b %Y")}\n" \
       "#{raw_data['actor']['login']} made a comment on Issue ##{raw_data['payload']['issue']['number']}\n" \
       "at #{raw_data['payload']['comment']['html_url']}"
  ```

- `spec/github_feed_spec.rb`

  ```diff
     end

     describe "#recent_comments" do
  -    let(:fake_events) do
  -      [double(:event, to_s: "abc"), double(:event, to_s: "def")]
  -    end
  +    let(:event_1) { spy(:event) }
  +    let(:event_2) { spy(:event) }
  +    let(:fake_events) { [ event_1, event_2 ] }

       before do
         expect(GithubEvent).to receive(:all)
  @@ -22,10 +22,10 @@

       it "prints from API" do
         feed = GithubFeed.new("rails/rails")
  -      comments = feed.recent_comments
  +      feed.recent_comments

  -      expect(GithubEvent).to have_received(:all)
  -      expect(comments).to match "abc\ndef"
  +      expect(event_1).to have_received(:render)
  +      expect(event_2).to have_received(:render)
       end
     end
   end
  @@ -66,7 +66,7 @@
       it "formats data" do
         expected = "27 Sep 2015\ntimbreitkreutz made a comment on Issue #20602\nat https://github.com/rails/rails/issues/20602#issuecomment-143573857"

  -      expect(event.to_s).to eq expected
  +      expect(event.render).to eq expected
       end
     end
   end
  ```

##### 1.30 Example 1 of using spies (partial double).

- `spec/github_feed_spec.rb`

  ```diff

       it "prints from API" do
         feed = GithubFeed.new("rails/rails")
  +      comments = feed.recent_comments

  -      expect(feed.recent_comments).to match "abc\ndef"
  +      expect(GithubEvent).to have_received(:all)
  +      expect(comments).to match "abc\ndef"
       end
     end
   end
  ```

##### 1.31 Trivial message chain stub.

- `github_feed.rb`

  ```diff
     def self.all(repo_name, only: nil)
       events =
         JSON.parse(HTTP.get("https://api.github.com/repos/#{repo_name}/events"))
  -    events.map!    { |event| GithubEvent.new(event) }
  -    events.select! { |event| event.type == only } if only
  +    events = events.map    { |event| GithubEvent.new(event) }
  +    events = events.select { |event| event.type == only } if only
       events
     end

  ```

- `spec/github_feed_spec.rb`

  ```diff
     let(:fake_json) { File.read("spec/fixtures/events.json") }

     describe ".all" do
  -    before do
  -      stub_request(
  -        :get, "https://api.github.com/repos/rails/rails/events"
  -      ).with(
  -        headers: { "User-Agent" => "http.rb/0.9.7" }
  -      ).to_return(
  -        status: 200, body: fake_json
  -      )
  -    end
  +    context "webmock" do
  +      before do
  +        stub_request(
  +          :get, "https://api.github.com/repos/rails/rails/events"
  +        ).with(
  +          headers: { "User-Agent" => "http.rb/0.9.7" }
  +        ).to_return(
  +          status: 200, body: fake_json
  +        )
  +      end

  -    it "returns results from API" do
  -      events = GithubEvent.all("rails/rails")
  +      it "returns results from API" do
  +        events = GithubEvent.all("rails/rails")

  -      expect(events.count).to eq 30
  -      expect(events.first).to be_an_instance_of(GithubEvent)
  -      expect(events.first.raw_data).to eq JSON.parse(fake_json).first
  +        expect(events.count).to eq 30
  +        expect(events.first).to be_an_instance_of(GithubEvent)
  +        expect(events.first.raw_data).to eq JSON.parse(fake_json).first
  +      end
       end

  -    it "filters results" do
  -      events = GithubEvent.all("rails/rails", only: "IssueCommentEvent")
  +    context "doubles" do
  +      before do
  +        allow(HTTP).to receive(:get) { HTTP }
  +      end
  +
  +      it "filters results" do
  +        fake_events = double(:events)
  +        expect(JSON).to receive(:parse) { fake_events }
  +        allow(fake_events).to receive_message_chain(:map, :select) { fake_events }
  +
  +        events = GithubEvent.all("rails/rails", only: "IssueCommentEvent")

  -      expect(events.count).to eq 10
  -      expect(events.map(&:type).uniq).to eq ["IssueCommentEvent"]
  +        expect(events).to eq fake_events
  +      end
       end
     end

  ```
