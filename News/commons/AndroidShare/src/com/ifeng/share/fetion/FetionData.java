package com.ifeng.share.fetion;

import java.io.Serializable;

import com.fetion.apis.lib.model.Contact;

public class FetionData implements Serializable{
	public static Contact[] friends;
	public FetionData(){}
	public static Contact[] getFriends() {
		return friends;
	}

	public static void setFriends(Contact[] friends) {
		FetionData.friends = friends;
	}
	
}
