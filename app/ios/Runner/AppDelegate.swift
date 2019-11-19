import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var player : Player?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        
        player = Player(controller)
        player?.initListeners()

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if event?.type == UIEvent.EventType.remoteControl{
            switch event!.subtype {
            case UIEvent.EventSubtype.remoteControlPlay:
                player?.play()
            case UIEvent.EventSubtype.remoteControlPause:
                player?.pause()
            case UIEvent.EventSubtype.remoteControlStop:
                player?.stop()
            case UIEvent.EventSubtype.remoteControlTogglePlayPause:
                player?.playOrPause()
            case UIEvent.EventSubtype.remoteControlNextTrack:
                player?.playNext()
            case UIEvent.EventSubtype.remoteControlPreviousTrack:
                player?.rewind()
            default:
                print("unkown event: \(event!)")
            }
        }
    }
    
}
