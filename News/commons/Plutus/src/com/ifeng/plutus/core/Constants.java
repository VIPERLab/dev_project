package com.ifeng.plutus.core;

public class Constants {

	public static final String DEFAULT_URL = "http://i.ifeng.com/ClientApiTest?";
	public static final String DEFAULT_STATISTIC_URL = "http://online.3g.ifeng.com/ad/adExposure.php";
	public static final String DEFAULT_CACHE_PATH = "/mnt/sdcard/";
	
	public static final String SELECT = "select";
	public static final String SELE_PRELOAD = "preLoad";
	public static final String SELE_ADPOSITION = "adPosition";
	public static final String SELE_THUMB = "thumb";
	public static final String SELE_EXPOSURE = "exposure";
	
	public static final String KEY_POSITION = "position";
	public static final String KEY_SUFFIX = "suffix";
	public static final String KEY_IMAGE = "imgUrl";
	public static final String KEY_HEIGHT = "height";
	
	/**
	 * ERROR:<br>
	 * &emsp;{@link com.ifeng.plutus.core.PlutusCoreManager.ERROR#ERROR_MISSING_ARG ERROR_MISSING_ARG}<br>
	 * &emsp;{@link com.ifeng.plutus.core.PlutusCoreManager.ERROR#ERROR_MISSING_SELECT ERROR_MISSING_SELECT}<br>
	 * &emsp;{@link com.ifeng.plutus.core.PlutusCoreManager.ERROR#ERROR_CONNECTION ERROR_CONNECTION}<br>
	 * &emsp;{@link com.ifeng.plutus.core.PlutusCoreManager.ERROR#ERROR_SELECT_NOT_FOUND ERROR_SELECT_NOT_FOUND}<br>
	 * &emsp;{@link com.ifeng.plutus.core.PlutusCoreManager.ERROR#ERROR_EXECUTION ERROR_EXECUTION}
	 * @author gao_miao
	 *
	 */
	public enum ERROR {
		/**
		 * Illegal Augument
		 */
		ERROR_MISSING_ARG,
		/**
		 * Illegal select augument
		 */
		ERROR_MISSING_SELECT,
		/**
		 * Error cause by net connection
		 */
		ERROR_CONNECTION,
		/**
		 * Corresponding hanlder not found
		 */
		ERROR_SELECT_NOT_FOUND,
		/**
		 * Error caused by executor
		 */
		ERROR_EXECUTION;
	}
}
