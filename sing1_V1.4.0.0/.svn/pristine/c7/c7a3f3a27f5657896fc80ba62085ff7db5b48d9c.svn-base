/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Comment;
import cn.kuwo.sing.bean.CommentInfo;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.MusicLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.CommentSendActivity;
import cn.kuwo.sing.ui.activities.LocalMainActivity;
import cn.kuwo.sing.ui.activities.LoginActivity;
import cn.kuwo.sing.util.DialogUtils;
import cn.kuwo.sing.widget.KuwoListView;
import cn.kuwo.sing.widget.KuwoListView.KuwoListViewListener;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageLoadingListener;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.assist.PauseOnScrollListener;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;
import com.nostra13.universalimageloader.core.display.SimpleBitmapDisplayer;

/**
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2012-12-18, 下午4:31:25, 2012
 *
 * @Author wangming
 *
 */
public class CommentController extends BaseController {
	private final String TAG = "CommentController";
	private BaseActivity mActivity;
	private KuwoListView lv_comment_list;
	private boolean isRefresh = false;
	private boolean isLoadMore = false;
	private List<Comment> totalResultList = new ArrayList<Comment>();
	private String kid;
	private String sid;
	private RelativeLayout rl_comment_progress;
	private int imageWidth;
	private int imageHeight;
	private boolean isBottom = false;
	private int currentPageNum = 1;
	private TextView tv_comment_list_no_data;
	private ImageLoader mImageLoader;
	private DisplayImageOptions options;
	
	public CommentController(BaseActivity activity, ImageLoader imageLoader) {
		mActivity = activity;
		mImageLoader = imageLoader;
		options = new DisplayImageOptions.Builder()
		.showStubImage(R.drawable.image_loading_small)
		.showImageForEmptyUri(R.drawable.image_loading_small)
		.showImageOnFail(R.drawable.image_loading_small)
		.cacheInMemory()
		.cacheOnDisc()
        .imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2) // default
        .bitmapConfig(Bitmap.Config.ARGB_8888) // default
		.displayer(new SimpleBitmapDisplayer())
		.build();
		imageWidth = mActivity.getWindowManager().getDefaultDisplay().getWidth()/4;
		imageHeight = mActivity.getWindowManager().getDefaultDisplay().getWidth()/4;
		kid = mActivity.getIntent().getStringExtra("kid");
		sid = mActivity.getIntent().getStringExtra("sid");
		initView();
	}
	
	private void showLoginDialog(int tip) {
		DialogUtils.alert(mActivity, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					//ok
					dialog.dismiss();
					Intent loginIntent = new Intent(mActivity, LoginActivity.class);
					mActivity.startActivity(loginIntent);
					break;
				case -2:
					//cancel
					dialog.dismiss();
					break;
				default:
					break;
				}
				
			}
		} , R.string.logout_dialog_title, R.string.dialog_ok, R.string.dialog_cancel, -1, tip);
	}

	private void initView() {
		tv_comment_list_no_data = (TextView) mActivity.findViewById(R.id.tv_comment_list_no_data);
		Button back = (Button) mActivity.findViewById(R.id.bt_comment_list_back);
		back.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				mActivity.finish();
			}
		});
		TextView tv_comment_sender = (TextView) mActivity.findViewById(R.id.tv_comment_sender);
		tv_comment_sender.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if(!Config.getPersistence().isLogin) {
					showLoginDialog(R.string.login_dialog_tip);
				}else {
					Intent sendIntent = new Intent(mActivity, CommentSendActivity.class);
					sendIntent.putExtra("kid", kid);
					sendIntent.putExtra("sid", sid);
					sendIntent.putExtra("toUid", "");
					mActivity.startActivityForResult(sendIntent, Constants.COMMENT_SEND_REQUEST);
				}
			}
		});
		lv_comment_list = (KuwoListView) mActivity.findViewById(R.id.lv_comment_list);
		lv_comment_list.setPullLoadEnable(true);
		lv_comment_list.setPullRefreshEnable(true);
		lv_comment_list.setOnScrollListener(new PauseOnScrollListener(mImageLoader, false, true));
		lv_comment_list.setKuwoListViewListener(new KuwoListViewListener() {
			
			@Override
			public void onRefresh() {
				toRefresh();
			}
			
			@Override
			public void onLoadMore() {
				if(isBottom) {
					Toast.makeText(mActivity, "亲，就这么多了", 0).show();
					lv_comment_list.setFooterNoData();
					return;
				}
				isLoadMore = true;
				loadCommentView(++currentPageNum);
			}
		});
		rl_comment_progress = (RelativeLayout) mActivity.findViewById(R.id.rl_comment_progress);
		loadCommentView(currentPageNum);
	}
	
	public void toRefresh() {
		if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
			isRefresh = true;
			isBottom = false;
			lv_comment_list.setNoDataStatus(false);
			loadCommentView(1);
		}else {
			Toast.makeText(mActivity, "网不通，请稍后再试", 0).show();
			onLoad();
		}
	}

	public synchronized void loadCommentView(int pageNum) {
		new CommentLoader().execute(kid, sid, pageNum);
	}
	
	private void onLoad() {
		lv_comment_list.stopRefresh();
		isRefresh = false;
		lv_comment_list.stopLoadMore();
		isLoadMore = false;
		SimpleDateFormat dateFormatter = new SimpleDateFormat("yy-MM-dd HH:mm:ss");
		String time = dateFormatter.format(new Date());
		lv_comment_list.setRefreshTime(time);
	}
	
	class CommentLoader extends AsyncTask<Object, Void, CommentInfo> {
		
		@Override
		protected void onPreExecute() {
			if(isRefresh || isLoadMore) {
				rl_comment_progress.setVisibility(View.INVISIBLE);
			}else {
				rl_comment_progress.setVisibility(View.VISIBLE);
			}
			super.onPreExecute();
		}

		@Override
		protected CommentInfo doInBackground(Object... params) {
			String kid = (String) params[0];
			String sid = (String) params[1];
			int pageNum =  (Integer)params[2];
			MusicLogic logic = new MusicLogic();
			return logic.getCommentInfo(kid, sid, pageNum);
		}

		@Override
		protected void onPostExecute(CommentInfo result) {
			rl_comment_progress.setVisibility(View.INVISIBLE);
			KuwoLog.i(TAG, "result="+result);
			if(result != null) {
				KuwoLog.i(TAG, "comment pagesize="+result.pagesize);
				KuwoLog.i(TAG, "totalPage="+result.total);
				KuwoLog.i(TAG, "currentPage="+result.current);
				currentPageNum = result.current;
				if(isRefresh) {
					if(!totalResultList.isEmpty()) {
						totalResultList.clear();
					}
				}
				List<Comment> commentList = result.commentList;
				KuwoLog.i(TAG, "commentList.size="+commentList.size());
				if(commentList.size() == 0) {
					lv_comment_list.getFooterView().hide();
					tv_comment_list_no_data.setVisibility(View.VISIBLE);
					return;
				}else {
					lv_comment_list.getFooterView().show();
					tv_comment_list_no_data.setVisibility(View.INVISIBLE);
				}
				if(result.current == result.total) {
					isBottom = true;
					lv_comment_list.setNoDataStatus(true);
				}
				totalResultList.addAll(commentList);
				CommentAdapter adapter = new CommentAdapter(totalResultList);
				if(isLoadMore) {
					adapter.notifyDataSetChanged();
				}else {
					lv_comment_list.setAdapter(adapter);
				}
				onLoad();
			}
			super.onPostExecute(result);
		}
	}
	
	public void clearDisplayedImages() {
		AnimateFirstDisplayListener.displayedImages.clear();
	}
	
	private static class AnimateFirstDisplayListener extends SimpleImageLoadingListener {

		static final List<String> displayedImages = Collections.synchronizedList(new LinkedList<String>());

		@Override
		public void onLoadingComplete(String imageUri, View view, Bitmap loadedImage) {
			if (loadedImage != null) {
				ImageView imageView = (ImageView) view;
				boolean firstDisplay = !displayedImages.contains(imageUri);
				if (firstDisplay) {
					FadeInBitmapDisplayer.animate(imageView, 500);
					displayedImages.add(imageUri);
				} else {
					imageView.setImageBitmap(loadedImage);
				}
			}
		}
	}
	
	class CommentAdapter extends BaseAdapter {
		private List<Comment> mCommentList;
		private ImageLoadingListener animateFirstListener = new AnimateFirstDisplayListener();
		
		public CommentAdapter(List<Comment> commentList) {
			mCommentList = commentList;
		}

		@Override
		public int getCount() {
			return mCommentList.size();
		}

		@Override
		public Object getItem(int position) {
			return mCommentList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			View view = null;
			ViewHolder viewHolder = null;
			if(convertView == null) {
				view = View.inflate(mActivity, R.layout.comment_layout_item, null);
				viewHolder = new ViewHolder();
				viewHolder.headIV = (ImageView) view.findViewById(R.id.iv_comment_head);
				viewHolder.ftimeTV = (TextView) view.findViewById(R.id.tv_comment_ftime);
				viewHolder.contentTV = (TextView) view.findViewById(R.id.tv_comment_content);
				viewHolder.goIV = (ImageView) view.findViewById(R.id.iv_comment_go);
				view.setTag(viewHolder);
			}else {
				view = convertView;
				viewHolder = (ViewHolder) view.getTag();
			}
			final Comment comment = mCommentList.get(position);
			String imageUrl = comment.fpic;
			mImageLoader.displayImage(imageUrl, viewHolder.headIV, options, animateFirstListener);
			viewHolder.headIV.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					Intent intent = new Intent(mActivity,LocalMainActivity.class);
					intent.putExtra("uname", comment.fname);
					intent.putExtra("flag", "otherHome");
					intent.putExtra("uid", comment.fid);
					intent.putExtra("url", comment.fpic);
					mActivity.startActivity(intent);
				}
			});
			viewHolder.ftimeTV.setText(comment.time);
			viewHolder.contentTV.setText(comment.fname+":"+comment.content);
			viewHolder.goIV.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					if(!Config.getPersistence().isLogin) {
						showLoginDialog(R.string.login_dialog_tip);
					}else {
						Intent sendIntent = new Intent(mActivity, CommentSendActivity.class);
						sendIntent.putExtra("kid", kid);
						sendIntent.putExtra("sid", sid);
						sendIntent.putExtra("toUid", comment.fid);
						sendIntent.putExtra("toName", comment.fname);
						mActivity.startActivity(sendIntent);
					}
				}
			});
			return view;
		}
	}
	
	static class ViewHolder {
		ImageView headIV;
		TextView ftimeTV;
		TextView contentTV;
		ImageView goIV;
	}
}
