FROM haskell:9.6 AS builder

WORKDIR /app

COPY lunch.cabal .
RUN cabal update && cabal build --only-dependencies

COPY . .
RUN cabal build exe:lunch && \
    cp $(cabal list-bin exe:lunch) /app/lunch-bin

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgmp10 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/lunch-bin /app/lunch

EXPOSE 8080
CMD ["/app/lunch"]
