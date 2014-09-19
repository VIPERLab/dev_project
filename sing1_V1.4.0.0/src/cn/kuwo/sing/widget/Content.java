package cn.kuwo.sing.widget;

public class Content {
	private String id;
	private String letter;
	private String name;
	private int songsCount;
	private String imageUrl;
	private String imagePath;
	
	public Content(String letter, String id, String name, int songsCount, String imageUrl) {
		super();
		this.id = id;
		this.letter = letter;
		this.name = name;
		this.songsCount = songsCount;
		this.imageUrl = imageUrl;
	}
	public String getLetter() {
		return letter;
	}
	public void setLetter(String letter) {
		this.letter = letter;
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public int getSongsCount() {
		return songsCount;
	}
	public void setSongsCount(int songsCount) {
		this.songsCount = songsCount;
	}
	public String getImageUrl() {
		return imageUrl;
	}
	public void setImageUrl(String imageUrl) {
		this.imageUrl = imageUrl;
	}
	
	public String getImagePath() {
		return imagePath;
	}
	
	public void setImagePath(String imagePath) {
		this.imagePath = imagePath;
	}
	
	
}
