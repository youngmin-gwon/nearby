
# Nearby Connections 

## 구조

- Constants 
    - Constants.swift
- Enums
    - Enum.swift
- Utils
    - Utils.swift    
- FlutterChannelConnector  
    - FlutterChannelConnector.swift  `플러터와 ios native간 여러 채널을 생성하여 플랫폼간 기능 구현을 연결을 이어주는 커넥터` 
    - FlutterChannelConnectorDelegate.swift `플러터 채널 커넥트 딜리게이트`
    - FlutterChannelMethodCallDelegate.swift `플러터 채널 setMethodCallHandler 딜리게이트 : flutter에서 ios쪽 호출해서 ios쪽에서 결과를 flutter로 다시 보내줌` 
    - FlutterChannelInovokeDelegate.swift `플러터 채널 invoke 딜리게이트 : ios쪽에서 생성한 값을 flutter로 결과값을 다시 보내줌`
- NearByConnectionController
    - Advertiser.swif  `연결할 기기에게 연결 요청하고 연결 요청에 대한 알림을 받음` 
    - ConnectionManager.swift `데이터 교환,연결 설정 및 페이로드,nearby connection 상태 프로세스 관리`
    - Discoverer.swift `근처 기기가 발견되면 검색기가 연결을 시작 및 기기와의 요청 시작` 
    - NearByConnectionController.swift `모든 연결 이벤트를 처리하며 기기 간에 데이터를 전송하기 위한 인터페이스`    
- FlutterChannels `플러터 채널` 
    - FlutterChannelDelegate.swift `플러터 채널 생성 딜리게이트` 
    - NearbyConnectionsChannel
        - NearbyConnectionsChannel.swift  `nearby connection 채널` 
        - NearbyConnectionsChannelDelegate.swift  `nearyby connection 채널 딜리게이트 (method callback , invoke 메소드 생성)`
- FlutterDictionary 
    - FlutterDictionary.swift `플러터 채널을 Dictionary 형태로 저장하여 플러터에서 채널을 호출하면 ios쪽에서 자동적으로 ios 해당 채널 클래스 반환`   
    - FlutterDictionaryDelegate.swift `플러터 Dictionary 딜리게이트`  
- Model
    - ConnectedEndpoint.swift `연결된 엔드포인트 모델` 
    - DiscoveredEndpoint.swift `연결되기전 발견한 엔드포인트 모델` 
    - Payload.swift `송수신시 데이터 연결하는 페이로드 모델`
    - ConnectionRequest.swift `연결 요청 모델`
- AppDelegate.swift `메인` 


## 개발 환경 

```
[✓] Flutter (Channel stable, 3.13.9, on macOS 14.0 23A344 darwin-arm64, locale ko-KR)
[✓] Xcode - develop for iOS and macOS (Xcode 15.0)
[✓] Minimum Deployments: iOS '16.2'
```


## Nearby 라이브러리 설치 방법 

1.Clone the Nearby repo with all submodules by running the following command:

`git clone --recurse-submodules https://github.com/google/nearby.git`

2.Open the sample app in Xcode:

`open nearby/connections/swift/NearbyConnections/Example/iOS\ Example.xcodeproj`

3.Choose a development team by navigating to iOS Example > iOS Example under "Targets" > Signing & Capabilities and then choosing your team from the "team" drop-down

4.info.plist 필수 사용키 입력 
    - NSBluetoothAlwaysUsageDescription
    - NSBluetoothPeripheralUsageDescription
    - NSLocalNetworkUsageDescription
    - UIRequiresPersistentWiFi
    - NSNearbyInteractionAllowOnceUsageDescription
    - NSBonjourServices
    - NSLocalNetworkUsageDescription

## API 공식 문서

- https://developers.google.com/nearby/connections/swift/get-started?hl=ko

## Sample Git 

- https://github.com/google/nearby/tree/main/connections/swift/NearbyConnections/Example

## Support 

For support, email ahhyun@nportverse.com or join our Slack channel.

