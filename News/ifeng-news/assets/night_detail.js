var cropper,
    IMAGE_PLACEHOLDER_WIDTH,
    IMAGE_PLACEHOLDER_HEIGHT,
    PLACEHOLDER_SLOPE = 174 / 294,
    MAX_SLOPE = 174 / 150,
    MIN_SLOPE = 100 / 294,
    MIN_ZOOM_WIDTH, MIN_ZOOM_HEIGHT,
    CONTENT_PADDING = 20,
    TASK_LOAD_ADV = 'loadAdv',
    TASK_LOAD_RELATIVE_NEWS = 'loadRelativeNews',
    TASK_LOAD_COMMENT = 'loadComment';

var MultTaskCollaborator = {
    _taskQueue: [],
    _callback: null,
    register: function(name) {
        this._taskQueue.push(name);
        return this;
    },
    setOnAllComplete: function(callback) {
        this._callback = callback;
        return this;
    },
    complete: function(name) {
        var index = this._taskQueue.indexOf(name);
        if (index < 0) {
            return false;
        }
        this._taskQueue.splice(index, 1);
//        console.log('task [' + name + '] completed!');
        if (this._taskQueue.length === 0) {
            this._callback();
        }
    }
};

window.addEventListener('deviceready', init, false);

function init(e) {
    MultTaskCollaborator.setOnAllComplete(function() {
        launchPageBottomDetector();

        document.addEventListener(REACH_PAGE_BOTTOM, function(e) {
            ifeng.showAdv();
        }, false);
        document.addEventListener(LEAVE_PAGE_BOTTOM, function(e) {
            ifeng.hideAdv();
        }, false);

        // 针对内容高度不足 无法触发scroll事件的情况 手动触发一下
        var event = document.createEvent('HTMLEvents');
        event.initEvent('scroll', false, true);
        window.dispatchEvent(event);
    }).register(TASK_LOAD_ADV)
        .register(TASK_LOAD_RELATIVE_NEWS)
        .register(TASK_LOAD_COMMENT);

    IMAGE_PLACEHOLDER_WIDTH = e.clientWidth - CONTENT_PADDING;
    IMAGE_PLACEHOLDER_HEIGHT = Math.round(IMAGE_PLACEHOLDER_WIDTH
        * PLACEHOLDER_SLOPE);
    MIN_ZOOM_WIDTH = Math.round(IMAGE_PLACEHOLDER_HEIGHT / MAX_SLOPE);
    MIN_ZOOM_HEIGHT = Math.round(IMAGE_PLACEHOLDER_WIDTH * MIN_SLOPE);
    cropper = new ImageCropper(new StandPlaceholderCropStrategy(
        IMAGE_PLACEHOLDER_WIDTH, IMAGE_PLACEHOLDER_HEIGHT, MIN_ZOOM_WIDTH,
        MIN_ZOOM_HEIGHT));

    try {
        var sheet = document.getElementsByTagName('link')[0].sheet;
        sheet.insertRule('.content .placeholder {min-height:'
            + IMAGE_PLACEHOLDER_HEIGHT + 'px}');
        sheet.insertRule('.content .video {min-height:' + IMAGE_PLACEHOLDER_HEIGHT
            + 'px}');
    } catch (e) {
        ifeng.reload(datas.getDocumentId());
        return false;
    }

    document.getElementById('title').innerHTML = datas.getTitle();

    var sourceText = datas.getSource(),
        sourceEl = document.getElementById('source'),
        sliceIndex = -3;
    if (sourceText && sourceText !== '未知') {
        if(sourceText.length > 6) sliceIndex = -9;
        sourceEl.innerHTML = sourceText.substring(0, 10);
    } else {
        sourceEl.style.display = 'none';
    }

    document.getElementById('time').innerHTML = datas.getEditTime().replace(
        /-/g, '/').slice(0, sliceIndex);

    document.addEventListener(DOUBLE_TAP, function(e) {
        ifeng.toggleFullScreen();
    }, false);

    setFontSize(datas.getFontSize());

    preprocessImage(formatText(datas.getText()),
        document.getElementById('content'));

    setTimeout(fixImgNoteStyle, 200);

    initRelativeNews();

    Ground.loadAdv(datas.getDocumentId(), initAdv, function() {
        MultTaskCollaborator.complete(TASK_LOAD_ADV);
    });

    var commentsUrl = datas.getCommentsUrl() || datas.getWwwurl();

    Ground.getHotComments(commentsUrl, datas.getDocumentId(), initComment, function() {
        MultTaskCollaborator.complete(TASK_LOAD_COMMENT);
    });

    document.getElementById('comment_count_btn').addEventListener(TAP, showCommentsView, false);
    document.getElementById('comment_more_btn').addEventListener(TAP, showCommentsView, false);

    setTimeout(function() {
        ifeng.hideLoadingMask(datas.getDocumentId());
    }, 20);
}

// 为了通知java层是否显示广告sdk而做的事件派发。需要派发到达页面底部REACH_PAGE_BOTTOM和离开页面底部LEAVE_PAGE_BOTTOM这两个事件
function launchPageBottomDetector() {
    var VIEWPORT_HEIGHT = window.innerHeight || document.documentElement.clientHeight,
        DOC_BODY_HEIGHT = document.body.scrollHeight - 5, // 临时解决高度计算 1px 偏差的问题
        REACH_PAGE_BOTTOM = 'reachpagebottom',
        LEAVE_PAGE_BOTTOM = 'leavepagebottom',
        isReachBottom = false;
    window.addEventListener('scroll', function(e) {
        var bottomOffset = document.body.scrollTop + VIEWPORT_HEIGHT,
            event;

        if (!isReachBottom && bottomOffset >= DOC_BODY_HEIGHT) {
            event = document.createEvent('HTMLEvents');
            event.initEvent(REACH_PAGE_BOTTOM, false, true);
            document.dispatchEvent(event);
            isReachBottom = true;
        } else if (isReachBottom && bottomOffset < DOC_BODY_HEIGHT) {
            event = document.createEvent('HTMLEvents');
            event.initEvent(LEAVE_PAGE_BOTTOM, false, true);
            document.dispatchEvent(event);
            isReachBottom = false;
        }
    }, false);

    window['REACH_PAGE_BOTTOM'] = REACH_PAGE_BOTTOM;
    window['LEAVE_PAGE_BOTTOM'] = LEAVE_PAGE_BOTTOM;
}


function setFontSize(fs) {
    var cdom = document.getElementById('content');
    if(fs && fs !== 'mid') {
        cdom.className += ' ' + fs;
    }
}

function initRelativeNews() {
    if (!datas.getRelationsData()
        || Object.prototype.toString.call(datas.getRelationsData()) !== '[object String]') {
        MultTaskCollaborator.complete(TASK_LOAD_RELATIVE_NEWS);
        return false;
    }
    var relativeNewsData = JSON.parse(datas.getRelationsData()), panel = document
        .getElementById('relativeNewsPanel'), list = panel
        .querySelector('ul.news-list'), TPL = '<li link-id="{{id}}">{{title}}</li>', content = '';

    if (relativeNewsData && relativeNewsData.length) {
        for ( var i = 0; i < relativeNewsData.length; i++) {
            content += TPL.replace(/{{(id|title)}}/g, function() {
                return relativeNewsData[i][arguments[1]];
            });
        }
        list.innerHTML = content;
        list.addEventListener(TAP, function(e) {
            var target = e.target;
            ifeng.jump('doc', target.getAttribute('link-id'));
        }, false);
        panel.style.display = 'block';
    }
    MultTaskCollaborator.complete(TASK_LOAD_RELATIVE_NEWS);
}
function initAdv(advData) {
    var advJson, advEl, itemEl, ITEM_FONT_SIZE = 20, itemFontAmount, doubleByteChars;
    if (!advData
        || Object.prototype.toString.call(advData) !== '[object String]') {
        MultTaskCollaborator.complete(TASK_LOAD_ADV);
        return false;
    }
    advEl = document.getElementById('adv');
    itemEl = document.getElementById('advItem');
    try {
        advJson = JSON.parse(decodeURIComponent(advData));
        itemFontAmount = Math.floor(IMAGE_PLACEHOLDER_WIDTH / ITEM_FONT_SIZE) - 3;
        doubleByteChars = advJson.text.match(/[^\x00-\xff]/ig);
        if (doubleByteChars && doubleByteChars.length) {
            itemFontAmount = Math.min(doubleByteChars.length, itemFontAmount) +
                2 * Math.max((itemFontAmount - doubleByteChars.length), 0);
        }
        itemEl.innerHTML = advJson.text.substr(0, itemFontAmount);

        document.getElementById('relativeNewsPanel').style.background = 'none';
        advEl.style.display = 'block';
        advEl.addEventListener(TAP, function(e) {
            ifeng.jump(advJson.adAction.type, advJson.adAction.url);
        }, false);
    } catch (e) {
        sendWebLog('Illegal json in adv data', decodeURIComponent(advData));
        console.log('Illegal json in adv data');
    }
    MultTaskCollaborator.complete(TASK_LOAD_ADV);
}

function initComment(commentData) {
    var commentEl, commentCountEl, container,
        commentJson, commentNum, commentList, commentListLen, commentListItem,
        commentListHtml = '';
    if (!commentData || Object.prototype.toString.call(commentData) !== '[object String]') {
        MultTaskCollaborator.complete(TASK_LOAD_COMMENT);
        return false;
    }

    try {
        commentJson = JSON.parse(decodeURIComponent(commentData));

        commentNum = commentJson.count || 0;
        commentList = commentJson.comments.hottest;
        commentListLen = Math.min(commentList.length, 5);

        commentCountEl = document.getElementById('comment_count_num');
        commentCountEl.innerHTML = commentNum;

        if(commentListLen === 0) {
            MultTaskCollaborator.complete(TASK_LOAD_COMMENT);
            return false;
        }

        commentEl = document.getElementById('comment');
        container = document.getElementById('comment_list');

        for(var i = 0; i < commentListLen; i++ ) {
            commentListItem = commentList[i];
            commentListHtml += '' +
                '<li class="comment-item">' +
                '<div class="comment-item-left">' +
                '<img src="comment_default_photo.png" class="comment-item-ava"/>' +
                '</div>' +
                '<div class="comment-item-right">' +
                '<div class="comment-item-title">凤凰网' + commentListItem.ip_from + '网友：</div>' +
                '<div class="comment-item-content">' + commentListItem.comment_contents + '</div>' +
                '</div>' +
                '</li>';
        }

        container.innerHTML = commentListHtml;
        commentEl.style.display = 'block';
    } catch (e) {
        sendWebLog('Illegal json in comment data', decodeURIComponent(commentData))
        console.log('Illegal json in comment data');
    }
    MultTaskCollaborator.complete(TASK_LOAD_COMMENT);
}

function fixImgNoteStyle() {
    var eles = Array.prototype.slice.call(document.getElementsByTagName('small')),
        ind, indH;

    for ( var i = 0; i < eles.length; i++) {
        ind = eles[i];
        indH = ind.clientHeight;

        if(indH && indH > 20) {
            ind.style.textAlign = 'left';
        }
    }
}

function showCommentsView() {
    ifeng.showCommentsView(datas.getDocumentId());
}

function formatText(text) {
    var fragment = document.createElement('div');
    fragment.innerHTML = text;
    var eles = Array.prototype.slice.call(fragment.getElementsByTagName('p'));
    for ( var i = 0; i < eles.length; i++) {
        var container = eles[i],
            imgs = Array.prototype.slice.call(container.getElementsByTagName('img'));

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
function preprocessImage(content, container) {
    var fragment = document.createElement('div');
    fragment.innerHTML = content;
    var imgEls = Array.prototype.slice.call(fragment
        .getElementsByTagName('img'));

    try{
        for ( var i = 0; i < imgEls.length; i++) {
            var img = imgEls[i],
                parent = img.parentNode,
                placeholder = document.createElement('p');

            placeholder.className = 'placeholder';
            placeholder.setAttribute('src', img.getAttribute('src'));
            placeholder.setAttribute('index', i);
            fragment.replaceChild(placeholder, parent);
        }
    }catch (e){
        sendWebLog('text img error', datas.getText());
    }

    var content = fragment.innerHTML;

    if (datas.getVideoSrc()) {
        var videoStr = '<p class="video" style="background-image:url(btn_play.png),url('
            + datas.getVideoPoster() + ')"></p>';
        content = videoStr + content;
    }
    container.innerHTML = content;
    if (datas.getVideoSrc()) {
        var video = container.getElementsByClassName('video')[0];
        video.addEventListener(TAP, function() {
            ifeng.playVideo();
        }, false);
    }

    setTimeout(loadImages, 200);
}

function loadImages() {
    var container = document.getElementById('content'),
        placeholders = Array.prototype.slice.call(container.getElementsByClassName('placeholder')),
        imgQuene = [], src, docId = datas.getDocumentId();

    var VIEWPORT_HEIGHT = window.innerHeight || document.documentElement.clientHeight;

    for ( var i = 0; i < placeholders.length; i++) {
        var imgDom = placeholders[i];

        src = imgDom.getAttribute('src');

        imgQuene.push({
            ot: imgDom.offsetTop,
            dom: imgDom,
            src: src
        })

        imgDom.addEventListener(TAP, function() {
            var index, src, isLoaded;
            index = parseInt(this.getAttribute('index'));
            src = this.getAttribute('src');
            isLoaded = (this.className).indexOf('loaded') > -1;

            if(isLoaded) {
                Ground.popupLightbox(src, loadImageSuccessInterceptor(this));
            } else {
                Ground.loadImage(src, docId,
                    loadImageSuccessInterceptor(this),
                    loadImageFailInterceptor(this, src));
            }
        }, false);
    }

    var scrollToLoad = function() {
        var bt = document.body.scrollTop + VIEWPORT_HEIGHT + VIEWPORT_HEIGHT;

        for(var j = 0, len = imgQuene.length; j < len; j++){
            var d = imgQuene[j];

            if(!d) continue;

            if(bt > d.ot){
                Ground.loadImage(d.src, docId,
                    loadImageSuccessInterceptor(d.dom),
                    loadImageFailInterceptor(d.dom, d.src));

                imgQuene[j] = false;
            }
        }
    }

    window.addEventListener('scroll', function() {
        throttle(scrollToLoad);
    }, false);

    scrollToLoad();
}

function loadImageSuccessInterceptor(placeholder) {
    return function(src, width, height) {
        var className = placeholder.className, result;
        if (className.indexOf('loaded') > -1) {
            return;
        }
        result = cropper.getResult(width, height);

        placeholder.style.backgroundSize = result.width + 'px ' + result.height + 'px';
        placeholder.style.backgroundImage = 'url(' + src + ')';
        placeholder.style.backgroundColor = 'transparent';
        placeholder.style.backgroundPosition = 'center center';
        placeholder.style.height =
            placeholder.style.minHeight =
                Math.min(result.height, IMAGE_PLACEHOLDER_HEIGHT) + 'px';
        placeholder.className = className + ' loaded';
    };
}
function loadImageFailInterceptor(placeholder, src) {
    return function() {
        sendWebLog('load img fail', src);
    };
}

function sendWebLog(type, msg, e) {
    var docId = datas.getDocumentId() || 'null doc id',
        eMsg = e && e.message ? e.message : 'null error msg';

    ifeng.webLog(docId + '---' + type + '---' + eMsg + '---' + msg);
}

function throttle(method, context) {
    clearTimeout(method.tId);
    method.tId = setTimeout(function(){
        method.call(context);
    }, 100);
}


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
        } else if (isFunction(fail)) {
            fail.apply(null, params);
        }
    }
    window['athene'] = athene;
})();

(function() {
    var Ground = {
        loadImage : function(src, documentId, success, fail) {
            athene.exec(success, fail, ifeng, ifeng.loadImage, [ src,
                documentId ]);
        },
        popupLightbox : function(src, success) {
            athene.exec(success, null, ifeng, ifeng.popupLightbox, [ src ]);
        },
        loadAdv : function(documentId, success, fail) {
            athene.exec(success, fail, ifeng, ifeng.loadAdv, [documentId]);
        },
        getHotComments: function(commentsUrl, documentId, success, fail) {
            athene.exec(success, fail, ifeng, ifeng.getHotComments, [commentsUrl, documentId]);
        }
    };

    window['Ground'] = Ground;
})();
(function() {
    var HAS_TOUCH = !!('ontouchstart' in window), START_EV = HAS_TOUCH ? 'touchstart'
        : 'mousedown', END_EV = HAS_TOUCH ? 'touchend' : 'mouseup', TAP_EV = '__tap__', DOUBLE_TAP_EV = '__doubletap__', MAIN_MOUSE_BUTTON_DOWN = 0, MIN_TAP_INTERVAL = 400, MAX_TAP_MOVEMENT = 10, isCancel = false, lastTapTimestamp = 0, touchstartEvent, touchendEvent;

    document.addEventListener(START_EV, function(e) {
        touchstartEvent = HAS_TOUCH ? e.touches[0] : e;
        if (HAS_TOUCH && e.touches.length > 1) {
            isCancel = true;
        }
    }, false);
    document.addEventListener(END_EV,
        function(e) {
            var absOffsetX, absOffsetY, tapInterval, eventName, ev;
            if (isCancel) {
                if (HAS_TOUCH && e.touches.length == 0) {
                    isCancel = false;
                }
                return false;
            }
            if (!HAS_TOUCH && e.button !== undefined
                && e.button !== MAIN_MOUSE_BUTTON_DOWN) {
                return false;
            }
            touchendEvent = HAS_TOUCH ? e.changedTouches[0] : e;
            absOffsetX = Math.abs(touchendEvent.pageX
                - touchstartEvent.pageX);
            absOffsetY = Math.abs(touchendEvent.pageY
                - touchstartEvent.pageY);
            tapInterval = e.timeStamp - lastTapTimestamp;
            if (absOffsetX < MAX_TAP_MOVEMENT
                && absOffsetY < MAX_TAP_MOVEMENT) {
                eventName = tapInterval > MIN_TAP_INTERVAL ? TAP_EV
                    : DOUBLE_TAP_EV;
                ev = document.createEvent('HTMLEvents');
                ev.initEvent(eventName, true, true);
                e.target.dispatchEvent(ev);
                lastTapTimestamp = e.timeStamp;
                isCancel = false;
            }
        }, false);

    window['TAP'] = TAP_EV;
    window['DOUBLE_TAP'] = DOUBLE_TAP_EV;
})();
(function() {

    var ScreenDetector = {
        MAX_RETRY_TIMES : 15,
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
            var self = this, currentDocWidth = document.body.clientWidth;

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