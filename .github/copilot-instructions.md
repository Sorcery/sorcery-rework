# Copilot Instructions for Sorcery Rework

## Project Overview
- This is a multi-gem Ruby project for authentication, following a Rails-inspired structure.
- Main gems:
  - `sorcery-core`: Core authentication logic (no OAuth/JWT/MFA).
  - `sorcery-oauth`: OAuth support (external providers).
  - `sorcery-jwt`: JWT support for API-only apps.
  - `sorcery-mfa`: Multi-factor authentication (MFA/2FA).
- Each gem is in its own folder with a `lib/` directory and a gemspec.
- The top-level `sorcery` gem will become a meta-gem bundling core and oauth.

## Key Patterns & Conventions
- **Plugins**: New features (OAuth, JWT, MFA) are implemented as plugins, not in core.
- **Extensibility**: Use the `sorcery/plugins/` directory for new plugin code.
- **Configuration**: Core config in `sorcery-core/lib/sorcery/config.rb`.
- **Controllers/Models**: Example/test controllers and models are in `spec/dummy_app/app/`.
- **Specs**: All specs live under `spec/`, with plugin-specific specs in `spec/plugins/`.
- **Factories**: Test factories are in `spec/factories/`.
- **Crypto**: Pluggable crypto providers in `sorcery-core/lib/sorcery/crypto_providers/`.

## Developer Workflows
- **Testing**: Use RSpec. Run all tests with `bundle exec rspec` from the project root.
- **Dummy App**: For integration tests, use the dummy Rails app in `spec/dummy_app/`.
  - In specs, require `rails_helper` (not `spec_helper`) to load the dummy app.
- **Building Gems**: Each gem can be built and installed independently using its gemspec.
- **Adding Plugins**: Place new plugin code in the relevant `plugins/` directory and add tests in `spec/plugins/`.

## Integration & Dependencies
- External dependencies (e.g., JWT, Omniauth, WebAuthn) are only loaded in their respective plugin gems.
- The core gem is kept minimal and dependency-light.

## Examples
- To add a new authentication method, create a new plugin in `sorcery-core/lib/sorcery/plugins/` and add corresponding tests.
- To test OAuth, use the dummy app and specs in `spec/plugins/oauth_controller_spec.rb`.

## References
- See each gem's `README.md` for details on its purpose and structure.
- For test setup, see `spec/rails_helper.rb` and `spec/dummy_app/README.md`.

---

*Update this file as project structure or conventions evolve. Focus on actionable, project-specific guidance for AI agents.*
