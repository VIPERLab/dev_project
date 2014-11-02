function init(){
	var contentDom = document.getElementById("content");
	contentDom.innerHTML = datas;
	var imgDoms	= contentDom.getElementsByTagName("img");
	var SCREEN_WIDTH = document.body.clientWidth;
	for(var i = 0 ; i < imgDoms.length ; i++){
		var src = imgDoms[i].getAttribute("src");
		imgDoms[i].style.backgroundImage = 'url(' + src + '),url(logo.png)';
		imgDoms[i].onclick = function(){
			ifeng.popupLightbox(this.getAttribute("src"));
		}
	}
}
