package com.ifeng.news2.activity;

import java.io.File;
import java.util.ArrayList;

import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.net.Uri;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.ifeng.news2.R;
import com.ifeng.news2.service.DownLoadAppService;
import com.ifeng.news2.service.DownLoadAppService.DownloadManageListener;
import com.ifeng.news2.service.DownLoadAppService.UpdateThread;

public class DownloadManageActivity extends AppBaseActivity implements DownloadManageListener{
	private DownLoadAppService downloadService;
	private boolean isBinded = false;
	
	private ProgressBar pb;
	private TextView title;
	private TextView progress;
	private TextView introduction;
	private Button cancelTaskBtn;
	
	//tofix    currentIndex始终为0  而 arraylist 中则一直在add
	private int currentIndex = 0;
	private ServiceConnection connection = new ServiceConnection() {
		
		@Override
		public void onServiceDisconnected(ComponentName name) {
			downloadService = null;
		}
		
		@Override
		public void onServiceConnected(ComponentName name, IBinder service) {
			downloadService = ((DownLoadAppService.localBinder)service).getService();
			downloadService.setDownloadManageListener(currentIndex,DownloadManageActivity.this);
			pb.setProgress(0);
			final ArrayList<UpdateThread> taskLists = downloadService.getTaskList();
			if(taskLists.isEmpty() || currentIndex >= taskLists.size()){
				return ;
			}
			title.setText(taskLists.get(currentIndex).appName);
			
			Log.i("***********************", currentIndex+"");
			
			//listener没有实时更新 progressPersent   listener中需要添加一个监听进度的方法  就搞定了 OY
			progress.setText(taskLists.get(currentIndex).progressPersent+"%");
			introduction.setVisibility(View.GONE);
			cancelTaskBtn.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					taskLists.get(currentIndex).exit = true;
				}
			});
		}
	};
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		setContentView(R.layout.download);
		findViewsById();
		currentIndex = getIntent().getIntExtra("index", 0);
		doBindService();
		super.onCreate(savedInstanceState);
	}
	
	private void findViewsById(){
		pb = (ProgressBar) findViewById(R.id.offline_down_pb);
		title = (TextView) findViewById(R.id.offline_down_title);
		progress = (TextView) findViewById(R.id.offline_down_report);
		introduction = (TextView) findViewById(R.id.offline_down_introduction);
		cancelTaskBtn = (Button) findViewById(R.id.cancel);
		
		
	}

	@Override
	protected void onDestroy() {
		doUnbindService();
		Log.i("~~~~~~~~~~~~~~", "OnDestory");
		super.onDestroy();
	}
	
	@Override
	protected void onNewIntent(Intent intent) {
		doUnbindService();
		currentIndex = intent.getIntExtra("index", 0);
		doBindService();
		super.onNewIntent(intent);
	}
	
	private void doUnbindService(){
		if(isBinded){
			downloadService.clearDownloadManageListener();
			unbindService(connection);
			isBinded = false;
			Log.i("----------------", "unbindservice");
		}
	}
	
	private void doBindService(){
			Intent intent = new Intent(DownloadManageActivity.this,DownLoadAppService.class);
			bindService(intent, connection, BIND_AUTO_CREATE);
			isBinded = true;
			Log.i("++++++++++++++++++++", "bindservice");
	}


	@Override
	public void updateProgress(final int progressPercent) {
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
					pb.setProgress(progressPercent);
					progress.setText(progressPercent+"%");
			}
		});
		
	}

	@Override
	public void onComplete(File updateFile) {
		//Toast.makeText(DownloadManageActivity.this, "下载完成，请在通知栏中点击安装。", Toast.LENGTH_SHORT).show();
		Uri uri = Uri.fromFile(updateFile);
		Intent installIntent = new Intent(Intent.ACTION_VIEW);
		installIntent.setDataAndType(uri,
				"application/vnd.android.package-archive");
		startActivity(installIntent);
		finish();
	}

	@Override
	public void onFail() {
		showMessage("下载失败");
		finish();
	}
	
}
