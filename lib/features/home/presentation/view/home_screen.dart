import 'dart:async';
import 'package:flutter/material.dart';

enum DotColor { red, blue, green }

Color baseColor(DotColor c) {
  switch (c) {
    case DotColor.red:
      return Colors.red;
    case DotColor.blue:
      return Colors.blue;
    case DotColor.green:
      return Colors.green;
  }
}

Color paleColor(DotColor c) {
  switch (c) {
    case DotColor.red:
      return Colors.red.shade200;
    case DotColor.blue:
      return Colors.blue.shade200;
    case DotColor.green:
      return Colors.green.shade200;
  }
}

class ColorDotDraggable extends StatelessWidget {
  const ColorDotDraggable({
    super.key,
    required this.colorKey,
    this.radius = 30,
  });

  final DotColor colorKey;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Draggable<DotColor>(
      data: colorKey,
      feedback: Material(
        type: MaterialType.transparency,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: baseColor(colorKey),
        ),
      ),
      childWhenDragging: CircleAvatar(
        radius: radius,
        backgroundColor: paleColor(colorKey),
      ),
      child: CircleAvatar(radius: radius, backgroundColor: baseColor(colorKey)),
    );
  }
}

class TargetState {
  final DotColor expected;
  bool isFilled;
  bool wrongFlash;

  TargetState({
    required this.expected,
    this.isFilled = false,
    this.wrongFlash = false,
  });
}

class ColorTargetTile extends StatelessWidget {
  const ColorTargetTile({
    super.key,
    required this.state,
    required this.size,
    required this.onAccept,
  });

  final TargetState state;
  final double size;
  final void Function(DragTargetDetails<DotColor> details) onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<DotColor>(
      onWillAcceptWithDetails: (details) => !state.isFilled,
      onAcceptWithDetails: onAccept,
      builder:
          (
            BuildContext context,
            List<DotColor?> candidateData,
            List<dynamic> rejectedData,
          ) {
            final hasCandidate = candidateData.isNotEmpty;
            final DotColor? dragging = hasCandidate
                ? candidateData.first
                : null;

            final bool isWrongHover =
                hasCandidate && dragging != state.expected;

            final Color bg = state.isFilled
                ? baseColor(state.expected)
                : paleColor(state.expected);

            final Color borderColor = state.wrongFlash
                ? Colors.redAccent
                : baseColor(state.expected);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 4),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (state.isFilled)
                    const Icon(Icons.done, color: Colors.white, size: 36),
                  if (!state.isFilled && isWrongHover)
                    const Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                      size: 30,
                    ),
                ],
              ),
            );
          },
    );
  }
}

class Challenge3HomeScreen extends StatefulWidget {
  const Challenge3HomeScreen({super.key});

  @override
  State<Challenge3HomeScreen> createState() => _Challenge3HomeScreenState();
}

class _Challenge3HomeScreenState extends State<Challenge3HomeScreen> {
  late final List<TargetState> targets;

  @override
  void initState() {
    super.initState();
    targets = [
      TargetState(expected: DotColor.red),
      TargetState(expected: DotColor.blue),
      TargetState(expected: DotColor.green),
    ];
  }

  void _handleAccept(int index, DotColor data) {
    final t = targets[index];
    if (t.isFilled) return;

    if (data == t.expected) {
      setState(() => t.isFilled = true);
    } else {
      setState(() => t.wrongFlash = true);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (!mounted) return;
        setState(() => t.wrongFlash = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double targetSize = MediaQuery.of(context).size.width * 0.28;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Physics Playground'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                ColorDotDraggable(colorKey: DotColor.red),
                ColorDotDraggable(colorKey: DotColor.blue),
                ColorDotDraggable(colorKey: DotColor.green),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(targets.length, (i) {
                return ColorTargetTile(
                  state: targets[i],
                  size: targetSize,
                  // ✅ unwrap details.data here
                  onAccept: (details) => _handleAccept(i, details.data),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
