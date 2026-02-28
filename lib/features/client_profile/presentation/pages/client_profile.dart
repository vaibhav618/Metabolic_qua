import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../common/screens/network_image_viewer.dart';
import '../../data/services/client_update_profile_service.dart';

class ClientProfileScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const ClientProfileScreen({super.key, required this.clientProfileModel});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // keep a mutable copy so UI can refresh after updates
  late ClientProfileModel _profile;

  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();

    _profile = widget.clientProfileModel;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    // Default blue background with light icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF308BF9),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _scrollController.addListener(() {
      final collapseOffset = 200;
      if (_scrollController.offset > collapseOffset) {
        // Collapsed → white background + dark icons
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
          ),
        );
      } else {
        // Expanded → blue background + light icons
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Color(0xFF308BF9),
            statusBarIconBrightness: Brightness.light,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }


  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile refreshed")),
    );
  }

  Future<void> _editField({
    required String label,
    required String keyName, // 'phone_no','email','age','height','weight','region','location','gender'
    required String currentValue,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final initialValue = (currentValue == 'NA' ? '' : currentValue).trim();
    final controller = TextEditingController(text: initialValue);

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,          // allow sheet to grow under keyboard
      useSafeArea: true,                 // avoid notches
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.decelerate,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom, // <-- key line
          ),
          child: SingleChildScrollView(
            // lets content move above keyboard instead of being clipped
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Update $label',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => FocusScope.of(ctx).unfocus(),
                    decoration: InputDecoration(
                      hintText: 'Enter $label',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );


    // User dismissed or no change/invalid (button disabled), nothing to do
    if (result == null) return;

    // (Optional) extra safety checks on the caller side
    if (result.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Value cannot be empty')),
      );
      return;
    }
    if (keyName == 'email' && !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(result)&& mounted)  {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email')),
      );
      return;
    }
    if ((keyName == 'age' || keyName == 'height' || keyName == 'weight')
        && int.tryParse(result) == null&& mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label must be a number')),
      );
      return;
    }

    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saving...')));
    final updated = await ClientUpdateProfileService.updateProfile(
      profileId: _profile.profileId,
      updates: {keyName: result},
    );

    if (!mounted) return;
    if (updated != null) {
      setState(() => _profile = updated);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update failed')));
    }
  }


  Widget _buildInfoCard(String label, String value, IconData icon,bool isEditable,
      {VoidCallback? onEdit}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(

        decoration: ShapeDecoration(
          color: const Color(0xFFF0F0F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: -0.24,

                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value == "NA" ? "add ${label.toLowerCase()}" : value,
                      style: GoogleFonts.poppins(
                        color: isEditable ?  Color(0xFF252525) : const Color(0xFF959595),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.30,
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: isEditable,
                child: IconButton(
                  icon: Icon(Icons.edit,  size: 20),
                  tooltip: 'Edit $label',
                  onPressed: onEdit,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {


    final profile = _profile;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController, // 👈 attach controller

            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                expandedHeight: 300,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                shadowColor:const Color(0xFFF0F0F0),
                elevation: 1,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
                    final t = ((constraints.maxHeight - collapsedHeight) /
                        (300 - collapsedHeight))
                        .clamp(0.0, 1.0);
                    return FlexibleSpaceBar(
                      titlePadding:  EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      title: Row(
                        children: [
                          Transform.scale(
                            scale: 1 - 0.3 * t,
                            child: Opacity(
                              opacity: 1 - t,
                              child: CircleAvatar(radius: 16,backgroundImage: NetworkImage(profile.profileImage),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ClipRect(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              widthFactor: 1 - t,
                              child: Opacity(
                                opacity: 1 - t,
                                child: Text(
                                  profile.profileName,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: const Color(0xFF252525),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.50, 0.21),
                                end: Alignment(0.50, 1.14),
                                colors: [const Color(0xFF308BF9), const Color(0xFF2365B5)],
                              ),
                            ),
                          ),
                          Center(
                            child: Opacity(
                              opacity: t,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Scaffold(
                                            backgroundColor: Colors.black,
                                            body: Center(
                                              child: Hero(
                                                tag: "client-image",
                                                child: InteractiveViewer(
                                                  child: NetworkImageView(
                                                    url: profile.profileImage.isNotEmpty
                                                        ? profile.profileImage
                                                        : "https://via.placeholder.com/300", // fallback
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    borderRadius: 0,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Hero(
                                      tag: "client-image",
                                      child: CircleAvatar(
                                        radius: 70,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          radius: 70,
                                          backgroundImage: profile.profileImage.isNotEmpty
                                              ? NetworkImage(profile.profileImage)
                                              : const AssetImage('assets/images/default_avatar.png')
                                          as ImageProvider,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    profile.profileName,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding:const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList(

                  delegate: SliverChildListDelegate(
                    [
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: _buildInfoCard(
                              "Phone No",
                              profile.phoneNo,
                              Icons.phone,
                              false,
                              onEdit: () => _editField(
                                label: "Phone No",
                                keyName: 'phone_no',
                                currentValue: profile.phoneNo,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ),
                          SizedBox(height: 25,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: _buildInfoCard(
                              "Email",
                              profile.email,
                              Icons.email,
                              false,
                              onEdit: () => _editField(
                                label: "Email",
                                keyName: 'email',
                                currentValue: profile.email,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ),
                          SizedBox(height: 25,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: _buildInfoCard(
                              "Age",
                              profile.age,
                              Icons.cake,
                              true,
                              onEdit: () => _editField(
                                label: "Age",
                                keyName: 'age',
                                currentValue: profile.age,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),
                          SizedBox(height: 25,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: _buildInfoCard(
                              "Gender",
                              profile.gender,
                              Icons.wc,
                              true,
                              onEdit: () => _editField(
                                label: "Gender",
                                keyName: 'gender',
                                currentValue: profile.gender,
                              ),
                            ),
                          ),
                          SizedBox(height: 25,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: _buildInfoCard(
                              "Height",
                              "${profile.height} cm",
                              Icons.height,
                              true,
                              onEdit: () => _editField(
                                label: "Height (cm)",
                                keyName: 'height',
                                currentValue: profile.height,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),
                          SizedBox(height: 25,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: _buildInfoCard(
                              "Weight",
                              "${profile.weight} kg",
                              Icons.monitor_weight,
                              true,
                              onEdit: () => _editField(
                                label: "Weight (kg)",
                                keyName: 'weight',
                                currentValue: profile.weight,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),
                          SizedBox(height: 25,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: _buildInfoCard(
                              "Region",
                              profile.region,
                              Icons.location_city,
                              true,
                              onEdit: () => _editField(
                                label: "Region",
                                keyName: 'region',
                                currentValue: profile.region,
                              ),
                            ),
                          ),

                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
