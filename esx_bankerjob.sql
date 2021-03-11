INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_banker','Banque', 1)
;
INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_banker','Banque', 1)
;
INSERT INTO `datastore` (name, label, shared) VALUES
	('society_banker','Banque', 1)
;
INSERT INTO `jobs` (name, label) VALUES
	('banker','Banquier')
;

DELETE FROM `job_grades` WHERE job_grades.job_name = 'banker';
INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('banker',0,'conveyor','Convoyeur',100,'{}','{}'),
	('banker',1,'conveyor_boss','Resp. Convoyeur',200,'{}','{}'),
	('banker',2,'banker',"Banquier",300,'{}','{}'),
	('banker',3,'advisor','Conseiller',400,'{}','{}'),
	('banker',4,'boss','PDG',500,'{}','{}')
;


CREATE TABLE `bank_lent_money` IF NOT EXISTS (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `firstname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) NOT NULL,
  `clientID` varchar(255) DEFAULT NULL,
  `amount` double DEFAULT NULL,
  `rate` double NOT NULL,
  `remainDeadlines` double DEFAULT NULL,
  `deadlines` double NOT NULL,
  `amountNextDeadline` double DEFAULT NULL,
  `alreadyPaid` double DEFAULT NULL,
  `timeLeft` double NOT NULL,
  `timeBeforeDeadline` double NOT NULL,
  `advisorFirstname` varchar(255) DEFAULT NULL,
  `advisorLastname` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'Ouvert'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `bank_savings` (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `firstname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) NOT NULL,
  `tot` double DEFAULT NULL,
  `rate` double NOT NULL,
  `advisorFirstname` varchar(255) DEFAULT NULL,
  `advisorLastname` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'Ouvert',
);

CREATE TABLE IF NOT EXISTS `bank_riskedsavings` (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `firstname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) NOT NULL,
  `tot` double DEFAULT NULL,
  `advisorFirstname` varchar(255) DEFAULT NULL,
  `advisorLastname` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'Ouvert',
  PRIMARY KEY (`id`)
);