import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_options.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/bloom_interest_chip.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../providers/edit_profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _bioController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Pre-fill text controllers from provider state on first build.
  void _maybeInit(EditProfileState state) {
    if (_initialized || state.nickname.isEmpty) return;
    _nicknameController.text = state.nickname;
    _bioController.text = state.bio;
    _initialized = true;
  }

  Future<void> _onSave(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    // Relationship goal is chip-driven (not a FormField) so validated separately.
    if (ref.read(editProfileProvider).relationshipGoal.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.editProfileSelectGoal)),
        );
      return;
    }
    await ref.read(editProfileProvider.notifier).saveChanges(
          nickname: _nicknameController.text,
          bio: _bioController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(editProfileProvider);
    _maybeInit(state);

    // Side-effect listener: SnackBar on error, pop on success.
    ref.listen<EditProfileState>(editProfileProvider, (prev, next) {
      if (next.saveError != null && next.saveError != prev?.saveError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.saveError!)));
      }
      if (prev?.isSaving == true && !next.isSaving && next.saveError == null) {
        if (context.mounted) context.pop();
      }
    });

    final isSaving = state.isSaving;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editProfileTitle),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Nickname ────────────────────────────────────────────────
                TextFormField(
                  controller: _nicknameController,
                  textInputAction: TextInputAction.next,
                  maxLength: 30,
                  enabled: !isSaving,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    labelText: l10n.editProfileNickname,
                    hintText: l10n.editProfileNicknameHint,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.editProfileNicknameRequired;
                    }
                    if (v.trim().length > 30) {
                      return l10n.editProfileNicknameTooLong;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Bio ─────────────────────────────────────────────────────
                TextFormField(
                  controller: _bioController,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 3,
                  enabled: !isSaving,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    labelText: l10n.editProfileBio,
                    hintText: l10n.editProfileBioHint,
                    alignLabelWithHint: true,
                  ),
                  validator: (v) {
                    if (v != null && v.length > 500) {
                      return l10n.editProfileBioTooLong;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Relationship goal ───────────────────────────────────────
                Text(l10n.editProfileRelationshipGoal,
                    style: AppTypography.subtitle),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final goal in AppOptions.relationshipGoals)
                      BloomInterestChip(
                        label: goal,
                        selected: state.relationshipGoal == goal,
                        onTap: isSaving
                            ? null
                            : () => ref
                                .read(editProfileProvider.notifier)
                                .setRelationshipGoal(goal),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Interests ───────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(l10n.editProfileInterests,
                          style: AppTypography.subtitle),
                    ),
                    Text(
                      '${state.interests.length}/10',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.editProfileInterestsHint,
                    style: AppTypography.caption),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final interest in AppOptions.interests)
                      BloomInterestChip(
                        label: interest,
                        selected: state.interests.contains(interest),
                        onTap: isSaving
                            ? null
                            : () => ref
                                .read(editProfileProvider.notifier)
                                .toggleInterest(interest),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Save button ─────────────────────────────────────────────
                GradientButton(
                  label: l10n.saveChanges,
                  isLoading: isSaving,
                  onPressed: isSaving ? null : () => _onSave(l10n),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
