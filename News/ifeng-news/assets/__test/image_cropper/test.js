var strategy,
	STD_WIDTH = 294,
	STD_HEIGHT = 174,
	MIN_ZOOM_WIDTH = 150,
	MIN_ZOOM_HEIGHT = 100;
module('Crop Strategy Test', {
	setup: function() {
		strategy = new StandPlaceholderCropStrategy(STD_WIDTH, STD_HEIGHT, MIN_ZOOM_WIDTH, MIN_ZOOM_HEIGHT);
	}
});
test('Both width and height are less(equal) than standard placeholder', function() {
	var w1 = 294, h1 = 170,
		r1 = strategy.getResult(w1, h1),
		expect1 = {
			width: w1,
			height: h1,
			top: 'center',
			left: 'center'
		},
		w2 = 100, h2 = 174,
		r2 = strategy.getResult(w2, h2),
		expect2 = {
			width: w2,
			height: h2,
			top: 'center',
			left: 'center'
		},
		w3 = 294, h3 = 174,
		r3 = strategy.getResult(w3, h3),
		expect3 = {
			width: w3,
			height: h3,
			top: 'center',
			left: 'center'
		},
		w4 = 290, h4 = 170,
		r4 = strategy.getResult(w4, h4),
		expect4 = {
			width: w4,
			height: h4,
			top: 'center',
			left: 'center'
		},
		w5 = 290, h5 = 50,
		r5 = strategy.getResult(w5, h5),
		expect5 = {
			width: w5,
			height: h5,
			top: 'center',
			left: 'center'
		},
		w6 = 100, h6 = 170,
		r6 = strategy.getResult(w6, h6),
		expect6 = {
			width: w6,
			height: h6,
			top: 'center',
			left: 'center'
		};
	deepEqual(r1, expect1, 'width equal, height less');
	deepEqual(r2, expect2, 'width less, height equal');
	deepEqual(r3, expect3, 'width equal, height equal');
	deepEqual(r4, expect4, 'slope between critical value');
	deepEqual(r5, expect5, 'slope smaller than minimum value');
	deepEqual(r6, expect6, 'slope larger than maximum value');
});

test('Slope between critical value and at least one edge is longer than standard placeholder', function() {
	var w1 = 300, h1 = 170,
		r1 = strategy.getResult(w1, h1),
		expect1 = {
			width: STD_WIDTH,
			height: Math.round(STD_WIDTH * (h1 / w1)),
			top: 'center',
			left: 'center'
		},
		w2 = 350, h2 = 195,
		r2 = strategy.getResult(w2, h2),
		expect2 = {
			width: STD_WIDTH,
			height: Math.round(STD_WIDTH * (h2 / w2)),
			top: 'center',
			left: 'center'
		},
		w3 = 290, h3 = 220,
		r3 = strategy.getResult(w3, h3),
		expect3 = {
			width: Math.round(STD_HEIGHT / (h3 / w3)),
			height: STD_HEIGHT,
			top: 'center',
			left: 'center'
		},
		w4 = 300, h4 = 230,
		r4 = strategy.getResult(w4, h4),
		expect4 = {
			width: Math.round(STD_HEIGHT / (h4 / w4)),
			height: STD_HEIGHT,
			top: 'center',
			left: 'center'
		};
	deepEqual(r1, expect1, 'slope < std_slope && width > std_width && height < std_height');
	deepEqual(r2, expect2, 'slope < std_slope && width > std_width && height > std_height');
	deepEqual(r3, expect3, 'slope > std_slope && width < std_width && height > std_width');
	deepEqual(r4, expect4, 'slope > std_slope && width > std_width && height > std_width');
});
test('Slope is larger than maximun slope', function() {
	var w1 = 140, h1 = 180,
		r1 = strategy.getResult(w1, h1),
		expect1 = {
			width: MIN_ZOOM_WIDTH,
			height: Math.round(MIN_ZOOM_WIDTH * (h1 / w1)),
			top: 'top',
			left: 'center'
		},
		w2 = 180, h2 = 220,
		r2 = strategy.getResult(w2, h2),
		expect2 = {
			width: MIN_ZOOM_WIDTH,
			height: Math.round(MIN_ZOOM_WIDTH * (h2 / w2)),
			top: 'top',
			left: 'center'
		};
	deepEqual(r1, expect1, 'width < std_width && height > std_height');
	deepEqual(r2, expect2, 'width > std_width && height > std_height');
});
test('Slope is smaller than minimum slope', function() {
	var w1 = 300, h1 = 90,
		r1 = strategy.getResult(w1, h1),
		expect1 = {
			width: Math.round(MIN_ZOOM_HEIGHT / (h1 / w1)),
			height: MIN_ZOOM_HEIGHT,
			top: 'center',
			left: 'center'
		},
		w2 = 600, h2 = 180,
		r2 = strategy.getResult(w2, h2),
		expect2 = {
			width: Math.round(MIN_ZOOM_HEIGHT / (h1 / w1)),
			height: MIN_ZOOM_HEIGHT,
			top: 'center',
			left: 'center'
		};
	deepEqual(r1, expect1, 'width < std_width && height > std_height');
	deepEqual(r2, expect2, 'width > std_width && height > std_height');
});