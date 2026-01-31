import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../services/supabase_service.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final SupabaseService _service = SupabaseService();
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      _addresses = await _service.getSavedAddresses();
    } catch (e) {
      debugPrint('Error loading addresses: ' + e.toString());
    }
    setState(() => _isLoading = false);
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Label (e.g., Home, Work)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Full Address'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (addressController.text.isNotEmpty) {
                await _service.saveAddress({
                  'label': nameController.text.isEmpty ? 'Address' : nameController.text,
                  'address': addressController.text,
                });
                Navigator.pop(context);
                _loadAddresses();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        backgroundColor: AppTheme.primaryRedDark,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.primaryRedDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No saved addresses', style: AppTheme.textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      const Text('Tap + to add your first address'),
                    ],
                  ).animate().fadeIn(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final addr = _addresses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.cobaltBlue.withOpacity(0.1),
                          child: const Icon(Icons.location_on, color: AppTheme.cobaltBlue),
                        ),
                        title: Text(addr['label'] ?? 'Address', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(addr['address'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            await _service.deleteAddress(addr['id']);
                            _loadAddresses();
                          },
                        ),
                      ),
                    ).animate().fadeIn(delay: (50 * index).ms);
                  },
                ),
    );
  }
}
