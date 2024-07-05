import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management_app/services/authentication.dart';
import 'package:go_router/go_router.dart';
import 'package:task_management_app/models/user.dart';
import 'package:task_management_app/view_models/me_vm.dart';
import 'package:task_management_app/view_models/all_messages_vm.dart';
import 'package:task_management_app/view_models/all_todos_vm.dart';
import 'package:task_management_app/view_models/all_votes_vm.dart';
import 'package:task_management_app/view_models/available_time_vm.dart';
import 'package:task_management_app/views/chat_page.dart';
import 'package:task_management_app/views/home_page.dart';
import 'package:task_management_app/views/available_time_page.dart';
import 'package:task_management_app/views/vote_view.dart';
import 'package:task_management_app/views/todo_list_page.dart';
import 'package:task_management_app/views/ai_assistant_page.dart';
import 'package:task_management_app/views/auth_page.dart';

const defaultServerId = '0'; // If don't join any server,

final routerConfig = GoRouter(
  initialLocation: '/server/$defaultServerId',
  routes: <RouteBase>[
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) =>
          const NoTransitionPage<void>(child: AuthPage()),
    ),
    ShellRoute(
      builder: (context, state, child) {
        final myId = Provider.of<AuthenticationService>(context, listen: false)
            .checkAndGetLoggedInUserId();
        if (myId == null) {
          debugPrint('Warning: ShellRoute should not be built without a user');
          return const SizedBox.shrink();
        }
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<MeViewModel>(
              create: (_) => MeViewModel(myId),
            ),
            ChangeNotifierProxyProvider<MeViewModel, AllMessagesViewModel>(
                create: (_) => AllMessagesViewModel(defaultServerId),
                update: (_, meViewModel, allMessagesViewModel) =>
                    allMessagesViewModel!
                      ..updateServerId(
                          meViewModel.me?.currentServerId ?? defaultServerId)),
            ChangeNotifierProxyProvider<MeViewModel, AllTodosViewModel>(
                create: (_) => AllTodosViewModel(defaultServerId),
                update: (_, meViewModel, allTodosViewModel) =>
                    allTodosViewModel!
                      ..updateServerId(
                          meViewModel.me?.currentServerId ?? defaultServerId)),
            ChangeNotifierProxyProvider<MeViewModel, AllVotesViewModel>(
                create: (_) => AllVotesViewModel(defaultServerId),
                update: (_, meViewModel, allVotesViewModel) =>
                    allVotesViewModel!
                      ..updateServerId(
                          meViewModel.me?.currentServerId ?? defaultServerId)),
            ChangeNotifierProxyProvider<MeViewModel, AvailableTimeViewModel>(
                create: (_) => AvailableTimeViewModel(defaultServerId),
                update: (_, meViewModel, availableTimeViewModel) =>
                    availableTimeViewModel!
                      ..updateServerId(
                          meViewModel.me?.currentServerId ?? defaultServerId)),
          ],
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/server/:serverId',
          pageBuilder: (context, state) {
            final meViewModel = Provider.of<MeViewModel>(context, listen: false);
            final int id = int.parse(state.pathParameters['serverId']!);
            return NoTransitionPage<void>(
                child: StreamBuilder<User>(
              // Listen to the me state changes
              stream: meViewModel.meStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.active ||
                    snapshot.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint('Error loading user data: ${snapshot.error}');
                  return const Center(
                    child: Text('Error loading user data'),
                  );
                }
                meViewModel.me!.currentServerId = id.toString();
                return HomePage(
                    centralPage: const ChatPage(),
                    title: "Discuss Room",
                    serverId: id);
              },
            ));
          },
          routes: [
            GoRoute(
              path: 'available-time',
              pageBuilder: (context, state) {
                final int id = int.parse(state.pathParameters['serverId']!);
                return NoTransitionPage(
                    child: HomePage(
                        centralPage: const AvailableTimePage(),
                        title: "Available Time",
                        serverId: id));
              },
            ),
            GoRoute(
              path: 'vote',
              pageBuilder: (context, state) {
                final int id = int.parse(state.pathParameters['serverId']!);
                return NoTransitionPage(
                    child: HomePage(
                        centralPage: const VoteView(),
                        title: "vote",
                        serverId: id));
              },
            ),
            GoRoute(
              path: 'todo-list',
              pageBuilder: (context, state) {
                final int id = int.parse(state.pathParameters['serverId']!);
                return NoTransitionPage(
                    child: HomePage(
                        centralPage: const TodoListPage(),
                        title: "todo list",
                        serverId: id));
              },
            ),
            GoRoute(
                path: 'ai-assistant',
                pageBuilder: (context, state) {
                  final int id = int.parse(state.pathParameters['serverId']!);
                  return NoTransitionPage(
                      child: HomePage(
                          centralPage: const AIassistant(),
                          title: "AI Assistant",
                          serverId: id));
                })
          ],
        ),
      ],
    ),
  ],
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final path = state.uri.path;
    final isLoggedIn =
        Provider.of<AuthenticationService>(context, listen: false)
                .checkAndGetLoggedInUserId() !=
            null;
    if (isLoggedIn && path == '/auth') {
      return '/server/$defaultServerId';
    }
    if (!isLoggedIn && path != '/auth') {
      // Redirect to auth page if the user is not logged in
      return '/auth';
    }
    if (path == '/' || path == '/server') {
      return '/server/$defaultServerId';
    }
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri.path}'),
    ),
  ),
);

class NavigationService {
  late final GoRouter _router;

  NavigationService() {
    _router = routerConfig;
  }

  String _currentPath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  void goTodoList(int serverId) {
    _router.go('/server/$serverId/todo-list');
  }

  void goVote(int serverId) {
    _router.go('/server/$serverId/vote');
  }

  void goDiscussRoom(int serverId) {
    _router.go('/server/$serverId');
  }

  void goAvailableTime(int serverId) {
    _router.go('/server/$serverId/available-time');
  }

  void goAIAssistant(int serverId) {
    _router.go('/server/$serverId/ai-assistant');
  }

  void changeServer(int serverId) {
    _router.go('/server/$serverId');
  }
}
