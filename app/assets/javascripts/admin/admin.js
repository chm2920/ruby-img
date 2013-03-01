$('#dvNav li').hover(function(){
	$(this).addClass('nP-hover');
}, function(){
	$(this).removeClass('nP-hover');
}).click(function(){
	$('#dvNav li').removeClass('nP-selected');
	$(this).addClass('nP-selected');
	
	var lists = $('.navtree-list');
	lists.hide();
	lists.eq($(this).index()).show();
});


$('#navtree h4').click(function(){
	$(this).next('ul').slideToggle(200);
});
$('#navtree li a').click(function(){
	$('#navtree li a').removeClass('selected');
	$(this).addClass('selected');
	$('#navNote').html($(this).attr('title'));
});

$('#logo a').click(function(){
	$('#navNote').html('后台管理');
});
