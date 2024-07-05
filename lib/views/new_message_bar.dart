import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:task_management_app/models/message.dart';
import 'package:task_management_app/models/user.dart';
import 'package:task_management_app/view_models/all_messages_vm.dart';
import 'package:task_management_app/view_models/me_vm.dart';

class NewMessageBar extends StatefulWidget {
  const NewMessageBar({super.key});

  @override
  State<NewMessageBar> createState() {
    return _NewMessageBarState();
  }
}

class _NewMessageBarState extends State<NewMessageBar> {
  late final User? _me;
  final _messageController = TextEditingController();
  String? _messageText;
  DateTime _lastDiscoveryTime = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isDiscoveryButtonEnabled = true;
  late Timer _timer;
  String? _discoveryUrl;
  String? _stickerUrl;

  @override
  void initState() {
    super.initState();

    _me = Provider.of<MeViewModel>(context, listen: false).me;

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remainingTime =
          15 * 60 - DateTime.now().difference(_lastDiscoveryTime).inSeconds;
      if (remainingTime <= 0) {
        setState(() {
          _isDiscoveryButtonEnabled = true;
        });
        timer.cancel();
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  void _submitMessage() async {
    FocusScope.of(context).unfocus();

    if (_me == null) {
      return;
    }

    final allMessagesViewModel =
        Provider.of<AllMessagesViewModel>(context, listen: false);
    allMessagesViewModel.addMessage(
      Message(
        text: _messageText != null && _messageText!.isNotEmpty
            ? _messageText!
            : 'New discovery',
        discoveryUrl: _discoveryUrl ?? _stickerUrl,
        userId: _me.id,
        userName: _me.name,
        userAvatarUrl: _me.avatarUrl,
      ),
    );

    if (_discoveryUrl == null && _stickerUrl == null) {
      setState(() {
        _messageController.clear();
        _messageText = null;
      });
    } else {
      setState(() {
        _messageController.clear();
        _messageText = null;
        _discoveryUrl = null;
        _stickerUrl = null;
        _lastDiscoveryTime = DateTime.now();
        _isDiscoveryButtonEnabled = false;
      });
      _startCountdown();
    }
  }

  void _selectSticker() async {
    await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return StickerPicker(
          onStickerSelected: (stickerUrl) {
            setState(() {
              _stickerUrl = stickerUrl;
            });
            _submitMessage();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingTime =
        15 * 60 - DateTime.now().difference(_lastDiscoveryTime).inSeconds;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              if (_me != null && _me.isModerator)
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (!_isDiscoveryButtonEnabled)
                      Positioned(
                        bottom: -4,
                        child: Text(
                            _formatDuration(Duration(seconds: remainingTime)),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            )),
                      ),
                  ],
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.emoji_emotions),
                onPressed: _selectSticker,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  onChanged: (value) {
                    setState(() {
                      _messageText = value.trim();
                    });
                  },
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    labelText: _discoveryUrl == null
                        ? 'Message text...'
                        : 'Discovery text...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(
                  Icons.send,
                ),
                onPressed: (_messageText != null && _messageText!.isNotEmpty) ||
                        _discoveryUrl != null
                    ? _submitMessage
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StickerPicker extends StatefulWidget {
  final Function(String) onStickerSelected;

  const StickerPicker({required this.onStickerSelected, Key? key}) : super(key: key);

  @override
  _StickerPickerState createState() => _StickerPickerState();
}

class _StickerPickerState extends State<StickerPicker> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _stickers = [];

  Future<void> _searchStickers(String query) async {
    final response = await http.get(Uri.parse(
        'https://api.giphy.com/v1/stickers/search?api_key=7cUCUyn17wvC2WNB9izqTp6WmIn38KUj&q=$query&limit=20'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _stickers = List<String>.from(
            data['data'].map((item) => item['images']['fixed_height']['url']));
      });
    } else {
      throw Exception('Failed to load stickers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Stickers',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _searchStickers(_searchController.text);
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
            ),
            itemCount: _stickers.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  widget.onStickerSelected(_stickers[index]);
                  Navigator.pop(context);
                },
                child: Image.network(_stickers[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
