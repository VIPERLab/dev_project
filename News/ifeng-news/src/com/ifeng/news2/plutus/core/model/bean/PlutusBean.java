package com.ifeng.news2.plutus.core.model.bean;

import java.io.Serializable;
import java.util.ArrayList;

public class PlutusBean implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -8212611040986739034L;
	public static final String TYPE_IMG = "image";
	public static final String TYPE_TXT = "text";
	public static final String TYPE_STORY = "story";

	private String adPositionId = "";
	private String adMaterialType = "";
	private int cacheTime = 0;
	private AdDescription adDescription = new AdDescription();
	private ArrayList<AdMaterial> adMaterials = new ArrayList<AdMaterial>();
	private ArrayList<AdResource> adResources = new ArrayList<AdResource>();
	
	public String getAdPositionId() {
		return adPositionId;
	}

	public int getCacheTime() {
		return cacheTime;
	}

	public AdDescription getAdDescription() {
		return adDescription;
	}

	public ArrayList<AdMaterial> getAdMaterials() {
		return adMaterials;
	}

	public ArrayList<AdResource> getAdResources() {
		return adResources;
	}

	public String getAdMaterialType() {
		return adMaterialType;
	}
	
	public ArrayList<AdMaterial> getFilteredAdMaterial() {
		ArrayList<AdMaterial> materials = new ArrayList<AdMaterial>();
		long currentTime = System.currentTimeMillis();
		for (AdMaterial material : getAdMaterials()) {
			try {
				long startTime = Long.valueOf(material.getAdStartTime()) * 1000;
				long endTime = Long.valueOf(material.getAdEndTime()) * 1000;
				if (startTime < currentTime && endTime > currentTime)
					materials.add(material);
			} catch (Exception e) {
			}
		}
		return materials;
	}
	
	@Override
	public boolean equals(Object o) {
		if (!(o instanceof PlutusBean))
			return false;
		
		boolean positionId = ((PlutusBean) o).getAdPositionId().equals(getAdPositionId());
		boolean adMaterials = ((PlutusBean) o).getAdMaterials().equals(getAdMaterials());
		if (positionId && adMaterials)
			return true;
		
		return false;
	}
}