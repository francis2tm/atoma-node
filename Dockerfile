# Builder stage
FROM --platform=$BUILDPLATFORM rust:1.76-slim-bullseye AS builder

# Add platform-specific arguments
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETARCH

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    curl \
    libssl-dev \
    libssl1.1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/atoma-node

COPY . .

ENV OPENSSL_DIR=/usr/lib/aarch64-linux-gnu
ENV OPENSSL_LIB_DIR=/usr/lib/aarch64-linux-gnu
ENV OPENSSL_INCLUDE_DIR=/usr/include/aarch64-linux-gnu

# Compile
RUN RUST_LOG=debug cargo build --release --bin atoma-node

# Final stage
FROM --platform=$TARGETPLATFORM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl1.1 \
    libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create necessary directories
RUN mkdir -p /app/data /app/logs

# Copy the built binary from builder stage
COPY --from=builder /usr/src/atoma-node/target/release/atoma-node /usr/local/bin/atoma-node

# Copy configuration file
COPY config.toml ./config.toml

RUN chmod +x /usr/local/bin/atoma-node

# Copy and set up entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/atoma-node", "--config-path", "/app/config.toml"]
