import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  final String avatarUrl;
  final String username;
  final String? location;
  final String qrCodeUrl;

  const UserProfile({
    super.key,
    required this.avatarUrl,
    required this.username,
    required this.location,
    required this.qrCodeUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 300,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                avatarUrl,
                width: 50,
                height: 50,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        // QR code
        Image.network(
          qrCodeUrl,
          width: 300,
          height: 300,
        ),
        const SizedBox(height: 20),
        const Text(
          '扫一扫上面的二维码图案，加我为朋友。',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
