var StandPlaceholderCropStrategy = function(stdWidth, stdHeight, minWidth, minHeight) {
	this._stdWidth = stdWidth;
	this._stdHeight = stdHeight;
	this._minWidth = minWidth;
	this._minHeight = minHeight;
};
StandPlaceholderCropStrategy.prototype = {
	getResult: function(width, height) {
		var ratio = Math.max(width / this._stdWidth, height / this._stdHeight, 1),
			topPos = (ratio > 1 && height / width > this._stdHeight / this._minWidth) ? 'top' : 'center';
		ratio = ratio == 1 ? 1 : Math.min(width / this._minWidth, height / this._minHeight, ratio);

		return {
			width: Math.round(width / ratio),
			height: Math.round(height / ratio),
			top: topPos,
			left: 'center'
		};
	}
};
var ImageCropper = function(strategy) {
	this._strategy = strategy;
}
ImageCropper.prototype = {
	getResult: function(width, height) {
		return this._strategy.getResult(width, height);
	}		
};