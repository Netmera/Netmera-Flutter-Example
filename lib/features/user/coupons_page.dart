import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/ui/app_colors.dart';
import 'package:netmera_flutter_example/ui/app_theme.dart';
import 'package:netmera_flutter_example/ui/widgets/list_rows.dart';
import 'package:netmera_flutter_example/utils/category_channel_utils.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraCouponDetail.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  final _page = TextEditingController(text: '0');
  final _max = TextEditingController(text: '10');

  List<NetmeraCouponDetail> _coupons = [];
  String _result = 'No coupons fetched yet';
  bool _fetching = false;

  @override
  void dispose() {
    _page.dispose();
    _max.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _fetching = true);
    final page = int.tryParse(_page.text.trim()) ?? 0;
    final max = int.tryParse(_max.text.trim()) ?? 10;
    try {
      final coupons = await Netmera.fetchCoupons(page, max);
      if (!mounted) return;
      setState(() {
        _coupons = coupons;
        _result = coupons.isEmpty
            ? 'No coupons found'
            : 'Found ${coupons.length} coupons';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _coupons = [];
        _result = 'Error: ${errorMessage(error)}';
      });
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  static String _detail(NetmeraCouponDetail coupon) {
    return [
      'ID: ${coupon.getCouponId()}',
      if (coupon.getExpireDate() != null) 'Expires: ${coupon.getExpireDate()}',
      if (coupon.getAssignDate() != null) 'Assigned: ${coupon.getAssignDate()}',
    ].join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Coupon Filter Parameters',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: AppColors.label),
              ),
              const SizedBox(height: 16),
              _NumberField(
                id: 'page',
                title: 'Page (index)',
                hint: 'Page index',
                controller: _page,
              ),
              const SizedBox(height: 16),
              _NumberField(
                id: 'max',
                title: 'Page size (max count)',
                hint: 'Page size',
                controller: _max,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const ValueKey('coupons.fetch'),
                onPressed: _fetching ? null : _fetch,
                child: Text(_fetching ? 'Fetching...' : 'Fetch Coupons'),
              ),
              const SizedBox(height: 16),
              Text(
                _result,
                key: const ValueKey('coupons.result'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.mutedText),
              ),
            ],
          ),
        ),
        for (final coupon in _coupons)
          MenuRow(
            title: '${coupon.getCode()} - ${coupon.getName()}',
            subtitle: _detail(coupon),
          ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.id,
    required this.title,
    required this.hint,
    required this.controller,
  });

  final String id;
  final String title;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTextStyles.switchTitle),
        const SizedBox(height: 8),
        TextField(
          key: ValueKey('coupons.$id.textField'),
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
