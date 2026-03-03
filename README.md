# Elm Components — Proof of Concept

This is a working proof of concept for **stateful, encapsulated components** in Elm. Components follow the Elm Architecture (init/update/view/subscriptions) but live inside the virtual DOM tree with their own local state, scoped JS effects, and parent communication via props and emits.

**This works today** — but requires forked versions of the Elm compiler, `elm/virtual-dom`, and `elm/browser`. Nothing here is upstream or official.

## What's in this demo

The test app (`src/Main.elm`) renders three components that showcase the full feature set:

- **Timer** — Local state (tick count, running flag) + co-located JS effects (`startTimer`/`stopTimer` commands, `onTick` subscription via `Timer.elm.js`). Emits tick count and reset events to the parent.
- **Counter** — Local state (`+local` button) alongside parent-controlled state (`+parent` button emits to parent, which passes the updated count back as a prop).
- **Wrapper** — Nests a Counter component inside itself. Demonstrates that components compose naturally — the inner Counter emits to Wrapper, and Wrapper can emit to Main.

## What's forked

| Repository | What changed | Why |
|---|---|---|
| **Elm compiler** (0.19.1) | New `component module` syntax, parser/canonicalizer/type-checker/codegen | Enforces the component interface at compile time, generates the wiring code |
| **elm/virtual-dom** | New `__2_COMPONENT` vnode type, diff/patch/mount/unmount lifecycle | Components need their own DOM lifecycle, event dispatcher, and effect routing |
| **elm/browser** | `Browser.Component` module, `ComponentMsg(Internal, Emit)`, `emit` helper | Elm-side API for component authors |

The forked packages live alongside this test app as local packages (the compiler's `local-packages` feature).

## Design decisions

### Components are a module type, not a library pattern

```elm
component module Timer where { msg = Msg, props = Props } exposing (timer)
```

The `component module` declaration tells the compiler this module defines a component. The compiler validates the interface (Props, Msg, Model, and the 5 required functions) and generates the exposed constructor function. The parent sees a simple function:

```elm
Timer.timer : { label : String, onTick : Int -> msg, onReset : msg } -> Html msg
```

The component's internal Msg, Model, and ComponentMsg machinery are completely hidden.

**Why a module type instead of a library function?** A library-only approach (Phase 1 of this project) works but requires manual `Internal`/`Emit` wrapping in every view handler and can't enforce the component contract. The compiler syntax eliminates boilerplate and catches mistakes at compile time.

### Parent message type stays abstract

Components never name the parent's concrete `Msg` type. Props are parameterized by `parentMsg`:

```elm
type alias Props parentMsg =
    { label : String
    , onTick : Int -> parentMsg
    }
```

This means the same component works with any parent. The compiler threads `parentMsg` through all internal types (`ComponentMsg Msg parentMsg`) and erases it in the exposed function signature.

### Each component instance is a mini Elm runtime

Under the hood, each component instance calls `Platform.initialize` to create its own stepper, command queue, and subscription manager. This means components get full Cmd/Sub support (Http, Time, Browser.Events, etc.) for free — effect managers already route correctly per-stepper.

The component's event dispatcher intercepts the virtual DOM's tagger chain:
- `Internal msg` → runs the component's own update cycle
- `Emit parentMsg` → unwraps and forwards to the parent's event chain

### Co-located JS effects replace ports for components

Instead of global ports, component modules can declare commands and subscriptions backed by a `.elm.js` file:

```elm
-- In Timer.elm (declarations without bodies = JS-backed effects)
startTimer : Int -> Cmd (ComponentMsg Msg parentMsg)
stopTimer : Cmd (ComponentMsg Msg parentMsg)
onTick : (Int -> Msg) -> Sub (ComponentMsg Msg parentMsg)
```

```javascript
// In Timer.elm.js
export function setup(instance, domNode) {
  instance.on("startTimer", function (intervalMs) { /* ... */ });
  instance.send("onTick", tickCount);
}
export function teardown(instance, domNode) { /* cleanup */ }
```

Each component instance gets its own JS `setup`/`teardown` lifecycle. Two Timers on the same page get independent intervals. This is scoped, instance-level JS interop — something `effect module` (restricted to `elm/` org packages) provides globally but that regular Elm code cannot do.

### Identity is position-based

Like React, component identity is determined by position in the virtual DOM tree + spec reference equality. Same component type at the same position preserves state across parent re-renders. Different type (or removed) triggers unmount/remount.

Props changes are detected via Elm's structural equality (`_Utils_eq`) and trigger `onPropsChange`, giving the component a chance to react.

## Running it

```bash
# Compile (requires the forked compiler on your PATH)
rm -rf elm-stuff && elm make src/Main.elm --output=elm.js

# Dev server (Vite)
npm run dev
```

Note: The Vite dev server handles `.elm` file HMR via `vite-plugin-elm`. Changes to `.elm.js` files trigger recompilation automatically (configured in `vite.config.js`), but the HMR wrapper has a known issue with nested `Platform.initialize` — a workaround patch in `node_modules/vite-plugin-elm` is needed and gets lost on `npm install`.

## Known limitations

- **Not upstream.** This is a personal fork and proof of concept, not a proposal to the Elm core team.
- **No debugger support.** Component state is opaque to the Elm debugger. Time-travel won't replay component-internal messages.
- **HMR is fragile.** The `vite-plugin-elm` HMR wrapper doesn't account for nested Platform instances. A manual patch is required.
- **No keyed list handling.** Components inside `Html.Keyed.node` haven't been tested for state preservation during reorder.
- **No lazy interaction.** Components inside `Html.lazy` may not receive prop updates if lazy's reference check skips re-rendering.
