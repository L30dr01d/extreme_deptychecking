# Extreme DepTyChecking

The same domain task can be solved by using very different dependent types.
The ways to implement dependent types differ in how comfortable they are for a developer to write,
how fast DepTyCheck can **derive** a generator, and how fast that generator can **produce** values.

This repository presents design patterns representing these trade-offs,
featuring minimal examples, benchmarks, and some practical rules and debugging tips.

## Contents

- [Rules of Extreme DepTyChecking](https://l3odr0id.github.io/extreme_deptychecking/rules_of_extreme_deptychecking/)
- [Debugging tips](https://l3odr0id.github.io/extreme_deptychecking/debugging-tips/)
- Patterns
  - [00_safe_select — shrink the choice set before picking](https://l3odr0id.github.io/extreme_deptychecking/patterns/00_safe_select/)
  - [01_second_fuel — a `Nat` used like extra fuel](https://l3odr0id.github.io/extreme_deptychecking/patterns/01_second_fuel/)
  - [02_helper_type — use an additional utility type](https://l3odr0id.github.io/extreme_deptychecking/patterns/02_helper_type/)
  - [03_constructive_predicate — place predicate before `Fin` using only dependent types](https://l3odr0id.github.io/extreme_deptychecking/patterns/03_constructive_predicate/)
  - [04_unique_index — postpone unique values generation](https://l3odr0id.github.io/extreme_deptychecking/patterns/04_unique_index/)

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
