package com.ifeng.news2.bean;

import java.io.Serializable;

import com.ifeng.news2.util.DateUtil;
import com.ifeng.news2.util.ReadUtil;


/** 
 * @author SunQuan: 
 * @version 创建时间：2013-8-22 下午1:11:15 
 * 类说明 
 */

public class PhotoAndTextLiveItemBean implements Serializable{

	private static final long serialVersionUID = -6347817708159891026L;
	private String lr_id = "";
	//标题
	private String title = "";
	//内容
	private String content = "";
	//标题链接地址
	private String title_link = "";
	//创建时间
	private String create_date = "";
	//聊天项ID
	private String id = "";
	
	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	private PhotoAndTextLiveItemImg img;
	
	private PhotoAndTextLiveItemVideo video;

	public String getLr_id() {
		return lr_id;
	}

	public void setLr_id(String lr_id) {
		this.lr_id = lr_id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public String getTitle_link() {
		return title_link;
	}

	public void setTitle_link(String title_link) {
		this.title_link = title_link;
	}

	public String getCreate_date() {		
		return DateUtil.getTimeForDirectSeeding(create_date);
	}

	public void setCreate_date(String create_date) {
		this.create_date = create_date;
	}

	public PhotoAndTextLiveItemImg getImg() {
		return img;
	}

	public void setImg(PhotoAndTextLiveItemImg img) {
		this.img = img;
	}

	public PhotoAndTextLiveItemVideo getVideo() {
		return video;
	}

	public void setVideo(PhotoAndTextLiveItemVideo video) {
		this.video = video;
	}
	
	public int getTitleColor() {
		return ReadUtil.isReaded(id) ? 0xff868686
				: 0xff2b5470;
	}
	
}
