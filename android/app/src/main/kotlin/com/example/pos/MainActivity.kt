package com.example.pos

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.easypay.pos/pegasus"
    private val REQUEST_CODE_PEGASUS = 1001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchPegasus") {
                pendingResult = result

                val intent = Intent()
                intent.setClassName(
                    "com.example.intent_app",
                    "com.example.intent_app.MainActivity"
                )
                intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)

                intent.putExtra("TransactionType", call.argument<String>("TransactionType"))
                intent.putExtra("Amount", call.argument<String>("Amount"))
                intent.putExtra("CashBackAmount", call.argument<String>("CashBackAmount"))
                intent.putExtra("UniqueId", call.argument<String>("UniqueId"))
                intent.putExtra("RefNo", call.argument<String>("RefNo"))
                intent.putExtra("IsLocalRequest", call.argument<String>("IsLocalRequest"))

                try {
                    startActivityForResult(intent, REQUEST_CODE_PEGASUS)
                } catch (e: Exception) {
                    pendingResult?.error("LAUNCH_ERROR", e.message, null)
                    pendingResult = null
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE_PEGASUS) {
            if (pendingResult == null) return

            if (resultCode == RESULT_OK) {
                val responseMap = mutableMapOf<String, String?>()

                data?.extras?.keySet()?.forEach { key ->
                    responseMap[key] = data.getStringExtra(key)
                }

                pendingResult?.success(responseMap)
            } else if (resultCode == RESULT_CANCELED) {
                pendingResult?.error("CANCELLED", "Transaction was cancelled", null)
            } else {
                pendingResult?.error("UNKNOWN_ERROR", "Unknown result code: $resultCode", null)
            }

            pendingResult = null
        }
    }
}
