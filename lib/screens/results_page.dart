import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/screens/scan_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_info.dart';
import 'dart:io';

class ResultsPage extends StatefulWidget {
  final String? barcodeId;
  final String? expiryDate;
  final String scannedText;
  final ProductInfo? productInfo;

  const ResultsPage({
    Key? key,
    this.barcodeId,
    this.expiryDate,
    required this.scannedText,
    this.productInfo,
  }) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  String? _currentExpiryDate;
  bool _isEditingDate = false;
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentExpiryDate = widget.expiryDate;
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _editExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      setState(() {
        _currentExpiryDate = "${picked.day}/${picked.month}/${picked.year}";
        _isEditingDate = false;
      });
    }
  }

  Future<void> _saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user == null) {
      // If no user is logged in, show an error or handle it accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to save data!')),
      );
      return;
    }

    final productData = {
      'barcodeId': widget.barcodeId,
      'expiryDate': _currentExpiryDate,
      'scannedText': widget.scannedText,
      'productName': widget.productInfo?.name,
      'description': widget.productInfo?.description,
      'imageUrl': widget.productInfo?.imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      // Save under the user's UID
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .add(productData);

      // Save publicly
      await firestore.collection('publicProducts').add(productData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product saved successfully!')),
      );

      // Navigate to the ScanScreen after saving
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanScreen(source: ImageSource.camera),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.productInfo?.imageUrl != null &&
                    widget.productInfo!.imageUrl.isNotEmpty) ...[
                  Center(
                    child: widget.productInfo!.imageUrl.startsWith('http')
                        ? Image.network(
                      widget.productInfo!.imageUrl,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                    )
                        : Image.file(
                      File(widget.productInfo!.imageUrl),
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (widget.productInfo?.name != null) ...[
                  Text(
                    'Product Name',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.productInfo!.name),
                  const SizedBox(height: 16),
                ],
                if (widget.productInfo?.description != null) ...[
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.productInfo!.description),
                  const SizedBox(height: 16),
                ],
                if (widget.barcodeId != null) ...[
                  Text(
                    'Barcode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.barcodeId!),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expiry Date',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!_isEditingDate) ...[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _editExpiryDate,
                        tooltip: 'Edit Date',
                      ),
                    ],
                  ],
                ),
                if (_currentExpiryDate != null)
                  Text(_currentExpiryDate!)
                else
                  TextButton.icon(
                    onPressed: _editExpiryDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Add Expiry Date'),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveToFirestore,
        tooltip: 'Save',
        child: const Icon(Icons.save),
      ),
    );
  }
}