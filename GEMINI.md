# Gemini Code Assistant Project Brief: Sorcery

## Project Overview

**Sorcery** is a modular, bare-bones authentication library for Ruby on Rails.
This project is a major rework of the original Sorcery gem, splitting it into
several smaller, more focused gems. The goal is to provide a flexible and
extensible authentication solution that is easy to understand and maintain.

### Key Technologies

*   **Ruby:** 3.0.0+
*   **Rails:** (Implicitly, as it's a Rails engine)

### Architecture

The project is structured as a collection of gems, each providing a specific
piece of functionality:

*   `sorcery-core`: Provides the core authentication logic, including user/password
    authentication, session management, and a plugin system.
*   `sorcery-jwt`: Adds support for JSON Web Tokens (JWT) for API-only
    applications.
*   `sorcery-mfa`: Implements multi-factor authentication (MFA) using Authy and
    WebAuthn.
*   `sorcery-oauth`: Provides OAuth support, replacing the external module from
    the original Sorcery gem.
*   `sorcery`: A meta-gem that includes `sorcery-core` and `sorcery-oauth` for
    backwards compatibility and ease of transition.

## Building and Running

### Dependencies

The project uses Bundler to manage its dependencies. To install the required
gems, run:

```bash
bundle install
```

### Testing

The project uses RSpec for testing. To run the test suite, use the following
command:

```bash
bundle exec rspec
```

To run the full test suite, including RuboCop, you can use the default Rake
task:

```bash
bundle exec rake
```

The tests are located in the `spec` directory and are organized by gem and module.

## Development Conventions

### Coding Style

The project follows the standard Ruby community style guide and uses `rubocop`
to enforce it. The `rubocop` configuration is defined in the `.rubocop.yml`
file.

### Contribution Guidelines

The project has a `CODE_OF_CONDUCT.md` file and a `MAINTAINING.md` file that
likely contain information about contributing to the project. There are also
issue and pull request templates in the `.github` directory.
