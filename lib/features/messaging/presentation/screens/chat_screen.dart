import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../match/domain/usecases/unmatch_use_case.dart';
import '../../../match/presentation/providers/match_celebration_provider.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../safety/domain/models/user_report.dart';
import '../../../safety/domain/usecases/block_user_use_case.dart';
import '../../../safety/domain/usecases/report_user_use_case.dart';
import '../../../safety/presentation/providers/block_provider.dart';
import '../../../safety/presentation/providers/report_provider.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/conversation_preview.dart';
import '../../domain/usecases/send_image_message_use_case.dart';
import '../../domain/usecases/send_text_message_use_case.dart';
import '../providers/chat_provider.dart';
import '../providers/typing_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.matchId,
    this.preview,
  });

  final String matchId;
  final ConversationPreview? preview;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final TextEditingController _textController;
  late final ScrollController _scrollController;
  bool _isSending = false;
  bool _isUnmatching = false;
  bool _isBlocking = false;
  bool _isReporting = false;
  Timer? _typingTimer;
  bool _isTypingSet = false;
  final Set<String> _markedReadIds = {};

  static final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _clearTyping();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText) {
      if (!_isTypingSet) {
        _isTypingSet = true;
        _setTypingRemote(true);
      }
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _isTypingSet = false;
        _setTypingRemote(false);
      });
    } else {
      _typingTimer?.cancel();
      if (_isTypingSet) {
        _isTypingSet = false;
        _setTypingRemote(false);
      }
    }
  }

  void _setTypingRemote(bool isTyping) {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;
    ref.read(setTypingUseCaseProvider).execute(
          matchId: widget.matchId,
          userId: currentUser.id,
          isTyping: isTyping,
        );
  }

  void _clearTyping() {
    _typingTimer?.cancel();
    _typingTimer = null;
    if (_isTypingSet) {
      _isTypingSet = false;
      _setTypingRemote(false);
    }
  }

  void _markIncomingRead(List<ChatMessage> messages) {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;
    final unread = messages
        .where((m) =>
            m.shouldMarkRead(currentUser.id) &&
            !_markedReadIds.contains(m.id))
        .map((m) => m.id)
        .toList();
    if (unread.isEmpty) return;
    _markedReadIds.addAll(unread);
    ref.read(markMessagesReadUseCaseProvider).execute(
          matchId: widget.matchId,
          currentUserId: currentUser.id,
          messageIds: unread,
        );
  }

  Future<void> _showUnmatchDialog() async {
    if (_isUnmatching) return;
    final l10n = AppLocalizations.of(context);
    final nickname = widget.preview?.nickname;
    final displayName = (nickname != null && nickname.isNotEmpty)
        ? nickname
        : l10n.chatUnknownUser;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.chatUnmatchTitle),
        content: Text(l10n.chatUnmatchBody(displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.chatUnmatchCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.chatUnmatchConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _unmatch();
  }

  Future<void> _unmatch() async {
    if (_isUnmatching) return;
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    setState(() => _isUnmatching = true);
    _clearTyping();

    final result = await ref.read(unmatchUseCaseProvider).execute(
          matchId: widget.matchId,
          currentUserId: currentUser.id,
        );

    if (!mounted) return;
    setState(() => _isUnmatching = false);

    final l10n = AppLocalizations.of(context);
    switch (result) {
      case UnmatchSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.chatUnmatchSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      case UnmatchValidationError():
        break;
      case UnmatchFailure():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.chatUnmatchFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _showBlockDialog() async {
    if (_isBlocking) return;
    final otherUserId = widget.preview?.otherUserId;
    if (otherUserId == null || otherUserId.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.safetyBlockTitle),
        content: Text(l10n.safetyBlockBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.safetyBlockCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.safetyBlockConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _block(otherUserId);
  }

  Future<void> _block(String otherUserId) async {
    if (_isBlocking) return;
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    setState(() => _isBlocking = true);
    _clearTyping();

    final result = await ref.read(blockUserUseCaseProvider).execute(
          currentUserId: currentUser.id,
          blockedUserId: otherUserId,
        );

    if (!mounted) return;
    setState(() => _isBlocking = false);

    final l10n = AppLocalizations.of(context);
    switch (result) {
      case BlockUserSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.safetyBlockSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      case BlockUserValidationError():
        break;
      case BlockUserFailure():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.safetyBlockFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _showReportSheet() async {
    if (_isReporting) return;
    final otherUserId = widget.preview?.otherUserId;
    if (otherUserId == null || otherUserId.isEmpty) return;

    final result = await showModalBottomSheet<(ReportReason, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _ReportSheet(),
    );
    if (result == null) return;
    await _report(otherUserId, result.$1, result.$2);
  }

  Future<void> _report(
    String otherUserId,
    ReportReason reason,
    String description,
  ) async {
    if (_isReporting) return;
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    setState(() => _isReporting = true);

    final result = await ref.read(reportUserUseCaseProvider).execute(
          reporterId: currentUser.id,
          targetUserId: otherUserId,
          reason: reason,
          description: description,
        );

    if (!mounted) return;
    setState(() => _isReporting = false);

    final l10n = AppLocalizations.of(context);
    switch (result) {
      case ReportUserSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.safetyReportSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case ReportUserFailure():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.safetyReportFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case ReportUserValidationError():
        break;
    }
  }

  Future<void> _pickAndSendImage() async {
    if (_isSending) return;

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (file == null) return;
    if (!mounted) return;

    setState(() => _isSending = true);

    final result = await ref.read(sendImageMessageUseCaseProvider).execute(
          matchId: widget.matchId,
          senderId: currentUser.id,
          imageFilePath: file.path,
        );

    if (!mounted) return;
    setState(() => _isSending = false);

    switch (result) {
      case SendImageMessageSuccess():
        _scrollToBottom();
      case SendImageMessageFailure():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).chatImageSendFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case SendImageMessageValidationError():
        break;
    }
  }

  Future<void> _send() async {
    final content = _textController.text;
    final trimmed = content.trim();
    if (trimmed.isEmpty || _isSending) return;

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    setState(() => _isSending = true);

    final result = await ref.read(sendTextMessageUseCaseProvider).execute(
          matchId: widget.matchId,
          senderId: currentUser.id,
          content: trimmed,
        );

    if (!mounted) return;
    setState(() => _isSending = false);

    switch (result) {
      case SendTextMessageSuccess():
        _clearTyping();
        _textController.clear();
        _scrollToBottom();
      case SendTextMessageFailure():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).chatSendFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case SendTextMessageValidationError():
        break;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final asyncMessages = ref.watch(chatMessagesProvider(widget.matchId));

    final isOtherTyping = currentUser != null
        ? ref
                .watch(otherUserTypingProvider((
                  matchId: widget.matchId,
                  currentUserId: currentUser.id,
                )))
                .valueOrNull ??
            false
        : false;

    final typingName = (widget.preview?.nickname.isNotEmpty ?? false)
        ? widget.preview!.nickname
        : l10n.chatTypingFallbackName;

    ref.listen(chatMessagesProvider(widget.matchId), (_, next) {
      if (next.hasValue && next.value!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        _markIncomingRead(next.value!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _ChatAppBar(
        preview: widget.preview,
        onUnmatch: _showUnmatchDialog,
        onBlock: _showBlockDialog,
        onReport: _showReportSheet,
      ),
      body: Column(
        children: [
          Expanded(
            child: asyncMessages.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (_, _) => _ErrorView(
                title: l10n.chatLoadErrorTitle,
                body: l10n.chatLoadErrorBody,
                retryLabel: l10n.chatRetry,
                onRetry: () =>
                    ref.invalidate(chatMessagesProvider(widget.matchId)),
              ),
              data: (messages) => messages.isEmpty
                  ? _EmptyView(text: l10n.chatStartConversation)
                  : _MessageList(
                      messages: messages,
                      currentUserId: currentUser?.id ?? '',
                      scrollController: _scrollController,
                    ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: isOtherTyping
                ? _TypingIndicator(name: typingName)
                : const SizedBox.shrink(),
          ),
          _Composer(
            controller: _textController,
            isSending: _isSending,
            onSend: _send,
            hint: l10n.chatMessageHint,
            onAttachImage: _pickAndSendImage,
            attachImageLabel: l10n.chatAttachImage,
          ),
        ],
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _ChatAppBar({this.preview, this.onUnmatch, this.onBlock, this.onReport});

  final ConversationPreview? preview;
  final VoidCallback? onUnmatch;
  final VoidCallback? onBlock;
  final VoidCallback? onReport;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nickname = (preview?.nickname.isNotEmpty ?? false)
        ? preview!.nickname
        : l10n.chatUnknownUser;
    final nameWithAge =
        preview?.age != null ? '$nickname, ${preview!.age}' : nickname;

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
      titleSpacing: 0,
      title: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 36,
              height: 36,
              child: _Avatar(imageUrl: preview?.profileImageUrl),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              nameWithAge,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) {
            if (value == 'unmatch') onUnmatch?.call();
            if (value == 'report') onReport?.call();
            if (value == 'block') onBlock?.call();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'unmatch',
              child: Text(
                l10n.chatUnmatch,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.error),
              ),
            ),
            if (preview?.otherUserId.isNotEmpty ?? false)
              PopupMenuItem(
                value: 'report',
                child: Text(
                  l10n.safetyReportUser,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textPrimary),
                ),
              ),
            if (preview?.otherUserId.isNotEmpty ?? false)
              PopupMenuItem(
                value: 'block',
                child: Text(
                  l10n.safetyBlockUser,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.error),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({this.imageUrl});

  final String? imageUrl;

  static const _placeholder = ColoredBox(
    color: AppColors.primaryLight,
    child: Center(
      child: Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) return _placeholder;
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (_, _) => _placeholder,
      errorWidget: (_, _, _) => _placeholder,
    );
  }
}

// ── Message list ──────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
  });

  final List<ChatMessage> messages;
  final String currentUserId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final lastOutgoingIndex =
        messages.lastIndexWhere((m) => m.senderId == currentUserId);
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) => _MessageBubble(
        message: messages[index],
        isOwnMessage: messages[index].senderId == currentUserId,
        currentUserId: currentUserId,
        showReadStatus: index == lastOutgoingIndex,
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isOwnMessage,
    required this.currentUserId,
    required this.showReadStatus,
  });

  final ChatMessage message;
  final bool isOwnMessage;
  final String currentUserId;
  final bool showReadStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final time = _formatTime(message.createdAt);
    const r = AppRadius.messagebubble;
    const corner4 = Radius.circular(4);
    const cornerR = Radius.circular(r);

    final borderRadius = BorderRadius.only(
      topLeft: cornerR,
      topRight: cornerR,
      bottomLeft: isOwnMessage ? cornerR : corner4,
      bottomRight: isOwnMessage ? corner4 : cornerR,
    );
    final bubbleColor =
        isOwnMessage ? AppColors.messageSent : AppColors.messageReceived;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.72;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isOwnMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (message.type == MessageType.image)
                  _ImageBubble(
                    imageUrl: message.imageUrl,
                    borderRadius: borderRadius,
                    bubbleColor: bubbleColor,
                    maxWidth: maxWidth,
                    fallback: l10n.chatImageMessageFallback,
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: borderRadius,
                    ),
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                if (time.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                  ),
                ],
                if (isOwnMessage && showReadStatus) ...[
                  const SizedBox(height: 2),
                  Text(
                    message.isReadByOtherParticipant(currentUserId)
                        ? l10n.chatMessageRead
                        : l10n.chatMessageSent,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Image bubble ──────────────────────────────────────────────────────────────

class _ImageBubble extends StatelessWidget {
  const _ImageBubble({
    required this.imageUrl,
    required this.borderRadius,
    required this.bubbleColor,
    required this.maxWidth,
    required this.fallback,
  });

  final String? imageUrl;
  final BorderRadius borderRadius;
  final Color bubbleColor;
  final double maxWidth;
  final String fallback;

  static const double _imageHeight = 200;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: maxWidth,
        height: _imageHeight,
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Text(
            fallback,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: maxWidth,
        height: _imageHeight,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          width: maxWidth,
          height: _imageHeight,
          color: bubbleColor,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        errorWidget: (_, _, _) => Container(
          width: maxWidth,
          height: _imageHeight,
          color: bubbleColor,
          child: const Center(
            child: Icon(
              Icons.broken_image_rounded,
              color: AppColors.textSecondary,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Composer ──────────────────────────────────────────────────────────────────

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.hint,
    required this.onAttachImage,
    required this.attachImageLabel,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final String hint;
  final VoidCallback onAttachImage;
  final String attachImageLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                onPressed: isSending ? null : onAttachImage,
                icon: const Icon(Icons.image_outlined),
                color: AppColors.textSecondary,
                disabledColor: AppColors.textDisabled,
                padding: EdgeInsets.zero,
                tooltip: attachImageLabel,
                style: IconButton.styleFrom(
                  minimumSize: const Size(44, 44),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isSending,
                maxLines: 5,
                minLines: 1,
                maxLength: kMaxMessageLength,
                buildCounter:
                    (_, {required currentLength, required isFocused, maxLength}) =>
                        null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle:
                      const TextStyle(color: AppColors.textDisabled),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 44,
              height: 44,
              child: isSending
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : ValueListenableBuilder(
                      valueListenable: controller,
                      builder: (_, value, _) => IconButton(
                        onPressed:
                            value.text.trim().isNotEmpty ? onSend : null,
                        icon: const Icon(Icons.send_rounded),
                        color: AppColors.primary,
                        disabledColor: AppColors.textDisabled,
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(44, 44),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        children: [
          const _TypingDots(),
          const SizedBox(width: AppSpacing.sm),
          Text(
            l10n.chatTypingIndicator(name),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(0),
          const SizedBox(width: 3),
          _buildDot(1),
          const SizedBox(width: 3),
          _buildDot(2),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final t = (_ctrl.value + index * 0.333) % 1.0;
    final opacity = (t < 0.5 ? 0.3 + t * 1.4 : 1.0 - (t - 0.5) * 1.4)
        .clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.textSecondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.title,
    required this.body,
    required this.retryLabel,
    required this.onRetry,
  });

  final String title;
  final String body;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Report sheet ──────────────────────────────────────────────────────────────

class _ReportSheet extends StatefulWidget {
  const _ReportSheet();

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  ReportReason? _reason;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_reason == null) return;
    Navigator.of(context).pop((_reason!, _descController.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                l10n.safetyReportTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
            RadioGroup<ReportReason>(
              groupValue: _reason,
              onChanged: (v) => setState(() => _reason = v),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final reason in ReportReason.values)
                    RadioListTile<ReportReason>(
                      value: reason,
                      title: Text(
                        _reasonLabel(l10n, reason),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                      activeColor: AppColors.primary,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: TextField(
                controller: _descController,
                maxLines: 3,
                minLines: 1,
                maxLength: kMaxReportDescriptionLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.safetyReportDescriptionHint,
                  hintStyle: const TextStyle(color: AppColors.textDisabled),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  isDense: true,
                  counterText: '',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side:
                            const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.button),
                        ),
                      ),
                      child: Text(l10n.safetyReportCancel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: _reason != null ? _submit : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.textDisabled,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.button),
                        ),
                      ),
                      child: Text(l10n.safetyReportSubmit),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _reasonLabel(AppLocalizations l10n, ReportReason reason) =>
      switch (reason) {
        ReportReason.spam => l10n.safetyReportReasonSpam,
        ReportReason.fakeProfile => l10n.safetyReportReasonFakeProfile,
        ReportReason.harassment => l10n.safetyReportReasonHarassment,
        ReportReason.hateSpeech => l10n.safetyReportReasonHateSpeech,
        ReportReason.inappropriateContent =>
          l10n.safetyReportReasonInappropriateContent,
      };
}
