var crop = {
	init: function(){
		var show_pic = $('#show_pic')[0]
			, preview_pic = $('#preview_pic')[0];
		
		var sw = show_pic.naturalWidth
			, sh = show_pic.naturalHeight
			, pw = preview_pic.naturalWidth
			, ph = preview_pic.naturalHeight
			, w = preview_pic.width
			, h = preview_pic.height
			, l = this.exs[0]
			, t = this.exs[1];
		
		var arr = this.scale.split('-');
		var scale = arr[1] / arr[0]
			, cw = parseInt(sw * scale, 10)
			, ch = parseInt(sh * scale, 10);
		if(arr[2] == 'x'){
			var showScale = w / arr[1];
		} else {
			var showScale = h / arr[1];
		};
		var cwS = cw * showScale
			, chS = ch * showScale;
		
		$('#mask').css({
			'left': l + 'px',
			'top': t + 'px',
			'width': cwS + 'px',
			'height': chS + 'px'
		});
			
		$('#natural_i').html(sw + ' x ' + sh);
		$('#mask_i').html(cw + ' x ' + ch);		
		$('#preview_i').html(pw + ' x ' + ph);
	},
	
	bind: function(){
		$("#mask").mousewheel(function(e, t) {
		    var n = t > 0 ? "Up" : "Down", r = parseInt($("#timelist").css("top"));
		    return n == "Up" ? $("#timelist").css({top: r + 20 + "px"}) : $("#timelist").css({top: r - 20 + "px"})
		});
	}	
};


$(document).ready(function(){	
	$(document).imagesLoaded({
	    done: function ($images) {
	    	crop.init();
	    },
	    fail: function ($images, $proper, $broken) {},
	    always: function () {},
	    progress: function (isBroken, $images, $proper, $broken) {}
	});
});