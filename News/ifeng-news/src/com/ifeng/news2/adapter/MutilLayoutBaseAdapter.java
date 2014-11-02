package com.ifeng.news2.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import com.qad.view.PageListView.PageAdapter;
import java.util.List;

/**
 * @author liu_xiaoliang
 * 多布局Base适配器
 */
public abstract class MutilLayoutBaseAdapter<T> extends BaseAdapter implements PageAdapter<List<T>> {

  protected int[] resLayout;

  protected List<T> items;
  protected Context context;

  public LayoutInflater inflater;

  public MutilLayoutBaseAdapter(Context context) {
    this.context = context;
    inflater = LayoutInflater.from(context);
  }

  @Override
  public int getCount() {
    return items.size();
  }

  @Override
  public Object getItem(int position) {
    return items.get(position);
  }

  @Override
  public long getItemId(int position) {
    return position;
  }

  @Override
  public int getItemViewType(int position){
    return getItemType(position);
  }

  @Override
  public int getViewTypeCount() {
    return resLayout.length;
  }

  @Override
  public View getView(int position, View convertView, ViewGroup parent) {
    Object viewHolder = null;
    if (null == convertView) {
      convertView = getLayoutById(resLayout[getItemViewType(position)]); 
      viewHolder = getViewHoler(position, convertView);
      convertView.setTag(viewHolder);
    } else {
      viewHolder = convertView.getTag();
    }
    bindData(position, viewHolder);
    return convertView;
  }

  public abstract int getItemType(int position);
  public abstract Object getViewHoler(int position, View convertView);
  public abstract View getLayoutById(int resLayout);
  public abstract void bindData(int position, Object viewHolder);

  @Override
  public void addPage(List<T> pageContent) {
    if (pageContent instanceof List) {
      List<T> list = (List<T>) pageContent;
      if (items != null) {
        items.addAll(list);
        notifyDataSetChanged();
      }
    }    
  }

  public List<T> getItems() {
    return items;
  }

  public void setItems(List<T> items) {
    this.items = items;
  }

}
