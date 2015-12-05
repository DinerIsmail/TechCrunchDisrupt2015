util.ajaxRequest({
  method: "GET",
  url: "flashPoint",
  successCallback: function(data) {
    insertData(data);
  },
  errorCallback: function(e) {
    console.log("There is an error" + e);
  }
});

function insertData(data) {
	number = $(".container").children().length;
    console.log( number );
    console.log( data.results.length );
    var i;
	for( i = number; i < data.results.length; i++ ){

		switch( data.results[i].flashPointType){

			case 0:

				$(".container").append(

					'<div class="flashPointDiv template1" >'
					+
						data.results[i].flashPointDescription
					+
					'</div>'
				);
				break;

			case 1:

				$(".container").append(

						'<div class="flashPointDiv template2" >'
							+
								data.results[i].flashPointDescription
							+
							'<img src="' 
							+ 
								data.results[i].image.url 
							+ 
							'"></img>' 
							+
						'</div>'

					);
				break;

			case 2:

				$(".container").append(

					'<div class="flashPointDiv template3" >'
						+
						'<video autoplay muted>'
						+
  							'<source src="'+ data.results[i].video.url+'" type="video/mp4">'+
 						+ '</video>'		
						+
						'</div>'
				);
				break;


		}

		//setting x position

		var limit = data.results.length;

		var myDate = new Date( data.results[ limit-1 ].flashPointDate.iso )
		console.log( "!" + $(".container").children().length );

		for( i=0; i<limit; i++){
			var myDate1 = new Date( data.results[i].flashPointDate.iso );
			
			var distance = Math.round( ( myDate.getTime() - myDate1.getTime() )/100 );
			console.log("x: "+distance);
			$(".container :nth-child(" + i + ")").css({

					'MarginRight':distance +'cm'
			});
		}
		


	}
	console.log( $(".container").children().length );
}

// util.ajaxRequest({
//   method: "POST",
//   url: "",
//   data: {
//     // Data to send to API here
//   },
//   successCallback: function(data) {
//
//   },
//   errorCallback: function(e) {
//     console.log("There is an error" + e);
//   }
// });
