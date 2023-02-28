#!/bin/bash

bundle config set path /workspaces/$1/vendor/cache
bundle install --jobs=1
