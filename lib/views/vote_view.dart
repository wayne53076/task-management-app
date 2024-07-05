import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:task_management_app/view_models/all_votes_vm.dart'; // Import the ViewModel
import 'package:task_management_app/models/vote.dart';
import 'vote_page.dart'; // Import VotePage

class VoteView extends StatefulWidget {
  const VoteView({Key? key}) : super(key: key);

  @override
  _VoteViewState createState() => _VoteViewState();
}

class _VoteViewState extends State<VoteView> {
  final TextEditingController _topicController = TextEditingController();
  final Map<String, String?> _topicImages = {};

  @override
  Widget build(BuildContext context) {
    final allVotesViewModel = Provider.of<AllVotesViewModel>(context); // Use the ViewModel

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Center(
          child: Text(
            'Vote',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (allVotesViewModel.isInitializing || allVotesViewModel.votes!.isEmpty)
            const Center(child: CircularProgressIndicator()),
          if (!allVotesViewModel.isInitializing )
            Positioned(
              top: 0,
              bottom: 100,
              left: 0,
              right: 0,
              child: ListView.builder(
                itemCount: allVotesViewModel.votes!.length,
                itemBuilder: (context, index) {
                  final vote = allVotesViewModel.votes![index];
                  return ListTile(
                    title: Text(vote.topic),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeleteVote(context, allVotesViewModel, vote),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VotePage(
                            voteId: vote.id!,
                          ),
                        ),
                      ).then((_) {
                        setState(() {}); // Refresh state when returning
                      });
                    },
                  );
                },
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _topicController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a vote question',
                    ),
                    onSubmitted: (_) {
                      _addTopicAndNavigate();
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addTopicAndNavigate,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteVote(BuildContext context, AllVotesViewModel viewModel, Vote vote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:const Text('Confirm Delete'),
        content:const Text('Are you sure you want to delete this vote?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await viewModel.deleteVoteById(vote.id!);
              Navigator.pop(context);
            },
            child:const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addTopicAndNavigate() async {
    final String topic = _topicController.text.trim();
    if (topic.isNotEmpty) {
      final allVotesViewModel = Provider.of<AllVotesViewModel>(context, listen: false);
      final newVote = Vote(
        endTime: DateTime.now().add(const Duration(days: 7)), // Example endTime
        topic: topic,
        voteData: [],
      );
      await allVotesViewModel.addVote(newVote);
      _topicController.clear();

      try {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VotePage(voteId: newVote.id!),
          ),
        ).then((_) {
          setState(() {}); // Refresh the state when coming back from VotePage
        });
      } catch (e) {
        print('Error generating image: $e');
      }
    }
  }
}
