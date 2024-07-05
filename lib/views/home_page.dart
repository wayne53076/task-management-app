import 'package:flutter/material.dart';
import 'package:task_management_app/views/side_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key, required this.centralPage, required this.title, required this.serverId});

  final String title;
  final int serverId;
  final Widget centralPage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} - ${widget.serverId}'),
      ),
      body: Center(
        child: widget.centralPage,
      ),
      drawer: SideMenu(
        serverId: widget.serverId,
      ),
    );
  }
}
