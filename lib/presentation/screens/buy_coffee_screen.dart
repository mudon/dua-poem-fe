import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blocs/donation_bloc/donation_bloc.dart';
import '../../core/themes/app_theme.dart';
import '../../app/dependency_injection.dart';

class BuyCoffeeScreen extends StatefulWidget {
  const BuyCoffeeScreen({super.key});

  @override
  State<BuyCoffeeScreen> createState() => _BuyCoffeeScreenState();
}

class _BuyCoffeeScreenState extends State<BuyCoffeeScreen> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  double _selectedAmount = 5;

  final List<double> _presetAmounts = [3, 5, 10, 20];

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DonationBloc>(),
      child: BlocConsumer<DonationBloc, DonationState>(
        listener: (context, state) {
          if (state is DonationSuccess) {
            _launchUrl(state.paymentUrl);
            context.read<DonationBloc>().add(ResetDonation());
            Navigator.pop(context);
          }
          if (state is DonationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              AppTheme.errorSnackBar(state.message),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Beli Saya Kopi'),
              backgroundColor: AppTheme.sage,
              foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.coffee, size: 64, color: AppTheme.earthBrown),
                  const SizedBox(height: 16),
                  const Text(
                    'Sokong Teduh',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3C4F34)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dengan membeli kopi, anda membantu kami terus menyediakan kandungan yang bermanfaat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF5C5346)),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _presetAmounts.map((amount) {
                      final selected = _selectedAmount == amount;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedAmount = amount),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.sage : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: selected ? AppTheme.sage : AppTheme.warmGray),
                            ),
                            child: Text(
                              'RM${amount.toInt()}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : const Color(0xFF3C4F34),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('RM ', style: TextStyle(fontSize: 16, color: Color(0xFF3C4F34))),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '5',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (v) {
                            final parsed = double.tryParse(v);
                            if (parsed != null) {
                              setState(() => _selectedAmount = parsed);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('lain', style: TextStyle(fontSize: 14, color: Color(0xFF5C5346))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama (pilihan)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Emel (pilihan)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon (pilihan)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state is DonationLoading
                          ? null
                          : () {
                              context.read<DonationBloc>().add(CreateBill(
                                    amount: _selectedAmount,
                                    name: _nameController.text.isNotEmpty ? _nameController.text : null,
                                    email: _emailController.text.isNotEmpty ? _emailController.text : null,
                                    phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
                                  ));
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.sage,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: state is DonationLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Beli Saya Kopi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pembayaran diproses secara selamat melalui ToyyibPay.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFFA69681)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
