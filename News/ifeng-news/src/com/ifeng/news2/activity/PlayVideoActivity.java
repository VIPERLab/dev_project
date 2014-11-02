package com.ifeng.news2.activity;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnErrorListener;
import android.media.MediaPlayer.OnPreparedListener;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.MediaController;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.VideoView;

import com.ifeng.news2.R;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.WindowPrompt;
import com.ifeng.share.util.NetworkState;
import com.qad.util.Utils;
import com.qad.util.WToast;

public class PlayVideoActivity extends AppBaseActivity {
	private VideoView videoView;
	private String videoPath;
	private int mPositionWhenPaused;
	private float videoRatio = -1;
	private TextView progressBar;
	private Boolean isPlaying=false;
	private String id;
	private PlayTask playTask;
	private boolean isFinish = false;
	private MediaPlayer localMPRef = null;
//	private String title = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.videoview);
		initData();
		findViewById();
		if(!TextUtils.isEmpty(id)){
			StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.v, "vid="+id);
		}		
		playVideo();

	}
	public static boolean playVideo(Context context,String path,String id){
		if (!NetworkState.isActiveNetworkConnected(context)) {
			WindowPrompt.getInstance(context).showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
			return false;
		}
		Intent intent =  new Intent(context,PlayVideoActivity.class);
		//fix bug 16219 
		intent.setFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
		Bundle bundle = new Bundle();
		bundle.putString("path", path);
		bundle.putString("id", id);
		intent.putExtras(bundle);
		context.startActivity(intent);
		((Activity) context).overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
		return true;
	}
	public String filterVideoPath(String videoPath){
		if(videoPath==null || videoPath.length()==0)return null;
		String filterPath = null;
		try {
			Uri uri = Uri.parse(videoPath);
			filterPath = uri.getQueryParameter("url");
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(TextUtils.isEmpty(filterPath)){
				filterPath = videoPath;
			}
		}
		return filterPath;
	}
	
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
	  super.onConfigurationChanged(newConfig);
	  setVideoLayout();
	}
	
	private void setVideoLayout(){
	  if (videoRatio == -1) {
	    return;
	  }
	  
	  try {
		  // fix bug #19400 【凤凰视频】横屏下观看视频home键退出再次点击凤凰新闻，凤凰新闻停止运行
		  // android.media.MediaPlayer.getVideoWidth 可能抛出异常：java.lang.IllegalStateException
		  if (null != localMPRef && 0 != localMPRef.getVideoWidth() && 0 != localMPRef.getVideoHeight()) {
			  videoRatio = localMPRef.getVideoWidth()/(float)localMPRef.getVideoHeight();
		  }
	  } catch (Exception e) {
		  // ignore
	  }
	  DisplayMetrics disp = getResources().getDisplayMetrics();
	  int windowWidth = disp.widthPixels, windowHeight = disp.heightPixels;
	  float windowRatio = windowWidth / (float) windowHeight;
	  boolean useWinWidth = windowRatio > videoRatio ? false : true;
	  int w = 0, h = 0;
	  if (useWinWidth) {//以宽为准
	    w = (int)windowWidth;
	    h = (int)(windowWidth/videoRatio);
	  } else {
	    w =  (int)(windowHeight*videoRatio);
	    h = windowHeight;
	  }

	  if (w == 0 || h== 0) {
	    return;
	  }
	  LayoutParams params = new LayoutParams(w, h);
	  params.addRule(RelativeLayout.CENTER_IN_PARENT);
	  videoView.setLayoutParams(params);
	  videoView.getHolder().setFixedSize(w, h);
	}
	
	public void playVideo() {
		Log.i("Sdebug", "IFeng Video -- playVideo -- in, videoPath: " + videoPath);
		if (TextUtils.isEmpty(videoPath)) {
			showMessage("播放失败");
			finish();
			return;
		}
		videoView.setVideoPath(videoPath);
		Log.i("Sdebug", "IFeng Video -- setVideoPath done! ");
		videoView.setOnPreparedListener(new OnPreparedListener() {

			@Override
			public void onPrepared(MediaPlayer mp) {
				Log.i("Sdebug", "IFeng Video -- onPrepared -- called");
				localMPRef = mp;
				mp.start();
				if (0 == mp.getVideoWidth() || 0 == mp.getVideoHeight() || videoPath.startsWith("rstp")) {
				  videoRatio = (float)(4/3);
                } else {
                  videoRatio = mp.getVideoWidth()/(float)mp.getVideoHeight();
                }
				setVideoLayout();
				if(isSpecialDevice()){
					progressBar.setVisibility(View.GONE);
				}
			}

		});
		
		videoView.setOnErrorListener(new OnErrorListener() {

			@Override
			public boolean onError(MediaPlayer mp, int what, int extra) {
				Toast.makeText(PlayVideoActivity.this, "播放失败", Toast.LENGTH_SHORT).show();
				finish();
				return true;
			}
		});
		videoView.setOnCompletionListener(new OnCompletionListener() {
			
			@Override
			public void onCompletion(MediaPlayer mp) {
				// TODO Auto-generated method stub
				isFinish = true ; 
			}
		});
		videoView.setMediaController(new MediaController(this));
		videoView.requestFocus();
		Log.i("Sdebug", "IFeng Video -- playVideo -- out");
	}
	public void initData() {
		try {
			Bundle bundle = getIntent().getExtras();
//			title = bundle.getString("title");
			videoPath = bundle.getString("path");
			//videoPath = "http://api.3g.ifeng.com//download?aid=38968803&url=http://3gs.ifeng.com/userfiles/video/2012/07/02/2858cb69-e234-4c96-a2e9-44c5e3b1921f280.mp4&mid=8995a3";
			videoPath = filterVideoPath(videoPath);
			id= bundle.getString("id");
			if (videoPath == null && bundle.getString("video_path") != null)
				videoPath = bundle.getString("video_path");
		} catch (Exception e) {
			showMessage("播放失败");
			if (getIntent() != null
					&& getIntent().getBooleanExtra(
							IntentUtil.EXTRA_REDIRECT_HOME, false)) {
				IntentUtil.redirectHome(PlayVideoActivity.this);				
			}
			finish();
		}
		
	}
	public void findViewById() {
		progressBar = (TextView)findViewById(R.id.progressBar);
		videoView = (VideoView)findViewById(R.id.surface_view);
	}
	@Override
	@SuppressWarnings("unchecked")
	protected void onResume() {
		super.onResume();
		continuePlay();
		playTask = new PlayTask();
		if(!isSpecialDevice())
			playTask.execute();
	}
	public void continuePlay(){
		//fix bug 18007
		if(!isFinish)
			progressBar.setVisibility(View.VISIBLE);
		
		if (mPositionWhenPaused>0) {
			videoView.seekTo(mPositionWhenPaused);
			mPositionWhenPaused = -1;
			if (!videoView.isPlaying() && isPlaying) {
				isPlaying = false;
				videoView.start();
			}
		}

	}
	@Override
	protected void onPause() {
		super.onPause();
		isPlaying = videoView.isPlaying();
		mPositionWhenPaused = videoView.getCurrentPosition();
		if(videoView.isPlaying())
			videoView.pause();	
		if(playTask != null){
			playTask.cancel(true);
			playTask = null;
		}
	}
	@Override
	protected void onDestroy() {
		super.onDestroy();
		if(videoView!=null)videoView.stopPlayback();	
		if(playTask != null){
			playTask.cancel(true);
			playTask = null;
		}
	}
	/*class VideoRedirect extends Thread{
		@Override
		public void run() {
			String host=Proxy.getDefaultHost();
			int port  =Proxy.getDefaultPort();
			HttpClient httpClient = new HttpClient();
			if (host!=null && port!=-1) {
				httpClient.getHostConfiguration().setProxy(host, port);
			}
			try {
				HttpMethod httpMethod = new GetMethod(videoPath);
				httpClient.executeMethod(httpMethod);
				httpMethod.releaseConnection();
			} catch (Exception e) {
				e.printStackTrace();
			} 
		}
		
	}
	public String getVideoPath(String videoPath){
		new VideoRedirect().start();
		return filterVideoPath(videoPath);
	}*/
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK){
			if (getIntent() != null
					&& getIntent().getBooleanExtra(
							IntentUtil.EXTRA_REDIRECT_HOME, false)) {
				IntentUtil.redirectHome(PlayVideoActivity.this);
				finish();
				return true;
			}
		}
		return super.onKeyDown(keyCode, event);
	}
	//监听播放
	private class PlayTask extends AsyncTask {

		@Override
		protected Object doInBackground(Object... params) {
			//只有当线程被cancle并且video的position大于0时跳出循环
			while (!isCancelled() && videoView.getCurrentPosition() <= 0) {
				try {
					Thread.sleep(100);
					continue;
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			return null; 
		}

		protected void onPostExecute(Object result) {
				progressBar.setVisibility(View.GONE);
			}
		};
		
		/**
		 * 特殊型号手机
		 * @return
		 */
		private boolean isSpecialDevice(){
			return "HUAWEI Y220-T10".equalsIgnoreCase(Utils.getPhoneModel()) 
					|| "Lenovo A288t".equalsIgnoreCase(Utils.getPhoneModel());
		}

}
