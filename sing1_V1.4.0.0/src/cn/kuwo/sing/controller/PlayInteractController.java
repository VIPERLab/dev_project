package cn.kuwo.sing.controller;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Field;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationSet;
import android.view.animation.AnimationUtils;
import android.view.animation.ScaleAnimation;
import android.view.animation.TranslateAnimation;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.download.DownloadManager;
import cn.kuwo.framework.download.DownloadStat;
import cn.kuwo.framework.download.DownloadTask;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.bean.MTV;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.business.MusicBusiness;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.db.KgeDao;
import cn.kuwo.sing.logic.DownloadLogic;
import cn.kuwo.sing.logic.MtvLogic;
import cn.kuwo.sing.logic.MusicLogic;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.logic.service.MusicService;
import cn.kuwo.sing.logic.service.UserService;
import cn.kuwo.sing.ui.activities.CommentActivity;
import cn.kuwo.sing.ui.activities.LoginActivity;
import cn.kuwo.sing.ui.activities.PlayActivity;
import cn.kuwo.sing.ui.activities.ShareActivity;
import cn.kuwo.sing.ui.activities.SingActivity;
import cn.kuwo.sing.ui.activities.ThirdPartyLoginActivity;
import cn.kuwo.sing.util.BitmapTools;
import cn.kuwo.sing.util.DensityUtils;
import cn.kuwo.sing.util.DialogUtils;
import cn.kuwo.sing.util.ImageUtils;
import cn.kuwo.sing.util.lyric.Lyric;

import com.tencent.mm.sdk.openapi.GetMessageFromWX;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.SendMessageToWX;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.tencent.mm.sdk.openapi.WXMediaMessage;
import com.tencent.mm.sdk.openapi.WXMusicObject;
import com.tencent.mm.sdk.openapi.WXTextObject;
import com.tencent.mm.sdk.openapi.WXVideoObject;
import com.tencent.mm.sdk.openapi.WXWebpageObject;

public class PlayInteractController {
	private final String TAG = "PlayInteractController";
	private PlayActivity mActivity;
	private MTV mMTV;
	/** ----------互动区域-------------- */
	/* 是否已经关注 */
	private boolean attentioned = true;
	/* 关注按钮 */
	private ImageView attentionBT;
	private TextView attentionTV;
	/* 送花按钮 */
	private ImageView flowerBT;
	private TextView flowerTV;
	/* 评论按钮 */
	private ImageView discussBT;
	private TextView discussTV;
	/* 我要唱按钮 */
	private ImageView wantSingBT;
	/* 分享按钮 */
	private ImageView shareBT;
	private ImageView sendflower_imageview;
	private ImageView pay_attention_imageview;
	private RelativeLayout rl_share_select_dialog;
	private final int DIALOG_BOTTOM_IN = 0, DIALOG_BOTTOM_OUT = 1;
	private Music mMusic;
	private ProgressDialog pd;
	public static int flowerNum = 20;
	public boolean shareDialogShowing;
	public boolean weixinShareDialogShowing;
	private DownloadLogic downloadLogic;
	private boolean downloadFinished = false; 
	private String mFlag;
	private Kge mLocalKge;
	private RelativeLayout inclickBg;
	private IWXAPI mWXApi;
	private RelativeLayout rl_weixin_share_dialog;
	private Bitmap mHeadBitmap;
	private String mKid;
	private boolean posted = false; //发布上传
	private Button btUpload;
	
	public PlayInteractController(PlayActivity activity, String flag, IWXAPI wxApi) {
		KuwoLog.i(TAG, "PlayInteractController");
		mActivity = activity;
		mFlag = flag;
		mWXApi = wxApi;
		if(mFlag.equals("localPlay")) {
			mLocalKge = (Kge) mActivity.getIntent().getSerializableExtra("kge");
		}
		if(Config.getPersistence().musicCancelMap == null) {
			Config.getPersistence().musicCancelMap = new HashMap<String, Boolean>();
		}
		initView();
	}
	
	public void setHeadBitmap(Bitmap bitmap) {
		mHeadBitmap = bitmap;
	}
	
	public void setKid(String kid) {
		mKid = kid;
	}
	
	public void setMTV(MTV mtv) {
		mMTV = mtv;
	}
	
	public void setUploadButtonDark() {
		if(mFlag.equals("localPlay")) {
			if(btUpload == null)
				btUpload = (Button) mActivity.findViewById(R.id.btUpload);
			btUpload.setBackgroundResource(R.drawable.bt_upload_dark);
			btUpload.setClickable(false);
			btUpload.setEnabled(false);
		}
			
	}

	private void initView() {
		LinearLayout play_menu_rl = (LinearLayout) mActivity.findViewById(R.id.play_menu_rl);
		LinearLayout llPlayMenuSecond = (LinearLayout) mActivity.findViewById(R.id.llPlayMenuSecond);
		if(mFlag.equals("localPlay")) {//local
			play_menu_rl.setVisibility(View.GONE);
			mActivity.findViewById(R.id.sendflower_imageview).setVisibility(View.GONE);
			mActivity.findViewById(R.id.pay_attention_imageview).setVisibility(View.GONE);
			llPlayMenuSecond.setVisibility(View.VISIBLE);
			btUpload = (Button) mActivity.findViewById(R.id.btUpload);
			if(mLocalKge.hasUpload)
				setUploadButtonDark();
			btUpload.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
						if(Config.getPersistence().isLogin) {
							String kgeId = TextUtils.isEmpty(mLocalKge.id) ? "" : mLocalKge.id;
							String aacFileName = kgeId + "_" + mLocalKge.date + ".aac";
							String zipPath = null;
							if(mLocalKge.squareActivityName != null)
								zipPath = DirectoryManager.getFilePath(DirContext.SDCARD_HIDDEN, "my_picture"+mLocalKge.squareActivityName+".zip");
							else
								zipPath = DirectoryManager.getFilePath(DirContext.SDCARD_HIDDEN, "my_picturelastPictures.zip");
							String aacPath = DirectoryManager.getFilePath(DirContext.RECORD, aacFileName);
							Intent intent = new Intent(mActivity, ShareActivity.class);
							intent.putExtra("mFlag", "uploadMySong");
							intent.putExtra("needSaveSong", false);
							intent.putExtra("uploadKgeId", kgeId);
							if(!TextUtils.isEmpty(kgeId)) {
								intent.putExtra("musicName", mLocalKge.title);
							}
							intent.putExtra("kgeDate", mLocalKge.date);
							intent.putExtra("zipPath", zipPath);
							intent.putExtra("aacPath", aacPath);
							intent.putExtra("uid", Config.getPersistence().user.uid);
							mActivity.startActivityForResult(intent, Constants.REQUEST_UPLOAD);
						}else {
							showLoginDialog(R.string.login_dialog_tip);
						}
					}else {
						Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
					}
				}
			});
			Button btDelete = (Button) mActivity.findViewById(R.id.btDelete);
			btDelete.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					//删除
					showDeleteDialog(mLocalKge);
				}
			});
			/**-----------控制区域-------*/
			
		}else {//server
			llPlayMenuSecond.setVisibility(View.GONE);
			play_menu_rl.setVisibility(View.VISIBLE);
			/** ----------控制区域-------------------------------------------- */
			// 关注按钮
			attentionBT = (ImageView) mActivity.findViewById(R.id.bt_play_attention);
			attentionBT.setOnClickListener(mOnClickListener);
			attentionTV = (TextView) mActivity.findViewById(R.id.tv_play_attention_count);
			sendflower_imageview = (ImageView) mActivity.findViewById(R.id.sendflower_imageview);
			sendflower_imageview.setVisibility(View.INVISIBLE);
			pay_attention_imageview = (ImageView) mActivity.findViewById(R.id.pay_attention_imageview);
			pay_attention_imageview.setVisibility(View.INVISIBLE);
			// 送花按钮
			flowerBT = (ImageView) mActivity.findViewById(R.id.bt_play_send_flower);
			flowerBT.setOnClickListener(mOnClickListener);
			flowerTV = (TextView) mActivity.findViewById(R.id.tv_play_flower_count);
			// 我要唱按钮
			wantSingBT = (ImageView) mActivity.findViewById(R.id.bt_play_i_want);
			wantSingBT.setOnClickListener(mOnClickListener);
			// 评论按钮
			discussBT = (ImageView) mActivity.findViewById(R.id.bt_play_discuss);
			discussBT.setOnClickListener(mOnClickListener);
			discussTV = (TextView) mActivity.findViewById(R.id.tv_play_discuss_count);
			// 分享按钮
			rl_share_select_dialog = (RelativeLayout) mActivity.findViewById(R.id.rl_share_select_dialog);
			shareBT = (ImageView) mActivity.findViewById(R.id.bt_play_share);
			shareBT.setOnClickListener(mOnClickListener);
			inclickBg = (RelativeLayout) mActivity.findViewById(R.id.play_inclick_bg);
			
			rl_weixin_share_dialog = (RelativeLayout) mActivity.findViewById(R.id.rl_weixin_share_dialog);
		}
		
	}
	
	private void showDeleteDialog(final Kge kge) {
		AlertDialog.Builder builder = new AlertDialog.Builder(mActivity);
		builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				String prefix = kge.id==null ? "" : kge.id;
				String kgeFileName = prefix+"_"+kge.date+".aac";
				File kgeFile = DirectoryManager.getFile(DirContext.RECORD, kgeFileName);
				if(kgeFile.exists()) {
					kgeFile.delete();
				}
				KgeDao kgeDao = new KgeDao(mActivity);
				kgeDao.delete(kge.date);
				//退出播放，并通知已录列表重新load
				mActivity.setResult(Constants.RESULT_RELOAD_RECORDED_KGE);
				mActivity.finish();
			}
		});
		builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});
		builder.setMessage("您确定要删除么？");
		AlertDialog dialog = builder.create();
		dialog.show();
	}
	
	public void setAttentionText(String attention) {
		attentionTV.setText(attention);
	}
	
	public void setFlowerText(String flowerCount) {
		flowerTV.setText(flowerCount);
	}
	
	public void setCommentText(String commentCount) {
		discussTV.setText(commentCount);
	}
	
	public void addCommentCount() {
		try {
			int count = Integer.parseInt(discussTV.getText().toString());
			count ++;
			discussTV.setText(count+"");
		} catch (NumberFormatException e) {
		}
	}
	
	private Handler addAttentionHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch(msg.what) {
			case 0:
				KuwoLog.i(TAG, "【添加关注成功！】");
				int payFlag = msg.arg1;
				if(payFlag == UserService.NO_LOGIN){
					//未登录或者其他原因，获取失败了
					Toast.makeText(mActivity, "关注失败,没有登录", Toast.LENGTH_SHORT).show();
				}
				else{
					//获取成功，今日剩余可送花数量flag1
					attentionTV.setText(String.valueOf(Integer.parseInt(mMTV.care) + 1));
					setAttentionState();
					Toast.makeText(mActivity, "关注成功", Toast.LENGTH_SHORT).show();
				}
				break;
			default:
				break;
			}
		}
		
	};
	
	private Handler sendFlowerHanlder = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch(msg.what) {
			case 0:
				KuwoLog.i(TAG, "【送鲜花成功！】");
				int result = msg.arg1;
				switch (result) {
				case UserService.NO_LOGIN:
//					Toast.makeText(mActivity, "没有登录", 0).show();
					showLoginDialog(R.string.login_dialog_tip);
					break;
				case UserService.UPPERLIMIT:
					Toast.makeText(mActivity, "每人每天只可以送20朵花", 0).show();
					break;
				case UserService.KGE_DEL_OR_SHENHE:
					Toast.makeText(mActivity, "k歌审核", 0).show();
					break;
				case UserService.NOT_EXIST:
					Toast.makeText(mActivity, "当前作品不存在", 0).show();
					break;

				default:
					setFlowerText(Integer.parseInt(flowerTV.getText().toString())+1+"");
					flowerNum--;
					break;
				}
				break;
			default:
				break;
			}
		}
	};
	
	private Handler lyricHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				Lyric lyric = (Lyric) msg.obj;
				if(lyric != null) {
					KuwoLog.i(TAG, "lyric="+lyric+",下载成功！");
				}
				break;

			default:
				break;
			}
		}
		
	};
	
	private Handler downloadMusicHandler = new Handler() {
		
		@Override
		public void handleMessage(Message msg) {
			switch(msg.what) {
			case 0:
				KuwoLog.i(TAG, "【获取音乐伴奏防盗链地址成功！】");
				String[] result = (String[])msg.obj;
				KuwoLog.i(TAG, "result[0]="+result[0]);
				KuwoLog.i(TAG, "result[1]="+result[1]);
				downloadLogic = new DownloadLogic(false, mActivity);
				new Thread(new Runnable() {
					
					@Override
					public void run() {
						MusicBusiness mb = new MusicBusiness();
						try {
							Lyric lyric = mb.getLyric(mMusic.getId(), Lyric.LYRIC_TYPE_KDTX); //
							KuwoLog.i(TAG, "lyric="+lyric);
							Message msg = lyricHandler.obtainMessage();
							msg.what = 0;
							msg.obj = lyric;
							lyricHandler.sendMessage(msg);
						} catch (Exception e) {
							e.printStackTrace();
						}
					}
				}).start();
				if(mMusic != null) {
					downloadLogic.downloadShakelightAndAccompaniment(mActivity, mMusic, result[0], result[1], Config.getPersistence().musicCancelMap.get(mMusic.getId()));
				}
				downloadLogic.setOnDownloadListener(new DownloadManager.OnDownloadListener() {
					
					@Override
					public void onProcess(DownloadManager dm, DownloadTask task,
							DownloadStat ds) {
						String taskId = task.getId();
						String musicId = taskId.substring(0, taskId.indexOf('_'));
						int progress = downloadLogic.computeProgress(musicId);
  						KuwoLog.i(TAG, "download accomp and music progress:"+progress);
						downloadLogic.publishProgress(progressUpdateHandler, musicId, progress);
					}
				});
				
				break;
			default:
				break;
			}
		}
		
	};
	
	public void showApnTipDialog(String tip) {
		DialogUtils.alert(mActivity, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					//ok
					downloadMusic();
					dialog.dismiss();
					break;
				case -2:
					//cancel
					dialog.dismiss();
					break;
				default:
					break;
				}
				
			}
		} , R.string.logout_dialog_title, R.string.dialog_ok, -1, R.string.dialog_cancel, tip);
	}
	
	
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
				Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
			}else {
				int id = v.getId();
				if(mMTV == null){
					return;
				}else{
					switch (id) {					
					case R.id.bt_play_attention:
						// 关注按钮
							if(mFlag.equals("localPlay")) {
								Toast.makeText(mActivity, "不可以关注自己哦", Toast.LENGTH_SHORT).show();
								break;
							}
							if(!Config.getPersistence().isLogin) {
								showLoginDialog(R.string.login_dialog_tip);
							}else if (Config.getPersistence().user.uid.equals(mMTV.uid)) {
								Toast.makeText(mActivity, "不可以关注自己哦", Toast.LENGTH_SHORT).show();
							}else {
								//关注动画
								attentionAnimation();
								new Thread(new Runnable() {
									
									@Override
									public void run() {
										Date currentTime = new Date();
										SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
										KuwoLog.i(TAG, "[6.添加关注线程]:"+Thread.currentThread().getName()+","+formatter.format(currentTime));
										UserLogic payLogic = new UserLogic();
										int payFlag = 0;
										try {
											payFlag = payLogic.payAction(mMTV.uid);
										} catch (IOException e) {
											KuwoLog.printStackTrace(e);
										}
										Message msg = addAttentionHandler.obtainMessage();
										msg.what = 0;
										msg.arg1 = payFlag;
										addAttentionHandler.sendMessage(msg);
									}
									
								}).start();
							}
						break;
					case R.id.bt_play_send_flower:
						// 送花按钮
							if(mFlag.equals("localPlay")) {
								Toast.makeText(mActivity, "把花送给其他人吧", Toast.LENGTH_SHORT).show();
								break;
							}
							if(!Config.getPersistence().isLogin) {
								showLoginDialog(R.string.login_dialog_tip);
							}else if (Config.getPersistence().user.uid.equals(mMTV.uid)) {
								Toast.makeText(mActivity, "把花送给其他人吧", Toast.LENGTH_SHORT).show();
							}else{
								//送花动画
								sendFlowerAnimation();
								new Thread(new Runnable(){
									
									@Override
									public void run() {
										int result = -1;
										UserLogic userLogic = new UserLogic();
										if(Config.getPersistence().isLogin){
											try {
												result = userLogic.avalidFlowers(mMTV.kid); //送花
											} catch (IOException e) {
												KuwoLog.printStackTrace(e);
											}
										}
										Message msg = sendFlowerHanlder.obtainMessage();
										msg.what = 0;
										msg.arg1 = result;
										sendFlowerHanlder.sendMessage(msg);
									}
									
								}).start();
							}
						break;
					case R.id.bt_play_i_want:
						// 我要唱按钮
						MusicLogic musiclogic = new MusicLogic();
						if(mMTV == null) {
							Toast.makeText(mActivity, "作品未加载完全", 0).show();
							return;
						}
						if(!TextUtils.isEmpty(mMTV.rid)) {
							KuwoLog.i(TAG, "检查原唱和伴奏");
							File originalFile = musiclogic.getOriginalFile(mMTV.rid);
							File accomFile = musiclogic.getAccompanyFile(mMTV.rid);
							MtvLogic mtvLogic = new MtvLogic();
							mMusic = mtvLogic.convertMusic(mMTV);
							if(originalFile == null || accomFile == null){
								if(AppContext.getNetworkSensor().isApnActive() && !Constants.isSquareOrderMobileStateActivited){
//									showApnTipDialog("您当前使用的是2G/3G网络，将产生一定的流量");
									Toast.makeText(mActivity, "您当前使用的是2G/3G网络，点歌将产生一定的流量", 0).show();
									Constants.isSquareOrderMobileStateActivited = true;
								}
								downloadMusic();
							}else {
								MTVBusiness business = new MTVBusiness(mActivity);
								business.singMtv(mMusic, MTVBusiness.MODE_AUDIO, null);
							}
						}else {
							Intent freeIntent = new Intent(mActivity, SingActivity.class);
							freeIntent.putExtra("mode", MTVBusiness.MODE_AUDIO);
							freeIntent.putExtra("action", MTVBusiness.ACTION_RECORD);
							mActivity.startActivity(freeIntent);
						}
						
						break;
					case R.id.bt_play_discuss:
						// 评论按钮
						if(mFlag.equals("localPlay")) {
							Toast.makeText(mActivity, "本地作品播放，没有评论", Toast.LENGTH_SHORT).show();
							break;
						}
						if(mMTV != null) {
							Intent commentIntent = new Intent(mActivity, CommentActivity.class);
							commentIntent.putExtra("kid", mMTV.kid);
							commentIntent.putExtra("sid", mMTV.sid);
							KuwoLog.i(TAG, "kid="+mMTV.kid);
							KuwoLog.i(TAG, "sid="+mMTV.sid);
							mActivity.startActivity(commentIntent);
						}
						break;
					case R.id.bt_play_share:
						// 分享按钮
						if(!Config.getPersistence().isLogin) {
							showLoginDialog(R.string.login_dialog_tip);
						}else {
							if(mLocalKge != null) {
								if(!mLocalKge.hasUpload) {
									Toast.makeText(mActivity, "该作品还没有上传哦", Toast.LENGTH_SHORT).show();
									break;
								}
							}
							showShareSelectDialog(); //弹出分享选择PopWindow
						}
						
						break;
					default:
						break;
					}
				}
			}
			
		}
	};
	
	private void attentionAnimation() {
		ScaleAnimation sa = new ScaleAnimation(0.0f, 1.0f, 0.0f, 1.0f, 
				Animation.RELATIVE_TO_SELF, 0.5f,
				Animation.RELATIVE_TO_SELF, 0.5f);  
		sa.setDuration(2000);  
		sa.setFillAfter(true);
		pay_attention_imageview.setVisibility(View.VISIBLE);
		pay_attention_imageview.setAnimation(sa);
		sa.setAnimationListener(new AnimationListener(){ 
			public void onAnimationStart(Animation animation) { 
			} 
			
			public void onAnimationEnd(Animation animation) { 
				Animation alphaAnimation = new AlphaAnimation(1.0f,0.0f );  
				alphaAnimation.setDuration(3000); 
				pay_attention_imageview.setAnimation(alphaAnimation);
				alphaAnimation.startNow();
				alphaAnimation.setAnimationListener(new AnimationListener() {
					
					@Override
					public void onAnimationStart(Animation animation) {
						
					}
					
					@Override
					public void onAnimationRepeat(Animation animation) {
						
					}
					
					@Override
					public void onAnimationEnd(Animation animation) {
						pay_attention_imageview.setVisibility(View.INVISIBLE);
					}
				});
			} 
			
			public void onAnimationRepeat(Animation animation) { 
				
			} 
			
		}); 
		sa.startNow();
	}
	
	private void sendFlowerAnimation() {
		AnimationSet as = new AnimationSet(true);
		float fromXDelta = (flowerBT.getRight()+flowerBT.getLeft())/2 - (AppContext.SCREEN_WIDTH/2);
		float fromYDelta = (flowerBT.getBottom()+flowerBT.getTop())/2 - DensityUtils.dip2px(mActivity, 320)/2;
		TranslateAnimation ta = new TranslateAnimation(fromXDelta, 0, fromYDelta, 0);
		ta.setDuration (2000);   
		ta.setFillAfter(true);
		as.addAnimation(ta);
		ScaleAnimation sa = new ScaleAnimation(0.0f, 1.0f, 0.0f, 1.0f, 
				Animation.RELATIVE_TO_SELF, 0.5f,
				Animation.RELATIVE_TO_SELF, 0.5f);  
		sa.setDuration(2000);  
		sa.setFillAfter(true);
		as.addAnimation(sa);
		sendflower_imageview.setVisibility(View.VISIBLE);
		sendflower_imageview.setAnimation(as);
		as.setAnimationListener(new AnimationListener(){ 
			public void onAnimationStart(Animation animation) { 
			}
			public void onAnimationEnd(Animation animation) { 
				Animation alphaAnimation = new AlphaAnimation(1.0f,0.0f );  
				alphaAnimation.setDuration(3000); 
				sendflower_imageview.setAnimation(alphaAnimation);
				alphaAnimation.startNow();
				alphaAnimation.setAnimationListener(new AnimationListener(){

					@Override
					public void onAnimationStart(
							Animation animation) {
						
					}

					@Override
					public void onAnimationEnd(
							Animation animation) {
						sendflower_imageview.setVisibility(View.INVISIBLE);
					}

					@Override
					public void onAnimationRepeat(
							Animation animation) {
						
					} 
					
				});
			} 
			
			public void onAnimationRepeat(Animation animation) { 
				
			} 
			
		}); 
		as.startNow();
	}
	
	private void downloadMusic() {
		downloadFinished = false;
		Config.getPersistence().musicCancelMap.put(mMusic.getId(), false);
		Config.savePersistence();
		pd = new ProgressDialog(mActivity);
		pd.setMessage("正在缓冲伴唱数据...");
		pd.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
		pd.setButton(DialogInterface.BUTTON_POSITIVE, "演唱", new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				MTVBusiness business = new MTVBusiness(mActivity);
				business.singMtv(mMusic, MTVBusiness.MODE_AUDIO, null);
				dialog.dismiss();
			}
		});
		pd.setButton(DialogInterface.BUTTON_NEGATIVE, "取消", new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				if(downloadFinished) {
					dialog.dismiss();
				}else {
					Config.getPersistence().musicCancelMap.put(mMusic.getId(), true);
					Config.savePersistence();
					if(downloadLogic != null) {
						downloadLogic.cancelDownloadMusic(mActivity, mMusic.getId());
					}
					dialog.dismiss();
				}
			}
		});
		pd.setCancelable(false);
		pd.setCanceledOnTouchOutside(false);
		pd.show();
		try {
	       	 Class<?> clazz = ProgressDialog.class;
	       	 TextView nullText = new TextView(mActivity);
	       	 nullText.setText("");
	       	 Field field = clazz.getDeclaredField("mProgressNumber");
	       	 field.setAccessible(true);
				field.set(pd, nullText);
			} catch (Exception e) {
				KuwoLog.printStackTrace(e);
			}
		pd.getButton(DialogInterface.BUTTON_POSITIVE).setEnabled(false);//禁用“演唱”按钮
		
		//下载伴奏文件
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				Date currentTime = new Date();
				SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				KuwoLog.i(TAG, "[8.下载音乐伴奏线程]:"+Thread.currentThread().getName()+","+formatter.format(currentTime));
				String[] result = new String[2];
				MusicLogic logic = new MusicLogic();
				KuwoLog.i(TAG, "music id="+mMusic.getId());
				result[0] = logic.getMusicUrl(mMusic.getId());
				result[1] = logic.getAccompanimentUrl(mMusic.getId());
				KuwoLog.i(TAG, "result0="+result[0]);
				KuwoLog.i(TAG, "result1="+result[1]);
				Message msg = downloadMusicHandler.obtainMessage();
				msg.what = 0;
				msg.obj = result;
				downloadMusicHandler.sendMessage(msg);
			}
			
		}).start();
	}
	
	private void toShareMTV(String shareType) {
		Intent shareIntent = new Intent(mActivity, ShareActivity.class);
		shareIntent.putExtra("mFlag", "shareMTV");
		shareIntent.putExtra("shareType", shareType);
		shareIntent.putExtra("uid", mMTV.uid);
		shareIntent.putExtra("kid", mMTV.kid);
		shareIntent.putExtra("uname", mMTV.uname);
		shareIntent.putExtra("title", mMTV.title);
		mActivity.startActivity(shareIntent);
		dimissShareSelectDialog();
	}
	
	/**
	 * 设置动画
	 * 
	 * @param view
	 *            待设置的View
	 * @param type
	 *            动画类型
	 */
	private void setAnimation(View view, int type) {

		Animation inAnim = null;

		switch (type) {
		case DIALOG_BOTTOM_IN:
			inAnim = AnimationUtils.loadAnimation(mActivity,
					R.anim.sing_img_dialog_bottom_in);
			break;
		case DIALOG_BOTTOM_OUT:
			inAnim = AnimationUtils.loadAnimation(mActivity,
					R.anim.sing_img_dialog_bottom_out);
			break;
		}
		if (inAnim != null)
			view.startAnimation(inAnim);
	}
	
	/**
	 * 弹出模式选择对话框
	 */
	private void showShareSelectDialog() {
		inclickBg.setVisibility(View.VISIBLE);
		shareDialogShowing = true;
		rl_share_select_dialog.setVisibility(View.VISIBLE);
		rl_share_select_dialog.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if(event.getAction() == MotionEvent.ACTION_DOWN) {
					return true;
				}
				return false;
			}
		});
		ImageView weiboShareIV = (ImageView) mActivity.findViewById(R.id.iv_weibo_share);
		weiboShareIV.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if(Config.getPersistence().user.isBindWeibo) {
					toShareMTV("weibo");
				}else{
					showBindDialog("weibo", R.string.bind_sina_dialog_content);
				}
			}
		});
		ImageView qqShareIV = (ImageView)mActivity.findViewById(R.id.iv_qq_share);
		qqShareIV.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if(Config.getPersistence().user.isBindQQ) {
					toShareMTV("qq");
				}else {
					showBindDialog("qq", R.string.bind_qq_dialog_content);
				}
			}
		});
		
		ImageView weixinShareIV = (ImageView)mActivity.findViewById(R.id.iv_weixin_share);
		weixinShareIV.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if(mWXApi.isWXAppInstalled()) { //微信是否安装
					dimissShareSelectDialog();
					showWeixinShareDialog();
				}else { //启动微信失败
					Toast.makeText(mActivity, "微信未安装,请先安装微信", 0).show();
				}
			}
		});
		
		ImageView iv_renren_share = (ImageView) mActivity.findViewById(R.id.iv_renren_share);
		iv_renren_share.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if(Config.getPersistence().user.isBindRenren) {
					toShareMTV("renren");
				}else {
					showBindDialog("renren", R.string.bind_renren_dialog_content);
				}
			}
		});
		
		Button cancleBT = (Button) mActivity.findViewById(R.id.share_cancle_btn);
		cancleBT.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				dimissShareSelectDialog();
			}
		});
		setAnimation(rl_share_select_dialog, DIALOG_BOTTOM_IN);
	}
	
	/**
	 * 收回模式选择对话框
	 */
	public void dimissShareSelectDialog() {
		inclickBg.setVisibility(View.GONE);
		shareDialogShowing = false;
		rl_share_select_dialog.setVisibility(View.INVISIBLE);
		setAnimation(rl_share_select_dialog, DIALOG_BOTTOM_OUT);
	}
	
	private Handler mMtvPlayUrlHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				String url = (String) msg.obj;
				int circle = msg.arg1;
				if(circle == 1) {
					if(sendMsgToWX(mActivity, mHeadBitmap, mMTV.title, "刚刚在酷我K歌中听到一首《"+mMTV.title+"》,好好听哦!", url, true)) {
						dismissWeixinShareDialog();
					}
				}else {
					if(sendMsgToWX(mActivity, mHeadBitmap, mMTV.title, "刚刚在酷我K歌中听到一首《"+mMTV.title+"》,好好听哦!", url, false)) {
						dismissWeixinShareDialog();
					}
				}
				break;

			default:
				break;
			}
		}
		
	};
	
	/**
	 * 
	 * @param circle 1:circle 0: 非circle
	 */
	private void getMtvPlayUrl(final int circle) {
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				MusicService service = new MusicService();
				if(!TextUtils.isEmpty(mKid)) {
					String url = service.getMtvPlayUrl(mKid);
					Message msg = mMtvPlayUrlHandler.obtainMessage();
					msg.what = 0;
					msg.obj = url;
					msg.arg1 = circle;
					mMtvPlayUrlHandler.sendMessage(msg);
				}
			}
		}).start();
	}
	
	private void showWeixinShareDialog() {
		inclickBg.setVisibility(View.VISIBLE); 
		weixinShareDialogShowing = true;
		rl_weixin_share_dialog.setVisibility(View.VISIBLE);
		Button btWeixinShareToFriend = (Button) mActivity.findViewById(R.id.btWeixinShareToFriend);
		btWeixinShareToFriend.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
//				mWXApi.openWXApp(); //打开微信
				if(mHeadBitmap != null) {
					getMtvPlayUrl(0);
				}else {
					Toast.makeText(mActivity, "歌手头像获取失败", 0).show();
				}
			}
		});
		Button btWeixinShareToCircle = (Button) mActivity.findViewById(R.id.btWeixinShareToCircle);
		btWeixinShareToCircle.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				int value = mWXApi.getWXAppSupportAPI();
				if(value >= 21020001) {
					//支持朋友圈
					if(mHeadBitmap != null) {
						getMtvPlayUrl(1);
					}else {
						Toast.makeText(mActivity, "歌手头像获取失败", 0).show();
					}
				}else {
					//不支持朋友圈
					Toast.makeText(mActivity, "您的微信版本不支持朋友圈分享", 0).show();
				}
			}
		});
		Button btWeixinShareCancle = (Button) mActivity.findViewById(R.id.btWeixinShareCancle);
		btWeixinShareCancle.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				dismissWeixinShareDialog();
			}
		});
		
		
		setAnimation(rl_weixin_share_dialog, DIALOG_BOTTOM_IN);
	}
	
	 /**
     * 
     * @param context ,上下文
     * @param bitmap    要分享的图片（32K以内）
     * @param title 分享的标题
     * @param content   内容
     * @param loadurl   链接
     * @param circle 分享好友还是分享到朋友圈
     * @return
     */
    public boolean sendMsgToWX(Context context, Bitmap bitmap, String title, String content, String loadurl, boolean circle) {
        boolean result = false;
		WXMusicObject musicObj = new WXMusicObject();
		musicObj.musicUrl = "http://player.kuwo.cn/webmusic/kgefs?kid="+mKid;
		musicObj.musicDataUrl = loadurl;
        WXMediaMessage msg = new WXMediaMessage(musicObj);
        msg.title = title;
        msg.description = content;
        if (bitmap != null) {
            bitmap = ImageUtils.comp(bitmap);
            msg.thumbData = ImageUtils.bmpToByteArray(bitmap, false);
            bitmap.recycle();
        }
        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.transaction = String.valueOf(System.currentTimeMillis());
        req.message = msg;
        if (circle) {
            //发送到朋友圈
            req.scene = SendMessageToWX.Req.WXSceneTimeline;
        } else {
            //发送到回话中。。
            req.scene = SendMessageToWX.Req.WXSceneSession;
        }
        result = mWXApi.sendReq(req);
        return result;
    }

	private void dismissWeixinShareDialog() {
		inclickBg.setVisibility(View.GONE);
		weixinShareDialogShowing = false;
		rl_weixin_share_dialog.setVisibility(View.GONE);
		setAnimation(rl_weixin_share_dialog, DIALOG_BOTTOM_OUT);
		
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
	
	private Handler progressUpdateHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case Constants.MESSAGE_DOWNLOAD_PROGRESS: 
				int progress = msg.getData().getInt("progress");
				if(progress == 100) {
					KuwoLog.i(TAG, "下载完成！");
					Toast.makeText(mActivity, "下载完成！", Toast.LENGTH_SHORT).show();
					pd.getButton(DialogInterface.BUTTON_POSITIVE).setEnabled(true);
					downloadFinished = true;
					pd.setProgress(100);
					return;
				}
				pd.setProgress(progress);
				break;
			default:
				break;
			}
		}
		
	};
	
	public void setAttentionState() {
//		attentionBT.setCompoundDrawablesWithIntrinsicBounds(0,R.drawable.bt_has_attention_normal, 0, 0);
		attentionBT.setImageResource(R.drawable.bt_has_attention_dark);
		attentionBT.setClickable(false);
	}
	
	public void setNOAttentionState() {
//		attentionBT.setCompoundDrawablesWithIntrinsicBounds(0, R.drawable.played_not_attention_btn_selector, 0, 0);
		attentionBT.setClickable(true);
	}
}