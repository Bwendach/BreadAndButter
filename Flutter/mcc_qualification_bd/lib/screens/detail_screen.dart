import 'package:bread_and_butter/apis/api.dart';
import 'package:bread_and_butter/models/review_model.dart';
import 'package:bread_and_butter/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:bread_and_butter/models/menu_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final MenuModel menu;

  const DetailScreen({super.key, required this.menu});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<List<ReviewModel>> _reviewsFuture;
  final TextEditingController _reviewController = TextEditingController();
  final FocusNode _reviewFocusNode = FocusNode();
  String? _userId;
  ReviewModel? _userReview;
  double _selectedRating = 5.0;
  bool _isEditingReview = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _reviewFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadUserId();
    setState(() {
      _reviewsFuture = _fetchReviews();
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    print('Loaded userId: $_userId'); // Debug print
  }

  Future<List<ReviewModel>> _fetchReviews() async {
    try {
      final reviewsData = await getReviews(widget.menu.menuId);
      final reviews = reviewsData
          .map((json) => ReviewModel.fromJson(json))
          .toList();

      print('Fetched ${reviews.length} reviews'); // Debug print
      print('Current userId: $_userId'); // Debug print

      // Check if current user has a review
      if (_userId != null) {
        try {
          _userReview = reviews.firstWhere((review) {
            print(
              'Comparing ${review.userId.toString()} with $_userId',
            ); // Debug print
            return review.userId.toString() == _userId;
          });

          print('Found user review: ${_userReview?.reviewId}'); // Debug print

          // Remove user review from the list to add it at the top later
          reviews.removeWhere((review) => review.userId.toString() == _userId);
        } catch (e) {
          print('No user review found: $e'); // Debug print
          _userReview = null;
        }
      }

      setState(() {
        _isLoading = false;
      });

      return reviews;
    } catch (e) {
      print('Error fetching reviews: $e'); // Debug print
      setState(() {
        _isLoading = false;
      });
      rethrow;
    }
  }

  Future<void> _createReview() async {
    if (_reviewController.text.isEmpty) {
      showSnackBar(context, 'Review cannot be empty.');
      _reviewFocusNode.requestFocus();
      return;
    }
    if (_userId == null) {
      showSnackBar(context, 'You must be logged in to post a review.');
      return;
    }

    try {
      await createReview(
        menuId: widget.menu.menuId,
        userId: _userId!,
        reviewText: _reviewController.text,
        rating: _selectedRating,
      );
      _reviewController.clear();
      _selectedRating = 5.0;
      showSnackBar(context, 'Review submitted successfully!');
      setState(() {
        _reviewsFuture = _fetchReviews();
      });
    } catch (e) {
      showSnackBar(context, 'Failed to submit review: $e');
    }
  }

  Future<void> _updateReview() async {
    if (_reviewController.text.isEmpty) {
      showSnackBar(context, 'Review cannot be empty.');
      _reviewFocusNode.requestFocus();
      return;
    }

    try {
      await updateReview(
        reviewId: _userReview!.reviewId,
        reviewText: _reviewController.text,
        rating: _selectedRating,
      );
      _reviewController.clear();
      _selectedRating = 5.0;
      _isEditingReview = false;
      showSnackBar(context, 'Review updated successfully!');
      setState(() {
        _reviewsFuture = _fetchReviews();
      });
    } catch (e) {
      showSnackBar(context, 'Failed to update review: $e');
    }
  }

  Future<void> _deleteReview() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete your review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await deleteReview(_userReview!.reviewId);
        _reviewController.clear();
        _selectedRating = 5.0;
        _isEditingReview = false;
        showSnackBar(context, 'Review deleted successfully!');
        setState(() {
          _reviewsFuture = _fetchReviews();
        });
      } catch (e) {
        showSnackBar(context, 'Failed to delete review: $e');
      }
    }
  }

  void _startEditingReview() {
    setState(() {
      _isEditingReview = true;
      _reviewController.text = _userReview!.reviewContent;
      _selectedRating = _userReview!.reviewRating.toDouble();
    });
  }

  void _cancelEditingReview() {
    setState(() {
      _isEditingReview = false;
      _reviewController.clear();
      _selectedRating = 5.0;
    });
  }

  Widget _buildRatingPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rating:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final rating = index + 1;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = rating.toDouble();
                });
              },
              child: Icon(
                Icons.star,
                size: 30,
                color: rating <= _selectedRating
                    ? Colors.amber
                    : Colors.grey[300],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text('${_selectedRating.toInt()}/5 stars'),
      ],
    );
  }

  Widget _buildUserReviewCard() {
    if (_userReview == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Your Review',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: _startEditingReview,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteReview,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 20,
                  color: index < _userReview!.reviewRating
                      ? Colors.amber
                      : Colors.grey[300],
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(_userReview!.reviewContent),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = '$URLPATH/assets/${widget.menu.menuImageUrl}';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.menu.menuName),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info), text: 'Details'),
              Tab(icon: Icon(Icons.reviews), text: 'Reviews'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- Details Tab ---
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      imageUrl,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, _) {
                        return const Icon(Icons.broken_image, size: 100);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.menu.menuName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.menu.menuPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.menu.menuDescription,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),

                  // Show loading indicator while checking for user review
                  if (_isLoading) ...[
                    const Center(child: CircularProgressIndicator()),
                  ] else if (_userReview == null) ...[
                    const Text(
                      'Leave a Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRatingPicker(),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reviewController,
                      focusNode: _reviewFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Enter your review here...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _createReview,
                        child: const Text('Submit Review'),
                      ),
                    ),
                  ] else if (_isEditingReview) ...[
                    const Text(
                      'Edit Your Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRatingPicker(),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reviewController,
                      focusNode: _reviewFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Enter your review here...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _cancelEditingReview,
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _updateReview,
                          child: const Text('Update Review'),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Show user's existing review
                    _buildUserReviewCard(),
                  ],
                ],
              ),
            ),

            // --- Reviews Tab ---
            FutureBuilder<List<ReviewModel>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    _isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    (snapshot.data!.isEmpty && _userReview == null)) {
                  return const Center(
                    child: Text('No reviews yet. Be the first!'),
                  );
                } else {
                  final reviews = snapshot.data!;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // User's review at the top
                      _buildUserReviewCard(),

                      // Other reviews
                      ...reviews
                          .map(
                            (review) => FutureBuilder<String>(
                              future: getUsername(review.userId.toString()),
                              builder: (context, userSnapshot) {
                                final username = userSnapshot.hasData
                                    ? userSnapshot.data!
                                    : 'Loading...';
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              Icons.star,
                                              size: 16,
                                              color: index < review.reviewRating
                                                  ? Colors.amber
                                                  : Colors.grey[300],
                                            );
                                          }),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(review.reviewContent),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                          .toList(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
