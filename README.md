# Extreme DepTyChecking

The same domain task can be solved by using very different dependent types.
The ways to implement dependent types differ in how comfortable they are for a developer to write,
how fast DepTyCheck can **derive** a generator, and how fast that generator can **produce** values.

This repository presents design patterns representing these trade-offs,
featuring minimal examples, benchmarks, and some practical rules and debugging tips.
Also there are some examples of specification development details.

[https://l3odr0id.github.io/extreme_deptychecking/](https://l3odr0id.github.io/extreme_deptychecking/)

## Notes

All example types in this repo are sized to work with **fuel 4**, and all generators in this repo are run with fuel 4 by default.
Other fuel values are possible, but fuel 4 was chosen as a sensible default based on practical experience.
See the sources to understand how to declare generators for the types presented here and how to run them.

## Benchmarks

```bash
./scripts/run_benchmarks.sh                  # all packages
./scripts/run_benchmarks.sh 02_helper_type   # one package
```

Results are written under `results/` as JSON and summarized as tables (also into `$GITHUB_STEP_SUMMARY` in CI).
