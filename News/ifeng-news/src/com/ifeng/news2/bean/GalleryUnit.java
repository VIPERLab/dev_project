package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;

public class GalleryUnit implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -275060767817845402L;
	private Meta meta = new Meta();
	private ArrayList<SlideUnit> body = new ArrayList<SlideUnit>();
	
	private ArrayList<SlideItem> slides2Cache;
	
	public ArrayList<SlideBody> getSlides() {
		ArrayList<SlideBody> slides=new ArrayList<SlideBody>();
		for(SlideUnit unit:body)
		{
			slides.add(unit.getBody());
		}
		return slides;
	}
	
	public ArrayList<SlideItem> getSlides2()
	{
		if(slides2Cache==null){
			ArrayList<SlideItem> items=new ArrayList<SlideItem>();
			for(SlideUnit unit : body){
				int slideSize = unit.getBody().getSlides().size();
				if(0 == slideSize) {
					continue; //unit.getBody().getSlides().size()==0) continue;
				}
				 ArrayList<SlideItem> slideItems = unit.getBody().getSlides();
				 // set bound to first and last item
				 slideItems.get(0).setBound(true);
				 slideItems.get(slideSize - 1).setBound(true);
//				unit.getBody().getSlides().get(0).setBound(true);
//				unit.getBody().getSlides().get(unit.getBody().getSlides().size()-1).setBound(true);
				int no=0;
				String sizeString = String.valueOf(slideSize);
				String comments = unit.getBody().getComments();
				String title = unit.getBody().getTitle();
				String url = unit.getBody().getUrl();
				String docId = unit.getMeta().getDocumentId();
				String commentUrl = unit.getBody().getCommentsUrl();
				String shareUrl =  unit.getBody().getShareurl();
				String id = unit.getMeta().getId();
				for(SlideItem item : slideItems){
					item.setComments(comments);
					item.setTitle(title);
					item.setPosition(++no + "/" +sizeString);
					item.setCommentsUrl(url);
					item.setUrl(url);
					item.setShareurl(shareUrl);
					item.setDocumentId(docId);
					item.setId(id);
					items.add(item);
				}
			}
			slides2Cache=items;
		}
		return slides2Cache;
	}
	
	public int getGlobalPosition(int position)
	{
		int start=0;
		for(int i=0;i<position;i++){
			SlideUnit unit=body.get(i);
			start+=unit.getBody().getSlides().size();
		}
		return start;
	}

	public Meta getMeta() {
		return meta;
	}

	public void setMeta(Meta meta) {
		this.meta = meta;
	}

	public ArrayList<SlideUnit> getBody() {
		return body;
	}

	public void setBody(ArrayList<SlideUnit> body) {
		this.body = body;
	}
}
