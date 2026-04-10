# Changelog

All notable changes to **fastcma** (PyPI: [`fast-cmaes`](https://pypi.org/project/fast-cmaes/)) are documented here.

Entries are grouped by tagged release (newest first). Each section links to the GitHub compare view. Individual commits use full-hash links.
Tags are lightweight -- no GitHub Releases exist; all versions are published to PyPI only.

Repository: <https://github.com/Dicklesworthstone/fast_cmaes>

---

## [Unreleased](https://github.com/Dicklesworthstone/fast_cmaes/compare/v0.1.4...main)

Large post-0.1.4 development phase spanning 2025-11-22 through 2026-02-22. This body of work transforms fastcma from a Python-only optimization package into a multi-language platform with C/C++ FFI, advanced restart strategies, constraint handling primitives, noise-aware optimization, and the option to use the Rust core without any Python dependency.

### Optimization Engine

- **BIPOP parallel restarts** -- population restart strategy with helpers for IPOP (increasing population) and BIPOP (alternating large/small populations) that escape local minima on multi-modal landscapes ([`d10f769`](https://github.com/Dicklesworthstone/fast_cmaes/commit/d10f769038e3a55ea1cb77218b83167aa521adb4))
- **Noise-aware CMA mode** -- detects stagnation from noisy fitness evaluations, temporarily expands step size with a cooldown to prevent oscillation; includes noisy Rastrigin benchmark ([`a247bb7`](https://github.com/Dicklesworthstone/fast_cmaes/commit/a247bb71125cd15adb102972f8639adb13079803))
- **Constraint helpers** -- reject/resample loop with configurable retry limit and augmented-Lagrangian penalty function for nonlinear constraint satisfaction ([`29bbcf0`](https://github.com/Dicklesworthstone/fast_cmaes/commit/29bbcf0fef24c8b3959cde9a0bdbd7b0c4d00149))
- **SIMD clamp and mirror boundaries** -- box-constraint enforcement via SIMD-accelerated clamping plus optional mirror-reflection that folds out-of-bounds points back into the feasible region ([`5e87a00`](https://github.com/Dicklesworthstone/fast_cmaes/commit/5e87a003745e1b3ea36cd99aa68aa79f46102956))
- **Enhanced FFI interface** -- improved C interoperability in `ffi.rs` and refined optimization algorithms in core library ([`1edb1a4`](https://github.com/Dicklesworthstone/fast_cmaes/commit/1edb1a446f8ee0ea1f0b26fce6d61ec3a171d2a0))

### C/C++ FFI & Integration

- **Minimal C ABI** -- `fastcma.h` / `fastcma.hpp` headers exposing `fastcma_sphere()` and `fastcma_version()` via `cdylib` crate type ([`09f9e2b`](https://github.com/Dicklesworthstone/fast_cmaes/commit/09f9e2ba8b309d61c7939253658b168badb3853f))
- **Version from crate metadata** -- `fastcma_version()` returns the version string derived at compile time from `Cargo.toml` ([`f10953d`](https://github.com/Dicklesworthstone/fast_cmaes/commit/f10953dc2240988c50983eea496b9aa92313807c))
- **FastAPI REST example** -- `examples/api_server.py` accepts a JSON body (`x0`, `sigma`, `maxfevals`) and returns `xmin` / `fbest` ([`a0a1097`](https://github.com/Dicklesworthstone/fast_cmaes/commit/a0a1097828518f9f3ad4e3870ce96dd6f00eb533))

### Pure-Rust Library Mode

- **Optional `python` feature gate** -- PyO3 bindings moved behind `features = ["python"]` (on by default); disabling it yields a pure-Rust `rlib` with zero Python linkage, enabling downstream Rust crates to consume `fastcma` as a library ([`17f633e`](https://github.com/Dicklesworthstone/fast_cmaes/commit/17f633e2c24bdd0c358310949066e5922b9e17b5))

### Testing & Benchmarks

- **Hard benchmark suite** -- 20 classic tough functions (Zakharov, Levy, Dixon-Price, Powell, Styblinski-Tang, Bohachevsky, Bukin6, Dropwave, and more) with seeded, higher-dimensional configurations ([`8d954cc`](https://github.com/Dicklesworthstone/fast_cmaes/commit/8d954cc777c625c172101be22318742f016651a1))
- **Very-hard suite on CI** -- ~20 additional high-dimensional/fractal/ill-conditioned cases (Katsuura, Weierstrass, HappyCat, Expanded Schaffer F6/F7, 30D Rastrigin/Ackley/Elliptic, etc.) running on GitHub Actions with relaxed Salomon tolerance ([`8dbce59`](https://github.com/Dicklesworthstone/fast_cmaes/commit/8dbce5978ed465d9cf818371cbc5e455dd79b029))
- **Expanded hard benchmark coverage** -- +390 lines of rigorous optimization scenarios in `hard_benchmarks.rs` ([`1edb1a4`](https://github.com/Dicklesworthstone/fast_cmaes/commit/1edb1a446f8ee0ea1f0b26fce6d61ec3a171d2a0))
- Loosen Salomon hard-case tolerance to 0.4 ([`dc18a60`](https://github.com/Dicklesworthstone/fast_cmaes/commit/dc18a605c93e73d40af8795e5bdbbf1967dd7a96))
- API/FFI smoke tests and CI integration ([`2602912`](https://github.com/Dicklesworthstone/fast_cmaes/commit/2602912350371672cdcfcf7f522aff795b3199a5))

### CI / Infrastructure

- Replace deprecated `toolchain` action to eliminate `set-output` warnings ([`f23f3ff`](https://github.com/Dicklesworthstone/fast_cmaes/commit/f23f3ff88928e8be968d835978961f9c70943553))
- Merge PR #1: CI very-hard suite ([`22a01e0`](https://github.com/Dicklesworthstone/fast_cmaes/commit/22a01e0c88d51940fda6896a71496a647b592667))
- Cache cargo artifacts; document longer PR runtime ([`aeb7fb0`](https://github.com/Dicklesworthstone/fast_cmaes/commit/aeb7fb0e0fe6754af5c1e2069da40f31e8cf9f6b))
- Lite very-hard nightly job with build timings and sanitizers ([`ed890f1`](https://github.com/Dicklesworthstone/fast_cmaes/commit/ed890f1e0ec4735a5d21ab1ea036458e6fbfa489))
- Drop clippy component for macOS builds ([`e3917ea`](https://github.com/Dicklesworthstone/fast_cmaes/commit/e3917eaa333e37177652018a763d7e53b656f857))
- Remove `rustfmt` component to prevent toolchain conflict ([`ead491f`](https://github.com/Dicklesworthstone/fast_cmaes/commit/ead491fec0b105ebed865ae9732bb47940a02ff3))
- Enhance wheel building workflow for cross-platform compatibility ([`ebaf6db`](https://github.com/Dicklesworthstone/fast_cmaes/commit/ebaf6db1a2adc484f18ebb9a0577bc4070097114))

### Code Quality

- Standardize import ordering and collapse verbose conditionals ([`7c9584f`](https://github.com/Dicklesworthstone/fast_cmaes/commit/7c9584f1db549e4db5ad81d90df5e7b538b4aae5), [`5e16a36`](https://github.com/Dicklesworthstone/fast_cmaes/commit/5e16a361292d0ce51f0e9e118686492a4f066566))
- Clean up Python examples and tests: remove unused imports, refactor lambda to named function ([`92c06b5`](https://github.com/Dicklesworthstone/fast_cmaes/commit/92c06b59e0d39bac25535fca201056f39da8c6d9))
- Suppress `dead_code` warnings for internal API reserve surface ([`9406d5e`](https://github.com/Dicklesworthstone/fast_cmaes/commit/9406d5ec9512767106c9639628e30902ef7eae32))

### Documentation

- Comprehensive README overhaul: Mermaid architecture diagrams, LaTeX mathematical notation for all CMA-ES formulas (ask/tell, covariance update, step-size adaptation), detailed optimization strategy write-ups, and design-decision rationale ([`0f196de`](https://github.com/Dicklesworthstone/fast_cmaes/commit/0f196dedfd2527b8e6ce6af581c6ce0f8a6ee8c0) through [`e7ec348`](https://github.com/Dicklesworthstone/fast_cmaes/commit/e7ec34848f29c1c49e14384fa9572a69b5820bee) -- 13 refinement commits)
- Document FFI surface and FastAPI example in README ([`7bcf6d0`](https://github.com/Dicklesworthstone/fast_cmaes/commit/7bcf6d0b5329818667fe973e1e3df00f1364e414))
- Note Python linking requirements for C demo ([`a84ca17`](https://github.com/Dicklesworthstone/fast_cmaes/commit/a84ca170478cbac5225fc085d37a5af717576a04))
- Add dependency upgrade log ([`3f52ad5`](https://github.com/Dicklesworthstone/fast_cmaes/commit/3f52ad5ab1d5a75dcf134f4753dd17a8a82ac3e0))
- Update README license references to MIT + OpenAI/Anthropic Rider ([`e49787e`](https://github.com/Dicklesworthstone/fast_cmaes/commit/e49787e1ab5d6cb9a65aac0f21ddaf4cf4515301))

### Licensing & Metadata

- Update license to MIT with OpenAI/Anthropic Rider ([`4055a7d`](https://github.com/Dicklesworthstone/fast_cmaes/commit/4055a7d7beee08a795fb5a94485b907994906f21))
- Add standalone MIT License file ([`58e1c08`](https://github.com/Dicklesworthstone/fast_cmaes/commit/58e1c083423df14ba7f3c40679a8cd0805078c36))
- Add GitHub social preview image (1280x640) ([`c198642`](https://github.com/Dicklesworthstone/fast_cmaes/commit/c198642d437bb8ef309c9cf1714004f46682e90b))

---

## [v0.1.4](https://github.com/Dicklesworthstone/fast_cmaes/compare/v0.1.3...v0.1.4) -- 2025-11-21

Tagged at [`ee05bc6`](https://github.com/Dicklesworthstone/fast_cmaes/commit/ee05bc6f69c379dbe9f295a7fd6619b5cda22de5). Published to PyPI.

Focuses on Python 3.14 forward-compatibility and demo script polish.

### Compatibility

- Fix Python smoke test to not require baseline module; allow PyO3 forward-compatibility for Python 3.14 ([`97844bc`](https://github.com/Dicklesworthstone/fast_cmaes/commit/97844bc5df2c47b3ffe92ebac22e8ddc5e969237))

### Developer Experience

- Demo script cleans old wheels before rebuild; refresh `uv.lock` ([`bc41241`](https://github.com/Dicklesworthstone/fast_cmaes/commit/bc412412f4406b2bbc290c8e2aef0e353bffc181))
- Update Python version badge to reflect supported range ([`4174f1f`](https://github.com/Dicklesworthstone/fast_cmaes/commit/4174f1f4ac580cce2f46bad973d38655c0cba1fe))

---

## [v0.1.3](https://github.com/Dicklesworthstone/fast_cmaes/compare/v0.1.2...v0.1.3) -- 2025-11-21

Tagged at [`985a241`](https://github.com/Dicklesworthstone/fast_cmaes/commit/985a2417256c0ee65fbe882041cab7741f9c1ac7). Published to PyPI.

Single-commit hotfix for broken Python smoke test after v0.1.2.

### Bug Fix

- Fix Python smoke test; bump version to 0.1.3 ([`985a241`](https://github.com/Dicklesworthstone/fast_cmaes/commit/985a2417256c0ee65fbe882041cab7741f9c1ac7))

---

## [v0.1.2](https://github.com/Dicklesworthstone/fast_cmaes/compare/v0.1.1...v0.1.2) -- 2025-11-21

Tagged at [`a62a961`](https://github.com/Dicklesworthstone/fast_cmaes/commit/a62a961d2170cb07dc33b59d9095946d1b41cb67). Published to PyPI.

Fixes the packaging layout broken in v0.1.1 and adds the PyPI smoke-on-tag CI job.

### Packaging & Bug Fixes

- Fix `numpy_support` feature extraction; set `python-source` to `fastcma_baseline` so the pure-Python baseline installs correctly ([`a62a961`](https://github.com/Dicklesworthstone/fast_cmaes/commit/a62a961d2170cb07dc33b59d9095946d1b41cb67))
- Bump version to 0.1.2 for fixed packaging ([`8c5c7ed`](https://github.com/Dicklesworthstone/fast_cmaes/commit/8c5c7ed148557d36dc599456410271c96b120372))

### CI / Infrastructure

- Add demo job (uv setup script) and PyPI smoke test triggered on tags ([`99d73be`](https://github.com/Dicklesworthstone/fast_cmaes/commit/99d73bea6e69ee4e0f9e8828eacedcba5d86ce19))

### Documentation

- Highlight PyPI installation path and add badges to README ([`f413faf`](https://github.com/Dicklesworthstone/fast_cmaes/commit/f413fafa8f0b5b000719d552056c16af2b3af78c))
- Auto-install `uv` in one-shot demo script; mention script in README ([`ac951d1`](https://github.com/Dicklesworthstone/fast_cmaes/commit/ac951d139ab5c90fc3335340ff099d63656baf19))

---

## [v0.1.1](https://github.com/Dicklesworthstone/fast_cmaes/compare/v0.1.0...v0.1.1) -- 2025-11-21

Tagged at [`2baeea0`](https://github.com/Dicklesworthstone/fast_cmaes/commit/2baeea09b2b1eca272f0bebca09234ee48a5f307). Published to PyPI.

Fixes the broken wheel packaging from v0.1.0, adds the one-shot demo installer, and strengthens CI gating.

### Packaging & Bug Fixes

- Fix wheel packaging: remove shadow `python/` package that masked the Rust extension; introduce `fastcma_baseline` module; demo script clears stale venv ([`d909eb0`](https://github.com/Dicklesworthstone/fast_cmaes/commit/d909eb0a37dc10b8d1c57be840584c5d786f7eea))

### Developer Experience

- Add `setup_and_demo.sh` one-shot installer that provisions nightly Rust, creates a uv venv, builds the extension, and launches the Rich TUI demo ([`2a916c9`](https://github.com/Dicklesworthstone/fast_cmaes/commit/2a916c979a33e30bfaaef77f935ee791c2fd99a5))

### CI / Infrastructure

- Add `cargo test --all-features` gate before wheel builds to catch Rust-level regressions ([`29d8442`](https://github.com/Dicklesworthstone/fast_cmaes/commit/29d84426346f76c549c0d4f251e88d74739f7f83))
- Test default features plus `numpy_support`/`test_utils` (skip LAPACK to avoid Fortran dependency) ([`2baeea0`](https://github.com/Dicklesworthstone/fast_cmaes/commit/2baeea09b2b1eca272f0bebca09234ee48a5f307))

---

## [v0.1.0](https://github.com/Dicklesworthstone/fast_cmaes/compare/c323e57...v0.1.0) -- 2025-11-21

Tagged at [`1437d20`](https://github.com/Dicklesworthstone/fast_cmaes/commit/1437d20f88b976d9dd267fa7a28c6a6671b7d7ec). First PyPI release as `fast-cmaes` (module name: `fastcma`).

The initial release ships a complete CMA-ES optimizer written from scratch in Rust, exposed to Python through PyO3.

### Core Optimizer

- **Ask/tell interface** (`CmaesState`) -- generate candidate solutions from a multivariate normal distribution, evaluate them, and update the search distribution with rank-one and rank-mu covariance updates ([`c323e57`](https://github.com/Dicklesworthstone/fast_cmaes/commit/c323e5784c4943a14f8e120f2a63fb373082c5c2))
- **Full and diagonal covariance modes** -- full `n x n` covariance for correlated problems, diagonal `O(n)` mode for high-dimensional separable problems
- **SIMD-accelerated math** -- `portable_simd` with 4 f64 lanes (256-bit AVX on x86_64) for dot products, squared sums, and vector operations (~3-4x speedup)
- **Rayon parallelization** -- embarrassingly-parallel fitness evaluation via `par_iter()` and parallel covariance updates via `par_chunks_mut()` (near-linear scaling with cores)
- **Lazy eigensystem updates** -- defers expensive `O(n^3)` eigen decomposition with an adaptive gap, reducing decompositions 5-10x in typical runs
- **Deterministic seeding** -- `new_with_seed()` uses `StdRng::seed_from_u64()` for reproducible optimization trajectories
- **Robust eigenvalue handling** -- floor non-positive eigenvalues to 1e-20 to prevent sampling failures; guard `tell()` input length ([`b04d141`](https://github.com/Dicklesworthstone/fast_cmaes/commit/b04d14150e1ee9462a5602e1b6df481ee24f2adc))
- **NaN-safe sorting** -- NaN fitness values sort to the end instead of causing panics
- **Multiple termination criteria** -- max evaluations, target fitness, condition number, TolFun, TolX

### Python API

- `fmin()` -- one-liner optimization with sigma, maxfevals, ftarget
- `fmin_vec()` -- batch/vectorized evaluation interface
- `fmin_constrained()` -- box constraints with lower/upper bounds
- `fmin_restart()` -- IPOP/BIPOP restart strategies
- `CMAES` class -- full ask/tell control for custom workflows
- Pure-Python baseline (`fastcma_baseline.cma_es`, `benchmark_sphere`) for direct speed comparison

### Demos & Visualization

- Rich TUI streaming demo (`examples/rich_tui_demo.py`) showing live sigma, fbest, and evaluation count while minimizing Rosenbrock ([`03fae2f`](https://github.com/Dicklesworthstone/fast_cmaes/commit/03fae2f453a44bf57547da9b224be018e6a45c3e))
- Quick-start script and benchmarks (`examples/python_quickstart.py`, `examples/python_benchmarks.py`)

### CI / Infrastructure

- Tag-based PyPI publish matrix via GitHub Actions ([`1437d20`](https://github.com/Dicklesworthstone/fast_cmaes/commit/1437d20f88b976d9dd267fa7a28c6a6671b7d7ec))
- Wheel build matrix covering Python 3.12--3.14 on Linux, macOS, and Windows ([`f1a8f65`](https://github.com/Dicklesworthstone/fast_cmaes/commit/f1a8f656626bacdfbcc2c200f80b787af3538686))
- Integration benchmarks with fixed seeds: sphere, Rosenbrock, Rastrigin, Ackley, Schwefel, Griewank (`tests/benchmarks.rs`)

### Licensing

- Add MIT license ([`f1a8f65`](https://github.com/Dicklesworthstone/fast_cmaes/commit/f1a8f656626bacdfbcc2c200f80b787af3538686))
