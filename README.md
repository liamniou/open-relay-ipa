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
Apple's active-app and App-ID limits still apply. The IPA includes the app's
widgets and share extension, which consume additional App IDs; AltStore may
offer to remove them. Upstream's Apple Watch companion app is removed from the
IPA: AltStore's signer crashes on its `arm64_32` binaries, and AltStore does
not provision or re-identify embedded Watch apps. Capabilities requiring paid/special
entitlements are not guaranteed when sideloading. This repository does not
bypass Apple's signing restrictions.

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

Packaging adds certificate-free **ad-hoc signatures** carrying only the App
Group entitlement to the app and its extensions. This lets AltStore discover
and provision their shared storage; the IPA is still not installable without
AltStore signing it for your device. Paid/special upstream entitlements are
not requested by these placeholder signatures.

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
building. The first two fix a "the compiler is unable to type-check this expression in
reasonable time" error that occurs in Release builds on every Xcode available
on GitHub's macOS 26 runners (26.4.1 to 26.6):

- `0001-watch-orbview-typecheck.patch`: the Watch companion's `OrbView.swift`.
  Splits one ternary into two statements, which give the same result.
- `0002-knowledge-editor-typecheck.patch`: `KnowledgeEditorView.swift`. Moves
  the folder picker's `onPick` closure body, unchanged, into a private method.
- `0003-sideload-share-handoff.patch`: fixes sharing into a new chat.
  Resolves AltStore's renamed App Group from `ALTAppGroups` in each installed
  bundle, including widgets. Accepts text providers returning strings or UTF-8
  data. The iPhone/iPad chat shell creates and populates a fresh view model
  directly, rather than losing version-counter events before the view mounts
  or sending text to an existing chat. Pending content survives a cold launch
  or sign-in, and duplicate foreground/deep-link callbacks import it only once.
  Shared URLs still use the web-context pipeline and files still upload normally;
  sharing does not automatically send a message.

If upstream already contains a patch's change, the build skips that patch and
prints a notice. If a patch no longer applies, the build fails. Update or
delete the patch, then rerun the build.

### Checking sharing on a device

Install a build containing the share fix in AltStore Classic, keeping the
**share extension** when prompted. An existing installation may need to be
refreshed/reinstalled so AltStore provisions the newly declared App Group.
Do not delete the app unless you have backed up any local-only data.

Check sharing selected text with the app closed, backgrounded in an existing
chat, and already showing an unsent new-chat draft. Each share should open a
fresh chat with the text in its composer, without sending it or modifying the
previous chat. Repeat with multiline/Unicode text, a browser URL, a photo,
and multiple files. Open the app normally afterward to confirm the content
is not imported twice. If a transcription is active in the new-chat draft,
the import remains pending; bring the app to the foreground after it finishes.

CI tests App Group resolution, builds all app/extension targets, and checks
the packaged App Group entitlements. Actual iOS share-sheet delivery still
requires the device checks above.

## Source and licensing

Open Relay remains under its [upstream GPL license](upstream/LICENSE).
Each IPA release includes a source archive of the exact upstream commit,
including its Swift package lockfile, the build patch applied on top of it
(`Open-Relay-*-build.patch`), and the original license.
GitHub's automatically generated source archives of **this pipeline repository**
do not include Git submodule contents; use the attached `Open-Relay-*-source.tar.gz`
for the application's corresponding source. Build commands are in
[the workflow](.github/workflows/build-ipa.yml).
