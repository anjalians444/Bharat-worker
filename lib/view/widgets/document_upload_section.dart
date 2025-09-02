import 'dart:io';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:file_picker/file_picker.dart';

class DocumentUploadSection extends StatefulWidget {
  final PartnerModel? partner;

  const DocumentUploadSection({Key? key, this.partner}) : super(key: key);

  @override
  State<DocumentUploadSection> createState() => _DocumentUploadSectionState();
}

class _DocumentUploadSectionState extends State<DocumentUploadSection> {
  // Remove local state for selectedIdType, idController, localExperienceCertificates

  Future<void> pickImage(BuildContext context, Function(File) onPicked) async {
    final picker = ImagePicker();
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: MyColors.whiteColor,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(languageProvider.translate('camera')),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                    await picker.pickImage(source: ImageSource.camera);
                if (picked != null) onPicked(File(picked.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(languageProvider.translate('gallery')),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                    await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) onPicked(File(picked.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickMultipleCertificates(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedImages = await picker.pickMultiImage();
    if (pickedImages != null && pickedImages.isNotEmpty) {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      for (var file in pickedImages) {
        profileProvider.addExperienceCertificate(File(file.path));
      }
    }
    // For picking PDFs, use file_picker if needed (not implemented here)
  }

  Future<void> pickLicenseFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', "PNG"],
    );
    // JPEG, JPG, PNG, WebP, AVIF and PDF
    if (result != null && result.files.isNotEmpty) {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      for (var file in result.files) {
        if (file.path != null) {
          profileProvider.addLicenseFile(File(file.path!));
        }
      }
    }
  }

  // Update removeCertificate to use removeLicenseFile
  void removeCertificate(BuildContext context, File file) {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.removeLicenseFile(file);
  }

  int getIdMaxLength(ProfileProvider profileProvider) {
    switch (profileProvider.selectedIdType) {
      case "Aadhar Card":
        return 14;
      case "PAN Card":
        return 10;
      default:
        return 30;
    }
  }

  String? idValidator(String? value, ProfileProvider profileProvider,
      LanguageProvider languageProvider) {
    if (value == null || value.isEmpty) {
      return languageProvider.translate('field_required');
    }
    final selectedIdType = profileProvider.selectedIdType;
    if (selectedIdType == "Aadhar Card") {
      profileProvider.aadharNumber = value?.replaceAll(' ', '') ?? '';
      var cleanedValue = value?.replaceAll(' ', '') ?? '';
      if (profileProvider.aadharNumber!.length != 12)
        return languageProvider.translate('aadhaar_12_digits');
      if (!RegExp(r'^\d{12}$').hasMatch(cleanedValue))
        return languageProvider.translate('aadhaar_digits_only');
    } else if (selectedIdType == "PAN Card") {
      if (value == null || value.length != 10)
        return languageProvider.translate('pan_10_characters');
      if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}').hasMatch(value.toUpperCase())) {
        return languageProvider.translate('pan_format');
      }
    } else if (selectedIdType == "Driving License") {
      if (value == null || value.length < 8)
        return languageProvider.translate('dl_valid');
      if (!RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]{8,13}')
          .hasMatch(value.toUpperCase())) {
        return languageProvider.translate('dl_format');
      }
    }
    return null;
  }

  Widget uploadBox(
      {required BuildContext context,
      required String labelKey,
      required File? image,
      required VoidCallback onUpload,
      required VoidCallback onRemove,
      required String imageUrl}) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(languageProvider.translate(labelKey),
                style: semiBoldTextStyle(fontSize: 15.0, color: MyColors.darkText)),

            Text(' *',
                style: TextStyle(color: Colors.red, fontSize: 15))
          ],
        ),
        const SizedBox(height: 8),
        DottedBorder(
          color: MyColors.borderColor,
          borderType: BorderType.RRect,
          radius: const Radius.circular(12),
          dashPattern: const [6, 4],
          strokeWidth: 1,
          child: Container(
            width: double.infinity,
            height: 90,
            alignment: Alignment.center,
            child: image == null && imageUrl == "null"
                ? GestureDetector(
                    onTap: onUpload,
                    child: Text(
                      languageProvider.translate('upload_id_image'),
                      style: regularTextStyle(
                          color: MyColors.lightText, fontSize: 14.0),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: image == null
                                ? NetworkImage(imageUrl)
                                : FileImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: onRemove,
                        child: Text(
                          languageProvider.translate('remove'),
                          style: TextStyle(
                              color: Colors.red.shade400, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.setData(widget.partner);
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.translate('verify_your_identity'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            languageProvider.translate('upload_id_certificates'),
            style: regularTextStyle(color: Colors.grey, fontSize: 14.0),
          ),
          const SizedBox(height: 18),
          Consumer<ProfileProvider>(builder: (context,profileProvider,_){
            return   Row(
              children: [
                Text(languageProvider.translate('select_government_id'),
                    style: semiBoldTextStyle(
                        fontSize: 15.0, color: MyColors.darkText)),
                Text(' *',
                    style: TextStyle(color: Colors.red, fontSize: 15))

              ],
            );
          }),
          Text(
            "Note: Aadhar Card is mandatory for verification.",
            style: regularTextStyle(fontSize: 11.0, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: profileProvider.selectedIdType,
            hint: Text(languageProvider.translate('select_government_id')),
            style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
            dropdownColor: MyColors.whiteColor,
            //  padding: EdgeInsets.symmetric(horizontal: 20),
            items: [
              DropdownMenuItem(
                  value: "Aadhar Card",
                  child: Text(languageProvider.translate('aadhar_card'))),
              DropdownMenuItem(
                  value: "PAN Card",
                  child: Text(languageProvider.translate('pan_card'))),
              //    DropdownMenuItem(value: "Driving License", child: Text(languageProvider.translate('driving_license'))),
            ],
            onChanged: (value) {
              // if(widget.partner!.id != null){
                profileProvider.onChangeDropDown(value.toString(),widget.partner);
              // }else{
              //  profileProvider.onChangeDropDown(value.toString());
            //  }

            },
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Text(languageProvider.translate('enter_id_no'),
                  style: semiBoldTextStyle(
                      fontSize: 15.0, color: MyColors.darkText)),
              Text(' *', style: TextStyle(color: Colors.red, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          Consumer<ProfileProvider>(builder: (context,profileProvider,_){
            return  TextFormField(
              controller: profileProvider.idController,
              focusNode: profileProvider.focusNode,
              maxLength: getIdMaxLength(profileProvider),
              keyboardType: profileProvider.selectedIdType == "Aadhar Card"
                  ? TextInputType.number
                  : TextInputType.text,
              textCapitalization: profileProvider.selectedIdType == "Aadhar Card"
                  ? TextCapitalization.none
                  : TextCapitalization.characters,
              // force capital letters on keyboard
              inputFormatters: profileProvider.selectedIdType == "Aadhar Card"
                  ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
                AadhaarInputFormatter(),
              ]
                  : [

                FilteringTextInputFormatter.allow(RegExp("[A-Z0-9]")),
                // ✅ Alphabets + Numbers
                UpperCaseTextFormatter(),
                LengthLimitingTextInputFormatter(10),
              ],
              onTapOutside: (v) {
                profileProvider.unfocusf(context);
              },
              decoration: InputDecoration(
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: languageProvider.translate('enter_id_number'),
                hintStyle:
                regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
                counterText: "",
              ),
              validator: (value) =>
                  idValidator(value, profileProvider, languageProvider),
            );
          }),

          const SizedBox(height: 18),
          // Front Side
          uploadBox(
              context: context,
              labelKey: 'front_side',
              image: profileProvider.frontImage,
              onUpload: () => pickImage(
                  context, (file) => profileProvider.setFrontImage(file)),
              onRemove: () => profileProvider.removeFrontImage(),
              imageUrl: profileProvider.frontImageUrl.toString()),
          // Back Side
          uploadBox(
              context: context,
              labelKey: 'back_side',
              image: profileProvider.backImage,
              onUpload: () => pickImage(
                  context, (file) => profileProvider.setBackImage(file)),
              onRemove: () => profileProvider.removeBackImage(),
              imageUrl: profileProvider.backImageUrl.toString()
              //profileProvider.setFrontImageUrl(partner)
              ),
          // Work License or Certificates (multiple files, images and PDFs)
          Row(
            children: [
              Text(languageProvider.translate('work_license_certificates'),
                  style:
                      semiBoldTextStyle(fontSize: 15.0, color: MyColors.darkText)),
              Text(' *',
                  style: TextStyle(color: Colors.red, fontSize: 15))
            ],
          ),
          const SizedBox(height: 8),
          DottedBorder(
            color: MyColors.borderColor,
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            dashPattern: const [6, 4],
            strokeWidth: 1,
            child: Container(
              width: double.infinity,
              height: 95,
              alignment: Alignment.center,
              child: profileProvider.certificateFiles.isEmpty
                  ? GestureDetector(
                      onTap: () => pickLicenseFiles(context),
                      child: Text(
                        languageProvider.translate('upload_id_image'),
                        style: regularTextStyle(
                            color: MyColors.lightText, fontSize: 14.0),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ...profileProvider.certificateFiles.map((cert) {
                                  return Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: cert.isPdf
                                            ? Icon(Icons.picture_as_pdf,
                                                size: 40, color: Colors.red)
                                            : cert.isLocal
                                                ? Image.file(cert.file!,
                                                    fit: BoxFit.cover)
                                                : Image.network(cert.url!,
                                                    fit: BoxFit.cover),
                                      ),
                                      GestureDetector(
                                        onTap: () => profileProvider
                                            .removeCertificate(cert),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.all(2),
                                          child: const Icon(Icons.close,
                                              color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                                GestureDetector(
                                  onTap: () => pickLicenseFiles(context),
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.blueAccent
                                              .withOpacity(0.5)),
                                    ),
                                    child: const Icon(Icons.add,
                                        color: Colors.blueAccent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            languageProvider.translate('documents_reviewed'),
            style: regularTextStyle(color: Colors.grey, fontSize: 13.0),
          ),
          hsized60,
          // Remove submit button from here
        ],
      );

  }

  removeCertificateUrl(BuildContext context, String url) {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.removeLicenseUrl(url);
  }
}

class AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted = '';

    for (int i = 0; i < digitsOnly.length; i++) {
      formatted += digitsOnly[i];
      if ((i + 1) % 4 == 0 && i != digitsOnly.length - 1) {
        formatted += ' ';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
