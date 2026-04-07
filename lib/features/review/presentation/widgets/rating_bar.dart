import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final Function(double)? onRatingUpdate;

  const RatingBar({
    super.key,
    required this.rating,
    this.size = 20,
    this.color = Colors.amber,
    this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: onRatingUpdate != null ? () => onRatingUpdate!(index + 1.0) : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: color,
            size: size,
          ),
        );
      }),
    );
  }
}
