import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSendText,
    required this.onSendImage,
  });

  final void Function(String text) onSendText;
  final void Function(String path) onSendImage;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _ctrl   = TextEditingController();
  final _picker = ImagePicker();
  bool  _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(
      () => setState(() => _hasText = _ctrl.text.trim().isNotEmpty),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    _ctrl.clear();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) widget.onSendImage(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left:   12, right: 12, top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset:     const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          // Image picker
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color:        const Color(0xFF1C3B2E).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.image_rounded,
                  color: Color(0xFF1C3B2E), size: 20),
            ),
          ),
          const SizedBox(width: 10),

          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color:        const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFB8974A).withOpacity(0.25),
                    width: 1),
              ),
              child: TextField(
                controller:      _ctrl,
                maxLines:        null,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                    color: Color(0xFF1A1A1A), fontSize: 14, height: 1.4),
                decoration: const InputDecoration(
                  hintText:       'Message the residence…',
                  hintStyle:      TextStyle(
                      color: Color(0xFF9A9A9A), fontSize: 14),
                  border:         InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send button
          GestureDetector(
            onTap: _hasText ? _send : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _hasText
                    ? const Color(0xFF1C3B2E)
                    : const Color(0xFF1C3B2E).withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.send_rounded,
                color: _hasText
                    ? const Color(0xFFE8D9B5)
                    : const Color(0xFFE8D9B5).withOpacity(0.5),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}