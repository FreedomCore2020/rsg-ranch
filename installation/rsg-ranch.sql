DROP TABLE IF EXISTS `ranch_animals`;
CREATE TABLE IF NOT EXISTS `ranch_animals` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `ranchid` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL,
    `animalid` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL,
    `animals` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `ranch_stock`;
CREATE TABLE IF NOT EXISTS `ranch_stock` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `jobaccess` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL,
  `item` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `stock` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `ranch_shop`;
CREATE TABLE IF NOT EXISTS `ranch_shop` (
  `shopid` varchar(255) NOT NULL,
  `jobaccess` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `displayname` varchar(255) NOT NULL,
  `money` double(11,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`shopid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `ranch_shop` (`shopid`, `jobaccess`, `displayname`, `money`) VALUES
('macfarranchshop', 'macfarranch', 'Macfarlan Ranch Shop', 0),
('prongranchshop', 'prongranch', 'Pronghorn Ranch Shop', 0);

DROP TABLE IF EXISTS `ranch_shop_stock`;
CREATE TABLE `ranch_shop_stock` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shopid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `items` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `price` double(11,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
