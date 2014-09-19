package cn.kuwo.base.codec;

import java.util.Arrays;

public class AudioCodec {
    final String mCodecName;
    final String[] mSupportFormats;
    final Class<? extends Decoder> mCodecClass;
    
    public AudioCodec(final String name, final Class<? extends Decoder> dc,
            final String[] formats) {
        this.mCodecName = name;
        this.mSupportFormats = formats;
        this.mCodecClass = dc;
    }

    public String[] getSupportFormats() {
        return mSupportFormats;
    }

    public Class<? extends Decoder> getCodecClass() {
        return mCodecClass;
    }
    
    public String getName() {
        return mCodecName;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((mCodecClass == null) ? 0 : mCodecClass.hashCode());
        result = prime * result + ((mCodecName == null) ? 0 : mCodecName.hashCode());
        result = prime * result + Arrays.hashCode(mSupportFormats);
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
        AudioCodec other = (AudioCodec) obj;
        if (mCodecClass == null) {
            if (other.mCodecClass != null)
                return false;
        } else if (!mCodecClass.equals(other.mCodecClass))
            return false;
        if (mCodecName == null) {
            if (other.mCodecName != null)
                return false;
        } else if (!mCodecName.equals(other.mCodecName))
            return false;
        if (!Arrays.equals(mSupportFormats, other.mSupportFormats))
            return false;
        return true;
    }  
}
