package bhumi.customInstagramShare;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.support.v4.content.FileProvider;
import android.util.Base64;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class CustomInstagramShareModule extends ReactContextBaseJavaModule
    implements ActivityEventListener {
  private static final int INSTAGRAM_SHARE_REQUEST = 500;
  private Activity mActivity;
  private ReactApplicationContext reactContext;
  private Callback successCallback;

  public CustomInstagramShareModule(ReactApplicationContext reactContext, Activity activity) {
    super(reactContext);
    this.mActivity = activity;
    this.reactContext = reactContext;
    this.reactContext.addActivityEventListener(new RNInstagramShareActivityEventListener());
  }

  @Override public String getName() {
    return "RNCustomShare";
  }

  @ReactMethod public void shareWithInstagram(
      String base64ImageData, Callback failureCallback, Callback successCallback) {
    try {
      this.successCallback = successCallback;

      String type = "image/*";

      if (!isAppInstalled("com.instagram.android")) {
        failureCallback.invoke(new PackageManager.NameNotFoundException("Instagram"));
      } else {
        // Create the new Intent using the 'Send' action.
        Intent share = new Intent(Intent.ACTION_SEND);

        share.setAction(Intent.ACTION_SEND);
        share.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION); // temp permission for receiving app to read this file

        Uri contentUri = saveImageToPath(base64ImageData);
        share.setDataAndType(contentUri, reactContext.getContentResolver().getType(contentUri));

        // Set the MIME type
        share.setType(type);
        share.setPackage("com.instagram.android");

        // Add the URI to the Intent.
        share.putExtra(Intent.EXTRA_STREAM, contentUri);

        // Broadcast the Intent.
        mActivity.startActivityForResult(share, INSTAGRAM_SHARE_REQUEST);
      }
    } catch (Exception e) {
      e.printStackTrace();
      failureCallback.invoke(e);
    }
  }

  @Override
  public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {

  }

  @Override public void onNewIntent(Intent intent) {

  }

  private boolean isAppInstalled(String packageName) {
    PackageManager pm = mActivity.getPackageManager();
    try {
      pm.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES);
      return true;
    } catch (PackageManager.NameNotFoundException e) {
      return false;
    }
  }

  private Uri saveImageToPath(String base64ImageData) throws IOException {
    byte[] decodedString = Base64.decode(base64ImageData, Base64.DEFAULT);

    File cachePath = new File(reactContext.getCacheDir(), "images");
    cachePath.mkdirs();
    FileOutputStream stream = new FileOutputStream(cachePath + "/image.png");
    stream.write(decodedString);
    stream.flush();
    stream.close();

    File imageFile = new File(cachePath, "image.png");

    return FileProvider.getUriForFile(reactContext,
        reactContext.getApplicationContext().getPackageName() + ".TempFileProvider",
        imageFile);
  }

  private class RNInstagramShareActivityEventListener extends BaseActivityEventListener {
    @Override public void onActivityResult(
        Activity activity,
        final int requestCode,
        final int resultCode,
        final Intent intent) {
      if (requestCode == INSTAGRAM_SHARE_REQUEST) {
        successCallback.invoke();
      }
    }
  }
}
