import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TimeStatCard extends StatelessWidget {
  final String realTime;
  final String plannedTime;
  final String avgTime;
  final List<Color> iconColors;
  final List<Color> barColors;
  final IconData icon;

  const TimeStatCard({
    super.key,
    required this.realTime,
    required this.plannedTime,
    required this.avgTime,
    required this.iconColors,
    required this.barColors,
    this.icon = Icons.access_time,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = barColors.first;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TempusColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top accent bar
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: barColors),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: iconColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                          ),
                        ),
                        child: Center(
                          child: Icon(icon, color: accentColor, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Visão Geral de Tempo',
                        style: TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 13,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      _buildStatColumn('Tempo Real', realTime),
                      Container(
                        width: 1,
                        height: 40,
                        color: TempusColors.border,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      _buildStatColumn('Planejado', plannedTime),
                      Container(
                        width: 1,
                        height: 40,
                        color: TempusColors.border,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      _buildStatColumn('Média/Sessão', avgTime),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: TempusColors.textSub,
              fontSize: 11,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: TempusColors.text,
              fontSize: 20,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
