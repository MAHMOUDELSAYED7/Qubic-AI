import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qubic_ai/core/themes/colors.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';

import '../../../core/utils/helper/regexp_methods.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.searchController,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController searchController;
  final Function(String) onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return BounceIn(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ColorManager.grey.withValues(alpha: 0.18),
            border: searchController.text.isNotEmpty
                ? Border.all(
                    color: ColorManager.purple,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  )
                : null),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                autocorrect: true,
                textInputAction: TextInputAction.search,
                textAlignVertical: TextAlignVertical.center,
                controller: searchController,
                style:
                    context.textTheme.bodyMedium?.copyWith(fontSize: 15.spMin),
                textDirection:
                    RegExpManager.getTextDirection(searchController.text),
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  hintText: 'Search chat history',
                ),
                onChanged: onChanged,
              ),
            ),
            _BuildSearchIcon(searchController: searchController, onClear: onClear),
          ],
        ),
      ).withAllPadding(4),
    );
  }
}

class _BuildSearchIcon extends StatelessWidget {
  const _BuildSearchIcon({
    required this.searchController,
    required this.onClear,
  });

  final TextEditingController searchController;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      duration: const Duration(milliseconds: 300),
      child: IconButton(
        key: ValueKey<bool>(searchController.text.isNotEmpty),
        icon: Icon(
            searchController.text.isEmpty ? Icons.search : Icons.close),
        color: searchController.text.isEmpty
            ? ColorManager.grey
            : ColorManager.white,
        onPressed: searchController.text.isNotEmpty
            ? onClear
            : () => FocusScope.of(context).unfocus(),
      ),
    );
  }
}
