try
  navigator.geolocation.getCurrentPosition ({coords}) ->
    ajax = new XMLHttpRequest

    ajax.onreadystatechange = ->
      return unless ajax.readyState == 4

      if ajax.responseText.trim()
        document.getElementById('restos').innerHTML = ajax.responseText
      else
        document.getElementById('restos').innerHTML = '
          <p class="error">
            <span>We couldn’t find any food</span>
            <span>joint within 1000m, sorry.</span>
          </p>
        '

    ajax.open('GET', "/restos?location=#{coords.latitude},#{coords.longitude}", true)
    ajax.send()
  , ->
    alert 'There was a problem detecting your location, sorry.'
  , maximumAge: 60000

catch e
  alert 'Your browser doesn’t support geolocation, sorry.'
