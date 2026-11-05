# Open Relay unsigned IPA

Builds [Ichigo3766/Open-Relay](https://github.com/Ichigo3766/Open-Relay) for
iPhone/iPad, without an Apple signing certificate or provisioning profile.
This is an unofficial build pipeline, not the upstream project.

## Install with AltStore

1. Download the `.ipa` from the [latest release](https://github.com/liamniou/open-relay-ipa/releases/latest).
2. Transfer it to your device and open/import it in **AltStore Classic**.
3. Let AltStore sign and install the app with your Apple ID.

The initial upstream version requires **iOS/iPadOS 18.1 or later**. AltStore
Classic must already be installed using AltServer; AltStore PAL does not import
arbitrary IPAs. With a free Apple ID, refresh the app at least every seven days.
Apple's active-app and App-ID limits still apply. The upstream app includes
widgets, a share extension, and a Watch companion; extensions consume additional
App IDs. AltStore may offer to remove extensions. Watch installation and
capabilities requiring paid/special entitlements are not guaranteed when
sideloading. This repository does not bypass Apple's signing restrictions.

## Builds and downloads

Pushes to `main`, pull requests, and manual runs of
[Build unsigned IPA](https://github.com/liamniou/open-relay-ipa/actions/workflows/build-ipa.yml)
build the exact source commit pinned by the `upstream` Git submodule.
The workflow uses a macOS 26 runner and the latest stable Xcode installed on
that runner. Swift packages use upstream's committed `Package.resolved`;
the build fails rather than silently updating those dependencies.

Every successful `main` build publishes a release containing the unsigned IPA,
corresponding upstream source, original license, SHA-256 checksums, and build
provenance. Pull requests produce downloadable workflow artifacts only, with no
release-write permissions. Artifacts expire after 30 days; release assets do not
have that expiry. Failed Xcode builds retain their build log for seven days.

No signing secrets, Apple ID, or paid Apple Developer membership are needed for
the pipeline. The Apple ID is used locally by AltStore, not GitHub Actions.

## Automatic upstream updates

Dependabot checks the `upstream` Git submodule **daily** and GitHub Actions
versions **weekly**. The submodule starts at upstream tag `v6.4.1`.
Dependabot's tagged-submodule support prefers semantic-version tags when the
current commit is tagged, instead of tracking every untagged commit on `main`.
Upstream currently publishes version tags, not GitHub Releases.

Review and merge Dependabot's upstream update pull requests to publish a new IPA.
**Automatic merging is not enabled.** The workflow rejects submodule commits
without a stable `vMAJOR.MINOR` or `vMAJOR.MINOR.PATCH` tag, so prerelease-only or
untagged updates cannot produce a published IPA. Upstream changes can still
require pipeline adjustments; failed builds do not publish a release.

To select a version manually:

```sh
git clone --recurse-submodules https://github.com/liamniou/open-relay-ipa.git
cd open-relay-ipa
git -C upstream fetch --tags
git -C upstream checkout v6.4.1
git add upstream
git commit -m "Update Open Relay to v6.4.1"
git push
```

Changing the submodule's Git commit, not editing a separate version variable,
updates the source used by the build.

## Build patches

Files in [`patches/`](patches) are applied to the upstream checkout before
building. They only work around build failures and do not change app behavior:

- `0001-watch-orbview-typecheck.patch`: the Watch companion's `OrbView.swift`
  fails with "the compiler is unable to type-check this expression in
  reasonable time" on every Xcode available on GitHub's macOS 26 runners
  (26.4.1 to 26.6). The patch splits one ternary into two statements, which
  give the same result.

If upstream already contains a patch's change, the build skips that patch and
prints a notice. If a patch no longer applies, the build fails. Update or
delete the patch, then rerun the build.

## Source and licensing

Open Relay remains under its [upstream GPL license](upstream/LICENSE).
Each IPA release includes a source archive of the exact upstream commit,
including its Swift package lockfile, the build patch applied on top of it
(`Open-Relay-*-build.patch`), and the original license.
GitHub's automatically generated source archives of **this pipeline repository**
do not include Git submodule contents; use the attached `Open-Relay-*-source.tar.gz`
for the application's corresponding source. Build commands are in
[the workflow](.github/workflows/build-ipa.yml).
