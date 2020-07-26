# DummyApp

This app provides a framework for testing the actual loading of Sorcery into a
Rails application. It's kept as minimal as possible, with only the files
necessary to prevent Rails from imploding when being loaded.

To use this app, call `require 'rails_helper'` at the top of a spec instead of
the usual `require 'spec_helper'`.
