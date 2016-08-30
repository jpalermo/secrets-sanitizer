# Sanitizer

We wrote this program to consolidate secrets into a single repo.
This program searches yaml files for keys matching a given regex ie: `secret` any keys that match that `secret` will have their keys replaces with mustache.  Those values are stores as json at a location specified by the user.  
This process is easily reversible.

## Example

Given the following (short) manifest file content:

```yaml
---
bla:
  foo:
    bar_secret_key: bar_secret_value
    bar_not_secret_key: bar_not_secret_value
    special_char_value_key: "*"
    multi_line_value_key: |
      ----------BEGIN RSA PRIVATE KEY--------
      ASDASDASDSADSAD
      ----------END RSA PRIVATE KEY----------
```

Sanitizing will:
- Scan yaml files in `/Path/to/manifests` for keys matching a regex (use our [default](https://github.com/pivotal-cloudops/secrets-sanitizer/blob/master/config/catchall) or specify your own using `--pattern-file`)
- Replace each value of the matching keys with a `{{mustache_placeholder}}` value
- Output the secrets read from the matching key/value pairs to a json file in the `secret-dir` specified.


For example,

```
sanitize --input /Path/to/manifests/ --secret-dir /Path/to/store/secret_json/
```

(where `/Path/to/manifests` included our manifest example above) will produce:

```yaml
---
bla:
foo:
  bar_secret_key: "{{bla_foo_bar_secret_key}}"
  bar_not_secret_key: "{{bla_foo_bar_not_secret_key}}"
  special_char_value_key: "{{bla_foo_special_char_value_key}}"
  multi_line_value_key: "{{bla_foo_multi_line_value_key}}"
```

The resulting `json` secrets file looks like:

```json
{
  "bla_foo_bar_secret_key": "bar_secret_value",
  "bla_foo_bar_not_secret_key": "bar_not_secret_value",
  "bla_foo_special_char_value_key": "*",
  "bla_foo_multi_line_value_key": "----------BEGIN RSA PRIVATE KEY--------\nASDASDASDSADSAD\n----------END RSA PRIVATE KEY----------\n"
}
```



To reverse this process, simply run:

```
desanitize --input /Path/to/manifests/ --secret-dir /Path/to/store/secret_json/
```

Desanitizing will:
- Scan yaml files in `/Path/to/manifests` for mustache that matches the secrets in the json files from the specified `secrets-dir`
- Replace those mustache values with the corresponding secrets

The result of desanitization will look familiar:

```yaml
---
bla:
  foo:
    bar_secret_key: bar_secret_value
    bar_not_secret_key: bar_not_secret_value
    special_char_value_key: "*"
    multi_line_value_key: |
      ----------BEGIN RSA PRIVATE KEY--------
      ASDASDASDSADSAD
      ----------END RSA PRIVATE KEY----------
```


*Like all well behaved unix programs, output is silent unless it is interesting.  You may with to add the `--verbose` flag to your commands while you are learning the ropes.*

## Installation
```bash
    $ gem install secrets-sanitizer
```

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

You can specify a pattern for secrets.  Patterns are newline delimted regex.  If you do not specify your own file: the defaults listed below will be used

```
secret
[kK]ey
password
[cC]ert
```

## Gotchas

because we interpret the YAML as a ruby object: `sanitizer` currently:

* eats comments
* reformats numbers like `186_000` to `186000`
* adds quotes to unquoted strings
* rearranging multi-line strings

We encourage going over the output and being selective about acceptable changes.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To release a new version, update the version numbers in `version.rb` located in desanitizer and sanitizer folders, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pivotal-cloudops/sanitizer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.  If you have a bad experience: tell us about it.  We are working to make this code more better!

Legal:
If you have not previously done so, please fill out and
submit the https://cla.pivotal.io/sign/pivotal[Contributor License Agreement].


## License

The gem is available as open source under the terms of the Apache 2.0 License, check LICENSE.txt for details.
