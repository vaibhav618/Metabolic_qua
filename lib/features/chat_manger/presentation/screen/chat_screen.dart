import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import '../../../profile_info/data/model/dietician_detail_model.dart';
import '../../data/bloc/chat_bloc.dart';
import '../../data/bloc/chat_event.dart';
import '../../data/bloc/chat_state.dart';
import '../../data/repository/chat_repository.dart';

class ChatScreen extends StatefulWidget {
  final DietitianDetailModel dietitianModel;
  final ClientProfileModel clientProfileModel;
  final String? initialMessage;

  const ChatScreen({
    super.key,
    required this.dietitianModel,
    required this.clientProfileModel,
    this.initialMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  ChatMessage? _replyingTo;
  bool _initialPopupShown = false;

  // ✅ Suggested / quick messages
  final List<String> _suggestedMessages = const [
    "Hi doctor, I have a doubt about my diet.",
    "Can you please review my last test?",
    "What should I eat today for dinner?",
    "I’m feeling low energy today.",
    "Can we update my plan?"
  ];

  static const SystemUiOverlayStyle _kUiStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.red,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  late final ChatUser _sender;
  late final ChatUser _receiver;
  late final ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ Create users + bloc ONCE (prevents dirty-scope errors)
    _sender = ChatUser(
      id: widget.clientProfileModel.profileId,
      firstName: widget.clientProfileModel.profileName,
    );

    _receiver = ChatUser(
      id: widget.dietitianModel.dietitianId,
      firstName: widget.dietitianModel.name,
    );

    _chatBloc = ChatBloc(
      repository: ChatRepository(sender: _sender, receiver: _receiver),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialPopupShown &&
        widget.initialMessage != null &&
        widget.initialMessage!.trim().isNotEmpty) {
      _initialPopupShown = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final msg = widget.initialMessage!.trim();
        _textController.text = msg;
        _textController.selection =
            TextSelection.fromPosition(TextPosition(offset: msg.length));
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _chatBloc.close();
    super.dispose();
  }

  void _sendPlainText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _chatBloc.add(SendMessage(trimmed));
  }

  void _sendFromInput() {
    final rawText = _textController.text.trim();
    if (rawText.isEmpty) return;

    final replyPrefix = _replyingTo != null
        ? '↩️ ${_replyingTo!.user.firstName ?? ''}: '
        '${_replyingTo!.text}\n—\n'
        : '';

    final fullText = '$replyPrefix$rawText';

    _sendPlainText(fullText);
    _textController.clear();
    setState(() => _replyingTo = null);
  }

  Widget _buildSuggestedBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      height: 53,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _suggestedMessages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final txt = _suggestedMessages[i];
          return InkWell(
            onTap: () {
              _sendPlainText(txt);
              _textController.clear();
              setState(() => _replyingTo = null);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE1E6ED)),
              ),
              child: Text(
                txt,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF252525),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ✅ Your OWN custom input + send button (DashChat input hidden)
  Widget _buildCustomInput() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSuggestedBar(),
            Container(
              decoration: ShapeDecoration(
                color: const Color(0xFFF0F0F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: "Type your message....",
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFFA1A1A1),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onChanged: (text) {
                        _chatBloc.add(UpdateTyping(text.isNotEmpty));
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: _sendFromInput,
                    icon: SvgPicture.asset(
                      "assets/images/icons/ic_send.svg",
                      color: const Color(0xFFA1A1A1),
                    ),
                    padding: EdgeInsets.zero,
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _kUiStyle,
      child: WillPopScope(
        onWillPop: () async => true,
        child: BlocProvider.value(
          value: _chatBloc,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Row(
                spacing: 10,
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundImage:
                    NetworkImage(widget.dietitianModel.logoUrl),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.dietitianModel.name,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.26,
                          letterSpacing: -0.32,
                        ),
                      ),
                      Text(
                        widget.dietitianModel.email,
                        style: GoogleFonts.poppins(
                          color: Colors.black.withValues(alpha: 0.62),
                          fontSize: 8,
                          fontWeight: FontWeight.w400,
                          height: 1.26,
                          letterSpacing: -0.16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color.fromRGBO(48, 139, 249, 0.44),
                      Color.fromRGBO(143, 194, 255, 0.29),
                    ],
                  ),
                ),
              ),
              elevation: 0,
              iconTheme: const IconThemeData(
                color: Color(0xFF252525),
              ),
            ),

            body: Column(
              children: [
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state is ChatLoaded) {
                        return Container(
                          color: Colors.white,
                          child: Stack(
                            children: [
                              DashChat(
                                currentUser: _sender,
                                messages: state.messages,

                                // ✅ HIDE DashChat input + send button
                                inputOptions: const InputOptions(
                                  inputDisabled: true,                 // disable field
                                  alwaysShowSend: false,              // hide send
                                  inputToolbarPadding: EdgeInsets.zero,
                                  inputToolbarMargin: EdgeInsets.zero,
                                  inputMaxLines: 1,
                                  leading: <Widget>[],
                                  trailing: <Widget>[],
                                  inputDecoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                  ),
                                  inputTextStyle: TextStyle(fontSize: 0),
                                  inputToolbarStyle: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                ),

                                messageOptions: MessageOptions(
                                  showTime: true,
                                  currentUserContainerColor:
                                  const Color(0xFF1D6ECF),
                                  containerColor:
                                  const Color(0xFFEAF3FF),
                                  showCurrentUserAvatar: false,
                                  showOtherUsersAvatar: true,
                                  avatarBuilder:
                                      (user, onPressAvatar, onLongPressAvatar) {
                                    return Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundImage: NetworkImage(
                                            widget.dietitianModel.logoUrl,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                      ],
                                    );
                                  },
                                ),

                                scrollToBottomOptions:
                                const ScrollToBottomOptions(disabled: true),

                                // still keep onSend for safety (unused now)
                                onSend: (ChatMessage raw) {
                                  _sendPlainText(raw.text);
                                },
                              ),

                              if (state.messages.isEmpty)
                                IgnorePointer(
                                  ignoring: true,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          "assets/images/icons/ic_welcome.png",
                                          width: 90,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "Welcome to chat",
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: -0.28,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "Start a conversation",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF252525),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: -0.20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      } else if (state is ChatError) {
                        return Center(child: Text(state.message));
                      }

                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),

                SizedBox(height: 20,),
                _buildCustomInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
