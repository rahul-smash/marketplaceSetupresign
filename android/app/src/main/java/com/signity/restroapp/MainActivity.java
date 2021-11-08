package com.signity.restroapp;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import java.security.MessageDigest;
import android.util.Base64;
import java.security.NoSuchAlgorithmException;
import android.util.Log;
import android.content.Context;


public class MainActivity extends FlutterActivity {
  private final String TAG = "MainActivity";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    printHashKey(this);
  }

  public void printHashKey(Context pContext) {
    try {
      PackageInfo info = pContext.getPackageManager().getPackageInfo(pContext.getPackageName(), PackageManager.GET_SIGNATURES);
      for (Signature signature : info.signatures) {
        MessageDigest md = MessageDigest.getInstance("SHA");
        md.update(signature.toByteArray());
        String hashKey = new String(Base64.encode(md.digest(), 0));
        Log.e(TAG, "printHashKey() Hash Key: " + hashKey);
        Log.e(TAG, "printHashKey() PackageName(): " + pContext.getPackageName());
      }
    } catch (NoSuchAlgorithmException e) {
      Log.e(TAG, "printHashKey()", e);
    } catch (Exception e) {
      Log.e(TAG, "printHashKey()", e);
    }
  }
}
