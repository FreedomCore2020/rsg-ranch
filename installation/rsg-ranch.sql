DROP TABLE IF EXISTS `ranch_animals`;
CREATE TABLE IF NOT EXISTS `ranch_animals` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `ranchid` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL,
    `animalid` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL,
    `animals` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
