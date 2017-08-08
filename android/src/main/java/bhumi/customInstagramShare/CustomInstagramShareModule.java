package bhumi.customInstagramShare;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Point;
import android.net.Uri;
import android.os.AsyncTask;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;
import android.os.Environment;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.net.URL;
import java.util.Timer;
import java.util.TimerTask;
import java.io.FileOutputStream;
import java.io.ObjectOutputStream;

import android.content.pm.PackageManager;

public class CustomInstagramShareModule extends ReactContextBaseJavaModule implements ActivityEventListener {
    private Activity mActivity;
    private ReactApplicationContext reactContext;
    private Callback callback;

    final int INSTAGRAM_SHARE_REQUEST = 500;

    public CustomInstagramShareModule(ReactApplicationContext reactContext, Activity activity) {
        super(reactContext);
        this.mActivity = activity;
        this.reactContext = reactContext;
        this.reactContext.addActivityEventListener(new RNInstagramShareActivityEventListener());
    }

    private class RNInstagramShareActivityEventListener extends BaseActivityEventListener {
        @Override
        public void onActivityResult(Activity activity, final int requestCode, final int resultCode, final Intent intent) {
            if (requestCode == INSTAGRAM_SHARE_REQUEST) {
                callback.invoke();
            }
        }
    }

    @Override
    public String getName() {
        return "RNCustomShare";
    }

    @ReactMethod
    public void shareWithInstagram(String base64ImageData , Callback callback) {
        try {
            this.callback = callback;

            String type = "image/*";

           if(isAppInstalled("com.instagram.android") == false){
             callback.invoke("Sorry,instagram is not installed in your device.");
           }else {
               // Create the new Intent using the 'Send' action.
               Intent share = new Intent(Intent.ACTION_SEND);

               // Set the MIME type
               share.setType(type);
               share.setPackage("com.instagram.android");

               //Create the URI from the media
               Uri uri = saveImageToPath(base64ImageData);

               // Add the URI to the Intent.
               share.putExtra(Intent.EXTRA_STREAM, uri);

               // Broadcast the Intent.
               mActivity.startActivityForResult(share, INSTAGRAM_SHARE_REQUEST);

            }
        }catch (Exception e) {
            Log.d("e", e.toString());
        }
    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {

    }

    @Override
    public void onNewIntent(Intent intent) {

    }

    private boolean isAppInstalled(String packageName) {
        PackageManager pm = mActivity.getPackageManager();
        boolean installed = false;
        try {
           pm.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES);
           installed = true;
        } catch (PackageManager.NameNotFoundException e) {
           installed = false;
        }
        return installed;
    }

    private Bitmap decodeStringToImage(String base64ImageData) {
        byte[] decodedString = Base64.decode(base64ImageData, Base64.DEFAULT);
        Bitmap image = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
        return image;
    }

    private Uri saveImageToPath(String base64ImageData) {
        Bitmap image = decodeStringToImage(base64ImageData);

        File pictureFile = getTemporaryImageFile(".png");
        if (pictureFile == null) {
            Log.d("Error", "creating media file, check storage permissions: ");
            return null;
        }
        try {
            FileOutputStream fos = new FileOutputStream(pictureFile);
            image.compress(Bitmap.CompressFormat.PNG, 90, fos);
            fos.flush();
            fos.close();
        } catch (Exception e) {
            Log.d("Exception: ", e.getMessage());
        }

        String mediaPath = pictureFile.getPath();
        File media = new File(mediaPath);
        Uri uri = Uri.fromFile(pictureFile);

        return uri;
    }

    private File getTemporaryImageFile( String extension ) {
        File tempFolder = new File(Environment.getExternalStorageDirectory()+File.separator+"CustomShareTmpFolder");
        if (!tempFolder.exists()) {
            tempFolder.mkdir();
            try {
                new File(tempFolder, ".nomedia").createNewFile();
            } catch (Exception e) {}
        }

        return new File(tempFolder, String.valueOf(System.currentTimeMillis())+extension);
    }
}
