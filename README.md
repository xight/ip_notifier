# ip-notifier

notify if global IP address was updated

## requirement

* Ruby Gem
  * mail
  * typhoeus

## install

```
cp config.yaml.sample config.yaml
vi config.yaml
bundle install --path=vendor/bundle
```

## usage

```
bundle exec ruby app.rb
```

## crontab

```
* * * * * bash -lc 'cd /path/to/ip-notifier && bundle exec ruby app.rb'
```
