package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;

import android.util.Log;

public class SubscriptionBean implements Serializable{
	
	private static final long serialVersionUID = -3007915060184465460L;

	private ArrayList<String> defaultOrderMenuItems = new ArrayList<String>();
	
	private HashMap<String, Channel> channels = new HashMap<String, Channel>();
	
	private String version;
	
	private ArrayList<String> defaultChannel = new ArrayList<String>();

	public ArrayList<String> getDefaultOrderMenuItems() {
		return defaultOrderMenuItems;
	}


	public void setDefaultOrderMenuItems(ArrayList<String> defaultOrderMenuItems) {
		this.defaultOrderMenuItems = defaultOrderMenuItems;
	}


	public ArrayList<String> getDefaultChannel() {
		return defaultChannel;
	}


	public void setDefaultChannel(ArrayList<String> defaultChannel) {
		this.defaultChannel = defaultChannel;
	}


	public HashMap<String, Channel> getChannels() {
		return channels;
	}


	public void setChannels(HashMap<String, Channel> channels) {
		this.channels = channels;
	}


	public String getVersion() {
		return version;
	}


	public void setVersion(String version) {
		this.version = version;
	}


	public ArrayList<String> getOtherChannelNames(){
		Set<String> set = channels.keySet();
		ArrayList<String> list = new ArrayList<String>(set);
		for(String channelName : defaultOrderMenuItems){
			if(list.contains(channelName)){
				list.remove(channelName);
			}
		}
		return list;
	}
	
	public Channel[] getchangedChannels(){
		Channel[] changedChannels = new Channel[defaultOrderMenuItems.size()];
		for(int i=defaultOrderMenuItems.size()-1; i>=1;i--){
			if(defaultOrderMenuItems.get(i).equals(defaultOrderMenuItems.get(i-1))){
				defaultOrderMenuItems.remove(i);
			}else{
				changedChannels[i] = channels.get(defaultOrderMenuItems.get(i));
			}
		}
		changedChannels[0]=channels.get(defaultOrderMenuItems.get(0));
		return changedChannels;
	}
	
	public void filterChannel(){
		for(int i=defaultOrderMenuItems.size()-1; i>=1;i--){
			if(defaultOrderMenuItems.get(i).equals(defaultOrderMenuItems.get(i-1))){
				defaultOrderMenuItems.remove(i);
			}
		}
	}
}
