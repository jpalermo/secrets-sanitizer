# Sanitizer

We wrote this program to consolidate secrets in one repo, instead of being spread across dozens of repos.
This program moves the secrets into a new repo, and replaces secrets with Mustache template references.


## Installation

Add this line to your application's Gemfile:

```
gem 'sanitizer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sanitizer

## Usage

```
Usage: example.rb [options]
    -s, --secret-dir=SECRETDIR       Secret file directory
    -p, --pattern-file=PATTERNFILE   File with regex patterns to match secret keys
    -m, --manifest=MANIFEST          Manifest yaml
    -d, --input-dir=INPUTDIR         Input directory of yaml files
```

Only use one `-m` or `-d` at a time.


First, Create a pattern file contains the regex expression how to match the key.



Example run:



```
± jy+kx kx ag |master U:2 ?:2 ✗| → ./bin/sanitize -d /Path/to/manifests/  -p secret_regex_pattern_file -s /Path/to/store/secret_json/

Sanitizing file /Path/to/manifests/manifest1.yml...
Sanitizing file /Path/to/manifests/manifest2.yml...
```


## Gotchas

`sanitizer` currently:

* eats comments
* reformats numbers like `186_000` to `186000`
* adds quotes to unquoted strings
* rearranging multi-line strings

We encourage going over the output and being selective about acceptable changes.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pivotal-cloudops/sanitizer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the Apache 2.0 License, check LICENSE.txt for details.

