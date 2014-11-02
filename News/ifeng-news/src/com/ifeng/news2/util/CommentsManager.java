package com.ifeng.news2.util;

import android.util.Log;

import android.text.TextUtils;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.bean.Comment;
import com.ifeng.news2.bean.CommentsData;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.net.HttpGetListener;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

/**
 * 评论管理类 对跳转到评论页，获取评论地址，发送评论，获取评论以及支持评论进行相关操作
 */
public class CommentsManager {

	private static final String HOT = "hot";
	private static final String ALL = "all";

	/**
	 * 跟帖页获取评论数
	 * 
	 * @param commentsUrl
	 * @param pageNo
	 * @return
	 * 
	 * @throw CommentsParameterErrorException
	 */
	private String getCommentUrl(String commentsUrl, int pageNo, String type, boolean isTopicComment) {
		if (TextUtils.isEmpty(commentsUrl)) {
			throw new CommentsParameterErrorException("获取评论参数错误");
		} else {
		  //经和后台沟通只对docUrl做encode
		  commentsUrl = URLEncoder.encode(commentsUrl);
		}
		// 根据与技术部的沟通去掉基本参数：gv、av、uid、proid、os、df、vt、screen、publishid
//		return ParamsManager.addParams(Config.URL_COMMENT + "?pagesize=20&p="
//				+ pageNo + "&docurl=" + commentsUrl + "&type=" + type);
		
		String url = Config.URL_COMMENT + 
            "?pagesize=20&p="+ pageNo + 
            "&docurl=" + commentsUrl + 
            "&type=" + type;
		if (isTopicComment) {
		  url = url + "&job=" + 9;
        }  
		return url.toString();
	}

	/**
	 * 获取支持评论地址
	 * 
	 * @param commentId
	 * @param commentsUrl
	 * @return
	 */
	private String getSupportCommentUrl(String commentId, String commentsUrl) {
		// 根据与技术部的沟通去掉基本参数：gv、av、uid、proid、os、df、vt、screen、publishid
//		return ParamsManager.addParams(Config.SUPPORT_COMMENT + "?cmtId="
//				+ commentId + "&docUrl=" + commentsUrl + "&job=up&"
//				+ System.currentTimeMillis());
	  if (TextUtils.isEmpty(commentsUrl)) {
        return null;
      } else {
        commentsUrl = URLEncoder.encode(commentsUrl);
      }  
		return Config.SUPPORT_COMMENT + 
		    "?cmtId=" + commentId +
		    "&docUrl=" + commentsUrl + 
		    "&job=up&"+ System.currentTimeMillis() + 
		    "&rt=sj";
	}

	/**
	 * 获取发送评论地址
	 * 
	 * @param quoteId
	 * @param docName
	 * @param docUrl
	 * @param content
	 * @param client_ip
	 * @param token_ip
	 * @return
	 */
	private String getSendCommentUrl(String commentId, String docName,
			String docUrl, String content, String commentsExt)
			    throws UnsupportedEncodingException {
	  if (TextUtils.isEmpty(docName)) {
	    return null;
	  } else {
	    docName = URLEncoder.encode(docName);
      }
	  if (TextUtils.isEmpty(docUrl)) {
	    return null;
	  } else {
	    docUrl = URLEncoder.encode(docUrl);
      }
	  if (TextUtils.isEmpty(content)) {
	    return null;
	  } else {
	    content = URLEncoder.encode(content);
      }
//	  String str = ParamsManager.addParams(Config.SEND_COMMENT_URL
//	    + "?quoteId=" + commentId + "&docName=" + docName + "&docUrl="
//	    + docUrl + "&content=" + content + "&client_ip=" + client_ip
//	    + "&_token_ip=" + token_ip + "&rt=sj");
	  /*
	   * 根据与技术部的沟通去掉client_ip,token_ip 参数平去掉客户端基本参数
	   * */
	  String str = Config.SEND_COMMENT_URL +
	    "?quoteId=" + commentId +
        "&docName=" + docName +
        "&docUrl=" + docUrl +
        "&client=1"+
        "&content=" + content +
        "&rt=sj"+(TextUtils.isEmpty(commentsExt)?"":"&ext3="+URLEncoder.encode(commentsExt));
	  return str;
	}

	/**
	 * 评论页获取评论内容
	 * 
	 * @param commentsUrl
	 * @param pageNo
	 * @param callBack
	 */
	public void obtainComments(String commentsUrl, int pageNo,
			LoadListener<CommentsData> listener, boolean isTopicComment) {
		try {
			IfengNewsApp
					.getBeanLoader()
					.startLoading(
							new LoadContext<String, LoadListener<CommentsData>, CommentsData>(
									getCommentUrl(commentsUrl, pageNo, ALL, isTopicComment),
									listener, CommentsData.class, Parsers
											.newCommentsParser(),
									LoadContext.FLAG_HTTP_FIRST));
		} catch (CommentsParameterErrorException e) {
			listener.loadFail(null);
		}
	}

	/**
	 * 正文页获取评论内容
	 * 
	 * @param commentsUrl
	 * @param listener
	 */
	public void obtainDetailComments(String commentsUrl,
			LoadListener<String> listener) {
		try {
			IfengNewsApp.getBeanLoader().startLoading(
					new LoadContext<String, LoadListener<String>, String>(
							getCommentUrl(commentsUrl, 1, HOT, false), listener,
							String.class, Parsers.newDetailCommentParser(),
							LoadContext.FLAG_HTTP_FIRST));
		} catch (CommentsParameterErrorException e) {
			listener.loadFail(null);
		}
	}

	/**
	 * 专题获取评论内容
	 * 
	 * @param commentsUrl
	 * @param pageNo
	 * @param callBack
	 */
	public void obtainTopicComments(String commentsUrl, LoadListener<CommentsData> listener) {
		try {
			IfengNewsApp
					.getBeanLoader()
					.startLoading(
							new LoadContext<String, LoadListener<CommentsData>, CommentsData>(
									getCommentUrl(commentsUrl, 1, HOT, true),
									listener, CommentsData.class, Parsers.newCommentsParser(),
									LoadContext.FLAG_HTTP_FIRST));
		} catch (CommentsParameterErrorException e) {
			listener.loadFail(null);
		}
	}
	
	public void sendComment(String commentId, String docName, String docUrl,
			String myCommentStr, HttpGetListener callBack) {
		myCommentStr = myCommentStr.replaceAll("<", " ").replaceAll(">", " ");
		/*
		 * 根据与技术部的沟通去掉client_ip,token_ip 参数
		 * */
//		String client_ip = GetIpAddress.getLocalIpAddress();
//		client_ip = URLEncoder.encode(client_ip);
//		String token_ip = MD5.md5s(client_ip);
		sendComments(commentId, docName, docUrl, myCommentStr, null, callBack);
	}
	
	/**
	 * 发送评论
	 * 
	 * @param sendUrl
	 * @param commentType
	 * @param callBack
	 */
	public void sendComments(String commentId, String docName, String docUrl,
			String myCommentStr ,String commentsExt, final HttpGetListener callBack) {
		try {
		    String url = getSendCommentUrl(commentId, docName, docUrl, myCommentStr, commentsExt);
		    Log.e("tag", "comment url = "+url);
		    if (null == url) {
		      callBack.loadHttpFail();
		      return;
            }
		    
		    if (null != callBack) {
		      callBack.preLoad();
            }
		    
		    IfengNewsApp.getBeanLoader().startLoading(
		      new LoadContext<String, LoadListener<String>, String>(
		          url,
		          new LoadListener<String>(){

                @Override
                public void postExecut(LoadContext<?, ?, String> context) {
                  
                }

                @Override
                public void loadComplete(LoadContext<?, ?, String> context) {
                  String result = (String)context.getResult();
                  
                  if (null == callBack) {
                    return;
                  }
                  //互动技术组 服务器只有返回1是才认为发送评论成功
                  if ("1".equals(result)) {
                    callBack.loadHttpSuccess();
                  } else {
                    callBack.loadHttpFail();;
                  }
                }

                @Override
                public void loadFail(LoadContext<?, ?, String> context) {
                  if (null != callBack) {
                    callBack.loadHttpFail();
                  }
                
                }}, String.class, Parsers
		          .newDetailCommentParser(),
		          LoadContext.FLAG_HTTP_ONLY));
	         
		} catch (Exception e) {
			callBack.loadHttpFail();
		}
	}

	/**
	 * 支持评论
	 * 
	 * @param commentId
	 * @param commentsUrl
	 * @param commentItem
	 * @param callBack
	 */
	public void supportComments(String commentsUrl, Comment commentItem,
			final HttpGetListener callBack) {
	  
	  String url = getSupportCommentUrl(commentItem.getComment_id() + "", commentsUrl); 
	 
	  if (null == url) {
	    callBack.loadHttpFail();
	    return;
      }
	  //HttpGetListener 接口里面方法执行顺序是先preLoad 后loadHttpSuccess或者loadHttpFail
	  if (null != callBack) {
        callBack.preLoad();
      }
	  
	  //根据互动技术部
      IfengNewsApp.getBeanLoader().startLoading(
        new LoadContext<String, LoadListener<String>, String>(
            url ,
            new LoadListener<String>(){

          @Override
          public void postExecut(LoadContext<?, ?, String> context) {
          }

          @Override
          public void loadComplete(LoadContext<?, ?, String> context) {
            String result = (String)context.getResult();
            
            if (null == callBack) {
              return;
            }
            //互动技术组 服务器只有返回1是才认为发送评论成功
            if ("1".equals(result)) {
              callBack.loadHttpSuccess();
            } else {
              callBack.loadHttpFail();;
            }
          }

          @Override
          public void loadFail(LoadContext<?, ?, String> context) {
            if (null != callBack) {
              callBack.loadHttpFail();
            }
          
          }}, String.class, Parsers
            .newDetailCommentParser(),
            LoadContext.FLAG_HTTP_ONLY));
	}

	/**
	 * 评论参数错误异常
	 * 
	 */
	final class CommentsParameterErrorException extends RuntimeException {

		private static final long serialVersionUID = 1L;

		public CommentsParameterErrorException(String detailMessage) {
			super(detailMessage);
		}

		public CommentsParameterErrorException() {
			super();
		}

		public CommentsParameterErrorException(String detailMessage,
				Throwable throwable) {
			super(detailMessage, throwable);
		}

		public CommentsParameterErrorException(Throwable throwable) {
			super(throwable);
		}
	}

}
