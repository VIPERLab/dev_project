package com.ifeng.news2.util;

import java.util.ArrayList;

import android.content.Context;
import android.util.Log;

import com.ifeng.news2.Config;
import com.ifeng.news2.bean.CollectionItem;
import com.ifeng.news2.bean.DocBody;
import com.ifeng.news2.bean.DocUnit;
import com.ifeng.news2.bean.Meta;
import com.ifeng.news2.bean.SlideItem;
import com.ifeng.news2.commons.statistic.Statistics;
import com.qad.lang.Files;
import com.qad.util.WToast;

public class CollectionManager {
	WToast wToast;
	public static ArrayList<CollectionItem> collections;
	private ArrayList<DocUnit> docUnits;
	private ArrayList<String> documentIds;
	private ArrayList<SlideItem> slideItems;
	private ArrayList<DocUnit> allUnits;
	public Context context;
	public CollectionManager(Context context){
		this.context = context;
		wToast = new WToast(context);
		getCollections();
	}
	public void saveCollections(){
		try {
			Files.serializeObject(context.getFileStreamPath(Config.COLLECTION_DAT_NAME).getAbsolutePath(), collections);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	@SuppressWarnings("unchecked")
	public ArrayList<CollectionItem> getCollections(){
		if(collections==null){
			collections = new ArrayList<CollectionItem>();
			try {
				collections=(ArrayList<CollectionItem>) Files.deserializeObject(context.getFileStreamPath(Config.COLLECTION_DAT_NAME).getAbsolutePath());
			} catch (Exception e) {
				Log.e("tag", "collection");
				return new ArrayList<CollectionItem>();
			}
		}
		initUnitDatas();
		return collections;
	}
	public void initUnitDatas(){
		documentIds = new ArrayList<String>();
		docUnits = new ArrayList<DocUnit>();
		slideItems = new ArrayList<SlideItem>();
		allUnits = new ArrayList<DocUnit>();
		int length = collections.size()-1;
		for (int i = length; i >= 0; i--) {
			DocUnit docUnit = collections.get(i).getDocUnit();
			if ("gallery".equals(docUnit.getMeta().getType())) {
				slideItems.add(getSlideItem(docUnit));
			}else {
				docUnits.add(docUnit);
				documentIds.add(collections.get(i).getKey());
			}
			allUnits.add(docUnit);
		}
	}
	public void addCollection(DocUnit docUnit){
		if (collections!=null) {
			CollectionItem cItem = new CollectionItem();
			cItem.setKey(docUnit.getMeta().getDocumentId());
			cItem.setDocUnit(docUnit);
			collections.add(cItem);
//			Statistics.addRecord(Statistics.RECORD_COLLECT, docUnit.getMeta().getDocumentId());
			wToast.showMessage("收藏成功");
		}else {
			wToast.showMessage("收藏失败");
		}
	}
	public void addCollection(DocUnit docUnit,String position){
		if (collections!=null) {
			CollectionItem cItem = new CollectionItem();
			cItem.setKey(docUnit.getMeta().getDocumentId()+position);
			cItem.setDocUnit(docUnit);
			collections.add(cItem);
//			Statistics.addRecord(Statistics.RECORD_COLLECT, docUnit.getMeta().getDocumentId());
			wToast.showMessage("收藏成功");
		}else {
			wToast.showMessage("收藏失败");
		}
	}
	public void deleteCollection(String id){
		
		if (collections!=null) {
			for (int i = 0; i < collections.size(); i++) {
				if (collections.get(i).getKey().equals(id)) {
					collections.remove(i);
				}
			}
		}
	}
	public void cleanCollections(){
		 collections.clear();
	}
	public Boolean isCollected(String documentId){
		if (collections!=null) {
			for (int i = 0; i < collections.size(); i++) {
				if (collections.get(i).getKey().equals(documentId)) {
					return true;
				}
			}
			return false;
		}else {
			return false;
		}
	}
	public void saveSlide(SlideItem slideItem){
		DocUnit docUnit = new DocUnit();
		Meta meta = new Meta();
		DocBody docBody = new DocBody();
		docBody.setTitle(slideItem.getTitle());
		docBody.setWapurl(slideItem.getUrl());
		docBody.setText(slideItem.getDescription());
		docBody.setSource(slideItem.getImage());
		docBody.setEditTime(slideItem.getPosition());
		meta.setDocumentId(slideItem.getDocumentId());
		meta.setType("gallery");
		docUnit.setBody(docBody);
		docUnit.setMeta(meta);
		addCollection(docUnit,slideItem.getPosition());
	}
	public SlideItem getSlideItem(DocUnit docUnit){
		SlideItem slideItem = new SlideItem();
		slideItem.setPosition(docUnit.getBody().getEditTime());
		slideItem.setTitle(docUnit.getBody().getTitle());
		slideItem.setDescription(docUnit.getBody().getText());
		slideItem.setImage(docUnit.getBody().getSource());
		slideItem.setDocumentId(docUnit.getMeta().getDocumentId());
		slideItem.setUrl(docUnit.getBody().getWapurl());
		return slideItem;
	}
	public int currentSlideIndex(DocUnit docUnit){
		for (int i = 0; i < slideItems.size(); i++) {
			SlideItem slideItem  = slideItems.get(i);
			if (docUnit.getMeta().getDocumentId().equals(slideItem.getDocumentId()) && docUnit.getBody().getEditTime().equals(slideItem.getPosition())) {
				return i;
			}
		}
		return -1;
	}
	public ArrayList<DocUnit> getDocUnits(){
		return docUnits;
		
	}
	public ArrayList<String> getDocumentIds(){
		return documentIds;
	}
	public ArrayList<SlideItem> getSlideItems(){
		return slideItems;
	}
	
	public ArrayList<DocUnit> getAllUnits() {
		if (allUnits==null) {
			allUnits = new ArrayList<DocUnit>();
		}
		return allUnits;
	}
	
}
