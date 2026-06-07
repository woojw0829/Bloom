import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_options.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/bloom_interest_chip.dart';
import '../../domain/models/discovery_filters.dart';
import '../providers/discovery_filters_provider.dart';

/// Shows the [DiscoveryFilterSheet] as a modal bottom sheet and waits for the
/// user to apply or dismiss. Reads the current active filters as the initial
/// draft state.
Future<void> showDiscoveryFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const DiscoveryFilterSheet(),
  );
}

// ── Sheet root ────────────────────────────────────────────────────────────────

class DiscoveryFilterSheet extends ConsumerStatefulWidget {
  const DiscoveryFilterSheet({super.key});

  @override
  ConsumerState<DiscoveryFilterSheet> createState() =>
      _DiscoveryFilterSheetState();
}

class _DiscoveryFilterSheetState extends ConsumerState<DiscoveryFilterSheet> {
  late DiscoveryFilters _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(discoveryFiltersProvider);
  }

  void _toggleIdentity(String value) {
    final s = Set<String>.from(_draft.identities);
    if (s.contains(value)) {
      s.remove(value);
    } else {
      s.add(value);
    }
    setState(() => _draft = _draft.copyWith(identities: s));
  }

  void _toggleGoal(String value) {
    final s = Set<String>.from(_draft.relationshipGoals);
    if (s.contains(value)) {
      s.remove(value);
    } else {
      s.add(value);
    }
    setState(() => _draft = _draft.copyWith(relationshipGoals: s));
  }

  void _apply() {
    ref.read(discoveryFiltersProvider.notifier).apply(_draft);
    Navigator.of(context).pop();
  }

  void _reset() {
    ref.read(discoveryFiltersProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: ColoredBox(
        color: Colors.white,
        child: SizedBox(
          height: screenHeight * 0.88,
          child: Column(
            children: [
              const _DragHandle(),
              _SheetHeader(
                title: l10n.filtersTitle,
                onClose: () => Navigator.of(context).pop(),
              ),
              const Divider(height: 1),

              // Scrollable filter sections.
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AgeSection(
                        draft: _draft,
                        l10n: l10n,
                        onChanged: (min, max) => setState(
                          () => _draft =
                              _draft.copyWith(minAge: min, maxAge: max),
                        ),
                      ),
                      const _SectionDivider(),
                      _IdentitySection(
                        draft: _draft,
                        l10n: l10n,
                        onToggle: _toggleIdentity,
                      ),
                      const _SectionDivider(),
                      _GoalSection(
                        draft: _draft,
                        l10n: l10n,
                        onToggle: _toggleGoal,
                      ),
                      const _SectionDivider(),
                      _VerifiedSection(
                        draft: _draft,
                        l10n: l10n,
                        onChanged: (v) => setState(
                          () => _draft = _draft.copyWith(verifiedOnly: v),
                        ),
                      ),
                      const _SectionDivider(),
                      _DistanceSection(
                        draft: _draft,
                        l10n: l10n,
                        onChanged: (km) => setState(
                          () => _draft = _draft.copyWith(maxDistanceKm: km),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),
              _Footer(
                l10n: l10n,
                onReset: _reset,
                onApply: _apply,
              ),
              SizedBox(height: bottomInset + AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Drag handle ───────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ── Sheet header ──────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTypography.subtitle),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.textSecondary),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

// ── Section divider ───────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Divider(height: 1, color: AppColors.divider),
    );
  }
}

// ── Section label row ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Text(label, style: AppTypography.bodyMedium),
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ── Age section ───────────────────────────────────────────────────────────────

class _AgeSection extends StatelessWidget {
  const _AgeSection({
    required this.draft,
    required this.l10n,
    required this.onChanged,
  });

  final DiscoveryFilters draft;
  final AppLocalizations l10n;
  final void Function(int min, int max) onChanged;

  @override
  Widget build(BuildContext context) {
    final minAge = draft.minAge.toDouble();
    final maxAge = draft.maxAge.toDouble();
    final maxLabel = draft.maxAge >= DiscoveryFilters.maxAgeLimit
        ? '${DiscoveryFilters.maxAgeLimit}+'
        : '${draft.maxAge}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          label: l10n.filtersAge,
          trailing: Text(
            '${draft.minAge} – $maxLabel',
            style:
                AppTypography.label.copyWith(color: AppColors.textSecondary),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            thumbColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            overlayColor: AppColors.primary.withValues(alpha: 0.12),
          ),
          child: RangeSlider(
            values: RangeValues(minAge, maxAge),
            min: DiscoveryFilters.minAgeLimit.toDouble(),
            max: DiscoveryFilters.maxAgeLimit.toDouble(),
            divisions: DiscoveryFilters.maxAgeLimit - DiscoveryFilters.minAgeLimit,
            labels: RangeLabels('${draft.minAge}', maxLabel),
            onChanged: (v) => onChanged(v.start.round(), v.end.round()),
          ),
        ),
      ],
    );
  }
}

// ── Identity section ──────────────────────────────────────────────────────────

class _IdentitySection extends StatelessWidget {
  const _IdentitySection({
    required this.draft,
    required this.l10n,
    required this.onToggle,
  });

  final DiscoveryFilters draft;
  final AppLocalizations l10n;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: l10n.filtersIdentity),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: AppOptions.identities
                .map(
                  (id) => BloomInterestChip(
                    label: id,
                    selected: draft.identities.contains(id),
                    onTap: () => onToggle(id),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── Relationship goal section ─────────────────────────────────────────────────

class _GoalSection extends StatelessWidget {
  const _GoalSection({
    required this.draft,
    required this.l10n,
    required this.onToggle,
  });

  final DiscoveryFilters draft;
  final AppLocalizations l10n;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: l10n.filtersRelationshipGoal),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: AppOptions.relationshipGoals
                .map(
                  (goal) => BloomInterestChip(
                    label: goal,
                    selected: draft.relationshipGoals.contains(goal),
                    onTap: () => onToggle(goal),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── Verified only section ─────────────────────────────────────────────────────

class _VerifiedSection extends StatelessWidget {
  const _VerifiedSection({
    required this.draft,
    required this.l10n,
    required this.onChanged,
  });

  final DiscoveryFilters draft;
  final AppLocalizations l10n;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Text(l10n.filtersVerifiedOnly, style: AppTypography.bodyMedium),
          ),
          Switch(
            value: draft.verifiedOnly,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ── Distance section ──────────────────────────────────────────────────────────

class _DistanceSection extends StatelessWidget {
  const _DistanceSection({
    required this.draft,
    required this.l10n,
    required this.onChanged,
  });

  final DiscoveryFilters draft;
  final AppLocalizations l10n;
  final ValueChanged<int> onChanged;

  static const int _minKm = 10;
  static const int _stepKm = 5;
  static const int _divisions =
      (DiscoveryFilters.maxDistanceKmLimit - _minKm) ~/ _stepKm;

  @override
  Widget build(BuildContext context) {
    final isAny = draft.maxDistanceKm >= DiscoveryFilters.maxDistanceKmLimit;
    final distanceLabel = isAny
        ? l10n.filtersAnyDistance
        : l10n.filtersWithinKm(draft.maxDistanceKm);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          label: l10n.filtersDistance,
          trailing: Text(
            distanceLabel,
            style:
                AppTypography.label.copyWith(color: AppColors.textSecondary),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            thumbColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            overlayColor: AppColors.primary.withValues(alpha: 0.12),
          ),
          child: Slider(
            value: draft.maxDistanceKm
                .clamp(_minKm, DiscoveryFilters.maxDistanceKmLimit)
                .toDouble(),
            min: _minKm.toDouble(),
            max: DiscoveryFilters.maxDistanceKmLimit.toDouble(),
            divisions: _divisions,
            label: distanceLabel,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({
    required this.l10n,
    required this.onReset,
    required this.onApply,
  });

  final AppLocalizations l10n;
  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReset,
              child: Text(l10n.filtersReset),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onApply,
              child: Text(l10n.filtersApply),
            ),
          ),
        ],
      ),
    );
  }
}
