var number
var deleted = 0

function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1) + min);
}

document.getElementById('back').addEventListener('click', function() {
    $(".container :nth-child(" + (number - deleted) + ")").fadeOut()
    deleted = deleted + 1
});


document.getElementById('add').addEventListener('click', function() {
    deleted = 0
    number = $(".container").children().length + 1
    var randomColor = Math.floor(Math.random() * 16777215).toString(16)
    var offSet = number * 50;
    $(".container").append('<div id="p2" class="object"></div>');
    $('.container').each(function() {
        $(".container :nth-child(" + number + ")").css({
            'marginTop': getRandomInt(10, 300),
            'marginLeft': offSet,
            'background': '#' + randomColor
        });
        $(".container :nth-child(" + number + ")").fadeIn();
    });

}, false);

function moveTheElems() {
    var value = $('#range').val();
    var maxVal = 100;
    if (value < maxVal) {
        $('.object').each(function() {
            var curMargin = $(this).css("margin-left").replace("px", "");;
            var updatedMargin = curMargin - 10;
            $(this).css("marginLeft", updatedMargin);
        });
        value++;
        $('#range').val(value);
    }
}

var toggle;

function toggleAnimation() {
    if (!toggle) {
        toggle = window.setInterval(moveTheElems, 200);
    } else {
        window.clearInterval(toggle);
        toggle = null;
    }
}

$("#animate-on").click(function() {
    toggleAnimation();
});

var switchAnimationOn = function() {
    setInterval(moveTheElems, 200);
}

// var myVar = setInterval(moveTheElems, 200);

function stopInterval() {
    clearInterval(switchAnimationOn);
}

function changeOffset(rangeValue) {
    $('.object').each(function() {
        var curMargin = $(this).css("margin-left").replace("px", "");;
        var updatedMargin = curMargin - 10;
        $(this).css("marginLeft", updatedMargin);
    });
}