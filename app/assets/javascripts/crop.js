var crop = {
	init: function(){
		this.show_pic = $('#show_pic')[0];
		this.preview_pic = $('#preview_pic')[0];
		
		// this.sw = this.show_pic.naturalWidth;
		// this.sh = this.show_pic.naturalHeight;
		this.pw = this.preview_pic.naturalWidth;
		this.ph = this.preview_pic.naturalHeight;
		
		this.sw = this.preview_pic.width;
		this.sh = this.preview_pic.height;
		
		this.l = parseInt(this.exs[0], 10);
		this.t = parseInt(this.exs[1], 10);
		
		this.cw = parseInt(this.exs[2], 10);
		this.ch = parseInt(this.exs[3], 10);
		
		this.showScale = this.sw / this.pw;
		
		this.showInfo();
		this.bind();
	},
	showInfo: function(){
		// 上传的图 宽 小于400px
		if(this.pw < this.w){
			return;
		}			
		
		var lS = this.l * this.showScale
			, tS = this.t * this.showScale
			, cwS = this.cw * this.showScale
			, chS = this.ch * this.showScale;
		
		$('#mask').css({
			'left': lS + 'px',
			'top': tS + 'px',
			'width': cwS + 'px',
			'height': chS + 'px'
		});
			
		$('#natural_i').html(this.cw + ' x ' + this.ch);
		$('#mask_i').html(this.cw + ' x ' + this.ch);
		$('#preview_i').html(this.pw + ' x ' + this.ph);
	},
	
	bind: function(){
		var self = this;
		$("#mask").mousewheel(function(e, t) {
			e.preventDefault();
			e.stopPropagation();
		    var n = t > 0 ? "Up" : "Down"
		    	, hw = parseInt($('#ipt_height').val(), 10) / parseInt($('#ipt_width').val(), 10)
		    	, w = parseInt($('#ipt_w').val(), 10)
		    	, h = parseInt($('#ipt_h').val(), 10);
		    if(n == "Up"){
		    	if(w <= self.pw / 4){
		    		return;
		    	} else {
		    		w = w - 10;
		    	}
		    } else {
		    	if(w > self.pw - 10 || h > self.ph - 10){
		    		return;
		    	} else {
		    		w = w + 10;
		    	}
		    }
	    	h = w * hw;
	    	var cw = w * self.showScale
	    		, ch = cw * hw;
		    $('#mask').css({
				'width': cw + 'px',
				'height': ch + 'px'
			});
			$('#mask_i').html(w + ' x ' + h);
			$('#ipt_w').val(w);
			$('#ipt_h').val(h);
		});
		
		$('#ipt_width, #ipt_height').change(function(){
			self.resize();
		});
		
		function mouseCoords(ev) {
            if (ev.pageX || ev.pageY) {
                return {
                    x: ev.pageX,
                    y: ev.pageY
                }
            }
            return {
                x: ev.clientX + document.body.scrollLeft - document.body.clientLeft,
                y: ev.clientY + document.body.scrollTop - document.body.clientTop
            }
        }
        
		$("#mask").mousedown(function (e) {
            e.stopPropagation();
            e.preventDefault();
            
            var mc = mouseCoords(e)
                , p = $("#mask").offset()
                , l = mc.x - p.left - parseInt($('#mask').css('left'), 10)
                , t = mc.y - p.top - parseInt($('#mask').css('top'), 10);
                
                console.log(p.left);
                    
            $(document).mousemove(function (e) {
                e.stopPropagation();
                e.preventDefault();
                var mc = mouseCoords(e)
                    , ml = mc.x - l - p.left
                    , mt = mc.y - t - p.top
                    , max_l = self.sw - parseInt($('#mask').width(), 10)
                    , max_t = self.sh - parseInt($('#mask').height(), 10);
                
                if(ml < 0){
                	ml = 0
                }
                if(mt < 0){
                	mt = 0
                }
                
                if(ml > max_l){
                	ml = max_l;
                }                
                if(mt > max_t){
                	mt = max_t;
                }
                $("#mask").css({
                    'left': ml + 'px',
                    'top': mt + 'px'
                });
            });
            $(document).mouseup(function (e) {  
            	$('#ipt_x').val(parseInt($('#mask').css('left'), 10) / self.showScale);
            	$('#ipt_y').val(parseInt($('#mask').css('top'), 10) / self.showScale);           
                $(document).unbind('mousemove').unbind('mouseup');
            });
        });
	},
	resize: function(){
		var w = parseInt($('#ipt_w').val(), 10)
			, h = parseInt($('#ipt_h').val(), 10)
			, sw = parseInt($('#ipt_width').val(), 10)
			, sh = parseInt($('#ipt_height').val(), 10);
		
		var rw, rh;
		rw = sw * h / sh;
		rh = sh * w / sw;
		if(rw > this.pw){
			h = sh * w / sw;
		} else {
			w = sw * h / sh;
		}
		
		if(w % 10 != 0){
			w = w - w % 10;
			h = w * sh / sw;
		}
		
		var cw = w * this.showScale
    		, ch = cw * sh / sw;
		$('#mask').css({
			'width': cw + 'px',
			'height': ch + 'px'
		});
		$('#ipt_w').val(w);
		$('#ipt_h').val(h)
		$('#mask_i').html(w + ' x ' + h);
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