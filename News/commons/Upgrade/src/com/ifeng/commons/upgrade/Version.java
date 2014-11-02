package com.ifeng.commons.upgrade;

public class Version implements Comparable<Version> {

	public int major;
	public int sub;
	public int fix;

	public Version(String version) {
		String[] versions = version.split("\\.");
		try {
			if (versions.length > 0)
				major = Integer.parseInt(versions[0]);
			if (versions.length > 1)
				sub = Integer.parseInt(versions[1]);
			if (versions.length > 2)
				fix = Integer.parseInt(versions[2]);
		} finally {
			// ignore parseError and make sure all version is positive
			if (major < 0)
				major = 0;
			if (sub < 0)
				sub = 0;
			if (fix < 0)
				fix = 0;
		}
	}

	@Override
	public boolean equals(Object o) {
		if (null == o)
			return false;
		if (!(o instanceof Version))
			return false;
		Version v = (Version) o;
		if (v.compareTo(this) == 0)
			return true;
		else
			return false;
	}

	@Override
	public int hashCode() {
		return major << 3 + sub << 2 + fix << 1;
	}

	@Override
	public String toString() {
		return major + "." + sub + "." + fix;
	}

	@Override
	public int compareTo(Version another) {
		int diff = major - another.major;
		if (diff != 0)
			return diff;
		diff = sub - another.sub;
		if (diff != 0)
			return diff;
		diff = fix - another.fix;
		return diff;
	}
}
