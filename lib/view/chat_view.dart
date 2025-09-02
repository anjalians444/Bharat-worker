import 'dart:io';

import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/ui_utils.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../provider/chat_provider.dart';
import '../constants/my_colors.dart';
import '../constants/font_style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/assets_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/chat_services.dart';
import '../models/chat_messages.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:async';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:collection/collection.dart';
import '../helper/common.dart';
import '../helper/router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

class ChatView extends StatefulWidget {
  final String customerName;
  final String customerAddress;
  final String customerAvatarUrl;
  final String jobType;
  final String jobDateTime;
  final String receiverId;
  final String? customerPhone;

  static  String currentUserId = "10";

  ChatView({
    Key? key,
    required this.customerName,
    required this.customerAddress,
    required this.customerAvatarUrl,
    required this.jobType,
    required this.jobDateTime,
    required this.receiverId,
    this.customerPhone,
  }) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController _scrollController = ScrollController();
  // Move uploadingMessages to parent
  List<_UploadingImageMessage> uploadingMessages = [];

  // Reply state
  ChatMessages? replyToMessage;
  void setReplyToMessage(ChatMessages? msg) {
    setState(() {
      replyToMessage = msg;
    });
  }

  void addUploadingMessage(_UploadingImageMessage msg) {
    setState(() {
      uploadingMessages.add(msg);
    });
  }

  void removeUploadingMessage(String id) {
    setState(() {
      uploadingMessages.removeWhere((msg) => msg.id == id);
    });
  }

  Map<String, GlobalKey> messageKeys = {}; // <-- Add this line
  late ChatServices chatServices;
  @override
  void dispose() {
    CurrentChat.groupChatId = null;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final chatServices = ChatServices(
      firebaseFirestore: FirebaseFirestore.instance,
      firebaseStorage: FirebaseStorage.instance,
    );
    setUser();
    final groupChatId = chatServices.getChatRoomIdByUserId(ChatView.currentUserId, widget.receiverId);
    CurrentChat.groupChatId = groupChatId;

  }

  void setUser() {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    // Use the MongoDB ObjectId directly for chat compatibility
    ChatView.currentUserId = profileProvider.partner?.id ?? "10";
    chatServices =
        Provider.of<ChatProvider>(context, listen: false).chatServices;
    chatServices.getSelfInfo(ChatView.currentUserId, "", "", 0);
  }


  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final chatServices = ChatServices(
      firebaseFirestore: FirebaseFirestore.instance,
      firebaseStorage: FirebaseStorage.instance,
    );
    final groupChatId = chatServices.getChatRoomIdByUserId(ChatView.currentUserId, widget.receiverId);
    // Ensure welcome message is present if chat is empty
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.ensureWelcomeMessage(
      groupChatId: groupChatId,
      receiverId: widget.receiverId,
      systemUserId: 'system',
      welcomeText: 'Welcome to the chat! How can we help you today?',
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:PreferredSize(preferredSize: Size.zero, child: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,elevation: 0,)),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:18.0, vertical:5),
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
                                  padding: EdgeInsets.all(6),
                                  child: const Icon(Icons.arrow_back,size: 24,)),
                            ),

                            SizedBox(width: 10,),
                            CircleAvatar(
                              backgroundImage: widget.customerAvatarUrl.isNotEmpty
                                  ? NetworkImage(widget.customerAvatarUrl)
                                  : null,
                              child: widget.customerAvatarUrl.isEmpty ? Icon(Icons.person) : null,
                              radius: 22,
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.customerName, style: boldTextStyle(fontSize: 18.0, color: MyColors.blackColor)),
                                  Text(widget.customerAddress, style: regularTextStyle(fontSize: 12.0, color: MyColors.color838383)),
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
                          padding: EdgeInsets.all(6),
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
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          icon: Icon(Icons.call, color: Colors.white,size: 20,),
                          label: Text('Call Customer', style: mediumTextStyle(fontSize: 14.0, color: Colors.white)),
                          onPressed: () {
                            print("widget.customerPhone.....${widget.customerPhone}");
                            _makePhoneCall();
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            side: BorderSide(color: MyColors.appTheme),
                            padding: EdgeInsets.symmetric(vertical:8),
                          ),
                          icon: SvgPicture.asset(MyAssetsPaths.navigation, height: 20, width: 20, color: MyColors.appTheme),
                          label: Text('Navigate', style: mediumTextStyle(fontSize: 14.0, color: MyColors.appTheme)),
                          onPressed: () {
                            _showLocationDialog(profileProvider.partner!.latitude!.toDouble(),  profileProvider.partner!.longitude!.toDouble(),  profileProvider.partner!.address!.toString());
                           // _openInMaps(profileProvider.partner!.latitude!.toDouble(), profileProvider.partner!.longitude!.toDouble());
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            //   hsized5,
            Divider(color: MyColors.borderColor,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical:5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.jobType, style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                  Text(' · 14 June, 12:00 PM – 1:00 PM', style: mediumTextStyle(fontSize: 14.0, color: MyColors.color7A849C)),
                ],
              ),
            ),
            hsized5,
            Divider(height: 1, color:MyColors.borderColor),
            hsized16,
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: chatServices.getChatMessage(groupChatId, 100),
                      builder: (context, snapshot) {
                        List<ChatMessages> messages = [];
                        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                          messages = snapshot.data!.docs.map((doc) => ChatMessages.fromDocument(doc)).toList();
                        }
                        // Use parent's uploadingMessages
                        final allMessages = List<Widget>.from(
                          uploadingMessages.map((uploadingMsg) => Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  padding: EdgeInsets.all(2),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.45,
                                    maxHeight: 200,
                                  ),
                                  decoration: BoxDecoration(
                                    color: MyColors.appTheme.withOpacity(0.7),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(0),
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          uploadingMsg.file,
                                          fit: BoxFit.cover,
                                          height: 180,
                                          width: 180,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.black.withOpacity(0.3),
                                          child: Center(
                                            child: SizedBox(
                                              width: 36,
                                              height: 36,
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                strokeWidth: 3,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                        );
                        allMessages.addAll(List.generate(messages.length, (index) {
                          final msg = messages[index];
                          final isSentByMe = msg.senderId == ChatView.currentUserId;
                          final msgId = msg.timestamp.millisecondsSinceEpoch.toString();
                          if (!messageKeys.containsKey(msgId)) {
                            messageKeys[msgId] = GlobalKey();
                          }
                          // Find the replied message if any
                          ChatMessages? repliedMsg;
                          if (msg.replyTo != null) {
                            repliedMsg = messages.firstWhereOrNull((m) => m.timestamp.millisecondsSinceEpoch.toString() == msg.replyTo);
                          }
                          // Mark messages as seen when viewing them
                          if (!isSentByMe) {
                            chatServices.markMessagesAsSeen(
                                chatServices.getChatRoomIdByUserId(ChatView.currentUserId, msg.senderId),
                                ChatView.currentUserId,
                                msg.senderId,"2","1");
                          }
                          chatServices.decrementCount(ChatView.currentUserId);
                          return Slidable(
                            key: ValueKey(msg.timestamp.toString() + msg.senderId),
                            endActionPane:isSentByMe ? ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  onPressed: (_) => setReplyToMessage(msg),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.white,
                                  icon: Icons.reply,
                                  label: '',
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ):null,
                            startActionPane: isSentByMe?null:
                            ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.2,
                              children: [
                                SlidableAction(
                                  onPressed: (_) => setReplyToMessage(msg),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.white,
                                  icon: Icons.reply,
                                  label: '',
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            )  ,
                            child: Align(
                              key: messageKeys[msgId], // <-- Assign key here
                              alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: isSentByMe ?CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  if (msg.replyTo != null && repliedMsg != null)
                                    GestureDetector(
                                      onTap: () {
                                        // Scroll to the replied message
                                        final targetIndex = messages.indexWhere((m) => m.timestamp.millisecondsSinceEpoch.toString() == msg.replyTo);
                                        if (targetIndex != -1) {
                                          final position = (messages.length - 1 - targetIndex) * 80.0; // Approximate height
                                          _scrollController.animateTo(
                                            position,
                                            duration: Duration(milliseconds: 400),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                                        margin: EdgeInsets.only(bottom: 0),
                                        //  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border(left: BorderSide(color: MyColors.appTheme, width: 4)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              repliedMsg.type == MessageType.image ? Icons.image : Icons.reply,
                                              size: 16,
                                              color: MyColors.color838383,
                                            ),
                                            SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                repliedMsg.type == MessageType.image ? 'Photo' :
                                                repliedMsg.type == MessageType.location ? 'Location' : repliedMsg.content,
                                                style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383),
                                                //  maxLines: 1,
                                                // overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (msg.type == MessageType.image)
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Dialog(
                                            backgroundColor: Colors.black,
                                            insetPadding: EdgeInsets.zero,
                                            child: GestureDetector(
                                              onTap: () => Navigator.of(context).pop(),
                                              child: Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: PhotoView(
                                                  imageProvider: NetworkImage(msg.content),
                                                  backgroundDecoration: BoxDecoration(color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(vertical: 4),
                                        padding: EdgeInsets.all(2),
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.45,
                                          maxHeight: 200,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF5F5F5),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                            bottomLeft: Radius.circular(isSentByMe ? 16 : 0),
                                            bottomRight: Radius.circular(isSentByMe ? 0 : 16),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            msg.content,
                                            fit: BoxFit.cover,
                                            height: 180,
                                            width: 180,
                                            errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 60),
                                          ),
                                        ),
                                      ),
                                    )
                                  else if (msg.type == MessageType.location)
                                    _buildLocationMessage(msg, isSentByMe)
                                  else
                                    Container(
                                      margin: EdgeInsets.only(bottom: 4),
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                                      decoration: BoxDecoration(
                                        color: isSentByMe ? MyColors.appTheme : Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                          bottomLeft: Radius.circular(isSentByMe ? 16 : 0),
                                          bottomRight: Radius.circular(isSentByMe ? 0 : 16),
                                        ),
                                      ),
                                      child: Text(
                                        msg.content,
                                        style: regularTextStyle(fontSize: 16.0, color: isSentByMe ? Colors.white : MyColors.blackColor),
                                      ),
                                    ),
                                  Row(
                                    mainAxisAlignment:isSentByMe ?  MainAxisAlignment.end:MainAxisAlignment.start,
                                    children: [
                                      isSentByMe ?
                                      Icon(
                                        msg.status == '2'
                                            ? Icons.done_all // double tick blue
                                            : msg.status == '1'
                                            ? Icons.done_all // double tick grey
                                            : Icons.check,   // single tick grey
                                        color: msg.status == '2'
                                            ? Colors.blue
                                            : MyColors.color838383,
                                        size: 11,
                                      ):SizedBox.shrink(),
                                      Text(
                                        _formatTime(msg.timestamp.toDate()),
                                        style: regularTextStyle(fontSize: 11.0, color:  MyColors.color838383),
                                      ),
                                    ],
                                  ),
                                  hsized15,
                                ],
                              ),
                            ),
                          );
                        }));
                        // Mark messages as delivered if not sent by me and status is 0
                        for (final msg in messages) {
                          final isSentByMe = msg.senderId == ChatView.currentUserId;
                          if (!isSentByMe && msg.status == '0') {
                            chatServices.markMessageDelivered(groupChatId, msg.timestamp.millisecondsSinceEpoch.toString());
                          }
                        }
                        // Scroll to bottom when new messages arrive or uploading
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              0.0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                        if (messages.isEmpty && uploadingMessages.isEmpty) {
                          return Center(child: Text('No messages yet'));
                        }
                        return ListView(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal:18),
                          reverse: true,
                          children: allMessages,
                        );
                      },
                    ),
                  ),
                  StreamBuilder<bool>(
                    stream: chatServices.typingStatusStream(groupChatId, widget.receiverId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data == true) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 4),
                          child: Row(
                            children: [
                              CircleAvatar(radius: 12, backgroundColor: MyColors.appTheme, child: Icon(Icons.more_horiz, color: Colors.white, size: 16)),
                              SizedBox(width: 8),
                              Text('Typing...', style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383)),
                            ],
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            _MessageInputBar(
              chatServices: chatServices,
              groupChatId: groupChatId,
              receiverId: widget.receiverId,
              currentUserId: ChatView.currentUserId,
              // Pass uploading message management to input bar
              onAddUploadingMessage: addUploadingMessage,
              onRemoveUploadingMessage: removeUploadingMessage,
              // Pass reply state
              replyToMessage: replyToMessage,
              onCancelReply: () => setReplyToMessage(null),
            ),
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

  Widget _buildLocationMessage(ChatMessages msg, bool isSentByMe) {
    try {
      Map<String, dynamic> locationData = jsonDecode(msg.content);
      double latitude = locationData['latitude'] ?? 0.0;
      double longitude = locationData['longitude'] ?? 0.0;
      String address = locationData['address'] ?? 'Location';

      return GestureDetector(
        onTap: () {
          _showLocationDialog(latitude, longitude, address);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.all(2),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.45,
            maxHeight: 200,
          ),
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(isSentByMe ? 16 : 0),
              bottomRight: Radius.circular(isSentByMe ? 0 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude, longitude),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('location'),
                        position: LatLng(latitude, longitude),
                      ),
                    },
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      // Controller can be stored if needed
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: MyColors.appTheme),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: regularTextStyle(fontSize: 12.0, color: MyColors.blackColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
        decoration: BoxDecoration(
          color: isSentByMe ? MyColors.appTheme : Color(0xFFF5F5F5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(isSentByMe ? 16 : 0),
            bottomRight: Radius.circular(isSentByMe ? 0 : 16),
          ),
        ),
        child: Text(
          'Location',
          style: regularTextStyle(fontSize: 16.0, color: isSentByMe ? Colors.white : MyColors.blackColor),
        ),
      );
    }
  }

    









  void _showLocationDialog(double latitude, double longitude, String address) {
    // Navigate to the location dialog route
    context.push(AppRouter.locationDialog, extra: {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'customerName': widget.customerName,
      'customerPhone': widget.customerPhone ?? '',
    });
  }

  void _openInMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open maps')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening maps: ${e.toString()}')),
      );
    }
  }

  void _makePhoneCall() async {
    print("widget.customerPhone...${widget.customerPhone.toString()}");
    // if (widget.customerPhone == null || widget.customerPhone!.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Phone number not available')),
    //   );
    //   return;
    // }
    if(widget.customerPhone != null){

      final phoneNumber = widget.customerPhone!.startsWith('+')
          ? widget.customerPhone!
          : '+91${widget.customerPhone!}'; // Default to India +91 if no country code


      final uri = Uri.parse('tel:$phoneNumber');

      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not make phone call')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error making phone call: ${e.toString()}')),
        );
      }
    }

  }
}

class _MessageInputBar extends StatefulWidget {
  final ChatServices chatServices;
  final String groupChatId;
  final String receiverId;
  final String currentUserId;
  final void Function(_UploadingImageMessage) onAddUploadingMessage;
  final void Function(String) onRemoveUploadingMessage;
  final ChatMessages? replyToMessage;
  final void Function() onCancelReply;
  const _MessageInputBar({
    required this.chatServices,
    required this.groupChatId,
    required this.receiverId,
    required this.currentUserId,
    required this.onAddUploadingMessage,
    required this.onRemoveUploadingMessage,
    this.replyToMessage,
    required this.onCancelReply,
  });
  @override
  State<_MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<_MessageInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final picker = ImagePicker();
  File? photoController;
  CroppedFile? _croppedFile;
  String fileName = '';
  File? xFile;
  String extension = "";
  String dateSeparatorText = "";
  bool isFirstMessageOfDay = false;
  bool upload = false;
  Timer? _typingTimer;

  // Unified message sending method now uses ChatProvider
  void onSendMessage(
      String content,
      String type,
      String filename,
      String seen,
      ) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(
      content: content,
      type: type,
      groupChatId: widget.groupChatId,
      currentUserId: widget.currentUserId,
      receiverId: widget.receiverId,
      filename: filename,
      seen: seen,
      controller: _controller,
      focusNode: focusNode,
      replyTo: widget.replyToMessage?.timestamp.millisecondsSinceEpoch.toString(), // Use timestamp as id
      // chatServices: chatServices
      // Optionally pass bookingId if needed
    );
    widget.onCancelReply();
  }

  void _setTyping(bool isTyping) {
    widget.chatServices.setTypingStatus(widget.groupChatId, widget.currentUserId, isTyping);
  }

  void _onTextChanged(String value) {
    _setTyping(true);
    _typingTimer?.cancel();
    _typingTimer = Timer(Duration(seconds: 2), () {
      _setTyping(false);
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _setTyping(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.replyToMessage != null)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                border: Border(
                  left: BorderSide(color: MyColors.appTheme, width: 4),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.replyToMessage!.senderId == widget.currentUserId ? 'You' : 'Reply to User',
                          style: boldTextStyle(fontSize: 15.0, color: MyColors.blackColor),
                        ),
                        SizedBox(height: 2),
                        if (widget.replyToMessage!.type == MessageType.image)
                          Row(
                            children: [
                              Icon(Icons.image, size: 16, color: MyColors.color838383),
                              SizedBox(width: 4),
                              Text('Photo', style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          )
                        else
                          Text(
                            widget.replyToMessage!.content,
                            style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onCancelReply,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                      child: Icon(Icons.close, size: 20, color: MyColors.color838383),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              SizedBox(width:10,),
              GestureDetector(
                onTap: (){
                  showBottomsheetUploadImage(context,picCameraOnTap,galleryOnTap,languageProvider);
                },
                child: Icon(Icons.add, color: Colors.black.withOpacity(0.7),size:35,),
              ),
              //SizedBox(width: 8),
              /*  GestureDetector(
                onTap: () {
                  _shareLocation();
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: MyColors.appTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.location_on, color: MyColors.appTheme, size: 28),
                ),
              ),*/
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 15, 24, 20),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical:0),
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
                          controller: _controller,
                          focusNode: focusNode,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          style: regularTextStyle(fontSize:16.0, color:MyColors.blackColor),
                          decoration: InputDecoration(
                            hintText: 'Type message...',
                            hintStyle: regularTextStyle(fontSize:16.0, color:MyColors.color838383),
                            border: InputBorder.none,
                          ),
                          onChanged: _onTextChanged,
                          onSubmitted: (val) {
                            onSendMessage(val, MessageType.text, '', '0');
                            _setTyping(false);
                          },
                          onEditingComplete: () => _setTyping(false),
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          onSendMessage(_controller.text, MessageType.text, '', '0');
                          _setTyping(false);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: MyColors.appTheme,
                              shape: BoxShape.circle
                          ),
                          padding: EdgeInsets.all(5),
                          child: Icon(Icons.send_outlined, color: Colors.white,size: 18,),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showBottomsheetUploadImage(BuildContext context, GestureTapCallback cameraOnTap,GestureTapCallback galleryOnTap,LanguageProvider languageProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor:Colors.transparent,
      builder: (BuildContext context) {
        return SizedBox(
          height: 390,
          child: UiUtils.uploadImageBottomUi(context,cameraOnTap,galleryOnTap,languageProvider,(){
            _shareLocation();
          }),
        );
      },
    );
  }

  Future<void> picCameraOnTap() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _cropImage(pickedFile.path);
      }
    });
  }
  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.pickImage(
        source: imageSource, imageQuality: 90);
    if (pickedFile != null) {
      File photo = File(pickedFile.path);
      setState(() {
        upload = true;
      });
      // Add uploading message to parent
      final tempMsg = _UploadingImageMessage(
        file: photo,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      widget.onAddUploadingMessage(tempMsg);
      _cropImage(photo.path, uploadingMsgId: tempMsg.id);
      Navigator.pop(context);
    }
  }

  void cameraOnTap() {
    getImage(ImageSource.camera);
  }

  void galleryOnTap() {
    getImage(ImageSource.gallery);
  }

  // Location sharing functionality
  Future<void> _shareLocation() async {
    Navigator.pop(context);
    // Show confirmation dialog first
    bool? shouldShare = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Share Location'),
          content: Text('Do you want to share your current location?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.appTheme,
              ),
              child: Text('Share', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (shouldShare != true) return;

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: MyColors.appTheme),
                  SizedBox(height: 16),
                  Text(
                    'Getting your location...',
                    style: regularTextStyle(fontSize: 16.0, color: MyColors.blackColor),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.isNotEmpty ? placemarks[0] : Placemark();
      String address = [
        if (place.name != null && place.name!.isNotEmpty) place.name,
        if (place.street != null && place.street!.isNotEmpty) place.street,
        if (place.locality != null && place.locality!.isNotEmpty) place.locality,
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty)
          place.administrativeArea,
        if (place.country != null && place.country!.isNotEmpty) place.country,
        if (place.postalCode != null && place.postalCode!.isNotEmpty)
          place.postalCode,
      ].where((e) => e != null && e.isNotEmpty).join(", ");

      // Create location data
      Map<String, dynamic> locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Close loading dialog
      Navigator.of(context).pop();

      // Send location message
      onSendMessage(
        jsonEncode(locationData),
        MessageType.location,
        '',
        '0',
      );

    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: ${e.toString()}')),
      );
    }
  }

  Future<void> _cropImage(String image, {String? uploadingMsgId}) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image,
      compressFormat: ImageCompressFormat.png,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );
    if (croppedFile != null) {
      if (mounted) {
        setState(() {
          _croppedFile = croppedFile;
          xFile = File(_croppedFile!.path.toString());
          fileName = xFile!.path.split('/').last;
          extension = xFile!.path.split('.').last;
        });
      }
      if (xFile != null) {
        uploadImageFile(uploadingMsgId: uploadingMsgId);
      }
    }
  }

  void uploadImageFile({String? uploadingMsgId}) async {
    String type = "";
    if (mounted) {
      //AllDialogs.progressLoadingDialog(context, true);
    }
    UploadTask uploadTask = widget.chatServices.uploadImageFile(xFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      if (extension == "mp4" || extension == "MP4") {
        type = MessageType.doc;
      } else {
        type = MessageType.image;
      }
      if (mounted) {
        setState(() {
          // Remove uploading message from parent
          if (uploadingMsgId != null) {
            widget.onRemoveUploadingMessage(uploadingMsgId);
          }
          onSendMessage(imageUrl, type, fileName, "0");
        });
        //AllDialogs.progressLoadingDialog(context, false);
      }
    } on FirebaseException catch (e) {
    }
  }
}

class _UploadingImageMessage {
  final File file;
  final String id;
  _UploadingImageMessage({required this.file, required this.id});
}

class MessageType {
  static const text = "text";
  static const image = "image";
  static const sticker = "sticker";
  static const doc = "doc";
  static const location = "location";
}




/*
import 'dart:io';

import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/ui_utils.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../provider/chat_provider.dart';
import '../constants/my_colors.dart';
import '../constants/font_style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/assets_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/chat_services.dart';
import '../models/chat_messages.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:async';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:collection/collection.dart';
import '../helper/common.dart';

class ChatView extends StatefulWidget {
  final String customerName;
  final String customerAddress;
  final String customerAvatarUrl;
  final String jobType;
  final String jobDateTime;
  final String receiverId;

  static  String currentUserId = "10";

  ChatView({
    Key? key,
    required this.customerName,
    required this.customerAddress,
    required this.customerAvatarUrl,
    required this.jobType,
    required this.jobDateTime,
    required this.receiverId,
  }) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController _scrollController = ScrollController();
  // Move uploadingMessages to parent
  List<_UploadingImageMessage> uploadingMessages = [];

  // Reply state
  ChatMessages? replyToMessage;
  void setReplyToMessage(ChatMessages? msg) {
    setState(() {
      replyToMessage = msg;
    });
  }

  void addUploadingMessage(_UploadingImageMessage msg) {
    setState(() {
      uploadingMessages.add(msg);
    });
  }

  void removeUploadingMessage(String id) {
    setState(() {
      uploadingMessages.removeWhere((msg) => msg.id == id);
    });
  }

  Map<String, GlobalKey> messageKeys = {}; // <-- Add this line
  late ChatServices chatServices;
  @override
  void dispose() {
    CurrentChat.groupChatId = null;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final chatServices = ChatServices(
      firebaseFirestore: FirebaseFirestore.instance,
      firebaseStorage: FirebaseStorage.instance,
    );
    setUser();
    final groupChatId = chatServices.getChatRoomIdByUserId(ChatView.currentUserId, widget.receiverId);
    CurrentChat.groupChatId = groupChatId;

  }

  void setUser() {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    // Use the MongoDB ObjectId directly for chat compatibility
    ChatView.currentUserId = profileProvider.partner?.id ?? "10";
    chatServices =
        Provider.of<ChatProvider>(context, listen: false).chatServices;
    chatServices.getSelfInfo(ChatView.currentUserId, "", "", 0);
  }


  @override
  Widget build(BuildContext context) {
    final chatServices = ChatServices(
      firebaseFirestore: FirebaseFirestore.instance,
      firebaseStorage: FirebaseStorage.instance,
    );
    print("ChatView.currentUserId...${ChatView.currentUserId}");
    print("widget.receiverId...${widget.receiverId}");
    final groupChatId = chatServices.getChatRoomIdByUserId(ChatView.currentUserId, widget.receiverId);
    print("Partner ...groupChatId...$groupChatId");
    // Ensure welcome message is present if chat is empty
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.ensureWelcomeMessage(
      groupChatId: groupChatId,
      receiverId: widget.receiverId,
      systemUserId: 'system',
      welcomeText: 'Welcome to the chat! How can we help you today?',
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:PreferredSize(preferredSize: Size.zero, child: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,elevation: 0,)),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:18.0, vertical:5),
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
                                  padding: EdgeInsets.all(6),
                                  child: const Icon(Icons.arrow_back,size: 24,)),
                            ),

                            SizedBox(width: 10,),
                            CircleAvatar(
                              backgroundImage: widget.customerAvatarUrl.isNotEmpty
                                  ? NetworkImage(widget.customerAvatarUrl)
                                  : null,
                              child: widget.customerAvatarUrl.isEmpty ? Icon(Icons.person) : null,
                              radius: 22,
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.customerName, style: boldTextStyle(fontSize: 18.0, color: MyColors.blackColor)),
                                  Text(widget.customerAddress, style: regularTextStyle(fontSize: 12.0, color: MyColors.color838383)),
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
                          padding: EdgeInsets.all(6),
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
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          icon: Icon(Icons.call, color: Colors.white,size: 20,),
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
                            padding: EdgeInsets.symmetric(vertical:8),
                          ),
                          icon: SvgPicture.asset(MyAssetsPaths.navigation, height: 20, width: 20, color: MyColors.appTheme),
                          label: Text('Navigate', style: mediumTextStyle(fontSize: 14.0, color: MyColors.appTheme)),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
         //   hsized5,
            Divider(color: MyColors.borderColor,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical:5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.jobType, style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                  Text(' · 14 June, 12:00 PM – 1:00 PM', style: mediumTextStyle(fontSize: 14.0, color: MyColors.color7A849C)),
                ],
              ),
            ),
            hsized5,
            Divider(height: 1, color:MyColors.borderColor),
            hsized16,
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: chatServices.getChatMessage(groupChatId, 100),
                      builder: (context, snapshot) {
                        List<ChatMessages> messages = [];
                        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                          messages = snapshot.data!.docs.map((doc) => ChatMessages.fromDocument(doc)).toList();
                        }
                        // Use parent's uploadingMessages
                        final allMessages = List<Widget>.from(
                          uploadingMessages.map((uploadingMsg) => Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  padding: EdgeInsets.all(2),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.45,
                                    maxHeight: 200,
                                  ),
                                  decoration: BoxDecoration(
                                    color: MyColors.appTheme.withOpacity(0.7),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(0),
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          uploadingMsg.file,
                                          fit: BoxFit.cover,
                                          height: 180,
                                          width: 180,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.black.withOpacity(0.3),
                                          child: Center(
                                            child: SizedBox(
                                              width: 36,
                                              height: 36,
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                strokeWidth: 3,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                        );
                        allMessages.addAll(List.generate(messages.length, (index) {
                          final msg = messages[index];
                          final isSentByMe = msg.senderId == ChatView.currentUserId;
                          final msgId = msg.timestamp.millisecondsSinceEpoch.toString();
                          if (!messageKeys.containsKey(msgId)) {
                            messageKeys[msgId] = GlobalKey();
                          }
                          // Find the replied message if any
                          ChatMessages? repliedMsg;
                          if (msg.replyTo != null) {
                            repliedMsg = messages.firstWhereOrNull((m) => m.timestamp.millisecondsSinceEpoch.toString() == msg.replyTo);
                          }
                          chatServices.markMessagesAsSeen(
                              chatServices.getChatRoomIdByUserId(ChatView.currentUserId,msg.receiverId),
                              ChatView.currentUserId,
                              msg.receiverId,"2","1");
                          //chatServices.seeMsg(chatServices.getChatRoomIdByUserId(ChatView.currentUserId,msg.receiverId),msg.receiverId,"2");
                          chatServices.decrementCount(ChatView.currentUserId);
                          return Slidable(
                            key: ValueKey(msg.timestamp.toString() + msg.senderId),
                            endActionPane:isSentByMe ? ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  onPressed: (_) => setReplyToMessage(msg),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.white,
                                  icon: Icons.reply,
                                  label: '',
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ):null,
                            startActionPane: isSentByMe?null:
                            ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.2,
                              children: [
                                SlidableAction(
                                  onPressed: (_) => setReplyToMessage(msg),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.white,
                                  icon: Icons.reply,
                                  label: '',
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            )  ,
                            child: Align(
                              key: messageKeys[msgId], // <-- Assign key here
                              alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: isSentByMe ?CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  if (msg.replyTo != null && repliedMsg != null)
                                    GestureDetector(
                                      onTap: () {
                                        // Scroll to the replied message
                                        final targetIndex = messages.indexWhere((m) => m.timestamp.millisecondsSinceEpoch.toString() == msg.replyTo);
                                        if (targetIndex != -1) {
                                          final position = (messages.length - 1 - targetIndex) * 80.0; // Approximate height
                                          _scrollController.animateTo(
                                            position,
                                            duration: Duration(milliseconds: 400),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                                        margin: EdgeInsets.only(bottom: 0),
                                      //  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border(left: BorderSide(color: MyColors.appTheme, width: 4)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              repliedMsg.type == MessageType.image ? Icons.image : Icons.reply,
                                              size: 16,
                                              color: MyColors.color838383,
                                            ),
                                            SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                repliedMsg.type == MessageType.image ? 'Photo' : repliedMsg.content,
                                                style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383),
                                              //  maxLines: 1,
                                               // overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (msg.type == MessageType.image)
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Dialog(
                                            backgroundColor: Colors.black,
                                            insetPadding: EdgeInsets.zero,
                                            child: GestureDetector(
                                              onTap: () => Navigator.of(context).pop(),
                                              child: Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: PhotoView(
                                                  imageProvider: NetworkImage(msg.content),
                                                  backgroundDecoration: BoxDecoration(color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(vertical: 4),
                                        padding: EdgeInsets.all(2),
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.45,
                                          maxHeight: 200,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF5F5F5),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                            bottomLeft: Radius.circular(isSentByMe ? 16 : 0),
                                            bottomRight: Radius.circular(isSentByMe ? 0 : 16),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            msg.content,
                                            fit: BoxFit.cover,
                                            height: 180,
                                            width: 180,
                                            errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 60),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      margin: EdgeInsets.only(bottom: 4),
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                                      decoration: BoxDecoration(
                                        color: isSentByMe ? MyColors.appTheme : Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                          bottomLeft: Radius.circular(isSentByMe ? 16 : 0),
                                          bottomRight: Radius.circular(isSentByMe ? 0 : 16),
                                        ),
                                      ),
                                      child: Text(
                                        msg.content,
                                        style: regularTextStyle(fontSize: 16.0, color: isSentByMe ? Colors.white : MyColors.blackColor),
                                      ),
                                    ),
                                  Row(
                                    mainAxisAlignment:isSentByMe ?  MainAxisAlignment.end:MainAxisAlignment.start,
                                    children: [
                                      isSentByMe ?
                                      Icon(
                                        msg.status == '2'
                                          ? Icons.done_all // double tick blue
                                          : msg.status == '1'
                                            ? Icons.done_all // double tick grey
                                            : Icons.check,   // single tick grey
                                        color: msg.status == '2'
                                          ? Colors.blue
                                          : MyColors.color838383,
                                        size: 11,
                                      ):SizedBox.shrink(),
                                      Text(
                                        _formatTime(msg.timestamp.toDate()),
                                        style: regularTextStyle(fontSize: 11.0, color:  MyColors.color838383),
                                      ),
                                    ],
                                  ),
                                  hsized15,
                                ],
                              ),
                            ),
                          );
                        }));
                        // Mark messages as delivered if not sent by me and status is 0
                        for (final msg in messages) {
                          final isSentByMe = msg.senderId == ChatView.currentUserId;
                          if (!isSentByMe && msg.status == '0') {
                            chatServices.markMessageDelivered(groupChatId, msg.timestamp.millisecondsSinceEpoch.toString());
                          }
                        }
                        // Scroll to bottom when new messages arrive or uploading
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              0.0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                        if (messages.isEmpty && uploadingMessages.isEmpty) {
                          return Center(child: Text('No messages yet'));
                        }
                        return ListView(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal:18),
                          reverse: true,
                          children: allMessages,
                        );
                      },
                    ),
                  ),
                  StreamBuilder<bool>(
                    stream: chatServices.typingStatusStream(groupChatId, widget.receiverId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data == true) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 4),
                          child: Row(
                            children: [
                              CircleAvatar(radius: 12, backgroundColor: MyColors.appTheme, child: Icon(Icons.more_horiz, color: Colors.white, size: 16)),
                              SizedBox(width: 8),
                              Text('Typing...', style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383)),
                            ],
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            _MessageInputBar(
              chatServices: chatServices,
              groupChatId: groupChatId,
              receiverId: widget.receiverId,
              currentUserId: ChatView.currentUserId,
              // Pass uploading message management to input bar
              onAddUploadingMessage: addUploadingMessage,
              onRemoveUploadingMessage: removeUploadingMessage,
              // Pass reply state
              replyToMessage: replyToMessage,
              onCancelReply: () => setReplyToMessage(null),
            ),
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

class _MessageInputBar extends StatefulWidget {
  final ChatServices chatServices;
  final String groupChatId;
  final String receiverId;
  final String currentUserId;
  final void Function(_UploadingImageMessage) onAddUploadingMessage;
  final void Function(String) onRemoveUploadingMessage;
  final ChatMessages? replyToMessage;
  final void Function() onCancelReply;
  const _MessageInputBar({
    required this.chatServices,
    required this.groupChatId,
    required this.receiverId,
    required this.currentUserId,
    required this.onAddUploadingMessage,
    required this.onRemoveUploadingMessage,
    this.replyToMessage,
    required this.onCancelReply,
  });
  @override
  State<_MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<_MessageInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final picker = ImagePicker();
  File? photoController;
  CroppedFile? _croppedFile;
  String fileName = '';
  File? xFile;
  String extension = "";
  String dateSeparatorText = "";
  bool isFirstMessageOfDay = false;
  bool upload = false;
  Timer? _typingTimer;

  // Unified message sending method now uses ChatProvider
  void onSendMessage(
    String content,
    String type,
    String filename,
    String seen,
  ) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(
      content: content,
      type: type,
      groupChatId: widget.groupChatId,
      currentUserId: widget.currentUserId,
      receiverId: widget.receiverId,
      filename: filename,
      seen: seen,
      controller: _controller,
      focusNode: focusNode,
      replyTo: widget.replyToMessage?.timestamp.millisecondsSinceEpoch.toString(), // Use timestamp as id
      // chatServices: chatServices
      // Optionally pass bookingId if needed
    );
    widget.onCancelReply();
  }

  void _setTyping(bool isTyping) {
    widget.chatServices.setTypingStatus(widget.groupChatId, widget.currentUserId, isTyping);
  }

  void _onTextChanged(String value) {
    _setTyping(true);
    _typingTimer?.cancel();
    _typingTimer = Timer(Duration(seconds: 2), () {
      _setTyping(false);
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _setTyping(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.replyToMessage != null)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                border: Border(
                  left: BorderSide(color: MyColors.appTheme, width: 4),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.replyToMessage!.senderId == widget.currentUserId ? 'You' : 'Reply to User',
                          style: boldTextStyle(fontSize: 15.0, color: MyColors.blackColor),
                        ),
                        SizedBox(height: 2),
                        if (widget.replyToMessage!.type == MessageType.image)
                          Row(
                            children: [
                              Icon(Icons.image, size: 16, color: MyColors.color838383),
                              SizedBox(width: 4),
                              Text('Photo', style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          )
                        else
                          Text(
                            widget.replyToMessage!.content,
                            style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onCancelReply,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                      child: Icon(Icons.close, size: 20, color: MyColors.color838383),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              SizedBox(width:10,),
              GestureDetector(
                onTap: (){
                  showBottomsheetUploadImage(context,picCameraOnTap,galleryOnTap);
                },
                child: Icon(Icons.add, color: Colors.black.withOpacity(0.7),size:35,),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 15, 24, 20),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical:0),
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
                          controller: _controller,
                          focusNode: focusNode,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          style: regularTextStyle(fontSize:16.0, color:MyColors.blackColor),
                          decoration: InputDecoration(
                            hintText: 'Type message...',
                            hintStyle: regularTextStyle(fontSize:16.0, color:MyColors.color838383),
                            border: InputBorder.none,
                          ),
                          onChanged: _onTextChanged,
                          onSubmitted: (val) {
                            onSendMessage(val, MessageType.text, '', '0');
                            _setTyping(false);
                          },
                          onEditingComplete: () => _setTyping(false),
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          onSendMessage(_controller.text, MessageType.text, '', '0');
                          _setTyping(false);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: MyColors.appTheme,
                              shape: BoxShape.circle
                          ),
                          padding: EdgeInsets.all(5),
                          child: Icon(Icons.send_outlined, color: Colors.white,size: 18,),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void showBottomsheetUploadImage(BuildContext context, GestureTapCallback cameraOnTap,GestureTapCallback galleryOnTap) {
    showModalBottomSheet(
      context: context,
      backgroundColor:Colors.transparent,
      builder: (BuildContext context) {
        return SizedBox(
          height: 350,
          child: UiUtils.uploadImageBottomUi(context,cameraOnTap,galleryOnTap),
        );
      },
    );
  }

  Future<void> picCameraOnTap() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _cropImage(pickedFile.path);
      }
    });
  }
  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.pickImage(
        source: imageSource, imageQuality: 90);
    if (pickedFile != null) {
      File photo = File(pickedFile.path);
      setState(() {
        upload = true;
      });
      // Add uploading message to parent
      final tempMsg = _UploadingImageMessage(
        file: photo,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      widget.onAddUploadingMessage(tempMsg);
      _cropImage(photo.path, uploadingMsgId: tempMsg.id);
      Navigator.pop(context);
    }
  }

  void cameraOnTap() {
    getImage(ImageSource.camera);
  }

  void galleryOnTap() {
    getImage(ImageSource.gallery);
  }

  Future<void> _cropImage(String image, {String? uploadingMsgId}) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image,
      compressFormat: ImageCompressFormat.png,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );
    if (croppedFile != null) {
      if (mounted) {
        setState(() {
          _croppedFile = croppedFile;
          xFile = File(_croppedFile!.path.toString());
          fileName = xFile!.path.split('/').last;
          extension = xFile!.path.split('.').last;
        });
      }
      if (xFile != null) {
        uploadImageFile(uploadingMsgId: uploadingMsgId);
      }
    }
  }

  void uploadImageFile({String? uploadingMsgId}) async {
    String type = "";
    if (mounted) {
      //AllDialogs.progressLoadingDialog(context, true);
    }
    UploadTask uploadTask = widget.chatServices.uploadImageFile(xFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      if (extension == "mp4" || extension == "MP4") {
        type = MessageType.doc;
      } else {
        type = MessageType.image;
      }
      if (mounted) {
        setState(() {
          // Remove uploading message from parent
          if (uploadingMsgId != null) {
            widget.onRemoveUploadingMessage(uploadingMsgId);
          }
          onSendMessage(imageUrl, type, fileName, "0");
        });
        //AllDialogs.progressLoadingDialog(context, false);
      }
    } on FirebaseException catch (e) {
    }
  }
}

class _UploadingImageMessage {
  final File file;
  final String id;
  _UploadingImageMessage({required this.file, required this.id});
}

class MessageType {
  static const text = "text";
  static const image = "image";
  static const sticker = "sticker";
  static const doc = "doc";
  static const location = "location";
} */

