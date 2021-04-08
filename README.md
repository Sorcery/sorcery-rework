# Sorcery

![Ruby](https://github.com/Sorcery/sorcery-rework/workflows/Ruby/badge.svg)

### **This code is not ready for production usage!!**

Please use the existing Sorcery Gem for the time being, v0.0.0 contains nothing
more than a hello world.

Working repo for Sorcery v1. Following Rails project layout as a guide for
multiple gems released in lock step.

New Gems:

* `sorcery-core` - All previous sorcery functionality except for OAuth support.
* `sorcery-jwt` - New plugin to add support for JWT / API only apps.
* `sorcery-mfa` - New plugin to add support for Authy apps and WebAuthn 2FA.
* `sorcery-oauth` - Acts as a 1:1 replacement for Sorcery's External module.

Original Gem

* `sorcery` - Will be updated to be a meta gem that includes core and oauth.

Nothing is set in stone at the moment, any and all suggestions are welcomed.
