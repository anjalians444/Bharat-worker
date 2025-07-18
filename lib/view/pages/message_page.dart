import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/models/chat_messages.dart';
import 'package:bharat_worker/services/chat_services.dart';
import 'package:bharat_worker/widgets/common_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/chat_provider.dart';

import '../../constants/assets_paths.dart';
import '../../constants/font_style.dart';
import '../../helper/router.dart';

List<QueryDocumentSnapshot> listMessages = [];
List<String> countList = [];

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _searchController = TextEditingController();
  late ChatServices chatServices;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get ChatServices from provider

    final String userId = "10"; // TODO: Replace with actual logged-in user id
    return Scaffold(
      backgroundColor: MyColors.whiteColor,
      appBar: commonAppBar(() {
        // Navigator.pop(context);
      }, 'Messages', actions: [
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
              // Show unread count at the top (example)
              // StreamBuilder<int>(
              //   stream: chatServices.getUnreadCountStream(userId),
              //   builder: (context, snapshot) {
              //     final unreadCount = snapshot.data ?? 0;
              //     return Row(
              //       children: [
              //         Text('Unread Chats:', style: mediumTextStyle(fontSize: 16.0, color: MyColors.darkText)),
              //         wsized10,
              //         CircleAvatar(
              //           radius: 12,
              //           backgroundColor: MyColors.appTheme,
              //           child: Text(
              //             unreadCount.toString(),
              //             style: boldTextStyle(fontSize: 14.0, color: MyColors.whiteColor),
              //           ),
              //         ),
              //       ],
              //     );
              //   },
              // ),
              // hsized25,
              Expanded(
                child: ListView.separated(
                  itemCount: chatMessages.length,
                  separatorBuilder: (context, index) => hsized30,
                  itemBuilder: (context, index) {
                    final message = chatMessages[index];
                    chatServices.seeMsg(chatServices.getChatRoomIdByUserId(userId,message.id),message.id,"1");
                    return InkWell(
                      onTap: () {
                        context.push(
                          AppRouter.chat,
                          extra: {
                            'customerName': chatMessages[index].name,
                            'customerAddress': 'Flat 305, Sector 11, Panchkula',
                            'customerAvatarUrl': chatMessages[index].imageUrl,
                            'jobType': "",
                            'jobDateTime': "",
                            'receiverId': message.id, // Pass receiverId here
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
                                  backgroundImage:
                                      NetworkImage(message.imageUrl),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(message.name,
                                          style: semiBoldTextStyle(
                                              fontSize: 16.0,
                                              color: MyColors.darkText)),
                                      hsized5,
                                      StreamBuilder<QuerySnapshot>(
                                        stream: chatServices.getChatMessage(
                                          chatServices.getChatRoomIdByUserId(userId, message.id.toString()),
                                          1, // Only need the latest message
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                            final lastMsg = ChatMessages.fromDocument(snapshot.data!.docs.first);
                                            if (lastMsg.type == 'image') {
                                              return Row(
                                                children: [
                                                  Icon(Icons.image, size: 16, color: MyColors.color838383),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Photo',
                                                    style: regularTextStyle(fontSize: 14.0, color: MyColors.blackColor),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return Text(
                                                lastMsg.content,
                                                style: regularTextStyle(fontSize: 14.0, color: MyColors.blackColor),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              );
                                            }
                                          } else {
                                            return Text(
                                              '',
                                              style: regularTextStyle(fontSize: 14.0, color: MyColors.blackColor),
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
                              Text(message.time,
                                  style: regularTextStyle(
                                      fontSize: 12.0,
                                      color: MyColors.color08151F)),
                              hsized5,
                              // You can also show per-chat unread count here if you have it per chat
                              StreamBuilder<QuerySnapshot>(
                                stream: chatServices.getChatMessage(
                                    chatServices.getChatRoomIdByUserId(
                                        userId, message.id.toString()),
                                    40),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot<Object?>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    listMessages = snapshot.data!.docs;

                                    if (listMessages.isNotEmpty) {
                                      list.clear();

                                      for (int i = 0;
                                          i < listMessages.length;
                                          i++) {
                                        ChatMessages chatMessages =
                                            ChatMessages.fromDocument(
                                                listMessages[i]);
                                        list.add(chatMessages);
                                      }

                                      for (var chat in list) {
                                        for (var user in chatMessages) {
                                          // new code
                                          if (chat.senderId.toString() ==
                                              user.id.toString()) {
                                            var collectionPath = listMessages
                                                .first.reference.parent.path
                                                .toString()
                                                .split("/")[1]
                                                .split("-")[1];

                                            int totalCount = 0;
                                            if (chat.seen == "0" &&
                                                chat.senderId.toString() ==
                                                    user.id.toString()) {
                                              if (countList.contains(
                                                      user.id.toString()) ==
                                                  false) {
                                                countList.add(
                                                    collectionPath.toString());
                                                totalCount = countList.length;
                                                chatServices.incrementCount(
                                                    userId.toString(),
                                                    totalCount);
                                              }
                                            }
                                            user.unreadCount = chatServices
                                                .countLastMessagesEqualZero(
                                                    list,
                                                    message.id.toString(),
                                                    userId)
                                                .toString();
                                          }
                                        }
                                      }
                                    } else {
                                      return Center(child: Text(''));
                                    }
                                    if (list.isNotEmpty) {
                                      return message.unreadCount == "0"
                                          ? SizedBox.shrink()
                                          : CircleAvatar(
                                              radius: 10,
                                              backgroundColor:
                                                  MyColors.appTheme,
                                              child: Text(
                                                message.unreadCount.toString(),
                                                style: boldTextStyle(
                                                    fontSize: 12.0,
                                                    color: MyColors.whiteColor),
                                              ),
                                            );
                                    } else {
                                      return Center(
                                        child: Text(
                                          "",
                                          style: const TextStyle(),
                                        ),
                                      );
                                    }
                                  } else {
                                    return Container();
                                  }
                                },
                              )
                              // if (message.unreadCount > 0)
                              //   CircleAvatar(
                              //     radius: 10,
                              //     backgroundColor: MyColors.appTheme,
                              //     child: Text(
                              //       message.unreadCount.toString(),
                              //       style: boldTextStyle(fontSize: 12.0, color: MyColors.whiteColor),
                              //     ),
                              //   )
                              // else
                              //   const SizedBox(
                              //     width: 10,
                              //   ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void setUser() {
    chatServices =
        Provider.of<ChatProvider>(context, listen: false).chatServices;
    //  chatServices = context.read<ChatServices>();
    // if(userId != "null") {
    chatServices.getSelfInfo("10", "", "", 0);
    chatServices.getSelfInfo("1", "", "", 0);
    // }
  }
}

class ChatMessageModel {
  final String id;
  final String name;
  final String lastMessage;
  final String imageUrl;
  final String time;
  String unreadCount = "0";

  ChatMessageModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.imageUrl,
    required this.time,
    required this.unreadCount,
  });
}

List<ChatMessageModel> chatMessages = [
  ChatMessageModel(
    id: '1',
    name: 'Ramesh Verma',
    lastMessage: 'I\'m available after 3 PM today',
    imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
    time: 'Now',
    unreadCount: "0",
  ),
  ChatMessageModel(
    id: '2',
    name: 'Neha Gupta',
    lastMessage: 'Thank you! The leakage has stopped',
    imageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
    time: '10 mins',
    unreadCount: "0",
  ),
  ChatMessageModel(
    id: '3',
    name: 'Rajeev Arora',
    lastMessage: 'Can we postpone to tomorrow?',
    imageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
    time: '30 mins',
    unreadCount: "0",
  ),
  ChatMessageModel(
    id: '4',
    name: 'Priya Verma',
    lastMessage: 'How much will the total cost be?',
    imageUrl: 'https://randomuser.me/api/portraits/women/4.jpg',
    time: '6:12 PM',
    unreadCount: "0",
  ),
  ChatMessageModel(
    id: '5',
    name: 'Mohit Bansal',
    lastMessage: 'I have an old brass tap. Will it work?',
    imageUrl: 'https://randomuser.me/api/portraits/men/5.jpg',
    time: 'Yesterday',
    unreadCount: "0",
  ),
  ChatMessageModel(
    id: '6',
    name: 'Deepak Mehta',
    lastMessage: 'Call me once you reach the gate.',
    imageUrl: 'https://randomuser.me/api/portraits/men/6.jpg',
    time: 'Yesterday',
    unreadCount: "0",
  ),
  ChatMessageModel(
    id: '7',
    name: 'Vikram Singh',
    lastMessage: 'I\'m out right now. Can you wait 10 min?',
    imageUrl: 'https://randomuser.me/api/portraits/men/7.jpg',
    time: '2 days',
    unreadCount: "0",
  ),
];
