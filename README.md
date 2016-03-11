# Redmine API [![Build Status](https://travis-ci.org/avdgaag/redmine-api.svg?branch=master)](https://travis-ci.org/avdgaag/redmine-api)

This is a command-line interface to the popular Redmine issue tracking system, based on its REST API. Use it to quickly get the information you need without taking your hands off the keyboard to open a browser.

This is a simple pure-Ruby gem with no additional runtime dependencies. It is as much an exercise in using the Ruby standard library as it is meant to be useful.

## Installation

You can install this gem using Rubygems:

    $ gem install redmine-api

## Usage

To use this gem, invoke its executable from the command line:

    % redmine --version
    0.1.0

This program consists of several subcommands, which you can see listed when you print the help information:

    % redmine --help

For example, to list all available projects in your Redmine installation, use the `projects` subcommand:

    % redmine projects

For more information, read the docs or the inline help.

## Authentication

In order to access your Redmine data, you need to configure the gem to point to the right Redmine installation and provide proper credentials. You can do so by creating a configuration file in your project directory containing that information. Such a configuration file would be named `.redmine.yml` and might look like this:

    ---
    api_token: '14acda31941e8c5dc3be12d1a5d108311b7da3eb'
    base_uri: 'http://redmine.mydomain.tld'
    http_cache: 'redmine.cache'

Using the API token is currently the only supported way to authenticate against Redmine. Since your API token is private, make sure you make your configuration file only accessible to yourself. This program will look for a `.redmine.yml` file in the current directory its ancestor directories, merging all of them together into one final configuration (with the first file to be encountered taking precedence over later files).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/avdgaag/redmine-api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Credits

* **Author**: Arjan van der Gaag <arjan@arjanvandergaag.nl>
* **URL**: arjanvandergaag.nl
* **Homepage**: https://github.com/avdgaag/redmine-api

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
