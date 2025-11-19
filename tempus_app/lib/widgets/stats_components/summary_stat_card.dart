import 'package:flutter/material.dart';

class SummaryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final List<Color> iconColors;
  final List<Color> barColors;
  final IconData icon;

  const SummaryStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconColors,
    required this.barColors,
    this.icon = Icons.star,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.00, 0.00),
          end: Alignment(1.00, 1.00),
          colors: [Color(0xCC171717), Color(0xCC0A0A0A)],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x19FFFEFE)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Positioned(
            child: Container(
              width: double.infinity,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.00, 0.50),
                  end: Alignment(1.00, 0.50),
                  colors: barColors,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Ícone e Ação
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(12),
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, 0.00),
                    end: Alignment(1.00, 1.00),
                    colors: iconColors,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: barColors.last.withOpacity(0.8),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Color(0xFFA0A0A0),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Título
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFA0A0A0),
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 8),
          // Valor
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFF4F4F4),
              fontSize: 26,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w600,
              height: 1.50,
            ),
          ),
        ],
      ),
    );
  }
}