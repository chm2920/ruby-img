var crop = {
	init: function(){
		this.show_pic = $('#show_pic')[0];
		this.preview_pic = $('#preview_pic')[0];
		
		this.showInfo();
		this.bind();
	},
	showInfo: function(){		
		var sw = this.show_pic.naturalWidth
			, sh = this.show_pic.naturalHeight
			, pw = this.preview_pic.naturalWidth
			, ph = this.preview_pic.naturalHeight
			, w = this.preview_pic.width
			, h = this.preview_pic.height
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
		var self = this;
		$("#mask").mousewheel(function(e, t) {
			e.preventDefault();
			e.stopPropagation();
		    var n = t > 0 ? "Up" : "Down"
		    	, w = parseInt($('#ipt_w').val(), 10)
		    	, h = parseInt($('#ipt_h').val(), 10)
		    	, cw = $(this).width()
		    	, ch = $(this).height()
		    	, hw = parseInt($('#ipt_height').val(), 10) / parseInt($('#ipt_width').val(), 10)
		    	, nw = self.preview_pic.naturalWidth;
		    if(n == "Up"){
		    	if(w == nw / 4){
		    		return;
		    	}
		    	w = w - 10;
		    } else {
		    	if(w == nw){
		    		return;
		    	}
		    	w = w + 10;
		    }
	    	h = w * hw;
	    	cw = w * self.showScale;
	    	ch = cw * hw;
		    $('#mask').css({
				'width': cw + 'px',
				'height': ch + 'px'
			});
			$('#mask_i').html(w + ' x ' + h);
			$('#ipt_w').val(w);
			$('#ipt_h').val(h);
		});
		$('#ipt_width').change(function(){
			self.resize();
		});
		$('#ipt_height').change(function(){
			self.resize();
		});
	},
	resize: function(){
		var h = parseInt($('#ipt_height').val(), 10)
			, w = parseInt($('#ipt_width').val(), 10)
			, hw = h /w;
		
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