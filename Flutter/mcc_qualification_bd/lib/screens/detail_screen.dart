import 'package:bread_and_butter/apis/api.dart';
import 'package:bread_and_butter/models/review_model.dart';
import 'package:bread_and_butter/utils/colors.dart';
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
  }

  Future<List<ReviewModel>> _fetchReviews() async {
    try {
      final reviewsData = await getReviews(widget.menu.menuId);
      final reviews = reviewsData
          .map((json) => ReviewModel.fromJson(json))
          .toList();

      if (_userId != null) {
        try {
          _userReview = reviews.firstWhere((review) {
            return review.userId.toString() == _userId;
          });
          reviews.removeWhere((review) => review.userId.toString() == _userId);
        } catch (e) {
          _userReview = null;
        }
      }

      setState(() {
        _isLoading = false;
      });

      return reviews;
    } catch (e) {
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
        Text(
          'Your Rating:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
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
                size: 32,
                color: rating <= _selectedRating
                    ? softYellow
                    : Theme.of(context).dividerColor,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildUserReviewCard() {
    if (_userReview == null) return const SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Your Review',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: _startEditingReview,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: _deleteReview,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 24,
                  color: index < _userReview!.reviewRating
                      ? softYellow
                      : Theme.of(context).dividerColor,
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              _userReview!.reviewContent,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewInputSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userReview == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewHeader('Leave a Review'),
          const SizedBox(height: 16),
          _buildRatingPicker(),
          const SizedBox(height: 16),
          TextField(
            controller: _reviewController,
            focusNode: _reviewFocusNode,
            decoration: InputDecoration(
              hintText: 'Enter your review here...',
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _createReview,
              icon: const Icon(Icons.send),
              label: const Text('Submit Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      );
    } else if (_isEditingReview) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewHeader('Edit Your Review'),
          const SizedBox(height: 16),
          _buildRatingPicker(),
          const SizedBox(height: 16),
          TextField(
            controller: _reviewController,
            focusNode: _reviewFocusNode,
            decoration: InputDecoration(
              hintText: 'Enter your review here...',
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _cancelEditingReview,
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _updateReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Update Review'),
              ),
            ],
          ),
        ],
      );
    } else {
      return _buildUserReviewCard();
    }
  }

  Widget _buildReviewHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
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
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
            indicatorColor: Theme.of(context).colorScheme.onPrimary,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.info), text: 'Details'),
              Tab(icon: Icon(Icons.reviews), text: 'Reviews'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- Details Tab ---
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, _) {
                        return Container(
                          height: 250,
                          color: Theme.of(context).colorScheme.surface,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.menu.menuName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.menu.menuPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.menu.menuDescription,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 24),
                  _buildReviewInputSection(),
                ],
              ),
            ),

            // --- Reviews Tab ---
            FutureBuilder<List<ReviewModel>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || (snapshot.data!.isEmpty && _userReview == null)) {
                  return const Center(
                    child: Text('No reviews yet. Be the first!'),
                  );
                } else {
                  final reviews = snapshot.data!;
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildUserReviewCard(),
                      ...reviews.map((review) => FutureBuilder<String>(
                            future: getUsername(review.userId.toString()),
                            builder: (context, userSnapshot) {
                              final username = userSnapshot.hasData ? userSnapshot.data! : 'Loading...';
                              return Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        username,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: List.generate(5, (index) {
                                          return Icon(
                                            Icons.star,
                                            size: 18,
                                            color: index < review.reviewRating
                                                ? softYellow
                                                : Theme.of(context).dividerColor,
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        review.reviewContent,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )),
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