
-- Seed users: 1 admin and 5 regular users
INSERT INTO users (username, role, email, password) VALUES
('admin', 'admin', 'admin@gmail.com', 'admin123'),
('brenda', 'user', 'brenda@gmail.com', 'brenda123'),
('helena', 'user', 'helena@gmail.com', 'helena123'),
('celine', 'user', 'celine@gmail.com', 'celine123'),
('agnes', 'user', 'agnes@gmail.com', 'agnes123'),
('komang', 'user', 'komang@gmail.com', 'komang123');


-- Seed menu with 8 items from the uploaded images
INSERT INTO menu (menuName, menuDescription, menuImageUrl, menuPrice) VALUES
('Avocado Toast', 'Toasted sourdough bread topped with mashed avocado, chili flakes, and a squeeze of lime.', 'avocado_toast.jpg', 8.50),
('Matcha Latte', 'A creamy and vibrant green tea latte, made with high-quality matcha powder and steamed milk.', 'matcha_latte.jpg', 6.00),
('Croissant', 'A classic French pastry with a golden, flaky crust and a soft, buttery interior.', 'croissant.jpg', 4.25),
('Flan', 'A classic rich and creamy custard with a caramel sauce topping.', 'flan.jpg', 5.50),
('Seasonal Fruit Tart', 'A delicate pastry crust filled with crème pâtissière and topped with an assortment of fresh seasonal fruits.', 'fruit_tart.jpg', 6.75),
('Strawberry Shortcake', 'Layers of light sponge cake, fresh strawberries, and sweet whipped cream.', 'strawberry_shortcake.jpg', 7.00),
('Matcha Crepe Cake', 'Thin layers of matcha-flavored crepes layered with rich cream and a dusting of matcha powder.', 'matcha_crepe_cake.jpg', 8.50),
('Strawberry Croissant', 'A buttery croissant filled with a sweet strawberry cream and topped with fresh strawberry slices.', 'strawberry_croissant.jpg', 5.25);

-- Reviews for 'Avocado Toast' (menuId = 1)
INSERT INTO menu_reviews (menuId, userId, reviewContent, reviewRating) VALUES
(1, 2, 'The perfect breakfast! So fresh and flavorful.', 5),
(1, 3, 'A bit spicy for my taste, but still a solid option.', 4),
(1, 4, 'Great value and delicious. My go-to order.', 5);

-- Reviews for 'Matcha Latte' (menuId = 2)
INSERT INTO menu_reviews (menuId, userId, reviewContent, reviewRating) VALUES
(2, 6, 'Rich and creamy, just the way I like it.', 5),
(2, 3, 'Good matcha flavor, not too sweet.', 4),
(2, 2, 'My favorite drink here, so smooth!', 5);

-- Reviews for 'Croissant' (menuId = 3)
INSERT INTO menu_reviews (menuId, userId, reviewContent, reviewRating) VALUES
(3, 4, 'Flaky and buttery, but a little small.', 4),
(3, 5, 'Perfectly baked, a true classic.', 5),
(3, 6, 'A decent croissant, but I prefer the strawberry one.', 3);

-- Reviews for 'Flan' (menuId = 4)
INSERT INTO menu_reviews (menuId, userId, reviewContent, reviewRating) VALUES
(4, 5, 'The texture is perfect and the caramel is heavenly.', 5),
(4, 3, 'Not a big fan of flan, but this one is well made.', 3),
(4, 2, 'A fantastic dessert option, so creamy.', 5);

-- Reviews for 'Seasonal Fruit Tart' (menuId = 5)
INSERT INTO menu_reviews (menuId, userId, reviewContent, reviewRating) VALUES
(5, 6, 'Love the fresh fruits and the crispy crust.', 5),
(5, 4, 'A little bit messy to eat, but it tastes great.', 4),
(5, 3, 'The best part is the rich cream filling!', 5);

-- Reviews for 'Strawberry Shortcake' (menuId = 6)
INSERT INTO menu_reviews (menuId, userId, reviewContent, reviewRating) VALUES
(6, 2, 'Light, fluffy, and full of fresh strawberries. Amazing!', 5),
(6, 5, 'A great classic dessert, very well executed.', 4),
(6, 6, 'The cake is a bit dry, but the whipped cream is good.', 3);

-- Reviews for 'Matcha Crepe Cake' (menuId = 7)
INSERT INTO menu_reviews (menuId, userId, reviewContent, reviewRating) VALUES
(7, 4, 'So many layers! Tastes as good as it looks.', 5),
(7, 3, 'The matcha flavor is a little strong for me.', 3),
(7, 5, 'A unique and delicious cake. Must-try!', 5);

-- Reviews for 'Strawberry Croissant' (menuId = 8)
INSERT INTO menu_reviews (menuId, userId, reviewContent, reviewRating) VALUES
(8, 2, 'The strawberry cream is amazing, and it\'s very fresh.', 5),
(8, 6, 'A nice twist on a regular croissant.', 4),
(8, 4, 'This is my new favorite pastry!', 5);