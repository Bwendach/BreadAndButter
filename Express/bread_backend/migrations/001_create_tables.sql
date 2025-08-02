-- Create users table
CREATE TABLE IF NOT EXISTS users (
    userId INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    token VARCHAR(255)
);

-- Create menu table
CREATE TABLE IF NOT EXISTS menu (
    menuId INT AUTO_INCREMENT PRIMARY KEY,
    menuName VARCHAR(100) NOT NULL,
    menuDescription TEXT,
    menuImageUrl VARCHAR(255),
    menuPrice DECIMAL(10,2) NOT NULL
);

-- Create menu_reviews table
CREATE TABLE IF NOT EXISTS menu_reviews (
    reviewId INT AUTO_INCREMENT PRIMARY KEY,
    menuId INT NOT NULL,
    userId INT NOT NULL,
    reviewContent TEXT,
    reviewRating INT CHECK (reviewRating >= 1 AND reviewRating <= 10),
    FOREIGN KEY (menuId) REFERENCES menu(menuId) ON DELETE CASCADE,
    FOREIGN KEY (userId) REFERENCES users(userId) ON DELETE CASCADE
);
