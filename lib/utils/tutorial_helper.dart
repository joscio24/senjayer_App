import 'package:flutter/material.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

Future<void> showAppTutorial({
  required BuildContext context,
  required List<GlobalKey> targets,
  required List<String> descriptions,
  VoidCallback? onFinish,
  VoidCallback? onSkip,
}) async {
  assert(targets.length == descriptions.length);

  int currentStep = 0;
  late TutorialCoachMark tutorial;

  // Function to build TargetFocus dynamically per step
  TargetFocus buildTarget(int index) {
    return TargetFocus(
      identify: "target_$index",
      keyTarget: targets[index],
      shape: ShapeLightFocus.RRect,
      radius: 12,
      enableOverlayTab: false,
      enableTargetTab: false,
      borderSide: const BorderSide(color: Colors.white, width: 1),
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder:
              (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        86,
                        86,
                        86,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                descriptions[index],
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.black26,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.next();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 18, color: Color.fromARGB(255, 255, 255, 255),),
                      label: const Text("Suivant"),
                    ),
                  ),
                ],
              ),
        ),
      ],
    );
  }

  // Recursive function to show steps
  Future<void> showStep(int index) async {
    if (index >= targets.length) {
      onFinish?.call();
      return;
    }

    await ensureWidgetVisible(targets[index]);
    await Future.delayed(const Duration(milliseconds: 300));

    tutorial = TutorialCoachMark(
      targets: [buildTarget(index)],
      colorShadow: Colors.black87,
      opacityShadow: 0.8,
      textSkip: "IGNORER",
      disableBackButton: false,
      paddingFocus: 8,
      onFinish: () => showStep(index + 1),
      onClickOverlay: (_) => showStep(index + 1),
      onClickTarget: (_) => showStep(index + 1),
      onSkip: () {
        onSkip?.call();
        return false; // prevent further steps
      },
    );

    tutorial.show(context: context);
  }

  await showStep(0);
}

Future<void> ensureWidgetVisible(
  GlobalKey key, {
  Duration duration = const Duration(milliseconds: 500),
}) async {
  final context = key.currentContext;
  if (context == null) return;

  try {
    await Scrollable.ensureVisible(
      context,
      alignment: 0.5,
      duration: duration,
      curve: Curves.easeInOut,
    );
  } catch (_) {
    debugPrint('⚠️ Widget not in a scrollable context — skipping scroll');
  }

  // Wait until it's fully built
  await Future.doWhile(() async {
    await Future.delayed(const Duration(milliseconds: 50));
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    return renderBox == null || !renderBox.attached;
  });
}
