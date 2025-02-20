import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_state.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/custom_bottom_navigation_bar.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/dashboard_content.dart';

class CustomerDashboardView extends StatefulWidget {
  final String userName;

  const CustomerDashboardView({super.key, required this.userName});

  @override
  CustomerDashboardViewState createState() => CustomerDashboardViewState();
}

class CustomerDashboardViewState extends State<CustomerDashboardView> {
  late final CustomerDashboardBloc _bloc;

  @override
  void initState() {
    super.initState();
    // Retrieve the bloc instance via DI (GetIt)
    _bloc = GetIt.I<CustomerDashboardBloc>()..add(LoadRestaurantsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        body: BlocConsumer<CustomerDashboardBloc, CustomerDashboardState>(
          listener: (context, state) {
            if (state is CustomerDashboardError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.red.shade800,
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return DashboardContent(
              state: state,
              userName: widget.userName,
            );
          },
        ),
        bottomNavigationBar: const CustomBottomNavigationBar(),
      ),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }
}










// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get_it/get_it.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tottouchordertastemobileapplication/features/customer/customer_profile.dart';
// import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
// import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';
// import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_state.dart';

// class CustomerDashboardView extends StatefulWidget {
//   final String userName;

//   const CustomerDashboardView({
//     super.key,
//     required this.userName,
//   });

//   @override
//   _CustomerDashboardViewState createState() => _CustomerDashboardViewState();
// }

// class _CustomerDashboardViewState extends State<CustomerDashboardView> {
//   late CustomerDashboardBloc _bloc;

//   @override
//   void initState() {
//     super.initState();
//     _bloc = GetIt.I<CustomerDashboardBloc>()
//       ..add(LoadRestaurantsEvent())
//       ..add(LoadProfileEvent(userName: widget.userName));
//   }

//   @override
//   void dispose() {
//     _bloc.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: _bloc,
//       child: BlocConsumer<CustomerDashboardBloc, CustomerDashboardState>(
//         listener: (context, state) {
//           if (state is CustomerDashboardError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//           }
//         },
//         builder: (context, state) {
//           return Scaffold(
//             body: _buildBody(context, state),
//             bottomNavigationBar: _buildBottomNavigationBar(context, state),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBody(BuildContext context, CustomerDashboardState state) {
//     if (state is CustomerDashboardLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (state is CustomerDashboardError) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Error: ${state.message}'),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 context.read<CustomerDashboardBloc>()
//                   ..add(LoadRestaurantsEvent())
//                   ..add(LoadProfileEvent(userName: widget.userName));
//               },
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (state is CustomerDashboardTabChanged) {
//       return _getPageForIndex(state.selectedIndex, context);
//     }

//     return _getPageForIndex(0, context);
//   }

//   Widget _getPageForIndex(int index, BuildContext context) {
//     switch (index) {
//       case 0:
//         return _buildRestaurantListScreen(context);
//       case 1:
//         return _buildCustomerProfileScreen(context);
//       default:
//         return _buildRestaurantListScreen(context);
//     }
//   }

//   Widget _buildRestaurantListScreen(BuildContext context) {
//     final state = context.watch<CustomerDashboardBloc>().state;

//     if (state is! RestaurantsLoaded) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Restaurants'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                     content: Text('Search functionality coming soon')),
//               );
//             },
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           context.read<CustomerDashboardBloc>().add(LoadRestaurantsEvent());
//         },
//         child: ListView.builder(
//           itemCount: state.restaurants.length,
//           itemBuilder: (context, index) {
//             final restaurant = state.restaurants[index];
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               child: ListTile(
//                 leading: const CircleAvatar(
//                   child: Icon(Icons.restaurant),
//                 ),
//                 title: Text(
//                   restaurant.restaurantName,
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//                 subtitle: Text(restaurant.location),
//                 trailing: const Icon(Icons.arrow_forward_ios),
//                 onTap: () {},
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomerProfileScreen(BuildContext context) {
//     final state = context.watch<CustomerDashboardBloc>().state;

//     if (state is! ProfileLoaded) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final profile = state.profile;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Profile')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Email: ${profile.email}',
//                 style: const TextStyle(fontSize: 16)),
//             Text('User Type: ${profile.role}',
//                 style: const TextStyle(fontSize: 16)),
//             Text(
//               'Email Verified: ${profile.isEmailVerified ? "Yes" : "No"}',
//               style: TextStyle(
//                   fontSize: 16,
//                   color: profile.isEmailVerified ? Colors.green : Colors.red),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// // Personal Information Card
//   Widget _buildPersonalInfoCard(BuildContext context, CustomerProfile profile) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Personal Information',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const Divider(),
//             _buildProfileInfoRow(
//               icon: Icons.person,
//               label: 'Username',
//               value: profile.username,
//             ),
//             _buildProfileInfoRow(
//               icon: Icons.email,
//               label: 'Email',
//               value: profile.email,
//             ),
//             _buildProfileInfoRow(
//               icon: Icons.phone,
//               label: 'Phone',
//               value: profile.phoneNumber ?? 'Not provided',
//             ),
//             _buildProfileInfoRow(
//               icon: Icons.verified,
//               label: 'Email Verified',
//               value: profile.isEmailVerified ? 'Yes' : 'No',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// // Account Details Card
//   Widget _buildAccountDetailsCard(
//       BuildContext context, CustomerProfile profile) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Account Details',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const Divider(),
//             _buildProfileInfoRow(
//               icon: Icons.calendar_today,
//               label: 'Joined',
//               value: _formatDate(profile.createdAt),
//             ),
//             _buildProfileInfoRow(
//               icon: Icons.update,
//               label: 'Last Updated',
//               value: _formatDate(profile.updatedAt),
//             ),
//             _buildProfileInfoRow(
//               icon: Icons.settings,
//               label: 'Role',
//               value: profile.role.toUpperCase(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// // Logout Button
//   Widget _buildLogoutButton(BuildContext context) {
//     return ElevatedButton.icon(
//       onPressed: () {
//         // Show confirmation dialog before logout
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Logout'),
//             content: const Text('Are you sure you want to logout?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   context.read<CustomerDashboardBloc>().add(
//                         const LogoutRequestedEvent(),
//                       );
//                 },
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 child: const Text('Logout'),
//               ),
//             ],
//           ),
//         );
//       },
//       icon: const Icon(Icons.logout),
//       label: const Text('Logout'),
//       style: ElevatedButton.styleFrom(
//         foregroundColor: Colors.white,
//         backgroundColor: Colors.red,
//         minimumSize: const Size(double.infinity, 50),
//       ),
//     );
//   }

// // Utility Methods
//   Widget _buildProfileInfoRow({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.blue),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     color: Colors.grey,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   Widget _buildProfilePictureSection(
//       BuildContext context, CustomerProfile profile) {
//     return GestureDetector(
//       onTap: () => _pickProfilePicture(context),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           CircleAvatar(
//             radius: 70,
//             backgroundImage:
//                 profile.profileImage != null && profile.profileImage!.isNotEmpty
//                     ? NetworkImage(profile.profileImage!)
//                     : null,
//             child: profile.profileImage == null || profile.profileImage!.isEmpty
//                 ? const Icon(Icons.person, size: 70)
//                 : null,
//           ),
//           Positioned(
//             bottom: 0,
//             right: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               padding: const EdgeInsets.all(8),
//               child: const Icon(
//                 Icons.camera_alt,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget _buildProfileInfoRow({
//   //   required IconData icon,
//   //   required String label,
//   //   required String value,
//   // }) {
//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(vertical: 8.0),
//   //     child: Row(
//   //       children: [
//   //         Icon(icon, color: Colors.blue),
//   //         const SizedBox(width: 12),
//   //         Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             Text(
//   //               label,
//   //               style: const TextStyle(
//   //                 color: Colors.grey,
//   //                 fontWeight: FontWeight.w500,
//   //               ),
//   //             ),
//   //             Text(
//   //               value,
//   //               style: const TextStyle(
//   //                 fontWeight: FontWeight.w600,
//   //                 fontSize: 16,
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // String _formatDate(DateTime date) {
//   //   return '${date.day}/${date.month}/${date.year}';
//   // }

//   Widget _buildProfilePicture(BuildContext context, CustomerProfile profile) {
//     return Stack(
//       children: [
//         CircleAvatar(
//           radius: 50,
//           backgroundImage:
//               profile.profileImage != null && profile.profileImage!.isNotEmpty
//                   ? NetworkImage(profile.profileImage!)
//                   : null,
//           child: profile.profileImage == null || profile.profileImage!.isEmpty
//               ? const Icon(Icons.person, size: 50)
//               : null,
//         ),
//         Positioned(
//           right: 0,
//           bottom: 0,
//           child: IconButton(
//             icon: const Icon(Icons.camera_alt),
//             onPressed: () => _pickProfilePicture(context),
//           ),
//         ),
//       ],
//     );
//   }

//   void _pickProfilePicture(BuildContext context) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (!mounted) return;

//     if (pickedFile != null) {
//       context.read<CustomerDashboardBloc>().add(
//             UpdateProfileEvent(
//               profilePicture: pickedFile.path,
//             ),
//           );
//     }
//   }

//   void _showProfileUpdateBottomSheet(
//       BuildContext context, CustomerProfile profile) {
//     final nameController =
//         TextEditingController(text: profile.displayName ?? '');
//     final emailController = TextEditingController(text: profile.email ?? '');
//     final phoneController =
//         TextEditingController(text: profile.phoneNumber ?? '');

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//           left: 16,
//           right: 16,
//           top: 16,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Name'),
//             ),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             TextField(
//               controller: phoneController,
//               decoration: const InputDecoration(labelText: 'Phone Number'),
//               keyboardType: TextInputType.phone,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 if (!mounted) return;

//                 context.read<CustomerDashboardBloc>().add(
//                       UpdateProfileEvent(
//                         name: nameController.text.isNotEmpty
//                             ? nameController.text
//                             : null,
//                         email: emailController.text.isNotEmpty
//                             ? emailController.text
//                             : null,
//                         phoneNumber: phoneController.text.isNotEmpty
//                             ? phoneController.text
//                             : null,
//                       ),
//                     );
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Update Profile'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileInfoCard(
//     BuildContext context, {
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const Divider(),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileField(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Colors.grey,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNavigationBar(
//     BuildContext context,
//     CustomerDashboardState state,
//   ) {
//     int currentIndex = 0;
//     if (state is CustomerDashboardTabChanged) {
//       currentIndex = state.selectedIndex;
//     }

//     return BottomNavigationBar(
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(Icons.restaurant),
//           label: 'Restaurants',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person),
//           label: 'Profile',
//         ),
//       ],
//       currentIndex: currentIndex,
//       selectedItemColor: Colors.orange,
//       onTap: (index) {
//         context.read<CustomerDashboardBloc>().add(ChangeTabEvent(index: index));
//       },
//     );
//   }
// }