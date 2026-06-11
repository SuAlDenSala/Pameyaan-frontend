import 'package:flutter/material.dart';

class StarRater extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double starSize;

  const StarRater({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 45.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          // 🔥 onTapDown guarantees it works inside modals and scrolls
          onTapDown: (_) {
            onRatingChanged(starValue);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: Icon(
              starValue <= rating ? Icons.star : Icons.star_border,
              color: starValue <= rating ? Colors.amber : Colors.grey.shade400,
              size: starSize,
            ),
          ),
        );
      }),
    );
  }
}
