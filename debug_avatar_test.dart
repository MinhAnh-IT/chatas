import 'package:flutter/material.dart';

/// Simple test widget to debug avatar image loading
class DebugAvatarTest extends StatelessWidget {
  const DebugAvatarTest({super.key});

  @override
  Widget build(BuildContext context) {
    // Test với một URL avatar thực tế từ profile
    const testAvatarUrl =
        'https://res.cloudinary.com/dzbo8ubol/image/upload/v1737956467/e6kcbbr7fjsqzfsznglt.jpg';

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Avatar Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Test Network Image Direct:'),
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(testAvatarUrl),
              onBackgroundImageError: (error, stackTrace) {
                print('Direct NetworkImage failed: $error');
              },
              child: const Text('F', style: TextStyle(fontSize: 30)),
            ),

            const SizedBox(height: 30),

            const Text('Test Image.network:'),
            const SizedBox(height: 10),
            ClipOval(
              child: Image.network(
                testAvatarUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Image.network failed: $error');
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey,
                    child: const Icon(Icons.error),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
