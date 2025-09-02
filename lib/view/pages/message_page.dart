import 'dart:async';

import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/models/chat_messages.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/services/chat_services.dart';
import 'package:bharat_worker/widgets/common_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/chat_provider.dart';
import '../../provider/notification_provider.dart';
import '../../provider/message_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../constants/assets_paths.dart';
import '../../constants/font_style.dart';
import '../../helper/router.dart';
import 'package:flutter/services.dart';

// Import the list variable from chat_services
import '../../services/chat_services.dart' show list;

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _searchController = TextEditingController();
  ChatServices? chatServices; // Make it nullable
  StreamSubscription<QuerySnapshot>? _allMessagesSubscription;

  @override
  void dispose() {
    _searchController.dispose();
    _allMessagesSubscription?.cancel();
    super.dispose();
  }

  // Helper function to format timestamp
  String _formatLastSeenTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize chatServices immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeChatServices();
    });

    // Fetch user list when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().getProfileData();
      context.read<ProfileProvider>().getProfile();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().fetchUserList();
      setUser();
    });

    // Add listener to search controller
    _searchController.addListener(() {
      setState(() {
        // This will trigger rebuild with new search query
      });
    });
  }

  void initializeChatServices() {
    try {
      chatServices = Provider.of<ChatProvider>(context, listen: false).chatServices;
    } catch (e) {
      print('Error initializing chatServices: $e');
    }
  }

  String userId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.whiteColor,
      appBar: commonAppBar(() {
        // Navigator.pop(context);
      }, 'Messages', isLeading: false, actions: [
        InkWell(
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: MyColors.borderColor),
                  borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.all(10),
              child: SvgPicture.asset(MyAssetsPaths.notificationIcon)),
          onTap: () {
            context.push(AppRouter.notifications);
          },
        )
      ]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hsized25,

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: CommonTextField(
                        controller: _searchController,
                        borderRadius: 45,
                        borderColor: Color(0xFFEEEEEE),
                        hintText: 'Search',
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            MyAssetsPaths.searchIcon,
                            color: MyColors.lightText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  wsized10,
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: MyColors.borderColor),
                          shape: BoxShape.circle),
                      padding: EdgeInsets.all(8),
                      child: SvgPicture.asset(
                        MyAssetsPaths.filterIcon,
                        height: 24,
                        width: 24,
                      ))
                ],
              ),
              hsized25,

              // Show loading or error state
              Consumer<MessageProvider>(
                builder: (context, messageProvider, child) {
                  if (messageProvider.isLoading) {
                    return Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: MyColors.appTheme,
                        ),
                      ),
                    );
                  }

                  if (messageProvider.error != null) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              messageProvider.error!,
                              style: regularTextStyle(
                                fontSize: 16.0,
                                color: MyColors.darkText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            hsized20,
                            ElevatedButton(
                              onPressed: () {
                                messageProvider.fetchUserList();
                              },
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (messageProvider.userList.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          'No partners found',
                          style: regularTextStyle(
                            fontSize: 16.0,
                            color: MyColors.darkText,
                          ),
                        ),
                      ),
                    );
                  }

                  // Check if chatServices is initialized
                  if (chatServices == null) {
                    return Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: MyColors.appTheme,
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: _SortedUserList(
                      userList: messageProvider.userList,
                      chatServices: chatServices!,
                      userId: userId,
                      searchQuery: _searchController.text.trim(),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void setUser() {
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      // Create a numeric ID from the MongoDB ObjectId for chat compatibility
      userId = profileProvider.partner?.id != null
          ? (profileProvider.partner!.id)
          .toString() // Convert ObjectId to numeric ID
          : "10"; // Fallback to default

      // Initialize chatServices if not already done
      if (chatServices == null) {
        chatServices = Provider.of<ChatProvider>(context, listen: false).chatServices;
      }

      if (chatServices != null) {
        chatServices!.getSelfInfo(userId, "", "", 0);
      }

      // Listen to all incoming messages for notification
     /* final firestore = FirebaseFirestore.instance;
      _allMessagesSubscription =
          firestore.collection('chat').snapshots().listen((chatSnapshot) {
            for (var chatDoc in chatSnapshot.docs) {
              firestore
                  .collection('chat')
                  .doc(chatDoc.id)
                  .collection('Message')
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .get()
                  .then((msgSnapshot) {
                if (msgSnapshot.docs.isNotEmpty) {
                  final msgData = msgSnapshot.docs.first.data();
                  final groupChatId = chatDoc.id;
                  // Only notify if this chat is NOT currently open
                  if (CurrentChat.groupChatId != groupChatId) {
                    final content = msgData['content'] ?? '';
                    final senderId = msgData['sender_id'] ?? '';
                    final type = msgData['type'] ?? '';
                    final NotificationProvider notificationProvider =
                    Provider.of<NotificationProvider>(context, listen: false);
                    if (senderId != userId && content.isNotEmpty)  {
                      notificationProvider.flutterLocalNotificationsPlugin.show(
                        msgSnapshot.docs.first.hashCode,
                        'New Message Customer',
                        content,
                        const NotificationDetails(
                          android: AndroidNotificationDetails(
                            'default_channel',
                            'Default',
                            channelDescription: 'Default channel for notifications',
                            importance: Importance.max,
                            priority: Priority.high,
                            playSound: true,
                            enableVibration: true,
                            enableLights: true,
                            ledColor: Color(0xFF00FF00),
                            ledOnMs: 1000,
                            ledOffMs: 500,
                            showWhen: true,
                          ),
                        ),
                      );
                    }
                  }
                }
              });
            }
          });*/

    } catch (e) {
      print('Error in setUser: $e');
    }
  }
}

class _SortedUserList extends StatefulWidget {
  final List<dynamic> userList;
  final ChatServices chatServices;
  final String userId;
  final String searchQuery;

  const _SortedUserList({
    required this.userList,
    required this.chatServices,
    required this.userId,
    required this.searchQuery,
  });

  @override
  State<_SortedUserList> createState() => _SortedUserListState();
}

class _SortedUserListState extends State<_SortedUserList> {
  List<dynamic> sortedUserList = [];
  Map<String, DateTime> userLastMessageTime = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUserList();
  }

  void _initializeUserList() {
    setState(() {
      sortedUserList = List.from(widget.userList);
      isLoading = true;
    });
    _fetchAllLastMessageTimes();
  }

  Future<void> _fetchAllLastMessageTimes() async {
    Map<String, DateTime> tempUserTimes = {};
    
    // Fetch last message time for each user
    for (var user in widget.userList) {
      final String partnerId = (user.id).toString();
      final String groupChatId = widget.chatServices.getChatRoomIdByUserId(widget.userId, partnerId);
      
      try {
        final snapshot = await widget.chatServices.firebaseFirestore
            .collection('chat')
            .doc(groupChatId)
            .collection('Message')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
        
        if (snapshot.docs.isNotEmpty) {
          final lastMsg = ChatMessages.fromDocument(snapshot.docs.first);
          tempUserTimes[partnerId] = lastMsg.timestamp.toDate();
        } else {
          tempUserTimes[partnerId] = DateTime(1970); // Default for users with no messages
        }
      } catch (e) {
        tempUserTimes[partnerId] = DateTime(1970);
      }
    }
    
    if (mounted) {
      setState(() {
        userLastMessageTime = tempUserTimes;
        _sortUsers();
        isLoading = false;
      });
    }
  }

  void _sortUsers() {
    sortedUserList.sort((a, b) {
      final aTime = userLastMessageTime[a.id.toString()] ?? DateTime(1970);
      final bTime = userLastMessageTime[b.id.toString()] ?? DateTime(1970);
      return bTime.compareTo(aTime); // Descending order (newest first)
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: MyColors.appTheme,
        ),
      );
    }

    // Filter users based on search query
    List<dynamic> filteredUserList = sortedUserList.where((user) {
      if (widget.searchQuery.isEmpty) {
        return true; // Show all users when search is empty
      }
      final userName = user.user.name.toLowerCase();
      final searchLower = widget.searchQuery.toLowerCase();
      return userName.contains(searchLower);
    }).toList();

    if (filteredUserList.isEmpty && widget.searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: MyColors.color838383,
            ),
            hsized20,
            Text(
              'No users found for "${widget.searchQuery}"',
              style: regularTextStyle(
                fontSize: 16.0,
                color: MyColors.color838383,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: filteredUserList.length,
      separatorBuilder: (context, index) => hsized30,
      itemBuilder: (context, index) {
        final partner = filteredUserList[index];
        final String partnerId = (partner.id).toString();

        return InkWell(
          onTap: () {
            context.push(
              AppRouter.chat,
              extra: {
                'customerName': partner.user.name,
                'customerAddress': partner.address ?? '',
                'customerAvatarUrl': partner.profile.isNotEmpty == true
                    ? partner.profile
                    : 'https://randomuser.me/api/portraits/men/1.jpg',
                'jobType': "",
                'jobDateTime': "",
                'receiverId': partnerId,
              },
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: getColorFromName(partner.user.name),
                      child: partner.profile?.isNotEmpty == true
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(500),
                        child: Image.network(
                          partner.profile!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              partner.user.name.isNotEmpty
                                  ? partner.user.name[0].toUpperCase()
                                  : 'U',
                              style: boldTextStyle(
                                fontSize: 18.0,
                                color: MyColors.whiteColor,
                              ),
                            );
                          },
                        ),
                      )
                          : Text(
                        partner.user.name.isNotEmpty
                            ? partner.user.name[0].toUpperCase()
                            : 'U',
                        style: boldTextStyle(
                          fontSize: 18.0,
                          color: MyColors.whiteColor,
                        ),
                      ),
                    ),

                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(partner.user.name,
                              style: semiBoldTextStyle(
                                  fontSize: 16.0, color: MyColors.darkText)),
                          hsized5,
                          StreamBuilder<QuerySnapshot>(
                            stream: widget.chatServices.getChatMessage(
                              widget.chatServices.getChatRoomIdByUserId(
                                  widget.userId, partnerId),
                              1, // Only need the latest message
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                final lastMsg = ChatMessages.fromDocument(
                                    snapshot.data!.docs.first);
                                
                                // Update sorting when new message arrives
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    final newTime = lastMsg.timestamp.toDate();
                                    if (userLastMessageTime[partnerId] != newTime) {
                                      setState(() {
                                        userLastMessageTime[partnerId] = newTime;
                                        _sortUsers();
                                      });
                                    }
                                  }
                                });

                                if (lastMsg.type == MessageType.image) {
                                  return Row(
                                    children: [
                                      Icon(Icons.image,
                                          size: 16, color: MyColors.color838383),
                                      SizedBox(width: 4),
                                      Text(
                                        'Photo',
                                        style: regularTextStyle(
                                            fontSize: 14.0,
                                            color: MyColors.blackColor),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  );
                                }else if (lastMsg.type == MessageType.location) {
                                  return Row(
                                    children: [
                                      Icon(Icons.location_on_rounded,
                                          size: 16, color: MyColors.color838383),
                                      SizedBox(width: 4),
                                      Text(
                                        'Location',
                                        style: regularTextStyle(
                                            fontSize: 14.0,
                                            color: MyColors.blackColor),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  );
                                } else {
                                  return Text(
                                    lastMsg.content,
                                    style: regularTextStyle(
                                        fontSize: 14.0, color: MyColors.blackColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }
                              } else {
                                return Text(
                                  '',
                                  style: regularTextStyle(
                                      fontSize: 14.0, color: MyColors.blackColor),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: widget.chatServices.getChatMessage(
                      widget.chatServices.getChatRoomIdByUserId(widget.userId, partnerId),
                      1, // Only need the latest message
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        final lastMsg = ChatMessages.fromDocument(snapshot.data!.docs.first);
                        return Text(
                          _formatLastSeenTime(lastMsg.timestamp.toDate()),
                          style: regularTextStyle(
                              fontSize: 12.0, color: MyColors.color08151F),
                        );
                      } else {
                        return Text(
                          '',
                          style: regularTextStyle(
                              fontSize: 12.0, color: MyColors.color08151F),
                        );
                      }
                    },
                  ),
                  hsized5,
                  // Show unread message count using optimized stream
                  StreamBuilder<int>(
                    stream: widget.chatServices.getUnreadCountForChat(
                        widget.chatServices.getChatRoomIdByUserId(widget.userId, partnerId),
                        widget.userId,
                        partnerId),
                    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasData && snapshot.data! > 0) {
                        try {
                          widget.chatServices.markMessagesAsSeen(
                              widget.chatServices.getChatRoomIdByUserId(widget.userId, partnerId),
                              widget.userId,
                              partnerId, "1", "0");
                        } catch (e) {
                          print('Error marking messages as seen: $e');
                        }
                        return CircleAvatar(
                          radius: 10,
                          backgroundColor: MyColors.appTheme,
                          child: Text(
                            snapshot.data! > 99 ? '99+' : snapshot.data!.toString(),
                            style: boldTextStyle(
                                fontSize: 12.0, color: MyColors.whiteColor),
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color getColorFromName(String name) {
    if (name.isEmpty) return Colors.grey;

    String firstLetter = name[0].toUpperCase();

    switch (firstLetter) {
      case 'A':
      case 'B':
      case 'C':
        return Colors.redAccent;
      case 'D':
      case 'E':
      case 'F':
        return Colors.blueAccent;
      case 'G':
      case 'H':
      case 'I':
        return Colors.green;
      case 'J':
      case 'K':
      case 'L':
        return Colors.orange;
      case 'M':
      case 'N':
      case 'O':
        return Colors.teal;
      case 'P':
      case 'Q':
      case 'R':
        return Colors.purple;
      case 'S':
      case 'T':
      case 'U':
        return Colors.pink;
      case 'V':
      case 'W':
      case 'X':
        return Colors.cyan;
      case 'Y':
      case 'Z':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }


  String _formatLastSeenTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }
}
