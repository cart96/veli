defmodule Veli.Validators.Format do
  @moduledoc """
  String format validator.
  
  ## Note
  Most of the format validation are done by using regex. Most of them are -> https://ihateregex.io/ <- taken from here.
  
  ## Atoms
  - `:email`: Email adress
  - `:url`: Url
  - `:slug`: Slug
  - `:ipv4`: IPv4
  - `:ipv6`: IPv6
  - `:ip`: both IPv4, IPv6
  - `:ascii`: ASCII
  - `:printable`: Printable ASCII
  - `:uuid`: UUID
  - `:mac`: MAC Adress
  - `:username`: Username
  - `:cc`: Credit Card
  - `:e164`: e.164 Phone Number Format
  - `:btcaddr`: Bitcoin Adress
  - `:semver`: Semantic Versioning
  
  ## Example
  
      rule = [type: :string, format: :url]
      Veli.valid("hello", rule) # not valid
      Veli.valid("https://x.org/", rule) # valid
  """

  @email_regex ~r/(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  @slug_regex ~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/
  @ipv4_regex ~r/(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}/
  @ipv6_regex ~r/(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/
  @ascii_regex ~r/^[\x00-\x7F]+$/
  @printable_regex ~r/^[\x20-\x7E]+$/
  @uuid_regex ~r/^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/
  @mac_regex ~r/^[a-fA-F0-9]{2}(:[a-fA-F0-9]{2}){5}$/
  @username_regex ~r/^[a-z0-9_-]+$/
  @cc_regex ~r/(^4[0-9]{12}(?:[0-9]{3})?$)|(^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$)|(3[47][0-9]{13})|(^3(?:0[0-5]|[68][0-9])[0-9]{11}$)|(^6(?:011|5[0-9]{2})[0-9]{12}$)|(^(?:2131|1800|35\d{3})\d{11}$)/
  @e164_regex ~r/^\+[1-9]\d{1,14}$/
  @btcaddr_regex ~r/^(bc1|[13])[a-zA-HJ-NP-Z0-9]{25,39}$/
  @semver_regex ~r/^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$/

  @spec valid?(binary, boolean) :: boolean
  def valid?(value, :email) when is_binary(value) do
    Regex.match?(@email_regex, value)
  end

  def valid?(value, :url) when is_binary(value) do
    uri = URI.parse(value)
    not is_nil(uri.scheme) and not is_nil(uri.host) and uri.host =~ "."
  end

  def valid?(value, :slug) when is_binary(value) do
    Regex.match?(@slug_regex, value)
  end

  def valid?(value, :ipv4) when is_binary(value) do
    Regex.match?(@ipv4_regex, value)
  end

  def valid?(value, :ipv6) when is_binary(value) do
    Regex.match?(@ipv6_regex, value)
  end

  def valid?(value, :ip) when is_binary(value) do
    Regex.match?(@ipv4_regex, value) or Regex.match?(@ipv6_regex, value)
  end

  def valid?(value, :ascii) when is_binary(value) do
    Regex.match?(@ascii_regex, value)
  end

  def valid?(value, :printable) when is_binary(value) do
    Regex.match?(@printable_regex, value)
  end

  def valid?(value, :uuid) when is_binary(value) do
    Regex.match?(@uuid_regex, value)
  end

  def valid?(value, :mac) when is_binary(value) do
    Regex.match?(@mac_regex, value)
  end

  def valid?(value, :username) when is_binary(value) do
    Regex.match?(@username_regex, value)
  end

  def valid?(value, :cc) when is_binary(value) do
    Regex.match?(@cc_regex, value)
  end

  def valid?(value, :e164) when is_binary(value) do
    Regex.match?(@e164_regex, value)
  end

  def valid?(value, :btcaddr) when is_binary(value) do
    Regex.match?(@btcaddr_regex, value)
  end

  def valid?(value, :semver) when is_binary(value) do
    Regex.match?(@semver_regex, value)
  end

  def valid?(_value, _rule) do
    false
  end
end
