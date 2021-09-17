-- phpMyAdmin SQL Dump
-- version 3.1.2deb1ubuntu0.2
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Apr 30, 2018 at 01:13 PM
-- Server version: 5.0.75
-- PHP Version: 5.3.0

CREATE DATABASE  IF NOT EXISTS `edith` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `edith`;

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `edith`
--

-- --------------------------------------------------------

--
-- Table structure for table `dbmaintain_scripts`
--

CREATE TABLE IF NOT EXISTS `dbmaintain_scripts` (
  `file_name` varchar(150) collate utf8_swedish_ci default NULL,
  `file_last_modified_at` bigint(20) default NULL,
  `checksum` varchar(50) collate utf8_swedish_ci default NULL,
  `executed_at` varchar(20) collate utf8_swedish_ci default NULL,
  `succeeded` bigint(20) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `document`
--

CREATE TABLE IF NOT EXISTS `document` (
  `id` bigint(20) NOT NULL auto_increment,
  `path` varchar(255) collate utf8_swedish_ci default NULL,
  `title` varchar(255) collate utf8_swedish_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci AUTO_INCREMENT=5219 ;

-- --------------------------------------------------------

--
-- Table structure for table `documentnote`
--

CREATE TABLE IF NOT EXISTS `documentnote` (
  `id` bigint(20) NOT NULL auto_increment,
  `createdOn` bigint(20) NOT NULL,
  `deleted` bit(1) NOT NULL,
  `fullSelection` text collate utf8_swedish_ci,
  `lemmaPosition` varchar(255) collate utf8_swedish_ci default NULL,
  `position` int(11) NOT NULL,
  `publishable` bit(1) NOT NULL,
  `revision` bigint(20) default NULL,
  `shortenedSelection` varchar(1024) collate utf8_swedish_ci default NULL,
  `document_id` bigint(20) default NULL,
  `note_id` bigint(20) default NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_DOCUMENTNOTE_NOTEID` (`note_id`),
  KEY `FK_DOCUMENTNOTE_DOCUMENTID` (`document_id`),
  KEY `del_pub_idx` (`deleted`,`publishable`),
  KEY `del_rev` (`deleted`,`revision`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci AUTO_INCREMENT=39806 ;

-- --------------------------------------------------------

--
-- Table structure for table `note`
--

CREATE TABLE IF NOT EXISTS `note` (
  `id` bigint(20) NOT NULL auto_increment,
  `description` text collate utf8_swedish_ci,
  `documentNoteCount` int(11) NOT NULL,
  `editedOn` bigint(20) default NULL,
  `format` enum('NOTE','PLACE','PERSON') collate utf8_swedish_ci default NULL,
  `lemma` varchar(255) collate utf8_swedish_ci default NULL,
  `lemmaMeaning` text collate utf8_swedish_ci,
  `sources` text collate utf8_swedish_ci,
  `subtextSources` text collate utf8_swedish_ci,
  `lastEditedBy_id` bigint(20) default NULL,
  `person_id` bigint(20) default NULL,
  `place_id` bigint(20) default NULL,
  `term_id` bigint(20) default NULL,
  `deleted` bit(1) NOT NULL,
  `status` enum('DRAFT','FINISHED') collate utf8_swedish_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_NOTE_LASTEDITEDBYID` (`lastEditedBy_id`),
  KEY `FK_NOTE_PLACEID` (`place_id`),
  KEY `FK_NOTE_PERSONID` (`person_id`),
  KEY `FK_NOTE_TERMID` (`term_id`),
  KEY `count_idx` (`documentNoteCount`),
  KEY `note_format_idx` (`format`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci AUTO_INCREMENT=33798 ;

-- --------------------------------------------------------

--
-- Table structure for table `notecomment`
--

CREATE TABLE IF NOT EXISTS `notecomment` (
  `id` bigint(20) NOT NULL auto_increment,
  `createdAt` datetime default NULL,
  `message` text collate utf8_swedish_ci,
  `username` varchar(255) collate utf8_swedish_ci default NULL,
  `note_id` bigint(20) default NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_NOTECOMMENT_NOTEID` (`note_id`),
  KEY `created_idx` (`createdAt`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci AUTO_INCREMENT=272 ;

-- --------------------------------------------------------

--
-- Table structure for table `note_types`
--

CREATE TABLE IF NOT EXISTS `note_types` (
  `Note_id` bigint(20) NOT NULL,
  `types` enum('WORD_EXPLANATION','LITERARY','HISTORICAL','DICTUM','CRITIQUE','TITLE','TRANSLATION','REFERENCE') collate utf8_swedish_ci default NULL,
  KEY `FK_NOTETYPES_NOTEID` (`Note_id`),
  KEY `note_types_idx` (`types`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `note_user`
--

CREATE TABLE IF NOT EXISTS `note_user` (
  `Note_id` bigint(20) NOT NULL,
  `allEditors_id` bigint(20) NOT NULL,
  PRIMARY KEY  (`Note_id`,`allEditors_id`),
  KEY `FK_NOTEUSER_NOTEID` (`Note_id`),
  KEY `FK_NOTEUSER_ALLEDITORSID` (`allEditors_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `person`
--

CREATE TABLE IF NOT EXISTS `person` (
  `id` bigint(20) NOT NULL auto_increment,
  `time_of_birth_end` datetime default NULL,
  `time_of_birth_start` datetime default NULL,
  `time_of_death_end` datetime default NULL,
  `time_of_death_start` datetime default NULL,
  `description` text collate utf8_swedish_ci,
  `first` varchar(255) collate utf8_swedish_ci default NULL,
  `last` varchar(255) collate utf8_swedish_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `person_nameform`
--

CREATE TABLE IF NOT EXISTS `person_nameform` (
  `person_id` bigint(20) NOT NULL,
  `description` text collate utf8_swedish_ci,
  `first` varchar(255) collate utf8_swedish_ci default NULL,
  `last` varchar(255) collate utf8_swedish_ci default NULL,
  KEY `FK_NAMEFORM_PERSONID` (`person_id`),
  KEY `person_nameform_idx` (`person_id`),
  KEY `person_nameform_last_idx` (`last`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `place`
--

CREATE TABLE IF NOT EXISTS `place` (
  `id` bigint(20) NOT NULL auto_increment,
  `description` text collate utf8_swedish_ci,
  `first` varchar(255) collate utf8_swedish_ci default NULL,
  `last` varchar(255) collate utf8_swedish_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `place_nameform`
--

CREATE TABLE IF NOT EXISTS `place_nameform` (
  `place_id` bigint(20) NOT NULL,
  `description` text collate utf8_swedish_ci,
  `first` varchar(255) collate utf8_swedish_ci default NULL,
  `last` varchar(255) collate utf8_swedish_ci default NULL,
  KEY `FK_NAMEFORM_PLACEID` (`place_id`),
  KEY `place_nameform_idx` (`place_id`),
  KEY `place_nameform_last_idx` (`last`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `term`
--

CREATE TABLE IF NOT EXISTS `term` (
  `id` bigint(20) NOT NULL auto_increment,
  `basicForm` varchar(255) collate utf8_swedish_ci default NULL,
  `language` enum('FINNISH','SWEDISH','FRENCH','LATIN','GERMAN','RUSSIAN','ENGLISH','ITALIAN','GREEK','OTHER') collate utf8_swedish_ci default NULL,
  `meaning` text collate utf8_swedish_ci,
  `otherLanguage` varchar(255) collate utf8_swedish_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `basic_form_idx` (`basicForm`),
  KEY `term_lang_idx` (`language`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci AUTO_INCREMENT=66319 ;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `id` bigint(20) NOT NULL auto_increment,
  `email` varchar(255) collate utf8_swedish_ci default NULL,
  `firstName` varchar(255) collate utf8_swedish_ci default NULL,
  `lastName` varchar(255) collate utf8_swedish_ci default NULL,
  `password` varchar(255) collate utf8_swedish_ci default NULL,
  `profile` varchar(255) collate utf8_swedish_ci default NULL,
  `username` varchar(255) collate utf8_swedish_ci default NULL,
  `active` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci AUTO_INCREMENT=42 ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `documentnote`
--
ALTER TABLE `documentnote`
  ADD CONSTRAINT `documentnote_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `document` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `documentnote_ibfk_2` FOREIGN KEY (`note_id`) REFERENCES `note` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `note`
--
ALTER TABLE `note`
  ADD CONSTRAINT `FK_NOTE_LASTEDITEDBYID` FOREIGN KEY (`lastEditedBy_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `FK_NOTE_PERSONID` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`),
  ADD CONSTRAINT `FK_NOTE_PLACEID` FOREIGN KEY (`place_id`) REFERENCES `place` (`id`),
  ADD CONSTRAINT `FK_NOTE_TERMID` FOREIGN KEY (`term_id`) REFERENCES `term` (`id`);

--
-- Constraints for table `notecomment`
--
ALTER TABLE `notecomment`
  ADD CONSTRAINT `FK_NOTECOMMENT_NOTEID` FOREIGN KEY (`note_id`) REFERENCES `note` (`id`);

--
-- Constraints for table `note_types`
--
ALTER TABLE `note_types`
  ADD CONSTRAINT `FK_NOTETYPES_NOTEID` FOREIGN KEY (`Note_id`) REFERENCES `note` (`id`);

--
-- Constraints for table `note_user`
--
ALTER TABLE `note_user`
  ADD CONSTRAINT `FK_NOTEUSER_ALLEDITORSID` FOREIGN KEY (`allEditors_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `FK_NOTEUSER_NOTEID` FOREIGN KEY (`Note_id`) REFERENCES `note` (`id`);

--
-- Constraints for table `person_nameform`
--
ALTER TABLE `person_nameform`
  ADD CONSTRAINT `FK_NAMEFORM_PERSONID` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`);

--
-- Constraints for table `place_nameform`
--
ALTER TABLE `place_nameform`
  ADD CONSTRAINT `FK_NAMEFORM_PLACEID` FOREIGN KEY (`place_id`) REFERENCES `place` (`id`);

CREATE USER 'edith'@'%' IDENTIFIED BY 'edith';
GRANT ALL PRIVILEGES ON edith.* TO 'edith'@'%';


UPDATE note SET status = 'DRAFT' WHERE status ='INITIAL';

ALTER TABLE note ADD new_status_column ENUM('DRAFT', 'FINISHED') CHARACTER SET utf8 COLLATE utf8_swedish_ci DEFAULT NULL ;
UPDATE note SET new_status_column = status;
ALTER TABLE note DROP status;

ALTER TABLE note CHANGE new_status_column status ENUM('DRAFT', 'FINISHED') CHARACTER SET utf8 COLLATE utf8_swedish_ci DEFAULT NULL ;

