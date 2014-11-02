package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import com.qad.form.PageEntity;

public class TopicFocusUnit implements Serializable, PageEntity {

	private static final long serialVersionUID = 5962831786944371320L;

	private ArrayList<TopicFocusItem> body = new ArrayList<TopicFocusItem>();

	private ListMeta meta = new ListMeta();

	@Override
	public List<?> getData() {
		return null;
	}

	@Override
	public int getPageSum() {
		return meta.getPageSize();
	}

	public ArrayList<TopicFocusItem> getBody() {
		return body;
	}

	public void setBody(ArrayList<TopicFocusItem> body) {
		this.body = body;
	}

	public ListMeta getMeta() {
		return meta;
	}

	public void setMeta(ListMeta meta) {
		this.meta = meta;
	}

	public void add(TopicUnit topicUnit) {
		
	}
	
	public ArrayList<DocUnit> getDocUnits(){
		ArrayList<DocUnit> units=new ArrayList<DocUnit>();
		for(TopicFocusItem item :getBody())
		{
			if(item.getDocUnit()!=null)
				units.add(item.getDocUnit());
			/*else {
				units.add(DocUnit.NULL);
			}*/
		}
		return units;
	}

}
