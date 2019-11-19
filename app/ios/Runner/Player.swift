import AVFoundation
import Flutter

class Player: NSObject {
    let CHANNEL_NAME = "pro.lichuang.blindenglish/player"
    let OBSERVER_KEY_STATUS = "player.currentItem.status"

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?

    private var isPlaying = false
    private var lastUrl = ""
    private var observers: Set<AnyHashable> = []
    private var timeobservers: Set<AnyHashable> = []

    private var position = 0

    private var playlist: [[String: Any]] = [] {
        didSet {
            channel?.invokeMethod("onPlaylistUpdated", arguments: ["token": token ?? "error_token", "list": playlist])
        }
    }

    private var currentMusic: [String: Any]? {
        didSet {
            if oldValue?["url"] as? String != currentMusic?["url"] as? String {
                channel?.invokeMethod("onMusicChanged", arguments: currentMusic)
            }
        }
    }

    // 0单曲循环，1顺序，2随机，目前不支持随机
    private var playMode: Int = 1
    private var token: String?
    private var initialized: Bool = false
    private var playWhenReady: Bool = false

    //    private var playStatus: AVPlayer.Status

    private var channel: FlutterMethodChannel?
    private var viewController: FlutterViewController

    init(_ viewController: FlutterViewController) {
        self.viewController = viewController
        channel = FlutterMethodChannel(name: CHANNEL_NAME,
                                       binaryMessenger: viewController)

        super.init()
    }

    func initListeners() {
        channel?.setMethodCallHandler {
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            print("\(call.method) method calld.")
            self.handle(call: call, result: result)
        }
        initRemoteEvents()
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            } else {}
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("error:\(error.localizedDescription)")
        }
    }

    func initRemoteEvents() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == OBSERVER_KEY_STATUS {
            if player?.currentItem?.status == .readyToPlay {
                onStart()

            } else if player?.currentItem?.status == .failed {
                channel?.invokeMethod("onPlayerError", arguments: [
                    // TODO:
                    "type": 0,
                    "message": player?.currentItem?.error?.localizedDescription ?? "no error message",
                ])
            } else {
                // Any unrecognized context must belong to super
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }
    }

    func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        typealias CaseBlock = () -> Void
        // Squint and this looks like a proper switch!
        let methods = [
            "init": {
                let args = call.arguments as? [String: Any]
                print("handle init method calld.")
                if self.initialized {} else {
                    let token = args?["token"] as? String
                    print("received token: \(token ?? "ops None")")

                    self.playlist = args?["list"] as? [[String: Any]] ?? []
                    self.currentMusic = args?["music"] as? [String: Any]
                    self.playMode = args?["playMode"] as? Int ?? 1
                    self.initialized = true
                }
            },
            "setPlayWhenReady": {
                let playing = call.arguments as? Bool ?? false
                if !playing {
                    self.pause()
                } else {
                    self.play()
                }
                result(nil)
            },
            "playWithMusic": {
                let args = call.arguments as? [String: Any]
                self.currentMusic = args
                if self.currentMusic != nil {
                    self.play(self.currentMusic!)
                }
                result(nil)
            },
            "playNext": {
                self.playNext()
                result(nil)
            },
            "playPrevious": {
                self.playPrevious()
                result(nil)
            },
            "updatePlaylist": {
                let args = call.arguments as? [String: Any]
                self.token = args?["token"] as? String
                self.playlist = args?["list"] as? [[String: Any]] ?? []
                //                self.currentMusic = args?["music"] as? Dictionary<String,Any>
                self.playMode = args?["playMode"] as? Int ?? 1
                result(nil)
            },
            "seekTo": {
                let toTime = Double(call.arguments as? Int ?? 0)
                self.seek(CMTimeMakeWithSeconds(toTime / 1000.0, preferredTimescale: 1))
                result(nil)
            },
            "setVolume": {},
            "setPlayMode": {
                let mode = call.arguments as? Int ?? 1
                self.playMode = mode
                result(nil)
            },
            "position": {
                result(self.position)
                result(nil)
            },
            "duration": {
                result(self.currentDuration())
                result(nil)
            },
        ]

        let c = methods[call.method]
        if c != nil {
            c?()
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    func playWhenReady(_ playWhenReady: Bool) {
        self.playWhenReady = playWhenReady
        if self.playWhenReady {
            if currentMusic != nil {
                play(currentMusic!)
            } else {
                playNext()
            }
        }
    }

    func currentIndex() -> Int {
        if currentMusic != nil {
            let currentIndex = playlist.firstIndex(where: { (music) -> Bool in
                music["url"] as? String == self.currentMusic!["url"] as? String?
            }) ?? -1
            return currentIndex
        }
        return -1
    }

    func play() {
        if currentMusic != nil {
            play(currentMusic!)
        }
    }

    func play(_ music: [String: Any]) {
        if !playlist.contains(where: { (music) -> Bool in
            music["url"] as? String == currentMusic!["url"] as? String?
        }) {
            var currentIndex = self.currentIndex()
            currentIndex = currentIndex >= 0 ? currentIndex : 0
            playlist.insert(music, at: currentIndex)
        }
        currentMusic = music
        play(url: music["url"] as! String, isLocal: false)
    }

    func playNext() {
        guard playlist.count > 0 else {
            return
        }
        var next = playlist[0]
        if currentMusic != nil {
            let currentIndex = self.currentIndex()

            if currentIndex >= 0 || currentIndex < playlist.count - 2 {
                next = playlist[currentIndex + 1]
            }
        }
        play(next)
    }

    func playPrevious() {
        guard playlist.count > 0 else {
            return
        }
        var previous = playlist[0]
        if currentMusic != nil {
            let currentIndex = self.currentIndex()

            if currentIndex > 0 || currentIndex < playlist.count {
                previous = playlist[currentIndex - 1]
            } else if currentIndex == 0 {
                previous = playlist.last!
            }
        }
        play(previous)
    }

    func play(url: String, isLocal: Bool) {
        if !(url == lastUrl) {
            playerItem?.removeObserver(self, forKeyPath: OBSERVER_KEY_STATUS)

            for ob: Any? in observers {
                if let ob = ob {
                    NotificationCenter.default.removeObserver(ob)
                }
            }
            //            observers = nil

            if isLocal {
                playerItem = AVPlayerItem(url: URL(fileURLWithPath: url))
            } else {
                if let url = URL(string: url) {
                    playerItem = AVPlayerItem(url: url)
                }
            }
            lastUrl = url

            let anobserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil, using: { _ in
                if self.playMode == 0 {
                    self.seek(CMTimeMakeWithSeconds(0.0, preferredTimescale: 1))
                    self.play()
                    return
                } else {
                    self.playNext()
                }
            })

            observers.insert(anobserver as! AnyHashable)

            if player != nil {
                player?.replaceCurrentItem(with: playerItem)
            } else {
                player = AVPlayer(playerItem: playerItem)
                // Stream player position.
                // This call is only active when the player is active so there's no need to
                // remove it when player is paused or stopped.
                let interval: CMTime = CMTimeMakeWithSeconds(0.2, preferredTimescale: Int32(NSEC_PER_SEC))
                let timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: { time in
                    self.onTimeInterval(time)
                })
                timeobservers.insert(timeObserver as! AnyHashable)
            }

            // is sound ready
            player?.currentItem?.addObserver(self, forKeyPath: OBSERVER_KEY_STATUS, options: [], context: nil)
        }

        player?.play()
        isPlaying = true
        onStart()
        UIApplication.shared.isIdleTimerDisabled = true
    }

    func pause() {
        UIApplication.shared.isIdleTimerDisabled = false
        player?.pause()
        isPlaying = false
        // TODO: 3 means ready on Android platform
        channel?.invokeMethod("onPlayerStateChanged", arguments: [
            "playWhenReady": false,
            "playbackState": 0,
        ])
    }

    func playOrPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func stop() {
        UIApplication.shared.isIdleTimerDisabled = false
        if isPlaying {
            player?.pause()
            isPlaying = false
        }
        playerItem?.seek(to: CMTimeMake(value: 0, timescale: 1))
    }

    func rewind() {
        channel?.invokeMethod("onRewind", arguments: nil)
    }

    private func seek(_ time: CMTime) {
        playerItem?.seek(to: time)
    }

    private func onStart() {
        // TODO: 3 means ready on Android platform
        channel?.invokeMethod("onPlayerStateChanged", arguments: [
            "playWhenReady": true,
            "playbackState": 3,
        ])
    }

    private func onTimeInterval(_ time: CMTime?) {
        let duration = currentDuration()
        if duration > 0 {
            let seconds: Int = (time == nil ? 0 : Int(CMTimeGetSeconds(time!) * 1000))
            position = seconds
            channel?.invokeMethod("onPositionChanged", arguments: [
                "position": seconds,
                "duration": duration,
            ])
        }
    }

    private func currentDuration() -> Int {
        let durationTime: CMTime? = player?.currentItem?.duration
        if durationTime != nil, CMTimeGetSeconds(durationTime!) > 0 {
            let duration = Int(CMTimeGetSeconds(durationTime!) * 1000)
            return duration
        }
        return 0
    }

    deinit {
        for ob: Any? in timeobservers {
            if let ob = ob {
                self.player?.removeTimeObserver(ob)
            }
        }

        for ob: Any? in observers {
            if let ob = ob {
                NotificationCenter.default.removeObserver(ob)
            }
        }
    }
}
