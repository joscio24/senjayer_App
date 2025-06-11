import 'package:flutter/material.dart';
import 'package:senjayer/app/core/theme.dart';

class CustomLoader extends StatefulWidget {
  const CustomLoader({super.key});

  @override
  _CustomLoaderState createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
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

    _animations = List.generate(5, (index) {
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
    return Container(
      padding: EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.5,
      alignment: Alignment.center,
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
              color:  appTheme.appViolet,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: index == 3? 20: 12,
                    height: _animations[index].value,
                    decoration: BoxDecoration(
                      color:
                          index == 3
                              ? const Color.fromARGB(255, 255, 89, 0) // Change second-to-last bar color
                              :  appTheme.appViolet,
                      borderRadius: index == 3 ? BorderRadius.circular(25): BorderRadius.circular(5),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
