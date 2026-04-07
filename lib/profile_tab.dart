import 'package:flutter/material.dart';
import 'splash_screen.dart';

class ProfileTab extends StatefulWidget {
  final String username;
  final Function(String) onUsernameChanged;

  const ProfileTab({super.key, required this.username, required this.onUsernameChanged});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late String _localUsername;

  @override
  void initState() {
    super.initState();
    _localUsername = widget.username;
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.username != oldWidget.username) {
      _localUsername = widget.username;
    }
  }

//Modal pop up
  Future<void> _showEditModal(BuildContext context) async {
    TextEditingController modalController = TextEditingController(text: _localUsername);

    return showDialog(
      context: context,
      barrierColor: Colors.black87, 
      useSafeArea: false,
      builder: (BuildContext context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
          child: Scaffold(
            backgroundColor: Colors.transparent, 
            resizeToAvoidBottomInset: false, 
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                    Image.asset(
                      'assets/usernameModal.png',
                      width: 450, 
                      fit: BoxFit.contain,
                    ),

                    Positioned(
                      top: 50, 
                      left: 180,
                      right: 50,
                      child: Material(
                        color: Colors.transparent,
                        child: TextField(
                          controller: modalController,
                          autofocus: true,
                          textAlign: TextAlign.left, 
                          style: const TextStyle(
                            color: Color(0xFF542E2E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50, 
                      left: 70,  
                      child: BouncingButton(
                        onPressed: () {
                          Navigator.of(context).pop(); 
                        },
                        child: Image.asset(
                          'assets/cancel-btn.png',
                          width: 140, 
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50, 
                      right: 70, 
                      child: BouncingButton(
                        onPressed: () {
                          if (modalController.text.trim().isNotEmpty) {
                            setState(() {
                              _localUsername = modalController.text.trim();
                            });
                            widget.onUsernameChanged(_localUsername);
                            Navigator.of(context).pop(); 
                          }
                        },
                        child: Image.asset(
                          'assets/confirm-btn.png',
                          width: 140, 
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ), 
              ),
            ],
          ),
        ), 
        );
      },
    );
  }

//displaySettings contents
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.15, -0.2), 
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            'assets/username-edit.png',
            width: 320, 
            fit: BoxFit.contain,
          ),
          Positioned(
            left: 100, 
            top: 24,  
            child: Text(
              _localUsername,
              style: const TextStyle(
                color: Color(0xFF542E2E),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 250, 
            top: 11,    
            child: BouncingButton(
              onPressed: () {
                _showEditModal(context);
              },
              child: Image.asset(
                'assets/edit-btn.png',
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
