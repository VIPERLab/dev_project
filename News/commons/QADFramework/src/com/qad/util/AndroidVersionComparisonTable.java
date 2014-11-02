package com.qad.util;

//import android.annotation.SuppressLint;
import java.util.HashMap;

//@SuppressLint("UseSparseArrays")
public class AndroidVersionComparisonTable {
  
  public static AndroidVersionComparisonTable androidVersion = null;
  private static HashMap<Integer, String> versionComparisonTable = new HashMap<Integer, String>();
  
  public static AndroidVersionComparisonTable getInstante(){
    
    if (null == androidVersion) {
      androidVersion = new AndroidVersionComparisonTable();
      androidVersion.setVersionComparisonTable();
    }
     return androidVersion;
  }
  
  private void setVersionComparisonTable(){
    versionComparisonTable.clear();
    versionComparisonTable.put(3, "1.5");
    versionComparisonTable.put(4, "1.6");
    versionComparisonTable.put(7, "2.1");
    versionComparisonTable.put(8, "2.2");
    versionComparisonTable.put(10, "2.3.3");
    versionComparisonTable.put(11, "3.0");
    versionComparisonTable.put(12, "3.1");
    versionComparisonTable.put(13, "3.2");
    versionComparisonTable.put(14, "4.0");
    versionComparisonTable.put(15, "4.0.3");
    versionComparisonTable.put(16, "4.1.2");
    versionComparisonTable.put(17, "4.2.2");
    versionComparisonTable.put(18, "4.3");
  }
  
  public String getAndroidVersion(){
    if (versionComparisonTable.containsKey(android.os.Build.VERSION.SDK_INT)) {
      return versionComparisonTable.get(android.os.Build.VERSION.SDK_INT);
    } else {
      return null;
    }
  }
}
