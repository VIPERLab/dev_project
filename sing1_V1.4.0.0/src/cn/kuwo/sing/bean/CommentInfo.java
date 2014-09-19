/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.bean;

import java.io.Serializable;
import java.util.List;

/**
 * @Package cn.kuwo.sing.bean
 *
 * @Date 2012-12-18, 下午4:42:10, 2012
 *
 * @Author wangming
 * 评论实体
 * 参数意义：
	total:总页数
	current：当前是第几页（1-n）
	pagesize：每页的条数。
	comment.vip:评论者是否为vip
	comment.time：发表时间
	comment.fid：发表人id
	comment.fname:发表人名称
	comment.fpic:发表人头像
	comment.lid：此条评论id
	comment.block：不用管
	comment.content：评论内容
 *
 */
public class CommentInfo implements Serializable {
	public int total; 
	public int current;
	public int pagesize = 30;
	public List<Comment> commentList;
}
