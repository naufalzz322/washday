import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../data/orders_controller.dart';
import '../../shared/ui.dart';

class DashboardHero extends StatelessWidget {
  const DashboardHero({
    super.key,
    required this.kicker,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final String kicker;
  final String title;
  final String description;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return WashdayDeepCard(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WashdayKicker(kicker, color: const Color(0xB3FFFFFF)),
          const SizedBox(height: 7),
          Text(
            title,
            style: WashdayType.style(
              size: 27,
              weight: 680,
              color: Colors.white,
              height: 1.05,
              letterSpacing: -1.35,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: WashdayType.style(
              size: 12.5,
              weight: 480,
              color: const Color(0xCCFFFFFF),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: WashdayButton(
                  label: primaryLabel,
                  tone: WashdayButtonTone.onDark,
                  height: 44,
                  fontSize: 12.5,
                  radius: WashdayRadii.tile,
                  onPressed: onPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: WashdayButton(
                  label: secondaryLabel,
                  tone: WashdayButtonTone.onDarkQuiet,
                  height: 44,
                  fontSize: 12.5,
                  radius: WashdayRadii.tile,
                  onPressed: onSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardKpis extends StatelessWidget {
  const DashboardKpis({super.key, required this.metrics});

  final List<DashboardMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final valueSize = (width * 0.066).clamp(23.0, 27.0);
    final rows = <Widget>[];
    for (var index = 0; index < metrics.length; index += 2) {
      if (index > 0) rows.add(const Divider(height: 1));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Kpi(metric: metrics[index], valueSize: valueSize),
              ),
              Container(width: 1, color: WashdayColors.hairline),
              Expanded(
                child: index + 1 < metrics.length
                    ? _Kpi(metric: metrics[index + 1], valueSize: valueSize)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: WashdayColors.surfaceMuted,
        borderRadius: BorderRadius.circular(WashdayRadii.control),
        border: Border.all(color: WashdayColors.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.metric, required this.valueSize});

  final DashboardMetric metric;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: WashdayType.style(
              size: 10.5,
              weight: 620,
              color: WashdayColors.textSecondary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              metric.value,
              style: WashdayType.style(
                size: valueSize,
                weight: 680,
                color: WashdayColors.ink,
                height: 1,
                letterSpacing: valueSize * -0.055,
                tabularFigures: true,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            metric.note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: WashdayType.muted(size: 10, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class QueueLoadBars extends StatelessWidget {
  const QueueLoadBars({super.key, required this.items});

  final List<QueueLoad> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: index == 0
                  ? null
                  : const Border(
                      top: BorderSide(color: WashdayColors.hairline),
                    ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 82,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[index].label,
                        style: WashdayType.style(
                          size: 12.5,
                          weight: 640,
                          color: WashdayColors.ink,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${items[index].count} orders',
                        style: WashdayType.muted(size: 9.5, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(WashdayRadii.pill),
                    child: SizedBox(
                      height: 7,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const ColoredBox(color: WashdayColors.hairline),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (items[index].count / items[index].max)
                                .clamp(0.0, 1.0),
                            child: ColoredBox(
                              color: switch (items[index].tone) {
                                'red' => WashdayColors.red500,
                                'teal' => WashdayColors.teal600,
                                _ => WashdayColors.amber500,
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 20,
                  child: Text(
                    '${items[index].count}',
                    textAlign: TextAlign.right,
                    style: WashdayType.style(
                      size: 12.5,
                      weight: 680,
                      color: WashdayColors.ink,
                      tabularFigures: true,
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

class WeekSalesChart extends StatelessWidget {
  const WeekSalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    const max = 450.0;
    return SizedBox(
      height: 154,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < weekSales.length; index++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == weekSales.length - 1 ? 0 : 5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      weekSales[index].$2.toInt().toString(),
                      maxLines: 1,
                      style: WashdayType.muted(size: 8.5, height: 1.2),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 104,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: 26,
                          height: 104 * (weekSales[index].$2 / max),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: index == weekSales.length - 1
                                  ? WashdayColors.ink
                                  : WashdayColors.teal600,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(7),
                                bottom: Radius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      weekSales[index].$1,
                      style: WashdayType.style(
                        size: 9.5,
                        weight: index == weekSales.length - 1 ? 680 : 590,
                        color: index == weekSales.length - 1
                            ? WashdayColors.ink
                            : WashdayColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ServiceMixBars extends StatelessWidget {
  const ServiceMixBars({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < ownerServiceMix.length; index++)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 4 : 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ownerServiceMix[index].$1,
                        style: WashdayType.style(
                          size: 11.5,
                          weight: 600,
                          color: WashdayColors.inkSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '${ownerServiceMix[index].$2}%',
                      style: WashdayType.style(
                        size: 10.5,
                        weight: 620,
                        color: WashdayColors.textSecondary,
                        height: 1.2,
                        tabularFigures: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(WashdayRadii.pill),
                  child: SizedBox(
                    height: 7,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const ColoredBox(color: WashdayColors.hairline),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: ownerServiceMix[index].$2 / 100,
                          child: const ColoredBox(color: WashdayColors.teal600),
                        ),
                      ],
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

class RecentOrdersList extends ConsumerWidget {
  const RecentOrdersList({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider).orders.take(4).toList();
    return Column(
      children: [
        for (var index = 0; index < orders.length; index++)
          WashdayListRow(
            title: orders[index].id,
            subtitle: '${orders[index].customer} · ${orders[index].service}',
            trailing: WashdayStatusPill(
              orders[index].stage.label,
              tone: orders[index].stage == OrderStage.ready
                  ? WashdayTone.warning
                  : orders[index].isDeclined
                  ? WashdayTone.red
                  : WashdayTone.neutral,
            ),
            onTap: onTap,
            showTopBorder: index > 0,
            padding: const EdgeInsets.symmetric(vertical: 9),
          ),
      ],
    );
  }
}

class DashboardAlert extends StatelessWidget {
  const DashboardAlert({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    this.neutral = false,
    this.showTopBorder = true,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool neutral;
  final bool showTopBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: showTopBorder
            ? const Border(top: BorderSide(color: WashdayColors.hairline))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: neutral ? WashdayColors.teal100 : WashdayColors.amber100,
              borderRadius: BorderRadius.circular(WashdayRadii.tile),
            ),
            child: Icon(
              icon,
              size: 16,
              color: neutral ? WashdayColors.teal700 : WashdayColors.amber700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: WashdayType.style(
                    size: 12.5,
                    weight: 640,
                    color: WashdayColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(detail, style: WashdayType.muted(size: 10.5, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared section card used by both dashboards.
class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    super.key,
    required this.kicker,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String kicker;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return WashdayCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WashdaySectionHead(
            kicker: kicker,
            title: title,
            titleSize: 18,
            trailing: trailing,
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
