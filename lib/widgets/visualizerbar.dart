import 'dart:math';
import 'package:flutter/material.dart';

class VisualizerBars extends StatefulWidget {
  final int barCount;
  final double maxHeight;
  final Color color;
  final bool animate;

  const VisualizerBars({
    super.key,
    this.barCount = 5,
    this.maxHeight = 30,
    this.color = Colors.greenAccent,
    this.animate = true,
  });

  @override
  State<VisualizerBars> createState() => _VisualizerBarsState();
}

class _VisualizerBarsState extends State<VisualizerBars> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  List<double> _barHeights = [];

  @override
  void initState() {
    super.initState();

    _barHeights = List.generate(widget.barCount, (_) => _random.nextDouble() * widget.maxHeight);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (widget.animate) {
      _controller.repeat();
    }

    _controller.addListener(() {
      setState(() {
        _barHeights = List.generate(widget.barCount, (_) => 10 + _random.nextDouble() * (widget.maxHeight - 10));
      });
    });
  }

  @override
  void didUpdateWidget(covariant VisualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBar(double height) {
    return Container(
      width: 3,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _barHeights.map((h) => _buildBar(h)).toList(),
    );
  }
}
