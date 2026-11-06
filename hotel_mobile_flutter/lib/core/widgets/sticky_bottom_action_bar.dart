import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StickyBottomActionBar extends StatelessWidget {
  final Widget? leading;
  final String buttonText;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? buttonColor;

  const StickyBottomActionBar({
    super.key,
    this.leading,
    required this.buttonText,
    required this.onPressed,
    this.isLoading = false,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (leading != null) ...[
                Expanded(child: leading!),
                const SizedBox(width: 16),
              ],
              Expanded(
                flex: leading != null ? 1 : 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor ?? AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

