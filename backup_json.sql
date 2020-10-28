CREATE TABLE `backup_json` (
  `idbackup_json` int NOT NULL AUTO_INCREMENT,
  `idtransaction` int DEFAULT NULL,
  `TABLE_NAME` varchar(45) DEFAULT NULL,
  `ROW_JSON` json DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idbackup_json`)
) ENGINE=InnoDB;
