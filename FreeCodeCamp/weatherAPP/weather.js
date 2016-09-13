$(document).ready(function(){

  function check_for_geo(){
    // check to see if browser supports geolocation
    if('geolocation' in navigator){
      navigator.geolocation.getCurrentPosition(get_location, location_error);
    } else {
      $('.display').text("Your browser does not support Geolocation.");
    }
  }

  function get_location(position){
    // geolocation callback & call to API_Call()
    var latitude = position.coords.latitude;
    var longitude = position.coords.longitude;
    API_call(latitude, longitude, convert_temp, convert_time);
  }

  function location_error(errorObj){
    // geolocation error
    alert(errorObj.message);
  }

  // data manipulations
  function convert_temp(tempK){
    // converts API data (deg K) to deg F
    var fahr = tempK * (9 / 5) - 459.67;
    return Math.round(fahr);
  }

  function convert_time(time){
    // used for sunrise/sunset, but API data is off
    var date = new Date(time);
    return date.getHours() + ':' + date.getMinutes();
  }

  function c_to_f(tempC){
    var fahr = tempC * 1.8 + 32;
    return Math.round(fahr);
  }

  function f_to_c(tempF){
    var cent = (tempF - 32) / 1.8;
    return cent.toFixed(1);
  }

  // api called in get_location()
  function API_call(lat, long, temp, time){
    var key = "5c444bd5dc0ffc772bf5b32c7f511567";
    var owURL = "http://api.openweathermap.org/data/2.5/weather?lat=" +
      lat + "&lon=" + long + "&APPID=" + key;

    $.ajax({
      dataType: 'json',
      url: owURL,
      success: function(response){
        print_response_to_DOM(response, temp, time);
        check_conditions(response);
      }
    });
  }

  // DOM manipulations
  function print_response_to_DOM(ajaxResponse, temp, time){
    // temp & time are functions
    $('#cityName').text(ajaxResponse.name);
    $('#temp').html(temp(ajaxResponse.main.temp) + '&degF');
    $('#tempMin').text(temp(ajaxResponse.main.temp_min));
    $('#tempMax').text(temp(ajaxResponse.main.temp_max));
    $('#weatherDescription').text(ajaxResponse.weather[0].description);
    $('#sunrise').text(time(ajaxResponse.sys.sunrise));
    $('#sunset').text(time(ajaxResponse.sys.sunset));
    $('#switchDeg').attr('disabled', false);
  }

  function check_conditions(ajaxResponse){
    // change BG img to current conditions
    if(ajaxResponse.hasOwnProperty('snow')){
      $('.bgimg').css('background', 'url(http://imgur.com/AK8Wimp.jpg)');
    } else if(ajaxResponse.hasOwnProperty('rain')){
      $('.bgimg').css('background', 'url(http://imgur.com/k7Sbhtc.jpg)');
    } else if(ajaxResponse.hasOwnProperty('clouds')){
      $('.bgimg').css('background', 'url(http://imgur.com/a0CZLsl.jpg)');
    } else {
      $('.bgimg').css('background', 'url(http://imgur.com/N3lEbLN.jpg)');
    }
  }

  $('#switchDeg').on('click', function(){
    // changes deg button & updates DOM
    var $temp = parseFloat($('#temp').text());
    var $tempMin = $('#tempMin').text();
    var $tempMax = $('#tempMax').text();

    if($(this).text() === 'Celsius?'){
      $(this).text('Fahrenheit?');
      $('#temp').html(f_to_c($temp) + '&degC');
      $('#tempMin').text(f_to_c($tempMin));
      $('#tempMax').text(f_to_c($tempMax));
    } else if($(this).text() === 'Fahrenheit?'){
      $(this).text('Celsius?');
      $('#temp').html(c_to_f($temp) + '&degF');
      $('#tempMin').text(c_to_f($tempMin));
      $('#tempMax').text(c_to_f($tempMax));
    }
  });

  check_for_geo();

});
