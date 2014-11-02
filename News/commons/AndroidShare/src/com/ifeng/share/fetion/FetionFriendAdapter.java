package com.ifeng.share.fetion;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.fetion.apis.lib.model.Contact;
import com.ifeng.share.R;

public class FetionFriendAdapter extends BaseAdapter{
	private LayoutInflater inflater;
	public Contact[] contacts;
	private Context context;
	public FetionFriendAdapter(Context context ,Contact[] contacts){
		this.contacts = contacts;
		this.context = context;
	}
	@Override
	public int getCount() {
		return contacts.length;
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return contacts[position];
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		if (convertView==null) {
			inflater = LayoutInflater.from(context);
			convertView = inflater.inflate(R.layout.fetion_friend_item, null);
		}
		Contact contact = contacts[position];
		TextView name = (TextView)convertView.findViewById(R.id.name);
		String localName=contact.getLocalname();
		String nickName=contact.getNickname();
		if (localName!=null && localName.length()>0) {
			name.setText(localName);
		}else if(nickName!=null && nickName.length()>0){
			name.setText(nickName);
		}else{
			name.setText(contact.getMobile());
		}
		
		return convertView;
	}
	
}
