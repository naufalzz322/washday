import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

class ShopSettingsScreen extends StatefulWidget {
  const ShopSettingsScreen({super.key});

  @override
  State<ShopSettingsScreen> createState() => _ShopSettingsScreenState();
}

class _ShopSettingsScreenState extends State<ShopSettingsScreen> {
  final _stampThreshold = TextEditingController(text: '10');
  final _loyaltyPercent = TextEditingController(text: '50');
  final _weightCap = TextEditingController(text: '5');
  final _orderExpiry = TextEditingController(text: '48');
  final _pickupReminder = TextEditingController(text: '3');
  final _unclaimedDays = TextEditingController(text: '30');

  String? _feedback;
  bool _error = false;

  @override
  void dispose() {
    _stampThreshold.dispose();
    _loyaltyPercent.dispose();
    _weightCap.dispose();
    _orderExpiry.dispose();
    _pickupReminder.dispose();
    _unclaimedDays.dispose();
    super.dispose();
  }

  void _save() {
    final threshold = int.tryParse(_stampThreshold.text.trim());
    final percent = int.tryParse(_loyaltyPercent.text.trim());
    final cap = double.tryParse(_weightCap.text.replaceAll(',', '.').trim());
    final expiry = int.tryParse(_orderExpiry.text.trim());
    final reminder = int.tryParse(_pickupReminder.text.trim());
    final unclaimed = int.tryParse(_unclaimedDays.text.trim());

    final valid =
        threshold != null &&
        threshold > 0 &&
        percent != null &&
        percent >= 0 &&
        percent <= 100 &&
        cap != null &&
        cap >= 0 &&
        expiry != null &&
        expiry > 0 &&
        reminder != null &&
        reminder > 0 &&
        unclaimed != null &&
        unclaimed > 0;

    setState(() {
      _error = !valid;
      _feedback = valid
          ? 'Settings saved.'
          : 'Check the values above. Use whole numbers for orders, hours and days.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WashdayPage(
      gap: 12,
      topPadding: 10,
      bottomClearance: 112,
      children: [
        const WashdayPageHeading(
          kicker: 'Rules',
          title: 'Shop settings',
          subtitle: 'Loyalty and order timing rules.',
          dense: true,
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WashdayKicker('Owner'),
              const SizedBox(height: 5),
              Text('Loyalty rules', style: WashdayType.title(size: 19)),
              const SizedBox(height: 13),
              WashdayField(
                label: 'Completed orders per reward',
                controller: _stampThreshold,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() => _feedback = null),
              ),
              const SizedBox(height: 5),
              Text(
                'Changing this threshold affects every customer’s balance.',
                style: WashdayType.muted(size: 11, height: 1.5),
              ),
              const SizedBox(height: 12),
              WashdayField(
                label: 'Reward discount (%)',
                controller: _loyaltyPercent,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() => _feedback = null),
              ),
              const SizedBox(height: 12),
              WashdayField(
                label: 'Weight cap (kg)',
                controller: _weightCap,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() => _feedback = null),
              ),
            ],
          ),
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Order timing', style: WashdayType.title(size: 19)),
              const SizedBox(height: 13),
              WashdayField(
                label: 'Ordered expiry window (hours)',
                controller: _orderExpiry,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() => _feedback = null),
              ),
              const SizedBox(height: 12),
              WashdayField(
                label: 'Ready pickup reminder (days)',
                controller: _pickupReminder,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() => _feedback = null),
              ),
              const SizedBox(height: 12),
              WashdayField(
                label: 'Unclaimed policy period (days)',
                controller: _unclaimedDays,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() => _feedback = null),
              ),
              const SizedBox(height: 14),
              WashdayButton(label: 'Save settings', onPressed: _save),
              if (_feedback != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
                  decoration: BoxDecoration(
                    color: _error
                        ? WashdayColors.red100
                        : WashdayColors.teal100,
                    borderRadius: BorderRadius.circular(WashdayRadii.control),
                    border: Border.all(
                      color: _error
                          ? WashdayColors.red500
                          : WashdayColors.teal200,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _error
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 15,
                        color: _error
                            ? WashdayColors.red500
                            : WashdayColors.teal700,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          _feedback!,
                          style: WashdayType.style(
                            size: 12,
                            weight: 580,
                            color: _error
                                ? WashdayColors.red500
                                : WashdayColors.teal900,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const WashdayNotice(
          title: 'Shop policy',
          body:
              'These values apply to new orders, pickup reminders and unclaimed items.',
        ),
      ],
    );
  }
}
