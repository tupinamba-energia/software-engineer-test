FROM elixir:1.19 AS build

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
COPY config ./config

RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get --only prod
RUN mix deps.compile

COPY lib ./lib
COPY priv ./priv

RUN mix compile
RUN mix release

FROM debian:trixie-slim AS runner

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates \
    libstdc++6 \
    openssl \
    ncurses-bin \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV MIX_ENV=prod
ENV PHX_SERVER=true
ENV LANG=C.UTF-8

COPY --from=build /app/_build/prod/rel/impression_click_api ./

EXPOSE 4000
CMD ["bin/impression_click_api", "start"]
