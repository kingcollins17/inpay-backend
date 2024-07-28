-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: inpay
-- ------------------------------------------------------
-- Server version	8.0.31

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `account_no` char(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `balance` decimal(20,2) NOT NULL DEFAULT '10.50',
  `level` decimal(10,6) NOT NULL DEFAULT '0.000005',
  `pin` int NOT NULL,
  `user_id` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `account_no` (`account_no`),
  KEY `fk_accounts_users` (`user_id`),
  CONSTRAINT `fk_accounts_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `accounts_chk_1` CHECK ((`balance` > 10.0))
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES (20,'Mike Ross','3101187635',800011.00,0.000005,1234,26),(21,'Anna Roberts','3109209220',10526774.00,37.965005,1234,27),(22,'Jon Doe','3101101398',241511.00,0.825005,2002,28),(23,'Grace Weaves','3109075596',10.50,0.000005,1234,29),(24,'Jonathan','3106800258',956011.00,0.000005,1234,30),(25,'Andrew','3107206816',500011.00,0.000005,1234,31);
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loans`
--

DROP TABLE IF EXISTS `loans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loans` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `amount` decimal(8,2) NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `account_id` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `loans_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loans`
--

LOCK TABLES `loans` WRITE;
/*!40000 ALTER TABLE `loans` DISABLE KEYS */;
INSERT INTO `loans` VALUES (51,250000.00,'2023-12-26 10:23:16',21),(52,250000.00,'2023-12-26 10:28:41',21),(53,50000.00,'2023-12-28 13:08:22',22);
/*!40000 ALTER TABLE `loans` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `take_loan` AFTER INSERT ON `loans` FOR EACH ROW BEGIN
     
     UPDATE `accounts` SET
       `balance` = `balance` + NEW.amount
     WHERE `id` = NEW.account_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `repay_loan` BEFORE DELETE ON `loans` FOR EACH ROW BEGIN
     
     DECLARE `bal` DECIMAL;
     SELECT `balance` INTO `bal` FROM `accounts` WHERE `id` = OLD.account_id;
     
     
     IF `bal` < OLD.amount THEN
          SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Insufficient funds to pay back loan';
     END IF;
          
     UPDATE `accounts` SET
       `balance` = `balance` - OLD.amount
     WHERE `id` = OLD.account_id;
     
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `savings`
--

DROP TABLE IF EXISTS `savings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `savings` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `amount` decimal(10,2) NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `account_id` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `savings_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `savings`
--

LOCK TABLES `savings` WRITE;
/*!40000 ALTER TABLE `savings` DISABLE KEYS */;
INSERT INTO `savings` VALUES (51,6500.00,'2023-12-21 15:18:26',22),(55,12000.00,'2023-12-25 21:01:28',22),(56,10000.00,'2023-12-25 21:02:11',22),(61,2500000.00,'2023-12-30 00:57:37',21);
/*!40000 ALTER TABLE `savings` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `save` BEFORE INSERT ON `savings` FOR EACH ROW BEGIN
     
     DECLARE `bal` DECIMAL;
     SELECT `balance` INTO `bal` FROM `accounts` WHERE id = NEW.account_id;
     
     IF `bal` < NEW.amount THEN
          SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Insufficient Funds';
     END IF;
     
     UPDATE `accounts` SET
       `balance` = `balance` - NEW.amount
     WHERE `id` = NEW.account_id;
         
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `unlock_savings` AFTER DELETE ON `savings` FOR EACH ROW BEGIN
     
     UPDATE `accounts` SET
       `balance` = `balance` + OLD.amount
     WHERE `id` = OLD.account_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `hash` char(32) COLLATE utf8mb3_unicode_ci NOT NULL,
  `sender_id` int unsigned NOT NULL,
  `recipient_id` int unsigned NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hash` (`hash`),
  KEY `sender_id` (`sender_id`),
  KEY `recipient_id` (`recipient_id`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`recipient_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (37,'a817dBB7a6a75d5d2C5B22BC40f6e5e3',21,20,25000.00,'2023-12-21 15:00:31'),(38,'edBB2Fd4ABa9bc255f86af1dEa97fAEf',21,20,500000.00,'2023-12-21 15:02:12'),(39,'F91Fc5dAE3ea09e6acfeeABBF6bF5758',21,22,250000.00,'2023-12-21 15:15:41'),(40,'50A6a1bC7EeaaeD7f30FEfCd6DD7AeC8',22,21,55000.00,'2023-12-21 15:17:31'),(41,'da221ec241e7E81bffDb09aaAE4909ce',21,20,250000.00,'2023-12-26 08:25:57'),(42,'Aa4C1Ffde6abAa14f1a05A05A1cdc0F9',21,22,25000.00,'2023-12-27 13:49:28'),(43,'06bf7bf2Cda96BECC876bb46A4D95fE7',21,20,25000.00,'2023-12-28 14:04:49'),(44,'Aa4d4BBdD922d9Ae46Ed9E82523FC23c',21,24,65000.00,'2024-01-03 07:56:49'),(45,'E92DFC7FaF0B74DACacc34Cd56D7Dd2F',21,24,120000.00,'2024-01-03 08:27:00'),(46,'2CeCCD93eDFBFf6cAfaD9C64533F3DF9',21,24,250000.00,'2024-01-03 08:29:09'),(47,'9429eb079c1f86756Ee4e22e0f371Ca6',21,24,21000.00,'2024-01-03 08:32:02'),(48,'753bd7dF2bF8B4A850AEb4Ae694A2A37',21,24,500000.00,'2024-01-03 08:34:29'),(49,'4ea5ccD9Ad808cD3BBC3543Bb9fB0BB1',21,25,500000.00,'2024-01-03 08:36:40');
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `transact` BEFORE INSERT ON `transactions` FOR EACH ROW BEGIN
     DECLARE `sender_balance` DECIMAL;
     DECLARE `recipient_balance` DECIMAL;
     
     SELECT `balance` INTO `sender_balance` FROM `accounts` WHERE `id` = NEW.sender_id;
     SELECT `balance` INTO `recipient_balance` FROM `accounts` WHERE `id` = NEW.recipient_id;

     IF `sender_balance` < New.amount THEN
          SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Insufficient Funds';
     END IF;
     
     UPDATE `accounts` SET
       `balance` = `sender_balance` - NEW.amount,
       `level` = `level` + (NEW.amount * 0.000015)
     WHERE `id` = NEW.sender_id;

     UPDATE `accounts` SET
       `balance` = `recipient_balance` + NEW.amount
     WHERE `id` =   NEW.recipient_id;
     
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (26,'Mike Ross','mike@gmail.com','$2b$12$lffV8dcfZp6Byyc1v/4Bu.R474X3HF86QYn4gx5dtnJ.KdSiueq92'),(27,'Anna Roberts','anna@gmail.com','$2b$12$sujaQ1f7EYjQGzMKfxRRte/pEaMzfoipfsKfdY/h04H9LgD8pl4Ee'),(28,'Jon Doe','jon@gmail.com','$2b$12$es4iv9k4oo81.XhqNUodGeayPJMA5OiezJQS2aPbXhQBB/gez93/W'),(29,'Grace Weaves','grace@gmail.com','$2b$12$sr4Rm1jcZ6RncT9IU9QQ5udER6Mn29Gf01FGsEaQ.FCyLBBVquFwS'),(30,'Jonathan','nathan@gmail.com','$2b$12$G577uPnS.y8ZNZfjFSlHCOKbYlSO8W4HSd4YYcpadTcH9xcCM6pFm'),(31,'Andrew','andrew@gmail.com','$2b$12$TwOABj2exZJLIxL.JyjrxevNCiTDZJM.ORro5DHFn7TbCjThTJB2G');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-07-27 15:39:59
