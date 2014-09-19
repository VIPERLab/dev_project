
package cn.kuwo.sing.controller;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Field;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.graphics.Color;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.Html;
import android.text.SpannableString;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.network.BaseProvider;
import cn.kuwo.framework.network.HttpProvider;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.bean.SquareShow;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.db.KgeDao;
import cn.kuwo.sing.db.MusicDao;
import cn.kuwo.sing.logic.AudioLogic;
import cn.kuwo.sing.logic.AudioLogic.ProcessListener;
import cn.kuwo.sing.logic.MtvLogic;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.logic.service.UserService;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.ThirdPartyLoginActivity;
import cn.kuwo.sing.util.DialogUtils;

import com.umeng.analytics.MobclickAgent;

public class ShareController extends BaseController {
	private final String TAG = "ShareController";
	private BaseActivity mActivity;
	private Button bt_share_layout_back;
	private EditText et_share_content;
	private Button bt_share_go;
	private String uid;
	private String kid;
	private String uname;
	private String title;
	private CheckBox cb_share_weibo;
	private CheckBox cb_share_qq;
	private CheckBox cb_share_renren;
	private TextView tv_share_text_count_tip;
	private String mFlag;
	private TextView tv_share_layout_title;
	private String zipPath;
	private String aacPath;
	private ProgressDialog uploadPd;
	private Long kgeDate;
	private Boolean needSaveSong;
	private ProgressDialog saveDialog;
	private ProgressDialog sharePd;
	private String uploadKgeId;
	private String shareKgeId;
	private String musicName;
	private String fromSquareActivity;
	private ProgressDialog lotteryingPd;
	private boolean mSaveKgeResult = false;
	
	public ShareController(BaseActivity activity) {
		mActivity = activity;
		initData();
		initView();
	}

	private void initData() {
		mFlag = mActivity.getIntent().getStringExtra("mFlag");
		if("shareMTV".equals(mFlag)) {
			uname = mActivity.getIntent().getStringExtra("uname");
			title = mActivity.getIntent().getStringExtra("title");
			kid = mActivity.getIntent().getStringExtra("kid");
		}else if("uploadMySong".equals(mFlag)) {
			kid = mActivity.getIntent().getStringExtra("kid");
			needSaveSong = mActivity.getIntent().getBooleanExtra("needSaveSong", false);
			uploadKgeId = (String) mActivity.getIntent().getStringExtra("uploadKgeId");
			if(!TextUtils.isEmpty(uploadKgeId)) {
				musicName = mActivity.getIntent().getStringExtra("musicName");
			}
			kgeDate = mActivity.getIntent().getLongExtra("kgeDate", 0);
			zipPath = mActivity.getIntent().getStringExtra("zipPath");
			aacPath = mActivity.getIntent().getStringExtra("aacPath");
		}else if("0".equals(mFlag)) {
			kid = mActivity.getIntent().getStringExtra("kid");
			shareKgeId = mActivity.getIntent().getStringExtra("uploadKgeId");
			if(!TextUtils.isEmpty(shareKgeId)) {
				musicName = mActivity.getIntent().getStringExtra("musicName");
			}
			kgeDate = mActivity.getIntent().getLongExtra("kgeDate", 0);
		}
		uid = mActivity.getIntent().getStringExtra("uid");
		fromSquareActivity = mActivity.getIntent().getStringExtra("fromSquareActivity");
	}

	private void initView() {
		tv_share_layout_title = (TextView) mActivity.findViewById(R.id.tv_share_layout_title);
		bt_share_layout_back = (Button) mActivity.findViewById(R.id.bt_share_layout_back);
		bt_share_layout_back.setOnClickListener(mOnClickListener);
		et_share_content = (EditText) mActivity.findViewById(R.id.et_share_content);
		bt_share_go = (Button) mActivity.findViewById(R.id.bt_share_layout_go);
		tv_share_text_count_tip = (TextView) mActivity.findViewById(R.id.tv_share_text_count_tip);
		String shareMTVStr = "我刚刚听到"+uname+"演唱的《"+title+"》,绝对够赞！快来听听吧!（分享自#酷我K歌#@酷我音乐）";
		String noMusicStr = "我用#酷我K歌#Android版清唱了一首歌，大家快来听听吧！";
		String musicStr = "我用#酷我K歌#Android版演唱了一首《"+musicName+"》，大家快来听听吧！";
		if(fromSquareActivity != null && Config.getPersistence().squareActivityMap != null) {
			musicStr = Config.getPersistence().squareActivityMap.get(fromSquareActivity).sharecont;
		}
		
		if("shareMTV".equals(mFlag)) {
			et_share_content.setText(shareMTVStr);
			bt_share_go.setText("发布");
			tv_share_layout_title.setText("分享");
			tv_share_text_count_tip.setText("还可以输入"+(140-shareMTVStr.toString().length())+"个字");
		}else if("uploadMySong".equals(mFlag)) {
			if(TextUtils.isEmpty(uploadKgeId)) {
				et_share_content.setText(noMusicStr);
				tv_share_text_count_tip.setText("还可以输入"+(140-noMusicStr.toString().length())+"个字");
			}else {
				et_share_content.setText(musicStr);
				tv_share_text_count_tip.setText("还可以输入"+(140-musicStr.toString().length())+"个字");
			}
			bt_share_go.setText("上传");
			tv_share_layout_title.setText("上传作品");
		}else if("shareMySong".equals(mFlag)) {
			if(TextUtils.isEmpty(shareKgeId)) {
				et_share_content.setText(noMusicStr);
				tv_share_text_count_tip.setText("还可以输入"+(140-noMusicStr.toString().length())+"个字");
			}else {
				et_share_content.setText(musicStr);
				tv_share_text_count_tip.setText("还可以输入"+(140-musicStr.toString().length())+"个字");
			}
			bt_share_go.setText("发布");
			tv_share_layout_title.setText("分享作品");
		}
		et_share_content.addTextChangedListener(new TextWatcher() {
			
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {
				int textCount = et_share_content.getText().toString().length();
				KuwoLog.i(TAG, "count="+textCount);
				if((140-textCount) <= 0) {
					tv_share_text_count_tip.setText((140-textCount)+"(输入内容大于140字) ");
					tv_share_text_count_tip.setTextColor(Color.RED);
				}else {
					tv_share_text_count_tip.setText("还可以输入"+(140-textCount)+"个字");
					tv_share_text_count_tip.setTextColor(Color.BLACK);
				}
			}
			
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				
			}
			
			@Override
			public void afterTextChanged(Editable s) {
				
			}
		});
		cb_share_weibo = (CheckBox) mActivity.findViewById(R.id.cb_share_weibo);
		cb_share_qq = (CheckBox) mActivity.findViewById(R.id.cb_share_qq);
		cb_share_renren = (CheckBox) mActivity.findViewById(R.id.cb_share_renren);
		
		if(Config.getPersistence().user != null) {
			if(Config.getPersistence().user.isBindQQ) {
				cb_share_qq.setChecked(true);
				cb_share_qq.setBackgroundResource(R.drawable.qq_share);
			}else {
				cb_share_qq.setChecked(false);
				cb_share_qq.setBackgroundResource(R.drawable.qq_share_down);
			}
			if(Config.getPersistence().user.isBindWeibo) {
				cb_share_weibo.setChecked(true);
				cb_share_weibo.setBackgroundResource(R.drawable.sina_share);
			}else {
				cb_share_weibo.setChecked(false);
				cb_share_weibo.setBackgroundResource(R.drawable.sina_share_down);
			}
			if(Config.getPersistence().user.isBindRenren) {
				cb_share_renren.setChecked(true);
				cb_share_renren.setBackgroundResource(R.drawable.renren_logo);
			}else {
				cb_share_renren.setChecked(false);
				cb_share_renren.setBackgroundResource(R.drawable.renren_logo_down);
			}
		}
		
		cb_share_weibo.setOnCheckedChangeListener(new OnCheckedChangeListener() {
			
			@Override
			public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
				if(isChecked) {
					if(Config.getPersistence().user.isBindWeibo){
						cb_share_weibo.setBackgroundResource(R.drawable.sina_share);
					}else{
						showBindDialog("weibo", R.string.bind_sina_dialog_content);
					}
					
				}else {
					cb_share_weibo.setBackgroundResource(R.drawable.sina_share_down);
				}
			}
		});
		
		cb_share_qq.setOnCheckedChangeListener(new OnCheckedChangeListener() {
			
			@Override
			public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
				if(isChecked) {
					if(Config.getPersistence().user.isBindQQ){
						cb_share_qq.setBackgroundResource(R.drawable.qq_share);
					}else{
						showBindDialog("qq", R.string.bind_qq_dialog_content);
					}
				}else {
					cb_share_qq.setBackgroundResource(R.drawable.qq_share_down);
				}
			}
		});
		
		cb_share_renren.setOnCheckedChangeListener(new OnCheckedChangeListener() {
			
			@Override
			public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
				if(isChecked) {
					if(Config.getPersistence().user.isBindRenren){
						cb_share_renren.setBackgroundResource(R.drawable.renren_logo);
					}else{
						showBindDialog("renren", R.string.bind_renren_dialog_content);
					}
				}else {
					cb_share_renren.setBackgroundResource(R.drawable.renren_logo_down);
				}
			}
		});
		bt_share_go.setOnClickListener(mOnClickListener);
	}
	
	class ShareAsyncTask extends AsyncTask<String, Void, Integer> {
		private String flag;
		private String kid;
		
		@Override
		protected Integer doInBackground(String... params) {
			flag = params[0];
			kid = params[2];
			UserService service = new UserService();
			return service.shareByThird(params[0],params[1], Config.getPersistence().user.uid, Config.getPersistence().user.sid);
		}

		@Override
		protected void onPostExecute(Integer result) {
			KuwoLog.i(TAG, "share result="+result);
			switch (result) {
			case 1:
				MobclickAgent.onEvent(mActivity, "KS_SHARE_MUSIC", "1");
				et_share_content.setText("");
				KuwoLog.i(TAG, "分享成功！");
				sharePd.dismiss();
				Toast.makeText(mActivity, "分享成功", Toast.LENGTH_SHORT).show();
				if(mFlag.equals("uploadMySong") && fromSquareActivity != null && fromSquareActivity.equals("172")) {
					//抽奖
					if(cb_share_qq.isChecked() && cb_share_weibo.isChecked() && flag.equals("weibo")) 
						break;
					showLotteryDialog(kid);
				}else if(mFlag.equals("uploadMySong") && fromSquareActivity == null) {
					updateKgeState(kid);
				}else {
					mActivity.finish();
				}
				break;
				
			case 2:
				MobclickAgent.onEvent(mActivity, "KS_SHARE_MUSIC", "0");
				KuwoLog.i(TAG, "分享失败,请重新绑定帐号!");
				sharePd.dismiss();
				Toast.makeText(mActivity, "分享失败", Toast.LENGTH_SHORT).show();
				if(mFlag.equals("uploadMySong") && fromSquareActivity != null && fromSquareActivity.equals("172")) {
					//抽奖
					if(cb_share_qq.isChecked() && cb_share_weibo.isChecked() && flag.equals("weibo")) 
						break;
					showLotteryDialog(kid);
				}else if(mFlag.equals("uploadMySong") && fromSquareActivity == null) {
					updateKgeState(kid);
				}else {
					mActivity.finish();
				}

			default:
				MobclickAgent.onEvent(mActivity, "KS_SHARE_MUSIC", "0");
				KuwoLog.i(TAG, "分享失败！");
				sharePd.dismiss();
				Toast.makeText(mActivity, "分享失败", Toast.LENGTH_SHORT).show();
				if(mFlag.equals("uploadMySong") && fromSquareActivity != null && fromSquareActivity.equals("172")) {
					showLotteryDialog(kid);
				}else if(mFlag.equals("uploadMySong") && fromSquareActivity == null) {
					updateKgeState(kid);
				}else {
					mActivity.finish();
				}
				break;
			}
			super.onPostExecute(result);
		}
	}
	
	private void updateKgeState(String kid) {
		KgeDao kgeDao = new KgeDao(mActivity);
		Kge kge = kgeDao.getKge(kgeDate);
		kge.hasUpload = true;
		kge.kid = kid;
		kgeDao.update(kge);
		mActivity.setResult(Constants.RESULT_UPLOAD_SUCCESS);
		mActivity.finish();
	}
	
	public class ZipUploadAsyncTask extends AsyncTask<String, Void, String> {
		private String uploadTitle;
		private String rid;
		private String artist;
		private String zipPath;
		private String aacPath;

		@Override
		protected String doInBackground(String... params) {
			uploadTitle = params[0];
			rid = params[1];
			artist = params[2];
			zipPath = params[3];
			aacPath = params[4];
			final long zipSize = new File(zipPath).length();
			MtvLogic mtvLogic = new MtvLogic();
			String url = null;
			try {
				String from = "";
				if(Config.getPersistence().squareActivityMap != null && fromSquareActivity != null) {
					SquareShow activity = Config.getPersistence().squareActivityMap.get(fromSquareActivity);
					if(activity != null) 
						from = activity.type;
				}
				url = mtvLogic.zipUploadUrl(uploadTitle, rid, artist, String.valueOf(zipSize),from);
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
			KuwoLog.i(TAG, "upload zip url=" + url);
			HttpProvider zipProvider = new HttpProvider();
			zipProvider.setOnDownloadListener(new BaseProvider.OnDownloadListener() {
						private int len;

						@Override
						public boolean onStart(BaseProvider arg0, String arg1,
								int arg2, int arg3) {
							return true;
						}

						@Override
						public boolean onProcess(BaseProvider provider, byte[] arg1, int arg2, int length) {
							len = len + length;
							KuwoLog.i(TAG, "zip upload len=" + len+",zipSize="+zipSize);
							uploadPd.setProgress(len);
							return true;
						}

						@Override
						public void onFinish(BaseProvider arg0) {
							KuwoLog.i(TAG, "zip upload finish");
						}

						@Override
						public void onCancel(BaseProvider arg0) {

						}
					});
				KuwoLog.i(TAG, "zipPath="+zipPath);
			return zipProvider.upload(url, zipPath);
		}

		@Override
		protected void onPostExecute(String result) {
			KuwoLog.i(TAG, "zip upload result=" + result);
			if(result == null || !result.substring(0, 3).equals("200")) {
				uploadPd.dismiss();
				if(result != null && "upload_limit".equals(result.substring(result.lastIndexOf('|') + 1))) {
					Toast.makeText(mActivity, "上传失败，达到上限", 0).show();
				}else {
					Toast.makeText(mActivity, "上传失败", 0).show();
				}
				return;
			}
			String kid = result.substring(result.lastIndexOf('|') + 1);
			new AACUploadAsyncTask().execute(uploadTitle, kid, rid, artist, aacPath, zipPath);
			super.onPostExecute(result);
		}

	}

	public class AACUploadAsyncTask extends AsyncTask<String, Void, String> {
		private int zipFileLength;
		private Exception ex;

		@Override
		protected String doInBackground(String... params) {
			String uploadTitle = params[0];
			String kid = params[1];
			String rid = params[2];
			String artist = params[3];
			String aacPath = params[4];
			String zipPath = params[5];
			zipFileLength = (int) new File(zipPath).length();
			MtvLogic logic = new MtvLogic();
			final long aacSize = new File(aacPath).length();
			String url = null;
			try {
				String from = "";
				if(Config.getPersistence().squareActivityMap != null && fromSquareActivity != null) {
					SquareShow activity = Config.getPersistence().squareActivityMap.get(fromSquareActivity);
					if(activity != null) 
						from = activity.type;
				}
				url = logic.audioUploadUrl(uploadTitle, kid, rid, artist, String.valueOf(aacSize), from);
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
			KuwoLog.i(TAG, "upload aac url=" + url);
			HttpProvider provider = new HttpProvider();
			provider.setOnDownloadListener(new BaseProvider.OnDownloadListener() {
				private int len;

				@Override
				public boolean onStart(BaseProvider arg0, String arg1,
						int arg2, int arg3) {
					return true;
				}

				@Override
				public boolean onProcess(BaseProvider arg0, byte[] arg1,
						int arg2, int length) {
					len = len + length;
					KuwoLog.i(TAG, "aac upload len=" + len+",aacSize="+aacSize);
					uploadPd.setProgress(len+zipFileLength);
					return true;
				}

				@Override
				public void onFinish(BaseProvider arg0) {
					KuwoLog.i(TAG, "aac upload finish");
				}

				@Override
				public void onCancel(BaseProvider arg0) {

				}
			});
			KuwoLog.i(TAG, "aacPath="+aacPath);
			return provider.upload(url, aacPath);
		}

		@Override
		protected void onPostExecute(String result) {
			KuwoLog.i(TAG, "aac upload result=" + result);
			if(result == null || !result.substring(0, 3).equals("200")) {
				MobclickAgent.onEvent(mActivity, "KS_UPLOAD_MUSIC", "0");
				uploadPd.dismiss();
				Toast.makeText(mActivity, "上传失败", 0).show();
			}else {
				MobclickAgent.onEvent(mActivity, "KS_UPLOAD_MUSIC", "1");
				uploadPd.dismiss();
				Toast.makeText(mActivity, "上传成功", 0).show();
				String kid = result.substring(result.lastIndexOf('|') + 1);
				//2.share,(upload完毕后再分享)
				if(kid == null)
					kid = "";
				toShare(kid);
			}
			super.onPostExecute(result);
		}
	}
	
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			int id = v.getId();
			switch (id) {
			case R.id.bt_share_layout_back:
				mActivity.finish();
				break;
			case R.id.bt_share_layout_go:
				//
				InputMethodManager imm = (InputMethodManager)mActivity.getSystemService(Context.INPUT_METHOD_SERVICE);
				imm.hideSoftInputFromWindow(et_share_content.getWindowToken(), 0); 
				if(et_share_content.getText().toString().length() > 140) {
					Toast.makeText(mActivity, "字数超过140", 0).show();
					return;
				}
				if("shareMTV".equals(mFlag) || "shareMySong".equals(mFlag)) {
					if(!cb_share_qq.isChecked() && !cb_share_weibo.isChecked() && !cb_share_renren.isChecked()) {
						AlertDialog.Builder builder = new AlertDialog.Builder(mActivity);
						builder.setTitle("提示");
						builder.setMessage("你还没有选择要分享的第三方平台，请先选择！");
						builder.setPositiveButton("好的，我知道了", new OnClickListener() {
							
							@Override
							public void onClick(DialogInterface dialog, int which) {
								dialog.dismiss();
							}
						});
						builder.create().show();
					}else {
						//微博分享
						if(kid == null)
							kid = "";
						toShare(kid);
					}
				}else if("uploadMySong".equals(mFlag)) {
					//上传,分享
					if(needSaveSong && !mSaveKgeResult) {
						//先保存录音再上传分享
						Kge kge = (Kge) mActivity.getIntent().getSerializableExtra("kge");
						saveKge(kge);
					}else {
						//直接上传分享
						toUploadAndShare();
					}
				}
				
				break;
			default:
				break;
			}
		}
	};
	
	private void saveKge(final Kge kge) {
		saveDialog = new ProgressDialog(mActivity);
		saveDialog.setMessage("正在合成录音...");
		saveDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
		saveDialog.setCancelable(false);
		saveDialog.setCanceledOnTouchOutside(false);
		saveDialog.show();
		try {
       	 Class<?> clazz = ProgressDialog.class;
       	 TextView nullText = new TextView(mActivity);
       	 nullText.setText("");
       	 Field field = clazz.getDeclaredField("mProgressNumber");
       	 field.setAccessible(true);
			field.set(saveDialog, nullText);
		} catch (Exception e) {
			KuwoLog.printStackTrace(e);
		}
		// 保存Kge实体
		final AudioLogic lAudio = new AudioLogic();
		lAudio.setProcessListener(new ProcessListener() {
			
			@Override
			public void onProcess(int process, int current, int total) {
				KuwoLog.v(TAG, "process: " + process +"      current: " + current + "      total:" + total);
				int p = (int)(((current-1)*25.0/total) + (process * 25.0));
				saveDialog.setProgress(p);
			}
		});
		new Thread(){
			public void run() {
				if (lAudio.process(kge) == 0) {
					//		保存图片
					MtvLogic mtvLogic = new MtvLogic();
					if(!mtvLogic.savePictures(kge, PostProcessedController.imgList, fromSquareActivity)){
						KuwoLog.i(TAG, "保存图片失败");
					}
					KgeDao kgeDao = new KgeDao(mActivity);
					kgeDao.insertKge(kge);
					Message msg = saveFinishHandler.obtainMessage();
					msg.what = 0;
					saveFinishHandler.sendMessage(msg);
				}
			};
		}.start();
	}
	
	private Handler saveFinishHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				saveDialog.dismiss();
				KuwoLog.i(TAG, "保存完成");
				mSaveKgeResult = true;
				Intent saveFinishedIntent = new Intent();
				saveFinishedIntent.setAction("cn.kuwo.sing.save.change");
				mActivity.sendBroadcast(saveFinishedIntent);
				toUploadAndShare();
				break;

			default:
				break;
			}
		}
		
	};
	
	private void toShare(String kid) {
		if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
			Toast.makeText(mActivity, "没有网络，请稍后再试", 0).show();
			return;
		}
		String content = et_share_content.getText().toString();
		sharePd = new ProgressDialog(mActivity);
		sharePd.setMessage("正在分享...");
		sharePd.setCancelable(false);
		sharePd.setCanceledOnTouchOutside(false);
		if(cb_share_qq.isChecked()) {
			sharePd.show();
			if (content.length() <= 140) { 
				new ShareAsyncTask().execute("qq", content+"http://kzone.kuwo.cn/mlog/u"+uid+"/kge_"+kid+".htm", kid);
			}else {
				Toast.makeText(mActivity, "输入内容大于140字", 0).show();
			}
		}
		if(cb_share_weibo.isChecked()) {
			sharePd.show();
			if(content.length() <= 140) {
				new ShareAsyncTask().execute("weibo", content+"http://kzone.kuwo.cn/mlog/u"+uid+"/kge_"+kid+".htm", kid);
			}else {
				Toast.makeText(mActivity, "输入内容大于140字", 0).show();
			}
		}
		if(cb_share_renren.isChecked()) {
			sharePd.show();
			if(content.length() <= 140) {
				new ShareAsyncTask().execute("renren", content+"http://kzone.kuwo.cn/mlog/u"+uid+"/kge_"+kid+".htm", kid);
			}else {
				Toast.makeText(mActivity, "输入内容大于140字", 0).show();
			}
		}
		if(!cb_share_qq.isChecked() && !cb_share_weibo.isChecked() && !cb_share_renren.isChecked()) {
			if(fromSquareActivity != null && fromSquareActivity == "172")
				//HRB抽奖
				showLotteryDialog(kid);
			else
				updateKgeState(kid);
				
		}
	}
	
	private void showLotteryDialog(final String kid) {
		AlertDialog.Builder builder = new AlertDialog.Builder(mActivity);
		builder.setTitle("恭喜，参赛成功！");
		builder.setCancelable(false);
		builder.setMessage("您获得一次抽奖的机会，点击下面的按钮开始抽奖吧");
		builder.setPositiveButton("开始抽奖", new OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
				showLotteryingDialog();
			}
		});
		builder.setNegativeButton("不了，谢谢", new OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
				updateKgeState(kid);
			}
		});
		builder.create().show();
	}
	
	private void showLotteryingDialog() {
		lotteryingPd = new ProgressDialog(mActivity);
		lotteryingPd.setMessage("正在抽奖...");
		lotteryingPd.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		lotteryingPd.setCancelable(true);
		lotteryingPd.setCanceledOnTouchOutside(false);
		new LotteringAsyncTask().execute();
	}
	
	private class LotteringAsyncTask extends AsyncTask<Void, Void, Integer> {
		
		@Override
		protected void onPreExecute() {
			super.onPreExecute();
			lotteryingPd.show();
		}

		@Override
		protected Integer doInBackground(Void... params) {
			UserLogic userLogic = new UserLogic();
			return userLogic.lotterying4HrbActivity(mActivity, fromSquareActivity, kid);
		}
		
		@Override
		protected void onPostExecute(Integer result) {
			lotteryingPd.dismiss();
			if(result == 1) {
				//中奖
				showWinLotteryDialog();
			}else if(result == 0) {
				//没中奖
				showFailLotteryDialog();
			}else {
				KuwoLog.e(TAG, "服务端数据错误");
			}
			super.onPostExecute(result);
		}
	}
	
	private void showWinLotteryDialog() {
		AlertDialog.Builder builder = new AlertDialog.Builder(mActivity);
		builder.setTitle("哇，中奖啦！");
		builder.setMessage("恭喜您抽得iphone手机一部，我们的工作人员会在2个工作日内联系您，请随时保持信号通畅");
		builder.setPositiveButton("好的", new OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
				updateKgeState(kid);
			}
		});
		builder.create().show();
	}
	
	private void showFailLotteryDialog() {
		AlertDialog.Builder builder = new AlertDialog.Builder(mActivity);
		builder.setTitle("很遗憾， 木有中奖！");
		builder.setMessage("什么也没抽到...您可以再唱一首，上传之后可以再次得到一次抽奖机会哦");
		builder.setPositiveButton("好的", new OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
				updateKgeState(kid);
			}
		});
		builder.create().show();
	}
	
	private void toUploadAndShare() {
		
		//上传时，先判断作品时长是否大于60秒
		if(AudioLogic.getMediaLength(aacPath) < 60) {
			AlertDialog.Builder builder = new AlertDialog.Builder(mActivity);
			builder.setTitle("提示");
			builder.setMessage("作品不足60秒不能上传");
			builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					dialog.dismiss();
				}
			});
			builder.create();
			builder.show();
			return ;
		}
		if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
			Toast.makeText(mActivity, "没有网络，请稍后再试", 0).show();
			return;
		}
		uploadPd = new ProgressDialog(mActivity);
		uploadPd.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
		uploadPd.setCancelable(true);
		uploadPd.setCanceledOnTouchOutside(false);
		uploadPd.setMessage("正在上传中...");
		uploadPd.show();
		try {
       	 Class<?> clazz = ProgressDialog.class;
       	 TextView nullText = new TextView(mActivity);
       	 nullText.setText("");
       	 Field field = clazz.getDeclaredField("mProgressNumber");
       	 field.setAccessible(true);
			field.set(uploadPd, nullText);
		} catch (Exception e) {
			KuwoLog.printStackTrace(e);
		}
		//1.upload
		File zipFile = new File(zipPath);
		String uploadTitle = null;
		String rid = null;
		String artist = Config.getPersistence().user.uname;
		File aacFile = new File(aacPath);
		String aacFileName = aacFile.getName();
		String aacFileNameTmp1 = aacFileName;
		String aacFileNameTmp2 = aacFileName;
		String musicId = aacFileNameTmp1.substring(0, aacFileNameTmp1.indexOf('_'));
		String kgeTime = aacFileNameTmp2.substring(aacFileNameTmp2.indexOf('_')+1, aacFileNameTmp2.indexOf('.'));
		KgeDao kgeDao = new KgeDao(mActivity);
		uploadTitle = kgeDao.getKge(Long.parseLong(kgeTime)).title;
		if(TextUtils.isEmpty(uploadTitle)) {
			uploadTitle = "ziyouqingchang";
		}
		if("".equals(musicId)) {
			rid = "";
		}else {
			MusicDao musicDao = new MusicDao(mActivity);
			rid = musicDao.getMusic(musicId).getId();
		}
		
		if(zipFile.exists()) {
			//先上传zip，再上传aac
			uploadPd.setMax((int)(new File(zipPath).length() + new File(aacPath).length()));
			new ZipUploadAsyncTask().execute(uploadTitle, rid, artist, zipPath, aacPath);
		}else {
			//直接上传aac 
			uploadPd.setMax((int)new File(aacPath).length());
			new AACUploadAsyncTask().execute(uploadTitle, kid, rid, artist, aacPath, zipPath);
		}
	}
	
	private void showBindDialog(final String type, int tip) {
		DialogUtils.alert(mActivity, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					//ok
					dialog.dismiss();
					Intent loginIntent = new Intent(mActivity, ThirdPartyLoginActivity.class);
					loginIntent.putExtra("flag", "bind");
					loginIntent.putExtra("type", type);
					mActivity.startActivityForResult(loginIntent, Constants.SHARE_BOUND_REQUEST);
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

	public void setWeiboChecked() {
		cb_share_weibo.setChecked(true);
		cb_share_weibo.setBackgroundResource(R.drawable.sina_share);
	}

	public void setQQChecked() {
		cb_share_qq.setChecked(true);
		cb_share_qq.setBackgroundResource(R.drawable.qq_share);
	}

	public void setRenrenChecked() {
		cb_share_renren.setChecked(true);
		cb_share_renren.setBackgroundResource(R.drawable.renren_logo);
	}
}
