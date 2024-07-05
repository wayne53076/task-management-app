import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:task_management_app/models/vote.dart';
import 'package:task_management_app/repositories/vote_repo.dart';

class AllVotesViewModel with ChangeNotifier {
  final VoteRepository _voteRepository;
  StreamSubscription<List<Vote>>? _votesSubscription;

  final StreamController<List<Vote>> _voteStreamController =
      StreamController<List<Vote>>();
  Stream<List<Vote>> get voteStream => _voteStreamController.stream;

  List<Vote>? _votes = [];
  List<Vote>? get votes => _votes;
  String _serverId;
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;
  Map<String, DateTime?> voteEndDates = {};

  AllVotesViewModel(String serverId, {VoteRepository? voteRepository})
      : _serverId = serverId,
        _voteRepository = voteRepository ?? VoteRepository() {
    _initialize();
  }

  void _initialize() {
    _votesSubscription = _voteRepository.streamVote(_serverId).listen(
      (votes) {
        _isInitializing = false;
        _votes = votes;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _votesSubscription?.cancel();
    _voteStreamController.close();
    super.dispose();
  }

  void updateServerId(String newServerId) {
    if (newServerId != _serverId) {
      _votesSubscription?.cancel();
      _serverId = newServerId;
      _isInitializing = true;
      notifyListeners();
      _initialize();
    }
  }

  Future<void> addVote(Vote newVote) async {
    await _voteRepository.addVote(_serverId, newVote);
  }

  Future<void> deleteVoteById(String voteId) async {
    await _voteRepository.deleteVote(_serverId, voteId);
  }

  Future<void> updateVoteDataById(String voteId, List<VoteData> voteData) async {
    await _voteRepository.updateVoteData(_serverId, voteId, voteData);
  }

  Future<void> updateVoteEndDateById(String voteId, DateTime date) async {
    await _voteRepository.updateVoteEndDateById(_serverId, voteId, date);
  }
}
