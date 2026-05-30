import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MasaPosApp());
}

class MasaPosApp extends StatelessWidget {
  const MasaPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MASA.POS // Masa Yönetimi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF07070F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F2FE),
          secondary: Color(0xFFEC008C),
          surface: Color(0xFF131325),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF131325).withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF00F2FE)),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// Order Item Model
class OrderItem {
  final String description;
  final double price;
  final String time;

  OrderItem({
    required this.description,
    required this.price,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'price': price,
        'time': time,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        time: json['time'] as String,
      );
}

// Table Model
class TableModel {
  final int number;
  List<OrderItem> orders;

  TableModel({
    required this.number,
    required this.orders,
  });

  double get totalAmount => orders.fold(0, (sum, item) => sum + item.price);
  bool get isActive => orders.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'number': number,
        'orders': orders.map((item) => item.toJson()).toList(),
      };

  factory TableModel.fromJson(Map<String, dynamic> json) {
    var orderList = json['orders'] as List;
    return TableModel(
      number: json['number'] as int,
      orders: orderList.map((item) => OrderItem.fromJson(item)).toList(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  final List<TableModel> _tables = List.generate(
    16,
    (index) => TableModel(number: index + 1, orders: []),
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTablesData();
  }

  // Get local file path for storage
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/tables_data.json');
  }

  // Load state from local storage JSON
  Future<void> _loadTablesData() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        
        setState(() {
          for (var i = 0; i < jsonList.length; i++) {
            final loadedTable = TableModel.fromJson(jsonList[i]);
            final index = _tables.indexWhere((t) => t.number == loadedTable.number);
            if (index != -1) {
              _tables[index] = loadedTable;
            }
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Data load error: $e");
    }
  }

  // Save state to local storage JSON
  Future<void> _saveTablesData() async {
    try {
      final file = await _getLocalFile();
      final jsonStr = jsonEncode(_tables.map((t) => t.toJson()).toList());
      await file.writeAsString(jsonStr);
    } catch (e) {
      debugPrint("Data save error: $e");
    }
  }

  // Calculate total checkout revenue
  double get _totalRevenue {
    return _tables.fold(0, (sum, table) => sum + table.totalAmount);
  }

  // Open detail sheet
  void _showTableDetails(TableModel table) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TableDetailsSheet(
          table: table,
          onUpdate: () {
            setState(() {});
            _saveTablesData();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background subtle aura
          Positioned(
            top: -200,
            right: -200,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F2FE).withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -200,
            left: -200,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEC008C).withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF00F2FE),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'MASA YÖNETİM SİSTEMİ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00F2FE).withOpacity(0.8),
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'AURA.POS',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      // Stats Container
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131325).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'AKTİF TOPLAM',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white.withOpacity(0.4),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₺${_totalRevenue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00F2FE),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // Tables Grid
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00F2FE),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: _tables.length,
                          itemBuilder: (context, index) {
                            final table = _tables[index];
                            return _buildTableCard(table);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(TableModel table) {
    return GestureDetector(
      onTap: () => _showTableDetails(table),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF131325).withOpacity(table.isActive ? 0.8 : 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: table.isActive
                ? const Color(0xFF00F2FE).withOpacity(0.4)
                : Colors.white.withOpacity(0.06),
            width: table.isActive ? 1.5 : 1,
          ),
          boxShadow: table.isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF00F2FE).withOpacity(0.06),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Interactive pulse accent at bottom
              if (table.isActive)
                Positioned(
                  bottom: -15,
                  right: -15,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00F2FE).withOpacity(0.1),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Masa ${table.number}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Status badge
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: table.isActive ? const Color(0xFF00F2FE) : Colors.white24,
                            boxShadow: table.isActive
                                ? [
                                    const BoxShadow(
                                      color: Color(0xFF00F2FE),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          table.isActive ? '${table.orders.length} Sipariş' : 'Boş',
                          style: TextStyle(
                            fontSize: 12,
                            color: table.isActive ? Colors.white70 : Colors.white30,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₺${table.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: table.isActive ? const Color(0xFF00F2FE) : Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Table Details Sheet
class TableDetailsSheet extends StatefulWidget {
  final TableModel table;
  final VoidCallback onUpdate;

  const TableDetailsSheet({
    super.key,
    required this.table,
    required this.onUpdate,
  });

  @override
  State<TableDetailsSheet> createState() => _TableDetailsSheetState();
}

class _TableDetailsSheetState extends State<TableDetailsSheet> {
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _descController.dispose();
    _priceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Quick Preset Additions
  void _addPresetAmount(double amount) {
    final current = double.tryParse(_priceController.text) ?? 0.0;
    _priceController.text = (current + amount).toStringAsFixed(0);
  }

  void _addOrderItem() {
    final desc = _descController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir tutar girin.'),
          backgroundColor: Color(0xFFEC008C),
        ),
      );
      return;
    }

    final itemDesc = desc.isEmpty ? 'Sipariş' : desc;
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      widget.table.orders.add(
        OrderItem(description: itemDesc, price: price, time: timeStr),
      );
    });

    _descController.clear();
    _priceController.clear();
    widget.onUpdate();

    // Scroll to bottom of list
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _deleteOrderItem(int index) {
    setState(() {
      widget.table.orders.removeAt(index);
    });
    widget.onUpdate();
  }

  void _checkoutTable() {
    if (widget.table.orders.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131325),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: Text('Masa ${widget.table.number} Kapatılsın mı?'),
        content: Text(
          'Toplam Tutar: ₺${widget.table.totalAmount.toStringAsFixed(2)}\n\nSipariş notları silinecek ve masa sıfırlanacaktır.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İPTAL', style: TextStyle(color: Colors.white30)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC008C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                widget.table.orders.clear();
              });
              widget.onUpdate();
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close sheet
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Masa ${widget.table.number} hesabı tahsil edildi ve kapatıldı.'),
                  backgroundColor: const Color(0xFF00F2FE),
                ),
              );
            },
            child: const Text('HESABI TAHSİL ET'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(top: 24, bottom: bottomInset + 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle and Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MASA DETAYI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00F2FE).withOpacity(0.8),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Masa ${widget.table.number}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white.withOpacity(0.5)),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Orders list
          Expanded(
            child: widget.table.orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 64,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Masa Boş',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.table.orders.length,
                    itemBuilder: (context, index) {
                      final item = widget.table.orders[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.time,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '₺${item.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Color(0xFF00F2FE),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _deleteOrderItem(index),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFFEC008C),
                                    size: 20,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Action input section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF131325).withOpacity(0.5),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _descController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Sipariş Notu (örn: Çay, Tost)',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: 'Tutar (₺)',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Preset amount buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPresetBtn(10),
                    _buildPresetBtn(20),
                    _buildPresetBtn(50),
                    _buildPresetBtn(100),
                    _buildPresetBtn(200),
                  ],
                ),
                const SizedBox(height: 16),

                // Save & checkout buttons
                Row(
                  children: [
                    if (widget.table.orders.isNotEmpty)
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEC008C)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: _checkoutTable,
                          child: const Text(
                            'MASAYI KAPAT',
                            style: TextStyle(
                              color: Color(0xFFEC008C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (widget.table.orders.isNotEmpty) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00F2FE),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _addOrderItem,
                        child: const Text(
                          'SİPARİŞ EKLE',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPresetBtn(double amount) {
    return GestureDetector(
      onTap: () => _addPresetAmount(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Text(
          '+₺${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00F2FE),
          ),
        ),
      ),
    );
  }
}
