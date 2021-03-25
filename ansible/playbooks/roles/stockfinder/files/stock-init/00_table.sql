DROP TABLE IF EXISTS `tickers`;

CREATE TABLE `tickers` (
    `ticker` char(8) NOT NULL,
    `ordered` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (`ticker`), UNIQUE KEY `ordered` (`ordered`)
)
