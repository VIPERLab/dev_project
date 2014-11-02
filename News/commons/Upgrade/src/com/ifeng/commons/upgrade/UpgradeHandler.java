package com.ifeng.commons.upgrade;

/**
 * @author 13leaf
 * 
 */
public interface UpgradeHandler {
	void handle(UpgradeResult result, UpgradeManager manager);
	/**
	 * 处理升级异常。
	 * @param manager
	 * @param exception 所产生的异常
	 */
	void handleError(UpgradeManager manager,Exception exception);
}
