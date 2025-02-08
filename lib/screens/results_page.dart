import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:product_pulse/screens/homeScreen.dart';
import 'package:product_pulse/screens/scan_screen.dart';
import '../models/product_info.dart';
import 'dart:io';

import '../widgets/uploadFile.dart';

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
  String? _editedName;
  String? _editedDescription;
  File? _imageFile;
  bool _isEditingDate = false;
  bool _isEditingName = false;
  bool _isEditingDescription = false;
  final _dateController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentExpiryDate = widget.expiryDate;
    _editedName = widget.productInfo?.name;
    _editedDescription = widget.productInfo?.description;

    if (widget.productInfo?.imageUrl != null && widget.productInfo!.imageUrl!.isNotEmpty) {
      if (widget.productInfo!.imageUrl!.startsWith('http')) {
        _imageFile = null; // If it's a network URL
      } else {
        _imageFile = File(widget.productInfo!.imageUrl!); // Local path
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
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

  Future<void> _editImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to save data!')),
      );
      return;
    }

    try {
      String? imageUrl = widget.productInfo?.imageUrl; // Get existing URL

      // Upload only if a new local image is picked
      if (_imageFile != null) {
        imageUrl = await UploadService.uploadImageToCloudinary(_imageFile!);
      }

      // Save product data to Firestore
      await firestore.collection('users').doc(user.uid).collection('products').add({
        'barcodeId': widget.barcodeId,
        'expiryDate': _currentExpiryDate,
        'scannedText': widget.scannedText,
        'productName': _editedName ?? widget.productInfo?.name,
        'description': _editedDescription ?? widget.productInfo?.description,
        'imageUrl': imageUrl ?? 'assets/images/dummy/img.png', // Keep asset images as is
        'timestamp': FieldValue.serverTimestamp(),
      });

      await firestore.collection('publicProducts').add({
        'barcodeId': widget.barcodeId,
        'expiryDate': _currentExpiryDate,
        'scannedText': widget.scannedText,
        'productName': _editedName ?? widget.productInfo?.name,
        'description': _editedDescription ?? widget.productInfo?.description,
        'imageUrl': imageUrl ?? 'assets/images/dummy/img.png', // Keep asset images as is
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product saved successfully!')),
      );

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


  Future<void> _saveToFirestore2() async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to save data!')),
      );
      return;
    }

    try {
      String? imageUrl = widget.productInfo?.imageUrl; // Get existing URL

      // Upload only if a new local image is picked
      if (_imageFile != null) {
        imageUrl = await UploadService.uploadImageToCloudinary(_imageFile!);
      }

      // Save product data to Firestore
      await firestore.collection('users').doc(user.uid).collection('products').add({
        'barcodeId': widget.barcodeId,
        'expiryDate': _currentExpiryDate,
        'scannedText': widget.scannedText,
        'productName': _editedName ?? widget.productInfo?.name,
        'description': _editedDescription ?? widget.productInfo?.description,
        'imageUrl': imageUrl ?? 'assets/images/dummy/img.png', // Keep asset images as is
        'timestamp': FieldValue.serverTimestamp(),
      });

      await firestore.collection('publicProducts').add({
        'barcodeId': widget.barcodeId,
        'expiryDate': _currentExpiryDate,
        'scannedText': widget.scannedText,
        'productName': _editedName ?? widget.productInfo?.name,
        'description': _editedDescription ?? widget.productInfo?.description,
        'imageUrl': imageUrl ?? 'assets/images/dummy/img.png', // Keep asset images as is
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product saved successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
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
                // Image display/edit
                if (_imageFile != null)
                  Center(
                    child: Image.file(
                      _imageFile!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (widget.productInfo?.imageUrl != null && widget.productInfo!.imageUrl!.isNotEmpty)
                  Center(
                    child: widget.productInfo!.imageUrl!.startsWith('http') // Check if it's a URL
                        ? Image.network(
                      widget.productInfo!.imageUrl!,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Icon(Icons.error, color: Colors.red));
                      },
                    )
                        : Image.asset(
                      widget.productInfo!.imageUrl!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Center(
                    child: Image.asset(
                      'assets/images/dummy/img.png',
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                IconButton(
                  icon: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('edit image', style: TextStyle(color: Colors.blue),),
                      SizedBox(width: 5,),
                      Icon(Icons.edit),
                    ],
                  ),
                  onPressed: _editImage,
                  tooltip: 'Change Image',
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),

                // Product Name
                if (_isEditingName) ...[
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Product Name'),
                    onChanged: (value) {
                      setState(() {
                        _editedName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Text(
                    'Product Name',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _editedName ?? 'No name available',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _isEditingName = true;
                          });
                        },
                        tooltip: 'Edit Name',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Product Description
                if (_isEditingDescription) ...[
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    onChanged: (value) {
                      setState(() {
                        _editedDescription = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _editedDescription ?? 'No description available',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _isEditingDescription = true;
                          });
                        },
                        tooltip: 'Edit Description',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Barcode ID
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

                // Expiry Date
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
                        color: Colors.blue,
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed:  _saveToFirestore,
                child: const Text('Save & Scan'),
              ),
              ElevatedButton(
                onPressed:_saveToFirestore2,
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
