/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import java.io.IOException;
import java.net.URISyntaxException;

import android.R.integer;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Message;
import android.widget.TextView;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.IOUtils;
import cn.kuwo.sing.R;
import cn.kuwo.sing.business.MusicBusiness;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.AudioLogic;
import cn.kuwo.sing.logic.LyricLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.compatibility.LrcView;
import cn.kuwo.sing.ui.compatibility.WaveView;
import cn.kuwo.sing.util.lyric.Lyric;
import cn.kuwo.sing.util.lyric.Sentence;
import cn.kuwo.sing.util.lyric.Word;

/**
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2012-11-8, 上午9:47:09, 2012
 *
 * @Author wangming
 *
 */
public class LyricController extends BaseController {
	private final String TAG = "LyricController";
	private BaseActivity mActivity;
	private LyricLogic lLyric;
	private Lyric lyric;
	private AudioLogic lAudio;
	private Sentence lastSen = null;
	private Word lastWord = null;
	private LrcView sing_lrc_bottom = null;
	private WaveView sing_waves_view = null;
	private TextView sing_single_score = null;
	private static Handler handler = new Handler();
	private TextView tv_single_score;
	private TextView tv_single_score_last_tip;
	private TextView tv_comprehensive_score;
	private int total = 0;
	
	public LyricController(BaseActivity activity) {
		KuwoLog.i(TAG, "LyricController");
		mActivity = activity;
		
		lLyric = new LyricLogic();
		lAudio = new AudioLogic();
		sing_lrc_bottom = (LrcView) activity.findViewById(R.id.sing_lrc_bottom);
		sing_waves_view = (WaveView) activity.findViewById(R.id.sing_waves_view);
		sing_single_score = (TextView) activity.findViewById(R.id.tv_single_score);
		tv_single_score_last_tip = (TextView) activity.findViewById(R.id.tv_single_score_last_tip);
		tv_comprehensive_score = (TextView) activity.findViewById(R.id.tv_comprehensive_score);
	}
	
	public void loadLyric(final String rid) {
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				Lyric lyric = null;
				MusicBusiness bMusic = new MusicBusiness();
				try {
					lyric = bMusic.getLyric(rid);
				} catch (Exception e) {
					e.printStackTrace();
				} 
				Message msg = lyricHandler.obtainMessage();
				msg.what = 0;
				msg.obj = lyric;
				lyricHandler.sendMessage(msg);
			}
		}).start();
	}
	
	private Handler lyricHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				Lyric result = (Lyric) msg.obj;
				lyric = result;

				sing_lrc_bottom.setLyric(result);
				if (lLyric.isKdtx(result)) {
					sing_waves_view.setLyric(result);
					// 初始化打分
					lAudio.scoreInit(Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_COUNT, result.getEnvelope());
				} else {
					// TODO @LIKANG 13、歌词下载失败，不影响录制歌曲，歌词区显示：歌词下载失败
				}
				break;

			default:
				break;
			}
		}
		
	};
	
	public void setPosition(long position) {
		// 设置控件位置
		sing_lrc_bottom.setPosition(position);
		sing_waves_view.setPosition(position);
		Sentence sentence = null;
		if(lyric != null)
			 sentence = lLyric.findSentence(position, lyric,LyricLogic.SENTENCE_RESULT_NOW);
		if (sentence == null){
			if(lastSen != null) {
				onSentenceEnd(lastSen);
				lastSen = null;
			}
			return;
		}else if (lastSen!=null&&sentence!=lastSen) {
//			当前一句与后一句有叠加时,每当前一句唱完就去更新分数
			if(position>(lastSen.getTimespan()+lastSen.getTimestamp())){
				onSentenceEnd(lastSen);
				lastSen = null;
			}
			return;
		}

		if (sentence != lastSen) {
			// 触发事件
			onSentenceStart(sentence);
			onSentenceIndexChanged(sentence);
		}

		Word word = lLyric.findWord(position, sentence);
		if (word!=lastWord) {
			onWordIndexChanged(word);
		}
	}

	public void ProcessWaveDate(byte[] data) {
		short[] wav = IOUtils.convertToShortArray(data, 0, data.length);
		lAudio.scoreOnWavComing(wav);
		wav = null;
		final double envelope = lAudio.computeSingle(data);

		handler.post(new Runnable() {
			
			@Override
			public void run() {
				if (lLyric.isKdtx(lyric)) {
					// 打分
					
					int color = WaveView.WAVE_GREEN;
					if(lastWord != null)
						color = lAudio.judgeArrowColor(envelope, lastWord.getEnvelope());
					sing_waves_view.setArrowValue((int)envelope);
					sing_waves_view.setArrowColor(color);
				}
			}
		});

	}

	private void onWordIndexChanged(Word word){   //该切换到word字
		KuwoLog.v(TAG, "onWordIndexChanged");
		lastWord = word;
	}
	
	private void onSentenceIndexChanged(Sentence sentence){
		KuwoLog.v(TAG, "onSentenceIndexChanged");
		lastSen = sentence;
	}

	private void onSentenceStart(Sentence sentence){
		if (lLyric.isKdtx(lyric))
			lAudio.scoreStart(sentence.getSpectrum(), sentence.getEnvelopes());
	}

	private void onSentenceEnd(Sentence sentence){
		handler.post(new Runnable() {
			
			@Override
			public void run() {
				if (lLyric.isKdtx(lyric)) {
//					TODO 每句打分没有调用JNI接口
//					int score = lAudio.scoreEnd();
					int score = lAudio.computeMean();
					sing_single_score.setText(String.valueOf(score));
					if(score >= 85){
						tv_single_score_last_tip.setText("分（太棒了！）");
					}else if(score>=70){
						tv_single_score_last_tip.setText("分（看好你哦！）");
					}else if(score>=60){
						tv_single_score_last_tip.setText("分（加油加油！）");
					}else if(score>=30){
						tv_single_score_last_tip.setText("分（要努力呀！）");
					}else{
						tv_single_score_last_tip.setText("分（雷死了！）");
					}
					total = lAudio.computTotal();
					tv_comprehensive_score.setText(String.valueOf(total));
				}
			}
		});
	}
	
	public int getTotalScore() {
		return total;
		
	}
}
