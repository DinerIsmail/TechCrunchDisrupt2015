var number
var deleted = 0
function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1) + min);
}

document.getElementById('back').addEventListener('click', function() {
    $(".container :nth-child("+ (number-deleted) +")").fadeOut()
    deleted = deleted + 1
});


document.getElementById('add').addEventListener('click', function() {
   deleted = 0
   number = $(".container").children().length+1
   var randomColor = Math.floor(Math.random()*16777215).toString(16)
   var offSet = number * 50;
   $(".container").append('<div id="p2" class="object"></div>')
   $('.container').each(function(){
    	$( ".container :nth-child("+ number +")" ).css(
            {'marginTop' : getRandomInt(10,300),
             'marginLeft': offSet,
             'background': '#' + randomColor
            });
   	var i;
    var blurvalue;
	for (i = 0; i <=number; i++) {
        blurvalue = (number-i)/3;
        $( ".container :nth-child("+ i +")" ).css(
    		{
          '-webkit-filter' : "blur("+ blurvalue +"px)"
        });
	}
    $(".container :nth-child("+ number +")").fadeIn();
});

}, false);

function moveTheElems() {
  $('.object').each(function() {
    var curMargin = $(this).css("margin-left");
    var updatedMargin = curMargin - 50;
    console.log(updatedMargin);
    $(this).css("marginLeft", updatedMargin);
  });
}

$( "#animate" ).click(function() {
  setInterval(moveTheElems(), 1000);
  // setInterval(function(){console.log('hi')}, 1000);
  console.log('clicked');
});