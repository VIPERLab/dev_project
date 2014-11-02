package com.ifeng.news2.adapter;

import android.content.Context;
import android.view.View;
import com.ifeng.news2.bean.TopicSubject;
import com.ifeng.news2.util.TopicDetailUtil;
import com.ifeng.news2.util.TopicDetailViewHolder;
import java.util.ArrayList;

/**
 * @author liu_xiaoliang
 * 动态专题adapter
 */
public class TopicDetailAdapter extends MutilLayoutBaseAdapter<TopicSubject> {

  private Context context;
  private int count;
  
  public TopicDetailAdapter(Context context) {
    super(context);
    this.context = context;
    this.resLayout = TopicDetailUtil.layouts;
  }

  @Override
  public int getCount() {
    count = TopicDetailUtil.resetCount((ArrayList<TopicSubject>) items);
    return count;
  }

  @Override
  public Object getItem(int position) {
    return TopicDetailUtil.getTopicItem(position, (ArrayList<TopicSubject>) items);
  }
  
  @Override
  public int getItemType(int position) {
    return TopicDetailUtil.getResLayoutPositon(((TopicSubject)getItem(position)));
  }

  @Override
  public TopicDetailViewHolder getViewHoler(int position, View convertView) {
    return TopicDetailUtil.getTopicHolder(((TopicSubject)getItem(position)), convertView);
  }

  @Override
  public View getLayoutById(int resLayout) {
    return inflater.inflate(resLayout, null);
  }

  @Override
  public void bindData(int position, Object viewHolder) {
    TopicDetailUtil.bindData(context, position, ((TopicSubject)getItem(position)), viewHolder);
  }
  
}
