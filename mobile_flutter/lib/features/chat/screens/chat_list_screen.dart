import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resident_app/features/chat/models/conversation.dart';
import 'package:resident_app/features/chat/screens/chat_screen.dart';
import 'package:resident_app/features/chat/services/chat_service.dart';
import 'package:resident_app/features/chat/widgets/conversation_tile.dart';
import 'package:resident_app/features/contact_admin/services/contact_admin_service.dart';

class _C {
  static const forest = Color(0xFF1C3B2E);
  static const champagne = Color(0xFFE8D9B5);
  static const gold = Color(0xFFB8974A);
  static const sage = Color(0xFF6B9E80);
  static const pageBg = Color(0xFFF5F0E8);
  static const textDark = Color(0xFF1A1A1A);
  static const textGray = Color(0xFF9A9A9A);
  static const urgent = Color(0xFFC0392B);
  static const medium = Color(0xFFE67E22);
  static const low = Color(0xFF27AE60);
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  Conversation? _groupConversation;
  List<Conversation> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    debugPrint('CHAT LIST: initState');
    _load();
  }

  Future<void> _refreshAfterChat() async {
    if (!mounted) return;
    setState(() => _loading = true);
    await _load();
  }

  Future<void> _load() async {
    debugPrint('CHAT LIST: loading conversations...');
    try {
      final group = await ChatService.fetchGroupConversation();
      final convs = await ChatService.fetchConversations();

      debugPrint('CHAT LIST: group loaded => id=${group.id}');
      debugPrint(
        'CHAT LIST: private conversations loaded => count=${convs.length}',
      );

      if (mounted) {
        setState(() {
          _groupConversation = group;
          _conversations = convs;
          _loading = false;
        });
      }
    } catch (e, st) {
      debugPrint('CHAT LIST: load failed => $e');
      debugPrint('$st');

      if (mounted) {
        setState(() => _loading = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_formatErrorMessage(e))));
      }
    }
  }

  Future<void> _openGroupChat() async {
    if (_groupConversation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Residence chat is still loading.')),
      );
      return;
    }

    debugPrint(
      'CHAT LIST: open residence group chat => id=${_groupConversation!.id}',
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: _groupConversation!.id,
          title: 'Residence Chat',
          subtitle: 'All residents',
          isGroup: true,
        ),
      ),
    );

    await _refreshAfterChat();
  }

  void _openNewDm() {
    debugPrint('CHAT LIST: open new DM sheet');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewDmSheet(
        onSelectResident: (resident) async {
          debugPrint(
            'CHAT LIST: resident selected for new DM => ${resident.name} (${resident.unit})',
          );

          Navigator.pop(context);

          try {
            final conv = await ChatService.startConversation(resident);

            if (!mounted) return;

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  conversationId: conv.id,
                  title: conv.otherUserName,
                  subtitle: conv.otherUserUnit,
                  isGroup: false,
                ),
              ),
            );

            await _refreshAfterChat();
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(_formatErrorMessage(e))));
          }
        },
      ),
    );
  }

  void _openContactAdmin() {
    debugPrint('CHAT LIST: open Contact Admin sheet');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ContactAdminSheet(),
    );
  }

  String _formatErrorMessage(Object error) {
    final raw = error.toString().trim();

    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '');
    }

    return raw.isEmpty ? 'Something went wrong.' : raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.pageBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: _C.forest,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Messages',
                        style: TextStyle(
                          color: _C.champagne,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Group & direct messages',
                        style: TextStyle(color: _C.sage, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _openNewDm,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _C.champagne.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _C.gold.withOpacity(0.30),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: _C.champagne,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _openContactAdmin,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _C.champagne.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _C.gold.withOpacity(0.30),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: _C.champagne,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: GestureDetector(
                      onTap: _openGroupChat,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _C.forest,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _C.forest.withOpacity(0.30),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: _C.champagne.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _C.gold.withOpacity(0.30),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.groups_rounded,
                                color: _C.champagne,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Residence Chat',
                                    style: TextStyle(
                                      color: _C.champagne,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Group chat for all residents',
                                    style: TextStyle(
                                      color: _C.sage,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: _C.sage,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
                    child: Text(
                      'DIRECT MESSAGES',
                      style: TextStyle(
                        color: _C.textGray,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: _C.gold,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else if (_conversations.isEmpty)
                    _emptyDms()
                  else
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: _C.gold.withOpacity(0.12),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          children: _conversations.map((conv) {
                            return ConversationTile(
                              conversation: conv,
                              onTap: () async {
                                debugPrint(
                                  'CHAT LIST: open DM => id=${conv.id}, title=${conv.otherUserName}',
                                );

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      conversationId: conv.id,
                                      title: conv.otherUserName,
                                      subtitle: conv.otherUserUnit,
                                      isGroup: false,
                                    ),
                                  ),
                                );

                                await _refreshAfterChat();
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyDms() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _C.gold.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.chat_outlined, color: _C.gold, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'No direct messages yet',
              style: TextStyle(
                color: _C.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _openNewDm,
              child: const Text(
                'Tap the pencil icon to start one',
                style: TextStyle(color: _C.gold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewDmSheet extends StatefulWidget {
  const _NewDmSheet({required this.onSelectResident});

  final void Function(Resident) onSelectResident;

  @override
  State<_NewDmSheet> createState() => _NewDmSheetState();
}

class _NewDmSheetState extends State<_NewDmSheet> {
  final _searchCtrl = TextEditingController();
  List<Resident> _all = [];
  List<Resident> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    debugPrint('NEW DM SHEET: initState');
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    debugPrint('NEW DM SHEET: loading residents...');
    try {
      final residents = await ChatService.fetchResidents();
      debugPrint('NEW DM SHEET: residents loaded => count=${residents.length}');

      if (mounted) {
        setState(() {
          _all = residents;
          _filtered = residents;
          _loading = false;
        });
      }
    } catch (e, st) {
      debugPrint('NEW DM SHEET: load failed => $e');
      debugPrint('$st');

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();

    setState(() {
      _filtered = _all.where((r) {
        return r.name.toLowerCase().contains(q) ||
            r.unit.toLowerCase().contains(q);
      }).toList();
    });
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF2A7F62),
      Color(0xFF5B7FA6),
      Color(0xFFB8974A),
      Color(0xFF7B5EA7),
      Color(0xFF2A5240),
    ];

    return colors[name.codeUnits.fold(0, (a, b) => a + b) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _C.textGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'New Message',
                  style: TextStyle(
                    color: _C.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: _C.pageBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.gold.withOpacity(0.25), width: 1),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: _C.textDark, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search by name or unit…',
                  hintStyle: TextStyle(color: _C.textGray, fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: _C.textGray,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: _C.gold,
                      strokeWidth: 2,
                    ),
                  )
                : _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No residents found',
                      style: TextStyle(color: _C.textGray),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final r = _filtered[i];
                      final color = _avatarColor(r.name);

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          debugPrint(
                            'NEW DM SHEET: tapped resident => ${r.name} (${r.unit})',
                          );
                          widget.onSelectResident(r);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: _C.pageBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _C.gold.withOpacity(0.12),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: color.withOpacity(0.15),
                                child: Text(
                                  r.initials,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.name,
                                      style: const TextStyle(
                                        color: _C.textDark,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      r.unit,
                                      style: const TextStyle(
                                        color: _C.gold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: _C.textGray,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ContactAdminSheet extends StatefulWidget {
  const _ContactAdminSheet();

  @override
  State<_ContactAdminSheet> createState() => _ContactAdminSheetState();
}

class _ContactAdminSheetState extends State<_ContactAdminSheet> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  String _urgency = 'Low';
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final subject = _subjectCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both subject and message.'),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _submitting = true);

    try {
      await ContactAdminService.sendRequest(
        subject: subject,
        message: message,
        urgency: _urgency.toLowerCase(),
      );

      if (!mounted) return;

      setState(() {
        _submitting = false;
        _submitted = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _submitting = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_formatErrorMessage(e))));
    }
  }

  String _formatErrorMessage(Object error) {
    final raw = error.toString().trim();

    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '');
    }

    return raw.isEmpty ? 'Failed to send request.' : raw;
  }

  Color _urgencyColor(String u) {
    if (u == 'Urgent') return _C.urgent;
    if (u == 'Medium') return _C.medium;
    return _C.low;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + bottom),
        child: _submitted ? _successState() : _formState(),
      ),
    );
  }

  Widget _successState() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: _C.low.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.check_rounded, color: _C.low, size: 32),
      ),
      const SizedBox(height: 16),
      const Text(
        'Message sent!',
        style: TextStyle(
          color: _C.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'The admin will get back to you soon.',
        style: TextStyle(color: _C.textGray, fontSize: 14),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _C.forest,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Done',
            style: TextStyle(
              color: _C.champagne,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _formState() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: _C.textGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _C.forest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: _C.champagne,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Admin',
                  style: TextStyle(
                    color: _C.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'We\'ll get back to you as soon as possible',
                  style: TextStyle(color: _C.textGray, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      const Text(
        'Urgency level',
        style: TextStyle(
          color: _C.textDark,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: ['Low', 'Medium', 'Urgent'].map((level) {
          final selected = _urgency == level;
          final color = _urgencyColor(level);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _urgency = level);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                height: 40,
                decoration: BoxDecoration(
                  color: selected ? color.withOpacity(0.12) : _C.pageBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? color : _C.textGray.withOpacity(0.2),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  level,
                  style: TextStyle(
                    color: selected ? color : _C.textGray,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      const Text(
        'Subject',
        style: TextStyle(
          color: _C.textDark,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      _inputField(
        controller: _subjectCtrl,
        hint: 'e.g. Noise complaint, Maintenance issue…',
        maxLines: 1,
      ),
      const SizedBox(height: 16),
      const Text(
        'Message',
        style: TextStyle(
          color: _C.textDark,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      _inputField(
        controller: _messageCtrl,
        hint: 'Describe your issue in detail…',
        maxLines: 5,
      ),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: _submitting ? null : _submit,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: _submitting ? _C.forest.withOpacity(0.5) : _C.forest,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: _C.champagne,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Send to Admin',
                  style: TextStyle(
                    color: _C.champagne,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    ],
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.pageBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.gold.withOpacity(0.25), width: 1),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: _C.textDark, fontSize: 14, height: 1.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _C.textGray, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
