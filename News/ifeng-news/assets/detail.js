var cropper,
	FIRSTFONT,
	SCREEN_WIDTH,
    IMAGE_PLACEHOLDER_WIDTH,
    IMAGE_PLACEHOLDER_HEIGHT,
    PLACEHOLDER_SLOPE = 174 / 294, // 标准框比例  
    CONTENT_PADDING = 40, // 两侧空白区域
    //图片广告比例
    ADV_SLOPE = 90 / 640,
    //顶部大图比例
    TOP_BANNER_SLOPE = 530/720,
	imgQuene = [],
	VOTEDATA,//投票数据
	delatHeight = 0,
    loadMode,
	FONTS={                                                              
        'smaller'  : 0,  
        'small'    : 1,
        'mid'      : 2,
        'big'      : 3,
        'bigger'   : 4,
        'biggest'  : 5,
    };

// 监听 deviceready 事件 执行 init 方法初始化逻辑
window.addEventListener('deviceready', init, false);

// 初始化所有业务逻辑
function init(e) {  

    loadMode = ifeng.is2g3gloadMode();
    SCREEN_WIDTH = e.clientWidth;
    IMAGE_PLACEHOLDER_WIDTH = e.clientWidth - CONTENT_PADDING;
    IMAGE_PLACEHOLDER_HEIGHT = Math.round(IMAGE_PLACEHOLDER_WIDTH
        * PLACEHOLDER_SLOPE);
    cropper = new ImageCropper(new StandPlaceholderCropStrategy(
        IMAGE_PLACEHOLDER_WIDTH));

    // 确定图片区域大小（图集和视频底图使用默认高度）
    try {
        var sheet = document.getElementsByTagName('link')[0].sheet;
        sheet.insertRule('.content .video {min-height:' + IMAGE_PLACEHOLDER_HEIGHT
            + 'px}');
        sheet.insertRule('.content .slide {min-height:' + IMAGE_PLACEHOLDER_HEIGHT
            + 'px}');
    } catch (e) {
        ifeng.reload(datas.getDocumentId());
        return false;
    }

    // 写入标题
    document.getElementById('title').innerHTML = datas.getTitle();

    // 写入来源 大于6字 去掉时间时分部分
    var sourceText = datas.getSource(),
        sourceEl = document.getElementById('source'),
        sliceIndex = -3;
    if (sourceText && sourceText !== '未知') {
        if(sourceText.length > 6) sliceIndex = -9;
        sourceEl.innerHTML = sourceText.substring(0, 10);
    } else {
        sourceEl.style.display = 'none';
    }

    // 写入时间
    document.getElementById('time').innerHTML = datas.getEditTime().replace(
        /-/g, '/').slice(0, sliceIndex);

    // 设置大小字体
    setFontSize(datas.getFontSize());

    // 处理图片后 填充正文内容
    preprocessImage(formatText(datas.getText()),
        document.getElementById('content'));
	
	
	
    //初始化顶部banner图
	initTopBanner(datas);

    // 初始化相关新闻
    initRelativeNews();

    // 加载文字链广告
    Ground.loadAdv01(datas.getDocumentId(), initAdv01, null);
	
	// 加载新增文字链广告
    Ground.loadAdv02(datas.getDocumentId(), initAdv02, null);
//    //加载图片广告
    Ground.loadAdv2(datas.getDocumentId(), initAdv2, null);
	
	//加载投票信息
	Ground.loadVote(buildVote, loadSurvey);
	
    // 加载评论数据
    var commentsUrl = datas.getCommentsUrl() || datas.getWwwurl();
    Ground.getHotComments(commentsUrl, datas.getDocumentId(), initComment, null);

    // 点击进评论页的2个入口
    document.getElementById('comment_count_btn').onclick = function(){
        ifeng.showCommentsView(datas.getDocumentId())};
    document.getElementById('comment_more_btn').onclick = function(){
        ifeng.showCommentsView(datas.getDocumentId())};

}

// 设置正文字体
function setFontSize(fs) {
    var cdom = document.getElementById('content');
    if(fs){
    	if(FIRSTFONT){
    		var offset = FONTS[fs] - FONTS[FIRSTFONT];
       		var spans = document.getElementsByName('content_span');
   			for(var i=0; i<spans.length; i++){
    			var spanClass = spans[i].getAttribute('class');
    			for(var font in FONTS){
    				if(FONTS[font] == FONTS[spanClass]+offset){
    					spans[i].setAttribute('class', font);
    				}
    			}
    		}
		}
		FIRSTFONT = fs;
        cdom.className = 'content ' + fs;
//        console.log(cdom.innerHTML);
    }
}

// 显示相关新闻
function initRelativeNews() {
	
    // 数据判断
	var relationData = datas.getRelationsData();
    if (!relationData
        || Object.prototype.toString.call(relationData) !== '[object String]') {       
        return false;
    }
    var relativeNewsData = JSON.parse(relationData),list = document.getElementById('news-list'),content='';
    
    //组装相关新闻数据
    if (relativeNewsData && relativeNewsData.length) {
		for(var i = relativeNewsData.length-1 ; i > -1 ; i-- ){
	   		var relativeNewsSrc = '<li link-id="'+relativeNewsData[i].id+
	   			'" type="'+relativeNewsData[i].type+'" class="relative" url="'+relativeNewsData[i].url+
	   			'">'+relativeNewsData[i].title+'&nbsp'+
	   			'<img  src="'+relativeNewsData[i].src+'" />'+'</li>';
	   		content = relativeNewsSrc + content;
		   	}
	    }
	    list.innerHTML = content;
    
	    var relativeEls = list.getElementsByClassName('relative');
    	
	    // 相关新闻点击跳转
    	for(var i = 0 ; i < relativeEls.length ; i++){
    		relativeEls[i].onclick = function() {
    			var type = this.getAttribute('type');
	            console.log('click type '+type);
	            if(type == 'slide' ){
	            	ifeng.jump('slide', this.getAttribute('link-id'));
	            }else {
	            	ifeng.jump('doc', this.getAttribute('link-id'));
	            }
	        };
   		}
	    
    document.getElementById('relativeNewsPanel').style.display = 'block';
}

//根据指定字号计算字符所占宽度
function textSize(text) {
    var span = document.createElement("span");
    var result = {};
    result.width = span.offsetWidth;
    result.height = span.offsetWidth; 
    span.style.visibility = "hidden";
    span.className = 'adv';
    document.body.appendChild(span);
    if (typeof span.textContent != "undefined")
        span.textContent = text;
    else span.innerText = text;
    result.width = span.offsetWidth - result.width;
    result.height = span.offsetHeight - result.height;
    span.parentNode.removeChild(span);
    return result;
}

// 初始化文字链广告
function initAdv01(advData) {
    var advJson, advEl, itemEl, ITEM_FONT_SIZE = 20, itemFontAmount, doubleByteChars;
	ITEM_FONT_SIZE = textSize("凤").width // detail_page.html 中定义文字链广告字号大小为18px
    if (!advData
        || Object.prototype.toString.call(advData) !== '[object String]') {
        return false;
    }
    advEl = document.getElementById('adv01');
    itemEl = document.getElementById('advItem01');
    try {
    	//java中encode会将空格替换成+号，所以js在decode的时候需要先将+替换成空格
        advJson = JSON.parse(decodeURIComponent(advData.replace(/\+/g,'%20')));
        itemFontAmount = Math.floor(IMAGE_PLACEHOLDER_WIDTH / ITEM_FONT_SIZE);
        doubleByteChars = advJson.text.match(/[^\x00-\xff]/ig);
//		console.log('adv:--- text=' + advJson.text + 'ITEM_FONT_SIZE=' + ITEM_FONT_SIZE + ', SCREEN_WIDTH=' + SCREEN_WIDTH + ', IMAGE_PLACEHOLDER_WIDTH=' + IMAGE_PLACEHOLDER_WIDTH + ', itemFontAmount=' + itemFontAmount + ', doubleByteChars=' + doubleByteChars);
        if (doubleByteChars && doubleByteChars.length) {
            itemFontAmount = Math.min(doubleByteChars.length, itemFontAmount) +
                2 * Math.max((itemFontAmount - doubleByteChars.length), 0);
        }
        
        itemEl.innerHTML = advJson.text.substr(0, itemFontAmount);

        document.getElementById('relativeNewsPanel').style.background = 'none';
        advEl.style.display = 'block';
        document.getElementById('adv_wrapper').style.display = 'block';
        advEl.onclick = function(e) {
            ifeng.jump(advJson.adAction.type, advJson.adAction.url);
        };
    } catch (e) {
        sendWebLog('Illegal json in adv data', decodeURIComponent(advData));
        console.log('Illegal json in adv data');
    }
}

// 初始新增化文字链广告
function initAdv02(advData) {
    var advJson, advEl, itemEl, ITEM_FONT_SIZE = 20, itemFontAmount, doubleByteChars;
	ITEM_FONT_SIZE = textSize("凤").width // detail_page.html 中定义文字链广告字号大小为18px
    if (!advData
        || Object.prototype.toString.call(advData) !== '[object String]') {
        return false;
    }
    advEl = document.getElementById('adv02');
    itemEl = document.getElementById('advItem02');
    try {
    	//java中encode会将空格替换成+号，所以js在decode的时候需要先将+替换成空格
        advJson = JSON.parse(decodeURIComponent(advData.replace(/\+/g,'%20')));
        itemFontAmount = Math.floor(IMAGE_PLACEHOLDER_WIDTH / ITEM_FONT_SIZE);
        doubleByteChars = advJson.text.match(/[^\x00-\xff]/ig);
//		console.log('adv:--- text=' + advJson.text + 'ITEM_FONT_SIZE=' + ITEM_FONT_SIZE + ', SCREEN_WIDTH=' + SCREEN_WIDTH + ', IMAGE_PLACEHOLDER_WIDTH=' + IMAGE_PLACEHOLDER_WIDTH + ', itemFontAmount=' + itemFontAmount + ', doubleByteChars=' + doubleByteChars);
        if (doubleByteChars && doubleByteChars.length) {
            itemFontAmount = Math.min(doubleByteChars.length, itemFontAmount) +
                2 * Math.max((itemFontAmount - doubleByteChars.length), 0);
        }
        
        itemEl.innerHTML = advJson.text.substr(0, itemFontAmount);

        document.getElementById('relativeNewsPanel').style.background = 'none';
        advEl.style.display = 'block';
        document.getElementById('adv_wrapper').style.display = 'block';
        advEl.onclick = function(e) {
            ifeng.jump(advJson.adAction.type, advJson.adAction.url);
        };
    } catch (e) {
        sendWebLog('Illegal json in adv data', decodeURIComponent(advData));
        console.log('Illegal json in adv data');
    }
}

//初始化顶部大图
function initTopBanner(datas) {		
	try {
		var imgPath = datas.getBtl().getPic();
		if (!imgPath||imgPath.length==0) {
		return false;
		}
		var topEl = document.getElementById('top-banner');
		topEl.style.height = topEl.style.minHeight = Math.round(SCREEN_WIDTH
				* TOP_BANNER_SLOPE)
				+ 'px';
		topEl.setAttribute('topElSrc',imgPath);
		topEl.style.display = 'block';
		topEl.innerHTML = '<span class="load-message">正在载入...</span>';
		Ground.loadImageDirectly(imgPath, null,
                                loadImageSuccessInterceptor(topEl),
                                loadImageFailInterceptor(topEl, imgPath), 'false');
		
		topEl.onclick = function() {
            var index, src, isLoaded, loadState;
            index = parseInt(this.getAttribute('index'));
            src = this.getAttribute('topElSrc');
            isLoaded = (this.className).indexOf('loaded') > -1;
			loadState = this.getAttribute('loadState');
		
           if(!isLoaded) {
          	  if(loadState=='loadFail'){
          	      	  //如果没有网络连接，直接提示无网络
				if(ifeng.checkNetWorkState() == 0) {
					return;
				}   		          		          	 	 
          	 	 if(loadMode == 1) {
          	 		this.style.backgroundImage = 'url(logo_loading.png)';
          	 	 } else {
					this.innerHTML = '<span class="load-message">正在载入...</span>';
				 } 
          	 	 this.setAttribute('loadState','loading');
          	 	 Ground.loadImageDirectly(imgPath, null,
                                loadImageSuccessInterceptor(topEl),
                                loadImageFailInterceptor(topEl, imgPath), 'forceLoad');
			  }
            }
        };
	} catch (e) {
	}
}

//初始化banner广告
function initAdv2(data) {	
	if (!data || Object.prototype.toString.call(data) !== '[object String]') {
		return false;
	}
	var advEl = document.getElementById('adv2'), advJson;
	try {
		advJson = JSON.parse(data);
		advEl.style.height = advEl.style.minHeight = Math.round(SCREEN_WIDTH
				* ADV_SLOPE)
				+ 'px';
		advEl.style.backgroundImage = 'url(' + advJson.imgPath + ')';
		advEl.style.display = 'block';
		advEl.onclick = function(e) {
			ifeng.jump(advJson.type, advJson.url);
		};
	} catch (e) {
		sendWebLog('Illegal json in adv data', decodeURIComponent(data));
	}
}
// 显示评论内容
function initComment(commentData) {
    var commentEl, commentCountEl, container,
        commentJson, commentNum, commentList, commentListLen, commentListItem,
        commentListHtml = '';
    if (!commentData || Object.prototype.toString.call(commentData) !== '[object String]') {
        return false;
    }

    try {  
    	//java中encode会将空格替换成+号，所以js在decode的时候需要先将+替换成空格       	
        commentJson = JSON.parse(decodeURIComponent(commentData.replace(/\+/g,'%20')));

        commentNum = commentJson.count || 0;
        commentList = commentJson.comments.hottest;
        commentListLen = Math.min(commentList.length, 5); // 截取5条
        
        commentCountEl = document.getElementById('comment_count_num');
        commentCountEl.innerHTML = commentNum;

        if(commentListLen === 0) {
            return false;
        }

        commentEl = document.getElementById('comment');
        container = document.getElementById('comment_list');

        for(var i = 0; i < commentListLen; i++ ) {
            commentListItem = commentList[i];
            commentListItem.userFace = commentListItem.userFace?commentListItem.userFace:'';
            commentListHtml += '' +
                '<li class="comment-item">' +
                '<div class="comment-item-left">' +
                '<img src="default_ava.png" commentImageSrc="'+commentListItem.userFace+'" class="comment-item-ava"/>' +
                '</div>' +
                '<div class="comment-item-right">' +
                '<div class="comment-item-title">凤凰网' + commentListItem.ip_from + '网友：</div>' +
                '<div class="comment-item-content">' + commentListItem.comment_contents + '</div>' +
                '</div>' +
                '</li>';
        }
        container.innerHTML = commentListHtml;       
        commentEl.style.display = 'block';
        setTimeout(function() {
        	 //加载评论头像
            var imgs = container.getElementsByTagName('img');
            for(var i=0;i<imgs.length;i++) {
            	var commentImageDom = imgs[i],commentImageSrc = commentImageDom.getAttribute('commentImageSrc');            	
            		if(commentImageSrc) { 
            			console.log("commentImageSrc:  "+ commentImageSrc);
            			Ground.loadImageDirectly(commentImageSrc, null,
                                loadImageSuccessInterceptor(commentImageDom, i),
                                loadImageFailInterceptor(commentImageDom, commentImageDom.getAttribute('commentImageSrc')), 'false');
            		}          	 
            }
		}, 100);
              
    } 
   catch (e) {
        sendWebLog('Illegal json in comment data', decodeURIComponent(commentData))
        console.log('Illegal json in comment data');
    }
}


// 修复p内套多个img 以及 p内有small标签
function formatText(text) {
    var fragment = document.createElement('div');
    fragment.innerHTML = text;
    var eles = Array.prototype.slice.call(fragment.getElementsByTagName('p'));
    for ( var i = 0; i < eles.length; i++) {
        var container = eles[i],
            imgs = Array.prototype.slice.call(container.getElementsByTagName('ifengimg'));

        if(container.getElementsByTagName('small').length === 1) {
        	container.className += ' img-note';
        }

        if (imgs.length < 2) {
            continue;
        }
        var frag = document.createDocumentFragment();
        for ( var j = 0; j < imgs.length; j++) {
            var p = document.createElement('p');
            p.appendChild(imgs[j]);
            frag.appendChild(p);
        }
        fragment.replaceChild(frag, container);
    }
    return fragment.innerHTML;
}

//得到图集的宽和高 如果有宽和高的话，需要重新设置min-height为返回的高
function getHeightRule() {
	var extraRule = '';
	if(arguments[0].thumbnailSize) {
		var width = arguments[0].thumbnailSize.width, height = arguments[0].thumbnailSize.height;
		if (width && height) {
			var minheight = 'min-height:'+cropper.getResult(width, height).height+'px';
			extraRule = 'style="'+minheight+'"';
		}
	}	
	return extraRule;
}

// 显示正文 处理图片显示底图 准备加载
function preprocessImage(content, container) {
 	var loadMessage = '';
         if(loadMode!=1) {
         	loadMessage = '<span class="load-message">正在载入...</span>';
         }
    var fragment = document.createElement('div');
    fragment.innerHTML = content;
    var imgEls = Array.prototype.slice.call(fragment.getElementsByTagName('ifengimg')), isFormat = true, imgInfo = datas.getImgJson();
    //如果传过来的json数据格式错误，使用默认底图
    if (!imgInfo || Object.prototype.toString.call(imgInfo) !== '[object String]') {
        isFormat = false;
    }  
	try {
		try{
			var imgObj = JSON.parse(imgInfo);
		} catch (e) {
		   imgObj = undefined;
		}
		for ( var i = 0; i < imgEls.length; i++) {
			var img = imgEls[i], parent = img.parentNode, placeholder = document
					.createElement('p');
			if (!img.getAttribute('src')) {
				continue;
			}
			
			placeholder.className = 'placeholder';
			placeholder.setAttribute('src', img.getAttribute('src'));
			placeholder.setAttribute('index', i);
			placeholder.setAttribute('loadState', 'loading');			
					
			//初始化默认底图的高（根据屏幕的宽和服务器传过来的高）
			if (isFormat&&imgObj&&imgObj[img.getAttribute('src')]) {
				var width = imgObj[img.getAttribute('src')].width, height = imgObj[img
						.getAttribute('src')].height;
				if (width && height) {
					result = cropper.getResult(width, height);
					placeholder.style.height = placeholder.style.minHeight = result.height
							+ 'px';
				} else {
					// 如果没有获取到高，就用默认高
					placeholder.style.height = placeholder.style.minHeight = IMAGE_PLACEHOLDER_HEIGHT
							+ 'px';
				}
			//	console.log(result.width+"-----"+result.height+"-----"+window.innerWidth);
			} else {
				// 如果没有获取到高，就用默认高
				placeholder.style.height = placeholder.style.minHeight = IMAGE_PLACEHOLDER_HEIGHT
						+ 'px';
			}
			placeholder.innerHTML= loadMessage;	
			parent.parentNode.replaceChild(placeholder, parent);
		}
    }catch (e){
        sendWebLog('text img error', datas.getText());
    }
    fragment = formatChild(fragment);
    var content = fragment.innerHTML;
 // 显示slide封面
    var slideData = datas.getExtSlidesJson();
     if(slideData
        && Object.prototype.toString.call(slideData) == '[object String]'){
         var extensionsData = JSON.parse(slideData);      
         for(var i = extensionsData.length-1; i > -1; i--) {
			    if (extensionsData[i].type == 'slide') {
			    	//图集定宽的规则		    	
				var slideStr = '<p class="slide" '+getHeightRule(extensionsData[i])+' slidesrc="'
						+ extensionsData[i].thumbnailpic
						+ '" src="'
						+ extensionsData[i].url + '">'+loadMessage+'</p>';
				//图集增加图注
				if(extensionsData[i].title) {
					slideStr = slideStr + '<p></p><small class="slide-small" style="margin-top:0px">'+extensionsData[i].title+'</small></p>' ;
				} 
      		 	content = slideStr + content;
    		}
   	 	}
   	}
     
     
    // 显示video封面
     var videoData = datas.getVideoJson();
     if(videoData && Object.prototype.toString.call(videoData) == '[object String]'){
    	var videos = JSON.parse(videoData)
    	for(var i = videos.length-1 ; i > -1 ; i-- ){
    		var videoStr = '<p class="video" '+getHeightRule(videos[i])+' imgsrc="'+videos[i].thumbnail+'" normalSrc="'+videos[i].video.Normal.src+'" HDSrc="'+videos[i].video.HD.src+'">'+loadMessage+'</p>';
    		content = videoStr + content;
    	}
    }
	
	// 显示视频直播liveStream封面
	var liveStreamData = datas.getLiveStreamJson();
	
	if(liveStreamData && Object.prototype.toString.call(liveStreamData) == '[object String]'){
    	var liveStream = JSON.parse(liveStreamData);
		var liveStreamStr = '<p class="video" '+getHeightRule(liveStream)+' imgsrc="'+liveStream.thumbnail+'" normalSrc="'+liveStream.android+'" HDSrc="'+liveStream.android+'">'+loadMessage+'</p>';
		content = liveStreamStr + content;
    }
    
     // 显示正文
    container.innerHTML = content;
    // 隐藏loading,可以视情况延时调用
    if(!SCREEN_WIDTH){
    	SCREEN_WIDTH = '0';
    }
    ifeng.hideLoadingMask(SCREEN_WIDTH);
    // 启动加载图片
    setTimeout(loadImages, 200);
}

function formatChild(note){
    var nodes = note.childNodes;
	var canBreak = 0;
	for(var i=nodes.length-1;i>=0;i--){
		if(nodes[i].nodeType==1&&nodes[i].nodeName=="P"&&nodes[i].getAttribute("class")!=="placeholder"){
			var cNodes = nodes[i].childNodes;
			for(var j=0;j<cNodes.length;j++){
				if(cNodes[j].nodeType==1){
					if(j==cNodes.length-1&&(cNodes[j].nodeName=="STRONG"||cNodes[j].nodeName=="SPAN")){
						if(cNodes[j].childNodes.length>0&&cNodes[j].childNodes[0].nodeName!=="SMALL"){
						cNodes[j].innerHTML = cNodes[j].innerHTML+'<img src="end_logo.png"/>';
						canBreak = 1;
						}
					}
				}else if(j==cNodes.length-1||cNodes[j].nodeType==3){
					cNodes[j].parentNode.innerHTML = cNodes[j].parentNode.innerHTML+'<img src="end_logo.png"/>';
					canBreak = 1;
				}
			}
		}
		if(canBreak){
			break;
		}
	}
    return note;
}

// 滚动加载图片
function loadImages() {	
    var container = document.getElementById('content'),
        placeholders = Array.prototype.slice.call(container.getElementsByClassName('placeholder')),
        src, docId = datas.getDocumentId(),loadMessage = '<span class="load-message">正在载入...</span>';
   
    var VIEWPORT_HEIGHT = window.innerHeight || document.documentElement.clientHeight; // VIEWPORT_HEIGHT || document.body.clientHeight;
	if (VIEWPORT_HEIGHT < 300) {
		VIEWPORT_HEIGHT = 800; // 若获取高度不正确给默认高度800，可能的副作用是浏览正文时会预载更多的图片。
	}
//    console.log('window.innerHeight  '+window.innerHeight+', document.body.clientHeight  '+document.body.clientHeight+', VIEWPORT_HEIGHT  '+VIEWPORT_HEIGHT);

    var videoComponent = container.getElementsByClassName('video');
    
    var slideComponent = container.getElementsByClassName('slide');
    //加载视频图片
    for(var i = 0; i<videoComponent.length; i++) {
    	var videoDom = videoComponent[i];
    	imgQuene.push({
            ot: videoDom.offsetTop,
            dom: videoDom,
            src: videoDom.getAttribute('imgsrc')
        })
        
        videoDom.onclick = function() {
       	 index = parseInt(this.getAttribute('index'));
         src = this.getAttribute('imgsrc');
         isLoaded = (this.className).indexOf('loaded') > -1;
			 loadState = this.getAttribute('loadState');
			 if(isLoaded) {
				ifeng.playVideo(this.getAttribute('normalSrc'),this.getAttribute('HDSrc'));
			 } else {
				if(loadState=='loadFail') {
				//如果没有网络连接，直接提示无网络
				if(ifeng.checkNetWorkState() == 0) {
					return;
				}
					if(loadMode == 1) {
						this.style.backgroundImage = 'url(video_loading.png),url()';
					} else {
						this.innerHTML = loadMessage;
					}
					 this.setAttribute('loadState','loading');
	          	 	 Ground.loadImageDirectly(src, docId,
	                    loadImageSuccessInterceptor(this),
	                    loadImageFailInterceptor(this, src),'forceLoad');
				}
			 }			
	};
    }
    
   //加载图集图片
    for(var i = 0; i < slideComponent.length; i++) {
    	var slideDom = slideComponent[i];
    	imgQuene.push({
            ot:  slideDom.offsetTop,
            dom: slideDom,
            src: slideDom.getAttribute('slidesrc')
        })
        
        slideDom.onclick = function() {
        	index = parseInt(this.getAttribute('index'));
            src = this.getAttribute('slidesrc');
            isLoaded = (this.className).indexOf('loaded') > -1;
 			loadState = this.getAttribute('loadState');
 			if(isLoaded) {
 				ifeng.goToSlide(this.getAttribute('src'));
 			 }  else {
 	          	  if(loadState=='loadFail'){ 
 	          	  //如果没有网络连接，直接提示无网络
				if(ifeng.checkNetWorkState() == 0) {
					return;
				}   		          		          	 	 
 	          	 	 if(loadMode == 1) {
 	          	 		this.style.backgroundImage = 'url(slide_text.png),url(logo_loading.png)';
 	          	 		this.style.backgroundSize = '40px 22px,auto';
 	          	 	 } else {
						this.innerHTML = loadMessage;
					 }
 	          	 	 this.setAttribute('loadState','loading');
 	          	 	 Ground.loadImageDirectly(src, docId,
 	                    loadImageSuccessInterceptor(this),
 	                    loadImageFailInterceptor(this, src),'forceLoad');
 				  }
 	            }          
         };
    }
     
    for ( var i = 0; i < placeholders.length; i++) {
        var imgDom = placeholders[i];

        src = imgDom.getAttribute('src');
//   console.log('img '+i+' offsetTop=' + imgDom.offsetTop);
        imgQuene.push({
            ot: imgDom.offsetTop,
            dom: imgDom,
            src: src
        })
        // 点击判断加载状态 执行重新加载 或 显示幻灯
        imgDom.onclick = function() {
            var index, src, isLoaded, loadState;
            index = parseInt(this.getAttribute('index'));
            src = this.getAttribute('src');
            isLoaded = (this.className).indexOf('loaded') > -1;
			loadState = this.getAttribute('loadState');
			console.log(this.style.width + 'px ---');
            if(isLoaded) {
			console.log('popup, url=' + src + ', img path=' + this.style.backgroundImage);
                Ground.popupLightbox(src, loadImageSuccessInterceptor(this));
            } else {
          	  if(loadState=='loadFail'){
          	      	  //如果没有网络连接，直接提示无网络
				if(ifeng.checkNetWorkState() == 0) {
					return;
				}   		          		          	 	 
          	 	 if(loadMode == 1) {
          	 		this.style.backgroundImage = 'url(logo_loading.png)';
          	 	 } else {
					this.innerHTML = loadMessage;
				 } 
          	 	 this.setAttribute('loadState','loading');
          	 	 Ground.loadImageDirectly(src, docId,
                    loadImageSuccessInterceptor(this),
                    loadImageFailInterceptor(this, src),'forceLoad');
			  }
            }
        };
    }

//	if (imgQuene.length > 0 && imgQuene[0].ot > VIEWPORT_HEIGHT * 4) {
		// 如果第一张图的底部是屏幕高度的4倍还多，认为获得图片高度不正确，比如手机Huawei Y220-T10
		// 打开长文章时会出现这种情况，为避免图片不能按高度加载，出现这种情况时一次性加载出正文的所有图片
		// fix bug #17146
//		VIEWPORT_HEIGHT = imgQuene[0].ot;
//	}
	
    // 滚动时的判断 执行加载
//    var scrollToLoad = function() {
//        var bt = document.body.scrollTop + VIEWPORT_HEIGHT * 3 + delatHeight; // 加载3屏
// console.log('scrollToLoad: VIEWPORT_HEIGHT=' + VIEWPORT_HEIGHT + ', scrollTop=' + document.body.scrollTop + ', !!!!bt=' + bt);
//        for(var j = 0, len = imgQuene.length; j < len; j++){
//            var d = imgQuene[j];
//            if(!d) continue;
//            if(bt > d.ot && (bt - d.ot) < (VIEWPORT_HEIGHT * 4)){            
//            		 Ground.loadImage(d.src, docId,
//                             loadImageSuccessInterceptor(d.dom, j),
//                             loadImageFailInterceptor(d.dom, d.src), 'false');
//            		 imgQuene[j] = false;     
//            }
//        }
//    }

//	if (imgQuene.length > 0 && imgQuene[0].ot > VIEWPORT_HEIGHT * 4) {
//		// 如果第一张图的底部是屏幕高度的4倍还多，认为获得图片高度不正确，比如手机Huawei Y220-T10
//		// 打开长文章时会出现这种情况，为避免图片不能按高度加载，出现这种情况时一次性加载出正文的所有图片
//		// fix bug #17146

		// 开始加载所有正文图片
		for(var j = 0, len = imgQuene.length; j < len; j++){
			var d = imgQuene[j];
            Ground.loadImage(d.src, docId,
                    loadImageSuccessInterceptor(d.dom, j),
                    loadImageFailInterceptor(d.dom, d.src), 'false');     
		}
		ifeng.startDownload();
		
		// 滚动结束时 执行 scrollToLoad
//		window.addEventListener('scroll', function() {
//			throttle(scrollToLoad);
//		}, false);
//
//		scrollToLoad();
}

// 图片加载的成功回调
function loadImageSuccessInterceptor(placeholder, imgPosition) {
    return function(src) {
    	placeholder.innerHTML = '';
    	if(src == "none") {
    		 //设置了无图模式并且网络为2G/3G
		    if(loadMode == 1) {
		    	if(placeholder.getAttribute('imgsrc')){
		    		placeholder.style.backgroundImage = 'url(video_no_load.png),url()';
		    	} 
		    	else if(placeholder.getAttribute('slidesrc')){
		    		placeholder.style.backgroundImage = 'url(slide_text.png),url(logo_no_load.png)';
		    	}
		    	else {
		    		placeholder.style.backgroundImage = 'url(logo_no_load.png)';
		    	}		    	
		    	 placeholder.setAttribute('loadState','loadFail');
		    } 
    		return;
    	}
    	
    	//加载成功了
        var className = placeholder.className;
//		imgQuene[imgPosition] = false;
        if (className.indexOf('loaded') > -1) {
            return;
        }
        if(placeholder.getAttribute('commentImageSrc')) {
        	placeholder.src = src;       	
        } 
        else if(placeholder.getAttribute('imgsrc')) {
        	placeholder.style.backgroundImage = 'url(btn_play.png),url('+src+')';          	
        } 
        else if(placeholder.getAttribute('slidesrc')) {
        	placeholder.style.backgroundImage = 'url(slide_text.png),url('+src+')';
        	placeholder.style.backgroundSize = '40px 22px,cover';
        }
        else {
        	placeholder.style.backgroundSize = '100%,100%';
        	placeholder.style.backgroundImage = 'url(' + src + ')';
            placeholder.style.backgroundPosition = 'center top';  
                     
        }              
        placeholder.className = className + ' loaded';
               
    };
}


function loadImageFailInterceptor(placeholder, src) {		
	    return function() {
		if (loadMode == 1) {
			if(placeholder.getAttribute('imgsrc')) {
				placeholder.style.backgroundImage = 'url(video_load_fail.png),url()';
			} 
			else if(placeholder.getAttribute('slidesrc')) {
				placeholder.style.backgroundImage = 'url(slide_text.png),url(logo_load_fail.png)'
			}
			else {
				placeholder.style.backgroundImage = 'url(logo_load_fail.png)';
			}			
		} else {			
				placeholder.innerHTML = '<span class="load-message">点击加载图片</span>';
		}
		placeholder.setAttribute('loadState', 'loadFail');
		sendWebLog('load img fail', src);
	};
}

function loadSurvey(){
	Ground.loadSurvey(buildSurvey, null);
}

function buildSurvey(survey, isSurved){
	if(!survey||Object.prototype.toString.call(survey) !== '[object String]'){
		return false;
	}
	var surveyData;
	survey = decodeURIComponent(survey);
	try{
		surveyData = JSON.parse(survey);
	} catch (e) {
		surveyData = undefined;
	}
	if(surveyData.result.length<1){
		return false;
	}
	document.getElementById("split").style.display = "block";
	var vote_content = document.getElementById("vote");
	var vote_title = document.getElementById("vote-title");
	var vote_share = document.getElementById("vote-share");
	var vote_discription = document.getElementById("vote-discription");
	var vote_list = document.createElement("ul");
	var vote_item = document.createElement("li");
	var percent_img = document.createElement("div");
	var percent_lable = document.createElement("span");
	var count_lable = document.createElement("span");
	var percent_title = document.createElement("div");
	var goto_survey = document.createElement("div");
	vote_share.style.display = "none";
	vote_content.style.display = "block";
	if(isSurved||surveyData.surveyinfo.isactive=="1"){
		vote_discription.innerHTML = "进行中  "+surveyData.surveyinfo.pnum+"人参与";
	}else{
		vote_discription.innerHTML = "已结束  "+surveyData.surveyinfo.pnum+"人参与";
	}
	if(surveyData.surveyinfo.isactive=="1"){
		goto_survey.innerHTML = "<div>参与调查</div>";
	}else{
		goto_survey.innerHTML = "<div>查看结果</div>";
	}
	vote_list.className = "vote-list";
	vote_item.className = "vote-item";
	vote_item.style.paddingLeft = "14px"
	percent_img.className = "percent-img";
	percent_lable.className = "percent-lable";
	count_lable.className = "count-lable";
	percent_title.className = "vote-item-title";
	var highest_result= 0;
	var highest_item = 0;
	//区百分比最高项进行显示
	for(var j=0;j<surveyData.result.length;j++){
		for(var i=1;i<surveyData.result[j].resultArray.length;i++){
			if(surveyData.result[j].resultArray[i].nump*10>surveyData.result[highest_result].resultArray[highest_item].nump*10){
				highest_item = i;
				highest_result = j;
			}
		}
	}
	vote_item.style.backgroundImage = 'url(single_split.png),url(vote_1.png)';
	percent_img.style.background = "#11c0f5"; 
	vote_title.innerHTML = surveyData.result[highest_result].question+" (共"+surveyData.result.length+"题)";
	goto_survey.setAttribute("id", "to-survey");
	goto_survey.className = "to-survey";
	goto_survey.onclick = function(){
		ifeng.goToSurvey(surveyData.surveyinfo.id);
	}
	percent_img.onload = statisticBarLoaded(percent_img, surveyData.result[highest_result].resultArray[highest_item].nump);
	percent_lable.innerHTML = surveyData.result[highest_result].resultArray[highest_item].nump+ '<span class="percent">%</span>';
	count_lable.innerHTML = surveyData.result[highest_result].resultArray[highest_item].num+"票";
	percent_title.innerHTML = surveyData.result[highest_result].resultArray[highest_item].title;
	vote_item.appendChild(percent_img);
	vote_item.appendChild(percent_lable);
	vote_item.appendChild(count_lable);
	vote_item.appendChild(percent_title);
	vote_list.appendChild(vote_item);
	vote_content.appendChild(vote_list);
	vote_content.appendChild(goto_survey);
}

function buildVote(vote, isVoted){
	if(!vote||Object.prototype.toString.call(vote) !== '[object String]'){
		return false;
	}
	vote = decodeURIComponent(vote);
	VOTEDATA = JSON.parse(vote)
	if(!VOTEDATA.votecount){
		VOTEDATA.votecount = 0;
	}
	document.getElementById("split").style.display = "block";
	var vote_content = document.getElementById("vote");
	var vote_title = document.getElementById("vote-title");
	var vote_share = document.getElementById("vote-share");
	var vote_end = document.createElement("span");
	vote_title.innerHTML = VOTEDATA.topic;
	var vote_discription = document.getElementById("vote-discription");
	var vote_list = document.createElement("ul");
	vote_list.className = "vote-list";
	vote_list.setAttribute("id", "vote-list");
	vote_end.className = "vote-end";
	vote_end.setAttribute("id","vote-end");
	vote_content.style.display = "block";
	if(VOTEDATA.isactive){
		vote_discription.innerHTML = "进行中  "+VOTEDATA.votecount+"人参与";
		buildVoteFace(VOTEDATA.iteminfo, vote_list);
		vote_end.innerHTML = "点击选项投票 投票后查看结果";
	}else{
		if(isVoted){
			vote_discription.innerHTML = "进行中  "+VOTEDATA.votecount+"人参与";
		}else{
			vote_discription.innerHTML = "投票已过期   "+VOTEDATA.votecount+"人参与";
		}
		buildVoteResults(VOTEDATA.iteminfo, vote_list);
		vote_end.innerHTML = "感谢您的参与";
	}
	vote_share.onclick = function(){
		ifeng.shareVoteData(VOTEDATA.topic);
	}
	vote_content.appendChild(vote_list);
	vote_content.appendChild(vote_end);
	
}

function buildVoteFace(iteminfo, vote_list){
		var num=iteminfo.length;
		for (var i = 0; i < num; i++) {
			var vote_item = document.createElement("li");
			var percent_lable = document.createElement("span");
			vote_item.className = "vote-item";
			vote_item.style.paddingLeft = "28px"
			percent_lable.className = "percent-lable";
			percent_lable.innerHTML = iteminfo[i].title;
			vote_item.setAttribute("id", iteminfo[i].id);
			vote_item.appendChild(percent_lable);
			vote_item.onclick = function(){
				Ground.submitVote(VOTEDATA.id,this.getAttribute("id"),buildSubmmitedResults,null);
			};
			vote_list.appendChild(vote_item);
		}
}

function buildSubmmitedResults(vote){
	var colors = ["#ff2c49","#11c0f5","#ffd500","#0088ba","#80e131"];
	var vote_items = document.getElementById("vote-list").getElementsByTagName("li");
	var num=vote_items.length;
	var lastPercent = 0;
	var vote_discription = document.getElementById("vote-discription");
	VOTEDATA = JSON.parse(vote);
	var reg = new RegExp("\\d+","gmi");
	vote_discription.innerHTML = vote_discription.innerHTML.replace(reg, VOTEDATA.votecount);
	for (var i = 0; i < num; i++) {
		vote_items[i].onclick = "";
		var currentPercent;
		var percent_img = document.createElement("div");
		var percent_lable = document.createElement("span");
		var count_lable = document.createElement("span");
		var percent_title = document.createElement("div");
		vote_items[i].style.backgroundImage = 'url(single_split.png),url(vote_'+i % colors.length+'.png)'
		vote_items[i].style.paddingLeft = "14px"
		percent_img.className = "percent-img";
		percent_lable.className = "percent-lable";
		count_lable.className = "count-lable";
		percent_title.className = "vote-item-title";
		percent_img.style.background = colors[i % colors.length]; 
		percent_img.onload = statisticBarLoaded(percent_img,VOTEDATA.iteminfo[i].nump);
		percent_lable.innerHTML = VOTEDATA.iteminfo[i].nump+ '<span class="percent">%</span>';
		count_lable.innerHTML = VOTEDATA.iteminfo[i].votecount+"票";
		percent_title.innerHTML = VOTEDATA.iteminfo[i].title;
		vote_items[i].removeChild(vote_items[i].getElementsByTagName("span")[0]);
		vote_items[i].appendChild(percent_img);
		vote_items[i].appendChild(percent_lable);
		vote_items[i].appendChild(count_lable);
		vote_items[i].appendChild(percent_title);
	}
	document.getElementById("vote-end").innerHTML = "感谢您的参与";
}

function formatFloat(number) {
	return Math.round(number*1000);
}

function buildVoteResults(iteminfo, vote_list){
		    var colors = ["#ff2c49","#11c0f5","#ffd500","#0088ba","#80e131"];
		    var num=iteminfo.length;
		    for (var i = 0; i < num; i++) {
		    	var vote_item = document.createElement("li");
				var percent_img = document.createElement("div");
				var percent_lable = document.createElement("span");
				var count_lable = document.createElement("span");
				var percent_title = document.createElement("div");
				vote_item.className = "vote-item";
				vote_item.style.backgroundImage = 'url(single_split.png),url(vote_'+i+'.png)'
				percent_img.className = "percent-img";
				percent_lable.className = "percent-lable";
				count_lable.className = "count-lable";
				percent_title.className = "vote-item-title";
				percent_img.style.background = colors[i % colors.length];
                percent_img.onload = statisticBarLoaded(percent_img,iteminfo[i].nump);
				percent_lable.innerHTML = iteminfo[i].nump + '<span class="percent">%</span>';
				count_lable.innerHTML = iteminfo[i].votecount+"票";
				percent_title.innerHTML = iteminfo[i].title;
				vote_item.appendChild(percent_img);
				vote_item.appendChild(percent_lable);
				vote_item.appendChild(count_lable);
				vote_item.appendChild(percent_title);
				vote_list.appendChild(vote_item);
		    }
}

function statisticBarLoaded(element,percentage){
			 var pos, runTime,
	            startTime = + new Date,
	            timer = setInterval(function () {
	                    runTime = + new Date - startTime;
	                    pos = runTime /1000;
	                    if (pos >= 1) {
	                        clearInterval(timer);
	                        element.style.width = 60*percentage/100 + '%';
	                    } else {
	                        element.style.width = 60*percentage*pos/100 + '%';
	                    };
	            }, 100);
		}

// 发送日志
function sendWebLog(type, msg, e) {
    var docId = datas.getDocumentId() || 'null doc id',
        eMsg = e && e.message ? e.message : 'null error msg';

    ifeng.webLog(docId + '---' + type + '---' + eMsg + '---' + msg);
}

// 函数节流包装器
function throttle(method, context) {
    clearTimeout(method.tId);
    method.tId = setTimeout(function(){
        method.call(context);
    }, 100);
}

// 与native交互实现
(function() {
    var toString = function(v) {
        return Object.prototype.toString.call(v);
    }, isFunction = function(v) {
        return toString(v) === '[object Function]';
    }, athene = {}, CALLBACK_PREFIX = 'callback__', callbacks = {}, callbackCount = 0, CallbackStatus = {
        OK : 1
    };
    athene.exec = function(success, fail, service, action, params) {
        var callbackId = CALLBACK_PREFIX + callbackCount++;
        callbacks[callbackId] = {
            success : success,
            fail : fail
        };
        params = Array.prototype.concat.call([], callbackId, params || []);
        action.apply(service, params);
    };
    athene.complete = function() {
        if (arguments.length < 2) {
            throw new Error('Missing essential arguments');
        }
        var callbackId = arguments[0], status = arguments[1], callback = callbacks[callbackId], params = Array.prototype.slice
            .call(arguments, 2), success, fail;
        delete callbacks[callbackId];
        if (!callback) {
            return;
        }
        success = callback.success;
        fail = callback.fail;
        if (status == CallbackStatus.OK && isFunction(success)) {
            success.apply(null, params);
//            console.log('params= '+ params[0]);
        } else if (isFunction(fail)) {
            fail.apply(null, params);
        }
    }
	athene.updata = function(){
		var vote_content = document.getElementById("to-survey");
		if(arguments[0]==0){
			vote_content.innerHTML = "<div>查看结果</div>";
		}
	}
    window['athene'] = athene;
})();

// ground 接口
(function() {
    var Ground = {
        loadImage : function(src, documentId, success, fail, forceLoad) {
            athene.exec(success, fail, ifeng, ifeng.loadImage, [ src,
                documentId, forceLoad]);
        },
		loadImageDirectly : function(src, documentId, success, fail, forceLoad) {
            athene.exec(success, fail, ifeng, ifeng.loadImageDirectly, [ src,
                documentId, forceLoad]);
        },
        popupLightbox : function(src, success) {
            athene.exec(success, null, ifeng, ifeng.popupLightbox, [ src ]);
        },
        loadAdv01 : function(documentId, success, fail) {
            athene.exec(success, fail, ifeng, ifeng.loadAdv01, [documentId]);
        },
		loadAdv02 : function(documentId, success, fail) {
            athene.exec(success, fail, ifeng, ifeng.loadAdv02, [documentId]);
        },
        loadAdv2 : function(documentId, success, fail) {
        	athene.exec(success, fail, ifeng, ifeng.loadAdv2, [documentId]);
        },
        getHotComments: function(commentsUrl, documentId, success, fail) {
            athene.exec(success, fail, ifeng, ifeng.getHotComments, [commentsUrl, documentId]);
        },
		loadVote : function(success, fail) {
            athene.exec(success, fail, ifeng, ifeng.getVoteData);
        },
		submitVote : function(id, itemid, success, fail) {
            athene.exec(success, fail, ifeng, ifeng.submitVoteData, [id, itemid]);
        },
		loadSurvey : function(success, fail) {
            athene.exec(success, fail, ifeng, ifeng.getSurveyData);
        }
    };

    window['Ground'] = Ground;
})();


// 屏幕宽度检测
(function() {
	var retry = 0;
    var ScreenDetector = {
        MAX_RETRY_TIMES : 30,
        INTERVAL : 5,
        STORAGE_WIDTH_KEY : '__devicewidth__', // localStorage 存储宽度值的 key

        launch : function() {

            var storage = window.localStorage, isReady = storage
                && storage.getItem(this.STORAGE_WIDTH_KEY); // 已存储过代表已准备好

            if (isReady) {
                this._ready();

            } else {
                this._docWidth = document.body.clientWidth;
                this._retryTimes = 0;
                this._start();
            }
        },
        _start : function() {
            var self = this;
            setTimeout(function() {
                self._detect();
            }, this.INTERVAL);
        },
        _detect : function() {
        	
            var currentDocWidth,self = this;
			if(datas.getArticleWidth()){
        		currentDocWidth = datas.getArticleWidth();
        	}else{
        		currentDocWidth = document.body.clientWidth;
        	}
        	console.log("-------"+currentDocWidth);
            if (this._retryTimes < this.MAX_RETRY_TIMES) {
                this._retryTimes++;
                if (this._docWidth != currentDocWidth) {
                    self._ready(currentDocWidth);
                } else {
                    setTimeout(function() {
                        self._detect();
                    }, this.INTERVAL);
                }

            } else {
                self._ready(self._docWidth);
            }
        },
        /**
         * 屏幕宽度检测完成 派发deviceready事件
         *
         * @param docWidth
         *            设置 localstorage 中的 width 值
         * @private
         */
        _ready : function(docWidth) {
            var storage = window.localStorage, clientWidth, ev;   
//            for(var i=0;i<7;i++) {
//            	VIEWPORT_HEIGHT = window.innerHeight;
//            	if(VIEWPORT_HEIGHT) {
//            		break;
//            	}
//            }
            if (docWidth && storage) {
                storage.setItem(this.STORAGE_WIDTH_KEY, docWidth);
            }
            // 设置 e.clientWidth 变量的值 方便业务逻辑中使用
            clientWidth = parseInt(docWidth
                || storage.getItem(this.STORAGE_WIDTH_KEY));
            ev = document.createEvent('Event');
            ev.clientWidth = clientWidth;
            ev.initEvent('deviceready', false, true);
            window.dispatchEvent(ev);
        }
    };
    window.addEventListener('load', function(e) {
        ScreenDetector.launch();
    }, false);
})();