import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:product_pulse/screens/homeScreen.dart';
import 'package:product_pulse/screens/scan_screen.dart';
import '../models/product_info.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

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
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _currentExpiryDate = widget.expiryDate;
    _editedName = widget.productInfo?.name;
    _editedDescription = widget.productInfo?.description;
    
    // Initialize controllers with existing values
    _nameController.text = _editedName ?? '';
    _descriptionController.text = _editedDescription ?? '';

    if (widget.productInfo?.imageUrl != null && widget.productInfo!.imageUrl!.isNotEmpty) {
      if (widget.productInfo!.imageUrl!.startsWith('http')) {
        _imageFile = null;
      } else {
        _imageFile = File(widget.productInfo!.imageUrl!);
      }
    }
    _initTts();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    flutterTts.stop();
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
    if (!mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to save products')),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      String? imageUrl;
      // Handle image upload first
      if (_imageFile != null) {
        try {
          imageUrl = await UploadService.uploadImageToCloudinary(_imageFile!);
        } catch (e) {
          print('Error uploading image: $e');
          imageUrl = 'assets/images/dummy/img.png';
        }
      }

      // Prepare product data with all required fields
      final productData = {
        if (widget.barcodeId != null && widget.barcodeId!.isNotEmpty)
          'barcodeId': widget.barcodeId,
        'productName': _nameController.text.isNotEmpty 
            ? _nameController.text 
            : (widget.productInfo?.name ?? 'No name'),
        'description': _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : (widget.productInfo?.description ?? ''),
        'expiryDate': _currentExpiryDate,
        'scannedText': widget.scannedText,
        'imageUrl': imageUrl ?? widget.productInfo?.imageUrl ?? 'assets/images/dummy/img.png',
        'timestamp': FieldValue.serverTimestamp(),
        'brand': widget.productInfo?.brand ?? '',
        'category': widget.productInfo?.category ?? '',
        'manufacturer': widget.productInfo?.manufacturer ?? '',
        'stores': widget.productInfo?.stores ?? '',
        'price': widget.productInfo?.price ?? '',
      };

      // Use batch write
      final batch = FirebaseFirestore.instance.batch();
      
      // Add to user's products
      final userProductRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .doc();
      batch.set(userProductRef, productData);

      // Add to public products
      final publicProductRef = FirebaseFirestore.instance
          .collection('publicProducts')
          .doc();
      batch.set(publicProductRef, productData);

      // Commit batch
      await batch.commit();

      if (!mounted) return;

      // Close loading indicator
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product saved successfully!')),
      );

      // Navigate to scan screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScanScreen(source: ImageSource.camera),
        ),
      );
    } catch (e) {
      print('Error saving product: $e'); // Add logging
      // Close loading indicator if open
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
        );
      }
    }
  }

  Future<void> _saveToFirestore2() async {
    if (!mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to save products')),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      String? imageUrl;
      // Handle image upload first
      if (_imageFile != null) {
        try {
          imageUrl = await UploadService.uploadImageToCloudinary(_imageFile!);
        } catch (e) {
          print('Error uploading image: $e');
          imageUrl = 'assets/images/dummy/img.png';
        }
      }

      // Prepare product data with all required fields
      final productData = {
        if (widget.barcodeId != null && widget.barcodeId!.isNotEmpty)
          'barcodeId': widget.barcodeId,
        'productName': _nameController.text.isNotEmpty 
            ? _nameController.text 
            : (widget.productInfo?.name ?? 'No name'),
        'description': _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : (widget.productInfo?.description ?? ''),
        'expiryDate': _currentExpiryDate,
        'scannedText': widget.scannedText,
        'imageUrl': imageUrl ?? widget.productInfo?.imageUrl ?? 'assets/images/dummy/img.png',
        'timestamp': FieldValue.serverTimestamp(),
        'brand': widget.productInfo?.brand ?? '',
        'category': widget.productInfo?.category ?? '',
        'manufacturer': widget.productInfo?.manufacturer ?? '',
        'stores': widget.productInfo?.stores ?? '',
        'price': widget.productInfo?.price ?? '',
      };

      // Use batch write
      final batch = FirebaseFirestore.instance.batch();
      
      // Add to user's products
      final userProductRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .doc();
      batch.set(userProductRef, productData);

      // Add to public products
      final publicProductRef = FirebaseFirestore.instance
          .collection('publicProducts')
          .doc();
      batch.set(publicProductRef, productData);

      // Commit batch
      await batch.commit();

      if (!mounted) return;

      // Close loading indicator
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product saved successfully!')),
      );

      // Navigate to home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Error saving product: $e'); // Add logging
      // Close loading indicator if open
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
        );
      }
    }
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _toggleNameEdit(bool editing) {
    setState(() {
      _isEditingName = editing;
      if (!editing) {
        // Save the changes when exiting edit mode
        if (_nameController.text.isEmpty) {
          _nameController.text = 'No name available';
        }
        _editedName = _nameController.text;
      }
    });
  }

  void _toggleDescriptionEdit(bool editing) {
    setState(() {
      _isEditingDescription = editing;
      if (!editing) {
        // Save the changes when exiting edit mode
        if (_descriptionController.text.isEmpty) {
          _descriptionController.text = 'No description available';
        }
        _editedDescription = _descriptionController.text;
      }
    });
  }

  Future<void> _deleteAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to delete data!')),
      );
      return;
    }

    try {
      final batch = firestore.batch();
      
      // Get references to documents to delete
      final userProductsQuery = firestore
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .where('productName', isEqualTo: widget.productInfo?.name)
          .limit(10); // Limit for safety

      final publicProductsQuery = firestore
          .collection('publicProducts')
          .where('productName', isEqualTo: widget.productInfo?.name)
          .limit(10); // Limit for safety

      // Get the documents
      final userDocs = await userProductsQuery.get();
      final publicDocs = await publicProductsQuery.get();

      // Add delete operations to batch
      for (var doc in userDocs.docs) {
        batch.delete(doc.reference);
      }
      for (var doc in publicDocs.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteAndNavigate,
            color: Colors.red,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard and exit edit mode when tapping outside
          FocusScope.of(context).unfocus();
          _toggleNameEdit(false);
          _toggleDescriptionEdit(false);
        },
        child: SingleChildScrollView(
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
                      onEditingComplete: () => _toggleNameEdit(false),
                      onSubmitted: (_) => _toggleNameEdit(false),
                      onChanged: (value) {
                        _editedName = value;
                      },
                    ),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _editedName ?? 'No name available',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up),
                                onPressed: () => _speak(_editedName ?? 'No name available'),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _toggleNameEdit(true),
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
                      onEditingComplete: () => _toggleDescriptionEdit(false),
                      onSubmitted: (_) => _toggleDescriptionEdit(false),
                      onChanged: (value) {
                        _editedDescription = value;
                      },
                    ),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _editedDescription ?? 'No description available',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up),
                                onPressed: () => _speak(_editedDescription ?? 'No description available'),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _toggleDescriptionEdit(true),
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
                      Row(
                        children: [
                          if (_currentExpiryDate != null)
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () => _speak('Expiry date is ${_currentExpiryDate}'),
                              color: Colors.blue,
                            ),
                          if (!_isEditingDate)
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: _editExpiryDate,
                              tooltip: 'Edit Date',
                              color: Colors.blue,
                            ),
                        ],
                      ),
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
