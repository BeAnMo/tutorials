function display_articles(){
	$('.article-list').html('');
	$('.article').html('');
	var $query = $('#textBox').val();
	var wikiURL = "https://en.wikipedia.org/w/api.php?action=opensearch&search="
				+ $query + "&format=json&formatversion=2&callback=wikiCallback";

	$.ajax({
		url: wikiURL,
		dataType: "jsonp",
		success: function(response){
			for(var x = 0; x < response[1].length; x++){
				console.log(response[3][x]);
				var description = response[2][x];
				if(description.length > 247){
					description = description.slice(0, 247) + '...';
				}
				$('.article-list').append('<div class="article"><h3><a href="' + response[3][x] + '">'
					+ response[1][x] + '</a></h3><p>' + description + '</p></div>');
			}
		}
	});

	return false;
}

$('#search-form').submit(display_articles);
