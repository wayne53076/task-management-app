import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:task_management_app/models/vote.dart';
import 'package:task_management_app/view_models/all_votes_vm.dart';
import 'package:task_management_app/view_models/me_vm.dart';

class VotePage extends StatefulWidget {
  final String voteId;
  VotePage({Key? key, required this.voteId}) : super(key: key);

  @override
  _VotePageState createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  final TextEditingController _optionController = TextEditingController();
  DateTime? _endDate;
  late String userId;
  late List<Vote> _votes;
  late Vote _currentVote;
  late AllVotesViewModel _allVotesViewModel;
  @override
  void initState() {
    super.initState();
    userId = Provider.of<MeViewModel>(context, listen: false).myId;
  }

  void _voteForOption(int index) {
    if (_isVotingActive() && !_currentVote.hasVoted(userId)) {
      setState(() {
        _currentVote.voteData[index].votes++;
        _currentVote.voteData[index].voters.add(userId);
      });
      _allVotesViewModel.updateVoteDataById(
          _currentVote.id!, _currentVote.voteData);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Voting Closed'),
          content: Text(_currentVote.hasVoted(userId)
              ? 'You have already voted.'
              : 'The voting period has ended.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  bool _isVotingActive() {
    final now = DateTime.now();
    if (_endDate == null) {
      return true;
    }
    return now.isBefore(_endDate!);
  }

  void _addOption() {
    String optionName = _optionController.text.trim();
    if (optionName.isNotEmpty) {
      final newOption = VoteData(optionName, 0, []);
      setState(() {
        _currentVote.voteData.add(newOption);
        _allVotesViewModel.updateVoteDataById(
            _currentVote.id!, _currentVote.voteData);
      });
      _optionController.clear();
    }
  }

  void _setEndTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      _currentVote.endTime = pickedDate;
      _allVotesViewModel.updateVoteEndDateById(_currentVote.id!, pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    _allVotesViewModel = Provider.of<AllVotesViewModel>(context, listen: false);
    if (_allVotesViewModel.isInitializing ||
        _allVotesViewModel.votes!.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    _votes = Provider.of<AllVotesViewModel>(context, listen: false).votes!;
    _currentVote = _votes.firstWhere((vote) => vote.id == widget.voteId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            _currentVote.topic,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range, color: Colors.white),
            onPressed: _setEndTime,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Voting ends on: ${_endDate != null ? DateFormat.yMMMd().format(_endDate!)
               : 'No end date set'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _currentVote.voteData.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_currentVote.voteData[index].option),
                  subtitle:
                      Text('Votes: ${_currentVote.voteData[index].votes}'),
                  onTap: () {
                    _voteForOption(index);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _optionController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a new option',
                    ),
                    onSubmitted: (_) {
                      _addOption();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addOption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
