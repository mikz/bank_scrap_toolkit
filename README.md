# BankScrapToolkit


Bank Scrap Toolkit is a CLI application to make easier working with mitmproxy.

Allows you to run mitmproxy/mitmdump and extract calls as JSON and then pretty print those interactions.


## Installation

    $ gem install bank_scrap_toolkit

## Usage

First start mitmdump or mitmproxy:

```shell
bank_scrap_toolkit mitmdump --output test.json --filter "~u /bsmobil/api/"
```

Then connect your device to mitmproxy (see instructions on mitmproxy website). Make some requests.

When you press 'Ctrl-C' the mitmproxy/dump will quit and write all the request to json file specified as output.

To print them as plain text, use:

```shell
bank_scrap_toolkit print test.json
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec bank_scrap_toolkit` to use the code located in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/mikz/bank_scrap_toolkit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
