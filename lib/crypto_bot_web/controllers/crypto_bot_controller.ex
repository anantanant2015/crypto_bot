defmodule CryptoBotWeb.CryptoBotController do
  use CryptoBotWeb, :controller
  alias CryptoBot.Service.CoinService

  def webhook(
        conn,
        %{"hub.mode" => mode, "hub.verify_token" => token, "hub.challenge" => challenge} = params
      ) do
    verify_token =
      Application.get_env(:crypto_bot, CryptoBot.CryptoBotController)[:app_verify_token]

    if mode == "subscribe" and token == verify_token do
      send_resp(conn, 200, challenge)
    else
      send_resp(conn, 403, "Unauthorized")
    end
  end

  def webhook(conn, _params) do
    send_resp(conn, 403, "Unauthorized")
  end

  def incoming_message(conn, %{"entry" => entries, "object" => "page"} = params) do
    Enum.each(entries, fn entry ->
      entry["messaging"]
      |> hd
      |> CoinService.send_replies()
    end)

    send_resp(conn, 200, "EVENT_RECEIVED")
  end
end
