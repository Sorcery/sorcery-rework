# frozen_string_literal: true

# TODO: This isn't done yet. Just adding this so I don't forget about the meta
#       gem.

version = File.read(File.expand_path('./SORCERY_VERSION', __dir__)).strip
repo_url = 'https://github.com/sorcery/sorcery'

Gem::Specification.new do |s|
  s.version     = version
  s.platform    = Gem::Platform::RUBY
  s.name        = 'sorcery'
  s.summary     = 'Magical Authentication'
  s.description = 'Meta gem to ease transition to v1 for existing applications.'

  # TODO: Sign the gem: https://guides.rubygems.org/security/#general

  # TODO: Does including minimum rubygems version make sense?
  s.required_ruby_version     = '>= 3.0.0'
  # s.required_rubygems_version = '>= 1.8.11'

  s.license = 'MIT'

  s.authors = [
    'Noam Ben Ari',
    'Kir Shatrov',
    'Grzegorz Witek',
    'Chase Gilliam',
    'Josh Buker'
  ]
  s.email    = 'crypto@joshbuker.com'
  s.homepage = 'https://sorcerygem.org'

  s.files = []

  s.metadata = {
    'bug_tracker_uri'       => "#{repo_url}/issues",
    'changelog_uri'         => "#{repo_url}/releases/tag/v#{version}",
    'documentation_uri'     => "#{repo_url}/wiki",
    'source_code_uri'       => "#{repo_url}/tree/v#{version}",
    'rubygems_mfa_required' => 'true'
  }

  s.add_dependency 'sorcery-core',  version
  s.add_dependency 'sorcery-oauth', version

  # Because omniauth strat dependencies will be need to be added, might as well
  # remove the hard requirement for bcrypt.
  # s.add_dependency 'bcrypt', '~> 3.0'
end
