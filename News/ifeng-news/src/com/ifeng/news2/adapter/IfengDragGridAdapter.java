package com.ifeng.news2.adapter;

import java.util.ArrayList;

import com.ifeng.news2.R;

import android.content.Context;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CalendarView;
import android.widget.TableLayout;
import android.widget.TextView;

public class IfengDragGridAdapter extends BaseAdapter {

	private ArrayList<String> arrayTitles;
	private Context context;
	private int dragPosition = -1;
	private ArrayList<String> unchangingPosition;
	private IfengLineNum ifengLineNum;

	public IfengDragGridAdapter(Context context, ArrayList<String> arrayTitles) {
		this.context = context;
		this.arrayTitles = arrayTitles;
		// this.arrayDrawables = arrayDrawables;
	}
	
	public IfengDragGridAdapter(Context context,ArrayList<String> arrayTitles,IfengLineNum _ifengLineNum) {
	    this.context = context;
	    this.arrayTitles = arrayTitles;
	    this.ifengLineNum=_ifengLineNum;
	  }
	
	
	public ArrayList<String> getArrayTitles() {
		return arrayTitles;
	}
	
	public View getView(int position, View convertView, ViewGroup parent) {
		View view = null;
		view = LayoutInflater.from(context).inflate(
				R.layout.ifeng_subscription_layout_item, null);
		view.setBackgroundDrawable(view.getContext().getResources()
				.getDrawable(R.drawable.subscription_divider));
		TextView textView = (TextView) view
				.findViewById(R.id.subscription_item_text);
		
		String currItemText = arrayTitles.get(position);
		if (null != currItemText && 3 < currItemText.length() && null !=ifengLineNum ) {
		   /**
	         * item高度为45dp(ifeng_subscription_layout_item文件).
	         *     以文字为normal(17dp)为例， (45-17)/2=14dp,文字距离top和bottom约为14dp（取了12更满足设计的要求，见ifeng_subscription_layout_item.xml文件）。
	         *     Font(smaller)=13（因文字显示两行） （45-13x2）/2=10
	         *     Font(small)=14   (45-14x2)/2=8(取到 5)
	         * */
		  switch (ifengLineNum) {
	          case TwoLineAndSmallerFont:
	            textView.setTextSize(13);
	            textView.setPadding(0, 10, 0,10);
	            textView.setMaxEms(2);
	            //2行-超小号字体
	            break;
	          case TwoLineAndSmallFont:
	            textView.setTextSize(14);
	            textView.setPadding(0, 5, 0,5);
	            textView.setMaxEms(2);
	            //2行-小号字体
	            break;
	          default:
	            textView.setMaxLines(1);
	            //一行-正常字体
	            break;
	        }
		  textView.setGravity(Gravity.CENTER);
		}
		
		textView.setText(currItemText);
		if(unchangingPosition!=null&&unchangingPosition.contains(arrayTitles.get(position))){
			textView.setTextColor(textView.getResources().getColor(R.color.subscription_red));
		}else{
			textView.setTextColor(textView.getResources().getColor(R.color.sport_title_color));
		}
		if(position == dragPosition){
//			dragPosition = -1;
			view.setVisibility(View.INVISIBLE);
		}
		return view;
	}

	public void update(int start, int down) {
		// 获取删除的东东.
		try {
			String title = arrayTitles.get(start);
			// int drawable_id = arrayDrawables.get(start);
			arrayTitles.remove(start);// 删除该项
			arrayTitles.add(down, title);// 添加删除项

			notifyDataSetChanged();// 刷新ListView
		} catch (Exception e) {
			// TODO: handle exception
		}
	}

	public int getCount() {
		return arrayTitles.size();
	}

	public Object getItem(int position) {
		return arrayTitles.get(position);
	}

	public long getItemId(int position) {
		return position;
	}

	public void setIsHidePosition(int dragPosition) {
		this.dragPosition = dragPosition;
	}
	
	public void setUnchangingPosition(ArrayList<String> unchangingPosition){
		this.unchangingPosition = unchangingPosition;
	}
	
	public static enum IfengLineNum{
	    OneLineAndNormalFont,TwoLineAndSmallFont,TwoLineAndSmallerFont
	  }

}
