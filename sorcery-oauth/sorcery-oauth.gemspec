# frozen_string_literal: true

version = File.read(File.expand_path('../SORCERY_VERSION', __dir__)).strip
repo_url = 'https://github.com/sorcery/sorcery'

Gem::Specification.new do |s|
  s.version     = version
  s.platform    = Gem::Platform::RUBY
  s.name        = 'sorcery-oauth'
  s.summary     = 'OAuth support for Sorcery.'
  s.description = 'Adds plugins to Sorcery for supporting OAuth login.'

  # TODO: Does including minimum rubygems version make sense?
  s.required_ruby_version     = '>= 3.0.0'
  # s.required_rubygems_version = '>= 1.8.11'

  s.license = 'MIT'

  s.author   = 'Josh Buker'
  s.email    = 'crypto@joshbuker.com'
  s.homepage = 'https://sorcerygem.org'

  s.files = ['lib/sorcery-oauth.rb']

  s.metadata = {
    'bug_tracker_uri'       => "#{repo_url}/issues",
    'changelog_uri'         => "#{repo_url}/releases/tag/v#{version}",
    'documentation_uri'     => "#{repo_url}/wiki",
    'source_code_uri'       => "#{repo_url}/tree/v#{version}",
    'rubygems_mfa_required' => 'true'
  }

  s.add_dependency 'sorcery-core', version

  s.add_dependency 'omniauth', '~> 2.0'
end
