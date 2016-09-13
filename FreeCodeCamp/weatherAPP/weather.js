// api key = 5c444bd5dc0ffc772bf5b32c7f511567
// lat 41.8487, long -87.8921
$(document).ready(function(){
  // data manipulation
  function convert_temp(tempK){
    var fahr = tempK * (9 / 5) - 459.67;
    return Math.round(fahr);
  }

  function convert_time(time){
    var date = new Date(time);
    return date.getHours() + ':' + date.getMinutes();
  }

  function get_location(position){
    var latitude = position.coords.latitude;
    var longitude = position.coords.longitude;
    API_call(latitude, longitude, convert_temp, convert_time);
  }

  function location_error(errorObj){
    alert(errorObj.message);
  }

  function API_call(lat, long, temp, time){
    //var cityData = {};
    var key = "5c444bd5dc0ffc772bf5b32c7f511567";
    var owURL = "http://api.openweathermap.org/data/2.5/weather?lat=" +
      lat + "&lon=" + long + "&APPID=" + key;

    $.ajax({
      dataType: 'json',
      url: owURL,
      success: function(response){
        $('#cityName').text(response.name);
        $('#temp').html(temp(response.main.temp) + '&degF');
        $('#tempMin').text(temp(response.main.temp_min));
        $('#tempMax').text(temp(response.main.temp_max));
        $('#weatherDescription').text(response.weather[0].description);
        $('#sunrise').text(time(response.sys.sunrise));
        $('#sunset').text(time(response.sys.sunset));
        $('#switchDeg').attr('disabled', false);
      }
    });
  }

  function check_for_geo(){
    if('geolocation' in navigator){
      navigator.geolocation.getCurrentPosition(get_location, location_error);
    } else {
      display.innerHTML = "Your browser does not support Geolocation.";
    }
  }

  // DOM manipulation
  function c_to_f(tempC){
    var fahr = tempC * 1.8 + 32;
    return Math.round(fahr);
  }
  function f_to_c(tempF){
    var cent = (tempF - 32) / 1.8;
    return cent.toFixed(1);
  }

  $('#switchDeg').on('click', function(){
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
