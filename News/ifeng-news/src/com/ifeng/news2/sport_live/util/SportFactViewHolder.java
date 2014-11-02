package com.ifeng.news2.sport_live.util;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.ifeng.news2.R.id;
import com.ifeng.news2.sport_live.entity.SportFactItem;

/**
 * @author liu_xiaoliang
 *
 */
public class SportFactViewHolder {


	/**
	 * 左侧图标
	 */
	public ImageView sportIcon;  
	/**
	 * 主持人名
	 */
	public TextView sportIconName;
	/**
	 * 节数提示语
	 */
	public TextView sportFactSignsPrompt;
	/**
	 * 节数
	 */
	public View sportFactSigns;
	/**
	 * 用户名  & 时间
	 */
	public View useModule;
	/**
	 * 用户名
	 */
	public TextView useName;
	/**
	 * 时间
	 */
	public TextView time;
	/**
	 * 标题
	 */
	public TextView title;
	/**
	 * 实况图模块
	 */
	public View sportFactIconModule;
	/**
	 * 缩略图
	 */
	public ImageView sportFactIcon;
	/**
	 * 用户 和 主持人交互内容
	 */
	public View sportLiveReplyModule;
	/**
	 * 评论模块用户名
	 */
	public TextView replyModuleName;
	/**
	 * 评论模块直播员
	 */
	public TextView replyModuleToName;
	/**
	 * 评论模块内容
	 */
	public TextView replyModuleContent;
	/**
	 * 评论模块时间
	 */
	public TextView replyModuleTime;
	/**
	 * 评论模块aa 对  bb 
	 */
	public TextView replyModuleTo;
	/**
	 * 评论模块 说
	 */
	public TextView replyModuleSay;
	/**
	 * 数据 
	 */
	public SportFactItem item;
	
	public static SportFactViewHolder create(View convertView) {
		SportFactViewHolder holder = new SportFactViewHolder();
		
		holder.sportIcon = (ImageView) convertView.findViewById(id.sport_icon);                  //左侧图标
		holder.sportIconName = (TextView) convertView.findViewById(id.sport_icon_name);          //主持人名
		
		holder.sportFactSigns = convertView.findViewById(id.sport_signs);                        //节数
		holder.sportFactSignsPrompt = (TextView) convertView.findViewById(id.sprot_fact_signs_prompt);  //节数提示语
		
		holder.title = (TextView) convertView.findViewById(id.sport_title);                      //标题
		
		holder.sportFactIconModule = convertView.findViewById(id.sport_fact_icon_module);        //实况图模块
		holder.sportFactIcon = (ImageView) convertView.findViewById(id.sport_fact_icon);         //缩略图
		
		holder.sportLiveReplyModule = convertView.findViewById(id.sport_live_reply_module);      //用户 和 主持人交互内容
		holder.replyModuleName = (TextView) convertView.findViewById(id.name);                   //评论模块用户名
		holder.replyModuleToName = (TextView) convertView.findViewById(id.to_name);              //评论模块直播员
		holder.replyModuleContent = (TextView) convertView.findViewById(id.content);             //评论模块内容
		holder.replyModuleTime = (TextView) convertView.findViewById(id.time);                   //评论模块时间
		holder.replyModuleTo =  (TextView) convertView.findViewById(id.to);                      //评论模块 aa 对   bb
		holder.replyModuleSay =  (TextView) convertView.findViewById(id.say);                    //评论模块 说
		
		return holder;
	}

}
