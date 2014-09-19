package cn.kuwo.sing.business;

import java.io.IOException;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.MTV;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.logic.MtvLogic;
import cn.kuwo.sing.ui.activities.LocalMainActivity;
import cn.kuwo.sing.ui.activities.PlayActivity;
import cn.kuwo.sing.ui.activities.PostProcessedActivity;
import cn.kuwo.sing.ui.activities.SingActivity;
//import cn.kuwo.sing.logic.DownloadLogic;

public class MTVBusiness extends BaseBusiness {
	private final String TAG = "MTVBusiness";
	
	public static final String ACTION_RECORD = "record";
	public static final String ACTION_REVIEW = "review";
	public static final String MODE_AUDIO = "audio";
	public static final String MODE_VEDIO = "vedio";
	
	private Context mContext;

	public MTVBusiness(Context context) {
		this.mContext = context;
	}
	
	/**
	 * 播放MTV
	 */
	public void playMtv(String kid){
		Intent intent = new Intent(mContext, PlayActivity.class);
		intent.putExtra("mFlag", "serverPlay");
		intent.putExtra("kid", kid);
		KuwoLog.i(TAG, "playMtv...");
		mContext.startActivity(intent);
	}
	
	public void loadMainPage(String url, String title) {
		Intent intent = new Intent(mContext, LocalMainActivity.class);
		intent.putExtra("flag", "loadMain");
		intent.putExtra("uname", title);
		intent.putExtra("url", url);
		mContext.startActivity(intent);
	}
	
	public List<Bitmap> getMtvPictures(MTV mtv) throws IOException {
		MtvLogic mtvLogic = new MtvLogic();
		List<Bitmap> lists = null;
		String kid = mtv.kid;
		lists = mtvLogic.getMtvPictures(kid);
		if (lists == null ) {
			mtvLogic.loadMtvPictures(mtv);
			lists = mtvLogic.getMtvPictures(kid);
		}
		return lists;
	}
	
	/**
	 * 后期处理
	 * @param music
	 * @param mode
	 */
	public void processMtv(Music music, String mode, String score, String ranking, String fromSquareActivity) {
		Intent intent = new Intent(mContext, PostProcessedActivity.class);
		intent.putExtra("music", music);
		intent.putExtra("mode", mode);
		intent.putExtra("score", score);
		intent.putExtra("ranking", ranking);
		intent.putExtra("fromSquareActivity", fromSquareActivity);
		mContext.startActivity(intent);
	}
	
	/*public void activeMtv(String strMuisc) {
		MusicLogic lMusic = new MusicLogic();
		Music music = lMusic.parse(strMuisc);
		Music local = lDownload.getMusic(music.getId());
		if (lDownload.hasDownload(local))
			singMtv(music, MODE_AUDIO);
		else if(lDownload.isDownloading(music.getId()))
			cancelDownloadMtv(music);
		else if(lDownload.isUncomplete(music))
			breakpointDownloadMtv(music.getId());
		else
			downloadMTV(music);
	}*/

	/*public void cancelDownloadMtv(Music music) {
		lDownload.cancelDownloadAccompaniment(music);
	}*/

	/**
	 * 下载MTV
	 */
//	public void downloadMtv(String strMusic) {
//		MusicLogic lMusic = new MusicLogic();
//		Music music = lMusic.parse(strMusic);
//		downloadMTV(music);
//	}
	public void downloadMTV(Music music) {
		KuwoLog.i(TAG, "download MTV rid:" + music.getId());
//		lDownload.downloadAccompaniment(music);
	}


	/**
	 * 获取本地已点歌曲状态字符串 用于与Web通信
	 */
	/*public String getMusicState(){
		List<Music> musics = lDownload.getMusics();
		StringBuilder sb = new StringBuilder();
		for (Music music : musics) {
			if (music.getTotal() == 0)
				continue;
			
			sb.append(music.getId());
			sb.append("&&");
			
			if (music.getProgress() == music.getTotal())
				sb.append("finish");
			else
				sb.append("pause");
			sb.append("&&");
			
			sb.append((music.getProgress()*100) / music.getTotal());
			sb.append("||");
		}
		
		return sb.toString();
	}*/
	
	/**
	 * 断点续传MTV
	 * 
	 * @param rid
	 *            歌曲rid
	 * @param sig
	 *            第一次下载时服务器返回的sig
	 */
	public void breakpointDownloadMtv(String rid) {
		// TODO @LIKANG
		// 获取相同资源的下载URL
		
		//获取URL地址成功

		// 定位需要续传的本地文件

		// 从上次中断的位置继续下载
		
		//获取失败, 提示用户
	}
	
	/**
	 * 演唱MTV
	 */
	public void singMtv(Music music, String model, String fromSquareActivity) {
		Intent intent = new Intent(mContext, SingActivity.class);
		intent.putExtra("music", music);
		intent.putExtra("mode", model);
		intent.putExtra("fromSquareActivity", fromSquareActivity);
		intent.putExtra("action", ACTION_RECORD);
		mContext.startActivity(intent);
	}

	/**
	 * 回放MTV
	 */
	public void reviewMtv(Music music, String mode, String fromSquareActivity) {
		Intent intent = new Intent(mContext, SingActivity.class);
		intent.putExtra("music", music);
		intent.putExtra("mode", mode);
		intent.putExtra("action", ACTION_REVIEW);
		intent.putExtra("fromSquareActivity", fromSquareActivity);
		mContext.startActivity(intent);
	}
}
