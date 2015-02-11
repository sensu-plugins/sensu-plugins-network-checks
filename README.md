[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-network-checks.svg?branch=master)][1]
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-network-checks.svg)][2]
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks/badges/gpa.svg)][3]
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks/badges/coverage.svg)][4]
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-network-checks.svg)][5]

## Functionality

## Files
 *
 *
 *
 *

## Usage

>>>>>>> initial commit
## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
<<<<<<< HEAD
gem install <gem> -P MediumSecurity
=======
gem install sensu-plugins-network-checks -P MediumSecurity
>>>>>>> initial commit
```

You can also download the key from /certs/ within each repository.

#### Rubygems

<<<<<<< HEAD
`gem install sensu-plugins-network`

#### Bundler

Add *sensu-plugins-network* to your Gemfile and run `bundle install` or `bundle update`
=======
`gem install sensu-plugins-network-checks`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`
>>>>>>> initial commit

#### Chef

Using the Sensu **sensu_gem** LWRP
```
<<<<<<< HEAD
sensu_gem 'sensu-plugins-network' do
  options('--prerelease')
  version '0.0.1.alpha.2'
=======
sensu_gem 'sensu-plugins-network-checks' do
  options('--prerelease')
  version '0.0.1.alpha.4'
>>>>>>> initial commit
end
```

Using the Chef **gem_package** resource
```
<<<<<<< HEAD
gem_package 'sensu-plugins-process-checks' do
  options('--prerelease')
  version '0.0.1.alpha.2'
=======
gem_package 'sensu-plugins-network-checks' do
  options('--prerelease')
  version '0.0.1.alpha.4'
>>>>>>> initial commit
end
```

## Notes
<<<<<<< HEAD
=======

[1]:[https://travis-ci.org/sensu-plugins/sensu-plugins-network-checks]
[2]:[http://badge.fury.io/rb/sensu-plugins-network-checks]
[3]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks]
[4]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks]
[5]:[https://gemnasium.com/sensu-plugins/sensu-plugins-network-checks]
>>>>>>> initial commit
