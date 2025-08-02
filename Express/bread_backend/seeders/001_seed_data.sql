-- Seed users (3 users, 1 admin)
INSERT INTO users (username, role, email, password) VALUES
('admin', 'admin', 'admin@gmail.com', 'admin123'),
('user', 'user', 'user@gmail.com', 'user123'),
('celine', 'user', 'celine@gmail.com', 'celine123');

-- Seed menu (4 menu items)
INSERT INTO menu (menuName, menuDescription, menuImageUrl, menuPrice) VALUES
('Bread Classic', 'Classic white bread', 'bread1.jpg', 2.50),
('Whole Wheat', 'Healthy whole wheat bread', 'bread2.jpg', 3.00),
('Sourdough', 'Tangy sourdough bread', 'bread3.jpg', 3.50),
('Baguette', 'French style baguette', 'bread4.jpg', 2.75);

-- Seed menu_reviews (minimal example)
INSERT INTO menu_reviews (menuId, userId, reviewContent, reviewRating) VALUES
(1, 2, 'Great bread!', 9),
(2, 3, 'Very healthy.', 8);
