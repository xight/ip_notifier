# IP Notifier

notify if global IP address was updated

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ip_notifier'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ip_notifier

## Usage

```
cp config.yaml.sample config.yaml
vi config.yaml
bundle exec ruby exe/ip_notifier check
```
### crontab

```
* * * * * bash -lc 'cd /path/to/ip-notifier && bundle exec ruby exe/ip_notifier check'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xight/ip_notifier.
