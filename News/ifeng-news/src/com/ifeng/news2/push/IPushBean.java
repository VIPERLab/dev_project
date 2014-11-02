package com.ifeng.news2.push;

import java.io.Serializable;

public class IPushBean implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 7767079061445515890L;
	
	private int feedback;
	private int styleId;
	private String content;
	private String title;
	private int notifyType; 
	private int delayPopup;
	private Extra extra;
	
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public int getNotifyType() {
		return notifyType;
	}
	public void setNotifyType(int notifyType) {
		this.notifyType = notifyType;
	}
	public int getDelayPopup() {
		return delayPopup;
	}
	public void setDelayPopup(int delayPopup) {
		this.delayPopup = delayPopup;
	}
	public int getFeedback() {
		return feedback;
	}
	public void setFeedback(int feedback) {
		this.feedback = feedback;
	}
	public int getStyleId() {
		return styleId;
	}
	public void setStyleId(int styleId) {
		this.styleId = styleId;
	}
	
	/**
	 * @return the extra
	 */
	public Extra getExtra() {
		return extra;
	}
	/**
	 * @param extra the extra to set
	 */
	public void setExtra(Extra extra) {
		this.extra = extra;
	}

	class Extra {
		private String id;
		private String type;
		private String sound;
		private String aid;
		
		public String getAid() {
			return aid;
		}
		public void setAid(String aid) {
			this.aid = aid;
		}
		public String getId() {
			return id;
		}
		public void setId(String id) {
			this.id = id;
		}
		public String getType() {
			return type;
		}
		public void setType(String type) {
			this.type = type;
		}
		/**
		 * @return the sound
		 */
		public String getSound() {
			return sound;
		}
		/**
		 * @param sound the sound to set
		 */
		public void setSound(String sound) {
			this.sound = sound;
		}
		
	}
}
