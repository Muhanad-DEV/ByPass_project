import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class UserTypeSelector extends StatelessWidget {
  final String selectedUserType;
  final Function(String) onUserTypeChanged;

  const UserTypeSelector({
    Key? key,
    required this.selectedUserType,
    required this.onUserTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildTypeOption(
            context,
            type: 'client',
            label: 'Customer',
            icon: Icons.person,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTypeOption(
            context,
            type: 'driver',
            label: 'Driver',
            icon: Icons.drive_eta,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption(
    BuildContext context, {
    required String type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedUserType == type;

    return GestureDetector(
      onTap: () => onUserTypeChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : AppConstants.lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppConstants.primaryColor : AppConstants.darkGrey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppConstants.primaryColor : AppConstants.darkGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
