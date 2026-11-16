import 'package:flutter/material.dart';

import '../app/theme.dart';

class WashdayOrderDock extends StatelessWidget {
  const WashdayOrderDock({
    super.key,
    required this.onTap,
    this.label = 'New order',
  });

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Start a new order',
      child: SizedBox(
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: WashdayColors.ink,
            borderRadius: BorderRadius.circular(WashdayRadii.pill),
            border: Border.all(color: const Color(0x14FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E0C1A23),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(WashdayRadii.pill),
              onTap: onTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 58),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: WashdayType.style(
                        size: 14.5,
                        weight: 650,
                        color: Colors.white,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    bottom: 7,
                    child: Container(
                      width: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_outward_rounded,
                        size: 19,
                        color: WashdayColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
