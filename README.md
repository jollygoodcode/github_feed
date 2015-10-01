# README

A commandline tool for pulling recent comments for a public GitHub repo,
used for teaching testing in Ruby.

## Interface

```
feed = GithubFeed.new("rails/rails")
feed.recent_comments
```

## Format

```
<date, format>
<name> made a comment on Issue #<issue number>
at <link>
> <body at length 30>
```

## Example

```
26 Sep 2015
rails-bot made a comment on Issue #123456
at https://github.com/rails/rails/pull/123456#issuecomment-123
> lorem ipsum..

26 Sep 2015
dhh made a comment on Issue #456789
at https://github.com/rails/rails/pull/456789#issuecomment-123
> lorem ipsum..

....
```

## API

https://api.github.com/repos/rails/rails/events
