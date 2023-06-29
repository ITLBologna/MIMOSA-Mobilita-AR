package com.pie.technology.ar.location.view.ar_location_view;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.hardware.display.DisplayManager;
import android.os.SystemClock;
import android.util.Log;
import android.view.Display;
import android.view.Surface;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;


/**
 * ArLocationViewPlugin
 */
public class ArLocationViewPlugin implements FlutterPlugin, StreamHandler {
    private static final String TAG = "ArLocationView";


    private static final int SENSOR_DELAY_MICROS = 100;

    private static final float ALPHA = 0.45f;


    private static final int COMPASS_UPDATE_RATE_MS = 10;

    private SensorEventListener sensorEventListener;

    private Display display;
    private SensorManager sensorManager;

    @Nullable
    private Sensor compassSensor;
    @Nullable
    private Sensor gravitySensor;
    @Nullable
    private Sensor magneticFieldSensor;

    private float[] truncatedRotationVectorValue = new float[4];
    private float[] rotationMatrix = new float[9];
    private float[] rotationVectorValue;
    private float lastHeading;
    private int lastAccuracySensorStatus;

    private long compassUpdateNextTimestamp;
    private float[] gravityValues = new float[3];
    private float[] magneticValues = new float[3];

    public ArLocationViewPlugin() {
        // no-op
    }

    private ArLocationViewPlugin(Context context) {
        display = ((DisplayManager) context.getSystemService(Context.DISPLAY_SERVICE))
                .getDisplay(Display.DEFAULT_DISPLAY);
        sensorManager = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
        compassSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);
        if (compassSensor == null) {
            Log.d(TAG, "Rotation vector sensor not supported on device, "
                    + "falling back to accelerometer and magnetic field.");
        }

        gravitySensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        magneticFieldSensor = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);
    }

    // New Plugin APIs

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        EventChannel channel = new EventChannel(binding.getBinaryMessenger(), "pie/ar_view_location");
        channel.setStreamHandler(new ArLocationViewPlugin(binding.getApplicationContext()));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    public void onListen(Object arguments, EventSink events) {
        sensorEventListener = createSensorEventListener(events);

        if (isCompassSensorAvailable()) {
            // Does nothing if the sensors already registered.
            sensorManager.registerListener(sensorEventListener, compassSensor, SENSOR_DELAY_MICROS);
        }

        sensorManager.registerListener(sensorEventListener, gravitySensor, SENSOR_DELAY_MICROS);
        sensorManager.registerListener(sensorEventListener, magneticFieldSensor, SENSOR_DELAY_MICROS);
    }

    public void onCancel(Object arguments) {
        if (isCompassSensorAvailable()) {
            sensorManager.unregisterListener(sensorEventListener, compassSensor);
        }

        sensorManager.unregisterListener(sensorEventListener, gravitySensor);
        sensorManager.unregisterListener(sensorEventListener, magneticFieldSensor);
    }

    private boolean isCompassSensorAvailable() {
        return compassSensor != null;
    }

    SensorEventListener createSensorEventListener(final EventSink events) {
        return new SensorEventListener() {
            @Override
            public void onSensorChanged(SensorEvent event) {
                boolean compassNeedsCalibration = false;
                if (lastAccuracySensorStatus == SensorManager.SENSOR_STATUS_UNRELIABLE) {
                    Log.d(TAG, "Compass sensor is unreliable, device calibration is needed.");
                    // Update the heading, even if the sensor is unreliable.
                    // This makes it possible to use a different indicator for the unreliable case,
                    // instead of just changing the RenderMode to NORMAL.
                    compassNeedsCalibration = true;
                }
                if (event.sensor.getType() == Sensor.TYPE_ROTATION_VECTOR) {
                    rotationVectorValue = getRotationVectorFromSensorEvent(event);
                    updateOrientation(compassNeedsCalibration);
                } else if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER && !isCompassSensorAvailable()) {
                    gravityValues = lowPassFilter(getRotationVectorFromSensorEvent(event), gravityValues);
                    updateOrientation(compassNeedsCalibration);
                } else if (event.sensor.getType() == Sensor.TYPE_MAGNETIC_FIELD && !isCompassSensorAvailable()) {
                    magneticValues = lowPassFilter(getRotationVectorFromSensorEvent(event), magneticValues);
                    updateOrientation(compassNeedsCalibration);
                }
            }

            @Override
            public void onAccuracyChanged(Sensor sensor, int accuracy) {
                if (lastAccuracySensorStatus != accuracy) {
                    lastAccuracySensorStatus = accuracy;
                }
            }

            @SuppressWarnings("SuspiciousNameCombination")
            private void updateOrientation(boolean compassNeedsCalibration) {
                // check when the last time the compass was updated, return if too soon.
                long currentTime = SystemClock.elapsedRealtime();
                if (currentTime < compassUpdateNextTimestamp) {
                    return;
                }

                if (rotationVectorValue != null) {
                    SensorManager.getRotationMatrixFromVector(rotationMatrix, rotationVectorValue);
                } else {
                    // Get rotation matrix given the gravity and geomagnetic matrices
                    SensorManager.getRotationMatrix(rotationMatrix, null, gravityValues, magneticValues);
                }

                int worldAxisForDeviceAxisX;
                int worldAxisForDeviceAxisY;

                // Assume the device screen was parallel to the ground,
                // and adjust the rotation matrix for the device orientation.
                switch (display.getRotation()) {
                    case Surface.ROTATION_90:
                        worldAxisForDeviceAxisX = SensorManager.AXIS_Y;
                        worldAxisForDeviceAxisY = SensorManager.AXIS_MINUS_X;
                        break;
                    case Surface.ROTATION_180:
                        worldAxisForDeviceAxisX = SensorManager.AXIS_MINUS_X;
                        worldAxisForDeviceAxisY = SensorManager.AXIS_MINUS_Y;
                        break;
                    case Surface.ROTATION_270:
                        worldAxisForDeviceAxisX = SensorManager.AXIS_MINUS_Y;
                        worldAxisForDeviceAxisY = SensorManager.AXIS_X;
                        break;
                    case Surface.ROTATION_0:
                    default:
                        worldAxisForDeviceAxisX = SensorManager.AXIS_X;
                        worldAxisForDeviceAxisY = SensorManager.AXIS_Y;
                        break;
                }

                float[] adjustedRotationMatrix = new float[9];
                SensorManager.remapCoordinateSystem(rotationMatrix, worldAxisForDeviceAxisX, worldAxisForDeviceAxisY,
                        adjustedRotationMatrix);

                // Transform rotation matrix into azimuth/pitch/roll
                float[] orientation = new float[3];
                SensorManager.getOrientation(adjustedRotationMatrix, orientation);

                if (orientation[1] < -Math.PI / 4) {
                    // The pitch is less than -45 degrees.
                    // Remap the axes as if the device screen was the instrument panel.
                    switch (display.getRotation()) {
                        case Surface.ROTATION_90:
                            worldAxisForDeviceAxisX = SensorManager.AXIS_Z;
                            worldAxisForDeviceAxisY = SensorManager.AXIS_MINUS_X;
                            break;
                        case Surface.ROTATION_180:
                            worldAxisForDeviceAxisX = SensorManager.AXIS_MINUS_X;
                            worldAxisForDeviceAxisY = SensorManager.AXIS_MINUS_Z;
                            break;
                        case Surface.ROTATION_270:
                            worldAxisForDeviceAxisX = SensorManager.AXIS_MINUS_Z;
                            worldAxisForDeviceAxisY = SensorManager.AXIS_X;
                            break;
                        case Surface.ROTATION_0:
                        default:
                            worldAxisForDeviceAxisX = SensorManager.AXIS_X;
                            worldAxisForDeviceAxisY = SensorManager.AXIS_Z;
                            break;
                    }
                } else if (orientation[1] > Math.PI / 4) {
                    // The pitch is larger than 45 degrees.
                    // Remap the axes as if the device screen was upside down and facing back.
                    switch (display.getRotation()) {
                        case Surface.ROTATION_90:
                            worldAxisForDeviceAxisX = SensorManager.AXIS_MINUS_Z;
                            worldAxisForDeviceAxisY = SensorManager.AXIS_MINUS_X;
                            break;
                        case Surface.ROTATION_180:
                            worldAxisForDeviceAxisX = SensorManager.AXIS_MINUS_X;
                            worldAxisForDeviceAxisY = SensorManager.AXIS_Z;
                            break;
                        case Surface.ROTATION_270:
                            worldAxisForDeviceAxisX = SensorManager.AXIS_Z;
                            worldAxisForDeviceAxisY = SensorManager.AXIS_X;
                            break;
                        case Surface.ROTATION_0:
                        default:
                            worldAxisForDeviceAxisX = SensorManager.AXIS_X;
                            worldAxisForDeviceAxisY = SensorManager.AXIS_MINUS_Z;
                            break;
                    }
                } else if (Math.abs(orientation[2]) > Math.PI / 2) {
                    // The roll is less than -90 degrees, or is larger than 90 degrees.
                    // Remap the axes as if the device screen was face down.
                    switch (display.getRotation()) {
                        case Surface.ROTATION_90:
                            worldAxisForDeviceAxisX = SensorManager.AXIS_MINUS_Y;
                            worldAxisForDeviceAxisY = SensorManager.AXIS_MINUS_X;
                            break;
                        case Surface.ROTATION_180:
                            worldAxisForDeviceAxisX = SensorManager.AXIS_MINUS_X;
                            worldAxisForDeviceAxisY = SensorManager.AXIS_Y;
                            break;
                        case Surface.ROTATION_270:
                            worldAxisForDeviceAxisX = SensorManager.AXIS_Y;
                            worldAxisForDeviceAxisY = SensorManager.AXIS_X;
                            break;
                        case Surface.ROTATION_0:
                        default:
                            worldAxisForDeviceAxisX = SensorManager.AXIS_X;
                            worldAxisForDeviceAxisY = SensorManager.AXIS_MINUS_Y;
                            break;
                    }
                }

                SensorManager.remapCoordinateSystem(rotationMatrix, worldAxisForDeviceAxisX, worldAxisForDeviceAxisY,
                        adjustedRotationMatrix);

                // Transform rotation matrix into azimuth/pitch/roll
                SensorManager.getOrientation(adjustedRotationMatrix, orientation);

                double[] v = new double[4];
                v[0] = Math.toDegrees(orientation[0]);
                v[2] = getAccuracy();
                v[3] = compassNeedsCalibration ? 1 : 0;
                // The x-axis is all we care about here.
                notifyCompassChangeListeners(v);

                // Update the compassUpdateNextTimestamp
                compassUpdateNextTimestamp = currentTime + COMPASS_UPDATE_RATE_MS;
            }

            private void notifyCompassChangeListeners(double[] heading) {
                events.success(heading);
                lastHeading = (float) heading[0];
            }

            private double getAccuracy() {
                return lastAccuracySensorStatus;
            }

            /**
             * Helper function, that filters newValues, considering previous values
             *
             * @param newValues      array of float, that contains new data
             * @param smoothedValues array of float, that contains previous state
             * @return float filtered array of float
             */
            private float[] lowPassFilter(float[] newValues, float[] smoothedValues) {
                if (smoothedValues == null) {
                    return newValues;
                }
                for (int i = 0; i < newValues.length; i++) {
                    smoothedValues[i] = smoothedValues[i] + ALPHA * (newValues[i] - smoothedValues[i]);
                }
                return smoothedValues;
            }

            /**
             * Pulls out the rotation vector from a SensorEvent, with a maximum length
             * vector of four elements to avoid potential compatibility issues.
             *
             * @param event the sensor event
             * @return the events rotation vector, potentially truncated
             */
            @NonNull
            private float[] getRotationVectorFromSensorEvent(@NonNull SensorEvent event) {
                if (event.values.length > 4) {
                    // On some Samsung devices SensorManager.getRotationMatrixFromVector
                    // appears to throw an exception if rotation vector has length > 4.
                    // For the purposes of this class the first 4 values of the
                    // rotation vector are sufficient (see crbug.com/335298 for details).
                    // Only affects Android 4.3
                    System.arraycopy(event.values, 0, truncatedRotationVectorValue, 0, 4);
                    return truncatedRotationVectorValue;
                } else {
                    return event.values;
                }
            }
        };
    }
}
