var crop = {
	init: function(){
		var show_pic = $('#show_pic')[0]
			, natural_i = $('#natural_i')[0]
			, preview_pic = $('#preview_pic')[0];
		
		var sw = show_pic.naturalWidth
			, sh = show_pic.naturalHeight
			, pw = preview_pic.naturalWidth
			, ph = preview_pic.naturalHeight
			, w = preview_pic.width
			, h = preview_pic.height
			, scale = w / pw;
			
		natural_i.innerHTML = sw + ' x ' + sh;
		
		if(sw * scale > w){
			$('#mask').css({
				'left': '0px',
				'top': '0px',
				'width': w + 'px',
				'height': h + 'px'
			});
		} else {
			$('#mask').css({
				'left': ((pw - sw) / 2) * scale + 'px',
				'top': ((ph - sh) / 2) * scale + 'px',
				'width': sw * scale + 'px',
				'height': sh * scale + 'px'
			});
		}
			
		$('#mask_i').html(sw + ' x ' + sh);
		
		$('#preview_i').html(pw + ' x ' + ph);
	},
	
	bind: function(){
		$("#mask").mousewheel(function(e, t) {
		    var n = t > 0 ? "Up" : "Down", r = parseInt($("#timelist").css("top"));
		    return n == "Up" ? $("#timelist").css({top: r + 20 + "px"}) : $("#timelist").css({top: r - 20 + "px"}), !1
		});
	}	
};


$(document).ready(function(){
	
	crop.init();
	
});