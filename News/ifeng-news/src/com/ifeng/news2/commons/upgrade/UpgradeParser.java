package com.ifeng.news2.commons.upgrade;

/**
 * 解析http返回结果
 * 
 * @author 13leaf
 * 
 */
public interface UpgradeParser {

	/**
	 * 
	 * @param content
	 * @param appVersion
	 * @param atmoVersion
	 *            可为空
	 * @return
	 * @throws HandlerException
	 */
	UpgradeResult parse(String content, Version appVersion, Version atmoVersion,boolean forceUpgrade)
			throws HandlerException;
}
