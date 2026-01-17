import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/promo_code.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/promo_code_provider.dart';
import '../../../../core/data/services_data.dart';

class PostPage extends ConsumerStatefulWidget {
  const PostPage({super.key});

  @override
  ConsumerState<PostPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _commentController = TextEditingController();
  DateTime? _expirationDate;
  bool _isSubmitting = false;
  String? _selectedService;

  @override
  void dispose() {
    _codeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _selectExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _expirationDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in to post')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final promoCode = PromoCode(
      id: '',
      code: _codeController.text.trim(),
      serviceName: _selectedService!,
      authorId: currentUser.id,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      publishDate: DateTime.now(),
      expirationDate: _expirationDate,
    );

    final useCase = ref.read(createPromoCodeProvider);
    final result = await useCase(promoCode);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${failure.message ?? 'Failed to create promo code'}',
            ),
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
      },
      (created) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Promo code posted successfully!')),
        );
        ref
            .read(promoCodesNotifierProvider.notifier)
            .loadPromoCodes(refresh: true);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Promo Code')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Service Selection with Search
              Autocomplete<Service>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return ServicesData.services;
                  }
                  return ServicesData.searchServices(textEditingValue.text);
                },
                displayStringForOption: (Service service) => service.name,
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  if (_selectedService != null) {
                    textEditingController.text = _selectedService!;
                  }
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Service *',
                      hintText: 'Search for a service...',
                      prefixIcon: const Icon(Icons.store),
                      suffixIcon: _selectedService != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _selectedService = null;
                                  textEditingController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    validator: (value) {
                      if (_selectedService == null) {
                        return 'Please select a service';
                      }
                      return null;
                    },
                  );
                },
                onSelected: (Service service) {
                  setState(() {
                    _selectedService = service.name;
                  });
                },
                optionsViewBuilder: (
                  BuildContext context,
                  AutocompleteOnSelected<Service> onSelected,
                  Iterable<Service> options,
                ) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final service = options.elementAt(index);
                            return ListTile(
                              leading: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.store,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              title: Text(service.name),
                              onTap: () {
                                onSelected(service);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_selectedService != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Chip(
                    label: Text('Selected: $_selectedService'),
                    avatar: const Icon(Icons.check_circle, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedService = null;
                      });
                    },
                  ),
                ),
              const SizedBox(height: 16),

              // Promo Code
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Promo Code *',
                  hintText: 'Enter the promo code',
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter promo code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Comment
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment (Optional)',
                  hintText: 'Add any additional information',
                  prefixIcon: Icon(Icons.comment),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Expiration Date
              InkWell(
                onTap: _selectExpirationDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expiration Date (Optional)',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _expirationDate == null
                        ? 'Select expiration date'
                        : '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year} ${_expirationDate!.hour}:${_expirationDate!.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              if (_expirationDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _expirationDate = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear expiration date'),
                  ),
                ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post Promo Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
