# frozen_string_literal: true

version = File.read(File.expand_path('../SORCERY_VERSION', __dir__)).strip
repo_url = 'https://github.com/sorcery/sorcery'

Gem::Specification.new do |s|
  s.version     = version
  s.platform    = Gem::Platform::RUBY
  s.name        = 'sorcery-core'
  s.summary     = 'Magical Authentication'
  s.description =
    'Provides common authentication needs that can be easily used within ' \
    'your own MVC structure.'

  # TODO: Does including minimum rubygems version make sense?
  s.required_ruby_version     = '>= 2.6.0'
  s.required_rubygems_version = '>= 1.8.11'

  s.license = 'MIT'

  s.author   = 'Josh Buker'
  s.email    = 'crypto@joshbuker.com'
  s.homepage = 'https://sorcerygem.org'

  s.files = ['lib/sorcery-core.rb', 'lib/sorcery/version.rb']

  s.metadata = {
    'bug_tracker_uri'       => "#{repo_url}/issues",
    'changelog_uri'         => "#{repo_url}/releases/tag/v#{version}",
    'documentation_uri'     => "#{repo_url}/wiki",
    'source_code_uri'       => "#{repo_url}/tree/v#{version}",
    'rubygems_mfa_required' => 'true'
  }

  # TODO: Rails dependency and version locking
  # s.add_dependency 'rails'

  # Crypto providers are optional, make sure to add them to your bundle if used.
  # This appears to be deprecated, check for recommended alternative
  # s.add_optional_dependency 'argon2', '~> 2.0'
  # s.add_optional_dependency 'bcrypt', '~> 3.0'
end
