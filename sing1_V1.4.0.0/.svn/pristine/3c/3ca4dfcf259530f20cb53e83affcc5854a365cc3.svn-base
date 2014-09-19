package cn.kuwo.sing.widget;

import android.content.Context;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;

/**
 * 
 * @author wangming
 * 自定义ScrollView
 *
 */
public class KuwoLazyScrollView extends ScrollView {
	private final String TAG = "KuwoLazyScrollView";
	private float mLastY = -1; // save event y
	private final static float OFFSET_RADIO = 1.8f; 
	private static final int HANDLER_WHAT = 13;
	private OnScrollListener mOnScrollListener;
	private KuwoViewFooter mFooterView;
	private KuwoViewHeader mHeaderView;
	private RelativeLayout mHeaderViewContent;
	private TextView mHeaderTimeView;
	private int mHeaderViewHeight; // header view's height
	private boolean mPullRefreshing = false; // is refreashing.
	private KuwoLazyScrollViewListener mLazyScrollViewListener;
	// 拉动标记
	private boolean isDragging = false;
	private boolean mPullLoading;
	private ViewGroup mView;
	private Handler mHandler;
	private int lastX;
	private int lastY;
	
	public KuwoLazyScrollView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		mFooterView = new KuwoViewFooter(context);
		mHeaderView = new KuwoViewHeader(context);
		mHeaderViewContent = (RelativeLayout) mHeaderView.findViewById(R.id.xlistview_header_content);
		mHeaderTimeView = (TextView) mHeaderView.findViewById(R.id.xlistview_header_time);
		mHeaderView.getViewTreeObserver().addOnGlobalLayoutListener(
				new OnGlobalLayoutListener() {
					@Override
					public void onGlobalLayout() {
						mHeaderViewHeight = mHeaderViewContent.getHeight();
						getViewTreeObserver()
								.removeGlobalOnLayoutListener(this);
					}
				});
	}
	
	public KuwoLazyScrollView(Context context, AttributeSet attrs) {
		this(context, attrs, 0);
	}
	
	public KuwoLazyScrollView(Context context) {
		this(context, null);
	}
	
	public interface OnScrollListener {
		void onTop();
		void onBottom();
		void onScroll();
		void onAutoScroll(int l, int t, int oldl, int oldt);
	}
	
	public void setOnScrollListener(OnScrollListener onScrollListener) {
		mOnScrollListener = onScrollListener;
	}
	
	@Override
	protected void onScrollChanged(int l, int t, int oldl, int oldt) {
		super.onScrollChanged(l, t, oldl, oldt);
		mOnScrollListener.onAutoScroll(l, t, oldl, oldt);
	}
	
	/**
	 * 暴露给外部的方法
	 */
	public void getView() {
		mView = (ViewGroup) getChildAt(0);
		if(mView != null) {
			init();
		}
	}

	private void init() {
		
		setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent ev) {
				switch (ev.getAction()) {
				case MotionEvent.ACTION_DOWN:
					break;
				case MotionEvent.ACTION_MOVE:
					if (mView != null && mOnScrollListener != null) {
						if (mView.getHeight() - 40 <= getScrollY() + getHeight()) {
							KuwoLog.i(TAG, "onBottom...");
							if(mView.findViewWithTag("footerView") == null) {
								KuwoLog.i(TAG, "add footerView...");
								mView.addView(mFooterView);
								mFooterView.setTag("footerView");
								mFooterView.setState(KuwoViewFooter.STATE_NORMAL);
								mFooterView.setOnClickListener(new OnClickListener() {
									
									@Override
									public void onClick(View v) {
										KuwoLog.i(TAG, "footerView onClick...");
										startLoadMore();
									}
								});
							}
							mOnScrollListener.onBottom();
						} else if (getScrollY() == 0) {
							KuwoLog.i(TAG, "onTop...");
							mOnScrollListener.onTop();
							if(mView.findViewWithTag("headerView") == null) {
								KuwoLog.i(TAG, "add headerView...");
								LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, mHeaderView.getHeight());
								params.gravity = Gravity.CENTER;
								params.topMargin = mHeaderView.getHeight();
								mView.addView(mHeaderView, params);
								mHeaderView.setTag("headerView");
								mHeaderView.setState(KuwoViewHeader.STATE_NORMAL);
							}
						} else {
							if (mOnScrollListener != null) {
								KuwoLog.i(TAG, "onScroll...");
								mOnScrollListener.onScroll();
							}
						}
					}
					break;
				default:
					break;
				}
				return false;
			}
		});
	}
	
	private void startLoadMore() {
		mPullLoading = true;
		mFooterView.setState(KuwoViewFooter.STATE_LOADING);
		if (mLazyScrollViewListener != null) {
			mLazyScrollViewListener.onLoadMore();
		}
	}
	
	public void setKuwoLazyScrollViewListener(KuwoLazyScrollViewListener listener) {
		mLazyScrollViewListener = listener;
	}
	
	/**
	 * implements this interface to get refresh/load more event.
	 */
	public interface KuwoLazyScrollViewListener {
		public void onRefresh();

		public void onLoadMore();
	}

}
