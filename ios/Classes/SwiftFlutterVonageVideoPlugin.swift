import Flutter
import UIKit

import OpenTok

public class SwiftFlutterVonageVideoPlugin: NSObject, FlutterPlugin {
	var nativeView: FlutterPlatformView?
	var nativeViewFactory: FLNativeViewFactory?
	var session: OTSession?
  var publisher: OTPublisher?

  public init(with registrar: FlutterPluginRegistrar) {
  	super.init()
  	let channel = FlutterMethodChannel(name: "flutter_vonage_video", binaryMessenger: registrar.messenger())
    // let instance = SwiftFlutterVonageVideoPlugin()
    registrar.addMethodCallDelegate(self, channel: channel)

  	let factory = FLNativeViewFactory(messenger: registrar.messenger())
    nativeViewFactory = factory
    print ("init nativeView", nativeViewFactory)
    registrar.register(factory, withId: "flutter-vonage-video-publisher")
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    // let channel = FlutterMethodChannel(name: "flutter_vonage_video", binaryMessenger: registrar.messenger())
    // let instance = SwiftFlutterVonageVideoPlugin()
    // registrar.addMethodCallDelegate(instance, channel: channel)

    registrar.addApplicationDelegate(SwiftFlutterVonageVideoPlugin(with: registrar))

    // let factory = FLNativeViewFactory(messenger: registrar.messenger())
    // // nativeView = factory.platformView
    // registrar.register(factory, withId: "flutter-vonage-video-publisher")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
  	var args = call.arguments as! Dictionary<String, Any>
  	if call.method == "initSession" {
  		var sessionId: String = args["sessionId"] as! String
  		var token: String = args["token"] as! String
  		var apiKey: String = args["apiKey"] as! String
  		initSession(sessionId: sessionId, token: token, apiKey: apiKey, result: result)
  	} else if call.method == "endSession" {
  		endSession(result: result)
  	} else if call.method == "publishStream" {
  		var name: String = args["name"] as! String
  		var viewId: Int = args["viewId"] as! Int
  		publishStream(name: name, viewId: viewId, result: result)
  	} else if call.method == "unpublishStream" {
  		unpublishStream(result: result)
  	} else {
    	result("iOS " + UIDevice.current.systemVersion)
    }
  }

  func initSession(sessionId: String, token: String, apiKey: String, result: FlutterResult) {
  	session = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)
    var error: OTError?
    session?.connect(withToken: token, error: &error)
    if error != nil {
       print(error!)
    }
    result("")
  }

  func endSession(result: FlutterResult) {
  	session?.disconnect()
  	result("")
  }

  func publishStream(name: String, viewId: Int, result: FlutterResult) {
  	let settings = OTPublisherSettings()
    // settings.name = UIDevice.current.name
    settings.name = name
    guard let publisher = OTPublisher(delegate: self, settings: settings) else {
      return
    }

    var error: OTError?
    session?.publish(publisher, error: &error)
    guard error == nil else {
      print(error!)
      return
    }

    // print ("publishStream", SwiftFlutterVonageVideoPlugin.nativeView)
    // var view: UIView = SwiftFlutterVonageVideoPlugin.nativeView!.view()
    var view: UIView = nativeViewFactory!.getView()
    print ("publishStream", nativeViewFactory, view)
    // print ("publishStream", viewId)
    // var view: UIView = nativeView!.view()

    guard let publisherView = publisher.view else {
      return
    }

    // let screenBounds = UIScreen.main.bounds
    // publisherView.frame = CGRect(x: screenBounds.width - 150 - 20, y: screenBounds.height - 150 - 20, width: 150, height: 150)
    publisherView.frame = view.bounds

    view.addSubview(publisherView)
    // view.backgroundColor = UIColor.red

  	result("")
  }

  func unpublishStream(result: FlutterResult) {
  	if publisher != nil {
  		session?.unpublish(publisher!)
  	}

  	// TODO - get typing errors..
  // 	for view in nativeView!.view()!.subviews {
		//   view.removeFromSuperview()
		// }

  	result("")
  }
}

extension SwiftFlutterVonageVideoPlugin: OTSessionDelegate {
	public func sessionDidConnect(_ session: OTSession) {
		print("The client connected to the OpenTok session.")
	}

	public func sessionDidDisconnect(_ session: OTSession) {
		print("The client disconnected from the OpenTok session.")
	}

	public func session(_ session: OTSession, didFailWithError error: OTError) {
		print("The client failed to connect to the OpenTok session: \(error).")
	}

	public func session(_ session: OTSession, streamCreated stream: OTStream) {
		print("A stream was created in the session.")
	}

	public func session(_ session: OTSession, streamDestroyed stream: OTStream) {
		print("A stream was destroyed in the session.")
	}
}

extension SwiftFlutterVonageVideoPlugin: OTPublisherDelegate {
	public func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
		print("The publisher failed: \(error)")
	}
}
