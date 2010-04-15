
$(document).ready(function () {

	//transitions
	//for more transition, goto http://gsgd.co.uk/sandbox/jquery/easing/
	var style = 'easeOutExpo';
	var default_left = Math.round($('#menu li.selected').offset().left - $('#menu').offset().left);
	var default_top = $('#menu li.selected').height();

	//Set the default position and text for the tooltips
	$('#box').css({left: default_left, top: default_top});
	$('#box .head').html($('#menu li.selected').find('img').attr('alt'));

	//if mouseover the menu item
	$('#menu li').hover(function () {

		//get the left pos
		left = Math.round($(this).offset().left - $('#menu').offset().left);

		//Set it to current item position and text
		$('#box .head').html($(this).find('img').attr('alt'));
		$('#box').stop(false, true).animate({left: left},{duration:500, easing: style});


	//if user click on the menu
	}).click(function () {

		//reset the selected item
		$('#menu li').removeClass('selected');

		//select the current item
		$(this).addClass('selected');

	});

	//If the mouse leave the menu, reset the floating bar to the selected item
	$('#menu').mouseleave(function () {

		//get the left pos
		default_left = Math.round($('#menu li.selected').offset().left - $('#menu').offset().left);

		//Set it back to default position and text
		$('#box .head').html($('#menu li.selected').find('img').attr('alt'));
		$('#box').stop(false, true).animate({left: default_left},{duration:1500, easing: style});

	});

});

