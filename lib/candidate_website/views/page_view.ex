defmodule CandidateWebsite.PageView do
  use CandidateWebsite, :view

  @states File.read!("./lib/candidate_website/views/states.json") |> Poison.decode!()

  def fb_share, do: "/images/facebook.svg"
  def twitter_share, do: "/images/twitter.svg"

  def congress_or_senate(district),
    do:
      district
      |> String.split("-")
      |> List.last()
      |> congress_or_senate_from_bit()

  def congress_or_senate_from_bit("SN"), do: "Senate"
  def congress_or_senate_from_bit(_), do: "Congress"

  def human_district(district) do
    [abbrev, num] = String.split(district, "-")

    case num do
      "SN" -> @states[abbrev]
      _dnum -> @states[abbrev] <> " " <> num
    end
  end

  def state(district) do
    [abbrev, _num] = String.split(district, "-")
    @states[abbrev]
  end

  def csrf_token() do
    Plug.CSRFProtection.get_csrf_token()
  end

  def th_district(district) do
    [abbrev, num] = String.split(district, "-")

    if num == "SN" do
      "#{@states[abbrev]} Senate"
    else
      {last_num, _} = num |> String.last() |> Integer.parse()

      cond do
        num == 11 -> "#{num}th District of #{@states[abbrev]}"
        num == 12 -> "#{num}th District of #{@states[abbrev]}"
        num == 13 -> "#{num}th District of #{@states[abbrev]}"
        last_num == 1  -> "#{num}st District of #{@states[abbrev]}"
        last_num == 2 -> "#{num}nd District of #{@states[abbrev]}"
        last_num == 3 -> "#{num}rd District of #{@states[abbrev]}"
        true -> "#{num}th district of #{@states[abbrev]}"
      end
    end
  end

  def process_vol_options(opts) do
    opts
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn opt ->
      %{
        label: opt,
        name: opt |> String.downcase() |> String.replace(" ", "_")
      }
    end)
  end

  def facebook_share_url(url, fragment, share_text) do
    "https://www.facebook.com/sharer/sharer.php?u=" <>
      url <>
      "#" <>
      fragment <>
      "&t=" <>
      share_text
    |> URI.encode()
  end

  def twitter_share_url(url, fragment, share_text) do
    "https://twitter.com/intent/tweet?url=" <>
      url <>
      "#" <>
      fragment <>
      "&text=" <>
      truncate(share_text, length: 280)
    |> URI.encode()
  end

  def data_exists?(data) do
    !is_nil(data) && data != ""
  end

  def truncate(text, options \\ []) do
    len = options[:length] || 30
    omi = options[:omission] || "..."

    cond do
      !String.valid?(text) ->
        text

      String.length(text) < len ->
        text

      true ->
        len_with_omi = len - String.length(omi)

        stop =
        if options[:separator] do
          rindex(text, options[:separator], len_with_omi) || len_with_omi
        else
          len_with_omi
        end

        "#{String.slice(text, 0, stop)}#{omi}"
    end
  end

  defp rindex(text, str, offset) do
    text =
    if offset do
      String.slice(text, 0, offset)
    else
      text
    end

    revesed = text |> String.reverse()
    matchword = String.reverse(str)

    case :binary.match(revesed, matchword) do
      {at, strlen} ->
        String.length(text) - at - strlen

      :nomatch ->
        nil
    end
  end
end
