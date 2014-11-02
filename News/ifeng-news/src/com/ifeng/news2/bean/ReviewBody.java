package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;

public class ReviewBody implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 5720658471566671386L;
	private ArrayList<ListItem> item = new ArrayList<ListItem>();

	
	public ArrayList<String> getIds() {
		ArrayList<String> ids = new ArrayList<String>();
		for (ListItem it : item) {
			ids.add(it.getId());
		}
		return ids;
	}
	
	public ArrayList<DocUnit> getDocUnits(){
		ArrayList<DocUnit> units=new ArrayList<DocUnit>();
		for(ListItem it :getItem())
		{
			if(it.getDocUnit()!=null)
				units.add(it.getDocUnit());
			/*else {
				units.add(DocUnit.NULL);
			}*/
		}
		return units;
	}

	public ArrayList<ListItem> getItem() {
		return item;
	}

	public void setItem(ArrayList<ListItem> item) {
		this.item = item;
	}

	
	
}
