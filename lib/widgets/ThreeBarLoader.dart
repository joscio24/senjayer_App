import 'package:flutter/material.dart';

class ThreeBarLoader extends StatefulWidget {
  const ThreeBarLoader({super.key});

  @override
  _ThreeBarLoaderState createState() => _ThreeBarLoaderState();
}

class _ThreeBarLoaderState extends State<ThreeBarLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 20, end: 50).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.2, 1.0, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      width: 12,
                      height: _animations[index].value,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 238, 238, 238),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
