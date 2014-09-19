/**
 * 
 */
package cn.kuwo.sing.controller;

import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import android.content.Intent;
import android.content.res.AssetManager;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Message;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Gallery;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.ChatContent;
import cn.kuwo.sing.logic.LiveLogic;
import cn.kuwo.sing.logic.service.LiveSocketService.OnLiveDataRecieveListener;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.util.DensityUtils;
import cn.kuwo.sing.util.ImageAsyncTask.ImageAsyncTaskCallback;
import cn.kuwo.sing.util.ImageUtils;

/**
 * @author wangming
 *
 */
public class LiveRoomController extends BaseController {
	private final String TAG = "LiveRoomController";
	private BaseActivity mActivity;
	private String mRoomId;
	private Gallery mSingerGallery;
	private TextView tv_live_room_singer_name;
	private TextView tv_live_room_singer_id;
	private TextView tv_live_room_singer_flower_count;
	private Button bt_live_room_back;
	private ListView chatListView;
	private List<ChatContent> contentList;
	private ChatAdapter mChatAdapter;
	private EditText et_live_room_input;
	private Button bt_live_room_sender;
	private LiveLogic liveLogic;
	private ImageView iv_live_room_face;
	private PopupWindow mChatPopupWindow;
	private ImageView iv_leave_room;
	private int imageWidth;
	private int imageHeight;
	
	private String[] mChatFaceStrs= {"拜拜","白眼", "鄙视", "闭嘴", "不高兴", "打哈哈", "发怒","鼓掌", "害羞","黑线","囧","可爱","可怜","酷","哭","冷汗","流泪",
			"亲亲","色","胜利","睡觉","偷笑","吐","委屈","微笑","握手","心","心碎","嘘","疑问","晕","眨眼","跩","抓狂","龇牙笑"};
	private List<Drawable> mChatDrawableList = new ArrayList<Drawable>();
	private HashMap<String, String> mChatFaceMap = new HashMap<String, String>();
	public LiveRoomController(BaseActivity activity) {
		KuwoLog.i(TAG, "LiveRoomController");
		mActivity = activity;
		imageWidth = mActivity.getWindowManager().getDefaultDisplay().getWidth()/4;
		imageHeight = mActivity.getWindowManager().getDefaultDisplay().getWidth()/4;
		initView();
		enterRoom();
	}

	private void initView() {
		Intent intent = mActivity.getIntent();
		mRoomId = intent.getStringExtra("roomId");
		
		bt_live_room_back = (Button) mActivity.findViewById(R.id.bt_live_room_back);
		bt_live_room_back.setOnClickListener(mOnClickListener);
		iv_leave_room = (ImageView) mActivity.findViewById(R.id.iv_leave_room);
		iv_leave_room.setOnClickListener(mOnClickListener);
		tv_live_room_singer_name = (TextView) mActivity.findViewById(R.id.tv_live_room_singer_name);
		tv_live_room_singer_name.setFocusable(true);
		tv_live_room_singer_name.setFocusableInTouchMode(true);
		tv_live_room_singer_name.requestFocus();
		tv_live_room_singer_id = (TextView) mActivity.findViewById(R.id.tv_live_room_singer_id);
		tv_live_room_singer_flower_count = (TextView) mActivity.findViewById(R.id.tv_live_room_singer_flower_count);
		mSingerGallery = (Gallery) mActivity.findViewById(R.id.gallery_singer_image);
//		KeyboardUtils.hideInputKeyboard(mActivity);
		chatListView = (ListView) mActivity.findViewById(R.id.lv_live_room_chat);
		et_live_room_input = (EditText) mActivity.findViewById(R.id.et_live_room_input);
		bt_live_room_sender = (Button) mActivity.findViewById(R.id.bt_live_room_sender);
		bt_live_room_sender.setOnClickListener(mOnClickListener);
		iv_live_room_face = (ImageView) mActivity.findViewById(R.id.iv_live_room_face);
		iv_live_room_face.setOnClickListener(mOnClickListener);
		
		mChatFaceMap.put("拜拜", "baibai"); 
		mChatFaceMap.put("白眼", "baiyan"); 
		mChatFaceMap.put("鄙视", "bishi");  
		mChatFaceMap.put("闭嘴", "bizui"); 
		mChatFaceMap.put("不高兴", "bugaoxing"); 
		mChatFaceMap.put("打哈哈", "dahaha");
		mChatFaceMap.put("发怒", "fanu");  
		mChatFaceMap.put("鼓掌", "guzhang"); 
		mChatFaceMap.put("害羞", "haixiu"); 
		mChatFaceMap.put("黑线", "heixian");
		mChatFaceMap.put("囧", "jiong");
		mChatFaceMap.put("可爱", "keai");
		mChatFaceMap.put("可怜", "kelian");
		mChatFaceMap.put("酷", "ku"); 
		mChatFaceMap.put("哭", "kule");
		mChatFaceMap.put("冷汗", "lenghan");
		mChatFaceMap.put("流泪", "liulei"); 
		mChatFaceMap.put("亲亲", "qinqin"); 
		mChatFaceMap.put("色", "se");
		mChatFaceMap.put("胜利", "shengli"); 
		mChatFaceMap.put("睡觉", "shuijiao"); 
		mChatFaceMap.put("偷笑", "touxiao");
		mChatFaceMap.put("吐", "tu"); 
		mChatFaceMap.put("委屈", "weiqu"); 
		mChatFaceMap.put("微笑", "weixiao"); 
		mChatFaceMap.put("握手", "woshou"); 
		mChatFaceMap.put("心", "xin"); 
		mChatFaceMap.put("心碎", "xinsui"); 
		mChatFaceMap.put("嘘", "xu"); 
		mChatFaceMap.put("疑问", "yiwen"); 
		mChatFaceMap.put("晕", "yun");
		mChatFaceMap.put("眨眼", "zhayan"); 
		mChatFaceMap.put("跩", "zhuai"); 
		mChatFaceMap.put("抓狂", "zhuakuang"); 
		mChatFaceMap.put("龇牙笑", "ziyaxiao"); 
		
		try {
			AssetManager am = mActivity.getAssets();
			String[] files = am.list("face");
			Bitmap bitmap = null;
			BitmapDrawable drawable = null;
			InputStream is = null;
			for(String file : files) {
				is = am.open("face/"+file);
				bitmap = BitmapFactory.decodeStream(is);
				drawable = new BitmapDrawable(mActivity.getResources(), bitmap);
				mChatDrawableList.add(drawable);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	private void enterRoom() {
		new EnterRoom().execute(mRoomId);
	}
	
	class ChatAdapter extends BaseAdapter {
		private List<ChatContent> mContentList;
		
		public ChatAdapter(List<ChatContent> contentList) {
			mContentList = contentList;
		}
		
		@Override
		public int getCount() {
			return mContentList.size();
		}

		@Override
		public Object getItem(int position) {
			return mContentList.get(position);
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
				view = View.inflate(mActivity, R.layout.live_room_chat, null);
				viewHolder = new ViewHolder();
				viewHolder.nameTV = (TextView) view.findViewById(R.id.tv_live_room_chat_name);
				viewHolder.timeTV = (TextView) view.findViewById(R.id.tv_live_room_chat_time);
				viewHolder.contentTV = (TextView) view.findViewById(R.id.tv_live_room_chat_content);
				view.setTag(viewHolder);
			}else {
				view = convertView;
				viewHolder = (ViewHolder) view.getTag();
			}
			ChatContent content = mContentList.get(position);
			viewHolder.nameTV.setText(content.getName());
			viewHolder.timeTV.setText(content.getTime());
			
			String data = content.getContent();
			SpannableString spannableString = new SpannableString(data);
			for(int i = 0; i < data.length(); i++) {
				int leftIndex = data.indexOf('[', i);
				KuwoLog.i(TAG, "leftIndex="+leftIndex);
				if(leftIndex != -1) {
					int rightIndex = data.indexOf(']', leftIndex);
					String faceStr = data.substring(leftIndex+1, rightIndex); //例如[心]：取出‘心’
					KuwoLog.i(TAG, "faceStr="+faceStr);
					Drawable drawable = getFaceFromAsset(faceStr);
					drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight());
					ImageSpan imageSpan = new ImageSpan(drawable,ImageSpan.ALIGN_BASELINE);
					spannableString.setSpan(imageSpan,leftIndex,rightIndex+1,Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
				}
				
			}
			viewHolder.contentTV.setText(spannableString);
			return view;
		}
		
	}
	
	static class ViewHolder {
		TextView nameTV;
		TextView timeTV;
		TextView contentTV;
	}
	
	private Drawable getFaceFromAsset(String fileName) {
		Bitmap bitmap = null;
		BitmapDrawable drawable = null;
		try {
			AssetManager am = mActivity.getResources().getAssets();
			String[] files = am.list("face");
			InputStream is = null;
			for(String file : files) {
				KuwoLog.i(TAG, "file name: "+file);
				String name = mChatFaceMap.get(fileName);
				if(file.equals(name+".png")) {
					is = am.open("face/"+file);
					break;
				}
			}
			bitmap = BitmapFactory.decodeStream(is);
			drawable = new BitmapDrawable(mActivity.getResources(), bitmap);
		} catch (IOException e) {
			e.printStackTrace();
		}
		return drawable;
	}
	
	private OnLiveDataRecieveListener mOnLiveDataRecieveListener = new OnLiveDataRecieveListener() {
		
		@Override
		public void onError(String id, String c, String t, String f, String n,
				String data) {
			
		}
		
		@Override
		public void onChatMessageRecieve(String id, String c, String t, String f,
				String n, String data) {
			
			KuwoLog.i(TAG, "n="+n);
			KuwoLog.i(TAG, "data="+data);
			if(n.equals("admin")) {
				return;
			}
			ChatContent content = new ChatContent();
			content.setName(n);
			SimpleDateFormat df = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");//设置日期格式 
			content.setTime(df.format(new Date()));
			content.setContent(data);
			contentList.add(content);
			handler.sendEmptyMessage(0);
		}
		
		@Override
		public void onChannelMessageRecieve(String id, String c, String t,
				String f, String data) {
			
		}
	};
	private Handler handler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				mChatAdapter.notifyDataSetChanged();
				break;
			default:
				break;
			}
		}
	};
	
	class EnterRoom extends AsyncTask<String, Void, Void> {

		@Override
		protected Void doInBackground(String... params) {
			String roomId = params[0];
			liveLogic = new LiveLogic();
			liveLogic.enterRoom(roomId, mOnLiveDataRecieveListener);
			return null;
		}
		
		@Override
		protected void onPostExecute(Void result) {
			loadSingerInfo();
			contentList = new ArrayList<ChatContent>();
			mChatAdapter = new ChatAdapter(contentList);
			chatListView.setAdapter(mChatAdapter);
			super.onPostExecute(result);
		}
	}

	private void loadSingerInfo() {
		new SingerInfoLoader().execute(mRoomId);
	}
	
	class SingerInfoLoader extends AsyncTask<String, Void, HashMap<String, String>> {

		/**
		 * anchorId,anchorName,flowers
		 */
		@Override
		protected HashMap<String, String> doInBackground(String... params) {
			HashMap<String, String> result = null;
			String roomId = params[0];
			KuwoLog.i(TAG, "roomId="+roomId);
			LiveLogic logic = new LiveLogic();
			result = logic.getAnchorInfo(roomId);
			KuwoLog.i(TAG, "result(hashmap)==="+result);
			return result;
		}

		@Override
		protected void onPostExecute(HashMap<String, String> result) {
			String anchorName = result.get("anchorName");
			String anchorId = result.get("anchorId");
			String flowers = result.get("flowers");
			tv_live_room_singer_name.setText("正在演唱："+anchorName);
			tv_live_room_singer_id.setText("("+anchorId+")");
			tv_live_room_singer_flower_count.setText("鲜花："+flowers);
			
			KuwoLog.i(TAG, "anchorName="+anchorName);
			KuwoLog.i(TAG, "anchorId="+anchorId);
			KuwoLog.i(TAG, "flowers="+flowers);
			
			if(anchorId == null) {
				return;
			}else {
				loadSingerImageUrl(anchorId);
			}
			super.onPostExecute(result);
		}
	}
	
	private void loadSingerImageUrl(String anchorId) {
		new SingerImageUrlLoader().execute(anchorId);
	}
	
	class SingerImageUrlLoader extends AsyncTask<String, Void, List<String>> {

		@Override
		protected List<String> doInBackground(String... params) {
			List<String> result = null;
			String anchorId = params[0];
			try {
				LiveLogic logic = new LiveLogic();
				result = logic.getAnchorPic(anchorId);
			} catch (IOException e) {
				e.printStackTrace();
			}
			return result;
		}

		@Override
		protected void onPostExecute(List<String> result) {
			if(result == null) {
				Toast.makeText(mActivity, "imageUrl result="+result, 0).show();
				return;
			}
			GalleryAdapter adapter = new GalleryAdapter(result);
			mSingerGallery.setAdapter(adapter);
			super.onPostExecute(result);
		}
		
	}
	
	class GalleryAdapter extends BaseAdapter {
		private List<String> mImageUrlList;
		private int myGalleryItemBackground;
		
		public GalleryAdapter(List<String> imageUrlList) {
			mImageUrlList = imageUrlList;
			// 实用布局文件中的Gallery属性
    		TypedArray a = mActivity.obtainStyledAttributes(R.styleable.Gallery);
    		// 取得gallery属性饿index id
    		myGalleryItemBackground = a.getResourceId(R.styleable.Gallery_android_galleryItemBackground, 0);
    		// 让对象的styleable属性能反复实用
    		a.recycle();	
		}

		@Override
		public int getCount() {
			return mImageUrlList.size();
		}

		@Override
		public Object getItem(int position) {
			return mImageUrlList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			ImageView iv = new ImageView(mActivity);
			String imageUrl = mImageUrlList.get(position);
			KuwoLog.i(TAG, "主播图片地址："+imageUrl);
			String imagePath = ImageUtils.makeImagePathFromUrl(imageUrl);
			iv.setTag(imagePath);
			Bitmap bitmap = ImageUtils.loadImageFromCache(new ImageCallback(), imagePath, imageUrl, imageWidth, imageHeight);
			if(bitmap == null) {
				iv.setImageResource(R.drawable.image_loading_small);
			}else {
				iv.setImageBitmap(bitmap);
			}
			//设置背景的
			iv.setBackgroundResource(myGalleryItemBackground);
			//设置图片的伸缩模式
			iv.setScaleType(ImageView.ScaleType.FIT_XY);
			//设置ImageView的布局，300*420
			iv.setLayoutParams(new Gallery.LayoutParams(200, 200));
			return iv ;
		}
		
	}
	
	class ImageCallback implements ImageAsyncTaskCallback {

		@Override
		public void onPreImageLoad() {
			
		}

		@Override
		public void onPostImageLoad(Bitmap bitmap, String imagePath) {
			ImageView iv = (ImageView) mSingerGallery.findViewWithTag(imagePath);
			if(iv != null) {
				iv.setImageBitmap(bitmap);
			}
		}
	}
	
	private View.OnClickListener mOnClickListener = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			int id = v.getId();
			switch (id) {
			case R.id.bt_live_room_back:
				mActivity.finish();
				break;
			case R.id.iv_leave_room:
				Toast.makeText(mActivity, "离开房间", 0).show();
				new LeafRoom().execute(mRoomId);
				break;
			case R.id.bt_live_room_sender:
				Toast.makeText(mActivity, "发送消息="+et_live_room_input.getText().toString(), 0).show();
				liveLogic.sendMessage(et_live_room_input.getText().toString());
				et_live_room_input.setText("");
				break;
			case R.id.iv_live_room_face:
				//TODO 弹出pupwindow
				Toast.makeText(mActivity, "room face click!", 0).show();
				int screenWidth = mActivity.getWindowManager().getDefaultDisplay().getWidth();
				
				View contentView = View.inflate(mActivity, R.layout.chat_face_layout, null);
				GridView chatFaceGV = (GridView) contentView.findViewById(R.id.gv_chat_face);
				chatFaceGV.setAdapter(new ChatFaceAdapter(mChatDrawableList));
				chatFaceGV.setOnItemClickListener(new OnItemClickListener() {

					@Override
					public void onItemClick(AdapterView<?> parent, View view,
							int position, long id) {
						mChatPopupWindow.dismiss();
						
						SpannableString spannableString = new SpannableString("["+mChatFaceStrs[position]+"]");
						Drawable drawable = mChatDrawableList.get(position);
						drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight());
						ImageSpan span = new ImageSpan(drawable,ImageSpan.ALIGN_BASELINE);
						spannableString.setSpan(span,0,spannableString.length(),Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
						int startIndex = et_live_room_input.getSelectionStart();
						et_live_room_input.getText().insert(startIndex, spannableString);
					}
				});
				mChatPopupWindow = new PopupWindow(contentView, screenWidth, DensityUtils.dip2px(mActivity, 200));
//				mChatPopupWindow.setBackgroundDrawable(mActivity.getResources().getDrawable(R.drawable.content_bg));
				mChatPopupWindow.setFocusable(true);
				mChatPopupWindow.setTouchable(true);
				showPopupWindow();
				break;
			default:
				break;
			}
			
		}

		private void showPopupWindow() {
			if(!mChatPopupWindow.isShowing()) {
				mChatPopupWindow.showAsDropDown(iv_live_room_face);
			}
		}
	};
	
	class ChatFaceAdapter extends BaseAdapter {
		private List<Drawable> mChatDrawables;
		
		public ChatFaceAdapter(List<Drawable> chatDrawable) {
			mChatDrawables = chatDrawable;
		}

		@Override
		public int getCount() {
			return mChatDrawables.size();
		}

		@Override
		public Object getItem(int position) {
			return mChatDrawables.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			View view = View.inflate(mActivity, R.layout.chat_face_grid_item, null);
			ImageView chatFaceIV = (ImageView) view.findViewById(R.id.iv_chat_face);
			chatFaceIV.setImageDrawable(mChatDrawables.get(position));
			return view;
		}
	}
	
	class LeafRoom extends AsyncTask<String, Void, Void> {

		@Override
		protected Void doInBackground(String... params) {
			String roomId = params[0];
			liveLogic.leftRoom(roomId);
			return null;
		}

		@Override
		protected void onPostExecute(Void result) {
			Toast.makeText(mActivity, "离开成功！", 0).show();
			mActivity.finish();
			super.onPostExecute(result);
		}
	}
}
