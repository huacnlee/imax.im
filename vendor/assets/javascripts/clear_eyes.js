if (document.cookie.indexOf('devicePixelRatio') == -1) {
  var ratio = (window.devicePixelRatio !== undefined ? window.devicePixelRatio : 1);
  document.cookie = 'devicePixelRatio=' + ratio + (document.cookie != "" ? "; " + document.cookie : "");
  if (ratio > 1) window.location.reload();
}