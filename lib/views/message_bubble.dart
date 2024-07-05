import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  // Factories to create different types of message bubbles
  factory MessageBubble.withUser({
    required String userAvatarUrl,
    required String userName,
    required String text,
    required bool isMine,
    required bool isLast,
    Function()? onDelete,
  }) {
    return MessageBubble._internal(
      userAvatarUrl: userAvatarUrl,
      userName: userName,
      text: text,
      isMine: isMine,
      isLast: isLast,
      onDelete: onDelete,
    );
  }

  factory MessageBubble.discovery({
    required String text,
    required bool isMine,
    required String discoveryUrl,
    Function()? onDelete,
  }) {
    return MessageBubble._internal(
      text: text,
      isMine: isMine,
      discoveryUrl: discoveryUrl,
      onDelete: onDelete,
    );
  }

  const MessageBubble({
    Key? key,
    required this.text,
    required this.isMine,
    this.isLast,
    this.onDelete,
    this.userAvatarUrl,
    this.userName,
    this.discoveryUrl,
  }) : super(key: key);

  // Internal constructor to handle the different types of message bubbles
  const MessageBubble._internal({
    required this.text,
    required this.isMine,
    this.isLast,
    this.onDelete,
    this.userAvatarUrl,
    this.userName,
    this.discoveryUrl,
  });

  final bool? isLast;
  final String? userAvatarUrl;
  final String? userName;
  final String text;
  final bool isMine;
  final String? discoveryUrl;
  final Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    if (discoveryUrl != null) {
      return _buildDiscoveryBubble(context);
    } else if (userAvatarUrl != null && userName != null) {
      return _buildWithUserBubble(context);
    } else {
      return _buildDefaultBubble(context);
    }
  }

  Widget _buildDefaultBubble(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isMine
                ? theme.colorScheme.primary
                : theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: !isMine ? Radius.zero : const Radius.circular(16),
              topRight: isMine ? Radius.zero : const Radius.circular(16),
              bottomLeft: isMine || (isLast ?? false)
                  ? const Radius.circular(16)
                  : Radius.zero,
              bottomRight: !isMine || (isLast ?? false)
                  ? const Radius.circular(16)
                  : Radius.zero,
            ),
          ),
          constraints: const BoxConstraints(maxWidth: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          // Add some margin to the edges of the messages, to allow space for the user's image.
          margin:
              EdgeInsets.symmetric(vertical: 2, horizontal: isMine ? 8 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  // height: 1.3,
                  color: isMine
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onPrimaryContainer,
                ),
                softWrap: true,
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                  ),
                  color: isMine
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onPrimaryContainer,
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWithUserBubble(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: isMine ? Alignment.topRight : Alignment.topLeft,
      children: [
        if (!isMine && userAvatarUrl != null)
          Positioned(
            top: 16,
            child: CircleAvatar(
              backgroundImage: NetworkImage(userAvatarUrl!),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 12,
            ),
          ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: isMine ? 0 : 24),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMine && userName != null) ...[
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                  child: Text(
                    userName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                )
              ],
              Container(
                decoration: BoxDecoration(
                  color: isMine
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.only(
                    topLeft: !isMine ? Radius.zero : const Radius.circular(16),
                    topRight: isMine ? Radius.zero : const Radius.circular(16),
                    bottomLeft: isMine || (isLast ?? false)
                        ? const Radius.circular(16)
                        : Radius.zero,
                    bottomRight: !isMine || (isLast ?? false)
                        ? const Radius.circular(16)
                        : Radius.zero,
                  ),
                ),
                constraints: const BoxConstraints(maxWidth: 200),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        // height: 1.3,
                        color: isMine
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                      softWrap: true,
                    ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                        ),
                        color: isMine
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onPrimaryContainer,
                        onPressed: onDelete,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryBubble(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        decoration: BoxDecoration(
          image: discoveryUrl != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(discoveryUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          borderRadius: BorderRadius.circular(24),
        ),
        width: 300,
        height: 300,
        margin: const EdgeInsets.symmetric(vertical: 24),
        // padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 16,
              child: Text(
                text,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onPrimary,
                  shadows: [
                    Shadow(
                      // offset: const Offset(0.0, 2.0),
                      blurRadius: 24,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ],
                ),
                softWrap: true,
              ),
            ),
            // if (onDelete != null)
            //   Positioned(
            //     bottom: 4,
            //     right: 4,
            //     child: IconButton(
            //       icon: const Icon(
            //         Icons.close,
            //         size: 16,
            //       ),
            //       color: theme.colorScheme.onPrimary,
            //       onPressed: onDelete,
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
