# Sorcery

Working repo for Sorcery v1. Following Rails project layout as a guide for
multiple gems released in lock step.

New Gems:

`sorcery-core` - All previous sorcery functionality except for OAuth support.
`sorcery-mfa` - New plugin to add support for Authy apps and WebAuthn 2FA.
`sorcery-oauth` - Acts as a 1:1 replacement for Sorcery's External module.

Original Gem

`sorcery` - Will be left as-is so the v1 migration is an optional/manual change.

Nothing is set in stone at the moment, any and all suggestions are welcomed.

## Updating Versions

You will need to update two files:

* `./SORCERY_VERSION`
* `./sorcery-core/lib/sorcery/version.rb`
