package com.ifeng.news2.bean;

import android.text.TextUtils;
import com.qad.form.PageEntity;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class ListUnit implements Serializable, PageEntity {

	private static final long serialVersionUID = 5685883013985174935L;

	private ListMeta meta = new ListMeta();

	private ListItems body = new ListItems();

	// @gm, for accessing head data of topic unit
	private HeadUnit head = new HeadUnit();
	
	public ArrayList<String> getIds() {
		ArrayList<String> ids = new ArrayList<String>();
		if (null == body) {
          return ids;
        }
		for (ListItem item : body.getItem()) {
			if (null == item || !"doc".equals(item.getType()))
				continue;
			//If id is empty, set an invalid value. Details page will fail to load. Avoid application crashes
			if (TextUtils.isEmpty(item.getDocumentId())) {
				item.setDocumentId("id is null");
			}
			ids.add(item.getDocumentId());
		}
		return ids;
	}
	
	public ArrayList<DocUnit> getDocUnits(){
		ArrayList<DocUnit> units=new ArrayList<DocUnit>();
		for(ListItem item :getUnitListItems())
		{
			if (!"doc".equals(item.getType()))
				continue;
			if(item.getDocUnit()!=null)
				units.add(item.getDocUnit());
			/*else {
				units.add(DocUnit.NULL);
			}*/
		}
		return units;
	}
	
	public ArrayList<ListItem> getWidgetItems(){
		ArrayList<ListItem> items =new ArrayList<ListItem>();
		for(ListItem item :getUnitListItems())
		{
			String linkType = item.getLinkType(); 
			if(null == linkType){
				continue ; 
			}else{
				if ("doc".equals(linkType) || "topic2".equals(linkType) ||
						"slide".equals(linkType) ||"plot".equals(linkType)){
					items.add(item);
				}
			}
		}
		return items;
	}
	

	public ListMeta getMeta() {
		return meta;
	}

	public void setMeta(ListMeta meta) {
		this.meta = meta;
	}

	public ArrayList<ListItem> getUnitListItems() {
	  return body.getItem();
	}
	
	public ListItems body() {
      return body;
    }

	public void setBody(ListItems body) {
	  if (null == body) {
	    this.body = new ListItems();
      } else {
        this.body = body;
      }
	}

	@Override
	public int getPageSum() {
		return meta.getPageSize();
	}

	@Override
	public List<?> getData() {
		return getUnitListItems();
	}

	public HeadUnit getHead() {
		return head;
	}

	public void setHead(HeadUnit head) {
		this.head = head;
	}
}
