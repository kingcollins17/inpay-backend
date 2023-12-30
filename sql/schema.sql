DROP DATABASE IF EXISTS `inpay`;

CREATE DATABASE `inpay` DEFAULT CHARACTER
SET
     utf8 COLLATE utf8_unicode_ci;

USE inpay;

CREATE TABLE
     IF NOT EXISTS `users` (
          `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
          `name` VARCHAR(255) NOT NULL,
          `email` VARCHAR(255) NOT NULL UNIQUE,
          `password` VARCHAR(255) NOT NULL,
          PRIMARY KEY `pk_id` (`id`)
     ) ENGINE = InnoDB;

CREATE TABLE
     IF NOT EXISTS `accounts` (
          `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
          `name` VARCHAR(255) NOT NULL UNIQUE,
          `account_no` CHAR(10) NOT NULL UNIQUE,
          `balance` DECIMAL(20, 2) NOT NULL DEFAULT 10.50 CHECK(`balance` > 10.0),
          `level` DECIMAL(10,6) NOT NULL DEFAULT 0.000005,
          `pin` INT(4) NOT NULL,
          `user_id` INT UNSIGNED NOT NULL,
          CONSTRAINT `fk_accounts_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
          PRIMARY KEY `pk_id` (`id`)
     ) ENGINE = InnoDB;


CREATE TABLE
     IF NOT EXISTS `transactions` (
          `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
          `hash` CHAR(32) NOT NULL UNIQUE,
          `sender_id` INT UNSIGNED NOT NULL,
          `recipient_id` INT UNSIGNED NOT NULL,
          `amount` DECIMAL(10, 2) NOT NULL,
          `date` DATETIME NOT NULL DEFAULT NOW(),
          PRIMARY KEY `pk_id` (`id`),
          FOREIGN KEY (`sender_id`) REFERENCES `inpay`.`accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
          FOREIGN KEY (`recipient_id`) REFERENCES `inpay`.`accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
     ) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `savings` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `amount` DECIMAL(10,2) NOT NULL,
  `date` DATETIME NOT NULL DEFAULT NOW(),
  `account_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY `pk_id`(`id`),
  FOREIGN KEY (`account_id`) REFERENCES `inpay`.`accounts`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;



CREATE TABLE IF NOT EXISTS `loans` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `amount` DECIMAL(8,2) NOT NULL,
  `date` DATETIME NOT NULL DEFAULT NOW(),
  `account_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY `pk_id`(`id`),
  FOREIGN KEY (`account_id`) REFERENCES `inpay`.`accounts`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;


DROP TRIGGER IF EXISTS `take_loan`;
DELIMITER $$

CREATE TRIGGER `take_loan` AFTER INSERT ON `loans` FOR EACH ROW
BEGIN
     
     UPDATE `accounts` SET
       `balance` = `balance` + NEW.amount
     WHERE `id` = NEW.account_id;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS `repay_loan`;
DELIMITER $$
CREATE TRIGGER `repay_loan` BEFORE DELETE ON `loans` FOR EACH ROW
BEGIN
     
     DECLARE `bal` DECIMAL;
     SELECT `balance` INTO `bal` FROM `accounts` WHERE `id` = OLD.account_id;
     
     
     IF `bal` < OLD.amount THEN
          SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Insufficient funds to pay back loan';
     END IF;
          
     UPDATE `accounts` SET
       `balance` = `balance` - OLD.amount
     WHERE `id` = OLD.account_id;
     
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS `transact`;

DELIMITER $$
CREATE TRIGGER `transact` BEFORE INSERT ON `transactions` FOR EACH ROW
BEGIN
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
     
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS `save`;
DELIMITER $$
CREATE TRIGGER `save` BEFORE INSERT ON `savings` FOR EACH ROW
BEGIN
     
     DECLARE `bal` DECIMAL;
     SELECT `balance` INTO `bal` FROM `accounts` WHERE id = NEW.account_id;
     
     IF `bal` < NEW.amount THEN
          SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Insufficient Funds';
     END IF;
     
     UPDATE `accounts` SET
       `balance` = `balance` - NEW.amount
     WHERE `id` = NEW.account_id;
         
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS `unlock_savings`;
DELIMITER $$
CREATE TRIGGER `unlock_savings` AFTER DELETE ON `savings` FOR EACH ROW
BEGIN
     
     UPDATE `accounts` SET
       `balance` = `balance` + OLD.amount
     WHERE `id` = OLD.account_id;
END $$
DELIMITER ;
