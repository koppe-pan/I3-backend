import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :iserver, IserverWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "o79uAtshehf+fc4V4FFC/8xn4Bie2NdytWqKwdGB8Eqe2H0y02a2OZqs9Tx7onLW",
  server: false

# In test we don't send emails.
config :iserver, Iserver.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
