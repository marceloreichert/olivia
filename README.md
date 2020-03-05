# Olivia

Olivia is a bot orchestration framework built on Elixir/Phoenix.


### Interfaces Supported
- Facebook Messenger
- Your own WebApp with webhook
- Your own WebApp with socket


### Thinkers Supported
- IBM Watson Assistant
- Wit


### Let's start
1. `mix phx.new <project_name>`
2. `cd <project_name>`
3. Add `{:olivia, git: "https://github.com/marceloreichert/olivia.git", tag: "0.1"}` to mix.exs
4. `mix deps.get`
5. If you decide to use Facebook Messenger, add this webhook to router:

```
  pipeline :webhook_fb_messenger do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  scope "/chat/messenger", OliviaWeb.Chat do
    pipe_through :webhook_fb_messenger
    get "/", MessengerController, :verify
    post "/", MessengerController, :create
  end
```

7. If you decide to use your own WebApp with webhook, add this webhook to router:

```
  pipeline :webhook_webapp do
    plug :accepts, ["json"]
  end

  scope "/chat/webapp", OliviaWeb.Chat do
    pipe_through :webhook_webapp
    post "/", WebAppController, :create
  end
```

8. If you decide to use your own WebApp with channels, add socket config to endpoint:

```
  socket "/socket", OliviaWeb.UserSocket,
    websocket: true,
    longpoll: false
```

9. Add new file `/lib/<project_name>/orchestra.ex`

```
defmodule <ProjectName>.Orchestra do
  def run(impression) do
    impression
  end
end
```



### Config
1. dev.exs - Add at the bottom

```
import_config "dev.secret.exs"
```

2. dev.secret.exs - Add this lines and config as you wish

```
use Mix.Config

config :olivia,
  fb_page_recipient_id: "",
  fb_page_access_token: "",
  wit_server_access_token: "",
  watson_assistant_id: "",
  watson_assistant_token: "",
  watson_assistant_version: "",
  watson_assistant_url: "",
  default_nlp: :watson_assistant or :wit or :none,
  bot_name: <ProjectName>
```

### Run
```
mix ecto.create
mix phx.server
```

### JSON messages to send

```
{
  "user": {
    "name": "Some User Name",
    "uid": "XX123456ABC"
  },
  "text": "Hello"
}
```
#### Required
- `uid` Unique ID to represent your user.
- `text` Text from your app.

### Test your Chat

1. Configure and up your ngrok (http://ngrok.com)
2. Send a message

```
curl -X POST \
  https://<your_login>.ngrok.io/chat/webapp \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d '{
    "user": {
      "name": "Marcelo Reichert",
      "uid": "XX123456ABC"
    },
    "text": "Hello"
}
'
```

### TODO
1. Tests
2. Build user responder thinker. Respond without use Watson or Wit.
3. Interface Slack
