package cn.kuwo.sing.bean;



public class AudioResourceNode {
	
	public static class  DirFlag {
		public static final int LOCAL = 0;
		public static final int CACHE = 1;
		public static final int DOWNLOAD = 2;
		public static final int PREFETCH = 3;
	}
	
	// 资源音质枚举
    public enum ResourceQuality {
        adaptive,       // 自适应
        fluent,         // 流畅
        standard,       // 标准
        highquality,    // 高品质
        perfect,        // 完美
        lossless        // 无损
    }
    // 资源应用模式
    public enum ApplyMode {
        audition,       // 试听
        download        // 下载
    }
    
	// 资源本地索引ID
	private int mId = -1;
	// 所属歌曲ID
	private int mMusicId = -1;
	// 资源URL
	private String mURL = null;
	// 资源本地路径
	private String mPath = null;
	// 音乐格式
	private String mAudioFormat;
	// 资源大小
	private int mCurrentSize = 0;
	// 资源路径标识 0:本地1:缓冲2:下载
	private int mDirFlag = 0;
	// 本地是否完整0：表示不完整1： 表示完整
	private boolean mIsComplete = false;
	// 资源标签
	private String mWrapperUrl = null;
	// 比特率 单位kbs
	private int mBitrate = 0;
	// 采样频率
	private int mSampleRate = 0;
	// 声道数
	private int mChannelNum = 0;
	// 音轨
	private String mTrackInfo = null;
	// 资源有效性
	private boolean mIsValid = true;
	// 文件总大小
	private int mTotalSize = 0;
	// 资源SIG
	private String mSig = null;
	// 资源音质
	private ResourceQuality mQuality = ResourceQuality.adaptive;
	// 资源应用模式
	private ApplyMode mMode = ApplyMode.audition;
	

	public AudioResourceNode(String format) {
		super();
		this.mAudioFormat = format;
	}

	public int getId() {
		return mId;
	}

	public void setId(int id) {
		this.mId = id;
	}
	
	public int getMusicId() {
		return mMusicId;
	}
	
	public void setMusicId(int mid) {
		this.mMusicId = mid;
	}

	public String getURL() {
		return mURL;
	}

	public void setURL(String URL) {
		this.mURL = URL;
	}

	public String getPath() {
		return mPath;
	}

	public void setPath(String path) {
		this.mPath = path;
	}

	public int getSize() {
		return mCurrentSize;
	}

	public void setSize(int size) {
		this.mCurrentSize = size;
	}

	public int getDirFlag() {
		return mDirFlag;
	}

	public void setDirFlag(int dirFlag) {
		this.mDirFlag = dirFlag;
	}

	public boolean isComplete() {
		return mIsComplete;
	}

	public void setComplete(boolean isComplete) {
		this.mIsComplete = isComplete;
	}

	public String getWrapperUrl() {
		return mWrapperUrl;
	}

	public void setWrapperUrl(String url) {
		this.mWrapperUrl = url;
	}

	public int getBitrate() {
		return mBitrate;
	}

	public void setBitrate(int bitrate) {
		this.mBitrate = bitrate;
	}

	public int getSampleRate() {
		return mSampleRate;
	}

	public void setSampleRate(int sampleRate) {
		this.mSampleRate = sampleRate;
	}

	public int getChannelNum() {
		return mChannelNum;
	}

	public void setChannelNum(int channelNum) {
		this.mChannelNum = channelNum;
	}

	public String getTrackInfo() {
		return mTrackInfo;
	}

	public void setTrackInfo(String trackInfo) {
		this.mTrackInfo = trackInfo;
	}

	public String getAudioFormat() {
		return mAudioFormat;
	}
	
	public void setAudioFormat(String format) {
		this.mAudioFormat = format;
	}

	public boolean isValid() {
		return mIsValid;
	}

	public void setValid(boolean valid) {
		this.mIsValid = valid;
	}
	
	public boolean fromLocal(){
		return mDirFlag == DirFlag.LOCAL;
	}
	
	public boolean fromCache(){
		return mDirFlag == DirFlag.CACHE;
	}
	
	public boolean fromDownload() {
		return mDirFlag == DirFlag.DOWNLOAD;
	}
	
	public boolean fromPrefetch() {
	    return mDirFlag == DirFlag.PREFETCH;
	}
	
	public void setTotalSize(int total) {
	    this.mTotalSize = total;
	}
	
	public int getTotalSize() {
	    return mTotalSize;
	}
	
	public void setSig(String sig) {
	    this.mSig = sig;
	}
	
	public String getSig() {
	    return mSig;
	}
	
	public ResourceQuality getQuality() {
	    return mQuality;
	}
	
	public void setQuality(ResourceQuality quality) {
	    this.mQuality = quality;
	}
	
	public ApplyMode getApplyMode() {
	    return mMode;
	}
	
	public void setApplyMode(ApplyMode mode) {
	    this.mMode = mode;
	}
}
