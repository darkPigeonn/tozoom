package com.darkPigeonn.tozoom;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import androidx.annotation.NonNull;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import us.zoom.sdk.CustomizedNotificationData;
import us.zoom.sdk.InMeetingNotificationHandle;
import us.zoom.sdk.InMeetingService;
import us.zoom.sdk.JoinMeetingOptions;
import us.zoom.sdk.JoinMeetingParams;
import us.zoom.sdk.MeetingService;
import us.zoom.sdk.MeetingStatus;
import us.zoom.sdk.MeetingViewsOptions;
import us.zoom.sdk.StartMeetingOptions;
import us.zoom.sdk.StartMeetingParams4NormalUser;
import us.zoom.sdk.ZoomAuthenticationError;
import us.zoom.sdk.ZoomError;
import us.zoom.sdk.ZoomSDK;
import us.zoom.sdk.ZoomSDKAuthenticationListener;
import us.zoom.sdk.ZoomSDKInitParams;
import us.zoom.sdk.ZoomSDKInitializeListener;


/** TozoomPlugin */
public class TozoomPlugin implements FlutterPlugin,MethodCallHandler{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  Activity activity;
  private Result pendingResult;

  private MethodChannel channel;
  private Context context;
  private EventChannel meetingStatusChannel;
  private InMeetingService inMeetingService;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "tozoom");
    channel.setMethodCallHandler(this);

    meetingStatusChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "tozoom_event_stream");
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
//    if (call.method.equals("getPlatformVersion")) {
//      result.success("Android 12" + android.os.Build.VERSION.RELEASE);
//    } else {
//      result.notImplemented();
//    }
    switch (call.method) {
      case "init":
        init(call, result);
        break;
      case "join":
        joinMeeting(call, result);
        break;
      case "meeting_status":
        meetingStatus(result);
        break;

    }

  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private void init(final MethodCall methodCall, final Result result) {
    Map<String, String> options = methodCall.arguments();

    ZoomSDK zoomSDK = ZoomSDK.getInstance();

    if(zoomSDK.isInitialized()) {
      List<Integer> response = Arrays.asList(0, 0);
      result.success(response);
      return;
    }

    ZoomSDKInitParams initParams = new ZoomSDKInitParams();
    initParams.appKey = options.get("appKey");
    initParams.appSecret = options.get("appSecret");
    initParams.domain = options.get("domain");
    initParams.enableLog = true;

    final InMeetingNotificationHandle handle= (context, intent) -> {
      intent = new Intent(context, TozoomPlugin.class);
      intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
      if(context == null) {
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      }
      intent.setAction(InMeetingNotificationHandle.ACTION_RETURN_TO_CONF);
      assert context != null;
      context.startActivity(intent);
      return true;
    };

    //Set custom Notification fro android
    final CustomizedNotificationData data = new CustomizedNotificationData();
    data.setContentTitleId(R.string.app_name_zoom_local);
    data.setLargeIconId(R.drawable.zm_mm_type_emoji);
    data.setSmallIconId(R.drawable.zm_mm_type_emoji);
    data.setSmallIconForLorLaterId(R.drawable.zm_mm_type_emoji);

    ZoomSDKInitializeListener listener = new ZoomSDKInitializeListener() {
      /**
       * @param errorCode {@link us.zoom.sdk.ZoomError#ZOOM_ERROR_SUCCESS} if the SDK has been initialized successfully.
       */
      @Override
      public void onZoomSDKInitializeResult(int errorCode, int internalErrorCode) {
        List<Integer> response = Arrays.asList(errorCode, internalErrorCode);

        if (errorCode != ZoomError.ZOOM_ERROR_SUCCESS) {
          System.out.println("Failed to initialize Zoom SDK");
          result.success(response);
          return;
        }

        ZoomSDK zoomSDK = ZoomSDK.getInstance();
        ZoomSDK.getInstance().getMeetingSettingsHelper().enableShowMyMeetingElapseTime(true);
        ZoomSDK.getInstance().getMeetingSettingsHelper().setCustomizedNotificationData(data, handle);

        MeetingService meetingService = zoomSDK.getMeetingService();
        System.out.println(response);
         meetingStatusChannel.setStreamHandler(new StatusStreamHandler(meetingService));
        result.success(response);
      }

      @Override
      public void onZoomAuthIdentityExpired() { }
    };
    zoomSDK.initialize(context, listener, initParams);

  }

  //Join Meeting with passed Meeting ID and Passcode
  private void joinMeeting(MethodCall methodCall, Result result) {

    Map<String, String> options = methodCall.arguments();

    ZoomSDK zoomSDK = ZoomSDK.getInstance();

    if(!zoomSDK.isInitialized()) {
      System.out.println("Not initialized!!!!!!");

      result.success(false);
      return;
    }

    MeetingService meetingService = zoomSDK.getMeetingService();

    JoinMeetingOptions opts = new JoinMeetingOptions();
    opts.no_invite = parseBoolean(options, "disableInvite");
    opts.no_share = parseBoolean(options, "disableShare");
    opts.no_titlebar =  parseBoolean(options, "disableTitlebar");
    opts.no_driving_mode = parseBoolean(options, "disableDrive");
    opts.no_dial_in_via_phone = parseBoolean(options, "disableDialIn");
    opts.no_disconnect_audio = parseBoolean(options, "noDisconnectAudio");
    opts.no_audio = parseBoolean(options, "noAudio");
    boolean view_options = parseBoolean(options, "viewOptions");
    if(view_options){
      opts.meeting_views_options = MeetingViewsOptions.NO_TEXT_MEETING_ID + MeetingViewsOptions.NO_TEXT_PASSWORD;
    }

    JoinMeetingParams params = new JoinMeetingParams();

    params.displayName = options.get("userId");
    params.meetingNo = options.get("meetingId");
    params.password = options.get("meetingPassword");

    meetingService.joinMeetingWithParams(context, params, opts);

    result.success(true);
  }

   //Listen to meeting status on joinning and starting the mmeting
  private void meetingStatus(Result result) {

    ZoomSDK zoomSDK = ZoomSDK.getInstance();

    if(!zoomSDK.isInitialized()) {
      System.out.println("Not initialized!!!!!!");
      result.success(Arrays.asList("MEETING_STATUS_UNKNOWN", "SDK not initialized"));
      return;
    }
    MeetingService meetingService = zoomSDK.getMeetingService();

    if(meetingService == null) {
      result.success(Arrays.asList("MEETING_STATUS_UNKNOWN", "No status available"));
      return;
    }

    MeetingStatus status = meetingService.getMeetingStatus();
    result.success(status != null ? Arrays.asList(status.name(), "") :  Arrays.asList("MEETING_STATUS_UNKNOWN", "No status available"));
  }

  //Helper Function for parsing string to boolean value
  private boolean parseBoolean(Map<String, String> options, String property) {
    return options.get(property) != null && Boolean.parseBoolean(options.get(property));
  }


}
