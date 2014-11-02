package com.ifeng.news2;

import com.ifeng.news2.bean.SurveyHttpResult;
import java.text.ParseException;
import java.util.ArrayList;
import android.text.TextUtils;
import com.google.myjson.Gson;
import com.google.myjson.JsonArray;
import com.google.myjson.JsonElement;
import com.google.myjson.JsonObject;
import com.google.myjson.JsonParser;
import com.ifeng.news2.bean.CommentsData;
import com.ifeng.news2.bean.DocBody;
import com.ifeng.news2.bean.DocUnit;
import com.ifeng.news2.bean.GalleryUnit;
import com.ifeng.news2.bean.HistoryMessageUnit;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.bean.ListUnit;
import com.ifeng.news2.bean.ListUnits;
import com.ifeng.news2.bean.PhotoAndTextLiveListUnit;
import com.ifeng.news2.bean.PhotoAndTextLiveTitleBean;
import com.ifeng.news2.bean.ReviewUnit;
import com.ifeng.news2.bean.SlideBody;
import com.ifeng.news2.bean.SlideUnit;
import com.ifeng.news2.bean.SubscriptionBean;
import com.ifeng.news2.bean.SurveyUnit;
import com.ifeng.news2.bean.TopicDetailUnits;
import com.ifeng.news2.bean.TopicUnit;
import com.ifeng.news2.bean.VideoDetailBean;
import com.ifeng.news2.bean.VideoRelativeBean;
import com.ifeng.news2.bean.VideoListUnit;
import com.ifeng.news2.bean.WeatherBeans;
import com.ifeng.news2.plot_module.bean.PlotTopicUnit;
import com.ifeng.news2.push.IPushBean;
import com.ifeng.news2.sport_live.entity.MatchInfo;
import com.ifeng.news2.sport_live.entity.Replyer;
import com.ifeng.news2.sport_live.entity.ReportInfo;
import com.ifeng.news2.sport_live.entity.SportCommentUnit;
import com.ifeng.news2.sport_live.entity.SportFactUnit;
import com.ifeng.news2.vote.entity.VoteData;
import com.ifeng.news2.vote.entity.VoteResult;
import com.qad.loader.callable.Parser;

public class Parsers {

	private static class GsonParser<T> implements Parser<T> {
		Gson gson = new Gson();
		Class<? extends T> clazz;

		GsonParser(Class<? extends T> beanClass) {
			clazz = beanClass;
		}

		@Override
		public T parse(String s) throws ParseException {
			try {
				return gson.fromJson(s, clazz);
			} catch (Exception e) {
				e.printStackTrace();
				throw new ParseException(e.getMessage(), 0);
			}
		}
	}

	private static class SmartDocUnitParser implements Parser<DocUnit> {
		@Override
		public DocUnit parse(String s) throws ParseException {
			try {
				Gson gson = new Gson();
				DocUnit unit = gson.fromJson(s, DocUnit.class);
				unit.getBody().setImgJson().setExtSlidesJson().setVideoJson().setLiveStreamJson();
				return unit;
			} catch (Exception e) {
				e.printStackTrace();
				throw new ParseException(e.getMessage(), 0);
			}
		}
	}
	
	private static class IPushBeanParser implements Parser<IPushBean> {

		@Override
		public IPushBean parse(String s) throws ParseException {
			try {
				Gson gson = new Gson();
				return gson.fromJson(s, IPushBean.class);
			} catch (Exception e) {
				e.printStackTrace();
				throw new ParseException(e.getMessage(), 0);
			}
		}
	}
	
	
	private static class DocUnitsParser  implements Parser<ArrayList<DocUnit>> {
		
		@Override
		public ArrayList<DocUnit> parse(String s) throws ParseException {
			try {
				SmartDocUnitParser smartDocParser = new SmartDocUnitParser();				
				JsonParser parser = new JsonParser();
				ArrayList<DocUnit> list = new ArrayList<DocUnit>();
				for (JsonElement element : parser.parse(s).getAsJsonArray()) {
					list.add(smartDocParser.parse(element.toString()));
				}
				return list;
			} catch (Exception e) {
				e.printStackTrace();
				throw new ParseException(e.getMessage(), 0);
			}
		}
	}
	
	/**
	 * 獨家频道的解析
	 * 
	 * @author SunQuan
	 *
	 */
	private static class SmartListUnitsParserForExecusive implements Parser<ListUnits> {

		@Override
		public ListUnits parse(String s) throws ParseException {
			ListUnit unit = new SmartListUnitParser().parse(s);
			ListUnits units = new ListUnits();
			units.add(unit);
			return units;
		}
		
	}

	private static class SmartListUnitParser implements Parser<ListUnit> {
		@Override
		public ListUnit parse(String s) throws ParseException {
			try {
				JsonParser parser = new JsonParser();
				JsonElement element = parser.parse(s);
				JsonObject object = null;
				if (element.isJsonObject())
					object = element.getAsJsonObject();
				else if (element.isJsonArray())
					object = element.getAsJsonArray().get(0).getAsJsonObject();
				else if (element.isJsonNull())
					return new ListUnit();
				return parseListUnit(object);
			} catch (Exception e) {
				e.printStackTrace();
				throw new ParseException(e.getMessage(), 0);
			}
		}
		
		public ListUnit parseListUnit(JsonObject object) throws Exception {
			Gson gson = new Gson();
			ListUnit unit = new ListUnit();
			if (object.has("doc")) {
				unit = gson.fromJson(object.get("list"), ListUnit.class);
				JsonArray array = object.get("doc").getAsJsonArray();
				for (int i = 0; i < unit.getUnitListItems().size() && i < array.size(); i++) {
					ListItem item = unit.getUnitListItems().get(i);
					DocUnit docUnit = gson
							.fromJson(array.get(i), DocUnit.class);
					DocBody data = docUnit.getBody();
					data.setEditTime(item.getEditTime());
					data.setIntroduction(item.getIntroduction());
					if (TextUtils.isEmpty(data.getTitle()))
						data.setTitle(item.getTitle());
					data.setSource(item.getSource());// 填充引用
					item.setDocUnit(docUnit);
					item.setDocumentId(docUnit.getMeta().getDocumentId());
					item.setId(docUnit.getMeta().getId());
				}
			} else
				unit = gson.fromJson(object, ListUnit.class);
			return unit;
		}
	}
	

	/**
	 * @author liu_xiaoliang 体育直播实况数据解析器
	 */
	private static class SportLiveFactUnitParser implements
			Parser<SportFactUnit> {
		@Override
		public SportFactUnit parse(String s) throws ParseException {
			try {
				JsonParser parser = new JsonParser();
				JsonElement element = parser.parse(s);
				JsonObject object = null;
				if (element.isJsonObject())
					object = element.getAsJsonObject();
				else if (element.isJsonArray())
					object = element.getAsJsonArray().get(0).getAsJsonObject();
				else if (element.isJsonNull())
					return new SportFactUnit();
				return parseListUnit(object);
			} catch (Exception e) {
				e.printStackTrace();
				throw new ParseException(e.getMessage(), 0);
			}
		}

		public SportFactUnit parseListUnit(JsonObject object) throws Exception {
			Gson gson = new Gson();
			SportFactUnit unit = new SportFactUnit();
			unit = gson.fromJson(object, SportFactUnit.class);
			return unit;
		}
	}

	private static class SmartListUnitsParser implements Parser<ListUnits> {
		SmartListUnitParser unitParser = new SmartListUnitParser();

		@Override
		public ListUnits parse(String s) throws ParseException {
			try {
				JsonParser parser = new JsonParser();
				JsonArray array = parser.parse(s).getAsJsonArray();
				ListUnits units = new ListUnits();
				for (int i = 0; i < array.size(); i++)
					units.add(unitParser.parseListUnit(array.get(i)
							.getAsJsonObject()));
				return units;
			} catch (Exception e) {				
				throw new ParseException(e.getMessage(), 0);
			}
		}
	}
	
	
	private static class WeatherBeansParser implements Parser<WeatherBeans> {

		@Override
		public WeatherBeans parse(String s) throws ParseException {
			try {
				Gson gson = new Gson();				
				WeatherBeans weatherBeans = gson.fromJson(s, WeatherBeans.class);
				return weatherBeans;
			} catch (Exception e) {
				e.printStackTrace();
				throw new ParseException(e.getMessage(), 0);
			}
		}
	}

	private static class SmartTopicUnitParser implements Parser<TopicUnit> {
		@Override
		public TopicUnit parse(String s) throws ParseException {
			try {
				JsonParser parser = new JsonParser();
				JsonElement element = parser.parse(s);
				JsonObject object = null;
				if (element.isJsonObject())
					object = element.getAsJsonObject();
				else if (element.isJsonNull())
					return new TopicUnit();
				return parseTopicUnit(object);
			} catch (Exception e) {
				e.printStackTrace();
				throw new ParseException(e.getMessage(), 0);
			}
		}

		public TopicUnit parseTopicUnit(JsonObject object) throws Exception {
			Gson gson = new Gson();
			TopicUnit unit = new TopicUnit();
			unit = gson.fromJson(object, TopicUnit.class);
			return unit;
		}
	}

	private static class SmartReviewUnitParser implements Parser<ReviewUnit> {
		@Override
		public ReviewUnit parse(String s) throws ParseException {
			try {
				JsonParser parser = new JsonParser();
				JsonElement element = parser.parse(s);
				JsonObject object = null;
				if (element.isJsonArray()) {
					JsonArray array = parser.parse(s).getAsJsonArray();
					object = array.get(0).getAsJsonObject();
				} else if (element.isJsonNull())
					return new ReviewUnit();
				return parseReviewUnit(object);
			} catch (Exception e) {
				e.printStackTrace();
				throw new ParseException(e.getMessage(), 0);
			}
		}

		public ReviewUnit parseReviewUnit(JsonObject object) throws Exception {
			Gson gson = new Gson();
			ReviewUnit unit = new ReviewUnit();
			unit = gson.fromJson(object, ReviewUnit.class);
			return unit;
		}
	}

	public static HistoryMessageUnit parseHistoryMessageUnit(JsonObject object)
			throws Exception {
		Gson gson = new Gson();
		HistoryMessageUnit unit = new HistoryMessageUnit();
		unit = gson.fromJson(object, HistoryMessageUnit.class);
		return unit;
	}

	private static class SmartHistoryMessageUnitParser implements
			Parser<HistoryMessageUnit> {
		@Override
		public HistoryMessageUnit parse(String s) throws ParseException {
			try {
				JsonParser parser = new JsonParser();
				JsonElement element = parser.parse(s);
				JsonObject object = null;
				if (element.isJsonObject()) {
					object = element.getAsJsonObject();
				} else if (element.isJsonNull()) {
					return new HistoryMessageUnit();
				}
				return parseHistoryMessageUnit(object);
			} catch (Exception e) {
				e.printStackTrace();
				throw new ParseException(e.getMessage(), 0);
			}
		}
	}

	/**
	 * 专题详情页解析
	 * 
	 * @author Administrator
	 * 
	 */
	private static class TopicDetailParser implements Parser<TopicDetailUnits> {
		@Override
		public TopicDetailUnits parse(String s) throws ParseException {
			try {
				JsonParser parser = new JsonParser();
				JsonElement element = parser.parse(s);
				JsonObject object = null;
				if (element != null) {
					object = element.getAsJsonObject();
				} else {
					return new TopicDetailUnits();
				}
				return parseTopicDetail(object);
			} catch (Exception e) {
				throw new ParseException(e.getMessage(), 0);
			}
		}

		public TopicDetailUnits parseTopicDetail(JsonObject object) {
			try {
				Gson gson = new Gson();
				TopicDetailUnits topicDetailUnits = new TopicDetailUnits();
				topicDetailUnits = gson
						.fromJson(object, TopicDetailUnits.class);
				return topicDetailUnits;
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}
	}

	
    /**
     * @author liu_xiaoliang
     * 策划专题解析器
     */
    private static class PlotTopicParser implements Parser<PlotTopicUnit> {
        @Override
        public PlotTopicUnit parse(String s) throws ParseException {
            try {
                JsonParser parser = new JsonParser();
                JsonElement element = parser.parse(s);
                JsonObject object = null;
                if (element != null) {
                    object = element.getAsJsonObject();
                } else {
                    return new PlotTopicUnit();
                }
                return parsePlotTopicDetail(object);
            } catch (Exception e) {
                throw new ParseException(e.getMessage(), 0);
            }
        }

        public PlotTopicUnit parsePlotTopicDetail(JsonObject object) {
            try {
                Gson gson = new Gson();
                PlotTopicUnit plotTopicUnit = new PlotTopicUnit();
                plotTopicUnit = gson
                        .fromJson(object, PlotTopicUnit.class);
                return plotTopicUnit;
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }
    }
	
	private static class DetailCommentParser implements Parser<String> {
		@Override
		public String parse(String arg0) throws ParseException {
			if (arg0 != null) {
				return arg0;
			}
			return null;
		}
	}

	private static class CommentsParser implements Parser<CommentsData> {
		@Override
		public CommentsData parse(String json) throws ParseException {
			Gson gson = new Gson();
			if (json != null) {
				return gson.fromJson(json, CommentsData.class);
			}
			return null;
		}
	}

	/**
	 * 战报页信息解析
	 * 
	 * @author SunQuan
	 * 
	 */
	private static class ReportInfoParser implements Parser<ReportInfo> {

		@Override
		public ReportInfo parse(String json) throws ParseException {
			Gson gson = new Gson();
			if (json != null) {
				return gson.fromJson(json, ReportInfo.class);
			}
			return null;
		}
	}

	/**
	 * 直播发言返回数据解析
	 * 
	 * @author SunQuan
	 * 
	 */
	private static class ReplyerInfoParser implements Parser<Replyer> {

		@Override
		public Replyer parse(String json) throws ParseException {
			Gson gson = new Gson();
			if (json != null) {
				return gson.fromJson(json, Replyer.class);
			}
			return null;
		}

	}

	/**
	 * 直播头信息数据解析
	 * 
	 * @author SunQuan
	 * 
	 */
	private static class MatchInfoParser implements Parser<MatchInfo> {

		@Override
		public MatchInfo parse(String json) throws ParseException {
			Gson gson = new Gson();
			if (json != null) {
				return gson.fromJson(json, MatchInfo.class);
			}
			return null;
		}

	}

	/**
	 * 图文直播头部数据解析
	 * 
	 * @author SunQuan
	 * 
	 */
	private static class DirectSeedingTitleBeanParser implements
			Parser<PhotoAndTextLiveTitleBean> {

		@Override
		public PhotoAndTextLiveTitleBean parse(String json) throws ParseException {
			Gson gson = new Gson();
			if (json != null) {
				return gson.fromJson(json, PhotoAndTextLiveTitleBean.class);
			}
			return null;
		}

	}
	
	/**
	 * 图文直播列表数据解析
	 * 
	 * @author SunQuan
	 * 
	 */
	private static class DirectSeedingListUnitParser implements
			Parser<PhotoAndTextLiveListUnit> {

		@Override
		public PhotoAndTextLiveListUnit parse(String json) throws ParseException {
			Gson gson = new Gson();
			if (json != null) {
				return gson.fromJson(json, PhotoAndTextLiveListUnit.class);
			}
			return null;
		}

	}
	
	/**
	 * 投票数据解析
	 * 
	 * @author SunQuan
	 *
	 */
	private static class VoteDataParser implements Parser<VoteData> {

		@Override
		public VoteData parse(String s) throws ParseException {
			Gson gson = new Gson();
			if(s != null) {
				return gson.fromJson(s, VoteData.class);
			}
			return null;
		}
		
	}
	
	/**
	 * 投票结果数据解析
	 * 
	 * @author SunQuan
	 *
	 */
	private static class VoteResultParser implements Parser<VoteResult> {

		@Override
		public VoteResult parse(String s) throws ParseException {
			Gson gson = new Gson();
			if(s != null) {
				return gson.fromJson(s, VoteResult.class);
			}
			return null;
		}
		
	}
	
	private static class VideoDetailParser implements Parser<VideoDetailBean> {

    @Override
    public VideoDetailBean parse(String s) throws ParseException {
      // TODO Auto-generated method stub
        Gson gson = new Gson();
        if(s != null) {
            return gson.fromJson(s, VideoDetailBean.class);
        }
        return null;
      }
	  
	}
	
	private static class VideoRelativeParser implements Parser<VideoRelativeBean> {

    @Override
    public VideoRelativeBean parse(String s) throws ParseException {
      // TODO Auto-generated method stub
        Gson gson = new Gson();
        if(s != null) {
            return gson.fromJson(s, VideoRelativeBean.class);
        }
        return null;
      }
	  
	}
	
	
	
//	/**
//	 * 图片切割接口返回数据解析
//	 * 
//	 * @author SunQuan
//	 *
//	 */
//	private static class DirectSeedingImgCutBeanParser implements Parser<DirectSeedingImgCutBean>{
//
//		@Override
//		public DirectSeedingImgCutBean parse(String s) throws ParseException {
//			DirectSeedingImgCutBean bean = null;
//			try {
//				XmlPullParser parser = Xml.newPullParser();
//				parser.setInput(new StringReader(s));
//				for (int type = parser.getEventType(); type != XmlPullParser.END_DOCUMENT; type = parser
//						.next()) {
//					if (type == XmlPullParser.START_TAG) {
//						if ("task".equals(parser.getName())) {
//							bean = new DirectSeedingImgCutBean();
//							bean.setOriginalUrl(parser.getAttributeValue(0));
//							bean.setSendSuccess(Boolean.parseBoolean(parser.getAttributeValue(1)));
//							bean.setHandleSuccess(Boolean.parseBoolean(parser.getAttributeValue(2)));
//							bean.setWidth(parser.getAttributeValue(3));
//							bean.setHeight(parser.getAttributeValue(4));
//							bean.setResultUrl(parser.nextText());						
//						}
//					}
//				}
//			} catch (Exception e) {
//				e.printStackTrace();
//				bean = null;
//			}
//			return bean;
//		}
//		
//	}

	private static class DetailSlideBodyParser implements Parser<SlideBody> {
		@Override
		public SlideBody parse(String json) throws ParseException {
			Gson gson = new Gson();
			if (json != null) {
				return gson.fromJson(json, SlideUnit.class).getBody();
			}
			return null;
		}
	}

	/**
	 * 策划专题解析器
	 */
	public static Parser<PlotTopicUnit> newPlotTopicParser() {
      return new PlotTopicParser();
  }
	
	public static Parser<TopicDetailUnits> newTopicDetailParser() {
		return new TopicDetailParser();
	}

	public static Parser<HistoryMessageUnit> newHistoryMessageUnitParser() {
		return new SmartHistoryMessageUnitParser();
	}
	
	public static Parser<SurveyUnit> newSurveyUnitParser() {
	  return new GsonParser<SurveyUnit>(SurveyUnit.class);
	}
	
	public static Parser<SurveyHttpResult> newSurveyHttpResultParser() {
      return new GsonParser<SurveyHttpResult>(SurveyHttpResult.class);
    }

	public static Parser<ListUnit> newListUnitParser() {
		return new SmartListUnitParser();
	}
	
	/**
	 * 视频频道解析器
	 * @author wu_dan
	 */
	public static Parser<VideoListUnit> newVideoListUnitParser() {
		return new SmartVideoListUnitParser();
	}
	
	private static class SmartVideoListUnitParser implements Parser<VideoListUnit>{

		@Override
		public VideoListUnit parse(String s) throws ParseException {
			try {
				JsonParser parser = new JsonParser();
				JsonElement element = parser.parse(s);
				JsonObject object = null;
				if (element.isJsonObject())
					object = element.getAsJsonObject();
				else if (element.isJsonArray())
					object = element.getAsJsonArray().get(0).getAsJsonObject();
				else if (element.isJsonNull())
					return new VideoListUnit();
				return parseVideoListUnit(object);
			} catch (Exception e) {
				e.printStackTrace();
				throw new ParseException(e.getMessage(), 0);
			}
		}

		private VideoListUnit parseVideoListUnit(JsonObject object) {
			Gson gson = new Gson();
			VideoListUnit unit = new VideoListUnit();
			unit = gson.fromJson(object, VideoListUnit.class);
			return unit;
		}
		
	}
	

	/**
	 * 体育直播实况解析器
	 */
	public static Parser<SportFactUnit> newSportLiveFactUnitParser() {
		return new SportLiveFactUnitParser();
	}

	public static Parser<ReviewUnit> newReviewUnitParser() {
		return new SmartReviewUnitParser();
	}

	public static Parser<TopicUnit> newTopicUnitParser() {
		return new SmartTopicUnitParser();
	}

	public static Parser<ListUnits> newListUnitsParser() {
		return new SmartListUnitsParser();
	}
	
	public static Parser<ListUnits> newListUnitsParserForExecusive() {
		return new SmartListUnitsParserForExecusive();
	}

	public static Parser<GalleryUnit> newGalleryUnitParser() {
		return new GsonParser<GalleryUnit>(GalleryUnit.class);
	}

	public static Parser<SportCommentUnit> newSportCommentUnitParser() {
		return new GsonParser<SportCommentUnit>(SportCommentUnit.class);
	}

	public static Parser<String> newDetailCommentParser() {
		return new DetailCommentParser();
	}

	public static Parser<SlideBody> newSlideBodyParser() {
		return new DetailSlideBodyParser();
	}

	public static Parser<CommentsData> newCommentsParser() {
		return new CommentsParser();
	}
	
	public static Parser<WeatherBeans> newWeatherBeansParser() {
		return new WeatherBeansParser();
	}

	public static Parser<ArrayList<DocUnit>> newDocUnitsParser() {
		return new DocUnitsParser();
	}
	
	public static Parser<IPushBean> newIPushBeanParser() {
		return new IPushBeanParser();
	}
	
	public static SmartDocUnitParser newSmartDocUnitParser(){
		return new SmartDocUnitParser();
	}

	public static Parser<ReportInfo> newReportInfoParser() {
		return new ReportInfoParser();
	}

	public static Parser<Replyer> newReplyerInfoParser() {
		return new ReplyerInfoParser();
	}

	public static Parser<MatchInfo> newMatchInfoParser() {
		return new MatchInfoParser();
	}

	public static Parser<PhotoAndTextLiveTitleBean> newDirectSeedingTitleBean() {
		return new DirectSeedingTitleBeanParser();
	}
	
	public static Parser<PhotoAndTextLiveListUnit> newDirectSeedingListUnit() {
		return new DirectSeedingListUnitParser();
	}
	
	public static Parser<VoteData> newVoteDataParser() {
		return new VoteDataParser();
	}
	
	public static Parser<VideoDetailBean> newVideoDetailParser() {
	  return new VideoDetailParser() ; 
	}
	
	public static Parser<VideoRelativeBean> newVideoRelativeParser(){
	  return new VideoRelativeParser();
	}
	
	public static Parser<VoteResult> newVoteResultParser() {
		return new VoteResultParser();
	}
	
	public static Parser<SubscriptionBean> newSubscriptionBeanParser() {
		return new GsonParser<SubscriptionBean>(SubscriptionBean.class);
	}
	
//	public static Parser<DirectSeedingImgCutBean> newDirectSeedingImgCutBean(){
//		return new DirectSeedingImgCutBeanParser();
//	}
}
