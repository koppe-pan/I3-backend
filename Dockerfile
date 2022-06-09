FROM elixir:1.13-alpine

WORKDIR /app
COPY . .

RUN apk update
RUN apk add inotify-tools

RUN mix do local.hex --force, local.rebar --force, deps.get


CMD [ "mix", "phx.server" ]
EXPOSE 4000
