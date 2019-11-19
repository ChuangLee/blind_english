package pro.lichuang.blindenglish

import android.content.Intent
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import pro.lichuang.blindenglish.service.QuietPlayerChannel
import pro.lichuang.blindenglish.service.NeteaseCrypto
import android.media.session.MediaSession
import android.view.KeyEvent
import android.os.Parcelable
import android.view.View
import pro.lichuang.blindenglish.player.QuietMusicPlayer
import com.google.android.exoplayer2.Player


class MainActivity : FlutterActivity() {

    private var mSession: MediaSession? = null
    private val tag = ":Flutter_BlindEnglish"

    companion object {

        /**
         * 网易云音乐加密
         */
        const val CHANNEL_NETEASE_CRYPTO = "tech.soit.netease/crypto"


        const val KEY_DESTINATION = "destination"

        const val DESTINATION_PLAYING_PAGE = "action_playing_page"

    }

    private lateinit var playerChannel: QuietPlayerChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        NeteaseCrypto.init(flutterView)
        playerChannel = QuietPlayerChannel.registerWith(registrarFor("pro.lichuang.blindenglish.service.QuietPlayerChannel"))
        findViewById<View>(android.R.id.content).keepScreenOn = true
    }

    override fun onResume() {
        createMediaSession()
        super.onResume()
    }

    override fun onDestroy() {
        playerChannel.destroy()
        releaseMediaSession()
        super.onDestroy()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        when (intent.getStringExtra(KEY_DESTINATION)) {
            DESTINATION_PLAYING_PAGE -> {
                flutterView.pushRoute("/playing")
            }
        }
    }

    private fun createMediaSession() {
        if (this.mSession === null) {
            mSession = MediaSession(this, tag)
            mSession?.setCallback(mSessionCallback)
            mSession?.isActive = true
        }
    }

    private fun releaseMediaSession() {
        mSession?.setCallback(null)
        mSession?.isActive = false
        mSession?.release()
        mSession = null
    }

    private val mSessionCallback = object : MediaSession.Callback() {
        override fun onMediaButtonEvent(mediaIntent: Intent): Boolean {
            if (Intent.ACTION_MEDIA_BUTTON == mediaIntent.action) {
                val event = mediaIntent.getParcelableExtra<Parcelable>(Intent.EXTRA_KEY_EVENT) as KeyEvent
                if (KeyEvent.ACTION_DOWN == event.action) {
                    when (event.keyCode) {
                        KeyEvent.KEYCODE_MEDIA_PREVIOUS -> this@MainActivity.onRewind()
                        KeyEvent.KEYCODE_MEDIA_NEXT -> onPlayNext()
                        KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE -> onPausePlay()
                        KeyEvent.KEYCODE_MEDIA_PAUSE -> onPausePlay()
                        KeyEvent.KEYCODE_MEDIA_PLAY -> onPausePlay()
                    }
                    return true
                }
            }
            return false
        }
    }

    private fun onPausePlay() {
        var musicPlayer = QuietMusicPlayer.getInstance()
        musicPlayer.playWhenReady = !(musicPlayer.playWhenReady && musicPlayer.playbackState == Player.STATE_READY)
    }

    private fun onPlayNext() {
        var musicPlayer = QuietMusicPlayer.getInstance()
        musicPlayer.playNext()
    }

    private fun onRewind() {
        playerChannel.rewind()
    }

}
