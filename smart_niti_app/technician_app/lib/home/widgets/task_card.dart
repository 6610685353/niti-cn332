import 'package:flutter/material.dart';
import '../../core/constants/app_color.dart';
import '../../work_order/screens/repairing.dart';
import '../../work_order/models/work.dart';

class TaskCard extends StatelessWidget {
  final WorkOrder workOrder;

  const TaskCard({required this.workOrder, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tagColor = workOrder.isUrgent ? Colors.red : Colors.blue;
    final bool needsAccept = !(workOrder.isAccepted ?? false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: needsAccept ? const Color(0xFFFED7AA) : AppColors.bgLight,
          width: needsAccept ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  workOrder.category,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (needsAccept)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: Color(0xFFEA580C),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                workOrder.id,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Text(
            workOrder.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  workOrder.scheduledTime,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  workOrder.location,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (!(workOrder.isAccepted ?? false)) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Accepted ${workOrder.id}'),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: Colors.white,
          ),
          label: const Text(
            'Accept Job',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RepairingScreen(workOrder: workOrder),
            ),
          );
        },
        icon: const Icon(
          Icons.edit_outlined,
          size: 18,
          color: AppColors.textDark2,
        ),
        label: const Text(
          'Update your progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark2,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bgLight2,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
