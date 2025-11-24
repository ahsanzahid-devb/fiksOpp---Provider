import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/base_scaffold_widget.dart';
import 'package:handyman_provider_flutter/components/selected_item_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/app_widgets.dart';
import '../components/empty_error_state_widget.dart';
import '../components/pdf_viewer_component.dart';
import '../main.dart';
import '../models/document_list_response.dart';
import '../networks/rest_apis.dart';
import '../utils/colors.dart';
import '../utils/common.dart';
import '../utils/configs.dart';
import '../utils/images.dart';
import 'sign_in_screen.dart';

class UploadDocumentsScreen extends StatefulWidget {
  final Map<String, dynamic> formRequest;
  const UploadDocumentsScreen({super.key, required this.formRequest});

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  bool isAcceptedTc = false;
  ValueNotifier _valueNotifier = ValueNotifier(true);
  Future<DocumentListResponse>? future;
  FilePickerResult? filePickerResult;
  File? imageFile;
  List<Documents> uploadDocResp = [];

  initState() {
    super.initState();
    init();
  }

  init() {
    future = getDocList().whenComplete(() {
      appStore.setLoading(false);
    });
  }

  void getMultipleFile({int? updateId, Function(String)? setImage}) async {
    filePickerResult = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.custom, allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf']);

    if (filePickerResult != null) {
      showConfirmDialogCustom(
        context,
        title: languages.confirmationUpload,
        onAccept: (BuildContext context) {
          ifNotTester(context, () {
            setState(() {
              imageFile = File(filePickerResult!.paths.first!);
              setImage?.call(imageFile!.path);
            });
          });
        },
        positiveText: languages.lblYes,
        negativeText: languages.lblNo,
        primaryColor: primaryColor,
      );
    } else {}
  }

  //Register API Fun
  Future<void> registerFun() async {
    if (!isAcceptedTc) {
      toast(languages.lblTermCondition);
      return;
    }
    log("Document List: ${uploadDocResp.where((element) => element.filePath?.isEmpty ?? true).toList()}");
    if (uploadDocResp.isEmpty || (uploadDocResp.where((element) => (element.isRequired == 1 && (element.filePath?.isEmpty ?? true))).isNotEmpty)) {
      toast(languages.pleaseUploadAllRequired);
      return;
    }
    appStore.setLoading(true);
    List<Documents> list = uploadDocResp.where((element) => element.filePath?.isNotEmpty ?? false).toList();
    for (int i = 0; i < list.length; i++) {
      widget.formRequest['document_id[$i]'] = list[i].id;
    }
    log("Request ---> ${widget.formRequest}");
    await registerUser(widget.formRequest,imageFile: list).then((value) {
      appStore.setLoading(false);
      toast(value.message.validate());
      push(SignInScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  // Termas of service and Provacy policy text
  Widget _buildTcAcceptWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: _valueNotifier,
          builder: (context, value, child) => SelectedItemWidget(isSelected: isAcceptedTc).onTap(() async {
            isAcceptedTc = !isAcceptedTc;
            _valueNotifier.notifyListeners();
          }),
        ),
        16.width,
        
        RichTextWidget(
          list: [
            TextSpan(text: '${languages.lblIAgree} ', style: secondaryTextStyle()),
            TextSpan(
              text: languages.lblTermsOfService,
              style: boldTextStyle(color: primaryColor),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  checkIfLink(context, appConfigurationStore.termConditions, title: languages.lblTermsAndConditions);
                },
            ),
            TextSpan(text: ' & ', style: secondaryTextStyle()),
            TextSpan(
              text: languages.lblPrivacyPolicy,
              style: boldTextStyle(color: primaryColor),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  checkIfLink(context, appConfigurationStore.privacyPolicy, title: languages.lblPrivacyPolicy);
                },
            ),
          ],
        ).flexible(flex: 2),
      ],
    ).paddingAll(16);
  }

  @override
  void dispose() {
    uploadDocResp.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.uploadDocuments,
      body: Stack(
        children: [
          Column(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(languages.uploadRequiredDocuments, style: boldTextStyle(size: 14)),
                    8.height,
                    RichText(
                      text: TextSpan(
                        style: secondaryTextStyle(size: 12),
                        children: [
                           TextSpan(
                            text: languages.pleaseUploadTheFollowing,
                          ),
                          TextSpan(
                            text: '*',
                            style: secondaryTextStyle(size: 12).copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                           TextSpan(
                            text: ' ${languages.requiredDocumentsMustBe}',
                          ),
                        ],
                      ),
                    ),
                    35.height,
                    SnapHelperWidget<DocumentListResponse>(
                      future: future,
                      loadingWidget: Center(child: LoaderWidget()).paddingTop(context.height() * 0.2),
                      onSuccess: (list) {
                        uploadDocResp = list.documents ?? [];
                        return AnimatedListView(
                          itemCount: uploadDocResp.length,
                          shrinkWrap: true,
                          listAnimationType: ListAnimationType.FadeIn,
                          fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                          emptyWidget: NoDataWidget(
                            title: languages.noNotificationTitle,
                            subTitle: languages.noNotificationSubTitle,
                            imageWidget: EmptyStateWidget(),
                          ),
                          itemBuilder: (context, index) {
                            Documents data = uploadDocResp[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RichText(
                                    text: TextSpan(
                                  style: primaryTextStyle(size: 14),
                                  children: [
                                    TextSpan(text: data.name.validate(), style: boldTextStyle(size: 14, weight: FontWeight.w500)),
                                    if (data.isRequired == 1) TextSpan(text: ' *', style: primaryTextStyle(color: Colors.red, size: 14)),
                                  ],
                                )),
                                12.height,
                                GestureDetector(
                                  onTap: () {
                                    getMultipleFile(setImage: (imagePath){
                                      log("Image Path: $imagePath");
                                      list.documents?[index] = list.documents?[index].copyWith(filePath: imagePath) ?? Documents();
                                      log("File Path: ${list.documents?[index].filePath}");
                                    });
                                    setState(() {});
                                  },
                                  child: DottedBorderWidget(
                                    color: context.dividerColor,
                                    radius: defaultRadius,
                                    child: Container(
                                      height: 200,
                                      width: context.width(),
                                      decoration: BoxDecoration(
                                        color:  lightPrimaryColor,
                                        borderRadius: radius(defaultRadius),
                                      ),
                                      alignment: Alignment.center,
                                      child: data.filePath?.isNotEmpty ?? false ? Container(
                                      height: 200,
                                      width: context.width(),
                                      decoration: BoxDecoration(
                                        color: lightPrimaryColor,
                                        borderRadius: radius(defaultRadius),
                                        image: data.filePath?.contains('.pdf') ?? false ?
                                         DecorationImage(
                                          image: AssetImage(img_files),
                                            colorFilter: ColorFilter.mode(
                                            black.withValues(alpha: 0.6),
                                            BlendMode.darken,
                                            ),
                                          fit: BoxFit.cover,
                                        ): DecorationImage(
                                          image: FileImage(File(data.filePath!)),
                                          fit: BoxFit.cover,
                                        ),
                                        ),
                                        child: data.filePath?.contains('.pdf')??  false ? Container(
                                          height: 40,
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: radiusCircular(defaultRadius),
                                              bottomRight: radiusCircular(defaultRadius)
                                            )
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("${data.filePath.validate().split("/").last}", style: boldTextStyle(color: white), maxLines: 2,overflow: TextOverflow.ellipsis),
                                              8.height,
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap: (){
                                                      PdfViewerComponent(pdfFile: data.filePath.validate(),isFile: true).launch(context);
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(4),
                                                        color: context.primaryColor,
                                                      ),
                                                      alignment: Alignment.center,
                                                      child: Text(languages.viewPDF, style: boldTextStyle(color: white)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ): Offstage(),
                                        ): Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(ic_documents, height: 58),
                                          18.height,
                                          RichText(
                                              text: TextSpan(
                                            style: primaryTextStyle(size: 14),
                                            children: [
                                              TextSpan(text: languages.dropYourFilesHereOr, style: primaryTextStyle(size: 14, weight: FontWeight.w500,color: black)),
                                              TextSpan(text: " ${languages.browse}", style: boldTextStyle(size: 14, color: context.primaryColor)),
                                            ],
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                16.height
                              ],
                            );
                          },
                          onSwipeRefresh: () async {
                            init();
                            setState(() {});
                            return await 2.seconds.delay;
                          },
                        );
                      },
                      errorBuilder: (error) {
                        return NoDataWidget(
                          title: error,
                          imageWidget: ErrorStateWidget(),
                          retryText: languages.reload,
                          onRetry: () {
                            appStore.setLoading(true);
                            init();
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ],
                ).paddingAll(16),
              ).expand(),
              _buildTcAcceptWidget(),
              Observer(
                builder: (_) => AppButton(
                  margin: EdgeInsets.only(bottom: 12),
                  text: languages.lblSignup,
                  height: 40,
                  color: appStore.isLoading ? primaryColor.withValues(alpha: 0.5) : primaryColor,
                  textStyle: boldTextStyle(color: white),
                  width: context.width() - context.navigationBarHeight,
                  onTap:  () {
                        if(!appStore.isLoading) {
                          registerFun();
                        }
                  }
                ),
              ).paddingOnly(left: 16.0, right: 16.0)
            ],
          ),
        ],
      ),
    );
  }

  Future<void> openPdfExternally(String pdfUrl) async {
    final uri = Uri.parse(pdfUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $pdfUrl';
    }
  }
}