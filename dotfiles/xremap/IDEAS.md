# xremap ideas — for when the layout work calls for it

## Adaptive swaps

Article: <https://dario.ca/posts/2026-05-18-keyboard-layout-adaptive-swaps/>

**The rule:** immediately after hitting key X, the positions of keys Y and Z
swap — one-shot, resolved by the next keypress, no timeouts. Example
`[S, C, D]`: after typing s, the d-position key emits c (fixing the `sc` SFB
as an outroll) while the c-position key emits d (so `sd`, like in `SDK`,
stays reachable — unlike Hands-Down-style full overrides that need a
timeout).

**Prerequisite before starting:** know Graphite's actual weaknesses first
(SFB/scissor data — e.g. layout analysis via cminibrowser), because the
article's rule sets are for **Gallium, Sturdy, Vylet, Whirl** — the rules do
NOT transfer, only the mechanism. Viable rules need an uncommon "fixer"
bigram and a good-side trigram that doesn't create new SFBs.

**xremap supports it natively** via nested remaps
(`doc/reference_key_sequence.md`), same handler path as the `set_mode`
toggle (proven working in this daemon):

```yaml
keymap:
  - remap:
      <trigger>:
        remap:            # arms on trigger press, one-shot
          <Y>: <Z>
          <Z>: <Y>
        # optional: timeout_key / timeout_millis for timed overrides
```

**The keyspace rule (the one real subtlety):** keymap entries match on
**post-modmap keys**, exactly like the shifted-punctuation block. Example
translation of `[S, C, D]` for Graphite:

- trigger "after typing graphite-s" → phys F → post-modmap `KEY_S`
- letter c in Graphite = phys c (identity) → post-modmap `KEY_C`
- letter d in Graphite = phys E → post-modmap `KEY_D`

```yaml
- name: adaptive-scd
  mode: ["default"]        # sleeps in friend mode; games-gating optional
  remap:
    KEY_S:
      remap:
        KEY_C: KEY_D
        KEY_D: KEY_C
```

**When picked up:** add a mode-gated `adaptive` keymap block with the chosen
rules (keys already translated to post-modmap keyspace), test `science` vs
`SDK` live, document the final rule set here. Scope intentionally stops at
adaptive swaps — no magic keys, no advanced scripting; xremap covers
everything else Graphite needs.
