package com.ifeng.news2.adapter;

import java.util.ArrayList;
import com.ifeng.news2.R.id;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.bean.TopicContent;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class IfengGridViewAdapter extends BaseAdapter {

	Context context;
	ArrayList<TopicContent> topicContents;
	
	public IfengGridViewAdapter(Context context, ArrayList<TopicContent> topicContents){
		this.context = context;
		this.topicContents = topicContents;
	}

	@Override
	public int getCount() {
		return topicContents.size();
	}

	@Override
	public Object getItem(int position) {
		return null;
	}

	@Override
	public long getItemId(int position) {
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		
		TopicContent topicContent = topicContents.get(position);
		View item = null;
		if (null == convertView) {
			item = LayoutInflater.from(context).inflate(layout.topic_link_module_item, null);
			TextView title = (TextView) item.findViewById(id.topic_link_module_title);
			title.setText(topicContent.getTitle());
			convertView = item;
			convertView.setTag(item);
		} else {
			convertView.getTag();
		}
		return convertView;
	}

}
