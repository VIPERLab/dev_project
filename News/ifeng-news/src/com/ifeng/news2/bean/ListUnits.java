package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import com.qad.form.PageEntity;

public class ListUnits extends ArrayList<ListUnit> implements Serializable, PageEntity{

	/**
	 * 
	 */
	private static final long serialVersionUID = -5857980617619573115L;

	ArrayList<String> ids=new ArrayList<String>();
	public ArrayList<String> getIds()
	{
		/*
		 * TODO
		 * 空指针异常 ids可能为空
		 */
		if(ids==null){
			ids=new ArrayList<String>();
		}else{
			ids.clear();
		}
		for(ListUnit unit:this)
			for(ListItem item :unit.getUnitListItems())
			{
				if (!"doc".equals(item.getType()))
					continue;
				if(item.getDocumentId()!=null && item.getDocumentId().length()>0)
					ids.add(item.getDocumentId());
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
		for(ListUnit unit :this)
			units.addAll(unit.getDocUnits());
		return units;
	}
	
	public ArrayList<ListItem> getWidgetItems()
	{
		ListUnit unit = this.get(0);
		if(unit != null){
			return unit.getWidgetItems();
		}
		return null;
	} 
	
	ArrayList<ArrayList<Extension>> extensions=new ArrayList<ArrayList<Extension>>();
	public ArrayList<ArrayList<Extension>> getExtensions(){
		extensions.clear();
		for(ListUnit unit :this)
			for(ListItem item :unit.getUnitListItems()){
				extensions.add(item.getLinks());
			}
		return extensions;
	}
	@Override
	public int getPageSum() {
		return this.get(0).getMeta().getPageSize();
	}
	/*
	 * V4.0.6版本频道接口与IOS作统一处理
	 * 1.android2GList全部替换为iosNews
	 * 2.首页列表与头图列表中的id参数，SYDT10，SYLB10位置做调换，并可以只写一个aid=
	 * */
	@Override
	public List<?> getData() {
	    //V4.0.6之后第一个位置为列表数据，第二个位置为焦点图位置
		return this.get(0).getUnitListItems();
	}
}
