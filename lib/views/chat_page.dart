import 'package:flutter/material.dart';
import 'package:task_management_app/models/user.dart';
import 'package:task_management_app/services/push_messaging.dart';
import 'package:task_management_app/view_models/me_vm.dart';
import 'package:task_management_app/views/message_list.dart';
import 'package:task_management_app/views/new_message_bar.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final PushMessagingService _pushMessagingService;
  late final User me;

  @override
  void initState() {
    super.initState();

    me = Provider.of<MeViewModel>(context, listen: false).me!;
    _pushMessagingService =
        Provider.of<PushMessagingService>(context, listen: false);
    // Initialize _pushMessagingService without awaiting, so that the build method can run
    _pushMessagingService.initialize(userId: me.id).then((isGranted) {
      if (!isGranted) {
        debugPrint('User denied permission for push notifications');
        return;
      }
    }).catchError((e) {
      debugPrint('Error initializing push messaging service: $e');
    });
  }

  @override
  void dispose() {
    // Do NOT unsubscribe from the topic here, as the user may want to receive notifications even when the app is in the background
    // _pushNotificationService.unsubscribeFromAllTopics();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AnimatedBackground(),
          Column(
            children: [
              const Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: MessageList(),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.transparent,
                child: const NewMessageBar(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _animation = ColorTween(
      begin: Colors.purple.shade300,
      end: Colors.blue.shade200,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_animation.value!, Colors.pink.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }
}
