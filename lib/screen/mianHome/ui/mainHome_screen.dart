import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constant/app_color.dart';
import '../../../router/routes.dart';
import '../../chat/ui/chat_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeView();
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColor.royalBlue,
        title: Text(
          'Chat App',
          style: TextStyle(
            color: AppColor.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return IconButton(
                onPressed:
                    state.isLoading
                        ? null
                        : () {
                          context.read<HomeBloc>().add(LogoutEvent());
                          context.go(Routes.signIn);
                        },
                icon: const Icon(Icons.logout, color: Colors.white),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  context.read<HomeBloc>().add(SearchUserEvent(value));
                },
                decoration: InputDecoration(
                  hintText: "Search users...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),

          Expanded(
            child: BlocConsumer<HomeBloc, HomeState>(
              listener: (context, state) {
                if (state.error.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${state.error}")),
                  );
                }

                if (state.openedChatId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatScreen(
                            chatId: state.openedChatId,
                            userName: state.openedUserName,
                            userId: state.openedUserId,
                            userAvatarUrl: state.openedUserAvatar,
                          ),
                    ),
                  );

                  context.read<HomeBloc>().add(ResetOpenedChatEvent());
                }
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.filteredUsers.isEmpty) {
                  return const Center(
                    child: Text(
                      "No users found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is OverscrollNotification &&
                        notification.overscroll < 0) {
                      context.read<HomeBloc>().add(LoadUsersEvent());
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    itemCount: state.filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = state.filteredUsers[index];
                      final name = user["fullName"] ?? "Unknown User";
                      final avatarUrl = user["avatarUrl"] ?? "";
                      final userId = user["id"];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.h),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          leading: CircleAvatar(
                            radius: 26.r,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage:
                                avatarUrl.isNotEmpty
                                    ? NetworkImage(avatarUrl)
                                    : null,
                            child:
                                avatarUrl.isEmpty
                                    ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 28,
                                    )
                                    : null,
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            user["lastMessage"]?.isNotEmpty == true
                                ? (user["lastMessageSender"] ==
                                        context
                                            .read<HomeBloc>()
                                            .homeService
                                            .currentUserId
                                    ? "You: ${user["lastMessage"]}"
                                    : user["lastMessage"])
                                : "No messages yet",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                          onTap: () {
                            context.read<HomeBloc>().add(
                              OpenChatEvent(userId, name, avatarUrl),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
