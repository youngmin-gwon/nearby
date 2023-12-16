package com.youngmin.poc

import android.util.Log
import androidx.annotation.NonNull
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.connection.AdvertisingOptions
import com.google.android.gms.nearby.connection.ConnectionInfo
import com.google.android.gms.nearby.connection.ConnectionLifecycleCallback
import com.google.android.gms.nearby.connection.ConnectionResolution
import com.google.android.gms.nearby.connection.ConnectionsStatusCodes
import com.google.android.gms.nearby.connection.DiscoveredEndpointInfo
import com.google.android.gms.nearby.connection.DiscoveryOptions
import com.google.android.gms.nearby.connection.EndpointDiscoveryCallback
import com.google.android.gms.nearby.connection.Payload
import com.google.android.gms.nearby.connection.PayloadCallback
import com.google.android.gms.nearby.connection.PayloadTransferUpdate
import com.google.android.gms.nearby.connection.Strategy
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

const val SERVICE_ID = "com.youngmin.poc"

const val NEARBY_METHOD_CHANNEL = "nearby_connections"

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
    private lateinit var nearbyChannel: MethodChannel

    override fun configureFlutterEngine(
        @NonNull flutterEngine: FlutterEngine,
    ) {
        super.configureFlutterEngine(flutterEngine)

        nearbyChannel =
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                NEARBY_METHOD_CHANNEL,
            )

        nearbyChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        try {
            when (call.method) {
                "stopAdvertising" -> {
                    Log.d("nearby_connections", "stopAdvertising")
                    Nearby.getConnectionsClient(this).stopAdvertising()
                    result.success(null)
                }

                "stopDiscovery" -> {
                    Log.d("nearby_connections", "stopDiscovery")
                    Nearby.getConnectionsClient(this).stopDiscovery()
                    result.success(null)
                }

                "startAdvertising" -> {
                    val userName = call.argument<Any>("userName") as String?
                    val strategy = call.argument<Any>("strategy") as String?
                    assert(userName != null)
                    val advertisingOptions =
                        AdvertisingOptions.Builder().setStrategy(getStrategy(strategy)).build()
                    Nearby.getConnectionsClient(this).startAdvertising(
                        (userName)!!,
                        SERVICE_ID,
                        connectionLifecycleCallback,
                        advertisingOptions,
                    ).addOnSuccessListener {
                        Log.d("nearby_connections", "startAdvertising")
                        result.success(true)
                    }.addOnFailureListener { e ->
                        result.error(
                            "Failure",
                            e.message,
                            null,
                        )
                    }
                }

                "startDiscovery" -> {
                    val userName = call.argument<Any>("userName") as String?
                    val strategy = call.argument<Any>("strategy") as String?
                    assert(userName != null)
                    val discoveryOptions =
                        DiscoveryOptions.Builder().setStrategy(getStrategy(strategy)).build()
                    Nearby.getConnectionsClient(this)
                        .startDiscovery(SERVICE_ID, endpointDiscoveryCallback, discoveryOptions)
                        .addOnSuccessListener {
                            Log.d("nearby_connections", "startDiscovery")
                            result.success(true)
                        }.addOnFailureListener { e ->
                            result.error(
                                "Failure",
                                e.message,
                                null,
                            )
                        }
                }

                "stopAllEndpoints" -> {
                    Log.d("nearby_connections", "stopAllEndpoints")
                    Nearby.getConnectionsClient(this).stopAllEndpoints()
                    result.success(null)
                }

                "disconnectFromEndpoint" -> {
                    Log.d("nearby_connections", "disconnectFromEndpoint")
                    val endpointId = call.argument<String>("endpointId")
                    assert(endpointId != null)
                    Nearby.getConnectionsClient(this).disconnectFromEndpoint((endpointId)!!)
                    result.success(null)
                }

                "requestConnection" -> {
                    Log.d("nearby_connections", "requestConnection")
                    val userName = call.argument<Any>("userName") as String?
                    val endpointId = call.argument<Any>("endpointId") as String?
                    assert(userName != null)
                    assert(endpointId != null)
                    Nearby.getConnectionsClient(this).requestConnection(
                        (userName)!!,
                        (endpointId)!!,
                        connectionLifecycleCallback,
                    ).addOnSuccessListener { result.success(true) }.addOnFailureListener { e ->
                        result.error(
                            "Failure",
                            e.message,
                            e.localizedMessage,
                        )
                    }
                }

                "acceptConnection" -> {
                    val endpointId = call.argument<Any>("endpointId") as String?
                    assert(endpointId != null)
                    Nearby.getConnectionsClient(this)
                        .acceptConnection((endpointId)!!, payloadCallback).addOnSuccessListener {
                            Log.d("nearby_connections", "acceptConnection")
                            result.success(true)
                        }.addOnFailureListener { e ->
                            result.error(
                                "Failure",
                                e.message,
                                e.localizedMessage,
                            )
                        }
                }

                "rejectConnection" -> {
                    val endpointId = call.argument<Any>("endpointId") as String?
                    assert(endpointId != null)
                    Nearby.getConnectionsClient(this).rejectConnection((endpointId)!!)
                        .addOnSuccessListener {
                            Log.d("nearby_connections", "rejectConnection")
                            result.success(true)
                        }.addOnFailureListener { e ->
                            result.error(
                                "Failure",
                                e.message,
                                e.localizedMessage,
                            )
                        }
                }

                "sendBytesPayload" -> {
                    val endpointIds: List<String> =
                        call.argument("endpointIds") as List<String>? ?: listOf()
                    val bytes = call.argument<Any>("bytes") as ByteArray?
                    assert(endpointIds.isNotEmpty())
                    assert(bytes != null && bytes.isNotEmpty())

                    val payload = Payload.fromBytes(bytes!!)

                    Nearby.getConnectionsClient(this).sendPayload(
                        endpointIds,
                        payload,
                    )
                    Log.d("nearby_connections", "sentBytes")
                    result.success(true)
                }

                "sendFilePayload" -> {
                    val endpointIds = call.argument("endpointIds") as List<String>? ?: listOf()
                    val uri = call.argument("uri") as String?
                    assert(endpointIds.isNotEmpty())
                    assert(!uri.isNullOrBlank())

                    val payload = Payload.fromFile(File(uri!!))

                    Nearby.getConnectionsClient(this).sendPayload(
                        endpointIds,
                        payload,
                    )
                    Log.d("nearby_connections", "sendFilePayload")
                    result.success(true)
                }

                "cancelPayload" -> {
                    val payloadId = call.argument<Any>("payloadId") as Long?
                    assert(payloadId != null)
                    Nearby.getConnectionsClient(this).cancelPayload(payloadId!!)
                    Log.d("nearby_connections", "cancelPayload")
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        } catch (e: IllegalArgumentException) {
            result.error("", e.message, null)
        } catch (e: Exception) {
            result.error("", e.message, null)
        }
    }

    private val connectionLifecycleCallback: ConnectionLifecycleCallback =
        object : ConnectionLifecycleCallback() {
            override fun onConnectionInitiated(
                endpointId: String,
                connectionInfo: ConnectionInfo,
            ) {
                Log.d("nearby_connections", "onConnectionInitiated")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                args["endpointName"] = connectionInfo.endpointName
                args["verificationCode"] = connectionInfo.authenticationDigits
                nearbyChannel.invokeMethod("onConnectionInitiated", args)
            }

            override fun onConnectionResult(
                endpointId: String,
                connectionResolution: ConnectionResolution,
            ) {
                Log.d("nearby_connections", "onConnectionResult")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                var status = "none"
                when (connectionResolution.status.statusCode) {
                    ConnectionsStatusCodes.STATUS_OK -> status = "connected"
                    ConnectionsStatusCodes.STATUS_CONNECTION_REJECTED -> status = "rejected"
                    ConnectionsStatusCodes.STATUS_ERROR -> status = "error"
                    else -> {}
                }
                args["status"] = status
                nearbyChannel.invokeMethod("onConnectionResult", args)
            }

            override fun onDisconnected(endpointId: String) {
                Log.d("nearby_connections", "onDisconnected")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                nearbyChannel.invokeMethod("onDisconnected", args)
            }
        }

    private val payloadCallback: PayloadCallback =
        object : PayloadCallback() {
            override fun onPayloadReceived(
                endpointId: String,
                payload: Payload,
            ) {
                Log.d("nearby_connections", "onPayloadReceived")
                val args: MutableMap<String, Any?> = HashMap()
                args["endpointId"] = endpointId
                args["payloadId"] = payload.id
                args["type"] = getPayloadName(payload.type)
                if (payload.type == Payload.Type.BYTES) {
                    val bytes = payload.asBytes()
                    assert(bytes != null)
                    args["bytes"] = bytes
                } else if (payload.type == Payload.Type.FILE) {
                    args["uri"] = payload.asFile()!!.asUri().toString()
                    args["name"] = payload.asFile()!!.asUri()!!.lastPathSegment
                }
                nearbyChannel.invokeMethod("onPayloadReceived", args)
            }

            override fun onPayloadTransferUpdate(
                endpointId: String,
                payloadTransferUpdate: PayloadTransferUpdate,
            ) {
                // required for files and streams
                Log.d("nearby_connections", "onPayloadTransferUpdate")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                args["payloadId"] = payloadTransferUpdate.payloadId
                args["status"] = getTransferStatusName(payloadTransferUpdate.status)
                args["bytesTransferred"] = payloadTransferUpdate.bytesTransferred
                args["totalBytes"] = payloadTransferUpdate.totalBytes
                nearbyChannel.invokeMethod("onPayloadTransferUpdate", args)
            }
        }

    private val endpointDiscoveryCallback: EndpointDiscoveryCallback =
        object : EndpointDiscoveryCallback() {
            override fun onEndpointFound(
                endpointId: String,
                discoveredEndpointInfo: DiscoveredEndpointInfo,
            ) {
                Log.d("nearby_connections", "onEndpointFound")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                args["endpointName"] = discoveredEndpointInfo.endpointName
                nearbyChannel.invokeMethod("onEndpointFound", args)
            }

            override fun onEndpointLost(endpointId: String) {
                Log.d("nearby_connections", "onEndpointLost")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                nearbyChannel.invokeMethod("onEndpointLost", args)
            }
        }

    private fun getStrategy(name: String?): Strategy {
        return when (name) {
            "cluster" -> Strategy.P2P_CLUSTER
            "star" -> Strategy.P2P_STAR
            "pointToPoint" -> Strategy.P2P_POINT_TO_POINT
            else -> throw IllegalArgumentException()
        }
    }

    private fun getPayloadName(payloadCode: Int): String {
        return when (payloadCode) {
            1 -> "bytes"
            2 -> "file"
            3 -> "stream"
            else -> throw IllegalArgumentException()
        }
    }

    private fun getTransferStatusName(transferUpdateCode: Int): String {
        return when (transferUpdateCode) {
            1 -> "success"
            2 -> "failure"
            3 -> "inProgress"
            4 -> "canceled"
            else -> throw IllegalArgumentException()
        }
    }
}
