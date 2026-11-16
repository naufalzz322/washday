import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WashdayPage(
      bottomClearance: 112,
      onRefresh: WashdayRefresh.replay,
      children: [
        WashdayBackLink(
          label: 'Back',
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customer/home');
            }
          },
        ),
        const WashdayPageHeading(
          kicker: 'Updates',
          title: 'Notifications',
          subtitle: 'Updates about your laundry, in one place.',
        ),
        WashdayCard(
          padding: EdgeInsets.zero,
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 12),
                child: Row(
                  children: [
                    const Expanded(child: WashdayKicker('Recent')),
                    const SizedBox(width: 8),
                    const WashdayStatusPill('1 unread', showDot: true),
                  ],
                ),
              ),
              const Divider(height: 1),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/customer/orders/LDR-0042'),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                    child: Row(
                      children: [
                        const WashdayLeadingTile(
                          size: 40,
                          child: Icon(Icons.check_rounded, size: 19),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Your laundry is ready',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: WashdayType.strong(size: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: WashdayColors.red500,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Order LDR-0042 · Ready for pickup',
                                style: WashdayType.muted(size: 12, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: WashdayColors.slate400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
