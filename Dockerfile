# Cross toolchain for the x7fox (MT7628, MIPS 24KEc, little-endian, soft-float):
# musl-cross-make mipsel-linux-muslsf + Rust nightly with rust-src (the
# mipsel-unknown-linux-musl target is tier 3, so std is built with -Z build-std).
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential ca-certificates curl git wget xz-utils bzip2 rsync file \
    && rm -rf /var/lib/apt/lists/*

ARG MCM_SHA=227df8b99103f9c59f6570babf892978e293082f
RUN git clone -q https://github.com/richfelker/musl-cross-make.git /mcm \
    && cd /mcm && git checkout -q "$MCM_SHA" \
    && printf '%s\n' \
        'TARGET = mipsel-linux-muslsf' \
        'OUTPUT = /opt/cross' \
        'GCC_CONFIG += --with-arch=mips32r2 --with-float=soft --enable-languages=c' \
        'COMMON_CONFIG += --disable-nls CFLAGS="-O2 -g0" CXXFLAGS="-O2 -g0"' \
        > config.mak \
    && make -j"$(nproc)" >/tmp/mcm.log 2>&1 || (tail -50 /tmp/mcm.log; exit 1) \
    && make install >/dev/null \
    && cd / && rm -rf /mcm /tmp/mcm.log
ENV PATH=/opt/cross/bin:/root/.cargo/bin:$PATH

# Rust's musl targets link -lunwind; GCC's libgcc_eh provides the same _Unwind_* ABI.
RUN mkdir -p /opt/unwind \
    && ln -s "$(mipsel-linux-muslsf-gcc -print-file-name=libgcc_eh.a)" /opt/unwind/libunwind.a

ARG RUST_NIGHTLY=nightly-2026-10-15
RUN curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal \
        --default-toolchain "$RUST_NIGHTLY" --component rust-src

WORKDIR /src
