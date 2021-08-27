package com.app.rtmp_publisher

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.Point
import android.hardware.camera2.CameraAccessException
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CameraMetadata
import android.util.Log
import android.view.SurfaceHolder
import android.view.View
import android.widget.Toast
import com.pedro.encoder.input.gl.render.filters.CartoonFilterRender
import com.pedro.encoder.input.gl.render.filters.FireFilterRender
import com.pedro.encoder.input.gl.render.filters.`object`.ImageObjectFilterRender
import com.pedro.encoder.input.gl.render.filters.`object`.TextObjectFilterRender
import com.pedro.encoder.input.video.CameraHelper.Facing.BACK
import com.pedro.encoder.input.video.CameraHelper.Facing.FRONT
import com.pedro.encoder.utils.gl.TranslateTo
import com.pedro.rtplibrary.rtmp.RtmpCamera2
import com.pedro.rtplibrary.view.LightOpenGlView
import com.pedro.rtplibrary.view.OpenGlView
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import net.ossrs.rtmp.ConnectCheckerRtmp
import java.io.*


class CameraNativeView(
        private var activity: Activity? = null,
        private var enableAudio: Boolean = false,
        private val preset: Camera.ResolutionPreset,
        private var cameraName: String,
        private var dartMessenger: DartMessenger? = null) :
        PlatformView,
        SurfaceHolder.Callback,
        ConnectCheckerRtmp {

    private val glView = OpenGlView(activity)
    private var rtmpCamera: RtmpCamera2

    private var isSurfaceCreated = false
    private var fps = 0

    init {
        glView.isKeepAspectRatio = true
        glView.holder.addCallback(this)
        rtmpCamera = RtmpCamera2(glView, this,4)
        rtmpCamera.setReTries(10)
        rtmpCamera.setFpsListener { fps = it }
    }

    override fun surfaceCreated(holder: SurfaceHolder) {
        Log.d("CameraNativeView", "surfaceCreated")
        isSurfaceCreated = true
        startPreview(cameraName)
    }

    override fun onAuthSuccessRtmp() {
    }

    override fun onNewBitrateRtmp(bitrate: Long) {
    }

    override fun onConnectionSuccessRtmp() {
    }

    override fun onConnectionFailedRtmp(reason: String) {
        activity?.runOnUiThread { //Wait 5s and retry connect stream
            if (rtmpCamera.reTry(5000, reason)) {
                dartMessenger?.send(DartMessenger.EventType.RTMP_RETRY, reason)
            } else {
                dartMessenger?.send(DartMessenger.EventType.RTMP_STOPPED, "Failed retry")
                rtmpCamera.stopStream()
            }
        }
    }

    override fun onAuthErrorRtmp() {
        activity?.runOnUiThread {
            dartMessenger?.send(DartMessenger.EventType.ERROR, "Auth error")
        }
    }

    override fun onDisconnectRtmp() {
        activity?.runOnUiThread {
            dartMessenger?.send(DartMessenger.EventType.RTMP_STOPPED, "Disconnected")
        }
    }

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        Log.d("CameraNativeView", "surfaceChanged $width $height")
    }

    override fun surfaceDestroyed(holder: SurfaceHolder) {
        Log.d("CameraNativeView", "surfaceDestroyed")
    }

    fun close() {
        Log.d("CameraNativeView", "close")
    }

    fun takePicture(filePath: String, result: MethodChannel.Result) {
        Log.d("CameraNativeView", "takePicture filePath: $filePath result: $result")
        val file = File(filePath)
        if (file.exists()) {
            result.error("fileExists", "File at path '$filePath' already exists. Cannot overwrite.", null)
            return
        }
        glView.takePhoto {
            try {
                val outputStream: OutputStream = BufferedOutputStream(FileOutputStream(file))
                it.compress(Bitmap.CompressFormat.JPEG, 100, outputStream)
                outputStream.close()
                view.post { result.success(null) }
            } catch (e: IOException) {
                result.error("IOError", "Failed saving image", null)
            }
        }
    }

    fun startVideoRecording(filePath: String?, result: MethodChannel.Result) {
        val file = File(filePath)
        if (file.exists()) {
            result.error("fileExists", "File at path '$filePath' already exists. Cannot overwrite.", null)
            return
        }
        Log.d("CameraNativeView", "startVideoRecording filePath: $filePath result: $result")
    }

    fun startVideoStreaming(url: List<String>?, result: MethodChannel.Result) {
//        rtmpCamera = RtmpCamera2(glView, this, url!!.size)
        Log.d("CameraNativeView", "startVideoStreaming url: $url, urlSize:${url!!.size}")
        if (url == null) {
            result.error("startVideoStreaming", "Must specify a url.", null)
            return
        }

        try {
            if (!rtmpCamera.isStreaming) {
                val streamingSize = CameraUtils.getBestAvailableCamcorderProfileForResolutionPreset(cameraName, preset)
                if (rtmpCamera.isRecording || rtmpCamera.prepareAudio() && rtmpCamera.prepareVideo(
                                streamingSize.videoFrameWidth,
                                streamingSize.videoFrameHeight,
                                streamingSize.videoBitRate)) {
                    // ready to start streaming
                    rtmpCamera.startStream(url)
//                    rtmpCamera.glInterface.setFilter( FireFilterRender())

                } else {
                    result.error("videoStreamingFailed", "Error preparing stream, This device cant do it", null)
                    return
                }
            } else {
                rtmpCamera.stopStream()
            }
            result.success(null)
        } catch (e: CameraAccessException) {
            result.error("videoStreamingFailed", e.message, null)
        } catch (e: IOException) {
            result.error("videoStreamingFailed", e.message, null)
        }
    }
    fun addTextToStream(text: String, size: Int, color: Int){

        val textObjectFilterRender = TextObjectFilterRender()
        var textColor= Color.BLACK
        if (color!=null&&color==1){
            textColor= Color.WHITE
        }
//        rtmpCamera.glInterface.setFilter(2, textObjectFilterRender)
        rtmpCamera!!.glInterface!!.setFilter(2, textObjectFilterRender)

        textObjectFilterRender.setText(text ?: "Hello world", size.toFloat(), textColor)
        textObjectFilterRender.setDefaultScale(rtmpCamera!!.streamWidth,
            rtmpCamera!!.streamHeight)
//        when (size) {
//            0 -> textObjectFilterRender.setScale(30f, 10f)
//
//            1 -> textObjectFilterRender.setScale(32f, 25f)
//
//            2 -> textObjectFilterRender.setScale(60f, 40f)
//
//            else -> { // Note the block
//                textObjectFilterRender.setScale(45f, 30f)
//
//            }
//        }
////
        textObjectFilterRender.setPosition(TranslateTo.BOTTOM_LEFT)
    }
    fun resizeBitmap(source: Bitmap, maxLength: Int): Bitmap {
        try {
            if (source.height >= source.width) {
                if (source.height <= maxLength) { // if image height already smaller than the required height
                    return source
                }

                val aspectRatio = source.width.toDouble() / source.height.toDouble()
                val targetWidth = (maxLength * aspectRatio).toInt()
                val result = Bitmap.createScaledBitmap(source, targetWidth, maxLength, false)
                return result
            } else {
                if (source.width <= maxLength) { // if image width already smaller than the required width
                    return source
                }

                val aspectRatio = source.height.toDouble() / source.width.toDouble()
                val targetHeight = (maxLength * aspectRatio).toInt()

                val result = Bitmap.createScaledBitmap(source, maxLength, targetHeight, false)
                return result
            }
        } catch (e: Exception) {
            return source
        }
    }

    fun addImageToStream(image: ByteArray, scale: Int){
        val bitmap = BitmapFactory.decodeByteArray(image, 0, image.size)
        val resizedImg=resizeBitmap(bitmap, rtmpCamera!!.streamHeight)
        println("**************gilli*****************")

        val imageObjectFilterRender = ImageObjectFilterRender()
        rtmpCamera!!.glInterface!!.setFilter(3, imageObjectFilterRender)
        imageObjectFilterRender.setImage(resizedImg)

//        imageObjectFilterRender.setDefaultScale((rtmpCamera!!.streamWidth),
//            (rtmpCamera!!.streamHeight))
        imageObjectFilterRender.setScale((resizedImg.width/scale).toFloat(),
            (resizedImg.height/scale).toFloat())
        imageObjectFilterRender.setPosition(TranslateTo.RIGHT)

    }
    fun addCtaImageToStream(image: ByteArray,scale : Int){
        val bitmap = BitmapFactory.decodeByteArray(image, 0, image.size)
        val resizedImg=resizeBitmap(bitmap, rtmpCamera!!.streamWidth)


        val imageObjectFilterRender = ImageObjectFilterRender()
        rtmpCamera!!.glInterface!!.setFilter(0, imageObjectFilterRender)
        imageObjectFilterRender.setImage(resizedImg)
        println("**************gilli*****************")
        println(rtmpCamera!!.streamWidth)
        imageObjectFilterRender.setDefaultScale((rtmpCamera!!.streamWidth),
            (rtmpCamera!!.streamHeight))
        imageObjectFilterRender.setScale((resizedImg.width/scale).toFloat(),
                (resizedImg.height/scale).toFloat())
        imageObjectFilterRender.setPosition(TranslateTo.BOTTOM_RIGHT)

    }
    fun addDegpegToStream(image: ByteArray,scale:Int){
        val bitmap = BitmapFactory.decodeByteArray(image, 0, image.size)
        val resizedImg=resizeBitmap(bitmap, rtmpCamera!!.streamWidth)
        println("**************gilli*****************")

        val imageObjectFilterRender = ImageObjectFilterRender()
        rtmpCamera!!.glInterface!!.setFilter(1, imageObjectFilterRender)
        imageObjectFilterRender.setImage(bitmap)

        imageObjectFilterRender.setDefaultScale((rtmpCamera!!.streamWidth),
            (rtmpCamera!!.streamHeight))
        imageObjectFilterRender.setScale((resizedImg.width/scale).toFloat(),
            (resizedImg.height/scale).toFloat())
        imageObjectFilterRender.setPosition(TranslateTo.TOP_RIGHT)

    }
    fun startVideoRecordingAndStreaming(filePath: String?, url: String?, result: MethodChannel.Result) {
        Log.d("CameraNativeView", "startVideoStreaming url: $url")
        // TODO: Implement video recording
//        startVideoStreaming(url, result)
    }

    fun pauseVideoStreaming(result: Any) {
        // TODO: Implement pause video streaming
    }

    fun resumeVideoStreaming(result: Any) {
        // TODO: Implement resume video streaming
    }

    fun stopVideoRecordingOrStreaming(result: MethodChannel.Result) {
        try {
            rtmpCamera.apply {
                if (isStreaming) stopStream()
                if (isRecording) stopRecord()
            }
            result.success(null)
        } catch (e: CameraAccessException) {
            result.error("videoRecordingFailed", e.message, null)
        } catch (e: IllegalStateException) {
            result.error("videoRecordingFailed", e.message, null)
        }
    }

    fun stopVideoRecording(result: MethodChannel.Result) {
        try {
            rtmpCamera.apply {
                if (isRecording) stopRecord()
            }
            result.success(null)
        } catch (e: CameraAccessException) {
            result.error("stopVideoRecordingFailed", e.message, null)
        } catch (e: IllegalStateException) {
            result.error("stopVideoRecordingFailed", e.message, null)
        }
    }

    fun stopVideoStreaming(result: MethodChannel.Result) {
        try {
            rtmpCamera.apply {
                if (isStreaming) stopStream()
            }
            result.success(null)
        } catch (e: CameraAccessException) {
            result.error("stopVideoStreamingFailed", e.message, null)
        } catch (e: IllegalStateException) {
            result.error("stopVideoStreamingFailed", e.message, null)
        }
    }

    fun pauseVideoRecording(result: Any) {
        // TODO: Implement pause Video Recording
    }

    fun resumeVideoRecording(result: Any) {
        // TODO: Implement resume video recording
    }

    fun startPreviewWithImageStream(imageStreamChannel: Any) {
        // TODO: Implement start preview with image stream
    }

    fun startPreview(cameraNameArg: String? = null) {
        val targetCamera = if (cameraNameArg.isNullOrEmpty()) {
            cameraName
        } else {
            cameraNameArg
        }
        cameraName = targetCamera
        val previewSize = CameraUtils.computeBestPreviewSize(cameraName, preset)

        Log.d("CameraNativeView", "startPreview: $preset")
        if (isSurfaceCreated) {
            try {
                if (rtmpCamera.isOnPreview) {
                    rtmpCamera.stopPreview()
                }

                rtmpCamera.startPreview(if (isFrontFacing(targetCamera)) FRONT else BACK, previewSize.width, previewSize.height)
            } catch (e: CameraAccessException) {
//                close()
                activity?.runOnUiThread { dartMessenger?.send(DartMessenger.EventType.ERROR, "CameraAccessException") }
                return
            }
        }
    }

    fun getStreamStatistics(result: MethodChannel.Result) {
        val ret = hashMapOf<String, Any>()
        ret["cacheSize"] = rtmpCamera.cacheSize
        ret["sentAudioFrames"] = rtmpCamera.sentAudioFrames
        ret["sentVideoFrames"] = rtmpCamera.sentVideoFrames
        ret["droppedAudioFrames"] = rtmpCamera.droppedAudioFrames
        ret["droppedVideoFrames"] = rtmpCamera.droppedVideoFrames
        ret["isAudioMuted"] = rtmpCamera.isAudioMuted
        ret["bitrate"] = rtmpCamera.bitrate
        ret["width"] = rtmpCamera.streamWidth
        ret["height"] = rtmpCamera.streamHeight
        ret["fps"] = fps
        result.success(ret)
    }

    override fun getView(): View {
        return glView
    }

    override fun dispose() {
        isSurfaceCreated = false
        activity = null
    }

    private fun isFrontFacing(cameraName: String): Boolean {
        val cameraManager = activity?.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        val characteristics = cameraManager.getCameraCharacteristics(cameraName)
        return characteristics.get(CameraCharacteristics.LENS_FACING) == CameraMetadata.LENS_FACING_FRONT
    }
}
