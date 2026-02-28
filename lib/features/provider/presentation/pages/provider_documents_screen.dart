import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/providers/shared_prefs_provider.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/provider/domain/utils/provider_access.dart';

class ProviderDocumentsScreen extends ConsumerStatefulWidget {
  const ProviderDocumentsScreen({super.key});

  @override
  ConsumerState<ProviderDocumentsScreen> createState() =>
      _ProviderDocumentsScreenState();
}

class _ProviderDocumentsScreenState
    extends ConsumerState<ProviderDocumentsScreen> {
  static const String _docStoragePrefix = 'provider_documents';
  final ImagePicker _picker = ImagePicker();
  final List<_ProviderDocumentItem> _documents = <_ProviderDocumentItem>[];

  bool _isLoading = true;
  bool _isAdding = false;

  String _storageKey(String providerId) => '$_docStoragePrefix:$providerId';

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    final session = ref.read(userSessionServiceProvider);
    final providerId = session.getUserId() ?? 'provider';
    final prefs = ref.read(sharedPrefsProvider);
    final raw = prefs.getString(_storageKey(providerId));

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _documents
          ..clear()
          ..addAll(
            decoded.whereType<Map>().map(
              (item) => _ProviderDocumentItem.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
            ),
          );
      } catch (_) {
        _documents.clear();
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _saveDocuments() async {
    final session = ref.read(userSessionServiceProvider);
    final providerId = session.getUserId() ?? 'provider';
    final prefs = ref.read(sharedPrefsProvider);
    final payload = jsonEncode(_documents.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey(providerId), payload);
  }

  Future<void> _addDocument(String documentType) async {
    setState(() => _isAdding = true);
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      _documents.insert(
        0,
        _ProviderDocumentItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: documentType,
          path: file.path,
          addedAt: DateTime.now().toIso8601String(),
        ),
      );
      await _saveDocuments();
      if (!mounted) return;
      setState(() {});
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  Future<void> _removeDocument(String id) async {
    _documents.removeWhere((doc) => doc.id == id);
    await _saveDocuments();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(userSessionServiceProvider);
    final providerType = session.getProviderType();
    final documentTypes = _documentTypesForProvider(providerType);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Documents'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: context.textSecondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'Add required documents for your ${getProviderTypeLabel(providerType)} account. Documents are stored locally on this device.',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: documentTypes
                      .map(
                        (type) => FilledButton.icon(
                          onPressed: _isAdding
                              ? null
                              : () => _addDocument(type),
                          icon: const Icon(Icons.upload_file_rounded, size: 18),
                          label: Text(type),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                if (_documents.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'No documents uploaded yet.',
                      style: TextStyle(color: context.textSecondary),
                    ),
                  ),
                ..._documents.map((doc) {
                  final addedAt = DateTime.tryParse(doc.addedAt);
                  final fileName = p.basename(doc.path);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.description_rounded),
                      title: Text(doc.type),
                      subtitle: Text(
                        '${fileName.isEmpty ? doc.path : fileName}\n${addedAt != null ? addedAt.toLocal().toString().split('.').first : ''}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_rounded),
                        onPressed: () => _removeDocument(doc.id),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

List<String> _documentTypesForProvider(ProviderType providerType) {
  if (isVetProvider(providerType)) {
    return const <String>['Medical License', 'Clinic Registration', 'ID Proof'];
  }
  if (isShopProvider(providerType)) {
    return const <String>[
      'Business Registration',
      'PAN / Tax Document',
      'ID Proof',
    ];
  }
  if (isGroomerProvider(providerType)) {
    return const <String>[
      'Grooming Certificate',
      'Experience Proof',
      'ID Proof',
    ];
  }
  return const <String>['Business Document', 'Certification', 'ID Proof'];
}

class _ProviderDocumentItem {
  final String id;
  final String type;
  final String path;
  final String addedAt;

  const _ProviderDocumentItem({
    required this.id,
    required this.type,
    required this.path,
    required this.addedAt,
  });

  factory _ProviderDocumentItem.fromJson(Map<String, dynamic> json) {
    return _ProviderDocumentItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Document',
      path: json['path']?.toString() ?? '',
      addedAt: json['addedAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'path': path,
      'addedAt': addedAt,
    };
  }
}
