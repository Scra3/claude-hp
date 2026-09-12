# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

Static HTML/CSS/JS, one file at `site/index.html`, no build step. Deploy target: Cloudflare Pages (same as the user's other sites). The product itself is a native macOS app in `main.swift`; the web surface is its landing page only.

## Users

Developers who use Claude Code on a Mac under a subscription quota. They run `/usage` repeatedly to see how much of the 5 hour session and the weekly windows are left, and they resent the interruption. They read terminals all day, install tools with `git clone`, and distrust marketing copy.

## Product Purpose

ClaudeHP shows the remaining Claude quota as Tekken style health bars in a floating window on the macOS desktop. Success: the developer glances at the bar instead of typing `/usage`, and knows before the session runs dry.

## Positioning

It renders the exact numbers `/usage` shows, from the same endpoint (`GET /api/oauth/usage`, `limits[]`), as a life bar that drains with a lagging red damage trail. Not a token counter, not an estimate: the official quota, as a fighting game HUD.

## Operating Context

- macOS 15 (built with the system Swift 6.2 toolchain, `swiftc` only, no Xcode project).
- Install: `git clone`, `./build.sh`, `open ClaudeHP.app`.
- First launch: macOS asks for keychain access to `Claude Code-credentials`; the user must click **Always Allow**. Every rebuild resets that authorization because the binary is ad hoc signed.
- The window floats above other windows, is draggable, and remembers its position. Click toggles compact (session only) and expanded (all windows). Right click: launch at login, quit.

## Capabilities and Constraints

- Bars: `SESSION 5H`, `SEMAINE 7J`, `FABLE 7J` (labels are in French in the current build; any future `weekly_scoped` limit appears as its own bar automatically).
- Bars show what remains, not what is used. Under 20 % remaining the bar turns red and pulses.
- Polls every 30 s. When the API call fails the bar shows `EN ATTENTE`, never a stale number.
- The OAuth token is read from the keychain at call time and never logged or written to disk.
- No signed or notarized release exists. No DMG. No Homebrew tap. The landing page must not claim any.
- Not affiliated with Anthropic or Bandai Namco; the page must say so.

## Brand Commitments

- Name: **ClaudeHP**.
- Visual identity is fixed by the app itself: sheared parallelogram bars, chrome bevel, amber to orange health gradient, striped depleted track, lagging red trail, DIN Condensed Bold lettering, near black matte panel. The web surface must be recognizably the same object.
- Voice: short, human, first person allowed. No dashes, no marketing formulas, no feature lists dressed as benefits.

## Evidence on Hand

- `main.swift`: the real rendering code and palette (source of truth for colors and geometry).
- `docs/bars.png`: a real capture of the expanded widget (contains a keychain dialog edge at the right; not clean enough for the page).
- No user testimonials, download counts, stars, or press. Do not fabricate any.
- Demo numbers on the page are synthetic and must be labeled as such.

## Product Principles

1. Understood in one second: the page shows the bar before it says a word.
2. Prove, never claim: the mechanism is demonstrated live, not described.
3. Same numbers as `/usage`: accuracy is the product, honesty is the copy.
4. Developer register: a command block is the call to action, not a button that says "Get started".
5. The app is the brand: every web element borrows the HUD's vocabulary rather than a template's.
