import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/screens/chat/components/user_item_widget.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../auth/sign_in_screen.dart';
import '../../components/base_scaffold_widget.dart';
import '../../components/empty_error_state_widget.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  /// Reuse the same [Query] instance for a given uid so pagination state is not
  /// reset when unrelated [Observer] parents rebuild.
  String? _contactsQueryUid;
  Query? _contactsQuery;

  Query _contactsQueryFor(String uid) {
    if (_contactsQueryUid == uid && _contactsQuery != null) {
      return _contactsQuery!;
    }
    _contactsQueryUid = uid;
    _contactsQuery = chatServices.fetchChatListQuery(userId: uid);
    return _contactsQuery!;
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Future<void> _debugFetchChatContactsOnce() async {
    final uid = appStore.uid;
    if (uid.isEmpty) return;

    try {
      final query = chatServices.fetchChatListQuery(userId: uid);
      final snap = await query.limit(5).get();
      developer.log('[ChatListScreen] debugFetch uid="$uid" '
          'docCount=${snap.docs.length}');
      for (final d in snap.docs) {
        final data = d.data() as Map<String, dynamic>;
        developer.log('[ChatListScreen] debugContact snapId="${d.id}" '
            'keys="${data.keys.toList()}" uidField="${data['uid']}" '
            'lastMessageTime="${data['lastMessageTime']}"');
      }
    } catch (e, st) {
      developer.log(
          '[ChatListScreen] debugFetchChatContactsOnce error '
          'uid="$uid" error="$e"',
          stackTrace: st);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  bool get isUserTypeHandyman => appStore.userType == USER_TYPE_HANDYMAN;
  bool get isUserTypeProvider => appStore.userType == USER_TYPE_PROVIDER;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Observer(
        builder: (context) {
          // Touch only what should relayout this screen. Other appStore fields
          // (e.g. notification count) must not rebuild FirestorePagination or a
          // new FutureBuilder future would reset the whole contact list UI.
          final uid = appStore.uid.validate();
          final isLoggedIn = FirebaseAuth.instance.currentUser != null &&
              uid.isNotEmpty;

          if (!isLoggedIn) {
            developer.log(
              '[ChatListScreen] Not logged in for chat. '
              'firebaseUser=${FirebaseAuth.instance.currentUser != null}, '
              'appStore.uid="$uid"',
            );
            return NoDataWidget(
              title: languages.youAreNotConnectedWithChatServer,
              subTitle: languages.tapBelowButtonToConnectWithOurChatServer,
              onRetry: () async {
                if (!appStore.isLoggedIn) {
                  SignInScreen().launch(context);
                } else {
                  appStore.setLoading(true);
                  await authService.verifyFirebaseUser().then((value) {
                    setState(() {});
                  }).catchError((e) {
                    toast(e.toString());
                  });
                  appStore.setLoading(false);
                }
              },
              retryText: languages.connect,
              imageWidget: EmptyStateWidget(),
            ).paddingSymmetric(horizontal: 16);
          }

          developer.log(
            '[ChatListScreen] Rendering chat list. appStore.uid="$uid"',
          );

          if (kDebugMode) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _debugFetchChatContactsOnce();
            });
          }

          return FirestorePagination(
            key: ValueKey<String>('chat_contacts_$uid'),
            query: _contactsQueryFor(uid),
            physics: AlwaysScrollableScrollPhysics(),
            isLive: true,
            shrinkWrap: true,
            itemBuilder: (context, snap, index) {
              try {
                final raw = snap[index].data() as Map<String, dynamic>?;
                if (kDebugMode) {
                  developer.log('[ChatListScreen] itemBuilder index=$index '
                      'snapId="${snap[index].id}" '
                      'rawKeys="${raw?.keys.toList() ?? []}"');
                }

                final uidStr = (raw?['uid']?.toString() ?? '').validate();
                final contactUid =
                    uidStr.isNotEmpty ? uidStr : snap[index].id;
                if (kDebugMode) {
                  developer.log(
                      '[ChatListScreen] itemBuilder resolved contactUid="$contactUid"');
                }
                return UserItemWidget(
                  key: ValueKey<String>('chat_row_$contactUid'),
                  userUid: contactUid.validate(),
                );
              } catch (e, st) {
                developer.log(
                  '[ChatListScreen] itemBuilder parse error at index=$index '
                  'snapId="${snap[index].id}" error="$e"',
                  stackTrace: st,
                );
                return const SizedBox.shrink();
              }
            },
            initialLoader: LoaderWidget(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 10),
            padding: EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 0),
            limit: PER_PAGE_CHAT_LIST_COUNT,
            separatorBuilder: (_, i) =>
                Divider(height: 0, indent: 82, color: context.dividerColor),
            viewType: ViewType.list,
            onEmpty: Builder(
              builder: (context) {
                developer.log(
                  '[ChatListScreen] Chat list is empty for uid="$uid"',
                );
                return NoDataWidget(
                  title: languages.noConversation,
                  subTitle: languages.noConversationSubTitle,
                  imageWidget: EmptyStateWidget(),
                ).paddingSymmetric(horizontal: 16);
              },
            ),
          );
        },
      ),
    );
  }
}
