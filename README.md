# rust-mipsel-builder

Build image for static Rust binaries on MIPS32r2 little-endian, soft-float
(MT7628 / MT7688 routers, OpenWrt `ramips/mt76x8`):

- musl-cross-make `mipsel-linux-muslsf` (GCC 9.4, musl 1.2.5,
  `--with-arch=mips32r2 --with-float=soft`) in `/opt/cross`
- Rust nightly with `rust-src`: `mipsel-unknown-linux-musl` is a tier-3
  target, so `std` is built with `-Z build-std`
- `/opt/unwind/libunwind.a` → GCC's `libgcc_eh.a` (Rust's musl targets link
  `-lunwind`)

Image: `ghcr.io/luke4oxnet/rust-mipsel-builder` (`latest`, and a pinned tag
per toolchain version, e.g. `mcm227df8-nightly-2026-10-15`), linux/amd64.

Project `.cargo/config.toml`:
```toml
[target.mipsel-unknown-linux-musl]
linker = "mipsel-linux-muslsf-gcc"
rustflags = ["-C", "target-feature=+crt-static", "-C", "link-self-contained=no", "-L", "/opt/unwind"]
```
Build:
```sh
cargo build --release -Z build-std=std,panic_abort --target mipsel-unknown-linux-musl
```
