import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/provider_service/domain/entities/provider_service_entity.dart';
import 'package:petcare/features/provider_service/presentation/view_model/provider_service_view_model.dart';
import 'package:petcare/app/l10n/app_localizations.dart';

class ApplyProviderServiceScreen extends ConsumerStatefulWidget {
  final String? initialServiceType;
  final bool lockServiceType;

  const ApplyProviderServiceScreen({
    super.key,
    this.initialServiceType,
    this.lockServiceType = false,
  });

  @override
  ConsumerState<ApplyProviderServiceScreen> createState() =>
      _ApplyProviderServiceScreenState();
}

class _ApplyProviderServiceScreenState
    extends ConsumerState<ApplyProviderServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  String? _selectedServiceType;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServiceType == null || _selectedServiceType!.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tr('pleaseSelectServiceType')),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    final duration = int.tryParse(_durationController.text.trim());
    if (price == null || duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid price and duration'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    final entity = ProviderServiceEntity(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _selectedServiceType!,
      price: price,
      durationMinutes: duration,
    );

    await ref.read(providerServiceProvider.notifier).applyForService(entity);

    final state = ref.read(providerServiceProvider);
    if (state.error == null) {
      if (!mounted) return;
      final l10nSnack = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10nSnack.tr('applicationSubmitted'))),
      );
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error!)));
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedServiceType = widget.initialServiceType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(providerServiceProvider);
    final session = ref.watch(userSessionServiceProvider);
    final providerType = (session.getProviderType() ?? '').toLowerCase();
    final serviceOptions = _serviceOptionsForProvider(providerType, l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('applyForProviderService'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedServiceType,
                decoration: InputDecoration(
                  labelText: l10n.tr('serviceType'),
                  border: OutlineInputBorder(),
                ),
                items: serviceOptions
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option.value,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                onChanged: widget.lockServiceType
                    ? null
                    : (value) {
                        setState(() {
                          _selectedServiceType = value;
                        });
                      },
                validator: (value) => value == null || value.isEmpty
                    ? l10n.tr('selectServiceType')
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) return 'Enter valid price';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) return 'Enter duration';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              SizedBox(height: 12),
              state.isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 12,
                        ),
                        child: Text(l10n.tr('submitApplication')),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTypeOption {
  final String value;
  final String label;

  const _ServiceTypeOption({required this.value, required this.label});
}

List<_ServiceTypeOption> _serviceOptionsForProvider(
  String providerType,
  AppLocalizations l10n,
) {
  switch (providerType) {
    case 'vet':
      return [
        _ServiceTypeOption(value: 'vet', label: l10n.tr('veterinaryServices')),
      ];
    case 'shop':
      return [
        _ServiceTypeOption(value: 'grooming', label: l10n.tr('grooming')),
        _ServiceTypeOption(value: 'boarding', label: l10n.tr('boarding')),
      ];
    case 'babysitter':
      return [
        _ServiceTypeOption(value: 'grooming', label: l10n.tr('grooming')),
        _ServiceTypeOption(value: 'boarding', label: l10n.tr('boarding')),
      ];
    default:
      return [
        _ServiceTypeOption(value: 'vet', label: l10n.tr('veterinaryServices')),
        _ServiceTypeOption(value: 'grooming', label: l10n.tr('grooming')),
        _ServiceTypeOption(value: 'boarding', label: l10n.tr('boarding')),
      ];
  }
}
