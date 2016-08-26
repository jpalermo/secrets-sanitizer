# Sanitizer

We wrote this program to consolidate secrets into a single repo.
This program moves the secrets into a new folder, and replaces secrets with Mustache template references.


## Installation

Add this line to your application's Gemfile:

```
gem 'secrets-sanitizer'
```

Or install it yourself as:

    $ gem install secrets-sanitizer

## Usage

```
sanitize [options]
-h, --help          Help. See this help message.
-i, --input         Input manifest file or directory
-s, --secret-dir    Folder where all secrets will be written
-p, --pattern-file  (optional) Pattern file containing secrets patterns
                      config/catchall is used by default
-v, --verbose
```

You can specify a pattern for secrets.  Pattern are newline delimted regex.  If you do not specify your own file: the defaults listed below will be used

```
secret
[kK]ey
password
[cC]ert
```



Example run:



```
± jy+kx kx ag |master U:2 ?:2 ✗| → ./bin/sanitize -i /Path/to/manifests/ -s /Path/to/store/secret_json/
```

Like all well behaved unix programs, output is silent unless it is interesting.  You may with to add the `--verbose` flag to your commands while you are learning the ropes.


## Gotchas

because we interpret the YAML as a ruby object: `sanitizer` currently:

* eats comments
* reformats numbers like `186_000` to `186000`
* adds quotes to unquoted strings
* rearranging multi-line strings

We encourage going over the output and being selective about acceptable changes.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `gem install secrets-sanitizer`. To release a new version, update the version numbers in `version.rb` located in desanitizer and sanitizer folders, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pivotal-cloudops/sanitizer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.  If you have a bad experience: tell us about it.  We are working to make this code more better!

Legal:
If you have not previously done so, please fill out and
submit the https://cla.pivotal.io/sign/pivotal[Contributor License Agreement].


## License

The gem is available as open source under the terms of the Apache 2.0 License, check LICENSE.txt for details.

