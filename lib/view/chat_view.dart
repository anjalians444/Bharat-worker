import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/message_provider.dart';
import '../models/message_model.dart';
import '../constants/my_colors.dart';
import '../constants/font_style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/assets_paths.dart';

class ChatView extends StatelessWidget {
  final String customerName;
  final String customerAddress;
  final String customerAvatarUrl;
  final String jobType;
  final String jobDateTime;

  const ChatView({
    Key? key,
    required this.customerName,
    required this.customerAddress,
    required this.customerAvatarUrl,
    required this.jobType,
    required this.jobDateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = MessageProvider();
        provider.receiveMessage("Hi Ravi, I've accepted your request for the bathroom tap repair. I'll reach by 11:45 AM.");
        provider.sendMessage("Great, thank you! Please call me when you're near the gate.");
        provider.receiveMessage("Sure! Is parking available nearby?");
        provider.sendMessage("Yes, you can park right outside the main gate. Security will guide you.");
        provider.receiveMessage("Perfect. I've got all required tools. I'll see you soon.");
        provider.sendMessage("Thanks! Please be careful, there's water near the sink area.");
        return provider;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar:PreferredSize(preferredSize: Size.zero, child: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,elevation: 0,)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: MyColors.borderColor),
                                      borderRadius: BorderRadius.circular(12)
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: const Icon(Icons.arrow_back,size: 24,)),
                            ),

                            SizedBox(width: 10,),
                            CircleAvatar(
                              backgroundImage: customerAvatarUrl.isNotEmpty
                                  ? NetworkImage(customerAvatarUrl)
                                  : null,
                              child: customerAvatarUrl.isEmpty ? Icon(Icons.person) : null,
                              radius: 22,
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(customerName, style: boldTextStyle(fontSize: 18.0, color: MyColors.blackColor)),
                                  Text(customerAddress, style: regularTextStyle(fontSize: 12.0, color: MyColors.color838383)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: MyColors.borderColor),
                              borderRadius: BorderRadius.circular(12)
                          ),
                          padding: EdgeInsets.all(10),
                          child: const Icon(Icons.more_vert_sharp,size: 24,)),
                    ],
                  ),
                  hsized12,

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.appTheme,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: Icon(Icons.call, color: Colors.white,size: 24,),
                          label: Text('Call Customer', style: mediumTextStyle(fontSize: 14.0, color: Colors.white)),
                          onPressed: () {},
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            side: BorderSide(color: MyColors.appTheme),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: SvgPicture.asset(MyAssetsPaths.navigation, height: 24, width: 24, color: MyColors.appTheme),
                          label: Text('Navigate', style: mediumTextStyle(fontSize: 14.0, color: MyColors.appTheme)),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            hsized12,
            Divider(color: MyColors.borderColor,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jobType, style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                  Text(' · 14 June, 12:00 PM – 1:00 PM', style: mediumTextStyle(fontSize: 14.0, color: MyColors.color7A849C)),
                ],
              ),
            ),
            Divider(height: 1, color:MyColors.borderColor),
            hsized25,
            Expanded(
              child: Consumer<MessageProvider>(
                builder: (context, provider, _) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal:24),
                    itemCount: provider.messages.length,
                    reverse: false,
                    itemBuilder: (context, index) {
                      final msg = provider.messages[index];
                      return Align(
                        alignment: msg.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: msg.isSentByMe ? MyColors.appTheme : Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(msg.isSentByMe ? 16 : 0),
                              bottomRight: Radius.circular(msg.isSentByMe ? 0 : 16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: regularTextStyle(fontSize: 16.0, color: msg.isSentByMe ? Colors.white : MyColors.blackColor),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _formatTime(msg.timestamp),
                                style: regularTextStyle(fontSize: 11.0, color: msg.isSentByMe ? Colors.white70 : MyColors.color838383),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            _MessageInputBar(),
          ],
        ),
      ),
    );
  }



  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $ampm';
  }
}

class _MessageInputBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MessageProvider>(context);
    return SafeArea(
      child: Container(
        margin: EdgeInsets.fromLTRB(24, 15, 24, 20),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical:6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: MyColors.borderColor),
          borderRadius: BorderRadius.circular(60),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: provider.messageController,
                style: regularTextStyle(fontSize:16.0, color:MyColors.blackColor),
                decoration: InputDecoration(
                  hintText: 'Type message...',
                  hintStyle: regularTextStyle(fontSize:16.0, color:MyColors.color838383),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) => provider.sendMessage(val),
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () => provider.sendMessage(provider.messageController.text),
              child: Container(
                decoration: BoxDecoration(
                  color: MyColors.appTheme,
                  shape: BoxShape.circle
                ),
                padding: EdgeInsets.all(12),
                child: Icon(Icons.send, color: Colors.white,size: 20,),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 