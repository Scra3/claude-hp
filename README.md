# ClaudeHP

Your Claude usage as a Tekken health bar, sitting on your Mac desktop.

![bars](docs/bars.png)

## What it shows

The same numbers as `/usage`, read from `GET /api/oauth/usage`:

| Bar | Source |
|---|---|
| `SESSION 5H` | `limits[kind=session]` |
| `WEEK 7D` | `limits[kind=weekly_all]` |
| `FABLE 7D` | `limits[kind=weekly_scoped]`, named after `scope.model.display_name` |

The bar shows what is **left**, not what is used: `/usage` says "18% used", the bar
sits at 82%. Under 20% it turns red and pulses.

Any new `weekly_scoped` window shows up on its own. Nothing to recode if another
model gets its own limit.

## Use

- **Click** to fold and unfold (folded shows the session alone)
- **Drag** to move it, the position is remembered
- **Right click** for launch at login and quit

## Build

```sh
git clone https://github.com/Scra3/claude-hp
cd claude-hp && ./build.sh
open ClaudeHP.app
```

macOS 15, Swift 6.2 toolchain. One file, no Xcode project.

## Keychain

The app reads Claude Code's OAuth token from the keychain (`Claude Code-credentials`)
to sign the API call. The token is never logged and never written to disk.

macOS asks on first launch: click **Always Allow**. The grant is tied to the binary's
signature, so **every `./build.sh` resets it** and the dialog comes back once.

If the token expires with no Claude Code session around to refresh it, the call fails
and the bars read `NO SIGNAL` rather than showing a stale number.

## Landing page

`site/index.html`, one static file, no dependencies. Open it in a browser or deploy
the `site/` folder as is.
