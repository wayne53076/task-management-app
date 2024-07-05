import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management_app/services/navigation.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key, required this.serverId});

  final int serverId;

  @override
  State<SideMenu> createState() => _SideMenu();
}

class _SideMenu extends State<SideMenu> {

  @override
  Widget build(BuildContext context) {

    final nav = Provider.of<NavigationService>(context);

    return Drawer(
      child: Row (
          children: [
            // server list
            Container(
              color: Colors.grey[300],
              child: SizedBox(
                width: 70,
                child: ListView(
                  children: <Widget>[
                    InkWell(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 30,
                        ),
                      ),
                      onTap: () {
                        nav.changeServer(0);
                      },
                    ),
                    InkWell(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 30,
                        ),
                      ),
                      onTap: () {
                        nav.changeServer(1);
                      },
                    ),
                    InkWell(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 30,
                        ),
                      ),
                      onTap: () {
                        nav.changeServer(2);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.blue),
                    child: Text('Server ${widget.serverId}'),
                  ),
                  ListTile(
                    title: const Text('Vote'),
                    onTap: () {
                      nav.goVote(widget.serverId);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Discuss Room'),
                    onTap: () {
                      nav.goDiscussRoom(widget.serverId);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Todo List'),
                    onTap: () {
                      nav.goTodoList(widget.serverId);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Available Time'),
                    onTap: () {
                      nav.goAvailableTime(widget.serverId);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(


                    title: const Text('AI assistant'),

                    onTap: () {
                      nav.goAIAssistant(widget.serverId);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            )
          ],
        )
      )
    ;
  }
}
