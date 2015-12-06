var number = 0;
var deleted = 0;
var containerWidth = 2000; //px

function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1) + min);
}

function moveTheElems() {
    var value = $('#range').val();
    var maxVal = 100;
    if (value < maxVal) {
        $('.object').each(function() {
            var curMargin = $(this).css("margin-left").replace("px", "");;
            var updatedMargin = curMargin - 40;
            $(this).css("marginLeft", updatedMargin);
            console.log(initialPositions);
        });
        value++;
        $('#range').val(value);
    }
}

var toggle;

function toggleAnimation() {
    if (!toggle) {
        toggle = window.setInterval(moveTheElems, 10);
        //change the intercal val to change the fps
    } else {
        window.clearInterval(toggle);
        toggle = null;
    }
}

$("#animate-on").click(function() {
    //toggleAnimation();
    //setOffSet(100);
});

var switchAnimationOn = function() {
    setInterval(moveTheElems, 200);
}

function stopInterval() {
    clearInterval(switchAnimationOn);
}

function setOffSet(rangeOffSetValue) {
    $('.input-range').val(rangeOffSetValue);
}

function changeOffset(rangeValue) {
    console.log(rangeValue);
    $('.object').each(function() {
        var initialOffSet = initialPositions[$(this).index()];
        console.log(initialOffSet);
        var curMargin = $(this).css("margin-left").replace("px", "");;
        var updatedMargin = curMargin - 10;
        $(this).css("marginLeft", updatedMargin);
    });
}

var range = $('.input-range'),
    value = $('.range-value');
    
value.html(range.attr('value'));

range.on('input', function(){
    value.html(this.value);
}); 