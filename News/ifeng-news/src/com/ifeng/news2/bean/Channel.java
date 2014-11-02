package com.ifeng.news2.bean;

import android.os.Parcel;
import android.os.Parcelable;

public class Channel implements Parcelable{

  private String channelName;
  private String channelUrl;
  private String channelSmallUrl;
  private String offlineUrl;
  private String statistic;
  private String adSite;

  public static final Channel NULL=new Channel();

  public static boolean isNull(Channel channel)
  {
    return channel==null || channel.equals(NULL);
  }

  public Channel()
  {

  }
  public Channel(String channelName, String channelUrl, String offlineUrl,
                 String statistic,String channelSmallUrl) {
    super();
    this.channelName = channelName;
    this.channelUrl = channelUrl;
    this.offlineUrl = offlineUrl;
    this.statistic = statistic;
    this.channelSmallUrl=channelSmallUrl;
  }
  
  public Channel(String channelName, String channelUrl, String offlineUrl,
                 String statistic, String channelSmallUrl, String adSite) {
    super();
    this.channelName = channelName;
    this.channelUrl = channelUrl;
    this.offlineUrl = offlineUrl;
    this.statistic = statistic;
    this.channelSmallUrl=channelSmallUrl;
    this.adSite=adSite;
  }

  public String getAdSite() {
    return adSite;
  }

  public void setAdSite(String adSite) {
    this.adSite = adSite;
  }

  public String getChannelName() {
    return channelName;
  }

  public void setChannelName(String channelName) {
    this.channelName = channelName;
  }

  public String getChannelUrl() {
    return channelUrl;
  }

  public String getPrefetchChannelUrl(){
    return channelSmallUrl+"&page="+1;
  }

  public void setChannelUrl(String channelUrl) {
    this.channelUrl = channelUrl;
  }

  public String getOfflineUrl() {
    return offlineUrl;
  }

  public void setOfflineUrl(String offlineUrl) {
    this.offlineUrl = offlineUrl;
  }

  public String getStatistic() {
    return statistic;
  }

  public void setStatistic(String statistic) {
    this.statistic = statistic;
  }

  public String getChannelSmallUrl() {
    return channelSmallUrl;
  }

  public void setChannelSmallUrl(String channelSmallUrl) {
    this.channelSmallUrl = channelSmallUrl;
  }

  @Override
  public int describeContents() {
    return 0;
  }
  @Override
  public void writeToParcel(Parcel dest, int flags) {
    dest.writeString(channelName);
    dest.writeString(channelUrl);
    dest.writeString(offlineUrl);
    dest.writeString(statistic);
    dest.writeString(channelSmallUrl);
    dest.writeString(adSite);
  }

  public static final Parcelable.Creator<Channel> CREATOR = new Parcelable.Creator<Channel>() {

    @Override
    public Channel createFromParcel(Parcel source) {
      Channel channel = new Channel();
      channel.channelName = source.readString();
      channel.channelUrl = source.readString();
      channel.offlineUrl = source.readString();
      channel.statistic = source.readString();
      channel.channelSmallUrl=source.readString();
      channel.adSite=source.readString();
      return channel;
    }

    @Override
    public Channel[] newArray(int size) {

      return new Channel[size];
    }

  };

  @Override
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result
        + ((channelSmallUrl == null) ? 0 : channelSmallUrl.hashCode());
    result = prime * result
        + ((channelUrl == null) ? 0 : channelUrl.hashCode());
    result = prime * result
        + ((offlineUrl == null) ? 0 : offlineUrl.hashCode());
    return result;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj)
      return true;
    if (obj == null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    Channel other = (Channel) obj;
    if (channelSmallUrl == null) {
      if (other.channelSmallUrl != null)
        return false;
    } else if (!channelSmallUrl.equals(other.channelSmallUrl))
      return false;
    if (channelUrl == null) {
      if (other.channelUrl != null)
        return false;
    } else if (!channelUrl.equals(other.channelUrl))
      return false;
    if (offlineUrl == null) {
      if (other.offlineUrl != null)
        return false;
    } else if (!offlineUrl.equals(other.offlineUrl))
      return false;
    return true;
  }

  @Override
  public String toString() {
    return channelName;
  }


}
