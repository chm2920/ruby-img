var crop = {
	init: function(){
		this.showInfo();
	},
	showInfo: function(){
		var show_pic = $('#show_pic')[0]
			, preview_pic = $('#preview_pic')[0];
		
		var sw = show_pic.naturalWidth
			, sh = show_pic.naturalHeight
			, pw = preview_pic.naturalWidth
			, ph = preview_pic.naturalHeight
			, w = preview_pic.width
			, h = preview_pic.height
			, l = this.exs[0]
			, t = this.exs[1]
			, cw = this.exs[2]
			, ch = this.exs[3];
			
		if(pw < w){
			return;
		}
		
		var scale = cw / sw;
			
		this.showScale = w / pw;
		var lS = l * this.showScale
			, tS = t * this.ShowScale
			, cwS = cw * this.showScale
			, chS = ch * this.showScale;
		
		$('#mask').css({
			'left': lS + 'px',
			'top': tS + 'px',
			'width': cwS + 'px',
			'height': chS + 'px'
		});
			
		$('#natural_i').html(sw + ' x ' + sh);
		$('#mask_i').html(cw + ' x ' + ch);		
		$('#preview_i').html(pw + ' x ' + ph);
	},
	
	bind: function(){
		$("#mask").mousewheel(function(e, t) {
		    var n = t > 0 ? "Up" : "Down";
		    if(n == "Up"){
		    	
		    } else {
		    	
		    }
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