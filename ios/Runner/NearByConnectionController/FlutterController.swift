////
////  FlutterController.swift
////  Runner
////
////  Created by ahhyun lee on 11/29/23.
////
//
//import NearbyConnections
//import Foundation
//import UIKit
//import Flutter
//
//extension NearByConnectionController {
//   
//    func onEndpointFound (endpointId:String, endpointName:String, serviceId:String){
//        var args = [
//            "endpointId":endpointId,"endpointName":endpointName,"serviceId":serviceId
//        ]as [String : Any]
//        FlutterChannel.invokeHandler(method: FlutterInvokeMethodEvent.onEndpointFound.toString,arguments:args)
//    }
//    
//    func onEndpointLost(endpointId:String){
//        
//        var args = ["endpointId":endpointId] as [String : Any]
//        FlutterPlatformChannel.invokeHandler(method: FlutterInvokeMethodEvent.onEndpointLost.toString,arguments:args)
//    }
//    
//    
//    func onPayloadReceived(endpointId:String,payloadType:String,bytes:Data,payloadId:Int,filePath:String){
//
//        var args = ["endpointId":endpointId,"type": payloadType , "bytes" : bytes,"payloadId":payloadId, "filePath":filePath ] as [String : Any]
//        FlutterPlatformChannel.invokeHandler(method: FlutterInvokeMethodEvent.onPayloadReceived.toString, arguments: args)
//    }
//    
//    func onPayloadTransferUpdate(endpointId:String,payloadId:Int64,payloadStatus:String,bytesTransferred:Int,totalBytes:Int){
//        
//        var args = ["endpointId":endpointId,"payloadId":payloadId,"status":payloadStatus,",bytesTransferred":bytesTransferred,"totalBytes":totalBytes] as [String : Any]
//        FlutterPlatformChannel.invokeHandler(method: FlutterInvokeMethodEvent.onPayloadTransferUpdate.toString, arguments: args)
//    }
//    
//    func onConnectionInitiated(endpointId:String,endpointName:String, authenticationDigits:String,isIncomingConnection:Bool){
//        
//        var args = ["endpointId":endpointId,"endpointName":endpointName,"authenticationDigits":authenticationDigits,"isIncomingConnection":isIncomingConnection]as [String : Any]
//        FlutterPlatformChannel.invokeHandler(method: FlutterInvokeMethodEvent.onConnectionInitiated.toString, arguments: args)
//    }
//    
//    func onConnectionResult(endpointId:String,status:ConnectionStatus){
//        
//        var args = ["endpointId":endpointId,"statusCode":status.rawValue]as [String : Any]
//        FlutterPlatformChannel.invokeHandler(method: FlutterInvokeMethodEvent.onConnectionResult.toString, arguments: args)
//    }
//    
//    func onDisconnected(endpointId:String){
//        var args = ["endpointId":endpointId]as [String : Any]
//        FlutterPlatformChannel.invokeHandler(method: FlutterInvokeMethodEvent.onDisconnected.toString, arguments: args)
//    }
//}
