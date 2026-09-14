-- ====================================================================
-- V3: MASSIVE MENU EXPANSION — 120+ Items (Mains, Desserts & More)
-- BenedictJeromeMart — Run this after V1 and V2
-- ====================================================================

-- ================================================================
-- MAINS — 55 Items (Indian Curries, Biryani, Rice, Bread, South Indian)
-- ================================================================
INSERT INTO menu_items (restaurant_id, name, description, price, stock_qty, category, image_url) VALUES

-- PANEER DISHES (10)
(1, 'Paneer Tikka Masala',   'Grilled paneer in spiced tomato-onion gravy',                    240.00, 40, 'Mains', 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&q=80'),
(1, 'Shahi Paneer',          'Royal creamy paneer cooked in cashew-saffron sauce',              260.00, 35, 'Mains', 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&q=80'),
(1, 'Palak Paneer',          'Fresh paneer cubes in smooth spinach gravy',                      220.00, 45, 'Mains', 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&q=80'),
(1, 'Kadai Paneer',          'Paneer with capsicum in tangy kadai spices',                      230.00, 40, 'Mains', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&q=80'),
(1, 'Paneer Lababdar',       'Rich tomato-cashew gravy with soft paneer',                       255.00, 30, 'Mains', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&q=80'),
(1, 'Paneer Korma',          'Paneer in mild sweet yogurt and nut gravy',                       245.00, 30, 'Mains', 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&q=80'),
(1, 'Paneer Do Pyaza',       'Double-onion paneer dry curry with aromatic spices',               225.00, 35, 'Mains', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&q=80'),
(1, 'Matar Paneer',          'Green peas and paneer in spiced tomato gravy',                    215.00, 40, 'Mains', 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&q=80'),
(1, 'Paneer Masala',         'Classic North Indian paneer in spicy masala sauce',               230.00, 35, 'Mains', 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&q=80'),
(1, 'Paneer Bhurji',         'Scrambled paneer with onion, tomato and spices',                  195.00, 40, 'Mains', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&q=80'),

-- CHICKEN DISHES (10)
(1, 'Butter Chicken',        'Tender chicken in velvety tomato-butter gravy',                   280.00, 50, 'Mains', 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&q=80'),
(1, 'Chicken Tikka Masala',  'Grilled chicken in rich masala sauce',                            290.00, 45, 'Mains', 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&q=80'),
(1, 'Chicken Korma',         'Tender chicken in mild yogurt and cashew gravy',                  270.00, 35, 'Mains', 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&q=80'),
(1, 'Chicken Do Pyaza',      'Chicken cooked with double the onions, bold flavors',             265.00, 35, 'Mains', 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&q=80'),
(1, 'Chicken Vindaloo',      'Fiery Goan-style chicken in tangy vinegar gravy',                 275.00, 30, 'Mains', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400&q=80'),
(1, 'Chicken Chettinad',     'South Indian spiced chicken with aromatic chettinad masala',      285.00, 30, 'Mains', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400&q=80'),
(1, 'Chicken Saag',          'Chicken cooked with fresh spinach and fenugreek',                 260.00, 35, 'Mains', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400&q=80'),
(1, 'Chicken Rogan Josh',    'Kashmiri slow-cooked chicken with whole spices',                  290.00, 30, 'Mains', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400&q=80'),
(1, 'Chicken Cafreal',       'Goan herb-marinated grilled chicken',                             275.00, 25, 'Mains', 'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=400&q=80'),
(1, 'Chicken Keema Masala',  'Spiced minced chicken with peas in rich gravy',                   255.00, 35, 'Mains', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400&q=80'),

-- BIRYANI & RICE (10)
(1, 'Mutton Biryani',        'Tender mutton pieces in fragrant long-grain basmati',             350.00, 25, 'Mains', 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&q=80'),
(1, 'Prawn Biryani',         'Succulent prawns layered with saffron-infused rice',              380.00, 20, 'Mains', 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&q=80'),
(1, 'Egg Biryani',           'Soft-boiled eggs cooked with fragrant biryani rice',              220.00, 35, 'Mains', 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&q=80'),
(1, 'Hyderabadi Biryani',    'Authentic Hyderabadi dum-cooked chicken biryani',                 310.00, 30, 'Mains', 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&q=80'),
(1, 'Jeera Rice',            'Basmati rice tempered with cumin and ghee',                       120.00, 60, 'Mains', 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&q=80'),
(1, 'Peas Pulao',            'Fragrant basmati with fresh green peas and whole spices',         150.00, 50, 'Mains', 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&q=80'),
(1, 'Lemon Rice',            'Tangy South Indian lemon rice with peanuts and curry leaf',       130.00, 50, 'Mains', 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&q=80'),
(1, 'Curd Rice',             'Cooling South Indian curd rice with tempering',                   110.00, 50, 'Mains', 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&q=80'),
(1, 'Veg Fried Rice',        'Wok-tossed rice with fresh vegetables in soy sauce',              160.00, 45, 'Mains', 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&q=80'),
(1, 'Egg Fried Rice',        'Classic fried rice with scrambled egg and spring onion',          180.00, 40, 'Mains', 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&q=80'),

-- DAL & LENTILS (5)
(1, 'Dal Tadka',             'Yellow lentils tempered with ghee, cumin and garlic',             170.00, 55, 'Mains', 'https://images.unsplash.com/photo-1546833998-877b37c2e5c6?w=400&q=80'),
(1, 'Dal Fry',               'Masoor dal fried with onion, tomato and spices',                  160.00, 55, 'Mains', 'https://images.unsplash.com/photo-1546833998-877b37c2e5c6?w=400&q=80'),
(1, 'Sambar',                'Tangy tamarind lentil soup with vegetables',                      120.00, 60, 'Mains', 'https://images.unsplash.com/photo-1546833998-877b37c2e5c6?w=400&q=80'),
(1, 'Rajma Masala',          'Kidney beans slow-cooked in tangy Punjabi masala',                190.00, 45, 'Mains', 'https://images.unsplash.com/photo-1546833998-877b37c2e5c6?w=400&q=80'),
(1, 'Chhole Masala',         'Spiced chickpeas in thick North Indian masala sauce',             195.00, 45, 'Mains', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&q=80'),

-- SOUTH INDIAN (8)
(1, 'Masala Dosa',           'Crispy crepe filled with spiced potato filling',                  130.00, 60, 'Mains', 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=400&q=80'),
(1, 'Plain Dosa',            'Thin crispy rice and lentil crepe with chutney',                  100.00, 60, 'Mains', 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=400&q=80'),
(1, 'Rava Dosa',             'Crispy semolina dosa with coconut chutney',                       120.00, 55, 'Mains', 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=400&q=80'),
(1, 'Idli Sambar (4 pcs)',   'Steamed rice cakes served with sambar and chutney',               110.00, 70, 'Mains', 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=400&q=80'),
(1, 'Medu Vada (2 pcs)',     'Crispy fried lentil donuts with sambar and chutney',              100.00, 65, 'Mains', 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=400&q=80'),
(1, 'Uttapam',               'Thick South Indian pancake with onion and tomato',                130.00, 50, 'Mains', 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=400&q=80'),
(1, 'Pongal',                'Creamy rice-lentil porridge with black pepper and ghee',          120.00, 45, 'Mains', 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=400&q=80'),
(1, 'Rava Idli (4 pcs)',     'Soft semolina idlis with coconut chutney and sambar',             125.00, 50, 'Mains', 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=400&q=80'),

-- BREADS (6)
(1, 'Butter Naan',           'Soft leavened bread brushed with butter from tandoor',            50.00,  100, 'Mains', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&q=80'),
(1, 'Garlic Naan',           'Naan topped with roasted garlic and fresh coriander',             60.00,  100, 'Mains', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&q=80'),
(1, 'Tandoori Roti',         'Whole wheat roti from the clay tandoor oven',                     35.00,  100, 'Mains', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&q=80'),
(1, 'Stuffed Aloo Paratha',  'Whole wheat paratha stuffed with spiced potatoes',                90.00,  60,  'Mains', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&q=80'),
(1, 'Laccha Paratha',        'Flaky layered whole wheat paratha with butter',                   70.00,  70,  'Mains', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&q=80'),
(1, 'Cheese Naan',           'Naan stuffed with gooey melted cheese',                           80.00,  80,  'Mains', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&q=80'),

-- MUTTON DISHES (4)
(1, 'Mutton Rogan Josh',     'Classic Kashmiri mutton curry with aromatic spices',              380.00, 20, 'Mains', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400&q=80'),
(1, 'Mutton Keema',          'Minced mutton with green peas in spiced masala',                  340.00, 20, 'Mains', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400&q=80'),
(1, 'Mutton Korma',          'Tender mutton in rich yogurt and almond gravy',                   400.00, 20, 'Mains', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400&q=80'),
(1, 'Mutton Curry',          'Traditional slow-cooked mutton in spicy gravy',                   360.00, 20, 'Mains', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400&q=80'),

-- VEG CURRIES (2)
(1, 'Mixed Veg Curry',       'Seasonal vegetables in aromatic Indian masala gravy',             190.00, 45, 'Mains', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&q=80'),
(1, 'Aloo Gobi',             'Cauliflower and potato curry with turmeric and spices',           170.00, 45, 'Mains', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&q=80');

-- ================================================================
-- DESSERTS — 40 Items (Indian Sweets, Cakes, Ice Cream, Puddings)
-- ================================================================
INSERT INTO menu_items (restaurant_id, name, description, price, stock_qty, category, image_url) VALUES

-- INDIAN SWEETS (20)
(1, 'Rasgulla',              'Soft spongy cottage cheese balls in light sugar syrup',           80.00,  60, 'Desserts', 'https://images.unsplash.com/photo-1607920592519-bab2a80efd77?w=400&q=80'),
(1, 'Rasmalai',              'Soft paneer patties soaked in saffron-flavoured cream',           110.00, 50, 'Desserts', 'https://images.unsplash.com/photo-1607920592519-bab2a80efd77?w=400&q=80'),
(1, 'Kheer',                 'Creamy rice pudding with saffron, cardamom and nuts',             95.00,  55, 'Desserts', 'https://images.unsplash.com/photo-1607920592519-bab2a80efd77?w=400&q=80'),
(1, 'Phirni',                'Ground rice pudding with rosewater and pistachios',               100.00, 45, 'Desserts', 'https://images.unsplash.com/photo-1607920592519-bab2a80efd77?w=400&q=80'),
(1, 'Gajar Halwa',           'Grated carrot slow-cooked in milk, sugar and ghee',              110.00, 50, 'Desserts', 'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=400&q=80'),
(1, 'Suji Halwa',            'Semolina pudding with saffron, cardamom and dry fruits',         90.00,  55, 'Desserts', 'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=400&q=80'),
(1, 'Besan Ladoo',           'Gram flour balls with ghee, sugar and cardamom',                 70.00,  70, 'Desserts', 'https://images.unsplash.com/photo-1515037893149-de7f840978e2?w=400&q=80'),
(1, 'Motichoor Ladoo',       'Fine boondi ladoo with cardamom and pistachios',                  75.00,  65, 'Desserts', 'https://images.unsplash.com/photo-1515037893149-de7f840978e2?w=400&q=80'),
(1, 'Jalebi',                'Crispy spiral fried in sugar syrup, warm and golden',             65.00,  80, 'Desserts', 'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=400&q=80'),
(1, 'Imarti',                'Crispy lentil spirals soaked in saffron sugar syrup',             70.00,  60, 'Desserts', 'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=400&q=80'),
(1, 'Kaju Katli',            'Premium cashew fudge with silver leaf',                           150.00, 40, 'Desserts', 'https://images.unsplash.com/photo-1515037893149-de7f840978e2?w=400&q=80'),
(1, 'Peda',                  'Rich milk-based sweet with cardamom',                             60.00,  70, 'Desserts', 'https://images.unsplash.com/photo-1515037893149-de7f840978e2?w=400&q=80'),
(1, 'Barfi',                 'Milk fudge with coconut and pistachio topping',                   80.00,  60, 'Desserts', 'https://images.unsplash.com/photo-1515037893149-de7f840978e2?w=400&q=80'),
(1, 'Sandesh',               'Bengali fresh cottage cheese sweet with jaggery',                 85.00,  50, 'Desserts', 'https://images.unsplash.com/photo-1607920592519-bab2a80efd77?w=400&q=80'),
(1, 'Rabri',                 'Thickened sweet milk with saffron and cardamom',                  100.00, 45, 'Desserts', 'https://images.unsplash.com/photo-1607920592519-bab2a80efd77?w=400&q=80'),
(1, 'Malpua',                'Pancake soaked in sugar syrup with fennel seeds',                 90.00,  50, 'Desserts', 'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=400&q=80'),
(1, 'Modak',                 'Steamed coconut-jaggery filled rice flour dumplings',             95.00,  45, 'Desserts', 'https://images.unsplash.com/photo-1515037893149-de7f840978e2?w=400&q=80'),
(1, 'Mysore Pak',            'Rich buttery gram flour sweet from Karnataka',                    90.00,  50, 'Desserts', 'https://images.unsplash.com/photo-1515037893149-de7f840978e2?w=400&q=80'),
(1, 'Kalakand',              'Grainy milk cake with cardamom and rose water',                   95.00,  45, 'Desserts', 'https://images.unsplash.com/photo-1607920592519-bab2a80efd77?w=400&q=80'),
(1, 'Shrikhand',             'Strained yogurt dessert with saffron and dry fruits',             100.00, 45, 'Desserts', 'https://images.unsplash.com/photo-1607920592519-bab2a80efd77?w=400&q=80'),

-- ICE CREAM (8)
(1, 'Vanilla Ice Cream',     'Classic vanilla with creamy, smooth texture',                     80.00,  80, 'Desserts', 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&q=80'),
(1, 'Chocolate Ice Cream',   'Rich dark chocolate scoop with chocolate chips',                  85.00,  80, 'Desserts', 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&q=80'),
(1, 'Butterscotch Ice Cream','Creamy butterscotch with caramel swirl',                          85.00,  75, 'Desserts', 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&q=80'),
(1, 'Mango Ice Cream',       'Alphonso mango flavoured creamy ice cream',                       90.00,  70, 'Desserts', 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&q=80'),
(1, 'Kulfi (Malai)',         'Traditional Indian frozen dessert with pistachios',               100.00, 60, 'Desserts', 'https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81?w=400&q=80'),
(1, 'Kulfi (Mango)',         'Mango kulfi on a stick — creamy and refreshing',                  105.00, 55, 'Desserts', 'https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81?w=400&q=80'),
(1, 'Sundae Delight',        'Two scoops of ice cream with chocolate fudge and nuts',           150.00, 40, 'Desserts', 'https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81?w=400&q=80'),
(1, 'Brownie Sundae',        'Warm brownie topped with ice cream and hot fudge sauce',          180.00, 35, 'Desserts', 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400&q=80'),

-- CAKES & BAKED (8)
(1, 'Chocolate Cake (slice)','Moist layered chocolate cake with ganache frosting',              130.00, 40, 'Desserts', 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&q=80'),
(1, 'Red Velvet Cake',       'Velvety red sponge with cream cheese frosting',                   140.00, 35, 'Desserts', 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&q=80'),
(1, 'Biscoff Cheesecake',    'No-bake cheesecake with caramelised Biscoff topping',             160.00, 30, 'Desserts', 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&q=80'),
(1, 'Tiramisu',              'Italian ladyfingers soaked in espresso with mascarpone',          150.00, 30, 'Desserts', 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400&q=80'),
(1, 'Chocolate Mousse',      'Light airy dark chocolate mousse with berries',                   130.00, 35, 'Desserts', 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400&q=80'),
(1, 'Lava Cake',             'Warm chocolate fondant with gooey molten centre',                 140.00, 35, 'Desserts', 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400&q=80'),
(1, 'Waffle with Syrup',     'Belgian waffle with maple syrup and butter',                      140.00, 40, 'Desserts', 'https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81?w=400&q=80'),
(1, 'Panna Cotta',           'Italian silky vanilla cream dessert with berry coulis',           135.00, 30, 'Desserts', 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400&q=80'),

-- FUSION DESSERTS (4)
(1, 'Gulab Jamun Ice Cream', 'Vanilla ice cream topped with warm gulab jamun',                  160.00, 30, 'Desserts', 'https://images.unsplash.com/photo-1533993192821-2cce3a8267d?w=400&q=80'),
(1, 'Jalebi Rabri',          'Hot crispy jalebi served with chilled rabri',                     120.00, 40, 'Desserts', 'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=400&q=80'),
(1, 'Chocolate Paan',        'Betel leaf filled with chocolate and dry fruits',                 80.00,  50, 'Desserts', 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&q=80'),
(1, 'Seviyan Kheer',         'Vermicelli cooked in sweet saffron-milk',                         90.00,  50, 'Desserts', 'https://images.unsplash.com/photo-1607920592519-bab2a80efd77?w=400&q=80');

-- ================================================================
-- STARTERS — 15 Items
-- ================================================================
INSERT INTO menu_items (restaurant_id, name, description, price, stock_qty, category, image_url) VALUES
(1, 'Paneer Tikka (6 pcs)',  'Marinated paneer grilled in tandoor with mint chutney',           200.00, 40, 'Starters', 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&q=80'),
(1, 'Veg Seekh Kebab',       'Minced vegetable kebabs grilled on skewers',                      170.00, 35, 'Starters', 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&q=80'),
(1, 'Tandoori Chicken (half)','Chicken marinated in yogurt spices, grilled in clay oven',       280.00, 25, 'Starters', 'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=400&q=80'),
(1, 'Chicken Seekh Kebab',   'Minced chicken skewers with coriander and chilli',                230.00, 30, 'Starters', 'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=400&q=80'),
(1, 'Mutton Seekh Kebab',    'Juicy minced mutton skewers from the tandoor',                    270.00, 25, 'Starters', 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&q=80'),
(1, 'Samosa (2 pcs)',        'Crispy fried pastry filled with spiced potatoes and peas',        70.00,  80, 'Starters', 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&q=80'),
(1, 'Onion Pakoda',          'Crispy onion fritters with chaat masala and chutney',             80.00,  70, 'Starters', 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&q=80'),
(1, 'Gobi Manchurian',       'Crispy cauliflower in Indo-Chinese Manchurian sauce',             150.00, 40, 'Starters', 'https://images.unsplash.com/photo-1617622141675-d3005b9d5e8a?w=400&q=80'),
(1, 'Chilli Chicken (dry)',  'Crispy chicken tossed in spicy Indo-Chinese chilli sauce',        200.00, 35, 'Starters', 'https://images.unsplash.com/photo-1617622141675-d3005b9d5e8a?w=400&q=80'),
(1, 'Chicken Wings (6 pcs)', 'Honey-glazed crispy chicken wings with dip',                     220.00, 30, 'Starters', 'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=400&q=80'),
(1, 'Prawn Tempura (4 pcs)', 'Japanese-style battered prawns with dipping sauce',              250.00, 25, 'Starters', 'https://images.unsplash.com/photo-1617622141675-d3005b9d5e8a?w=400&q=80'),
(1, 'Fish Fry',              'Crispy battered fish fillet with tartar sauce',                   220.00, 30, 'Starters', 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&q=80'),
(1, 'Cheese Corn Nuggets',   'Golden fried corn and cheese nuggets',                            140.00, 45, 'Starters', 'https://images.unsplash.com/photo-1617622141675-d3005b9d5e8a?w=400&q=80'),
(1, 'Potato Wedges',         'Oven-roasted potato wedges with herb seasoning',                  110.00, 55, 'Starters', 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&q=80'),
(1, 'Masala Papad',          'Roasted papad topped with onion, tomato and chaat masala',        60.00,  80, 'Starters', 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&q=80');

-- ================================================================
-- BURGERS — 8 More Items
-- ================================================================
INSERT INTO menu_items (restaurant_id, name, description, price, stock_qty, category, image_url) VALUES
(1, 'Mushroom Swiss Burger',  'Sautéed mushrooms with Swiss cheese and garlic mayo',            190.00, 25, 'Burgers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80'),
(1, 'Double Smash Burger',    'Double smashed beef patties with special burger sauce',          260.00, 20, 'Burgers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80'),
(1, 'Veggie Burger',          'Crispy veggie patty with fresh lettuce, tomato and sauce',       140.00, 30, 'Burgers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80'),
(1, 'BBQ Chicken Burger',     'Grilled chicken with smoky BBQ sauce and onion rings',           200.00, 25, 'Burgers', 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=400&q=80'),
(1, 'Paneer Burger',          'Crispy paneer patty with mint mayo and onion',                   170.00, 30, 'Burgers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80'),
(1, 'Egg Burger',             'Fried egg with cheese, lettuce and hot sauce',                   160.00, 30, 'Burgers', 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=400&q=80'),
(1, 'Loaded Fries Burger',    'Burger served with a loaded side of cheese fries',               230.00, 20, 'Burgers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80'),
(1, 'Fish Fillet Burger',     'Crispy battered fish with tartare sauce and coleslaw',           210.00, 20, 'Burgers', 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=400&q=80');

-- ================================================================
-- PIZZA — 8 More Items
-- ================================================================
INSERT INTO menu_items (restaurant_id, name, description, price, stock_qty, category, image_url) VALUES
(1, 'Margherita Pizza',       'Classic tomato, fresh mozzarella and basil leaves',             220.00, 30, 'Pizza', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80'),
(1, 'Pepperoni Pizza',        'Loaded pepperoni with mozzarella on tomato base',               320.00, 25, 'Pizza', 'https://images.unsplash.com/photo-1528137871618-79d2761e3fd5?w=400&q=80'),
(1, 'BBQ Chicken Pizza',      'Grilled chicken, caramelised onion and smoky BBQ sauce',        340.00, 20, 'Pizza', 'https://images.unsplash.com/photo-1528137871618-79d2761e3fd5?w=400&q=80'),
(1, 'Paneer Tikka Pizza',     'Marinated paneer with capsicum and tikka sauce',                310.00, 25, 'Pizza', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80'),
(1, 'Veggie Supreme Pizza',   'Loaded with bell peppers, olives, corn and mushroom',           280.00, 25, 'Pizza', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80'),
(1, 'Four Cheese Pizza',      'Mozzarella, cheddar, parmesan and ricotta blend',               360.00, 20, 'Pizza', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80'),
(1, 'Pesto Chicken Pizza',    'Chicken strips on basil pesto base with parmesan',              330.00, 20, 'Pizza', 'https://images.unsplash.com/photo-1528137871618-79d2761e3fd5?w=400&q=80'),
(1, 'Spicy Mexican Pizza',    'Jalapeños, beans, corn with chipotle and cheese',               300.00, 20, 'Pizza', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80');

-- ================================================================
-- NOODLES — 8 More Items
-- ================================================================
INSERT INTO menu_items (restaurant_id, name, description, price, stock_qty, category, image_url) VALUES
(1, 'Chicken Hakka Noodles',  'Wok-tossed noodles with chicken and vegetables',               180.00, 35, 'Noodles', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80'),
(1, 'Egg Noodles',            'Stir-fried noodles with scrambled egg and soy',                160.00, 40, 'Noodles', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80'),
(1, 'Schezwan Noodles',       'Spicy Schezwan sauce noodles with vegetables',                 170.00, 35, 'Noodles', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80'),
(1, 'Singapore Noodles',      'Thin rice noodles with curry powder and vegetables',            165.00, 30, 'Noodles', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80'),
(1, 'Pad Thai Noodles',       'Thai-style flat noodles with peanuts and spring onion',        200.00, 25, 'Noodles', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80'),
(1, 'Ramen Bowl',             'Japanese-style ramen in rich broth with noodles',              250.00, 25, 'Noodles', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80'),
(1, 'Udon Noodles',           'Thick Japanese udon in miso broth with tofu',                  230.00, 20, 'Noodles', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80'),
(1, 'Chicken Chow Mein',      'Classic crispy chow mein noodles with chicken',               190.00, 30, 'Noodles', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80');

-- ================================================================
-- DRINKS — 10 More Items
-- ================================================================
INSERT INTO menu_items (restaurant_id, name, description, price, stock_qty, category, image_url) VALUES
(1, 'Rose Sharbat',           'Chilled rose syrup drink with fresh seeds and milk',             70.00,  70, 'Drinks', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&q=80'),
(1, 'Buttermilk (Chaas)',     'Salted spiced yogurt drink with curry leaves',                  50.00,  80, 'Drinks', 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=400&q=80'),
(1, 'Strawberry Milkshake',   'Thick creamy strawberry milkshake with fresh berries',          110.00, 50, 'Drinks', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&q=80'),
(1, 'Chocolate Milkshake',    'Rich blended chocolate milkshake with whipped cream',           115.00, 50, 'Drinks', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&q=80'),
(1, 'Watermelon Juice',       'Fresh watermelon juice with a hint of mint',                    70.00,  65, 'Drinks', 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=400&q=80'),
(1, 'Pineapple Juice',        'Freshly squeezed pineapple juice with ginger',                  75.00,  60, 'Drinks', 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=400&q=80'),
(1, 'Masala Chai',            'Spiced Indian tea brewed with ginger and cardamom',             40.00,  100, 'Drinks', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&q=80'),
(1, 'Filter Coffee',          'South Indian strong filter coffee with frothy milk',             50.00,  90, 'Drinks', 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400&q=80'),
(1, 'Virgin Mojito',          'Fresh lime, mint and soda — cool and refreshing',               90.00,  60, 'Drinks', 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=400&q=80'),
(1, 'Tender Coconut Water',   'Fresh tender coconut water — natural electrolytes',             80.00,  55, 'Drinks', 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=400&q=80');

-- ================================================================
-- Summary: This file adds 130+ new menu items
-- Mains: 55  | Desserts: 40 | Starters: 15
-- Burgers: 8 | Pizza: 8    | Noodles: 8 | Drinks: 10
-- Total new items: 144
-- ================================================================
