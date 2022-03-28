defmodule CryptoBot.Service.CoinService do
  alias CryptoBot.Market.Coin
  alias CryptoBot.Market.Consumer

  @url Application.get_env(:crypto_bot, CryptoBot.CryptoBotController)[:graph_url] <>
         "?access_token=#{Application.get_env(:crypto_bot, CryptoBot.CryptoBotController)[:app_access_token]}"
  @coin_gecko_url Application.get_env(:crypto_bot, CryptoBot.CryptoBotController)[
                    :coin_gecko_url
                  ]
  @coin_gecko_list_url @coin_gecko_url <> "coins/list"
  @default_headers [{"Content-type", "application/json"}]

  def send_replies(params) do
    refresh_coin_list()

    sender_id =
      params
      |> get_in(["sender", "id"])

    quick_reply_payload =
      params
      |> get_in(["message", "quick_reply", "payload"])

    text =
      params
      |> get_in(["message", "text"])

    process_payload(sender_id, text, quick_reply_payload)
  end

  def process_payload(sender_id, text, payload) when is_nil(payload) do
    user = Consumer.get_user_by(sender_id)

    if user do
      send_search_replies(sender_id, text, user)
    else
      Consumer.create_user(%{id: sender_id, state: "initial"})
      send_quick_replies(sender_id)
    end
  end

  def process_payload(sender_id, text, "start_over") do
    send_quick_replies(sender_id)
  end

  def process_payload(sender_id, _text, "search_coin_by_name") do
    user = Consumer.get_user_by(sender_id)

    if user do
      user
      |> Consumer.update_user(%{id: user.id, state: "search_coin_by_name"})
    else
      Consumer.create_user(%{id: sender_id, state: "search_coin_by_name"})
    end

    send_message(sender_id, "Please enter text to search by 'name'")
  end

  def process_payload(sender_id, _text, "search_coin_by_id") do
    user = Consumer.get_user_by(sender_id)

    if user do
      user
      |> Consumer.update_user(%{id: user.id, state: "search_coin_by_id"})
    else
      Consumer.create_user(%{id: sender_id, state: "search_coin_by_id"})
    end

    send_message(sender_id, "Please enter text to search by 'id'")
  end

  def process_payload(sender_id, _text, coin_data) do
    data =
      String.replace(coin_data, "get_data-", "")
      |> get_coin_data()

    user = Consumer.get_user_by(sender_id)

    user
    |> Consumer.update_user(%{id: user.id, state: "initial"})

    send_message(sender_id, data)
  end

  def send_message(sender_id, message) do
    url =
      "https://graph.facebook.com/v13.0/me/messages?access_token=#{Application.get_env(:crypto_bot, CryptoBot.CryptoBotController)[:app_access_token]}"

    body = %{messaging_type: "RESPONSE", recipient: %{id: sender_id}, message: %{text: message}}
    headers = [{"Content-type", "application/json"}]
    HTTPoison.post(url, Jason.encode!(body), headers)
  end

  def send_response_message(
        sender_id,
        elements,
        template_type \\ "generic",
        headers \\ @default_headers
      ) do
    body = %{
      messaging_type: "RESPONSE",
      recipient: %{id: sender_id},
      message: %{
        attachment: %{
          type: "template",
          payload: %{
            template_type: template_type,
            elements: elements
          }
        }
      }
    }

    HTTPoison.post(@url, Jason.encode!(body), headers)
  end

  def send_quick_replies(sender_id, headers \\ @default_headers) do
    body = %{
      messaging_type: "RESPONSE",
      recipient: %{id: sender_id},
      message: %{
        text: "Search coins by name or by ID (Coins ID)",
        quick_replies: [
          %{
            content_type: "text",
            title: "By Name",
            payload: "search_coin_by_name"
          },
          %{
            content_type: "text",
            title: "By Id",
            payload: "search_coin_by_id"
          }
        ]
      }
    }

    HTTPoison.post(@url, Jason.encode!(body), headers)
  end

  def send_custom_quick_replies(sender_id, text, replies, headers \\ @default_headers) do
    body = %{
      messaging_type: "RESPONSE",
      recipient: %{id: sender_id},
      message: %{
        text: text,
        quick_replies: replies
      }
    }

    HTTPoison.post(@url, Jason.encode!(body), headers)
  end

  def send_search_replies(sender_id, search_text, %{state: "search_coin_by_name"} = _user) do
    elements =
      Coin.search_by(:name, search_text)
      |> Enum.map(fn x ->
        prepare_quick_reply_element(x)
      end)

    if Enum.empty?(elements) do
      send_custom_quick_replies(sender_id, "No, records found for your search", [
        prepare_start_over_quick_reply_element()
      ])
    else
      send_custom_quick_replies(
        sender_id,
        "Search Results, pick one to get the data",
        elements ++ [prepare_start_over_quick_reply_element()]
      )
    end
  end

  def send_search_replies(sender_id, search_text, %{state: "search_coin_by_id"} = _user) do
    elements =
      Coin.search_by(:id, search_text)
      |> Enum.map(fn x ->
        prepare_quick_reply_element(x)
      end)

    if Enum.empty?(elements) do
      send_custom_quick_replies(sender_id, "No, records found for your search", [
        prepare_start_over_quick_reply_element()
      ])
    else
      send_custom_quick_replies(
        sender_id,
        "Search Results, pick one to get the data",
        elements ++ [prepare_start_over_quick_reply_element()]
      )
    end
  end

  def send_search_replies(sender_id, _search_text, %{state: "initial"}) do
    send_quick_replies(sender_id)
  end

  def prepare_search_element(element) do
    %{
      title: element.name,
      buttons: [
        %{
          type: "postback",
          title: "Get Data",
          payload: "get_data-" <> element.id
        }
      ]
    }
  end

  def prepare_quick_reply_element(element) do
    %{
      content_type: "text",
      title: element.name,
      payload: "get_data-" <> element.id
    }
  end

  def prepare_start_over_quick_reply_element() do
    %{
      content_type: "text",
      title: "Start over again",
      payload: "start_over"
    }
  end

  def refresh_coin_list() do
    today = Date.utc_today()

    data_inserted_at = Coin.data_inserted_at()

    data_inserted_date = (data_inserted_at || DateTime.utc_now()) |> DateTime.to_date()

    date_diff = Date.diff(today, data_inserted_date)

    if date_diff > 0 || is_nil(data_inserted_at) || true do
      {:ok, response} = HTTPoison.get(@coin_gecko_list_url)
      Coin.delete_all()

      inserted_at = DateTime.utc_now() |> DateTime.truncate(:second)

      {:ok, coins} =
        response.body
        |> Jason.decode()

      coins
      |> Enum.map(fn x ->
        %{id: x["id"], name: x["name"], symbol: x["symbol"], inserted_at: inserted_at}
      end)
      |> Coin.insert_all()
    end
  end

  def get_coin_data(coin_id) do
    url =
      @coin_gecko_url <> "coins/#{coin_id}/market_chart?vs_currency=usd&days=14&interval=daily"

    {:ok, response} = HTTPoison.get(url)

    {:ok, data} =
      response.body
      |> Jason.decode()

    data["prices"]
    |> Enum.map(fn x ->
      " Dated " <>
        (x |> hd |> DateTime.from_unix(:millisecond) |> elem(1) |> Date.to_string()) <>
        " has price in $" <> Float.to_string(x |> List.last())
    end)
    |> Enum.join(", ")
  end
end
