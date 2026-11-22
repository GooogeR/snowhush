# GooogeR Snowhush fork setup

This fork is configured to check the Sparkle appcast at:

https://github.com/GooogeR/snowhush/releases/latest/download/appcast.xml

The macOS release script targets the GitHub repository `GooogeR/snowhush`.

## Build a local DMG (no Apple Developer membership required)

On a Mac with Xcode and the Command Line Tools installed:

```sh
./make-dmg-local.sh
```

The output is `dist/Snowhush.dmg`. This build is ad-hoc signed and is suitable for local testing. Gatekeeper may warn/block it on other Macs. Public distribution without that warning requires a Developer ID Application certificate and Apple notarization.

## Important: Sparkle update signing is not finished yet

`Resources/Info.plist` still contains the upstream Sparkle `SUPublicEDKey`. Do not publish updates using this key: the matching private key belongs to the upstream project and is not available to this fork. Before enabling updates, generate a new Sparkle EdDSA key on the release Mac using Sparkle's `generate_keys`, then replace `SUPublicEDKey` with the newly generated public key. Keep the private key in that Mac's login Keychain and back it up securely. Never commit or publish the private key.

After that, build each update archive and generate `appcast.xml` with Sparkle's `generate_appcast` so each update receives a matching EdDSA signature. The appcast and update archive must be uploaded as assets to a GitHub Release in `GooogeR/snowhush`. The current `release.sh` still requires Developer ID signing, notarization credentials, and other release prerequisites; it is not a no-signing release workflow.

## Versioning

Increment both `CFBundleShortVersionString` and `CFBundleVersion` in `Resources/Info.plist` for each release. Sparkle compares `CFBundleVersion` to decide whether an update is newer.
