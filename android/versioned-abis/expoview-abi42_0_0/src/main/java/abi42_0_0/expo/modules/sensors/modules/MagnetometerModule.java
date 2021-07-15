// Copyright 2015-present 650 Industries. All rights reserved.

package abi42_0_0.expo.modules.sensors.modules;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorManager;
import android.os.Bundle;

import abi42_0_0.org.unimodules.core.Promise;
import abi42_0_0.org.unimodules.core.interfaces.ExpoMethod;

import abi42_0_0.expo.modules.interfaces.sensors.SensorServiceInterface;
import abi42_0_0.expo.modules.interfaces.sensors.services.MagnetometerServiceInterface;

public class MagnetometerModule extends BaseSensorModule {
  public MagnetometerModule(Context reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "ExponentMagnetometer";
  }

  @Override
  public String getEventName() {
    return "magnetometerDidUpdate";
  }

  @Override
  protected SensorServiceInterface getSensorService() {
    return getModuleRegistry().getModule(MagnetometerServiceInterface.class);
  }

  protected Bundle eventToMap(SensorEvent sensorEvent) {
    Bundle map = new Bundle();
    map.putDouble("x", sensorEvent.values[0]);
    map.putDouble("y", sensorEvent.values[1]);
    map.putDouble("z", sensorEvent.values[2]);
    return map;
  }

  @ExpoMethod
  public void startObserving(Promise promise) {
    super.startObserving();
    promise.resolve(null);
  }

  @ExpoMethod
  public void stopObserving(Promise promise) {
    super.stopObserving();
    promise.resolve(null);
  }

  @ExpoMethod
  public void setUpdateInterval(int updateInterval, Promise promise) {
    super.setUpdateInterval(updateInterval);
    promise.resolve(null);
  }

  @ExpoMethod
  public void isAvailableAsync(Promise promise) {
    SensorManager mSensorManager = (SensorManager) getContext().getSystemService(Context.SENSOR_SERVICE);
    boolean isAvailable = mSensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD) != null;
    promise.resolve(isAvailable);
  }
}
