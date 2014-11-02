package com.ifeng.news2.util;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.util.Log;

public class ShakeListener implements SensorEventListener {

  private Context mContext;
  private OnShakeListener mShakeListener;

  // 速度阈值，当摇晃速度达到这值后产生作用
  private static final int SPEED_SHRESHOLD = 1500;
  // 两次检测的时间间隔
  private static final int UPTATE_INTERVAL_TIME = 100;
  // 传感器管理器
  private SensorManager sensorManager;
  // 传感器
  private Sensor accelerometerSensor;
  // 手机相对于各个轴（x,y,z）的加速度,单位是m/s^2
  private float lastX;
  private float lastY;
  private float lastZ;
  // 上次检测时间
  private long lastUpdateTime;

  public ShakeListener(Context _context) {
    if (null == this.mContext) {
      this.mContext = _context;
    }
  }

  public void openShakeListen() {

    if (null != mContext) {

      if (null == accelerometerSensor) {
        sensorManager = (SensorManager) mContext.getSystemService(Context.SENSOR_SERVICE);
        accelerometerSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
      }
      if (null != accelerometerSensor) {
        sensorManager.registerListener(this, accelerometerSensor, SensorManager.SENSOR_DELAY_GAME);
      }
    }

  }

  public void closeShakListen() {

    if (null != sensorManager) {
      
      sensorManager.unregisterListener(this);
    }
  }

  public boolean isShakeValue() {

    boolean result = false;
    if (null == accelerometerSensor) {

      sensorManager = (SensorManager) mContext.getSystemService(Context.SENSOR_SERVICE);
      accelerometerSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
      if (null != accelerometerSensor) {

        result = true;
      } else {}
    } else {
      result = true;
    }
    return result;
  }

  public void setOnShakeListener(OnShakeListener onShakeListener) {

    this.mShakeListener = onShakeListener;
  }

  @Override
  public void onSensorChanged(SensorEvent event) {

    long currentUpdateTime = System.currentTimeMillis();
    long timeInterval = currentUpdateTime - lastUpdateTime;
    if (timeInterval < UPTATE_INTERVAL_TIME) {
      return;
    }
    lastUpdateTime = currentUpdateTime;
    float x = event.values[0];
    float y = event.values[1];
    float z = event.values[2];
    // 获得x,y,z的变化值
    float deltaX = x - lastX;
    float deltaY = y - lastY;
    float deltaZ = z - lastZ;
    // 重置 手机相对位置坐标.
    lastX = x;
    lastY = y;
    lastZ = z;

    double deltaSpeed = calcCurrShakeSpeed(deltaX, deltaY, deltaZ, timeInterval);
    if (null != mShakeListener && deltaSpeed > SPEED_SHRESHOLD) {

      mShakeListener.onShake();
    }
  }

  /**
   * 根据相对位置和两次的时间差计算速度.
   * 
   * */
  private double calcCurrShakeSpeed(float deltaX, float deltaY, float deltaZ, long deltaTimeMillions) {
    return Math.sqrt((Math.pow(deltaX, 2) + Math.pow(deltaY, 2) + Math.pow(deltaZ, 2))) * 10000
        / deltaTimeMillions;
  }

  @Override
  public void onAccuracyChanged(Sensor sensor, int accuracy) {

  }

  public interface OnShakeListener {
    /**
     * 用户摇晃手机，执行onShake。
     * 
     * @author zhouym
     * */
    public void onShake();
  }

}
