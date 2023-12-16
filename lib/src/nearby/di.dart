import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:faker/faker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_bloc.dart';
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_state.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_bloc.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_state.dart';
import 'package:poc/src/nearby/application/service/nearby.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_resolver.dart';
import 'package:poc/src/nearby/application/service/user_info_fetcher.dart';
import 'package:poc/src/nearby/infrastructure/datastore/asset_local_datastore.dart';
import 'package:poc/src/nearby/infrastructure/datastore/asset_remote_datastore.dart';
import 'package:poc/src/nearby/infrastructure/datastore/transaction_local_datastore.dart';
import 'package:poc/src/nearby/infrastructure/service/asset_facade_service_fake_impl.dart';
import 'package:poc/src/nearby/infrastructure/service/nearby_impl.dart';
import 'package:poc/src/nearby/infrastructure/service/nearby_precondition_resolver_impl.dart';
import 'package:poc/src/nearby/infrastructure/service/user_info_fetcher_impl.dart';

final nearbySenderBlocProvider =
    NotifierProvider.autoDispose<NearbySenderBloc, NearbySenderState>(
  NearbySenderBloc.new,
);

final nearbyReceiverBlocProvider =
    NotifierProvider.autoDispose<NearbyReceiverBloc, NearbyReceiverState>(
  NearbyReceiverBloc.new,
);

final nearbyProvider = Provider<Nearby>(
  (_) => NearbyImpl(),
);

final nearbyPreconditionResolverProvider = Provider<NearbyPreconditionResolver>(
  (ref) {
    if (Platform.isAndroid) {
      return NearbyPreconditionResolverConcreteImplAndroid(
          ref.watch(deviceInfoProvider));
    }

    if (Platform.isIOS) {
      return const NearbyPreconditionResolverConcreteImplIos();
    }

    throw UnimplementedError();
  },
);

final infoFetcherProvider = Provider<UserInfoFetcher>(
  (ref) => UserInfoFetcherImpl(
    ref.watch(deviceInfoProvider),
  ),
);

final deviceInfoProvider = Provider(
  (_) => DeviceInfoPlugin(),
);

// --- asset 관련 ---
// =================
final assetFacadeServiceProvider = Provider(
  (ref) => AssetFacadeServiceFakeImpl(
    ref.watch(assetLocalDatastoreProvider),
    ref.watch(assetRemoteDatastoreProvider),
    ref.watch(transactionLocalDatastoreProvider),
  ),
);

final assetRemoteDatastoreProvider = Provider(
  (ref) => AssetRemoteDatastoreFakeImpl(
    ref.watch(localEncrypterProvider),
    // 반드시 16bytes 길이여야함
    ref.watch(localIvProvider),
    Faker(),
  ),

  // (ref) => AssetRemoteDatastoreImpl(
  //   dotenv.get('REMOTE_SERVER_URL'),
  //   ref.watch(httpClientProvider),
  //   ref.watch(remoteEncrypterProvider),
  //   Faker(),
  // ),
);

final assetLocalDatastoreProvider = Provider(
  (ref) => AssetLocalDatastoreImpl(
    ref.watch(isarDatabaseProvider),
    ref.watch(localEncrypterProvider),
    ref.watch(localIvProvider),
  ),
);

final transactionLocalDatastoreProvider = Provider(
  (ref) => TransactionLocalStorageFakeImpl(),
);

/// server 에서 사용하는 encryption key 와 local 에서 저장/쿼리를 위한 encryption key 를
/// 다르게 사용하는 것이 좋을 것 같다는 관점에서
/// [localEncrypterProvider] 와 [remoteEncrypterProvider]로 나눠뒀음.
///
/// 두 개를 합쳐도 전혀 상관없음
final remoteEncrypterProvider = Provider(
  (_) => encrypt.Encrypter(
    encrypt.AES(
      encrypt.Key.fromUtf8(dotenv.get('REMOTE_ENCRYPTION_KEY')),
      mode: encrypt.AESMode.cbc,
    ),
  ),
);

/// server 에서 사용하는 encryption key 와 local 에서 저장/쿼리를 위한 encryption key 를
/// 다르게 사용하는 것이 좋을 것 같다는 관점에서
/// [localEncrypterProvider] 와 [remoteEncrypterProvider]로 나눠뒀음.
///
/// 두 개를 합쳐도 전혀 상관없음
final localEncrypterProvider = Provider(
  (_) => encrypt.Encrypter(
    encrypt.AES(
      encrypt.Key.fromUtf8(
        dotenv.get('LOCAL_ENCRYPTION_KEY'),
      ),
      mode: encrypt.AESMode.cbc,
    ),
  ),
);

final localIvProvider = Provider(
  (ref) => encrypt.IV.fromUtf8(dotenv.get('LOCAL_ENCRYPTION_KEY')),
);

final httpClientProvider = Provider((ref) => http.Client());

/// 왜 아무것도 넣지않고 Exception 처리하는지 의문이 들 수 있음.
/// 이는, 비동기로 생성해야하는 constructor 가 있는 경우, 사용하는 방법으로,
/// 확실하게 instance 를 생성할 수 있는 지점에서 생성한 후,
/// override 하는 방식으로 사용하라는 공식문서의 지침을 따름.
/// `lib/main.dart` 참고
final isarDatabaseProvider = Provider<Isar>(
  (_) => throw UnimplementedError(),
);
