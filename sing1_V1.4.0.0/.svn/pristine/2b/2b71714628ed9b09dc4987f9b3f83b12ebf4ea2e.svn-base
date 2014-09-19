/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.adapter;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.ui.activities.LocalEditActivity;
import cn.kuwo.sing.ui.activities.LocalNoticeActivity;
import cn.kuwo.sing.ui.activities.MyHomeActivity;

import com.googlecode.mp4parser.h264.BTree;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;

import de.greenrobot.event.EventBus;

/**
 * @Package cn.kuwo.sing.ui.adapter
 *
 * @Date 2013-12-25, 下午3:38:12
 *
 * @Author wangming
 *
 */
public class UserKgeListAdapter extends BaseAdapter {
	private static final String HTTP_URL_ATTENTATION = "http://changba.kuwo.cn/kge/webmobile/an/user_list.html?type=getfav";
	private static final String HTTP_URL_FANS = "http://changba.kuwo.cn/kge/webmobile/an/user_list.html?type=getfans";
	private Activity mActivity;
	private List<Kge> mKgeList = new ArrayList<Kge>();
	private String mUserPicUrl;
	private String mUname;
	private String mUid;
	private String mOtherInfos;
	private String mFans;
	private String mAttentation;
	private boolean isMyHome;
	private int hasCare;
	private String mUserId;
	private static final int EXTRA_ITEM = 1;
	
	public UserKgeListAdapter(Activity activity) {
		mActivity = activity;
	}
	
	public void setUserBaseInfo(String uname, String uid, String OtherInfos, String fans, String attentation, String userPicUrl) {
		mUname = uname;
		mUid = uid;
		mOtherInfos = OtherInfos;
		mFans = fans;
		mAttentation = attentation;
		mUserPicUrl = userPicUrl;
	}
	
	public void setUserType(boolean isMyHome, int hasCare, String userId) {
		this.isMyHome = isMyHome;
		this.hasCare = hasCare;
		mUserId = userId;
	}
	
	public void clearList() {
		mKgeList.clear();
	}
	
	public void setUserKgeList(List<Kge> kgeList) {
		mKgeList.addAll(kgeList);
		notifyDataSetChanged();
	}
	
	public void removeKge(int position) {
		mKgeList.remove(position);
		notifyDataSetChanged();
	}

	@Override
	public int getCount() {
		return mKgeList.size()+EXTRA_ITEM;
	}

	@Override
	public Object getItem(int position) {
		return mKgeList.get(position-EXTRA_ITEM);
	}

	@Override
	public long getItemId(int position) {
		return position-EXTRA_ITEM;
	}
	
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			switch (v.getId()) {
			case R.id.btUserHomeFans:
				if(Config.getPersistence().user != null) {
					Intent intent = new Intent(mActivity, LocalNoticeActivity.class);
					String urlFans = null;
					if(isMyHome) {
						intent.putExtra("title", "我的粉丝");
						urlFans = HTTP_URL_FANS+"&uid="+Config.getPersistence().user.uid+"&t="+System.currentTimeMillis();
					}else {
						intent.putExtra("title", "他的粉丝");
						urlFans = HTTP_URL_FANS+"&uid="+mUserId+"&t="+System.currentTimeMillis();
					}
					intent.putExtra("webviewurl", urlFans);
					mActivity.startActivity(intent);
				}
				break;
			case R.id.btUserHomeAttention:
				if(Config.getPersistence().user != null) {
					Intent attentationIntent = new Intent(mActivity, LocalNoticeActivity.class);
					String urlAttentation = null;
					if(isMyHome) {
						attentationIntent.putExtra("title", "我的关注");
						urlAttentation = HTTP_URL_ATTENTATION+"&uid="+Config.getPersistence().user.uid+"&t="+System.currentTimeMillis();
					}else {
						attentationIntent.putExtra("title", "他的关注");
						urlAttentation = HTTP_URL_ATTENTATION+"&uid="+mUserId+"&t="+System.currentTimeMillis();
					}
					attentationIntent.putExtra("webviewurl", urlAttentation);
					mActivity.startActivity(attentationIntent);
				}
				break;
			case R.id.ivUserHomePortrait:
				if(isMyHome) {
					Message msg = new Message();
					msg.what =  Constants.MSG_MY_HOME_PORTRAIT_CLICK;
					EventBus.getDefault().post(msg);
				}
				break;
			case R.id.btMyHomeMsg:
				Intent msgIntent = new Intent(mActivity, LocalNoticeActivity.class);
				msgIntent.putExtra("title", "我的消息");
				String url = "http://changba.kuwo.cn/kge/webmobile/an/news.html";
				msgIntent.putExtra("webviewurl", url);
				mActivity.startActivity(msgIntent);
				break;
			default:
				break;
			}
		}
	};

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View view = null;
		ViewHolder viewHolder = null;
		if(position == 0) {
			view = View.inflate(mActivity, R.layout.user_home_list_item_0, null);
			//消息按钮
			Button btMyHomeMsg = (Button)view.findViewById(R.id.btMyHomeMsg);
			//消息提示图片
			ImageView ivMyHomeMsgPrompt = (ImageView)view.findViewById(R.id.ivMyHomeMsgPrompt);
			btMyHomeMsg.setVisibility(View.VISIBLE);
			btMyHomeMsg.setOnClickListener(mOnClickListener);
			
			if(Config.getPersistence().user.noticeNumber != 0) 
				ivMyHomeMsgPrompt.setVisibility(View.VISIBLE);
			else 
				ivMyHomeMsgPrompt.setVisibility(View.INVISIBLE);
			
			ImageView ivMyHomePortrait = (ImageView)view.findViewById(R.id.ivUserHomePortrait);
			ImageLoader.getInstance().displayImage(mUserPicUrl, ivMyHomePortrait, new AnimateFirstDisplayListener());
			ivMyHomePortrait.setOnClickListener(mOnClickListener);
			
			TextView tvMyHomeUsername = (TextView)view.findViewById(R.id.tvUserHomeUsername);
			tvMyHomeUsername.setText(mUname);
			TextView tvMyHomeUserID = (TextView)view.findViewById(R.id.tvUserHomeUserID);
			tvMyHomeUserID.setText("ID: "+mUid);
			TextView tvMyHomeOtherInfo = (TextView)view.findViewById(R.id.tvUserHomeOtherInfo);
			tvMyHomeOtherInfo.setText(mOtherInfos);
			Button btMyHomeFans = (Button)view.findViewById(R.id.btUserHomeFans);
			btMyHomeFans.setText(mFans);
			btMyHomeFans.setOnClickListener(mOnClickListener);
			Button btMyHomeAttention = (Button) view.findViewById(R.id.btUserHomeAttention);
			btMyHomeAttention.setText(mAttentation);
			btMyHomeAttention.setOnClickListener(mOnClickListener);
			final Button btMyHomeEditInfo = (Button)view.findViewById(R.id.btUserHomeOptions);
			if(isMyHome) {
				btMyHomeEditInfo.setText("编辑资料");
			}else {
				if(this.hasCare == 1)
					btMyHomeEditInfo.setText("取消关注");
				else 
					btMyHomeEditInfo.setText("关注");
					
			}
			btMyHomeEditInfo.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					if(isMyHome) {
						Intent editintent = new Intent(mActivity, LocalEditActivity.class);
						mActivity.startActivityForResult(editintent, Constants.LOCAL_EDITINFO_REQUEST);
					}else {
						Message msg = new Message();
						msg.what = Constants.MSG_OTHERE_HOME_ATTENTATION_BUTTON;
						EventBus.getDefault().post(msg);
						btMyHomeEditInfo.setText("处理中...");
					}
				}
			});
			return view;
		}
		if(convertView == null || viewHolder == null) {
			view = View.inflate(mActivity, R.layout.user_kge_list_item, null);
			viewHolder = new ViewHolder();
			viewHolder.ivUserPortrait = (ImageView) view.findViewById(R.id.ivUserPortrait);
			viewHolder.ivUserKgeGo = (ImageView) view.findViewById(R.id.ivUserKgeGo);
			viewHolder.tvTitle = (TextView) view.findViewById(R.id.tvUserKgeTitle);
			viewHolder.tvSrc = (TextView) view.findViewById(R.id.tvUserKgeSrc);
			viewHolder.tvTime = (TextView) view.findViewById(R.id.tvUserKgeTime);
			viewHolder.tvViews = (TextView) view.findViewById(R.id.tvUserKgeViews);
			viewHolder.tvComments = (TextView) view.findViewById(R.id.tvUserKgeComments);
			viewHolder.tvFlowers = (TextView) view.findViewById(R.id.tvUserKgeFlowers);
			view.setTag(viewHolder);
		}else {
			view = convertView;
			viewHolder = (ViewHolder) view.getTag();
		}
		
		final Kge kge = mKgeList.get(position-EXTRA_ITEM);
		KuwoLog.e("adapter", "viewHolder="+viewHolder);
		KuwoLog.e("adapter", "picUrl="+mUserPicUrl+",portrait="+viewHolder.ivUserPortrait);
		ImageLoader.getInstance().displayImage(mUserPicUrl, viewHolder.ivUserPortrait, new AnimateFirstDisplayListener());
		viewHolder.ivUserKgeGo.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				MTVBusiness mb = new MTVBusiness(mActivity);
				mb.playMtv(kge.id);
			}
		});
		viewHolder.tvTitle.setText(kge.title);
		viewHolder.tvSrc.setText(kge.src);
		viewHolder.tvTime.setText(kge.time);
		viewHolder.tvViews.setText(kge.view+"");
		viewHolder.tvComments.setText(kge.comment+"");
		viewHolder.tvFlowers.setText(kge.flower+"");
		return view;
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
	
	static class ViewHolder {
		ImageView ivUserPortrait;
		ImageView ivUserKgeGo;
		TextView tvTitle;
		TextView tvViews;
		TextView tvFlowers;
		TextView tvComments;
		TextView tvSrc;
		TextView tvTime;
		Button btPlay;
	}

	public void setMsgInfo() {
		// TODO Auto-generated method stub
		
	}

}
