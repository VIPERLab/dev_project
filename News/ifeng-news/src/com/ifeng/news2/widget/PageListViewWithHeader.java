package com.ifeng.news2.widget;


import android.content.Context;
import android.support.v4.view.WindowCompat;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.view.animation.DecelerateInterpolator;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.ListAdapter;
import android.widget.Scroller;
import android.widget.TextView;

import com.ifeng.news2.R;
import com.ifeng.news2.util.WindowPrompt;
import com.ifeng.share.util.NetworkState;
import com.qad.form.PageManager;
import com.qad.util.IfengGestureDetector;
import com.qad.util.OnFlingListener;
import com.qad.util.WToast;
import com.qad.view.PageListView;

public class PageListViewWithHeader extends PageListView implements
OnScrollListener{

	// save event y
	private float mLastY = -1;
	// used for scroll back
	private Scroller mScroller;
	// user's scroll listener
	private OnScrollListener mScrollListener;
	// the interface to trigger refresh and load more.
	private ListViewListener mListViewListener;
	// header view
	private HeaderView mHeaderView;
	private View mFirstView;
	// header view content, use it to calculate the Header's height. And hide it
	// when disable pull refresh.
	private View mHeaderViewContent;

	private TextView mHeaderTimeView;
	
	private invokeHeadViewhandler headViewhandler;
	// header view's height
	private int mHeaderViewHeight;
	
	private int mHeaderViewDefaultHeight = 0;
	
	private boolean mEnablePullRefresh = true;
	// refresh state
	private boolean mPullRefreshing = false;
	// for mScroller, scroll back from header or footer.
	private int mScrollBack;
	private WToast wToast;
	private final static int SCROLLBACK_HEADER = 0;
	// scroll back duration
	private final static int SCROLL_DURATION = 450;
	// support iOS like pull feature.
	private final static float OFFSET_RADIO = 1.8f;
	
	private IfengGestureDetector detector = null;
	
	public boolean isStopScroll = false;
	public int scrollState = 0;
	//是否滑动
	public int visibleItemCount = 0;

	public PageListViewWithHeader(Context context, AttributeSet attrs) {
		super(context, attrs);
		initWithContext(context);
	}

	public PageListViewWithHeader(Context context, PageManager<?> pageManager,
			int flag, String loadButton, String loadingMsg, String loadErrorMsg) {
		super(context, pageManager, flag, loadButton, loadingMsg, loadErrorMsg);
		initWithContext(context);
	}

	public PageListViewWithHeader(Context context, PageManager<?> pageManager,
			int flag) {
		super(context, pageManager, flag);
		initWithContext(context);
	}
	
	public PageListViewWithHeader(Context context, PageManager<?> pageManager) {
		super(context, pageManager);
		initWithContext(context);
	}

	private void initWithContext(Context context) {
		wToast = new WToast(context);
		mScroller = new Scroller(context, new DecelerateInterpolator());
		// ListView need the scroll event, and it will dispatch the event to
		// user's listener (as a proxy).
		
		super.setOnScrollListener(this);
		// init header view
		mHeaderView = new HeaderView(context);
		mHeaderViewContent = mHeaderView
				.findViewById(R.id.header_content);
		mHeaderTimeView = (TextView) mHeaderView.findViewById(R.id.header_time);
		addHeaderView(mHeaderView);
		// init header height
		mHeaderView.getViewTreeObserver().addOnGlobalLayoutListener(
				new OnGlobalLayoutListener() {
					@Override
					public void onGlobalLayout() {
						mHeaderViewHeight = mHeaderView.getContentHight();
						getViewTreeObserver()
						.removeGlobalOnLayoutListener(this);
					}
				});
		//setDivider(getResources().getDrawable(drawable.channel_list_divider));
		setDividerHeight(0);
		setHeaderDividersEnabled(false);
	}

	@Override
	public void setAdapter(ListAdapter adapter) {
		super.setAdapter(adapter);
	}

	/**
	 * enable or disable pull down refresh feature.
	 * 
	 * @param enable
	 */
	public void setPullRefreshEnable(boolean enable) {
		mEnablePullRefresh = enable;
		if (!mEnablePullRefresh) { // disable, hide the content
			mHeaderViewContent.setVisibility(View.INVISIBLE);
		} else {
			mHeaderViewContent.setVisibility(View.VISIBLE);
		}
	}
	public boolean startRefresh(){
		if(!isNetworkActive()){
			return false;
		}
		if(!mPullRefreshing && scrollState==0){
			setSelection(0);
			mPullRefreshing=true;
			mHeaderView.restartLoading();
			mHeaderView.isShowRefreshLoading(true);
			mHeaderView.isShowRefreshDown(false);
			mHeaderView.setState(HeaderView.STATE_REFRESHING);
			mScroller.startScroll(0, mHeaderViewDefaultHeight, 0, mHeaderViewHeight + mHeaderViewDefaultHeight, SCROLL_DURATION);
			invalidate();
//			postDelayed(stopRunnable, REFRESH_TIMEOUT);
		}
		return true;
	}
	/**
	 * stop refresh, reset header view.
	 */
	public void stopRefresh() {
		//if (mPullRefreshing) {
		mPullRefreshing = false;
		resetHeaderHeight(mHeaderViewHeight);
		//}
	}
	/**
	 * set last refresh time
	 * 
	 * @param time
	 */
	public void setRefreshTime(String time) {
		mHeaderTimeView.setText(time);
	}

	private void invokeOnScrolling() {
		if (mScrollListener instanceof OnXScrollListener) {
			OnXScrollListener l = (OnXScrollListener) mScrollListener;
			l.onXScrolling(this);
		}
	}

	private void updateHeaderHeight(float delta) {
		mHeaderView.setVisibleHeight((int) delta + mHeaderView.getVisiableHeight());
		if (mEnablePullRefresh && !mPullRefreshing) { // 未处于刷新状态，更新箭头
			if (mHeaderView.getVisiableHeight() > mHeaderViewHeight) {
				mHeaderView.setState(HeaderView.STATE_READY);
			} else {
				mHeaderView.setState(HeaderView.STATE_NORMAL);
			}
		}
		//fix Bug #17980 [列表]下拉刷新列表时，页面抖动很厉害
		if(mHeaderViewDefaultHeight == 0) {
			setSelection(0); // scroll to top each time
		}		
	}
	/**
	 * reset header view's height.
	 */
	private void resetHeaderHeight(int height) {
		if (height < 0) // not visible.
			return;
		// refreshing and header isn't shown fully. do nothing.
		if (mPullRefreshing && height <= mHeaderViewHeight) {
			return;
		}
		int finalHeight = 0; // default: scroll back to dismiss header.
		// is refreshing, just scroll back to show all the header.
		if (mPullRefreshing && height > mHeaderViewHeight) {
			finalHeight = mHeaderViewHeight;
		}
		mScrollBack = SCROLLBACK_HEADER;
		mScroller.startScroll(0, height, 0, finalHeight - height,
				SCROLL_DURATION);
		// trigger computeScroll
		invalidate();
	}

	@Override
	public boolean onTouchEvent(MotionEvent ev) {
		if (null != detector&&detector.onTouchEvent(ev)) {
		       return true;
		}
		if(!isStopScroll){
			if (mLastY == -1) {
				mLastY = ev.getRawY();
			}
			if(mHeaderView.getState() != HeaderView.STATE_REFRESHING){
				mHeaderView.isShowRefreshLoading(false);
				mHeaderView.isShowRefreshDown(true);
			}
		}
		switch (ev.getAction()) {
		case MotionEvent.ACTION_DOWN:
			mLastY = ev.getRawY();
			isStopScroll = false;
			break;
		case MotionEvent.ACTION_MOVE:
			if(isStopScroll){
				return true;
			}
			final float deltaY = ev.getRawY() - mLastY;
			mLastY = ev.getRawY();
			if(headViewhandler!=null){
				headViewhandler.invokeHeadView(mHeaderView.getBottom());
			}
			if (isScollerTop()
					&& (mHeaderView.getVisiableHeight() > 0 || deltaY > 0)) {
				// the first item is showing, header has shown or pull down.
				updateHeaderHeight(deltaY / OFFSET_RADIO);
				invokeOnScrolling();
			}
			break;
		default:
			if(isStopScroll){
				return true;
			}
			mLastY = -1; // reset
			if (isScollerTop()) {
				// invoke refresh
				if (mEnablePullRefresh && mHeaderView.getVisiableHeight() > mHeaderViewHeight) {
					if(!isNetworkActive()){
						stopRefresh();
						return false;
					}
					mPullRefreshing = true;
					mHeaderView.setState(HeaderView.STATE_REFRESHING);
					mHeaderView.isShowRefreshLoading(true);
					mHeaderView.isShowRefreshDown(false);
					if (mListViewListener != null) {
						mListViewListener.onRefresh();
					}
//					postDelayed(stopRunnable, REFRESH_TIMEOUT);
				}
				resetHeaderHeight(mHeaderView.getVisiableHeight());
				
			}
			break;
		}
		return super.onTouchEvent(ev);
	}
	
	public void forceFinished(){
		stopRefresh();
		mHeaderView.setVisibleHeight(0);
		mScroller.forceFinished(true);
	}
	public Boolean isNetworkActive(){
		if(!NetworkState.isActiveNetworkConnected(getContext())){
			WindowPrompt.getInstance(getContext()).showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
			return false;
		}
		return true;
	}
	@Override
	public void computeScroll() {
		if (mScroller.computeScrollOffset()) {
			if(headViewhandler!=null){
				headViewhandler.invokeHeadView(getScrollY());
			}
			if (mScrollBack == SCROLLBACK_HEADER) {
				mHeaderView.setVisibleHeight(mScroller.getCurrY());
			}
			invalidate();
			invokeOnScrolling();
		}
		super.computeScroll();
	}

	@Override
	public void setOnScrollListener(OnScrollListener l) {
		mScrollListener = l;
	}

	@Override
	public void onScrollStateChanged(AbsListView view, int scrollState) {
		this.scrollState = scrollState;
		if (mScrollListener != null) {
			mScrollListener.onScrollStateChanged(view, scrollState);
		}
	}

	@Override
	public void onScroll(AbsListView view, int firstVisibleItem,
			int visibleItemCount, int totalItemCount) {			
		if(this.visibleItemCount == 0){
			this.visibleItemCount = visibleItemCount;
		}	
		// send to user's listener
		if (mScrollListener != null) {
			mScrollListener.onScroll(view, firstVisibleItem, visibleItemCount,
					totalItemCount);
		}
	}
	
	public void setOnFlingListener(OnFlingListener listener) {
		detector = IfengGestureDetector.getInsensitiveIfengGestureDetector(listener);
	}

	public void setListViewListener(ListViewListener l) {
		mListViewListener = l;
	}

	/**
	 * you can listen ListView.OnScrollListener or this one. it will invoke
	 * onXScrolling when header/footer scroll back.
	 */
	public interface OnXScrollListener extends OnScrollListener {
		public void onXScrolling(View view);
	}

	/**
	 * implements this interface to get refresh/load more event.
	 */
	public interface ListViewListener {
		public void onRefresh();
	}

	public int getHeaderState() {
		return mHeaderView.getState();
	}
	public View getHeaderView(){
		return mHeaderView;
	}
	
	public View getFirstView(){
		return mFirstView; 
	}
	
	public void setHeaderViewDefaultHeight(int height){ 
		if(this.mHeaderViewDefaultHeight!=height){
			mHeaderViewDefaultHeight = height;
			mHeaderView.setDefaultHeaderViewHeight(height);
			updateHeaderHeight(mHeaderViewDefaultHeight);
		}
	}

	private boolean isScollerTop(){
		if(mHeaderViewDefaultHeight>0){
			return true;
		}else if(getFirstVisiblePosition()==0){
			return true;
		}
		return false;
	}
	
	public interface invokeHeadViewhandler {
		public void invokeHeadView(int height);
	} 
	
	public void setHeadViewhandler(invokeHeadViewhandler headViewhandler) {
		this.headViewhandler = headViewhandler;
	}
	
	/**
	 * 做必要的清理工作以确保列表相关内存能够被回收
	 * GifView会导致内存被保留
	 */
	public void cleanup() {
		removeHeaderView(mHeaderView);
		super.cleanup();
	}

}
