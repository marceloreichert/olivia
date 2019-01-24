use Mix.Config

config :olivia, OliviaWeb.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn

config :olivia, :fb_messenger_dispatcher, Olivia.FbMessenger.Dispatcher.Mock
config :olivia, :nlp, Olivia.NLPMock

config :olivia, :bots, [
  BotMock
]
