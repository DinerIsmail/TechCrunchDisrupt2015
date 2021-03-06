// DOM element where the Timeline will be attached
var container = document.getElementById('visualization');
var timeline;
var exista = false;

// Items array
 items = new vis.DataSet({});
 var elemOnStage = 0;

// Animation variables
var runType = 2;
// runType mapping: 
// 0 - fast backwards
// 1 - play
// 2 - stop
// 3 - fast forwards
// 4 - live

var quickAnime = false;

// Animation speed in ms per frame
var timeFrame = 100;
var playSpeed = 1000;
var fastSpeed = playSpeed * 10 * 60;

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
	//console.log("New call");
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
  			items.add( {id:i, description: data.results[i].flashPointDescription, video: data.results[i].video.url ,start: data.results[i].flashPointDate.iso, initialTime: data.results[i].flashPointDate.iso, flashType: 2} );
  			break;
  	}
  }

  elemOnStage = data.results.length;

  console.log(elemOnStage);

  // Configuration for the Timeline
  var dataSetOptions = {
  	width: '100%',
  	height: '600px',
    maxHeight: '600px',
  	throttleRedraw: 1,
  	configure: false,
  	stack: true,
  	zoomMin: 60 * 1000,
  	zoomMax: 10 * 60 * 60 * 1000,
    //min: Date(items.get(0).start).getTime() - 30 * 60 * 1000,
  	moveable: false,


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
    					'<video id = "video' + item.id + '" class="video" width = "320" height = "240" muted>'
    				+
    					'<source src="'+ item.video +'" type="video/mp4">'
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
  
  
     
  if (exista == false){
    timeline = new vis.Timeline(container, items, dataSetOptions);
    exista = true;  
    console.log("timeline");
  }
  
  // Buttons

 document.getElementById('fastBack').onclick = function() {
  	runType = 0;
  };

  document.getElementById('play').onclick = function() {
  	runType = 1;
  };

  document.getElementById('stop').onclick = function() {
  	runType = 2;
  };

 document.getElementById('fastForwards').onclick = function() {
  	runType = 3;
  };

  document.getElementById('live').onclick = function() {
  	runType = 4;
  	quickAnime = true;
  	var tmpDate = new Date();
  };

  document.getElementById('fitAll').onclick = function() {
  	runType = 2;
  	timeline.fit({});
  };


  // Keep videos static
  function onRangeChange (properties) {

  	//console.log(properties.start.getTime());
  	//console.log(properties.end.getTime());

  	for (var index = 0; index < items.length; index++){
  		
  		// Check if video
  		if (items.get(index).flashType == 2){

  			// Check if it should be playing:
  			var tempTime = new Date(items.get(index).initialTime);

        var currentVideo = document.getElementById("video"+ index.toString());
       // console.log(currentVideo);

  			if (tempTime.getTime() > properties.start.getTime() && tempTime.getTime() < properties.end.getTime()){
  				
  				//items.update({id: index, start : (properties.end.getTime() - properties.start.getTime()) / 2 + properties.start.getTime()});
          

          

          var videoTime = (((properties.end.getTime() - properties.start.getTime()) / 2 + properties.start.getTime()) - tempTime.getTime()) / 1000;

          
          if (runType == 1 || runType == 4){

              // if the video should play just play it :D
              currentVideo.play();
          
          } 
          else 
                   // Check if videoTime doesn't exceed the video lenght
                    if (videoTime < currentVideo.duration && videoTime >= 0){

                      console.log(videoTime);

                      currentVideo.currentTime = videoTime;  

                    } 
                    else {

                        currentVideo.pause();

                    }

                 
         
          

  			   }
            else {

              // Just pause it
             //currentVideo.pause();
      				//items.update({id: index, start : items.get(index).initialTime});

  			}
  		}	
  	
  	}
  
  }


  // add event listener
  timeline.on('rangechange', onRangeChange);



	

	// Animate the darn thing
	window.setInterval(function() {


		// Animate only if there's something to animate
		if (elemOnStage > 0 ){
			var d = new Date();

			switch (runType){
				// fast backwards:
				case 0:

					// Don't let the user move it!
					timeline.setOptions({moveable: false});

					timeline.setWindow(timeline.getWindow().start.getTime() - fastSpeed, timeline.getWindow().end.getTime() - fastSpeed, {});

					break;

				// play:
				case 1:
					// Don't let the user move it!
					timeline.setOptions({moveable: false});

					timeline.setWindow(timeline.getWindow().start.getTime() + playSpeed, timeline.getWindow().end.getTime() + playSpeed, {});

					break;

				// stop:
				case 2:
					// Stopped, let the people move it
					timeline.setOptions({moveable: true});

					break;

				// fast forwards:
				case 3:
					// Don't let the user move it!
					timeline.setOptions({moveable: false});

					timeline.setWindow(timeline.getWindow().start.getTime() + fastSpeed, timeline.getWindow().end.getTime() + fastSpeed, {});

					break;

				// live:
				case 4:
					// Don't let the user move it!
					timeline.setOptions({moveable: true});

					// First go there FAST
					if (quickAnime == true){

						//console.log("dap");

						timeline.moveTo(d.getTime(), {animation: false});

						//timeline.setWindow (d.getTime() - 30 * 1000 , d.getTime() + 30 * 1000, {});

						timeline.setWindow (d.getTime() - 30 * 1000 , d.getTime() + 30 * 1000, {animated:false});

						quickAnime = false;	
					}
					

					timeline.moveTo(d.getTime(), {duration: 100, easingFunction:"linear"});

					break;

			}
		}


	}, timeFrame);

}