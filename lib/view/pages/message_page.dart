import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../constants/assets_paths.dart';
import '../../constants/font_style.dart';
import '../../helper/router.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.whiteColor,
      appBar: commonAppBar((){
       // Navigator.pop(context);
      },'Messages',
      actions: [
        InkWell(
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: MyColors.borderColor),
                  borderRadius: BorderRadius.circular(12)
              ),
              padding: EdgeInsets.all(10),
              child:  SvgPicture.asset(MyAssetsPaths.notificationIcon)),
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
                    child: CommonTextField(
                      controller: _searchController,
                      borderRadius: 40,
                      borderColor: Color(0xFFEEEEEE),
                      hintText: 'Search',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: SvgPicture.asset(
                          MyAssetsPaths.searchIcon,color: MyColors.lightText,
                        ),
                      ),
                    ),
                  ),
                  wsized10,
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: MyColors.borderColor),
                          shape: BoxShape.circle
                      ),
                      padding: EdgeInsets.all(13),
                      child: SvgPicture.asset(MyAssetsPaths.filterIcon,height: 24,width: 24,))
                ],
              ),
              hsized25,
              Expanded(
                child: ListView.separated(
                  itemCount: chatMessages.length,
                  separatorBuilder: (context, index) => hsized30,
                  itemBuilder: (context, index) {
                    final message = chatMessages[index];
                    return InkWell(
                      onTap: (){
                        context.push(
                          AppRouter.chat,
                          extra: {
                            'customerName': 'Ravi Malhotra',
                            'customerAddress': 'Flat 305, Sector 11, Panchkula',
                            'customerAvatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
                            'jobType':"",
                            'jobDateTime': "",
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
                                  backgroundImage: NetworkImage(message.imageUrl),
                                ),
                                SizedBox(width: 15,),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(message.name, style: semiBoldTextStyle(fontSize: 16.0, color: MyColors.darkText)),
                                     hsized5,
                                      Text(message.lastMessage, style: regularTextStyle(fontSize: 14.0, color: MyColors.blackColor)),

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
                              Text(message.time, style: regularTextStyle(fontSize: 12.0, color: MyColors.color08151F)),
                              hsized5,
                              if (message.unreadCount > 0)
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: MyColors.appTheme,
                                  child: Text(
                                    message.unreadCount.toString(),
                                    style: boldTextStyle(fontSize: 12.0, color: MyColors.whiteColor),
                                  ),
                                )
                              else
                                const SizedBox(
                                  width: 10,
                                ),
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
}

class ChatMessage {
  final String name;
  final String lastMessage;
  final String imageUrl;
  final String time;
  final int unreadCount;

  ChatMessage({
    required this.name,
    required this.lastMessage,
    required this.imageUrl,
    required this.time,
    required this.unreadCount,
  });
}

List<ChatMessage> chatMessages = [
  ChatMessage(
    name: 'Ramesh Verma',
    lastMessage: 'I\'m available after 3 PM today',
    imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
    time: 'Now',
    unreadCount: 1,
  ),
  ChatMessage(
    name: 'Neha Gupta',
    lastMessage: 'Thank you! The leakage has stopped',
    imageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
    time: '10 mins',
    unreadCount: 0,
  ),
  ChatMessage(
    name: 'Rajeev Arora',
    lastMessage: 'Can we postpone to tomorrow?',
    imageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
    time: '30 mins',
    unreadCount: 4,
  ),
  ChatMessage(
    name: 'Priya Verma',
    lastMessage: 'How much will the total cost be?',
    imageUrl: 'https://randomuser.me/api/portraits/women/4.jpg',
    time: '6:12 PM',
    unreadCount: 2,
  ),
  ChatMessage(
    name: 'Mohit Bansal',
    lastMessage: 'I have an old brass tap. Will it work?',
    imageUrl: 'https://randomuser.me/api/portraits/men/5.jpg',
    time: 'Yesterday',
    unreadCount: 0,
  ),
  ChatMessage(
    name: 'Deepak Mehta',
    lastMessage: 'Call me once you reach the gate.',
    imageUrl: 'https://randomuser.me/api/portraits/men/6.jpg',
    time: 'Yesterday',
    unreadCount: 0,
  ),
  ChatMessage(
    name: 'Vikram Singh',
    lastMessage: 'I\'m out right now. Can you wait 10 min?',
    imageUrl: 'https://randomuser.me/api/portraits/men/7.jpg',
    time: '2 days',
    unreadCount: 2,
  ),
]; 