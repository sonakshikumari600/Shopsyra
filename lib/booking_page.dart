import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  final String? preSelectedShop;
  final String? preSelectedItem;
  const BookingPage({super.key, this.preSelectedShop, this.preSelectedItem});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color bgColor       = const Color(0xFFF0E8DF);

  final List<String> _shops = [
    'Vogue Boutique', 'Fashion Hub', 'Urban Style', 'Lifestyle Attire'
  ];

  final Map<String, List<String>> _shopItems = {
    'Vogue Boutique':   ['Casual Jacket ₹1,599', 'Black Skinny Jeans ₹1,399', 'Floral Dress ₹1,199'],
    'Fashion Hub':      ['Denim Jacket ₹1,899', 'Slim Denim Jeans ₹1,250', 'Summer Dress ₹999'],
    'Urban Style':      ['Graphic T-Shirt ₹699', 'White Sneakers ₹1,999'],
    'Lifestyle Attire': ['Plain White Tee ₹499', 'Running Shoes ₹2,499'],
  };

  final List<String> _timeSlots = [
    '10:00 AM', '11:00 AM', '12:00 PM',
    '2:00 PM',  '3:00 PM',  '4:00 PM',
    '5:00 PM',  '6:00 PM',  '7:00 PM',
  ];

  String? _selectedShop;
  final List<String> _selectedItems = [];
  DateTime? _selectedDate;
  String? _selectedTime;
  final _notesCtrl = TextEditingController();

  // Whether shop/item came pre-selected
  bool get _shopPreSelected => widget.preSelectedShop != null;
  bool get _itemPreSelected => widget.preSelectedItem != null;

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedShop != null) _selectedShop = widget.preSelectedShop;
    if (widget.preSelectedItem != null) _selectedItems.add(widget.preSelectedItem!);
  }

  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  List<String> get _currentItems =>
      _selectedShop != null ? (_shopItems[_selectedShop] ?? []) : [];

  bool get _isFormValid =>
      _selectedShop != null &&
      _selectedItems.isNotEmpty &&
      _selectedDate != null &&
      _selectedTime != null;

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: primaryOrange, onSurface: darkBrown),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submitBooking() {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please fill all required fields!'),
            backgroundColor: Colors.red.shade400, duration: const Duration(seconds: 2)));
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 40),
          ),
          const SizedBox(height: 16),
          Text('Booking Confirmed!',
              style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Your visit to $_selectedShop is booked for ${_formatDate(_selectedDate!)} at $_selectedTime.',
              textAlign: TextAlign.center,
              style: TextStyle(color: darkBrown.withOpacity(0.6), fontSize: 13, height: 1.5)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () { Navigator.pop(context); Navigator.pop(context); },
            child: Container(
              width: double.infinity, height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryOrange, const Color(0xFFA8481A)],
                    begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Done',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _navBar(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Show selected shop/item as info card (not selectable) ──
                  if (_shopPreSelected) ...[
                    _infoCard(
                      icon: Icons.store_rounded,
                      label: 'Shop',
                      value: widget.preSelectedShop!,
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (_itemPreSelected) ...[
                    _infoCard(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Item',
                      value: widget.preSelectedItem!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Show shop selector only if not pre-selected ──
                  if (!_shopPreSelected) ...[
                    _sectionTitle('1. Select Shop', Icons.store_rounded),
                    const SizedBox(height: 10),
                    _shopSelector(),
                    const SizedBox(height: 20),
                  ],

                  // ── Show item selector only if not pre-selected ──
                  if (!_itemPreSelected) ...[
                    _sectionTitle('${_shopPreSelected ? "1" : "2"}. Select Items', Icons.shopping_bag_outlined),
                    const SizedBox(height: 10),
                    _itemSelector(),
                    const SizedBox(height: 20),
                  ],

                  // ── Date ──
                  _sectionTitle(
                    '${_shopPreSelected && _itemPreSelected ? "1" : _shopPreSelected || _itemPreSelected ? "2" : "3"}. Select Date',
                    Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 10),
                  _datePicker(),
                  const SizedBox(height: 20),

                  // ── Time ──
                  _sectionTitle(
                    '${_shopPreSelected && _itemPreSelected ? "2" : _shopPreSelected || _itemPreSelected ? "3" : "4"}. Select Time',
                    Icons.access_time_rounded,
                  ),
                  const SizedBox(height: 10),
                  _timePicker(),
                  const SizedBox(height: 20),

                  // ── Notes ──
                  _sectionTitle(
                    '${_shopPreSelected && _itemPreSelected ? "3" : _shopPreSelected || _itemPreSelected ? "4" : "5"}. Notes (Optional)',
                    Icons.notes_rounded,
                  ),
                  const SizedBox(height: 10),
                  _notesField(),
                  const SizedBox(height: 24),

                  _bookingButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info card for pre-selected values ──
  Widget _infoCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryOrange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryOrange.withOpacity(0.25)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 11)),
          Text(value, style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const Spacer(),
        Icon(Icons.check_circle_rounded, color: primaryOrange, size: 20),
      ]),
    );
  }

  Widget _navBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8)]),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Book a Visit', style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w800)),
            Text('Reserve your spot at the shop', style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 12)),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: primaryOrange.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(Icons.bookmark_outline_rounded, color: primaryOrange, size: 14),
              const SizedBox(width: 4),
              Text('New', style: TextStyle(color: primaryOrange, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      Icon(icon, color: primaryOrange, size: 18),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w800)),
    ]);
  }

  Widget _shopSelector() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Column(
        children: List.generate(_shops.length, (i) => Column(children: [
          GestureDetector(
            onTap: () => setState(() {
              _selectedShop = _shops[i];
              _selectedItems.clear();
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _selectedShop == _shops[i] ? primaryOrange : primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.store_rounded,
                      color: _selectedShop == _shops[i] ? Colors.white : primaryOrange, size: 18),
                ),
                const SizedBox(width: 12),
                Text(_shops[i], style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (_selectedShop == _shops[i])
                  Icon(Icons.check_circle_rounded, color: primaryOrange, size: 20),
              ]),
            ),
          ),
          if (i < _shops.length - 1)
            Divider(color: darkBrown.withOpacity(0.06), height: 1, indent: 16, endIndent: 16),
        ])),
      ),
    );
  }

  Widget _itemSelector() {
    if (_selectedShop == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
        child: Row(children: [
          Icon(Icons.info_outline_rounded, color: darkBrown.withOpacity(0.3), size: 18),
          const SizedBox(width: 10),
          Text('Select a shop first', style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 13)),
        ]),
      );
    }
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Column(
        children: List.generate(_currentItems.length, (i) => Column(children: [
          GestureDetector(
            onTap: () => setState(() {
              if (_selectedItems.contains(_currentItems[i])) {
                _selectedItems.remove(_currentItems[i]);
              } else {
                _selectedItems.add(_currentItems[i]);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: _selectedItems.contains(_currentItems[i]) ? primaryOrange : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _selectedItems.contains(_currentItems[i]) ? primaryOrange : darkBrown.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: _selectedItems.contains(_currentItems[i])
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(_currentItems[i], style: TextStyle(color: darkBrown, fontSize: 13.5, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
          if (i < _currentItems.length - 1)
            Divider(color: darkBrown.withOpacity(0.06), height: 1, indent: 16, endIndent: 16),
        ])),
      ),
    );
  }

  Widget _datePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.calendar_today_rounded, color: primaryOrange, size: 20),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Visit Date', style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 11)),
            Text(_selectedDate != null ? _formatDate(_selectedDate!) : 'Tap to select date',
                style: TextStyle(
                    color: _selectedDate != null ? darkBrown : darkBrown.withOpacity(0.3),
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, color: darkBrown.withOpacity(0.3), size: 20),
        ]),
      ),
    );
  }

  Widget _timePicker() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: _timeSlots.map((t) => GestureDetector(
        onTap: () => setState(() => _selectedTime = t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _selectedTime == t ? primaryOrange : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
          ),
          child: Text(t, style: TextStyle(
            color: _selectedTime == t ? Colors.white : darkBrown,
            fontSize: 13, fontWeight: FontWeight.w600,
          )),
        ),
      )).toList(),
    );
  }

  Widget _notesField() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: TextField(
        controller: _notesCtrl,
        maxLines: 3,
        cursorColor: primaryOrange,
        style: TextStyle(color: darkBrown, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Any special requests or notes...',
          hintStyle: TextStyle(color: darkBrown.withOpacity(0.35), fontSize: 13.5),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _bookingButton() {
    return GestureDetector(
      onTap: _submitBooking,
      child: Container(
        width: double.infinity, height: 54,
        decoration: BoxDecoration(
          gradient: _isFormValid
              ? LinearGradient(colors: [primaryOrange, const Color(0xFFA8481A)],
                  begin: Alignment.centerLeft, end: Alignment.centerRight)
              : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade300],
                  begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isFormValid
              ? [BoxShadow(color: primaryOrange.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]
              : [],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.bookmark_added_rounded,
              color: _isFormValid ? Colors.white : Colors.grey.shade500, size: 20),
          const SizedBox(width: 10),
          Text('Confirm Booking',
              style: TextStyle(
                  color: _isFormValid ? Colors.white : Colors.grey.shade500,
                  fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}