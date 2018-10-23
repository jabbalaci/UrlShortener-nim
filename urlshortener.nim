import httpclient
import json
import os
import rdstdin
import strformat
import strutils
import terminal
import uri

let
  ACCESS_TOKEN = os.getEnv("BITLY_ACCESS_TOKEN").strip
  SHORTEN_API_URL_TEMPLATE = &"https://api-ssl.bit.ly/v3/shorten?uri=$1&format=json&access_token={ACCESS_TOKEN}"
  EXPAND_API_URL_TEMPLATE = &"https://api-ssl.bit.ly/v3/expand?hash=$1&format=json&access_token={ACCESS_TOKEN}"
  client = newHttpClient()

proc inputExtra*(prompt: string = ""): string =
  # Read from stdin. Arrows also work, like in Bash.
  var line: string = ""
  let val = readLineFromStdin(prompt, line)    # line is modified
  if not val:
    raise newException(EOFError, "abort")
  line

func rchop*(s, sub: string): string =
  # Remove ``sub`` from the end of ``s``.
  if s.endsWith(sub):
    s[0 ..< ^sub.len]
  else:
    s

proc shorten(url: string): tuple[url: string, hash: string] =
  let
    url_api = SHORTEN_API_URL_TEMPLATE.format(url.encodeUrl)

  try:
    let
      response = client.getContent(url_api)
      parsed = parseJson(response)

    result = (parsed["data"]["url"].str, parsed["data"]["hash"].str)
  except:
    echo "Error: couldn't process the response from bit.ly"
    quit(1)

proc expand(hash: string): string =
  let
    url_api = EXPAND_API_URL_TEMPLATE.format(hash)

  try:
    let
      response = client.getContent(url_api)
      parsed = parseJson(response)
    result = parsed["data"]["expand"][0]["long_url"].str
  except:
    echo "Error: couldn't process the response from bit.ly"
    quit(1)

proc process(text: string) =
  let
    url = text
    (shortened, hash) = shorten(url)
  var
    expanded = expand(hash)

  if not url.endsWith('/') and expanded.endsWith('/'):
    expanded = expanded.rchop("/")

  system.addQuitProc(resetAttributes)
  setStyle({styleBright})    # bold

  setForegroundColor(fgYellow); echo shortened
  resetAttributes(); stdout.write &"# expanded from shortened URL: {expanded} "
  setStyle({styleBright})    # bold
  if expanded == url:
    setForegroundColor(fgGreen); echo "(matches)"
  else:
    setForegroundColor(fgRed); echo "(differs)"

# ############################################################################

when isMainModule:
  if ACCESS_TOKEN.len == 0:
    echo "Error: your bit.ly access token was not found"
    echo "Tip: put it in the environment variable called BITLY_ACCESS_TOKEN"
    echo "Tip: on the home page of bit.ly you can generate one for free"
    quit(1)
  # else
  if paramCount() > 0:
    process(paramStr(1))
  else:
    try:
      let text = inputExtra("Long URL: ").strip
      process(text)
    except:
      echo "abort."
      quit(1)
