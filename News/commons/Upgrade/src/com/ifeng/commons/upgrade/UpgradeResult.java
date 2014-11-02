package com.ifeng.commons.upgrade;

public class UpgradeResult {

	private Status atmoStatus;
	private Status groundStatus;
	private String atmoDownUrl;
	private String groundDownUrl;

	public UpgradeResult(Status atmoStatus, String atmoDownUrl,
			Status groundStatus, String groundDownUrl) {
		this.atmoStatus = atmoStatus;
		this.groundStatus = groundStatus;
		this.atmoDownUrl = atmoDownUrl;
		this.groundDownUrl = groundDownUrl;
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

	public static enum Status {
		ForceUpgrade, AdviseUpgrade, NoUpgrade
	}
}
