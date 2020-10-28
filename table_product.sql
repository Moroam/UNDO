CREATE TABLE `product` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(120) DEFAULT NULL,
  `manufacturer` varchar(120) DEFAULT NULL,
  `price` int DEFAULT NULL,
  `et` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

delimiter //
CREATE TRIGGER `product_BEFORE_UPDATE` BEFORE UPDATE ON `product` FOR EACH ROW BEGIN
INSERT INTO test.backup_json(`TABLE_NAME`, ROW_JSON)
VALUES (
	'product', 
    JSON_OBJECT('id', OLD.id, 'name', OLD.`name`, 'manufacturer',  OLD.manufacturer, 'price', OLD.price, 'et', OLD.et)
);
SET NEW.et=now();
END;//
delimiter ;

insert into product(name,manufacturer,price)
values 
('LED Desk Lamp', 'X', '26'),
('Laptop', 'Y', '800'),
('Grill', 'Z2', '300');
