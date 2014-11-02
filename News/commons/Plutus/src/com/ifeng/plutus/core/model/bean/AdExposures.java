package com.ifeng.plutus.core.model.bean;

import java.io.Serializable;
import java.util.ArrayList;

public class AdExposures implements Serializable {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 2711014365490100426L;
	
	private ArrayList<AdExposure> adExposure = null;

	public ArrayList<AdExposure> getAdExposure() {
		return adExposure;
	}

	public void setAdExposure(ArrayList<AdExposure> adExposure) {
		this.adExposure = adExposure;
	}
	
}
