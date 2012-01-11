#!/bin/sh

set -e
set -x

bundle install --deployment --path=.bundle/gems
bundle exec rake spec
