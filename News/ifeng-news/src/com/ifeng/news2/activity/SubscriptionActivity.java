package com.ifeng.news2.activity;

import java.util.ArrayList;

import android.graphics.Bitmap;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.ifeng.news2.Config;
import com.ifeng.news2.FunctionActivity;
import com.ifeng.news2.R;
import com.ifeng.news2.adapter.IfengDragGridAdapter;
import com.ifeng.news2.adapter.IfengDragGridAdapter.IfengLineNum;
import com.ifeng.news2.bean.SubscriptionBean;
import com.ifeng.news2.fragment.NewsMasterFragmentActivity;
import com.ifeng.news2.util.ConfigManager;
import com.ifeng.news2.util.IfengTextViewManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.widget.IfengDragGridView;

public class SubscriptionActivity extends FunctionActivity {
	
	private ArrayList<String> topArray ;
	private ArrayList<String> bottomArray ;
	private IfengDragGridView gridView;
	private IfengDragGridView gridViewBttom;
	private IfengDragGridView targetView;
	private IfengDragGridAdapter gridAdapter;
	private IfengDragGridAdapter gridViewBttomAdapter;
	private int selectPosition;
	private int dragSrcPosition;
	private int dragPosition;
	private int temChangId;
	private int dragPointX;
	private int dragPointY;
	private int dragOffsetX;
	private int dragOffsetY;
	private LayoutParams windowParams;
	private WindowManager windowManager;
	private ImageView dragImageView;
	private TextView txtSubscriptTitle;
	private long currentTime;
	private View title;
	private View midTitle;
	private SubscriptionBean subscriptionChannel;
	private boolean interrupte = false;
	private int topOffset;
	private int bottomOffset;
	private int heightOfStatusBar = 0;
	private String refChannel = "";
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.ifeng_subscription_layout);
		findViews();
		init();
		initDatas();
		
		createGridViewAdaptorByScreenWithAndDesity();
		
//		gridView.setCoverView(R.layout.ifeng_subscription_layout_item, "鳳凰衛視");
		gridView.setAdapter(gridAdapter);
		gridViewBttom.setAdapter(gridViewBttomAdapter);
		if(subscriptionChannel!=null){
			gridAdapter.setUnchangingPosition(subscriptionChannel.getDefaultChannel());
		}
	}
	
  private void createGridViewAdaptorByScreenWithAndDesity() {

    DisplayMetrics dm = new DisplayMetrics();
    getWindowManager().getDefaultDisplay().getMetrics(dm);
    if (dm.widthPixels >= 700 && dm.widthPixels <= 800) {
      if (dm.densityDpi > 240) {

        gridAdapter = new IfengDragGridAdapter(this, topArray, IfengLineNum.TwoLineAndSmallerFont);
        gridViewBttomAdapter =
            new IfengDragGridAdapter(this, bottomArray, IfengLineNum.TwoLineAndSmallerFont);
      } else {

        gridAdapter = new IfengDragGridAdapter(this, topArray, IfengLineNum.OneLineAndNormalFont);
        gridViewBttomAdapter =
            new IfengDragGridAdapter(this, bottomArray, IfengLineNum.OneLineAndNormalFont);
      }
    } else if (dm.widthPixels < 700) {

      gridAdapter = new IfengDragGridAdapter(this, topArray, IfengLineNum.TwoLineAndSmallFont);
      gridViewBttomAdapter =
          new IfengDragGridAdapter(this, bottomArray, IfengLineNum.TwoLineAndSmallFont);
    } else {
      
      if(dm.densityDpi>=480){
        
        gridAdapter = new IfengDragGridAdapter(this, topArray, IfengLineNum.TwoLineAndSmallFont);
        gridViewBttomAdapter =
            new IfengDragGridAdapter(this, bottomArray, IfengLineNum.TwoLineAndSmallFont);
      }else{
        
        gridAdapter = new IfengDragGridAdapter(this, topArray);
        gridViewBttomAdapter = new IfengDragGridAdapter(this, bottomArray);
      }
    }

  }

  private int getCurrentScreenWidth() {
	  
	  DisplayMetrics dm = new DisplayMetrics();
	  getWindowManager().getDefaultDisplay().getMetrics(dm);
      return dm.widthPixels;
  }

  private void initDatas() {
		refChannel  = getIntent().getStringExtra(NewsMasterFragmentActivity.REF_CHANNEL);
	}

	private void init() {
		subscriptionChannel = Config.SUBSCRIPTIONS;
		if(subscriptionChannel!=null){
			topArray = subscriptionChannel.getDefaultOrderMenuItems();
			bottomArray = subscriptionChannel.getOtherChannelNames();
		}
		if(topArray == null){
			topArray = new ArrayList<String>();
		}
		if(bottomArray == null){
			bottomArray = new ArrayList<String>();
		}
	}

	private void findViews() {
		
	    txtSubscriptTitle=(TextView) findViewById(R.id.txt_subscript_title);
	    gridView = (IfengDragGridView) findViewById(R.id.ifeng_subscription_gridview_top);
		gridViewBttom = (IfengDragGridView) findViewById(R.id.ifeng_subscription_gridview_bottom);
		title = findViewById(R.id.ifeng_subscription_title);
		midTitle = findViewById(R.id.ifeng_subscription_midTitle);
		ImageButton button = (ImageButton) findViewById(R.id.submit);
		RelativeLayout layoutSubmit = (RelativeLayout) findViewById(R.id.layout_submit);
		layoutSubmit.setOnClickListener(new OnClickListener() {
          
          @Override
          public void onClick(View v) {
              onBackPressed();
          }
      });
		button.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				onBackPressed();
			}
		});
	}
	
	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		if(!TextUtils.isEmpty(refChannel)){
			StatisticUtil.addRecord(this
					, StatisticUtil.StatisticRecordAction.page
					, "id=dl$ref="+refChannel+"$type=" + StatisticUtil.StatisticPageType.set);
		}
	}
	
	@Override
	public boolean onTouchEvent(MotionEvent ev) {
	  
	  if (0 == heightOfStatusBar) {

	      heightOfStatusBar = IfengTextViewManager.getStatusBarHeight(this);
	    }
	  
		if (ev.getAction() == MotionEvent.ACTION_DOWN) {
			int x = (int) ev.getX();
			temChangId = dragSrcPosition = dragPosition = getValidPosition(x, (int)ev.getY());
			int y =  getRelativeY((int) ev.getY());
			if(dragPosition == AdapterView.INVALID_POSITION){
				ignoreTouch();
				return super.onTouchEvent(ev);
			}
			ViewGroup itemView = (ViewGroup) targetView.getChildAt(dragPosition
					- targetView.getFirstVisiblePosition());

			dragPointX = x - itemView.getLeft();
			dragPointY = y- itemView.getTop();
			dragOffsetX = (int) (ev.getRawX() - x);
			dragOffsetY = (int) (ev.getRawY() - y);

			View dragger = itemView.findViewById(R.id.subscription_item_text);
			/***
			 * 判断是否选中拖动图标
			 */
			if (dragger != null /*&& dragPointX > dragger.getLeft()
					&& dragPointX < dragger.getRight()
					&& dragPointY > dragger.getTop()
					&& dragPointY < dragger.getBottom()*/) {
				itemView.setDrawingCacheEnabled(true);
				itemView.setBackgroundDrawable(getResources().getDrawable(R.drawable.subscription_divider_bottom_and_right));
				if(itemView.getDrawingCache() == null){
					ignoreTouch();
					return super.onTouchEvent(ev);
				}
				Bitmap bm = Bitmap.createBitmap(itemView.getDrawingCache());
				currentTime = System.currentTimeMillis();
				startDrag(bm, x, y);// 初始话映像
				((IfengDragGridAdapter) (targetView.getAdapter())).setIsHidePosition(dragPosition);// 隐藏该项.
				((IfengDragGridAdapter) (targetView.getAdapter())).notifyDataSetChanged();
			}
		}
		if(targetView != null){
			switch (ev.getAction()) {
			case MotionEvent.ACTION_UP:
				int upX = (int) ev.getX();
				int upY = (int) ev.getY();
				stopDrag();// 删除映像
				if(interrupte){
					targetView = null;
					selectPosition = 0;
					interrupte = false;
					return super.onTouchEvent(ev);
				}
				onDrop(upX, upY);// 松开
				// isDoTouch = false;
				break;

			case MotionEvent.ACTION_MOVE:
				int moveX = (int) ev.getX();
				int moveY = (int) ev.getY();
				if(interrupte){
					return super.onTouchEvent(ev);
				}
				onDrag(moveX, moveY);// 拖拽
				break;
				
			default:
				break;
			}
		}
		return super.onTouchEvent(ev);
	}

	private void ignoreTouch() {
		targetView = null;
		selectPosition = 0;
		gridAdapter.notifyDataSetChanged();
		gridViewBttomAdapter.notifyDataSetChanged();
	}
	
	private int getRelativeY(int y) {
		if(selectPosition == 1){
			return getTopY(y);
		}else if(selectPosition == 2){
			return getBottomY(y);
		}
		return -1; 
	}
	
	public int getTopY(int y){
		return y-topOffset;
	}
	
	public int getBottomY(int y){
		return y-bottomOffset;
	}

	private int getValidPosition(int x, int y) {
		if(selectPosition==0){
			
		    topOffset = heightOfStatusBar+title.getHeight()+title.getPaddingTop()+gridView.getPaddingTop()-txtSubscriptTitle.getPaddingTop();
			bottomOffset = heightOfStatusBar+title.getHeight()+gridView.getPaddingTop()+gridView.getHeight()+midTitle.getHeight()+midTitle.getPaddingTop();
		}
		int position = AdapterView.INVALID_POSITION;
		if ( y < heightOfStatusBar+title.getHeight() + title.getPaddingTop()
						+ gridView.getPaddingTop() + gridView.getHeight()) {
			if(selectPosition==0){
				selectPosition = 1;
			}
			position = gridView.pointToPosition(x, getTopY(y));
				try {
					if (position!=AdapterView.INVALID_POSITION&&subscriptionChannel.getDefaultChannel().contains(topArray.get(position))){
						position=AdapterView.INVALID_POSITION;
					}
					update(targetView, gridView, position);
					targetView = gridView;
				} catch (Exception e) {
					position=AdapterView.INVALID_POSITION;
				}
				//update要放在position判断之后，以免过快的操作造成位置更新失败
				update(targetView, gridView, position);
				targetView = gridView;
		} else/* if (y > heightOfStatusBar+title.getHeight() + title.getPaddingTop()
						+ gridView.getPaddingTop() + gridView.getHeight()) */{
			if(selectPosition==0){
				selectPosition = 2;
			}
			position = gridViewBttom.pointToPosition(
					x,
					(int)getBottomY(y));
			try {
				update(targetView, gridViewBttom, position);
				targetView = gridViewBttom;
			} catch (Exception e) {
			}
				
		}
		return position;
	}

	private void update(IfengDragGridView targetView1, IfengDragGridView gridView1, int position) {
		if(position == AbsListView.INVALID_POSITION){
			position = gridView1.getChildCount();
		}
		if(targetView1 == null||targetView1==gridView1){
			return;
		}else{
			((IfengDragGridAdapter) (targetView1.getAdapter())).setIsHidePosition(-1);
			((IfengDragGridAdapter) (gridView1.getAdapter())).getArrayTitles()
					.add(position, ((IfengDragGridAdapter) (targetView1.getAdapter()))
							.getArrayTitles().remove(dragPosition));
			((IfengDragGridAdapter) (gridView1.getAdapter())).setIsHidePosition(position);
			dragPosition = gridView1.getAdapter().getCount() - 1;
			temChangId = -1;
			gridAdapter.notifyDataSetChanged();
			gridViewBttomAdapter.notifyDataSetChanged();
		}
	}

	/**
	 * 准备拖动，初始化拖动项的图像
	 * 
	 * @param bm
	 * @param y
	 */
	public void startDrag(Bitmap bm, int x, int y) {

		windowParams = new WindowManager.LayoutParams();
		windowParams.gravity = Gravity.TOP | Gravity.LEFT;
		windowParams.x = x - dragPointX + dragOffsetX;
		windowParams.y = y - dragPointY + dragOffsetY;
		windowParams.width = WindowManager.LayoutParams.WRAP_CONTENT;
		windowParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
		windowParams.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
				| WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
				| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
				| WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN;

		windowParams.windowAnimations = 0;

		ImageView imageView = new ImageView(me);
		imageView.setImageBitmap(bm);
		windowManager = (WindowManager)getSystemService("window");
		windowManager.addView(imageView, windowParams);
		dragImageView = imageView;

	}

	/***
	 * 拖动时时change
	 */
	private synchronized void onChange(int x, int y) {
		int tempPosition = getValidPosition(x, y);
		// 获取适配器
		IfengDragGridAdapter adapter = (IfengDragGridAdapter) targetView.getAdapter();
		// 数据交换
		if (dragPosition < targetView.getAdapter().getCount()) {
			// 不相等的情况下要进行换位,相等的情况下说明正在移动
			if (dragPosition != temChangId) {
				adapter.setIsHidePosition(dragPosition);
				adapter.update(temChangId, dragPosition);// 进行换位
				temChangId = dragPosition;// 将点击最初所在位置position付给临时的，用于判断是否换位.
			}
		}
		
		if (tempPosition != AdapterView.INVALID_POSITION) {
			dragPosition = tempPosition;
		}

	}

	/***
	 * 拖动执行，在Move方法中执行
	 * 
	 * @param x
	 * @param y
	 */
	public void onDrag(int x, int y) {
		// 移动
		if (dragImageView != null) {
			windowParams.alpha = 0.8f;
			windowParams.x = x - dragPointX + dragOffsetX;
			windowParams.y = (int) (getRelativeY(y) - dragPointY + dragOffsetY);
			windowManager.updateViewLayout(dragImageView, windowParams);
		}
		onChange(x, y);// 时时交换ff

//		// 滚动
//		if (y < upScrollBounce || y > downScrollBounce) {
//			// 使用setSelection来实现滚动
//			targetView.setSelection(dragPosition);
//		}

	}

	/**
	 * 停止拖动，删除影像
	 */
	public void stopDrag() {
		if (dragImageView != null) {
			windowManager.removeView(dragImageView);
			dragImageView = null;
		}
	}
	
	public ImageView getDragImageView() {
		return dragImageView;
	}
	
	public WindowManager.LayoutParams getWindowParams() {
		return windowParams;
	}

	public int getDragPosition() {
		return dragPosition;
	}

	public void setDragImage(ImageView dragImageView, WindowManager.LayoutParams windowParams) {
		this.dragImageView = dragImageView;
		this.windowParams = windowParams;
	}

	/***
	 * 拖动放下的时候
	 * 
	 * @param x
	 * @param y
	 */
	public synchronized void onDrop(int x, int y) {
		if(dragSrcPosition == dragPosition&&System.currentTimeMillis()-currentTime<200){
			try {
				click(dragSrcPosition);
			} catch (Exception e) {
			}
		}
		if(targetView==null){
			return;
		}
		gridAdapter.setIsHidePosition(-1);
		gridViewBttomAdapter.setIsHidePosition(-1);
		gridAdapter.notifyDataSetChanged();
		gridViewBttomAdapter.notifyDataSetChanged();
		targetView = null;
		selectPosition = 0;
	}
	

	private void click(int dragSrcPosition) {
		if (targetView == gridView&&selectPosition == 1) {
			((IfengDragGridAdapter) (gridViewBttom.getAdapter()))
					.getArrayTitles().add(
							((IfengDragGridAdapter) (targetView.getAdapter()))
									.getArrayTitles().remove(dragPosition));
		} else if (targetView == gridViewBttom&&selectPosition == 2) {
			((IfengDragGridAdapter) (gridView.getAdapter()))
					.getArrayTitles().add(
							((IfengDragGridAdapter) (targetView.getAdapter()))
									.getArrayTitles().remove(dragPosition));
		}
	}
	
	@Override
	public void onBackPressed() {
		StatisticUtil.isBack = true ; 
		setResult(200);
		subscriptionChannel.getDefaultOrderMenuItems().remove("鳳凰衛視");
		NewsMasterFragmentActivity.isGoToSubscription = true;
		finish();
		overridePendingTransition(R.anim.slide_down_in, R.anim.slide_up);
	}
	
}
