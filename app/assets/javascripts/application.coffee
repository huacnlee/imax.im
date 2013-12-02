#= require jquery
#= require jquery_ujs
#= require jquery.autocomplete
#= require jquery.timeago
#= require jquery.timeago.settings
#= require jquery.atwho
#= require bootstrap
#= require will_paginate
#= require homeland
#= require clear_eyes
#= require social-share-button
#= require_tree
#= require_self
window.App =
  completeLineMovie : (data) ->
    html = ""
    if data[2] != ""
      html += "<div class='cover'><img src='#{data[2]}' /></div>"
    year = ""
    if data[3] != ""
      year = "<abbr>(#{data[3]})</abbr>"
    html += "<div class='info'><a href=\"/movies/#{data[1]}\">#{data[0]}</a>#{year}<br />#{data[4]}</div>"
    html

  completeMovies : (el) ->
    hash =
      minChars: 1
      delay: 50
      width: 350
      scroll : false
      formatItem : (data, i, total) ->
        return App.completeLineMovie(data)
    $(el).autocomplete("#{SETTING_API_URL}/api/movies/search",hash).result (e, data, formatted) ->
      location.href = "/movies/#{data[1]}"
      return false

  loading : (show = false) ->
    console.log("loading...")

  reloadCaptcha : (el) ->
    imgbox = $(el).prev()
    imgbox.attr("src","#{imgbox.attr("src")}&t=#{Math.random()}")
    false

$(document).ready ->
  $('.dropdown-toggle').dropdown()
  $("abbr.timeago").timeago()
  $("a[rel=twipsy]").tooltip()
  opts =
    transitionIn  : 'fade'
    speedIn : 150
    speedOut : 150
    transitionOut : 'none'
    overlayShow : false
    hideOnContentClick : true
  App.completeMovies('.navbar-search input.search-query')
