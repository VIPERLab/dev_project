package com.ifeng.news2.commons.upgrade;

public class UpgradeResult {

	private Status atmoStatus;
	private Status groundStatus;
	private String atmoDownUrl;
	private String groundDownUrl;
	private String tips;

	public UpgradeResult(Status atmoStatus, String atmoDownUrl,
			Status groundStatus, String groundDownUrl, String tips) {
		this.atmoStatus = atmoStatus;
		this.groundStatus = groundStatus;
		this.atmoDownUrl = atmoDownUrl;
		this.groundDownUrl = groundDownUrl;
		this.tips = tips;
	}

	public Status getStatus(UpgradeType type) {
		if (type == UpgradeType.Atmosphere)
			return atmoStatus;
		else if (type == UpgradeType.Ground)
			return groundStatus;
		else
			return null;
	}

	public String getDownUrl(UpgradeType type) {
		if (type == UpgradeType.Atmosphere)
			return atmoDownUrl;
		else if (type == UpgradeType.Ground)
			return groundDownUrl;
		else
			return null;
	}
	
	public String getDownloadTips() {
		return tips;
	}

	public static enum Status {
		ForceUpgrade, AdviseUpgrade, NoUpgrade
	}
}
