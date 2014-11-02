package com.ifeng.news2.vote;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;

import android.content.Context;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.style.RelativeSizeSpan;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationSet;
import android.view.animation.TranslateAnimation;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.ViewSwitcher;

import com.ifeng.news2.R;
import com.ifeng.news2.vote.VoteProgress.VoteBarColor;
import com.ifeng.news2.vote.entity.Data;
import com.ifeng.news2.vote.entity.VoteItemInfo;

/**
 * 投票模块构造器
 * 
 * @author SunQuan:
 * @version 创建时间：2013-11-28 下午4:47:48 类说明
 */

public class VoteModuleBuilder {

	public static final int SINGLE_PAGE_MODE = 0x0001;
	public static final int EMBEDDED_MODE = 0x0002;

	public static final int QUESTION_PAGE = 0x0003;
	public static final int RESULT_PAGE = 0x0004;
	
	private static final int UP_ANMATION_HEIGHT = -100;
	
	//投票页&结果页
	private int currentPage = 0;
	private View content;
	private TextView voteTitle;
	private TextView createTime;
	private TextView partake;
	private TextView status;
	private LinearLayout question;
	private LinearLayout result;
	private LayoutInflater inflater;
	private ViewSwitcher switcher;
	private VoteProgress[] resultBars;
	private Context context;
	private Data data;
	private boolean isOverDue;
	private boolean isVoted;
	private VoteItemClickListener voteItemClickListener;
	private VoteShareListener voteShareListener;
	private int selectedItemIndex;
	private VoteBarColor[] voteBarColors;
	private ImageView shareButton;
	private int mode;
	private int backgroudResource;
	private TextView message;
	private NumberFormat formatter;
	private int totalCount;
	private boolean isIgnoreAnimation;
	
	

	/**
	 * 初始化投票构造器
	 * 
	 * @param context
	 * @return
	 */
	public static VoteModuleBuilder initialize(Context context,int mode) {
		return new VoteModuleBuilder(context,mode,0);
	}
	
	/**
	 * 初始化投票构造器,并且设置其背景颜色
	 * 
	 * @param context
	 * @return
	 */
	public static VoteModuleBuilder initialize(Context context,int mode,int backgroudResource) {
		return new VoteModuleBuilder(context,mode,backgroudResource);
	}
	
	public int getCurrentPage() {
		return currentPage;
	}
	
	
	

	/**
	 * 设置是否忽略动画
	 * 
	 * @param isIgnoreAnimation
	 */
	public VoteModuleBuilder setIgnoreAnimation(boolean isIgnoreAnimation) {
		this.isIgnoreAnimation = isIgnoreAnimation;
		return this;
	}

	/**
	 * 初始化视图布局
	 * 
	 * @param context
	 */
	private VoteModuleBuilder(Context context,int mode,int backgroudResource) {
		this.context = context;
		this.backgroudResource = backgroudResource;
		isIgnoreAnimation = false;
		selectedItemIndex = -1;
		formatter = new DecimalFormat("#0.0");
		voteBarColors = new VoteBarColor[] { VoteBarColor.COLOR_RED,
				VoteBarColor.COLOR_BLUE, VoteBarColor.COLOR_YELLOW,
				VoteBarColor.COLOR_DARK_BLUE, VoteBarColor.COLOR_GREEN };
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		content = inflater.inflate(R.layout.vote_module, null);
		if(backgroudResource != 0) {
			content.setBackgroundResource(backgroudResource);
		} else {
			content.setBackgroundResource(R.drawable.channellist_selector);
		}
		voteTitle = (TextView) findViewById(R.id.vote_title);
		createTime = (TextView) findViewById(R.id.vote_create_time);
		partake = (TextView) findViewById(R.id.vote_partakeNum);
		status = (TextView) findViewById(R.id.vote_status);
		question = (LinearLayout) findViewById(R.id.vote_question_module);
		result = (LinearLayout) findViewById(R.id.vote_result_module);
		switcher = (ViewSwitcher) findViewById(R.id.vote_switcher);
		shareButton = (ImageView) findViewById(R.id.vote_share);
		message = (TextView) findViewById(R.id.vote_message);
		shareButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if(voteShareListener != null) {
					voteShareListener.onShare();
				}
			}
		});
		this.mode = mode;
	}

	/**
	 * 设置问题选项点击的监听
	 * 
	 * @param voteItemClickListener
	 */
	public void setVoteItemClickListener(
			VoteItemClickListener voteItemClickListener) {
		this.voteItemClickListener = voteItemClickListener;
	}
	
	/**
	 * 设置投票分享的监听
	 * 
	 * @param voteShareListener
	 */
	public void setOnShareListener(VoteShareListener voteShareListener) {
		this.voteShareListener = voteShareListener;
	}

	/**
	 * 渲染投票视图
	 * 
	 * @param data
	 */
	public VoteModuleBuilder bindData(Data data) {
		this.data = data;
		isOverDue = data.isOverDue();
		isVoted = data.isVoted(context);
		// 渲染投票头部视图
		renderTitle();

		ArrayList<VoteItemInfo> voteItemInfos = data.getIteminfo();

		int count = voteItemInfos.size();
		resultBars = new VoteProgress[count];
		// 渲染问题视图
		for (int i = 0; i < count; i++) {
			VoteItemInfo voteItemInfo = voteItemInfos.get(i);
			// 如果过期，或者已经投票了，直接显示结果页，不渲染问题页视图
			if (isOverDue || isVoted) {
				renderResult(i, voteItemInfo);				
			} else {
				// 渲染问题页视图
				renderQuestion(i, voteItemInfo);
			}

		}

		// 如果已经过期或者已经投过票，则直接展示结果页
		if (isOverDue || isVoted) {
			displayResultModule(false);
		} else {
			displayQuestionModule();
		}

		return this;
	}
	
	/**
	 * 更新结果页
	 */
	private void updateResultPage() {
		result.removeAllViews();
		totalCount = Integer.valueOf(data.getVotecount());
		ArrayList<VoteItemInfo> voteItemInfos = data.getIteminfo();
		int count = voteItemInfos.size();
		for (int i = 0; i < count; i++) {
			VoteItemInfo voteItemInfo = voteItemInfos.get(i);
			renderResult(i, voteItemInfo);
		}
		partake.setText(totalCount + "人参与");
	}

	/**
	 * 渲染投票顶部视图
	 */
	private void renderTitle() {
		voteTitle.setText(data.getTopic());
		createTime.setText(data.getPublished());
		totalCount = Integer.valueOf(data.getVotecount());
		partake.setText(totalCount + "人参与");
		if (!isOverDue) {
			status.setText("进行中");
		} else {
			status.setText("投票已过期");
		}
	}

	/**
	 * 渲染问题页视图
	 */
	private void renderQuestion(final int index, final VoteItemInfo voteItemInfo) {
		View itemWrapper = inflater.inflate(R.layout.vote_question_item, null);
		if(backgroudResource != 0) {
			itemWrapper.setBackgroundResource(backgroudResource);
		} else {
			itemWrapper.setBackgroundResource(R.drawable.channellist_selector);
		}
		TextView questionText = (TextView) itemWrapper
				.findViewById(R.id.vote_question_text);
		questionText.setText(voteItemInfo.getTitle());
		question.addView(itemWrapper);
		itemWrapper.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				if (voteItemClickListener != null) {
					selectedItemIndex = index;					
					voteItemClickListener.onVoteItemClick(index, voteItemInfo);
				}
			}
		});
	}

	/**
	 * 展示结果视图
	 */
	public void displayResultModule(boolean voteSuccess) {
		currentPage = RESULT_PAGE;
        if (voteSuccess) {
          try {
            data.setVotecount((Integer.parseInt(data.getVotecount())+1)+"");
          } catch (Exception e) {
          }
        }
	    if(!(isOverDue || isVoted)) {
			updateResultPage();
		}
		// 切换到结果页视图
		switcher.setDisplayedChild(1);
		//删除掉问题页
		switcher.removeViewAt(0);
		message.setText(context.getString(R.string.vote_result_message));
		//如果不忽略动画 或者点击投票页
		if(!isIgnoreAnimation || voteSuccess) {
			// 播放评论进度条的动画
		    Log.e("tag", "vote isIgnoreAnimation = "+isIgnoreAnimation+"   voteSuccess = "+voteSuccess);
			for (VoteProgress resultBar : resultBars) {
				resultBar.startAni();
			}
		} else {
		  for (VoteProgress resultBar : resultBars) {
            resultBar.showProgress();
        }
		}
		
		resultBars = null;
	}

	/**
	 * 展示问题视图
	 */
	public void displayQuestionModule() {
		currentPage = QUESTION_PAGE;
		switcher.setDisplayedChild(0);
		message.setText(context.getString(R.string.vote_question_message));
	}

	/**
	 * 渲染结果页视图
	 */
	private void renderResult(int currentIndex, VoteItemInfo voteItemInfo) {
		View resultItemWrapper = inflater.inflate(R.layout.vote_result_item,
				null);
		if(backgroudResource != 0) {
			resultItemWrapper.setBackgroundResource(backgroudResource);
		} else {
			resultItemWrapper.setBackgroundResource(R.drawable.channellist_selector);
		}
		TextView votePercent = (TextView) resultItemWrapper
				.findViewById(R.id.vote_percent);
		TextView voteNum = (TextView) resultItemWrapper
				.findViewById(R.id.vote_num);
		TextView resultText = (TextView) resultItemWrapper
				.findViewById(R.id.vote_result_text);
		VoteProgress progress = (VoteProgress) resultItemWrapper
				.findViewById(R.id.bar);
		// 为进度条设置背景
		if (currentIndex < 5) {
			progress.setVoteBarColor(voteBarColors[currentIndex]);
		} else {
			progress.setVoteBarColor(voteBarColors[currentIndex % 5]);
		}
		
		resultBars[currentIndex] = progress;		
		int count = Integer.valueOf(voteItemInfo.getVotecount());
		// 如果投票的话，则将该项的票数加1
		if (selectedItemIndex == currentIndex) {
		  
		  final ImageView imgSupport = (ImageView) resultItemWrapper.findViewById(R.id.img_slice);
	      TranslateAnimation mAnaAnimation = new TranslateAnimation(0, 0, 0, UP_ANMATION_HEIGHT);
	      mAnaAnimation.setDuration(2000);
	      AlphaAnimation mAlphaAnimation = new AlphaAnimation(1, 0);
	      mAlphaAnimation.setDuration(600);
	      AnimationSet mAnimaSet = new AnimationSet(true);

	      mAnimaSet.addAnimation(mAnaAnimation);
	      mAnimaSet.addAnimation(mAlphaAnimation);
	      mAnimaSet.setAnimationListener(new AnimationListener() {

	        @Override
	        public void onAnimationStart(Animation animation) {

	          imgSupport.setVisibility(View.VISIBLE);
	        }

	        @Override
	        public void onAnimationRepeat(Animation animation) {

	        }

	        @Override
	        public void onAnimationEnd(Animation animation) {

	          imgSupport.clearAnimation();
	          imgSupport.setVisibility(View.GONE);
	        }
	      });
	      imgSupport.startAnimation(mAnimaSet);
		  
			count = count + 1;
//			totalCount = totalCount + 1;
			voteItemInfo.setVotecount(String.valueOf(count));	
//			data.setVotecount(String.valueOf(totalCount));
		}
		
		voteNum.setText(count + "票");
		String percent = "0.0";
		//当totalcount为0的时候，所有的选项所占的百分比都是0
		if(totalCount > 0) {
			//计算票数的百分比
			percent = formatter.format((float)count/totalCount * 100);
		}	
		voteItemInfo.setNump(Float.valueOf(percent));
		votePercent.setText(processStr(percent));
		// 为进度条设置百分比
		progress.setPercent(Float.valueOf(percent));
		resultText.setText(voteItemInfo.getTitle());
		result.addView(resultItemWrapper);
	}
	
	/**
	 * 加工textView的数据，将%变小居底
	 * 
	 * @param str
	 */
	private SpannableString processStr(String str) {
		SpannableString span = new SpannableString(str + "%");
	    span.setSpan(new RelativeSizeSpan(0.5f), str.length(),
	    str.length() + 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
	    return span;
	}

	private View findViewById(int resId) {
		return content.findViewById(resId);
	}

	/**
	 * 创建投票模块
	 * 
	 * @return
	 */
	public View build() {
		//单页模式不显示分享按钮
		if(mode == SINGLE_PAGE_MODE) {
			shareButton.setVisibility(View.INVISIBLE);
			voteTitle.setTextColor(context.getResources().getColor(R.color.black));
		} 
		//嵌入模式不显示创建日期
		else if(mode == EMBEDDED_MODE) {
			createTime.setVisibility(View.GONE);
			voteTitle.setTextColor(context.getResources().getColor(R.color.topic_title_font));
		}
		return content;
	}

	/**
	 * 投票问题项的点击监听
	 * 
	 * @author SunQuan
	 * 
	 */
	public interface VoteItemClickListener {
		void onVoteItemClick(int position, VoteItemInfo voteItemInfo);
	}
	
	/**
	 * 投票分享监听
	 * @author SunQuan
	 *
	 */
	public interface VoteShareListener {
		void onShare();
	}

}
