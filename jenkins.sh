#!/usr/bin/env bash

set -e
set -x

eval "$(rbenv init -)"

bundle install --deployment --path=.bundle/gems
bundle exec rake spec
