import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/product_info.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/uploadFile.dart';
import '../screens/results_page.dart';

class ManualEntryPage extends StatefulWidget {
  final String? expiryDate;

  const ManualEntryPage({
    Key? key,
    this.expiryDate,
  }) : super(key: key);

  @override
  State<ManualEntryPage> createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends State<ManualEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  final FlutterTts flutterTts = FlutterTts();
  bool _isEditingName = false;
  bool _isEditingDescription = false;
  String? _currentExpiryDate;

  @override
  void initState() {
    super.initState();
    _currentExpiryDate = widget.expiryDate;
    _initTts();
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
      });
    }
  }

  Future<void> _navigateToResults() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to continue')),
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

      // Handle image upload
      String imageUrl = 'assets/images/dummy/img.png';
      if (_selectedImage != null) {
        try {
          imageUrl = await UploadService.uploadImageToCloudinary(_selectedImage!);
        } catch (e) {
          print('Error uploading image: $e');
        }
      }

      // Create ProductInfo object
      final productInfo = ProductInfo(
        name: _nameController.text.isNotEmpty 
            ? _nameController.text 
            : 'No name available',
        description: _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : 'No description available',
        imageUrl: imageUrl,
        brand: '',
        category: '',
        manufacturer: '',
        stores: '',
        price: '0',
      );

      // Close loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      // Navigate to ResultsPage with the product info
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(
              productInfo: productInfo,
              expiryDate: _currentExpiryDate ?? 'Not set',
              scannedText: '',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error preparing product: $e');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleNameEdit(bool editing) {
    setState(() {
      _isEditingName = editing;
      if (!editing) {
        // Save the changes when exiting edit mode
        if (_nameController.text.isEmpty) {
          _nameController.text = 'No name available';
        }
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Product Details'),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Name Field
                if (_isEditingName) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                    onEditingComplete: () => _toggleNameEdit(false),
                    onFieldSubmitted: (_) => _toggleNameEdit(false),
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
                        child: Text(_nameController.text.isEmpty 
                          ? 'No name available' 
                          : _nameController.text
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _speak(_nameController.text),
                        color: Colors.blue,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _toggleNameEdit(true),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Description Field
                if (_isEditingDescription) ...[
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onEditingComplete: () => _toggleDescriptionEdit(false),
                    onFieldSubmitted: (_) => _toggleDescriptionEdit(false),
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
                        child: Text(_descriptionController.text.isEmpty 
                          ? 'No description available' 
                          : _descriptionController.text
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _speak(_descriptionController.text),
                        color: Colors.blue,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _toggleDescriptionEdit(true),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Image Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (_selectedImage != null) ...[
                          Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 8),
                        ],
                        ElevatedButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(Icons.add_a_photo),
                          label: Text(_selectedImage == null 
                            ? 'Add Product Image' 
                            : 'Change Image'
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Expiry Date Section
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
                            onPressed: () => _speak('Expiry date is $_currentExpiryDate'),
                            color: Colors.blue,
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _editExpiryDate,
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

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _navigateToResults,
            child: const Text('Review & Save'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 