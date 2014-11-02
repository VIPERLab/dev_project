package com.ifeng.news2.bean;

import java.util.ArrayList;

public class ReviewUnits extends ArrayList<ReviewUnit>{
	/**
	 * 
	 */
	private static final long serialVersionUID = -8299312163952601637L;
	ArrayList<String> ids=new ArrayList<String>();
	public ArrayList<String> getIds()
	{
		ids.clear();
		for(ReviewUnit unit:this)
			for(ListItem item :unit.getBody().getItem()){
				if ("ad".equals(item.getType()))
					continue;
				if(item.getId()!=null && item.getId().length()>0)
					ids.add(item.getId());
				else if(item.getDocUnit()!=null){
					ids.add(item.getDocUnit().getMeta().getId());
				}
			}
		return ids;
	}
	
	ArrayList<DocUnit> units=new ArrayList<DocUnit>();
	public ArrayList<DocUnit> getDocUnits()
	{
		units.clear();
		for(ReviewUnit unit :this)
			for(ListItem item :unit.getBody().getItem())
			{
				if ("ad".equals(item.getType()))
					continue;
				if(item.getDocUnit()!=null)
					units.add(item.getDocUnit());
				/*else {
					units.add(DocUnit.NULL);
				}*/
			}
		return units;
	}
	ArrayList<ArrayList<Extension>> extensions=new ArrayList<ArrayList<Extension>>();
	public ArrayList<ArrayList<Extension>> getExtensions(){
		extensions.clear();
		for(ReviewUnit unit :this)
			for(ListItem item :unit.getBody().getItem()){
				extensions.add(item.getLinks());
			}
		return extensions;
	}
}
