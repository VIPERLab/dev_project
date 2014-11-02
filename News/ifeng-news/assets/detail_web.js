var ifeng = {
    isSupportFullscreen: document.webkitFullscreenEnabled === true ? true : false,
    CallbackStatus: {
        OK: 1,
        ERROR: 0
    },
    hasStared: function() {
        return true;
    },
    share: function() {
        console.log('shared');
    },
    toggleStar: function() {
        console.log('star toggled');
    },
    toggleFullScreen: function() {
        this._isFullscreen === true ? this._cancelFullscreen() : this._requestFullscreen();
    },
    _isFullscreen: false,
    _requestFullscreen: function() {
        this.isSupportFullscreen ? document.body.webkitRequestFullScreen() : console.log('fullscreen!');
        this._isFullscreen = true;
    },
    _cancelFullscreen: function() {
        this.isSupportFullscreen ? document.webkitCancelFullScreen() : console.log('cancel fullscreen!');
        this._isFullscreen = false;
    },
    playVideo: function() {
        console.log('play video');
    },
    loadImage: function(callbackId, src, documentId) {
        var image = new Image();
        image.addEventListener('load', function(e) {
            var target = e.target;
            setTimeout(function() {
                athene.complete(callbackId, ifeng.CallbackStatus.OK, target.getAttribute('src'), target.width, target.height);
            }, Math.random() * 3000);
        }, false);
        image.addEventListener('error', function(e) {
            athene.complete(callbackId, ifeng.CallbackStatus.ERROR);
        }, false);
        image.src = src;
    },
    popupLightbox: function(callbackId, src) {
        console.log('popup lightbox url=' + src);
        ifeng.loadImage(callbackId, src);
    },
    isLoadImageEnable: function() {
        return false;
    },
    jump: function(type, url) {
        console.log(type, url);
    },
    loadAdv: function(callbackId) {
        setTimeout(function() {
            var advData = '{"adId": "10000050","adStartTime": 1359015540,"adEndTime": 1359620340,"text": "正在测试正在测试正在测试正","adAction": {"type": "browser","url": "http://online.3g.ifeng.com/ad/client.php?vt=5&adid=10000050&ps=0&v=5&mid=9WvEqQ"}}';
            athene.complete(callbackId, ifeng.CallbackStatus.OK, advData);
        }, Math.random() * 1000);
    },
    getCommentsAmount: function(callbackId) {
        athene.complete(callbackId, ifeng.CallbackStatus.OK, Math.round(Math.random() * 20000));
    },
    getHotComments: function(callbackId) {
        var mockData = '{"count":"' + Math.round(Math.random() * 50000) + '","join_count":111,"comments":{"hottest":[{"comment_contents":"\u6350\u7ed9\u6211\u597d\u4e86\u601d\u871c\u8fbe","comment_date":"2013-04-10  07:44","uname":"\u624b\u673a\u7528\u6237","ip_from":"\u5317\u4eac\u5e02","uptime":"7","usrIcon":"http:\/\/s3.mimg.ifeng.com\/upload\/day_130411\/201304111746054751.png"},{"comment_contents":"\u8bc4\u8bba\u8005\u4e0d\u8981\u8fd8\u5728\u94b1\u773c\u91cc\u6323\u624e,\u6211\u8d5e\u8d4f\u8fd9\u6b21\u56fd\u4e52\u6559\u7ec3\u7684\u5904\u7f6e\u5efa\u8bae\uff01","comment_date":"2013-04-10  10:19","uname":"\u624b\u673a\u7528\u6237","ip_from":"\u5317\u4eac\u5e02","uptime":"5","usrIcon":"http:\/\/s3.mimg.ifeng.com\/upload\/day_130411\/201304111746054751.png"},{"comment_contents":"\u6536\u7740\u5427\uff0c\u4eba\u5bb6\u53cb\u597d\u7684\u4e00\u70b9\u5fc3\u610f\u3002","comment_date":"2013-04-10  07:23","uname":"\u624b\u673a\u7528\u6237","ip_from":"\u5317\u4eac\u5e02","uptime":"3","usrIcon":"http:\/\/s3.mimg.ifeng.com\/upload\/day_130411\/201304111746054751.png"},{"comment_contents":"\u6cf1\u6cf1\u5927\u56fd!\u8fd0\u52a8\u5458\u7684\u5408\u6cd5\u6536\u5165\u5c31\u8fd9\u6837\u9001\u4eba\u4e86!\u4e0d\u5728\u6c11\u95f4\u4e0d\u77e5\u6c11\u95f4\u75be\u82e6\u554a","comment_date":"2013-04-10  10:55","uname":"\u624b\u673a\u7528\u6237","ip_from":"\u5317\u4eac\u5e02","uptime":"2","usrIcon":"http:\/\/s3.mimg.ifeng.com\/upload\/day_130411\/201304111746054751.png"},{"comment_contents":"\u548c\u961f\u5458\u5546\u91cf\u4e86\u5417\uff1f\u4f60\u6709\u5565\u8d44\u683c\u81ea\u5df1\u5b9a\u3002","comment_date":"2013-04-10  11:16","uname":"\u624b\u673a\u7528\u6237","ip_from":"\u5317\u4eac\u5e02","uptime":"2","usrIcon":"http:\/\/s3.mimg.ifeng.com\/upload\/day_130411\/201304111746054751.png"}]}}';
        setTimeout(function() {
            athene.complete(callbackId, ifeng.CallbackStatus.OK, mockData);
        }, Math.random() * 2000);

    },
    hideLoadingMask: function() {
        console.log('hideLoadingMask')
    },
    showCommentsView: function() {
        alert('show comments view')
    }
};
var datas = {
    _data: {
        "meta": {
            "id": "http://api.3g.ifeng.com/jpaddoc?imgwidth=300&aid=37943032&channel=%E5%A8%B1%E4%B9%90&chid=5&vt=2&piece=3",
            "type": "doc",
            "updateTime": "2012-06-13 10:26:25",
            "expiredTime": 21600000,
            "class": "20000226"
        },
        "resources": [
            {
                "name": "",
                "src": "http://y3.ifengimg.com/ba335e69308f03f3/2012/0613/rdn_4fd7e5bab0d84.jpg"
            },
            {
                "name": "",
                "src": "http://y3.ifengimg.com/ba335e69308f03f3/2012/0613/rdn_4fd7e5ba4a111.jpg"
            }
        ],
        "body": {
            "cate": "http://api.3g.ifeng.com/jpadnews?id=api.3g.ifeng.com/aid=0053&imgwidth=300&type=list&pagesize=20",
            "documentId": "imcp_37943032",
            "title": "崔永元：我依然坚持对湖南教育厅“三不”评价",
            "author": "",
            "source": "北京晨报快讯出版社",
            "editTime": "2012-06-13 09:00:00",
            "wapurl": "http://api.3g.ifeng.com/news?aid=37943032",
            "channel": "娱乐",
            "introduction": "",
            "wwwurl": "http://ent.ifeng.com/idolnews/mainland/detail_2012_06/13/15257673_0.shtml",
            "commentCount": "",
            "text": "<p>三星与苹果的关系真够拧巴的。<\/p><p>国外媒体送出的研究数据显示，目前三星处理器80%的收入都是来自苹果，这与三星是苹果自家处理器代工商密不可分，不过之前的消息显示，与三星的合同到期后，苹果已经将自己处理器代工的业务交给了台积电。<\/p><p>虽说苹果去三星化态度是坚决的，但是从目前的情况来看，他们还要依靠三星。之前韩国媒体给出的消息显示，本国轻薄玻璃面板之所以出现增长，完全得益于苹果抛向了三星许多订单，而他们大规模采购的轻薄面板将会用于iPhone、iPad以及MacBook等产品上。<\/p><p>由于产能等因素制约，苹果可能不会一下子把自己处理器代工的业务交给台积电，但他们的终极愿望是完全抛弃三星。对于苹果这位大财主，三星也在私下极力的缓和他们之家的关系。<\/p><p>毕竟在利益面前没有绝对的朋友也没有绝对的敌人，不是吗？<\/p><p>没想象的那么扁平！iOS 7更多细节曝光<\/p><p>苹果拒绝大屏！iPhone 5S\/低价iPhone 5量产<\/p><p style=\"text-align:center\"><img longdesc=\"IC Insights统计的2012年前十位MPU（微处理器）厂商的营收和市场份额\" src=\"http:\/\/res01.mimg.ifeng.com\/g?url=http:\/\/y0.ifengimg.com\/tech_spider\/dci_2013\/06\/ae42e2341bec28e6559926265677303c.jpg&w=320&h=-1&v=867c915571&r=1\" \/><\/p><p><small>IC Insights统计的2012年前十位MPU（微处理器）厂商的营收和市场份额<\/small><\/p><p>【新闻链接】<\/p><p>研究称三星2012年芯片制造业营业额80%来自苹果<\/p><p>【TechWeb报道】6月4日消息，据国外媒体报道，研究机构Digitimes Research发布数据显示，三星公司2012年芯片制造业营业额的80%是由苹果公司贡献的。<\/p><p>数据显示，三星芯片制造业营业额另外20%的贡献者是高通、德州仪器、Xilinx、Marvell、STMicroelectronics、东芝、Renesas。<\/p><p>Quartz网站称，在2012年，三星斥资70亿美元升级芯片制造工厂。值得一提的是，其中一个主要工厂位于美国德州奥斯汀市，它获得了40亿美元的投资，而该工厂负责生产苹果iPad 5和iPhone 5芯片。<\/p><p>苹果研发“视线检测”技术 对抗三星眼球滚动翻页<\/p><p style=\"text-align:center\"><img src=\"http:\/\/res01.mimg.ifeng.com\/g?url=http:\/\/y1.ifengimg.com\/a128e318c4b5c830\/2013\/0531\/rdn_51a8007e624b0.jpg&w=320&h=-1&v=279cde05b7&r=1\" \/><\/p><p>三星Galaxy S4手机采用了“眼球滚动翻页（Smart Scroll）”技术<\/p><p>凤凰科技讯 北京时间5月30日消息，据外国媒体AppleInsider报道称，据美国专利商标局（USPTO）公布的一项专利显示，苹果又一次将目光投向“视线检测（gaze detection）”眼球跟踪技术，未来或将在其iOS产品中应用。苹果此举或许旨在回应三星最新旗舰机Galaxy S4智能手机的“眼球滚动翻页（Smart Scroll）”技术。<\/p><p>美国专利商标局公布的苹果这项专利名为“搭载视线检测功能的电子设备”，该专利为苹果2008年9月申请主专利的一个附加分支专利。苹果该主专利于2010年获得授权。苹果该专利描述的系统可以利用前置摄像头检测用户视线是否集中在设备上。此外专利中还提到利用加速度计，当检测到设备移动时，便会关闭视线检测系统。<\/p><p>在实际应用中，如果该系统确定用户视线是集中在设备上，那显示屏将会以适度的亮度亮起。相反，如果用户视线检测确定从设备上飘走，或者加速度计检测到设备的移动参数大于移动的界限，显示屏则会灰暗。<\/p><p>在其他应用中，如果视线检测未达到条件，该设备可进入待机模式。一旦用户视线又被检测到集中在显示屏上，该设备将会退出待机模式，激活所有功能。另外，实体输入如按键也可以激活设备回到活跃状态。<\/p><p>尽管该发明从许多方面来看都是一种节能措施，但苹果在专利中还提到一种用该视线检测技术来控制媒体回放的功能：“例如，当设备在活跃状态下播放视频时，如果设备检测到用户视线不再集中于设备上，该电子设备可以进入待机模式，放暗显示屏，暂停视频播放。此外根据用户需要，如果该电子设备再次检测到视线集中于设备，则可继续播放视频。”<\/p><p>由于今天公布的该专利为分支专利，其中隐去了一些苹果此前专利的陈述。根据苹果专利文件显示，苹果似乎集中在研发眼球跟踪技术，其中包括视线跟踪系统带来的播放功能控制、节能特色等。<\/p><p>三星目前正在其旗舰机Galaxy S4中应用类似的功能，称为“眼球滚动翻页（Smart Scroll）”技术，还技术很多应用方式均与苹果该专利相似，也是利用设备的前置摄像头，跟踪用户眼球的移动然后放暗显示屏或者暂停媒体播放。三星的应用更为广泛，还包括网页以及电子邮件的滚动浏览功能。<\/p><p>有趣的是，2013年1月24日美国专利商标局（USPTO）将“眼球暂停（Eye Pause）”商标权发放给了三星，而这天正是苹果提交该分支专利申请的前一天。此后2月三星又提交了“眼球滚动（Eye Scroll）”商标申请，以及在3月8号即Galaxy S4发布前六天提交了“三星智能滚动（Samsung Smart Scroll）”商标申请。<\/p><p>尽管苹果最初的视线检测专利早在2008年就已经启动，三星也拥有类似的眼球跟踪专利。据猜测苹果或在试图打造眼球跟踪技术更加优秀的应用，以抗衡不断壮大的三星电子公司。（编译\/小邝）<\/p>",
            "videoPoster": "http://res01.mimg.ifeng.com/g?url=http%3A%2F%2Fimg.ifeng.com%2Fitvimg%2F%2F2012%2F06%2F13%2F68fdfb95-6d7f-4a6f-b29f-9f12aa226994.jpg&amp;w=160&amp;h=-1&amp;v=ccd070ab3c&amp;r=1",
            "videoSrc": "http://api.3g.ifeng.com//download?aid=37943032&amp;url=http://3gs.ifeng.com/userfiles/video/2012/06/13/f41f1ca5-5809-4dd3-b908-f5e3c1296cbb280.mp4&amp;mid=8zuhEn&amp;vt=2"
        }
    },

    getTitle: function() {
        return this._data.body.title;
    },
    getSource: function() {
        return this._data.body.source;
    },
    getEditTime: function() {
        return this._data.body.editTime;
    },
    getText: function() {
        return this._data.body.text;
    },
    getVideoPoster: function() {
        return this._data.body.videoPoster;
    },
    getVideoSrc: function() {
        return this._data.body.videoSrc;
    },
    getRelationsData: function() {
        return JSON.stringify([{
            title: "新浪出手整治，微博发广告赚钱难了",
            id: "100001"
        }, {
            title: "希拉里不言退休引猜测",
            id: "100002"
        }]);
    },
    getDocumentId: function() {
        return this._data.body.documentId;
    },
    getAdvData: function() {
        return '{"adAction":{"type":"webfull","url":"http://online.3g.ifeng.com/ad/client.php?vt\u003d5\u0026adid\u003d10000005\u0026ps\u003d0\u0026v\u003d5\u0026mid\u003d6igdfh"},"adConditions":{"index":-1},"adEndTime":"1359613320","adId":"10000005","adStartTime":"1357539720","imageURL":"","longTitle":"","shortTitle":"","text":"借钱不再难以启齿,找平安"}';
    },
    getCommentsUrl: function() {

    },
    getFontSize: function() {
        return 'big';
    }
};

function flagStar(hasStared)
{
    var favouriteButton=document.getElementById('favourite');
    if(hasStared)
        favouriteButton.style.backgroundImage='url(btn_star.png)';
    else
        favouriteButton.style.backgroundImage='url(btn_star_active.png)';
}

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
        console.log('task [' + name + '] completed!');
        if (this._taskQueue.length === 0) {
            this._callback();
        }
    }
};

var cropper,
    IMAGE_PLACEHOLDER_WIDTH,
    IMAGE_PLACEHOLDER_HEIGHT,
    PLACEHOLDER_SLOPE = 174 / 294,
    MAX_SLOPE = 174 / 150,
    MIN_SLOPE = 100 / 294,
    MIN_ZOOM_WIDTH, MIN_ZOOM_HEIGHT,
    TASK_LOAD_ADV = 'loadAdv',
    TASK_LOAD_RELATIVE_NEWS = 'loadRelativeNews',
    TASK_LOAD_COMMENT = 'loadComment';

window.addEventListener('deviceready', init, false);

function init() {
    MultTaskCollaborator.setOnAllComplete(function() {
        launchPageBottomDetector();

        document.addEventListener(REACH_PAGE_BOTTOM, function(e) {
            console.log('reach page bottom');
        }, false);
        document.addEventListener(LEAVE_PAGE_BOTTOM, function(e) {
            console.log('leave page bottom');
        }, false);

        var event = document.createEvent('HTMLEvents');
        event.initEvent('scroll', false, true);
        window.dispatchEvent(event);
    }).register(TASK_LOAD_ADV)
        .register(TASK_LOAD_RELATIVE_NEWS)
        .register(TASK_LOAD_COMMENT);

    IMAGE_PLACEHOLDER_WIDTH = document.getElementById('content').clientWidth;
    IMAGE_PLACEHOLDER_HEIGHT = Math.round(IMAGE_PLACEHOLDER_WIDTH
        * PLACEHOLDER_SLOPE);
    MIN_ZOOM_WIDTH = Math.round(IMAGE_PLACEHOLDER_HEIGHT / MAX_SLOPE);
    MIN_ZOOM_HEIGHT = Math.round(IMAGE_PLACEHOLDER_WIDTH * MIN_SLOPE);
    cropper = new ImageCropper(new StandPlaceholderCropStrategy(
        IMAGE_PLACEHOLDER_WIDTH, IMAGE_PLACEHOLDER_HEIGHT, MIN_ZOOM_WIDTH,
        MIN_ZOOM_HEIGHT));
    var sheet = document.getElementsByTagName('link')[0].sheet;
    sheet.insertRule('.content .placeholder {min-height:'
        + IMAGE_PLACEHOLDER_HEIGHT + 'px}');
    sheet.insertRule('.content .video {min-height:' + IMAGE_PLACEHOLDER_HEIGHT
        + 'px}');

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

    fixImgNoteStyle();

    initRelativeNews();

    initAdv(datas.getAdvData());

    Ground.getHotComments(initComment);

    document.getElementById('comment_count_btn').addEventListener(TAP, showCommentsView, false);
    document.getElementById('comment_more_btn').addEventListener(TAP, showCommentsView, false);

    setTimeout(function() {
        ifeng.hideLoadingMask(datas.getDocumentId());
    }, 20);
}
// 为了通知java层是否显示广告sdk而做的事件派发。需要派发到达页面底部REACH_PAGE_BOTTOM和离开页面底部LEAVE_PAGE_BOTTOM这两个事件
function launchPageBottomDetector() {
    var VIEWPORT_HEIGHT = window.innerHeight || document.documentElement.clientHeight,
        DOC_BODY_HEIGHT = document.body.scrollHeight,
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
        MultTaskCollaborator.complete(TASK_LOAD_RELATIVE_NEWS);
    }
}
function initAdv(advData) {
    var advJson, advEl, itemEl, ITEM_FONT_SIZE = 20, itemFontAmount, contentWidth = document
            .getElementById('content').clientWidth,
        doubleByteChars;
    if (!advData
        || Object.prototype.toString.call(advData) !== '[object String]') {
        MultTaskCollaborator.complete(TASK_LOAD_ADV);
        return false;
    }
    advEl = document.getElementById('adv');
    itemEl = document.getElementById('advItem');
    try {
        advJson = JSON.parse(advData);
        itemFontAmount = Math.floor(contentWidth / ITEM_FONT_SIZE) - 3;
        doubleByteChars = advJson.text.match(/[^\x00-\xff]/ig);
        if (doubleByteChars && doubleByteChars.length) {
            itemFontAmount = Math.min(doubleByteChars.length, itemFontAmount) + 2 * Math.max((itemFontAmount - doubleByteChars.length), 0);
        }

        itemEl.innerHTML = advJson.text.substr(0, itemFontAmount);

        document.getElementById('relativeNewsPanel').style.background = 'none';
        advEl.style.display = 'block';
        advEl.addEventListener(TAP, function(e) {
            ifeng.jump(advJson.adAction.type, advJson.adAction.url);
        }, false);
        MultTaskCollaborator.complete(TASK_LOAD_ADV);
    } catch (e) {
        console.log('Illegal json in adv data');
    }
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
        commentJson = JSON.parse(commentData);

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
                '<img src="default_ava.png" class="comment-item-ava"/>' +
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
    for ( var i = 0; i < imgEls.length; i++) {
        var img = imgEls[i],
            parent = img.parentNode,
            placeholder = document.createElement('p');

        placeholder.className = 'placeholder';
        placeholder.setAttribute('src', img.getAttribute('src'));
        placeholder.setAttribute('index', i);
        fragment.replaceChild(placeholder, parent);
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
    document.addEventListener(TAP, function(e) {
        var target = e.target, index, src;
        if (target.className.indexOf('placeholder') > -1) {
            index = parseInt(target.getAttribute('index'));
            src = target.getAttribute('src');
            Ground.popupLightbox(src, loadImageSuccessInterceptor(target,
                index));
        }
    }, false);

    loadImages();
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
    }

    var scrollToLoad = function() {
        var bt = document.body.scrollTop + VIEWPORT_HEIGHT + 20;

        for(var j = 0, len = imgQuene.length; j < len; j++){
            var d = imgQuene[j];

            if(!d) continue;

            if(bt > d.ot){
                Ground.loadImage(d.src, docId,
                    loadImageSuccessInterceptor(d.dom),
                    loadImageFailInterceptor(d.dom));

                imgQuene[j] = false;
            }
        }
    }

    window.addEventListener('scroll', function() {
        throttle(scrollToLoad);
    }, false);
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
function loadImageFailInterceptor(placeholder) {
    return function() {
        // placeholder.style.backgroundImage = 'url(bg_no_pic.png)';
    };
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
        },
        isFunction = function (v) {
            return toString(v) === '[object Function]';
        },
        athene = {},
        CALLBACK_PREFIX = 'callback__',
        callbacks = {},
        callbackCount = 0,
        CallbackStatus = {
            OK: 1
        };
    athene.exec = function(success,fail,service,action,params) {
        var callbackId = CALLBACK_PREFIX + callbackCount++;
        callbacks[callbackId] = {
            success: success,
            fail: fail
        };
        params = Array.prototype.concat.call([], callbackId, params || []);
        action.apply(service, params);
    };
    athene.complete = function() {
        if (arguments.length < 2) {
            throw new Error('Missing essential arguments');
        }
        var callbackId = arguments[0],
            status = arguments[1],
            callback = callbacks[callbackId],
            params = Array.prototype.slice.call(arguments, 2),
            success,fail;
        delete callbacks[callbackId];
        if (!callback) {
            return;
        }
        success = callback.success;
        fail = callback.fail;
        if (status == CallbackStatus.OK && isFunction(success)) {
            success.apply(null,params);
        } else if (isFunction(fail)) {
            fail.apply(null,params);
        }
    }
    window['athene'] = athene;
})();

(function(){
    var Ground = {
        loadImage: function(src, documentId, success, fail) {
            athene.exec(success, fail, ifeng, ifeng.loadImage, [src, documentId]);
        },
        popupLightbox: function(src, success) {
            athene.exec(success, null, ifeng, ifeng.popupLightbox, [src]);
        },
        loadAdv: function(success) {
            athene.exec(success, null, ifeng, ifeng.loadAdv);
        },
        getCommentsAmount: function(success) {
            athene.exec(success, null, ifeng, ifeng.getCommentsAmount);
        },
        getHotComments: function(success, fail) {
            athene.exec(success, fail, ifeng, ifeng.getHotComments);
        }
    };

    window['Ground'] = Ground;
})();

(function() {
    var HAS_TOUCH = !!('ontouchstart' in window) ,
        START_EV = HAS_TOUCH ? 'touchstart' : 'mousedown',
        END_EV = HAS_TOUCH ? 'touchend' : 'mouseup',
        TAP_EV = '__tap__',
        DOUBLE_TAP_EV = '__doubletap__',
        MAIN_MOUSE_BUTTON_DOWN = 0,
        MIN_TAP_INTERVAL = 400,
        MAX_TAP_MOVEMENT = 10,
        isCancel = false,
        lastTapTimestamp = 0,
        touchstartEvent,
        touchendEvent;

    document.addEventListener(START_EV, function(e) {
        touchstartEvent = HAS_TOUCH ? e.touches[0] : e;
        if (HAS_TOUCH && e.touches.length > 1) {
            isCancel = true;
        }
    }, false);
    document.addEventListener(END_EV, function(e) {
        var absOffsetX, absOffsetY,
            tapInterval,
            eventName,
            ev;
        if(isCancel) {
            if (HAS_TOUCH && e.touches.length == 0) {
                isCancel = false;
            }
            return false;
        }
        if (!HAS_TOUCH && e.button !== undefined && e.button !== MAIN_MOUSE_BUTTON_DOWN) {
            return false;
        }
        touchendEvent = HAS_TOUCH ? e.changedTouches[0] : e;
        absOffsetX = Math.abs(touchendEvent.pageX - touchstartEvent.pageX);
        absOffsetY = Math.abs(touchendEvent.pageY - touchstartEvent.pageY);
        tapInterval = e.timeStamp - lastTapTimestamp;
        if(absOffsetX < MAX_TAP_MOVEMENT && absOffsetY < MAX_TAP_MOVEMENT){
            eventName = tapInterval > MIN_TAP_INTERVAL ? TAP_EV : DOUBLE_TAP_EV;
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