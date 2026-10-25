# Rules of Extreme DepTyChecking

1. Do not use hand-written generators.
2. Do not use hand-written generators.
3. Do not leave implicit type indexes ambiguous. If you want them to be given, constrain them explicitly, or they may be treated as generated.
4. Do not invent complex structures. DepTyCheck works best with flat lists. Represent your domain using them.
5. Do not design the specification in isolation. Real specifications are printer-centric. Structure your model so that generated values can be easily printed (translated into input data of tested tool).
6. Do not use functions by default. Model your specification using dependent types first.
7. Do not hesitate to add auxiliary arguments to constructors. Even if they aren't needed for value generation, they can be used to pattern match on them later.
8. If this is your first time using DepTyCheck, you have to see [pil-fun](https://github.com/buzden/deptycheck/tree/master/examples/pil-fun) implementation for reference.
