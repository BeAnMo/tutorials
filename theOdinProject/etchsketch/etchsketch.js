
function sketch(){
	$('.square').remove();	
	var ask = prompt("Pick the number of squares per side");
		
	if(ask > 1 && ask < 101) {
		var size = $('.grid').width() / ask;
		for(var y = 0; y < ask; y++) {
			$('.grid').append('<div class="square"></div>');
			for(var x = 0; x < ask - 1; x++) {
				$('.grid').append('<div class="square"></div>');
			}
		}		
		$('.square').css('width', size);
		$('.square').css('height', size);
			
	} else {
		alert("You broke it!");
	}		
};
/* this ain't workin'
function clear(){
	var sq = document.getElementsByClassName('square');
	sq.remove();
}
*/

function standard() {	
	$('.square').mouseenter(function(){	
		$(this).css('background-color', '#202020');	
	});
};

/* neither is this...
function shaded() {	
	$('.square').mouseenter(function(){
		var opaque = $(this).css('opacity')
		$(this).css('opacity', 0.1, 'background-color', '#202020');
		if(opaque < 1){
			$(this).css('opacity', opaque + 0.1);
		}
	});
};
*/

function random() {	
	function random_num(){
		return Math.floor(Math.random() * 255);
	};
	$('.square').mouseenter(function(){	
		$(this).css('background-color', 'rgb('+random_num()+', '+random_num()+', '+random_num()+')');
	});
};
		

	