package com.ifeng.news2.widget;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TableRow;
import android.widget.TextView;

import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.id;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.R.string;
import com.ifeng.news2.R.style;

/**
 * @author liu_xiaoliang
 * 底部导航栏 统一详情页和图片页 提供详情页夜间和白天模式
 */
public class IfengBottomTitleTabbar extends TableRow {


	/**
	 * 详情页白天模式
	 */
	public static final int MODE_DETAIL_DAY = 0x1;
	/**
	 * 详情页夜间模式
	 */
	public static final int MODE_DETAIL_NIGHT = 0x2;
	/**
	 * 图片页白天模式
	 */
	public static final int MODE_GALLERY_DAY = 0x3;
	/**
	 * 图片页夜间模式
	 */
	public static final int MODE_GALLERY_NIGHT = 0x4;
	/**
	 * json专题白天模式
	 */
	public static final int MODE_JSON_TOPIC_DAY = 0x5;
	/**
	 * json专题夜间模式
	 */
	public static final int MODE_JSON_TOPIC_NIGHT = 0x6;
	
	/**
	 * 投票白天模式
	 */
	public static final int MODE_VOTE_DAY = 0x7;

	private String DETAIL_DAY = "mode_detail_day";
	private String DETAIL_NIGHT = "mode_detail_night";
	private String GALLERY_DAY = "mode_gallery_day";
	private String GALLERY_NIGHT = "mode_gallery_night";
	private String JSON_TOPIC_DAY = "mode_json_topic_day";
	private String JSON_TOPIC_NIGHT = "mode_json_topic_night";
	private String VOTE_DAY = "mode_vote_day";
	
	private int MODE;
	private ImageView back;
	private ImageView more;
	private ImageView placeholder;
	private ImageView writeComment;
	private TextView backPrompt;
	private TextView writeCommentPrompt;
	private TextView morePrompt;
	private TextView plcaeHolderPrompt;
	private ImageView firstDivider;
	private ImageView secondDivider;
	private ImageView thirdDivider;
	private View bottomTitleTabbar;

	private Context context;
	
	public IfengBottomTitleTabbar(Context context, int mode) {
		super(context);
		this.MODE = mode;
		init(context);
		setStyle();
	}

	public IfengBottomTitleTabbar(Context context, AttributeSet attrs) {
		super(context, attrs);
		MODE = getModeByString(attrs.getAttributeValue(null, "mode"));
		init(context);
		setStyle();
	}

	public int getModeByString(String modeStr){
		if (DETAIL_DAY.equals(modeStr))
			return MODE_DETAIL_DAY;
		else if (DETAIL_NIGHT.equals(modeStr)) 
			return MODE_DETAIL_NIGHT;
		else if (GALLERY_DAY.equals(modeStr)) 
			return MODE_GALLERY_DAY;
		else if (GALLERY_NIGHT.equals(modeStr)) 
			return MODE_GALLERY_NIGHT;
		else if (JSON_TOPIC_DAY.equals(modeStr)) 
			return MODE_JSON_TOPIC_DAY;
		else if (JSON_TOPIC_NIGHT.equals(modeStr)) 
			return MODE_JSON_TOPIC_NIGHT;
		else if(VOTE_DAY.equals(modeStr))
			return MODE_VOTE_DAY;
		else 
			return MODE_DETAIL_DAY; //默认
	}
	
	private void init(Context context) {
		this.context = context;
		LayoutInflater inflater = LayoutInflater.from(context);
		View view = inflater.inflate(layout.bottom_title_tabbar, this);
		back = (ImageView)view.findViewById(id.back);
		backPrompt = (TextView)view.findViewById(id.back_prompt);
		firstDivider = (ImageView)view.findViewById(id.first_divider);
		secondDivider = (ImageView)view.findViewById(id.second_divider);
		thirdDivider = (ImageView)view.findViewById(id.third_divider);
		placeholder = (ImageView)view.findViewById(id.placeholder);
		plcaeHolderPrompt = (TextView) findViewById(R.id.placeholder_prompt);
		writeComment = (ImageView)view.findViewById(id.write_comment);
		writeCommentPrompt = (TextView)view.findViewById(id.write_comment_prompt);
		more = (ImageView)view.findViewById(id.more);
		morePrompt = (TextView)view.findViewById(id.more_prompt);
		
		bottomTitleTabbar = view;
	}

	private void setStyle(){
		StyleBean styleBean = getStyleBean();
		
		Drawable drawable = null;
		
		if(styleBean.getDrawableBackId() != 0  ){
			back.setBackgroundResource(styleBean.getDrawableBackId());
		}
		if(styleBean.getDrawableBackPromptId() != 0 ){
			drawable = getResources().getDrawable(styleBean.getDrawableBackPromptId());
			drawable.setBounds(0, 0, drawable.getMinimumWidth(), drawable.getMinimumHeight());  
			backPrompt.setCompoundDrawables(drawable, null, null, null);
		}
		if(styleBean.getStrBackPromptId() != 0){
			backPrompt.setText(styleBean.getStrBackPromptId());
			backPrompt.setTextAppearance(context, styleBean.getTextStyle());
		}
		
		if(styleBean.getDrawableWriteCommentId() != 0){
			writeComment.setBackgroundResource(styleBean.getDrawableWriteCommentId());
		}
		if(styleBean.getDrawableWriteCommentPromptId() != 0){
			drawable = getResources().getDrawable(styleBean.getDrawableWriteCommentPromptId());
			drawable.setBounds(0, 0, drawable.getMinimumWidth(), drawable.getMinimumHeight());  
			writeCommentPrompt.setCompoundDrawables(drawable, null, null, null);
		}
		if(styleBean.getStrWriteCommentPromptId() != 0){
			writeCommentPrompt.setText(styleBean.getStrWriteCommentPromptId());
			writeCommentPrompt.setTextAppearance(context, styleBean.getTextStyle());
		}

		if(styleBean.getDrawableMoreId() != 0){
			more.setBackgroundResource(styleBean.getDrawableMoreId());
		}
		if(styleBean.getDrawableMorePromptId() != 0){
			drawable = getResources().getDrawable(styleBean.getDrawableMorePromptId());
			drawable.setBounds(0, 0, drawable.getMinimumWidth(), drawable.getMinimumHeight());  
			morePrompt.setCompoundDrawables(drawable, null, null, null);
		}
		if(styleBean.getStrMorePromptStrId() != 0){
			morePrompt.setText(styleBean.getStrMorePromptStrId());
			morePrompt.setTextAppearance(context, styleBean.getTextStyle());
		}
		
		if(styleBean.getDrawablePlaceholderId() != 0){
			placeholder.setBackgroundResource(styleBean.getDrawablePlaceholderId());
		}
		if(styleBean.getDrawablePlaceholderPromptId() != 0){
			drawable = getResources().getDrawable(styleBean.getDrawablePlaceholderPromptId());
			drawable.setBounds(0, 0, drawable.getMinimumWidth(), drawable.getMinimumHeight());  
			plcaeHolderPrompt.setCompoundDrawables(drawable, null, null, null);
		}
		if(styleBean.getStrPlaceHolderPromptId() != 0){
			plcaeHolderPrompt.setText(styleBean.getStrPlaceHolderPromptId());
			plcaeHolderPrompt.setTextAppearance(context, styleBean.getTextStyle());
		}

		firstDivider.setBackgroundResource(styleBean.getDrawableFirstDividerId());
		secondDivider.setBackgroundResource(styleBean.getDrawableSecondDividerId());
		thirdDivider.setBackgroundResource(styleBean.getDrawableThirdDividerId());
		
		bottomTitleTabbar.setBackgroundResource(styleBean.getDrawableBottomTitleTabbarBg());
		
	}

	private StyleBean getStyleBean(){
		StyleBean styleBean = null;
		switch (MODE) {
		case MODE_DETAIL_DAY:
			styleBean = getDetailDayStyleBean();
			break;
		case MODE_DETAIL_NIGHT:
			styleBean = getDetailNightStyleBean();
			break;
		case MODE_GALLERY_DAY:
			styleBean = getGalleryDayStyleBean();
			break;
		case MODE_GALLERY_NIGHT:
			styleBean = getGalleryNightStyleBean();
			break;
		case MODE_JSON_TOPIC_DAY:
			styleBean = getJsonTopicDayStyleBean();
			break;
		case MODE_JSON_TOPIC_NIGHT:
			styleBean = getJsonTopicNightStyleBean();
			break;
		case MODE_VOTE_DAY:
			styleBean = getVoteDayStyleBean();
		}
		return styleBean;
	}

	/**
	 * 获取投票页白天模式的资源bean
	 * @return
	 */
	private StyleBean getVoteDayStyleBean() {
		StyleBean styleBean = new StyleBean();
		
		styleBean.setDrawableBackId(drawable.detail_title_bar_button);
		styleBean.setDrawableBackPromptId(drawable.back);
		styleBean.setStrBackPromptId(string.back);
		
		styleBean.setDrawableMoreId(drawable.detail_title_bar_button);
		styleBean.setDrawableMorePromptId(drawable.share);
		styleBean.setStrMorePromptStrId(string.detail_title_bar_share);
		
		styleBean.setDrawablePlaceholderId(drawable.detail_title_bar_button);	
		styleBean.setDrawableFirstDividerId(drawable.detail_tabbar_cutoff);
		styleBean.setDrawableThirdDividerId(drawable.detail_tabbar_cutoff);		
		styleBean.setTextStyle(style.detail_title_bar_button);

		styleBean.setDrawableBottomTitleTabbarBg(drawable.detail_tabbar_background);
		placeholder.setClickable(false);
		writeComment.setClickable(false);
		return styleBean;
	}

	/**
	 * @return StyleBean 获取详情页白天模式底部导航栏资源bean
	 */
	private StyleBean getDetailDayStyleBean(){

		StyleBean styleBean = new StyleBean();
		
		styleBean.setDrawableBackId(drawable.detail_title_bar_button);
		styleBean.setDrawableBackPromptId(drawable.back);
		styleBean.setStrBackPromptId(string.back);
		
		styleBean.setDrawablePlaceholderId(drawable.detail_title_bar_button);
		styleBean.setDrawablePlaceholderPromptId(drawable.write_comment);
		styleBean.setStrPlaceHolderPromptId(string.detail_title_bar_write_comment);
		
		styleBean.setDrawableWriteCommentId(drawable.detail_title_bar_button);
		styleBean.setDrawableWriteCommentPromptId(drawable.share);
		styleBean.setStrWriteCommentPromptId(string.detail_title_bar_share);
		
		styleBean.setDrawableMoreId(drawable.detail_title_bar_button);
		styleBean.setDrawableMorePromptId(drawable.collection);
		styleBean.setStrMorePromptStrId(string.favourite);
		
		styleBean.setDrawableFirstDividerId(drawable.detail_tabbar_cutoff);
		styleBean.setDrawableSecondDividerId(drawable.detail_tabbar_cutoff);
		styleBean.setDrawableThirdDividerId(drawable.detail_tabbar_cutoff);
		
		styleBean.setTextStyle(style.detail_title_bar_button);

		styleBean.setDrawableBottomTitleTabbarBg(drawable.detail_tabbar_background);
		
		return styleBean;
	}
	/**
	 * @return StyleBean  获取图片页夜间模式底部导航栏资源bean
	 */
	private StyleBean getGalleryNightStyleBean(){
		return null;
	}
	/**
	 * @return  StyleBean 获取图片模式底部导航栏资源bean
	 */
	private StyleBean getGalleryDayStyleBean(){

		StyleBean styleBean = new StyleBean();
		
		styleBean.setDrawableBackId(drawable.gallery_title_bar_button);
		styleBean.setDrawableBackPromptId(drawable.gallery_back);
		styleBean.setStrBackPromptId(string.back);
		
		styleBean.setDrawablePlaceholderId(drawable.gallery_title_bar_button);
		styleBean.setDrawablePlaceholderPromptId(drawable.gallery_comment);
		styleBean.setStrPlaceHolderPromptId(string.detail_title_bar_write_comment);
		
		styleBean.setDrawableWriteCommentId(drawable.gallery_title_bar_button);
		styleBean.setDrawableWriteCommentPromptId(drawable.gallery_share);
		styleBean.setStrWriteCommentPromptId(string.detail_title_bar_share);
		
		styleBean.setDrawableMoreId(drawable.gallery_title_bar_button);
		styleBean.setDrawableMorePromptId(drawable.gallery_download);
		styleBean.setStrMorePromptStrId(string.detail_title_bar_download);
		
		styleBean.setDrawableFirstDividerId(drawable.gallery_divider);
		styleBean.setDrawableSecondDividerId(drawable.gallery_divider);
		styleBean.setDrawableThirdDividerId(drawable.gallery_divider);

		styleBean.setTextStyle(style.gallery_title_bar_button);
		
		styleBean.setDrawableBottomTitleTabbarBg(drawable.gallery_bottom_title_bar_background);
		
		return styleBean;
	}

	/**
	 * @return StyleBean  获取详情页夜间模式底部导航栏资源bean
	 */
	private StyleBean getDetailNightStyleBean(){
		return null;
	}
	/**
	 * @return StyleBean  获取专题日间模式底部导航栏资源bean
	 */
	private StyleBean getJsonTopicDayStyleBean(){
		StyleBean styleBean = new StyleBean();
		
		styleBean.setDrawableBackId(drawable.detail_title_bar_button);
		styleBean.setDrawableBackPromptId(drawable.back);
		styleBean.setStrBackPromptId(string.back);
		
		styleBean.setDrawableMoreId(drawable.detail_title_bar_button);
		styleBean.setDrawableMorePromptId(drawable.share);
		styleBean.setStrMorePromptStrId(string.detail_title_bar_share);
		
		styleBean.setDrawablePlaceholderId(drawable.detail_title_bar_button);

		styleBean.setDrawableWriteCommentId(drawable.detail_title_bar_button);
		styleBean.setDrawableWriteCommentPromptId(drawable.write_comment);
		styleBean.setStrWriteCommentPromptId(string.detail_title_bar_write_comment);
		
		styleBean.setDrawableFirstDividerId(drawable.detail_tabbar_cutoff);
		styleBean.setDrawableSecondDividerId(drawable.detail_tabbar_cutoff);
		styleBean.setDrawableThirdDividerId(drawable.detail_tabbar_cutoff);
		
		styleBean.setTextStyle(style.detail_title_bar_button);

		styleBean.setDrawableBottomTitleTabbarBg(drawable.detail_tabbar_background);
		
		return styleBean;
	}
	/**
	 * @return StyleBean  获取专题夜间模式底部导航栏资源bean
	 */
	private StyleBean getJsonTopicNightStyleBean(){
		return null;
	}
	
	/**
	 * @param mode int 模式类型
	 * 对外提供设置模式方法
	 */
	public void setMode(int mode){
		this.MODE = mode;
		setStyle();
	}
	
	class StyleBean {
		private int drawableBackId;
		private int drawableBackPromptId;
		private int strBackPromptId;

		private int drawableWriteCommentId;
		private int drawableWriteCommentPromptId;
		private int strWriteCommentPromptId;
		
		private int drawableMoreId;
		private int drawableMorePromptId;
		private int strMorePromptStrId;

		private int drawablePlaceholderId;
		private int drawablePlaceholderPromptId;
		private int strPlaceHolderPromptId; 
		
		
		private int drawableFirstDividerId;
		
		private int drawableSecondDividerId;
		private int drawableThirdDividerId;

		private int textStyle;
		
		private int drawableBottomTitleTabbarBg;

		public int getDrawableBackId() {
			return drawableBackId;
		}

		public void setDrawableBackId(int drawableBackId) {
			this.drawableBackId = drawableBackId;
		}

		public int getDrawableBackPromptId() {
			return drawableBackPromptId;
		}

		public void setDrawableBackPromptId(int drawableBackPromptId) {
			this.drawableBackPromptId = drawableBackPromptId;
		}

		public int getStrBackPromptId() {
			return strBackPromptId;
		}

		public void setStrBackPromptId(int strBackPromptId) {
			this.strBackPromptId = strBackPromptId;
		}

		public int getDrawableWriteCommentId() {
			return drawableWriteCommentId;
		}

		public void setDrawableWriteCommentId(int drawableWriteCommentId) {
			this.drawableWriteCommentId = drawableWriteCommentId;
		}

		public int getDrawableWriteCommentPromptId() {
			return drawableWriteCommentPromptId;
		}

		public void setDrawableWriteCommentPromptId(int drawableWriteCommentPromptId) {
			this.drawableWriteCommentPromptId = drawableWriteCommentPromptId;
		}

		public int getStrWriteCommentPromptId() {
			return strWriteCommentPromptId;
		}

		public void setStrWriteCommentPromptId(int strWriteCommentPromptId) {
			this.strWriteCommentPromptId = strWriteCommentPromptId;
		}

		public int getDrawableMoreId() {
			return drawableMoreId;
		}

		public void setDrawableMoreId(int drawableMoreId) {
			this.drawableMoreId = drawableMoreId;
		}

		public int getDrawableMorePromptId() {
			return drawableMorePromptId;
		}

		public void setDrawableMorePromptId(int drawableMorePromptId) {
			this.drawableMorePromptId = drawableMorePromptId;
		}

		public int getStrMorePromptStrId() {
			return strMorePromptStrId;
		}

		public void setStrMorePromptStrId(int strMorePromptStrId) {
			this.strMorePromptStrId = strMorePromptStrId;
		}

		public int getDrawablePlaceholderId() {
			return drawablePlaceholderId;
		}

		public void setDrawablePlaceholderId(int drawablePlaceholderId) {
			this.drawablePlaceholderId = drawablePlaceholderId;
		}

		public int getDrawableFirstDividerId() {
			return drawableFirstDividerId;
		}

		public void setDrawableFirstDividerId(int drawableFirstDividerId) {
			this.drawableFirstDividerId = drawableFirstDividerId;
		}

		public int getDrawableSecondDividerId() {
			return drawableSecondDividerId;
		}

		public void setDrawableSecondDividerId(int drawableSecondDividerId) {
			this.drawableSecondDividerId = drawableSecondDividerId;
		}

		public int getDrawableThirdDividerId() {
			return drawableThirdDividerId;
		}

		public void setDrawableThirdDividerId(int drawableThirdDividerId) {
			this.drawableThirdDividerId = drawableThirdDividerId;
		}

		public int getTextStyle() {
			return textStyle;
		}

		public void setTextStyle(int textStyle) {
			this.textStyle = textStyle;
		}

		public int getDrawableBottomTitleTabbarBg() {
			return drawableBottomTitleTabbarBg;
		}

		public void setDrawableBottomTitleTabbarBg(int drawableBottomTitleTabbarBg) {
			this.drawableBottomTitleTabbarBg = drawableBottomTitleTabbarBg;
		}

		public int getDrawablePlaceholderPromptId() {
			return drawablePlaceholderPromptId;
		}

		public void setDrawablePlaceholderPromptId(int drawablePlaceholderPromptId) {
			this.drawablePlaceholderPromptId = drawablePlaceholderPromptId;
		}

		public int getStrPlaceHolderPromptId() {
			return strPlaceHolderPromptId;
		}

		public void setStrPlaceHolderPromptId(int strPlaceHolderPromptId) {
			this.strPlaceHolderPromptId = strPlaceHolderPromptId;
		}
	}


}
