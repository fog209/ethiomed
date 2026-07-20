package com.wardready.app

import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.Signature
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    private val securityChannel = "com.wardready.app/security"
    private val installerChannel = "com.wardready.app/installer"

    override fun onCreate(savedInstanceState: Bundle?) {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, securityChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "getSha256Signature") {
                    try {
                        val signature = getSigningCertificateSha256()
                        result.success(signature)
                    } catch (e: Exception) {
                        result.error("SIGNATURE_ERROR", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, installerChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canRequestPackageInstalls" -> {
                        result.success(canRequestPackageInstalls())
                    }
                    "openInstallSettings" -> {
                        try {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                                Uri.parse("package:$packageName")
                            )
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("INSTALL_SETTINGS_ERROR", e.message, null)
                        }
                    }
                    "installApk" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("MISSING_PATH", "APK path argument required", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val installed = installApk(File(path))
                            result.success(installed)
                        } catch (e: Exception) {
                            result.error("INSTALL_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun canRequestPackageInstalls(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            packageManager.canRequestPackageInstalls()
        } else {
            true
        }
    }

    private fun installApk(apkFile: File): Boolean {
        if (!apkFile.exists()) {
            throw IllegalArgumentException("APK file does not exist: ${apkFile.absolutePath}")
        }
        val uri = FileProvider.getUriForFile(
            this,
            "$packageName.fileprovider",
            apkFile
        )
        val intent = Intent(Intent.ACTION_INSTALL_PACKAGE).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        if (intent.resolveActivity(packageManager) == null) {
            throw IllegalStateException("No activity available to handle APK install")
        }
        startActivity(intent)
        return true
    }

    private fun getSigningCertificateSha256(): ByteArray {
        val packageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
        val signatures: Array<Signature>? = packageInfo.signatures
        if (signatures == null || signatures.isEmpty()) {
            throw SecurityException("No app signatures found")
        }
        val md = MessageDigest.getInstance("SHA-256")
        md.update(signatures[0].toByteArray())
        return md.digest()
    }
}
