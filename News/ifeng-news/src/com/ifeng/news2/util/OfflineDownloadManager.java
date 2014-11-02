package com.ifeng.news2.util;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import android.text.TextUtils;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.DocUnit;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.bean.ListUnit;
import com.ifeng.news2.bean.ListUnits;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.SaveBackupDocUnitsUtil;
import com.ifeng.news2.util.SaveBackupUtil;
import com.qad.loader.BeanLoader;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;

/**
 * 离线下载helper
 * 
 * @author SunQuan
 *
 */
public class OfflineDownloadManager {

	private List<Channel> downloadedChannels;
	private float totalProgress = 0f;
	private float progressNum = 0f;
	private BeanLoader beanLoader = null;
	private static OfflineDownloadManager instance = null;
	private OffineManagerCallback callBack;	

	/**
	 * 判断离线下载实例是否被销毁
	 * 
	 * @return
	 */
	public static boolean isInstanceDestoryed() {
		return instance == null;
	}

	public static OfflineDownloadManager getInstance(OffineManagerCallback callBack) {
		if (isInstanceDestoryed()) {
			instance = new OfflineDownloadManager(callBack);
		}			
		return instance;
	}

	private OfflineDownloadManager(OffineManagerCallback callBack) {
		beanLoader = IfengNewsApp.getBeanLoader();
		this.callBack = callBack;
	}

	public void startPrefetch() {			
			
		//初始化离线相关信息
		initOfflineInfo();
		//开始离线下载
		downLoadChannels();
	}
		
	@SuppressWarnings("rawtypes")
	private void downLoadChannels() { 		
		//如果所有频道已经离线完成，则离线成功
		if(downloadedChannels.size()==0) {
			 downloadedSuccess();
		}
		else {
			Channel channel = downloadedChannels.remove(0);		
			  //如果频道包含焦点图
				   String url = ParamsManager.addParams(channel
					        .getPrefetchChannelUrl());
					    beanLoader.startLoading(new LoadContext<String, LoadListener, ListUnits>(
					        url, new LoadListener<ListUnits>() {
					          @Override
					          public void loadComplete(
					                                   LoadContext<?, ?, ListUnits> context) {
					            ListUnits units = (ListUnits) context.getResult();
					            SaveBackupUtil savingThread = new SaveBackupUtil(
					              (ListUnits) context.getResult());
					            savingThread.run();
					            StringBuilder builder = new StringBuilder();
					            for (ListUnit unit : units) {
					              for (ListItem item : unit.getUnitListItems()) {
					                // 增加判断条件，只离线doc类型，因为JSON专题的DocumentId不是标准类型
					                // 会造成离线失败
					                if (item.getLinks().size()>0
					                    &&(item.getLinks().get(0).getType().equals("doc")||item.getLinks().get(0).getType().equals("originalDoc"))
					                    &&!TextUtils.isEmpty(item.getFilterDocumentId())
					                    && IfengNewsApp.getMixedCacheManager().getCache(
					                      String.format(Config.DETAIL_URL,
					                        item.getDocumentId())) == null) {
					                  builder.append(item.getFilterDocumentId() + ",");
					                }
					              }
					            }
					            upgradeProgress();
					            if(instance != null && downloadedChannels != null) {
					            	//下载该频道对应的所有文章
					            	loadDetail(context, builder.toString());
					            }					       
					          }

					          @Override
					          public void loadFail(
					                               LoadContext<?, ?, ListUnits> arg0) {	
					        	//失败毁掉
					            downloadedFial();
					          }

					          @Override
					          public void postExecut(LoadContext<?, ?, ListUnits> context) {}
					        }, ListUnits.class, Parsers.newListUnitsParser(),
					        false, LoadContext.FLAG_HTTP_ONLY, false));
		}		
	}

	/**
	 * 初始化离线下载相关信息
	 */
	private void initOfflineInfo() {
		downloadedChannels = new LinkedList<Channel>();
		// 把需要离线的频道放入一个临时的集合中
		for (Channel channel : Config.CHANNELS) {
			// 不离线图片频道和獨家频道
			if (channel.getChannelName().equals("圖片")
					|| channel.getChannelName().equals("鳳凰節目")) {
				continue;
			}
			downloadedChannels.add(channel);
		}
		totalProgress = 0;
		progressNum = downloadedChannels.size() * 2;
		callBack.updateProgress((int) totalProgress);
	}

	/**
	 * 离线下载成功回调
	 */
	private void downloadedSuccess() {
		callBack.onComplete();
		destroyInstance();		
	}
	
	/**
	 * 离线下载失败
	 */
	private void downloadedFial() {
		callBack.onFail();
		destroyInstance();
	}

	/**
	 * 取消离线下载
	 * 
	 * @param isCancelOffine
	 */
	public void cancelOffline() {
		callBack.onCancel();
		destroyInstance();
	}

	/**
	 * 离线下载的回调接口
	 * 
	 * @author SunQuan
	 *
	 */
	public interface OffineManagerCallback {

		 void updateProgress(int progressPercent);

		 void onComplete();

		 void onFail();
		 
		 void onCancel();
	}
	
	//更新进度条信息
	private void upgradeProgress() {
		totalProgress ++;			
		callBack.updateProgress((int) (100*(totalProgress/progressNum)));
	}

	private void excuteComplete(LoadContext<?, ?, ?> context) {				
		String id = null;
		if (context.getResult() instanceof ListUnit) {
		  ListUnit unit = (ListUnit) context.getResult();
		  id = unit.getMeta().getId().replace("&amp;", "&");
		  if (!id.startsWith("http://"))
		    id = "http://" + id;
		} else if (context.getResult() instanceof ListUnits) {
		  ListUnits units = (ListUnits) context.getResult();
		  id = units.get(0).getMeta().getId().replace("&amp;", "&");
		} 		
	}

	
	/**
	 * 销毁实例
	 */
	private void destroyInstance() {
		if(downloadedChannels!=null) {
			downloadedChannels.clear();
			downloadedChannels = null;
		}
		instance = null;
	}

	private void loadDetail(final LoadContext<?, ?, ?> channelContext,
			String documentIds) {
		if (documentIds.length() != 0) {
			//给后台传必要参数，为了后台缓存考虑，其他参数不传
			beanLoader
					.startLoading(new LoadContext<String, LoadListener<ArrayList<DocUnit>>, ArrayList<DocUnit>>(
							ParamsManager.addSimpleParams(String.format(
									Config.DETAIL_URLS,
									documentIds.substring(0,
											documentIds.length() - 1))),
							new LoadListener<ArrayList<DocUnit>>() {

								@Override
								public void loadComplete(
										LoadContext<?, ?, ArrayList<DocUnit>> arg0) {
									//成功之后存储
									SaveBackupDocUnitsUtil savingThread = 
										new SaveBackupDocUnitsUtil( 
												arg0.getResult());
									savingThread.run();									
									excuteComplete(channelContext);
									upgradeProgress();	
									if(instance != null && downloadedChannels != null) {
										//离线下一个频道
										downLoadChannels();
									}											
								}

								@Override
								public void loadFail(
										LoadContext<?, ?, ArrayList<DocUnit>> arg0) {
										//失败回调
										downloadedFial();										
								}

								@Override
								public void postExecut(
										LoadContext<?, ?, ArrayList<DocUnit>> arg0) {
									
								}

							}, ArrayList.class, Parsers.newDocUnitsParser(),
							false, LoadContext.FLAG_HTTP_ONLY, false));
		} else {
			downloadedFial();
		}
	}
	
}