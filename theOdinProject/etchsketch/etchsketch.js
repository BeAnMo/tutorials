
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

		function options(style) {	
			$('.square').mouseenter(function(){	
				switch(style) {
					case 1: 
						$(this).css('background-color', '#202020');
						break;
					case 2:
						var opaque = $(this).css('opacity');
						
						break;
					case 3:
						function random(){
							return Math.floor(Math.random() * 255);
						};
						$(this).css('background-color', 'rgb('+random()+', '+random()+', '+random()+')');
						break;
				};		
		});
		}
	
		

	