import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:task_management_app/repositories/user_repo.dart';
import "package:universal_html/html.dart" as html;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// VAPID key for web push notifications.
/// FIXME: DO NOT hardcode the VAPID key in production. Store it securely in environment variables using, for example, the `flutter_dotenv` package
final String? vapidKey =  dotenv.env['VAPID_KEY'];

// A static map to hold the background data message handlers
final Map<String, Function(Map<String, dynamic>)> _backgroundDataHandlers = {};

/// Annotated as entry point to prevent being tree-shaken in release mode.
@pragma('vm:entry-point')
Future<void> _onBackgroundData(RemoteMessage message) async {
  debugPrint(
      "RemoteMessagingService: Received a data message in the background: ${message.data.toString()}");

  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services like this:
  // await Firebase.initializeApp();

  final key = message.data['key'];
  if (key != null) {
    final handler = _backgroundDataHandlers[key];
    if (handler != null) {
      handler(message.data);
    }
  }
}

class PushMessagingService {
  late final UserRepository _userRepository;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Map<String, Function(Map<String, dynamic>)> _foregroundDataHandlers =
      {};
  final Map<String, Function(Map<String, dynamic>)> _openNotificationHandlers =
      {};
  String? _token;

  final Set<String> subscribedTopics = <String>{};

  static PushMessagingService? _instance;

  // Singleton pattern
  factory PushMessagingService({UserRepository? userRepository}) {
    _instance ??=
        PushMessagingService._internal(userRepository: userRepository);
    return _instance!;
  }

  PushMessagingService._internal({required UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  /// Request permission for receiving push notifications and subscribe 
  /// to the provided topics. Returns whether the user granted permission.
  Future<bool> initialize({
    required String userId,
  }) async {
    final settings = await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      // User denied permission
      return false;
    }

    // Register handlers for foreground data messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          'RemoteMessagingService: Received data in the foreground: ${message.data.toString()}');

      final key = message.data['key'];
      if (key != null) {
        final handler = _foregroundDataHandlers[key];
        if (handler != null) {
          handler(message.data);
        }
      }
    });

    // Register handlers for the opening of notifications with data
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          'RemoteMessagingService: Opened a notification message with data: ${message.data.toString()}');

      final key = message.data['key'];
      if (key != null) {
        final handler = _openNotificationHandlers[key];
        if (handler != null) {
          handler(message.data);
        }
      }
    });

    // Register handlers for background data messages
    FirebaseMessaging.onBackgroundMessage(_onBackgroundData);

    // Register the service worker for web
    if (kIsWeb) {
      await html.window.navigator.serviceWorker
          ?.register('/firebase-messaging-sw.js');
    }

    // Get the device token and sync user doc
    _token = await _getToken();
    if (_token != null) {
      await _postUpdateToken(userId);
    }

    // Listen to token changes and sync user doc
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _token = token;
      _postUpdateToken(userId);
    }).onError((err) {
      debugPrint('Error refreshing push messaging token: $err');
    });

    return true;
  }

  Future<String?> _getToken() async {
    String? token;
    if (kIsWeb) {
      token = await _firebaseMessaging.getToken(vapidKey: vapidKey);
    } else {
      token = await _firebaseMessaging.getToken();
    }
    debugPrint('Push messaging token: $token');
    return token;
  }

  Future<void> _postUpdateToken(String userId) async {
    // Subscribe to topics
    await subscribeToTopics(subscribedTopics);

    // Optionally, perform additional logic with the token, such as saving it to Firestore
    await _userRepository.updatePushMessagingToken(userId, _token);
  }

  Future<void> subscribeToTopics(Set<String> topics) async {
    List<Future<void>> futures = [];
    for (String topic in topics) {
      // Subscribe to a new topic
      if (kIsWeb) {
        final HttpsCallable callable = FirebaseFunctions.instance
            .httpsCallable('groupChatAppSubscribeToTopic');
        futures.add(
            callable.call(<String, dynamic>{'token': _token, 'topic': topic}));
      } else {
        futures.add(_firebaseMessaging.subscribeToTopic(topic));
      }
    }
    await Future.wait(futures); // Await all futures in parallel
    subscribedTopics.addAll(topics);
  }

  Future<void> unsubscribeFromTopics(Set<String> topics) async {
    List<Future<void>> futures = [];
    for (String topic in topics) {
      if (kIsWeb) {
        final HttpsCallable callable = FirebaseFunctions.instance
            .httpsCallable('groupChatAppUnsubscribeFromTopic');
        futures.add(
            callable.call(<String, dynamic>{'token': _token, 'topic': topic}));
      } else {
        futures.add(_firebaseMessaging.unsubscribeFromTopic(topic));
      }
    }
    // Await all futures in parallel
    await Future.wait(futures);
    subscribedTopics.removeAll(topics);
  }

  Future<void> unsubscribeFromAllTopics() async {
    await unsubscribeFromTopics(subscribedTopics);
  }

  /// Register the handler for foreground data of a specific key
  void registerForegroundDataHandler(
      String key, Function(Map<String, dynamic>) handler) {
    _foregroundDataHandlers[key] = handler;
  }

  /// Unregister the handler for foreground data of a specific key
  void unregisterForegroundDataHandler(String key) {
    _foregroundDataHandlers.remove(key);
  }

  /// Register the handler for opening notifications with data of a specific key
  void registerOpenNotificationHandler(
      String key, Function(Map<String, dynamic>) handler) {
    _openNotificationHandlers[key] = handler;
  }

  /// Unregister the handler for opening notifications with data of a specific key
  void unregisterOpenNotificationHandler(String key) {
    _openNotificationHandlers.remove(key);
  }

  /// Register the handler for background data of a specific key
  void registerBackgroundDataHandler(
      String key, Function(Map<String, dynamic>) handler) {
    _backgroundDataHandlers[key] = handler;
  }

  /// Unregister the handler of background data of a specific key
  void unregisterBackgroundDataHandler(String key) {
    _backgroundDataHandlers.remove(key);
  }
}
