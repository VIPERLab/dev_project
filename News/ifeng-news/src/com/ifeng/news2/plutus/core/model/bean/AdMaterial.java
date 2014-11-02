package com.ifeng.news2.plutus.core.model.bean;

import java.io.Serializable;

public class AdMaterial implements Serializable {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -7252557917947030906L;
	
	private String adId = "";
	private String adStartTime = ""; 
	private String adEndTime = "";
	private String imageURL = "";
	private String text = "";
	private String shortTitle = "";
	private String longTitle = "";
	private AdAction adAction = new AdAction();
	private AdConditions adConditions = new AdConditions();
		
	public String getImageURL() {
		return imageURL;
	}

	public String getText() {
		return text;
	}

	public String getShortTitle() {
		return shortTitle;
	}

	public String getLongTitle() {
		return longTitle;
	}
	
	public String getAdId() {
		return adId;
	}

	public String getAdStartTime() {
		return adStartTime;
	}

	public String getAdEndTime() {
		return adEndTime;
	}

	public AdAction getAdAction() {
		return adAction;
	}

	public AdConditions getAdConditions() {
		return adConditions;
	}
	
	public String getValueByType(String type) {
		if (PlutusBean.TYPE_IMG.equalsIgnoreCase(type))
			return getImageURL();
		else if (PlutusBean.TYPE_TXT.equalsIgnoreCase(type))
			return getText();
		else
			return "";
	}

	@Override
	public boolean equals(Object o) {
		if (o == null || !(o instanceof AdMaterial))
			return false;
		
		boolean imageUrl = ((AdMaterial) o).getImageURL().equals(getImageURL()); 
		boolean text = ((AdMaterial) o).getText().equals(getText()); 
		boolean adid = ((AdMaterial) o).getAdId().equals(getAdId()); 
		if (text && imageUrl && adid)
			return true;
		
		return false;
	}
}
