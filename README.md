# Iserver

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# What I did on server side
- `UserSupervisor` は `User` プロセスを作成する。`User` は以下の`struct`を持つ。
```
{ id: ""
, name: ""
, muted: true
, camera_on: false
, raising_hand: false
, volume: 100
, room: "lobby"
}
```
- `RoomSupervisor` は `Room` プロセスを作成する。
## `WebSocket`
- はじめのハンドシェイク時には以下の`join`関数が呼ばれる。この際に上記の2プロセスを作成する。
```
def join("room:" <> room_id, %{user_id: user_id}, socket) do
  socket =
    socket
    |> get_or_create_user(user_id)
    |> get_or_create_room(room_id)

  {:ok, %{me: socket.assigns.me, room: socket.assigns.room}, socket}
end
```
- `WebSocket`でのやりとりは以降`send`関数が呼ばれる。
  - `endpoint`として`ip_address:4000/socket`に以下が生やされている
    - `/ice` : ice 情報を全体にbroadcastする
    - `/room` : room の情報を返す
    - `/close` : 退室処理などを行う
    - `/description` : description 情報を全体にbroadcastする
