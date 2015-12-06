// DOM element where the Timeline will be attached
var container = document.getElementById('visualization');

// Items array
 var items = new vis.DataSet({});
 var elemOnStage = 0;

// Animation variables
var run = true;
var runLive = false;


// Animation speed in ms per frame
var timeFrame = 100;

window.setInterval(function() {
	util.ajaxRequest({
  method: "GET",
  url: "flashPoint",
  successCallback: function(data) {

  	if (data.results.length > elemOnStage){
  		setData(data);	
  	} 
    
  },
  errorCallback: function(e) {
    console.log("There is an error" + e);
  }
})
	console.log("New call");
}, 1000);

function setData(data) {  
  

  for(var i = elemOnStage; i<data.results.length; i++){

  	switch( data.results[i].flashPointType){
  		case 0:
  			items.add( {id:i, description: data.results[i].flashPointDescription, start: data.results[i].flashPointDate.iso, flashType: 0} );
  			break;

  		case 1:
  			items.add( {id:i, description: data.results[i].flashPointDescription, image: data.results[i].image.url ,start: data.results[i].flashPointDate.iso, flashType: 1} );
  			break;

  		case 2:
  			items.add( {id:i, description: data.results[i].flashPointDescription, video: data.results[i].video.url ,start: data.results[i].flashPointDate.iso, flashType: 2} );
  			break;
  	}
  }

  elemOnStage = data.results.length;
  console.log(elemOnStage);

  // Configuration for the Timeline
  dataSetOptions = {
  	width: '100%',
  	height: '700px',
  	configure: false,
  	stack: true,

  	template: function (item) {

    var html;
    
    switch( item.flashType ){

    	case 0:
    		html = '<div class="type0">'
    				+
    				item.description
    				+
    				'</div>';
    		break;

    	case 1:
    		html = '<div class="type1">'
    				+
    					'<img class="image" src="'+item.image+'"></img>'
    				+
    					'<br>'
    				+
    					item.description
    				+
    				'</div>';
    		break;

    	case 2:
    		html = '<div class="type2">'
    				
    				+
    					'<video class="video" width = "320" height = "240" autoplay muted>'
    				+
    					'<source src="'+item.video+'" type="video/mp4">'
    				+
    					'</video>'
    				+
    					'<br>'
    				+
    					item.description
    				+
    				'</div>';
    			break;
    }
    //console.log(item);
    return html;
  }
  };

  // Create a Timeline
  
  var timeline = new vis.Timeline(container, items, dataSetOptions);

  // Buttons

  document.getElementById('play').onclick = function() {
  	run = true;
  };

  document.getElementById('stop').onclick = function() {
  	run = false;
  	runLive = false;
  };

  document.getElementById('live').onclick = function() {
  	runLive = true;
  };


	
	// Animate the darn thing
	window.setInterval(function() {


		// Animate only if there's something to animate
		if (elemOnStage > 0 ){
			var d = new Date();

			// If live:
			if (runLive == true){

				// First go there FAST
				timeline.moveTo(d.getTime(), {animation: false});

				timeline.moveTo(d.getTime(), {duration:100, easingFunction:"linear"});

			// Not live but playing	
			} else if (run == true){


				timeline.setWindow(timeline.getWindow().start.getTime() + 30000, timeline.getWindow().end.getTime() + 30000, {});
				

			} else if (run == false){

				// Stopped, let the people move it

			}

		}


	}, timeFrame);

}