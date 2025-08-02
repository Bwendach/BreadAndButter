class ReviewModel {
  int reviewId;
  int menuId;
  int userId;
  String reviewContent;
  int reviewRating;

  ReviewModel({
    required this.reviewId,
    required this.menuId,
    required this.userId,
    required this.reviewContent,
    required this.reviewRating,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: json['reviewId'] ?? 0,
      menuId: json['menuId'] ?? 0,
      userId: json['userId'] ?? '',
      reviewContent: json['reviewContent'] ?? '',
      reviewRating: json['reviewRating'] ?? 0,
    );
  }
}
