package cn.kuwo.sing.bean;

import java.io.Serializable;

import com.j256.ormlite.field.DatabaseField;

//我的作品
public class MySong implements Serializable {
	
	private static final long serialVersionUID = 3963934016036370332L;

	@DatabaseField(id=true)
	private String id;

	@DatabaseField(index = true)
	private long date;
	
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}

	public long getDate() {
		return date;
	}

	public void setDate(long date) {
		this.date = date;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
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
		MySong other = (MySong) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		return true;
	}
}
