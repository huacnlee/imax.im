window.UrlDecoder =
  decode : (url) ->
    result = ["",""]
    switch url.split(":")[0]
      when "thunder"
        result = UrlDecoder.decode_thunder(url)
      when "magnet"
        result = UrlDecoder.decode_magnet(url)
      when "ed2k"
        result = UrlDecoder.decode_ed2k(url)
    return result
    
  decode_ed2k : (url) ->
    urls = url.split("|")
    if urls.length > 4
      filename = urls[2]
      file_size = Math.round((parseInt(urls[3]) / 1024 / 1024 / 1024) * 10) / 10
    return [decodeURIComponent(filename), file_size]
    
  decode_thunder : (url) ->
    return ["", ""]
    
  decode_magnet : (url) ->
    keys = url.split("?")[1].split("&")[0]
    return ["", ""]