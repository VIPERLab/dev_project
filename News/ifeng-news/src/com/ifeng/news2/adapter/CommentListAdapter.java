package com.ifeng.news2.adapter;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.text.Html;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.R.color;
import com.ifeng.news2.bean.Comment;
import com.ifeng.news2.bean.CommentsData;
import com.ifeng.news2.bean.ParentComment;
import com.qad.loader.ImageLoader;
import com.qad.loader.LoadContext;
import java.util.ArrayList;

public class CommentListAdapter extends BaseAdapter {
	private LayoutInflater inflater;
	private Context ctxt;
	private ArrayList<Comment> newsCommentsList;
	private ArrayList<Comment> hotCommentsList;	
	private Boolean submitSuccess = false;
	private int submitCount;
	private Comment tmpComment = null;
	private CommentsData commentsData = null;
	public static final int TITLE_LENGTH = 14;
	
	public void setCommentsData(CommentsData commentsData) {
		this.commentsData = commentsData;
	}

	
	public CommentListAdapter(Context ctxt) {
		this.ctxt = ctxt;
		inflater = LayoutInflater.from(ctxt);
	}

	public void setNewsComments(ArrayList<Comment> newsCommentsList) {
		this.newsCommentsList = newsCommentsList;
	}
	
	public void setHotComments(ArrayList<Comment> hotComments) {
		this.hotCommentsList = hotComments;
	}
	
	@Override
	public boolean isEnabled(int position) {
		if(position==0||position==hotCommentsList.size()+1){
			return false;
		}
		return super.isEnabled(position);
	}

	@Override
	public int getCount() {
		return hotCommentsList.size()+newsCommentsList.size()+2;
	}

	@Override
	public Comment getItem(int position) {
		if(position==0){
			return null;
		}
		else if(position<=hotCommentsList.size()){
			return hotCommentsList.get(position-1);
		}
		else if(position==hotCommentsList.size()+1){
			return null;
		}
		else{
			return newsCommentsList.get(position-hotCommentsList.size()-2);
		}		
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public int getViewTypeCount() {
		return 2;
	}

	@Override
	public int getItemViewType(int position) {
		return position-hotCommentsList.size()-getViewTypeCount() < submitCount && position > hotCommentsList.size()+1 && submitSuccess ? 0 : 1;
	}

	public void setCommentSuccess(Boolean isSuccess, int count) {
		this.submitSuccess = isSuccess;
		this.submitCount = count;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {		
		
		CommentsViewHolder holder = null;
		if (position == 0) {
			LinearLayout titleView = (LinearLayout) inflater.inflate(R.layout.comment_title, null);
			((ImageView)titleView.findViewById(R.id.comment_logo)).setImageResource(R.drawable.comment_hot_tag);	
			((TextView)titleView.findViewById(R.id.join_count)).setText(Html.fromHtml("<font color=#bb0b15>"+commentsData.getJoin_count()+"</font>人参与"));
			((TextView)titleView.findViewById(R.id.count)).setText(Html.fromHtml("<font color=#bb0b15>"+commentsData.getCount()+"</font>条评论"));
			if(hotCommentsList.size()==0){
				titleView.findViewById(R.id.no_comments_message).setVisibility(View.VISIBLE);
			}
			return titleView;
		}		
		else if(position == hotCommentsList.size()+1){
			LinearLayout titleView = (LinearLayout) inflater.inflate(R.layout.comment_title, null);
			((ImageView)titleView.findViewById(R.id.comment_logo)).setImageResource(R.drawable.comment_news_tag);
			if(newsCommentsList.size()==0){
				titleView.findViewById(R.id.no_comments_message).setVisibility(View.VISIBLE);
			}
			return titleView;
		}
		else{
			tmpComment = getItem(position);
			return renderCommentView(convertView, holder, position);
		}		
	}
	
	private View renderCommentView(View convertView,CommentsViewHolder holder,int position){
		if (convertView != null&&!(convertView instanceof LinearLayout)) {
			holder = (CommentsViewHolder) convertView.getTag();
		} else {				
			convertView = inflater.inflate(R.layout.widget_comment_list_item,
					null);
			holder = new CommentsViewHolder();				
			holder.ip_fromTV = (TextView) convertView
					.findViewById(R.id.ip_from);
			holder.comment_contentTV = (TextView) convertView
					.findViewById(R.id.comment_content);
			holder.comment_FloorListLY = (LinearLayout) convertView
					.findViewById(R.id.comment_floor_list);
			holder.comment_FloorShadowLY = (LinearLayout) convertView
					.findViewById(R.id.comment_floor_shadow);
			holder.uptimes = (TextView) convertView.findViewById(R.id.uptimes);
			holder.uptimes_icon = (ImageView) convertView.findViewById(R.id.uptimes_icon);
			holder.userFace = (ImageView) convertView.findViewById(R.id.userIcon);
			convertView.setTag(holder);
		}

		if (getItemViewType(position) == 0) {
			SpannableString ss = new SpannableString(tmpComment.getIp_from());
			ss.setSpan(new ForegroundColorSpan(Color.RED), 0, tmpComment
					.getIp_from().length(),
			// setSpan时需要指定的 flag,Spanned.SPAN_EXCLUSIVE_EXCLUSIVE(前后都不包括).
					Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
			holder.ip_fromTV.setText(ss);
			convertView.setBackgroundResource(color.yellow);			
		} else {
			holder.ip_fromTV.setText(processText(tmpComment.getIp_from()));			
		}
		String commentContent = tmpComment.getComment_contents();
		if (commentContent == null) {
			commentContent = "";
		}
		holder.comment_contentTV.setText(commentContent.replace("&quot;", "\"")
				.replace("<br>", ""));
		holder.uptimes.setText(tmpComment.getUptimes());
		if(tmpComment.isUped()){
			holder.uptimes_icon.setBackgroundDrawable(ctxt.getResources().getDrawable(R.drawable.comment_clicked));
		}else{
			holder.uptimes_icon.setBackgroundDrawable(ctxt.getResources().getDrawable(R.drawable.comment_default));			
		}
		String iconUrl = tmpComment.getUserFace();	
		if (!TextUtils.isEmpty(iconUrl)) {
			IfengNewsApp.getImageLoader().startLoading(
			        new LoadContext<String, ImageView, Bitmap>(iconUrl, holder.userFace, 
					Bitmap.class, LoadContext.FLAG_CACHE_FIRST, ctxt)
					, new ImageLoader.DefaultImageDisplayer(ctxt.getResources().getDrawable(R.drawable.comment_default_photo)));
		}else{
			holder.userFace.setImageDrawable(ctxt.getResources().getDrawable(R.drawable.comment_default_photo));
		}
		setFloors(tmpComment, holder.comment_FloorListLY,
				holder.comment_FloorShadowLY);
		return convertView;
	}

	private void setFloors(Comment cmt, LinearLayout comment_FloorList,
			LinearLayout comment_FloorShadow) {
		comment_FloorList.removeAllViews();
		ArrayList<ParentComment> parentCmt = cmt.getParent();
		if (null == parentCmt)
			return;
		int floorCount = parentCmt.size();
		if (floorCount > 0) {
			comment_FloorShadow.setVisibility(View.VISIBLE);
		} else {
			comment_FloorShadow.setVisibility(View.GONE);
			return;
		}
		if (cmt.isExpansion()) {
			// 全部显示
			addFloorItems(parentCmt, comment_FloorList, true);
		} else {
			if (floorCount <= 0) {
				// 不做处理
			} else if (0 < floorCount && floorCount <= 4) {
				// 正常显示
				addFloorItems(parentCmt, comment_FloorList, true);
			} else {
				// 特殊处理
				addFloorItems(parentCmt, comment_FloorList, false);
			}
		}
	}

	private void addFloorItems(ArrayList<ParentComment> parentCmt,
			LinearLayout comment_FloorList, boolean isExpansion) {
		int floorCount = 0;
		if (isExpansion) {
			floorCount = parentCmt.size();
		} else {
			floorCount = 3;
		}
		for (int i = 0; i < floorCount; i++) {
			View floorItem = null;
			if (isExpansion) {
				floorItem = getFloorItem(false, parentCmt, i);
			} else {
				if (i == 1) {
					floorItem = getFloorItem(true, parentCmt, i);
				} else if (i == 2) {
					floorItem = getFloorItem(false, parentCmt,
							parentCmt.size() - 1);
				} else {
					floorItem = getFloorItem(false, parentCmt, i);
					floorItem.findViewById(R.id.comment_floor_item_line)
							.setVisibility(View.GONE);
				}
			}
			if (i == floorCount - 1)
				floorItem.findViewById(R.id.comment_floor_item_line)
						.setVisibility(View.GONE);
			comment_FloorList.addView(floorItem);
		}
	}

	private View getFloorItem(boolean isLoadMoreItem,
			ArrayList<ParentComment> parentCmtTmp, int index) {
		View floorItem = null;
		if (isLoadMoreItem) {
			floorItem = inflater.inflate(
					R.layout.widget_comment_list_item_floor_loadmore, null);
			TextView loadmore_but = (TextView) floorItem
					.findViewById(R.id.comment_list_floor_loadmore_but);
			loadmore_but
					.setText("隐藏了" + (parentCmtTmp.size() - 2) + "条评论，点击展开");
			floorItem.setTag(tmpComment);
			floorItem.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
				    Comment tempComment = (Comment)v.getTag();
				    if (null != tempComment) {
				      tempComment.setExpansion(true);
                    }
					CommentListAdapter.this.notifyDataSetChanged();
				}
			});
		} else {
			floorItem = inflater.inflate(
					R.layout.widget_comment_list_item_floor_item, null);
			floorItem.setBackgroundColor(ctxt.getResources().getColor(R.color.comments_build));
			TextView floorFrom = (TextView) floorItem
					.findViewById(R.id.ip_floor_from);
			TextView floorNumber = (TextView) floorItem
					.findViewById(R.id.comment_floor_number);
			TextView floorContent = (TextView) floorItem
					.findViewById(R.id.comment_floor_content);	
			if("未知IP".equals(parentCmtTmp.get(index).getIp_from())) {
				floorFrom.setText("凤凰网"+parentCmtTmp.get(index).getIp_from()+"网友");
			} else {
				floorFrom.setText(subTitle("凤凰网"+parentCmtTmp.get(index).getIp_from()+"网友",parentCmtTmp.get(index).getUname()));
			}
			floorNumber.setText(index + 1 + "");
			String content = parentCmtTmp.get(index).getComment_contents();
			if (TextUtils.isEmpty(content)) {
				content = "";
			} else {
				content = content.replace("&quot;", "\"").replace("<br>", "");
			}
			floorContent.setText(content);
		}
		return floorItem;
	}
	
	private String processText(String text){
		if(!"您的评论正在审核中".equals(text)){
			if("未知IP".equals(tmpComment.getIp_from())) {
				text = "凤凰网"+tmpComment.getIp_from()+"网友";
			} else {
				text = subTitle("凤凰网"+tmpComment.getIp_from()+"网友",tmpComment.getUname());	
			}
		}
		return text;
	}
	
	private String subTitle(String text,String uname) {
		try {
			if((text.length()+uname.length()+1)>TITLE_LENGTH) {
				return text;
			}
			return text+":"+uname;
		}catch(Exception e) {
			return text;
		}
	}
	
//	private String ipFromIntercept(String ipForm) {
//		int provinceIndex  = ipForm.indexOf("省");
//		int cityIndex  = ipForm.indexOf("市");
//		if(provinceIndex !=-1 && cityIndex != -1) {
//				return ipForm.substring(provinceIndex+1);
//		}
//		return ipForm;
//	}
	
	static class CommentsViewHolder {
		
		public TextView ip_fromTV;
		public TextView comment_contentTV;
		public LinearLayout comment_FloorListLY;
		public LinearLayout comment_FloorShadowLY;
		public TextView uptimes;
		public ImageView uptimes_icon;
		public ImageView userFace;
		
	}
}
