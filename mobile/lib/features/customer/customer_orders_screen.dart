import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/clock.dart';
import '../../data/models.dart';
import '../../data/orders_controller.dart';
import '../../data/session_controller.dart';
import '../../shared/page.dart';
import '../../shared/ui.dart';

enum _DateScope { any, today, last7, last30, custom }

enum _RangeField { start, end }

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _fullMonthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

DateTime _dayOf(DateTime date) => DateTime(date.year, date.month, date.day);

String _dayKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _shortDate(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]}';

class _OrderDateFilter {
  const _OrderDateFilter.any() : scope = _DateScope.any, range = null;

  const _OrderDateFilter.preset(this.scope) : range = null;

  const _OrderDateFilter.range(DateTimeRange this.range)
    : scope = _DateScope.custom;

  final _DateScope scope;
  final DateTimeRange? range;

  bool get isActive => scope != _DateScope.any;

  String get label {
    return switch (scope) {
      _DateScope.any => 'Any date',
      _DateScope.today => 'Today',
      _DateScope.last7 => 'Last 7 days',
      _DateScope.last30 => 'Last 30 days',
      _DateScope.custom =>
        range == null ? 'Custom range' : _customLabel(range!),
    };
  }

  String _customLabel(DateTimeRange value) {
    final start = _dayOf(value.start);
    final end = _dayOf(value.end);
    if (start == end) return _shortDate(start);
    return '${_shortDate(start)} – ${_shortDate(end)}';
  }

  bool includes(DateTime? date, DateTime todayRaw) {
    if (scope == _DateScope.any) return true;
    if (date == null) return false;

    final day = _dayOf(date);
    final today = _dayOf(todayRaw);

    return switch (scope) {
      _DateScope.any => true,
      _DateScope.today => day == today,
      _DateScope.last7 =>
        !day.isBefore(today.subtract(const Duration(days: 6))) &&
            !day.isAfter(today),
      _DateScope.last30 =>
        !day.isBefore(today.subtract(const Duration(days: 29))) &&
            !day.isAfter(today),
      _DateScope.custom =>
        range != null &&
            !day.isBefore(_dayOf(range!.start)) &&
            !day.isAfter(_dayOf(range!.end)),
    };
  }
}

class _OrderFilterSelection {
  const _OrderFilterSelection({required this.status, required this.dateFilter});

  final String status;
  final _OrderDateFilter dateFilter;
}

class CustomerOrdersScreen extends ConsumerStatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  ConsumerState<CustomerOrdersScreen> createState() =>
      _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends ConsumerState<CustomerOrdersScreen>
    with SingleTickerProviderStateMixin {
  static const _loadDuration = WashdayRefresh.duration;

  late final AnimationController _loadController;
  bool _loading = true;
  String _filter = 'all';
  _OrderDateFilter _dateFilter = const _OrderDateFilter.any();

  List<WashdayOrder> get _ownOrders {
    final customerId = ref.watch(currentAccountProvider).customerId;
    return ref.watch(ordersProvider).forCustomer(customerId);
  }

  List<WashdayOrder> get _activeOrders =>
      _ownOrders.where((order) => order.isActive).toList();

  List<WashdayOrder> get _declinedOrders =>
      _ownOrders.where((order) => order.isDeclined).toList();

  List<WashdayOrder> get _collectedOrders =>
      _ownOrders.where((order) => order.isCollected).toList();

  DateTime get _today => ref.watch(washdayTodayProvider);

  List<WashdayOrder> get _visibleOrders => _ownOrders.where((order) {
    final matchesStatus = switch (_filter) {
      'active' => order.isActive,
      'declined' => order.isDeclined,
      'collected' => order.isCollected,
      _ => true,
    };
    return matchesStatus && _dateFilter.includes(order.datedOn, _today);
  }).toList();

  @override
  void initState() {
    super.initState();
    _loadController = AnimationController(vsync: this, duration: _loadDuration);
    _loadController.forward().then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _loadController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    setState(() => _loading = true);
    return _loadController.forward(from: 0).then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  void _clearFilters() {
    setState(() {
      _filter = 'all';
      _dateFilter = const _OrderDateFilter.any();
    });
  }

  Future<void> _openFilters() async {
    final selection = await showModalBottomSheet<_OrderFilterSelection>(
      context: context,
      // Layer above the shell so the floating order dock cannot cover the
      // lower sheet actions.
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (sheetContext) => _OrderFilterSheet(
        status: _filter,
        dateFilter: _dateFilter,
        today: _today,
      ),
    );
    if (!mounted || selection == null) return;

    setState(() {
      _filter = selection.status;
      _dateFilter = selection.dateFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ownOrders = _ownOrders;
    final activeOrders = _activeOrders;
    final declinedOrders = _declinedOrders;
    final cancelledOrders = ownOrders
        .where((order) => order.isCancelled)
        .toList();
    final collectedOrders = _collectedOrders;
    final visibleActive = activeOrders
        .where((order) => _dateFilter.includes(order.datedOn, _today))
        .toList();
    final visibleDeclined = declinedOrders
        .where((order) => _dateFilter.includes(order.datedOn, _today))
        .toList();
    final visibleCancelled = cancelledOrders
        .where((order) => _dateFilter.includes(order.datedOn, _today))
        .toList();
    final visibleCollected = collectedOrders
        .where((order) => _dateFilter.includes(order.datedOn, _today))
        .toList();
    final visibleOrders = _visibleOrders;
    final filtered = _filter != 'all' || _dateFilter.isActive;
    final showActive = _filter == 'all' || _filter == 'active';
    final showDeclined = _filter == 'all' || _filter == 'declined';
    final showCancelled = _filter == 'all';
    final showCollected = _filter == 'all' || _filter == 'collected';
    final groups = <(String, List<WashdayOrder>)>[
      if (showActive) ('In progress', visibleActive),
      if (showDeclined) ('Declined', visibleDeclined),
      if (showCancelled) ('Cancelled', visibleCancelled),
      if (showCollected) ('Collected', visibleCollected),
    ].where((group) => group.$2.isNotEmpty).toList();

    return WashdayPage(
      bottomClearance: 176,
      onRefresh: _refresh,
      children: [
        const WashdayPageHeading(
          kicker: 'Your laundry',
          title: 'Order history',
          subtitle: 'Your current and past laundry orders.',
        ),
        WashdayMetricStrip(
          metrics: [
            WashdayMetric(value: '${activeOrders.length}', label: 'Active'),
            WashdayMetric(
              value: '${collectedOrders.length}',
              label: 'Collected',
            ),
            WashdayMetric(value: '${ownOrders.length}', label: 'Total'),
          ],
        ),
        WashdayCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WashdaySectionHead(
                kicker: 'Filter',
                title: 'Your orders',
                titleSize: 18,
                trailing: WashdayCountPill(
                  _loading
                      ? 'Loading'
                      : filtered
                      ? '${visibleOrders.length} of ${ownOrders.length}'
                      : '${ownOrders.length} orders',
                ),
              ),
              const SizedBox(height: 11),
              _OrderStatusChipRow(
                filter: _filter,
                filterActive: filtered,
                onStatusSelected: (value) => setState(() => _filter = value),
                onFilterTapped: _openFilters,
              ),
              if (filtered) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_dateFilter.isActive) ...[
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _ActiveDateTag(
                            label: _dateFilter.label,
                            onRemove: () => setState(
                              () => _dateFilter = const _OrderDateFilter.any(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else
                      const Spacer(),
                    WashdayTextLink('Clear filters', onTap: _clearFilters),
                  ],
                ),
                const SizedBox(height: 4),
              ] else
                const SizedBox(height: 2),
              if (_loading)
                _OrdersSkeleton(animation: _loadController)
              else if (visibleOrders.isEmpty)
                _EmptyOrders(
                  filter: _filter,
                  dateFiltered: _dateFilter.isActive,
                  onClear: filtered ? _clearFilters : null,
                )
              else ...[
                for (var index = 0; index < groups.length; index++) ...[
                  if (index > 0) const SizedBox(height: 14),
                  _OrderGroup(
                    label: groups[index].$1,
                    orders: groups[index].$2,
                    onTap: (order) =>
                        context.push('/customer/orders/${order.id}'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterMenuButton extends StatelessWidget {
  const _FilterMenuButton({
    super.key,
    required this.active,
    required this.onTap,
  });

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: active ? 'Filters, active' : 'Filters',
      child: Tooltip(
        message: 'Filter orders',
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40,
            height: 38,
            decoration: BoxDecoration(
              color: active ? WashdayColors.teal100 : WashdayColors.white,
              borderRadius: BorderRadius.circular(WashdayRadii.pill),
              border: Border.all(
                color: active
                    ? WashdayColors.teal500
                    : WashdayColors.hairlineStrong,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: active
                      ? WashdayColors.teal700
                      : WashdayColors.inkSecondary,
                ),
                if (active)
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: WashdayColors.teal700,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrollable status chip row with left/right nudge buttons.
///
/// The status chips do not fit one line on narrow phones, so the row scrolls
/// and the arrow buttons page it in both directions.
class _OrderStatusChipRow extends StatefulWidget {
  const _OrderStatusChipRow({
    required this.filter,
    required this.filterActive,
    required this.onStatusSelected,
    required this.onFilterTapped,
  });

  final String filter;
  final bool filterActive;
  final ValueChanged<String> onStatusSelected;
  final VoidCallback onFilterTapped;

  @override
  State<_OrderStatusChipRow> createState() => _OrderStatusChipRowState();
}

class _OrderStatusChipRowState extends State<_OrderStatusChipRow> {
  static const _statusOptions = [
    ('all', 'All'),
    ('active', 'Active'),
    ('declined', 'Declined'),
    ('collected', 'Collected'),
  ];

  static const _scrollStep = 96.0;

  late final ScrollController _scrollController;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateArrowVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateArrowVisibility();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrowVisibility() {
    final position = _scrollController.position;
    if (!position.hasContentDimensions || !position.hasViewportDimension) {
      return;
    }
    final maxExtent = position.maxScrollExtent;
    final offset = position.pixels;
    final canLeft = offset > 1;
    final canRight = offset < maxExtent - 1;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  void _nudge(double direction) {
    final target = (_scrollController.offset + direction * _scrollStep).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _select(String value) {
    widget.onStatusSelected(value);
    final index = _statusOptions.indexWhere((option) => option.$1 == value);
    if (index < 0) return;
    // Ensure the selected chip is fully visible after the rebuild.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      const margin = 8.0;
      final start = index * (_scrollStep + 7) - margin;
      final end = start + _scrollStep + margin * 2;
      if (_scrollController.offset > start) {
        _scrollController.animateTo(
          start.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      } else if (_scrollController.offset +
              _scrollController.position.viewportDimension <
          end) {
        _scrollController.animateTo(
          (end - _scrollController.position.viewportDimension).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ScrollArrowButton(
          key: const Key('orders-status-left'),
          icon: Icons.chevron_left_rounded,
          enabled: _canScrollLeft,
          semanticLabel: 'Scroll status filters left',
          onTap: () => _nudge(-1),
        ),
        Expanded(
          child: SingleChildScrollView(
            key: const Key('orders-status-scroll'),
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in _statusOptions) ...[
                  WashdayFilterChip(
                    key: ValueKey('status-chip-${option.$1}'),
                    label: option.$2,
                    selected: widget.filter == option.$1,
                    onTap: () => _select(option.$1),
                  ),
                  const SizedBox(width: 7),
                ],
                _FilterMenuButton(
                  key: const Key('orders-filter-button'),
                  active: widget.filterActive,
                  onTap: widget.onFilterTapped,
                ),
              ],
            ),
          ),
        ),
        _ScrollArrowButton(
          key: const Key('orders-status-right'),
          icon: Icons.chevron_right_rounded,
          enabled: _canScrollRight,
          semanticLabel: 'Scroll status filters right',
          onTap: () => _nudge(1),
        ),
      ],
    );
  }
}

class _ScrollArrowButton extends StatelessWidget {
  const _ScrollArrowButton({
    super.key,
    required this.icon,
    required this.enabled,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 28,
          height: 38,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: enabled ? WashdayColors.white : WashdayColors.surfaceMuted,
            borderRadius: BorderRadius.circular(WashdayRadii.pill),
            border: Border.all(
              color: enabled
                  ? WashdayColors.hairlineStrong
                  : WashdayColors.hairline,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? WashdayColors.inkSecondary
                : WashdayColors.textFaint,
          ),
        ),
      ),
    );
  }
}

class _ActiveDateTag extends StatelessWidget {
  const _ActiveDateTag({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Remove $label date filter',
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(WashdayRadii.pill),
        child: Container(
          constraints: const BoxConstraints(minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: WashdayColors.teal100,
            borderRadius: BorderRadius.circular(WashdayRadii.pill),
            border: Border.all(color: WashdayColors.teal500),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 14,
                color: WashdayColors.teal700,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WashdayType.style(
                    size: 11.5,
                    weight: 630,
                    color: WashdayColors.teal700,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.close_rounded,
                size: 14,
                color: WashdayColors.teal700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderFilterSheet extends StatefulWidget {
  const _OrderFilterSheet({
    required this.status,
    required this.dateFilter,
    required this.today,
  });

  final String status;
  final _OrderDateFilter dateFilter;
  final DateTime today;

  @override
  State<_OrderFilterSheet> createState() => _OrderFilterSheetState();
}

class _OrderFilterSheetState extends State<_OrderFilterSheet> {
  late String _status;
  late _OrderDateFilter _dateFilter;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
    _dateFilter = widget.dateFilter;
  }

  Future<void> _pickCustomRange() async {
    final picked = await showModalBottomSheet<DateTimeRange>(
      context: context,
      // Layer above the filter sheet and the floating order dock.
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (sheetContext) => _CustomRangeSheet(
        initialRange: _dateFilter.range,
        today: widget.today,
      ),
    );
    if (!mounted || picked == null) return;
    setState(() => _dateFilter = _OrderDateFilter.range(picked));
  }

  void _selectDate(_DateScope scope) {
    if (scope == _DateScope.custom) {
      _pickCustomRange();
      return;
    }
    setState(() {
      _dateFilter = switch (scope) {
        _DateScope.any => const _OrderDateFilter.any(),
        _DateScope.today => const _OrderDateFilter.preset(_DateScope.today),
        _DateScope.last7 => const _OrderDateFilter.preset(_DateScope.last7),
        _DateScope.last30 => const _OrderDateFilter.preset(_DateScope.last30),
        _DateScope.custom => _dateFilter,
      };
    });
  }

  void _reset() {
    setState(() {
      _status = 'all';
      _dateFilter = const _OrderDateFilter.any();
    });
  }

  void _apply() {
    Navigator.of(
      context,
    ).pop(_OrderFilterSelection(status: _status, dateFilter: _dateFilter));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    final customDetail =
        _dateFilter.scope == _DateScope.custom && _dateFilter.range != null
        ? _dateFilter.label
        : 'Choose a start and end date';
    final options = [
      (
        _DateScope.any,
        Icons.calendar_today_outlined,
        'Any date',
        'Show every order',
      ),
      (_DateScope.today, Icons.today_outlined, 'Today', 'Orders from today'),
      (
        _DateScope.last7,
        Icons.schedule_rounded,
        'Last 7 days',
        'Orders from this week',
      ),
      (
        _DateScope.last30,
        Icons.date_range_rounded,
        'Last 30 days',
        'Orders from the past month',
      ),
      (
        _DateScope.custom,
        Icons.edit_calendar_outlined,
        'Custom range',
        customDetail,
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      // Hug the content so the barrier above the sheet remains tappable.
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500, maxHeight: maxHeight),
          child: Container(
            decoration: BoxDecoration(
              color: WashdayColors.white,
              borderRadius: BorderRadius.circular(WashdayRadii.panel),
              border: Border.all(color: WashdayColors.hairline),
              boxShadow: const [
                BoxShadow(
                  color: WashdayColors.shadow,
                  blurRadius: 30,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: WashdayColors.dottedBorder,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const WashdayKicker('Filter'),
                  const SizedBox(height: 6),
                  Text('Filter orders', style: WashdayType.title(size: 22)),
                  const SizedBox(height: 14),
                  Text(
                    'Status',
                    style: WashdayType.style(
                      size: 12,
                      weight: 650,
                      color: WashdayColors.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final option in const [
                        ('all', 'All'),
                        ('active', 'Active'),
                        ('declined', 'Declined'),
                        ('collected', 'Collected'),
                      ])
                        WashdayFilterChip(
                          label: option.$2,
                          selected: _status == option.$1,
                          onTap: () => setState(() => _status = option.$1),
                        ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: WashdayColors.hairline,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Date',
                    style: WashdayType.style(
                      size: 12,
                      weight: 650,
                      color: WashdayColors.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (var index = 0; index < options.length; index++)
                    _FilterDateOption(
                      key: ValueKey('date-filter-${options[index].$1.name}'),
                      option: options[index],
                      selected: _dateFilter.scope == options[index].$1,
                      showTopBorder: index > 0,
                      onTap: () => _selectDate(options[index].$1),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: WashdayButton(
                          label: 'Reset',
                          tone: WashdayButtonTone.secondary,
                          height: 46,
                          fontSize: 13.5,
                          onPressed: _reset,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: WashdayButton(
                          label: 'Apply filters',
                          height: 46,
                          fontSize: 13.5,
                          onPressed: _apply,
                          key: const Key('orders-filter-apply'),
                        ),
                      ),
                    ],
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

class _CustomRangeSheet extends StatefulWidget {
  const _CustomRangeSheet({required this.initialRange, required this.today});

  final DateTimeRange? initialRange;
  final DateTime today;

  @override
  State<_CustomRangeSheet> createState() => _CustomRangeSheetState();
}

class _CustomRangeSheetState extends State<_CustomRangeSheet> {
  late DateTime _month;
  DateTime? _start;
  DateTime? _end;
  _RangeField _activeField = _RangeField.start;

  DateTime get _today => _dayOf(widget.today);

  DateTime get _firstDate => DateTime(_today.year, 1, 1);

  DateTimeRange? get _range {
    final start = _start;
    final end = _end;
    if (start == null || end == null) return null;
    return DateTimeRange(start: start, end: end);
  }

  bool get _hasSelection => _start != null || _end != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRange;
    if (initial == null) {
      _month = DateTime(_today.year, _today.month, 1);
      return;
    }
    _start = _dayOf(initial.start);
    _end = _dayOf(initial.end);
    _month = DateTime(_end!.year, _end!.month, 1);
  }

  void _shiftMonth(int delta) {
    final next = DateTime(_month.year, _month.month + delta, 1);
    final earliest = DateTime(_firstDate.year, _firstDate.month, 1);
    final latest = DateTime(_today.year, _today.month, 1);
    if (next.isBefore(earliest) || next.isAfter(latest)) return;
    setState(() => _month = next);
  }

  void _selectField(_RangeField field) {
    if (field == _RangeField.end && _start == null) return;
    final date = field == _RangeField.start ? _start : _end;
    setState(() {
      _activeField = field;
      if (date != null &&
          (date.year != _month.year || date.month != _month.month)) {
        _month = DateTime(date.year, date.month, 1);
      }
    });
  }

  void _selectDay(DateTime day) {
    if (day.isBefore(_firstDate) || day.isAfter(_today)) return;
    if (_activeField == _RangeField.end) {
      final start = _start;
      if (start == null || day.isBefore(start)) return;
      setState(() => _end = day);
      return;
    }
    setState(() {
      _start = day;
      if (_end != null && _end!.isBefore(day)) {
        _end = null;
      }
    });
  }

  void _clear() {
    setState(() {
      _start = null;
      _end = null;
      _activeField = _RangeField.start;
      _month = DateTime(_today.year, _today.month, 1);
    });
  }

  void _apply() {
    final range = _range;
    if (range == null) return;
    Navigator.of(context).pop(range);
  }

  String get _helper {
    final start = _start;
    final end = _end;
    if (start == null) return 'Tap Start, then choose a date.';
    if (end == null) {
      if (_activeField == _RangeField.end) {
        return 'Choose an end date on or after ${_shortDate(start)}.';
      }
      return 'Start set. Tap End, then choose a date.';
    }
    final days = end.difference(start).inDays + 1;
    final label = days == 1 ? '1 day selected' : '$days days selected';
    return '$label. Tap Start or End to change a date.';
  }

  Widget _buildDayCell({
    required int row,
    required int column,
    required int leading,
    required int daysInMonth,
    required DateTime today,
  }) {
    final dayNumber = row * 7 + column - leading + 1;
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox.shrink();
    }

    final day = DateTime(_month.year, _month.month, dayNumber);
    final start = _start;
    final end = _end;
    final withinBounds = !day.isBefore(_firstDate) && !day.isAfter(today);
    final allowedForField =
        _activeField == _RangeField.start ||
        start == null ||
        !day.isBefore(start);
    final enabled = withinBounds && allowedForField;
    final isStart = start == day;
    final isEnd = end == day;
    final inRange =
        start != null &&
        end != null &&
        !day.isBefore(start) &&
        !day.isAfter(end);
    final isActive =
        (isStart && _activeField == _RangeField.start) ||
        (isEnd && _activeField == _RangeField.end);

    return _CalendarDay(
      key: ValueKey('range-day-${_dayKey(day)}'),
      day: day,
      enabled: enabled,
      isToday: day == today,
      isStart: isStart,
      isEnd: isEnd,
      inRange: inRange,
      isActive: isActive,
      onTap: enabled ? () => _selectDay(day) : null,
    );
  }

  List<Widget> _buildWeeks(DateTime today) {
    final first = DateTime(_month.year, _month.month, 1);
    final leading = first.weekday - 1;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final rowCount = (leading + daysInMonth + 6) ~/ 7;

    return [
      for (var row = 0; row < rowCount; row++)
        SizedBox(
          height: 44,
          child: Row(
            children: [
              for (var column = 0; column < 7; column++)
                Expanded(
                  child: _buildDayCell(
                    row: row,
                    column: column,
                    leading: leading,
                    daysInMonth: daysInMonth,
                    today: today,
                  ),
                ),
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    final today = _today;
    final start = _start;
    final end = _end;
    final hasSelection = _hasSelection;
    final canApply = start != null && end != null;
    final earliestMonth = DateTime(_firstDate.year, _firstDate.month, 1);
    final latestMonth = DateTime(today.year, today.month, 1);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500, maxHeight: maxHeight),
          child: Container(
            decoration: BoxDecoration(
              color: WashdayColors.white,
              borderRadius: BorderRadius.circular(WashdayRadii.panel),
              border: Border.all(color: WashdayColors.hairline),
              boxShadow: const [
                BoxShadow(
                  color: WashdayColors.shadow,
                  blurRadius: 30,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: WashdayColors.dottedBorder,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const WashdayKicker('Custom range'),
                  const SizedBox(height: 6),
                  Text('Choose dates', style: WashdayType.title(size: 22)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _RangeFieldCard(
                          key: const Key('custom-range-start-field'),
                          label: 'Start',
                          value: start == null ? null : _shortDate(start),
                          active: _activeField == _RangeField.start,
                          enabled: true,
                          onTap: () => _selectField(_RangeField.start),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: WashdayColors.slate400,
                        ),
                      ),
                      Expanded(
                        child: _RangeFieldCard(
                          key: const Key('custom-range-end-field'),
                          label: 'End',
                          value: end == null ? null : _shortDate(end),
                          active: _activeField == _RangeField.end,
                          enabled: start != null,
                          alignEnd: true,
                          onTap: () => _selectField(_RangeField.end),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _helper,
                      style: WashdayType.muted(size: 11.5, height: 1.35),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _CalendarNavButton(
                        key: const Key('custom-range-previous'),
                        label: 'Previous month',
                        icon: Icons.chevron_left_rounded,
                        onTap: _month.isAfter(earliestMonth)
                            ? () => _shiftMonth(-1)
                            : null,
                      ),
                      Expanded(
                        child: Text(
                          '${_fullMonthNames[_month.month - 1]} ${_month.year}',
                          textAlign: TextAlign.center,
                          style: WashdayType.style(
                            size: 14,
                            weight: 650,
                            color: WashdayColors.ink,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      _CalendarNavButton(
                        key: const Key('custom-range-next'),
                        label: 'Next month',
                        icon: Icons.chevron_right_rounded,
                        onTap: _month.isBefore(latestMonth)
                            ? () => _shiftMonth(1)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      for (final label in const [
                        'M',
                        'T',
                        'W',
                        'T',
                        'F',
                        'S',
                        'S',
                      ])
                        Expanded(
                          child: Center(
                            child: Text(
                              label,
                              style: WashdayType.style(
                                size: 10.5,
                                weight: 650,
                                color: WashdayColors.slate500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ..._buildWeeks(today),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Opacity(
                          opacity: hasSelection ? 1 : 0.45,
                          child: WashdayButton(
                            key: const Key('custom-range-clear'),
                            label: 'Clear',
                            tone: WashdayButtonTone.secondary,
                            height: 46,
                            fontSize: 13.5,
                            onPressed: hasSelection ? _clear : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Opacity(
                          opacity: canApply ? 1 : 0.45,
                          child: WashdayButton(
                            key: const Key('custom-range-apply'),
                            label: 'Use dates',
                            height: 46,
                            fontSize: 13.5,
                            onPressed: canApply ? _apply : null,
                          ),
                        ),
                      ),
                    ],
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

class _RangeFieldCard extends StatelessWidget {
  const _RangeFieldCard({
    super.key,
    required this.label,
    required this.value,
    required this.active,
    required this.enabled,
    required this.onTap,
    this.alignEnd = false,
  });

  final String label;
  final String? value;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final placeholder = value == null;
    final alignment = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.end : TextAlign.start;

    return Semantics(
      button: true,
      enabled: enabled,
      selected: active,
      label: '$label date, ${value ?? 'not set'}${active ? ', editing' : ''}',
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: active ? WashdayColors.teal100 : WashdayColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(minHeight: 54),
              padding: const EdgeInsets.fromLTRB(11, 8, 11, 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active
                      ? WashdayColors.teal500
                      : WashdayColors.hairline,
                  width: active ? 1.4 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: alignment,
                children: [
                  Row(
                    mainAxisAlignment: alignEnd
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: WashdayType.style(
                          size: 9.5,
                          weight: 700,
                          color: active
                              ? WashdayColors.teal700
                              : WashdayColors.slate500,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (active) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: WashdayColors.teal600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Editing',
                          style: WashdayType.style(
                            size: 9.5,
                            weight: 650,
                            color: WashdayColors.teal700,
                            height: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value ?? 'Not set',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: textAlign,
                    style: WashdayType.style(
                      size: 13.5,
                      weight: placeholder ? 500 : 650,
                      color: placeholder
                          ? WashdayColors.slate500
                          : WashdayColors.ink,
                      height: 1.25,
                      letterSpacing: -0.1,
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

class _CalendarNavButton extends StatelessWidget {
  const _CalendarNavButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? WashdayColors.surfaceMuted
                : WashdayColors.surfaceMuted.withValues(alpha: 0.5),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? WashdayColors.inkSecondary
                : WashdayColors.slate400,
          ),
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    super.key,
    required this.day,
    required this.enabled,
    required this.isToday,
    required this.isStart,
    required this.isEnd,
    required this.inRange,
    required this.isActive,
    required this.onTap,
  });

  final DateTime day;
  final bool enabled;
  final bool isToday;
  final bool isStart;
  final bool isEnd;
  final bool inRange;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final selected = isStart || isEnd;
    final background = selected
        ? isActive
              ? WashdayColors.teal700
              : WashdayColors.ink
        : inRange
        ? WashdayColors.teal100
        : Colors.transparent;
    final foreground = !enabled
        ? WashdayColors.slate400.withValues(alpha: 0.55)
        : selected
        ? Colors.white
        : inRange
        ? WashdayColors.teal700
        : WashdayColors.ink;
    final role = isStart && isEnd
        ? ', start and end date'
        : isStart
        ? ', start date'
        : isEnd
        ? ', end date'
        : '';

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label:
          '${day.day} ${_fullMonthNames[day.month - 1]} ${day.year}$role${isActive ? ', editing' : ''}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: background,
              border: isToday && !selected
                  ? Border.all(color: WashdayColors.teal500)
                  : null,
            ),
            child: Text(
              '${day.day}',
              style: WashdayType.style(
                size: 12.5,
                weight: selected || inRange ? 650 : 500,
                color: foreground,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterDateOption extends StatelessWidget {
  const _FilterDateOption({
    super.key,
    required this.option,
    required this.selected,
    required this.showTopBorder,
    required this.onTap,
  });

  final (_DateScope, IconData, String, String) option;
  final bool selected;
  final bool showTopBorder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (scope, icon, title, detail) = option;
    final isCustom = scope == _DateScope.custom;

    return Container(
      decoration: BoxDecoration(
        border: showTopBorder
            ? const Border(top: BorderSide(color: WashdayColors.hairline))
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected
                        ? WashdayColors.teal100
                        : WashdayColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: selected
                        ? WashdayColors.teal700
                        : WashdayColors.inkSecondary,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: WashdayType.style(
                          size: 13,
                          weight: 640,
                          color: selected
                              ? WashdayColors.teal700
                              : WashdayColors.ink,
                          height: 1.3,
                          letterSpacing: -0.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: WashdayType.muted(size: 11.2, height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.check_rounded
                      : isCustom
                      ? Icons.chevron_right_rounded
                      : null,
                  size: 18,
                  color: selected
                      ? WashdayColors.teal700
                      : WashdayColors.slate400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderGroup extends StatelessWidget {
  const _OrderGroup({
    required this.label,
    required this.orders,
    required this.onTap,
  });

  final String label;
  final List<WashdayOrder> orders;
  final ValueChanged<WashdayOrder> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GroupLabel(label),
        for (var index = 0; index < orders.length; index++)
          _OrderRow(
            order: orders[index],
            showTopBorder: index > 0,
            onTap: () => onTap(orders[index]),
          ),
      ],
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({
    required this.filter,
    required this.dateFiltered,
    this.onClear,
  });

  final String filter;
  final bool dateFiltered;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final message = dateFiltered
        ? filter == 'all'
              ? 'No orders in this date range.'
              : 'No orders match these filters.'
        : switch (filter) {
            'active' => 'No active orders right now.',
            'declined' => 'No declined requests.',
            'collected' => 'No collected orders yet.',
            _ => 'No orders yet.',
          };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 22,
            color: WashdayColors.slate400,
          ),
          const SizedBox(height: 8),
          Text(message, style: WashdayType.muted(size: 12.5)),
          if (onClear != null) ...[
            const SizedBox(height: 6),
            WashdayTextLink('Clear filters', onTap: onClear!),
          ],
        ],
      ),
    );
  }
}

class _OrdersSkeleton extends StatelessWidget {
  const _OrdersSkeleton({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const Key('orders-loading'),
      label: 'Loading orders',
      liveRegion: true,
      container: true,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final pulse = 0.55 + 0.45 * math.sin(math.pi * animation.value);
            return Opacity(opacity: pulse, child: child);
          },
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SkeletonGroupLabel(),
              _SkeletonOrderRow(showTopBorder: false),
              _SkeletonOrderRow(),
              _SkeletonOrderRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonGroupLabel extends StatelessWidget {
  const _SkeletonGroupLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const WashdaySkeletonBlock(width: 68, height: 9),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: WashdayColors.hairline)),
      ],
    );
  }
}

class _SkeletonOrderRow extends StatelessWidget {
  const _SkeletonOrderRow({this.showTopBorder = true});

  final bool showTopBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: showTopBorder
            ? const Border(top: BorderSide(color: WashdayColors.hairline))
            : null,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: const Row(
          children: [
            WashdaySkeletonBlock(
              width: 38,
              height: 38,
              radius: WashdayRadii.tile,
            ),
            SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.64,
                    child: WashdaySkeletonBlock(height: 11),
                  ),
                  SizedBox(height: 7),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.86,
                    child: WashdaySkeletonBlock(height: 9),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            WashdaySkeletonBlock(width: 62, height: 22, radius: 999),
          ],
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        WashdayKicker(label),
        const SizedBox(width: 10),
        const Expanded(
          child: Divider(height: 1, color: WashdayColors.hairline),
        ),
      ],
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.order,
    required this.showTopBorder,
    required this.onTap,
  });

  final WashdayOrder order;
  final bool showTopBorder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = order.service.characters.first.toUpperCase();
    final collected = order.isCollected;
    final tone = switch (order.stage) {
      OrderStage.ready => WashdayTone.warning,
      OrderStage.declined => WashdayTone.red,
      OrderStage.cancelled => WashdayTone.neutral,
      _ => WashdayTone.neutral,
    };
    final subtitle = '${order.counterLabel} · ${order.rateLabel}';

    return WashdayListRow(
      title: '${order.id} · ${order.service}',
      subtitle: subtitle,
      leading: WashdayLeadingTile(
        background: collected
            ? WashdayColors.surfaceMuted
            : WashdayColors.teal100,
        foreground: collected ? WashdayColors.slate500 : WashdayColors.teal700,
        child: Text(initial),
      ),
      trailing: WashdayStatusPill(order.statusCopy, tone: tone),
      onTap: onTap,
      showTopBorder: showTopBorder,
      padding: const EdgeInsets.symmetric(vertical: 11),
      titleMaxLines: 2,
    );
  }
}
