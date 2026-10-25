# Debugging tips

- If derivation or generation suspiciously freezes, try converting complex dependent types into standard functions and replace predicates with So + Bool functions.
- Never leave unnamed arguments in constructors. Giving every argument an explicit name makes reading derivation logs and tracking arguments order significantly easier.
- If you are unsure whether a specific type can actually be constructed, try instantiating its value manually. Use `%search` to make the compiler handle the routine boilerplate for you.
- When verifying if a specific dependent type value can actually be constructed, use auto implicit auxiliary arguments to manually inject values for testing.
- If derivation hangs on a specific constructor for an unusually long time, do not wait for it to finish. Cancel the process and begin debugging that constructor.
- If nothing works, recreate a minimal, bare-bones version of the model in a clean test project. Verify that basic generation works, then add features back step-by-step.
