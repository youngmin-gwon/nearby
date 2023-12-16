# Data Transfer Protocol

근거리 기기 간 직접 통신으로 데이터를 주고 받을 때, 데이터 수신 및 검증을 위한 프로토콜이 필요하므로 해당 프로토콜을 정의함.

## Overview

### Original Idea

```mermaid
%%{init: { 'sequence': {'showSequenceNumbers': true, 'noteAlign': 'left'} }}%%
sequenceDiagram
    participant sender as Sender
    participant receiver as Receiver
    Note left of receiver: Payload:Byte<br/><br/>{<br/>&ensp;&ensp;"type" : "byte"<br/>}
    sender->>receiver: 메타 데이터: file/byte 중 어떤 데이터 보낼지 정보
    activate receiver
    Note left of receiver: Payload
    sender->>receiver: 실제 데이터
    Note right of sender: Payload:Byte<br/><br/>{<br/>&ensp;&ensp;"checksum" : "xxxxxx"<br/>}
    receiver-->>sender: 데이터 수신 결과
    Note left of sender: 받은 데이터와 체크섬 비교하여<br/>수신 성공여부 확인
    Note left of receiver: Payload:Byte<br/><br/>{<br/>&ensp;&ensp;"isOk" : true<br/>}
    sender->>receiver: 검증 결과
    deactivate receiver
```

### Modified Idea

```mermaid
---
title: Data Transfer sequence diagram
---
%%{init: { 'sequence': {'showSequenceNumbers': true, 'noteAlign': 'left'} }}%%
sequenceDiagram
    participant sender as Sender
    participant receiver as Receiver
    Note left of receiver: Payload:Byte<br/><br/>{<br/>&ensp;&ensp;"type" : "meta_data",<br/>&ensp;&ensp;"data" : [<br/>&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;{<br/>&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;"checksum" : "xxxxx",<br/>&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;...<br/>&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;},<br/>&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;]<br/>}
    sender->>receiver: 메타 데이터: file/byte 중 어떤 데이터 인지, 체크섬 정보
    activate receiver
    loop Payloads
        Note left of receiver: Payload 1
        Note left of receiver: Payload ...
        Note left of receiver: Payload n
    end
    sender->>receiver: 실제 데이터
    Note right of receiver: 받은 데이터와 체크섬 비교하여<br/>수신 성공여부 확인
    Note right of sender: Payload:Byte<br/><br/>{<br/>&ensp;&ensp;"type" : "response",<br/>&ensp;&ensp;"isOk" : true<br/>}
    receiver-->>sender: 데이터 수신 성공 여부
    deactivate receiver
```

Payload를 다 받을 때 까지, checksum 정보를 계속 가지고 있어야하는 점은 귀찮을 수 있음.

## Considerations

파일을 여러개 보내는 경우에 어떻게 해야 하는가?

복합 구조체인 경우(e.g. file + data) 어떻게 처리해야하는가?

## Any thoughts

send, response 를 어떻게 구현하면 좋을까

1. send-meta data

byte, file 을 어떻게 구분해서 처리해야하나 -> subclass?

공통적으로 필요한 부분? `checksum`, `type 정보`, `toMap or toJson` + `id` 같은 고유값도 필요하지 않을까 싶음

공통적으로 처리해야할 부분? `암호화` 및 `복호화`

어디에 들어가야하는가? -> application layer or domain layer
