-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3315
-- Generation Time: Dec 04, 2025 at 09:39 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bytieresto`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_make_payment` (IN `p_OrderID` INT, IN `p_PaymentMethod` ENUM('Cash','Card','Online'), IN `p_Taxes` DECIMAL(10,2), IN `p_DiscountPct` DECIMAL(5,2))   BEGIN
  DECLARE v_total DECIMAL(12,2);
  START TRANSACTION;
  SELECT fn_order_total(p_OrderID) INTO v_total;
  SET v_total = v_total + IFNULL(p_Taxes,0) - (v_total * IFNULL(p_DiscountPct,0) / 100);
  INSERT INTO Payments (OrderID, PaymentMethod, TotalAmount, Taxes, DiscountPct, PaidAt)
    VALUES (p_OrderID, p_PaymentMethod, v_total, p_Taxes, p_DiscountPct, NOW());
  UPDATE Orders SET Status = 'Completed' WHERE OrderID = p_OrderID;
  COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_place_order` (IN `p_CustomerID` INT, IN `p_WaiterID` INT, IN `p_TableID` INT, IN `p_OrderType` ENUM('DineIn','Online'), IN `p_MenuIDs` TEXT, IN `p_Quantities` TEXT)   BEGIN
    DECLARE v_OrderID INT;

    START TRANSACTION;

    INSERT INTO Orders(CustomerID, WaiterID, TableID, OrderType)
    VALUES (p_CustomerID, p_WaiterID, p_TableID, p_OrderType);

    SET v_OrderID = LAST_INSERT_ID();

    
    COMMIT;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_order_total` (`p_OrderID` INT) RETURNS DECIMAL(12,2) DETERMINISTIC BEGIN
  DECLARE v_total DECIMAL(12,2) DEFAULT 0;
  SELECT IFNULL(SUM(Quantity * UnitPrice),0) INTO v_total FROM OrderDetails WHERE OrderID = p_OrderID;
  RETURN v_total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `chefsections`
--

CREATE TABLE `chefsections` (
  `SectionID` int(11) NOT NULL,
  `SectionName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `chefsections`
--

INSERT INTO `chefsections` (`SectionID`, `SectionName`) VALUES
(2, 'Broasted'),
(5, 'Charcoal'),
(1, 'Fryer'),
(4, 'Salad'),
(3, 'Snack');

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `CustomerID` int(11) NOT NULL,
  `Name` varchar(150) NOT NULL,
  `Phone` varchar(30) DEFAULT NULL,
  `Email` varchar(150) DEFAULT NULL,
  `Address` text DEFAULT NULL,
  `LoyaltyPoints` int(11) DEFAULT 0,
  `OrdersPerMonth` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`CustomerID`, `Name`, `Phone`, `Email`, `Address`, `LoyaltyPoints`, `OrdersPerMonth`, `created_at`) VALUES
(1, 'Alice Smith', '+96170000001', 'alice@example.com', '123 Main St', 10, 2, '2025-12-04 20:38:57'),
(2, 'Bob Johnson', '+96170000002', 'bob@example.com', '456 Elm St', 5, 1, '2025-12-04 20:38:57'),
(3, 'Charlie Brown', '+96170000003', 'charlie@example.com', '789 Pine St', 0, 0, '2025-12-04 20:38:57'),
(4, 'Diana Prince', '+96170000004', 'diana@example.com', '321 Oak St', 20, 4, '2025-12-04 20:38:57'),
(5, 'Ethan Hunt', '+96170000005', 'ethan@example.com', '654 Maple St', 15, 3, '2025-12-04 20:38:57');

-- --------------------------------------------------------

--
-- Table structure for table `diningtables`
--

CREATE TABLE `diningtables` (
  `TableID` int(11) NOT NULL,
  `TableNumber` int(11) DEFAULT NULL,
  `Capacity` int(11) DEFAULT NULL,
  `IsAvailable` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `diningtables`
--

INSERT INTO `diningtables` (`TableID`, `TableNumber`, `Capacity`, `IsAvailable`, `created_at`) VALUES
(1, 1, 4, 1, '2025-12-04 20:39:25'),
(2, 2, 2, 1, '2025-12-04 20:39:25'),
(3, 3, 6, 1, '2025-12-04 20:39:25'),
(4, 4, 4, 1, '2025-12-04 20:39:25'),
(5, 5, 8, 1, '2025-12-04 20:39:25'),
(6, 6, 2, 1, '2025-12-04 20:39:25'),
(7, 7, 4, 1, '2025-12-04 20:39:25'),
(8, 8, 6, 1, '2025-12-04 20:39:25'),
(9, 9, 4, 1, '2025-12-04 20:39:25'),
(10, 10, 2, 1, '2025-12-04 20:39:25');

-- --------------------------------------------------------

--
-- Table structure for table `menuitems`
--

CREATE TABLE `menuitems` (
  `MenuID` int(11) NOT NULL,
  `Name` varchar(200) NOT NULL,
  `Category` varchar(100) DEFAULT NULL,
  `Price` decimal(10,2) NOT NULL,
  `DiscountPct` decimal(5,2) DEFAULT 0.00,
  `IsAvailable` tinyint(1) DEFAULT 1,
  `AmountInStock` int(11) DEFAULT 0,
  `SectionID` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `menuitems`
--

INSERT INTO `menuitems` (`MenuID`, `Name`, `Category`, `Price`, `DiscountPct`, `IsAvailable`, `AmountInStock`, `SectionID`, `created_at`) VALUES
(1, 'Burger', 'FastFood', 5.99, 0.00, 1, 50, 1, '2025-12-04 18:50:13'),
(2, 'Broasted Chicken', 'Broasted', 8.99, 0.00, 1, 30, 2, '2025-12-04 18:50:13'),
(3, 'Fries', 'Snack', 2.50, 0.00, 1, 100, 1, '2025-12-04 18:50:13'),
(4, 'Garden Salad', 'Salad', 4.50, 0.00, 1, 40, 4, '2025-12-04 18:50:13'),
(5, 'Kebab', 'Charcoal', 9.50, 0.00, 1, 25, 5, '2025-12-04 18:50:13');

-- --------------------------------------------------------

--
-- Table structure for table `orderdetails`
--

CREATE TABLE `orderdetails` (
  `OrderDetailID` int(11) NOT NULL,
  `OrderID` int(11) NOT NULL,
  `MenuID` int(11) NOT NULL,
  `Quantity` int(11) NOT NULL DEFAULT 1,
  `UnitPrice` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `orderdetails`
--
DELIMITER $$
CREATE TRIGGER `trg_after_insert_orderdetail` AFTER INSERT ON `orderdetails` FOR EACH ROW BEGIN
  UPDATE MenuItems
    SET AmountInStock = AmountInStock - NEW.Quantity,
        IsAvailable = CASE WHEN AmountInStock - NEW.Quantity > 0 THEN 1 ELSE 0 END
    WHERE MenuID = NEW.MenuID;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `OrderID` int(11) NOT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `WaiterID` int(11) DEFAULT NULL,
  `TableID` int(11) DEFAULT NULL,
  `OrderType` enum('DineIn','Online') NOT NULL,
  `OrderDateTime` datetime DEFAULT current_timestamp(),
  `Status` enum('Placed','Preparing','Completed','Cancelled','Problem') DEFAULT 'Placed',
  `Note` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `orders`
--
DELIMITER $$
CREATE TRIGGER `trg_after_insert_order` AFTER INSERT ON `orders` FOR EACH ROW BEGIN
  IF NEW.OrderType = 'DineIn' AND NEW.TableID IS NOT NULL THEN
    UPDATE DiningTables SET IsAvailable = 0 WHERE TableID = NEW.TableID;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `PaymentID` int(11) NOT NULL,
  `OrderID` int(11) DEFAULT NULL,
  `PaymentMethod` enum('Cash','Card','Online') NOT NULL,
  `TotalAmount` decimal(12,2) NOT NULL,
  `Taxes` decimal(10,2) DEFAULT 0.00,
  `DiscountPct` decimal(5,2) DEFAULT 0.00,
  `PaidAt` datetime DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stockmovements`
--

CREATE TABLE `stockmovements` (
  `MovementID` int(11) NOT NULL,
  `MenuID` int(11) NOT NULL,
  `Quantity` int(11) NOT NULL,
  `MovementType` enum('IN','OUT') NOT NULL,
  `Cost` decimal(10,2) DEFAULT 0.00,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_best_items`
-- (See below for the actual view)
--
CREATE TABLE `vw_best_items` (
`MenuID` int(11)
,`Name` varchar(200)
,`Category` varchar(100)
,`total_sold` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_best_waiters`
-- (See below for the actual view)
--
CREATE TABLE `vw_best_waiters` (
`WaiterID` int(11)
,`Name` varchar(150)
,`orders_served` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_live_sales`
-- (See below for the actual view)
--
CREATE TABLE `vw_live_sales` (
`sale_date` date
,`orders_count` bigint(21)
,`revenue` decimal(42,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_problem_orders`
-- (See below for the actual view)
--
CREATE TABLE `vw_problem_orders` (
`OrderID` int(11)
,`OrderType` enum('DineIn','Online')
,`Status` enum('Placed','Preparing','Completed','Cancelled','Problem')
,`OrderDateTime` datetime
,`Note` text
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_top_customers`
-- (See below for the actual view)
--
CREATE TABLE `vw_top_customers` (
`CustomerID` int(11)
,`Name` varchar(150)
,`orders_count` bigint(21)
,`total_spent` decimal(34,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_working_sections`
-- (See below for the actual view)
--
CREATE TABLE `vw_working_sections` (
`SectionID` int(11)
,`SectionName` varchar(100)
,`items_prepared` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Table structure for table `waiters`
--

CREATE TABLE `waiters` (
  `WaiterID` int(11) NOT NULL,
  `Name` varchar(150) NOT NULL,
  `Phone` varchar(30) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `waiters`
--

INSERT INTO `waiters` (`WaiterID`, `Name`, `Phone`, `created_at`) VALUES
(1, 'Waleed', '+96171000001', '2025-12-04 20:39:13'),
(2, 'Maya', '+96171000002', '2025-12-04 20:39:13'),
(3, 'Nabil', '+96171000003', '2025-12-04 20:39:13'),
(4, 'Sara', '+96171000004', '2025-12-04 20:39:13'),
(5, 'Rami', '+96171000005', '2025-12-04 20:39:13');

-- --------------------------------------------------------

--
-- Structure for view `vw_best_items`
--
DROP TABLE IF EXISTS `vw_best_items`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_best_items`  AS SELECT `m`.`MenuID` AS `MenuID`, `m`.`Name` AS `Name`, `m`.`Category` AS `Category`, sum(`od`.`Quantity`) AS `total_sold` FROM (`orderdetails` `od` join `menuitems` `m` on(`od`.`MenuID` = `m`.`MenuID`)) GROUP BY `m`.`MenuID`, `m`.`Name`, `m`.`Category` ORDER BY sum(`od`.`Quantity`) DESC LIMIT 0, 10 ;

-- --------------------------------------------------------

--
-- Structure for view `vw_best_waiters`
--
DROP TABLE IF EXISTS `vw_best_waiters`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_best_waiters`  AS SELECT `w`.`WaiterID` AS `WaiterID`, `w`.`Name` AS `Name`, count(`o`.`OrderID`) AS `orders_served` FROM (`orders` `o` join `waiters` `w` on(`o`.`WaiterID` = `w`.`WaiterID`)) GROUP BY `w`.`WaiterID`, `w`.`Name` ORDER BY count(`o`.`OrderID`) DESC ;

-- --------------------------------------------------------

--
-- Structure for view `vw_live_sales`
--
DROP TABLE IF EXISTS `vw_live_sales`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_live_sales`  AS SELECT cast(`o`.`OrderDateTime` as date) AS `sale_date`, count(distinct `o`.`OrderID`) AS `orders_count`, sum(`od`.`Quantity` * `od`.`UnitPrice`) AS `revenue` FROM (`orders` `o` join `orderdetails` `od` on(`o`.`OrderID` = `od`.`OrderID`)) WHERE cast(`o`.`OrderDateTime` as date) = curdate() GROUP BY cast(`o`.`OrderDateTime` as date) ;

-- --------------------------------------------------------

--
-- Structure for view `vw_problem_orders`
--
DROP TABLE IF EXISTS `vw_problem_orders`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_problem_orders`  AS SELECT `o`.`OrderID` AS `OrderID`, `o`.`OrderType` AS `OrderType`, `o`.`Status` AS `Status`, `o`.`OrderDateTime` AS `OrderDateTime`, `o`.`Note` AS `Note` FROM `orders` AS `o` WHERE `o`.`Status` in ('Cancelled','Problem') ;

-- --------------------------------------------------------

--
-- Structure for view `vw_top_customers`
--
DROP TABLE IF EXISTS `vw_top_customers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_top_customers`  AS SELECT `c`.`CustomerID` AS `CustomerID`, `c`.`Name` AS `Name`, count(`o`.`OrderID`) AS `orders_count`, sum(`p`.`TotalAmount`) AS `total_spent` FROM ((`customers` `c` left join `orders` `o` on(`c`.`CustomerID` = `o`.`CustomerID`)) left join `payments` `p` on(`o`.`OrderID` = `p`.`OrderID`)) GROUP BY `c`.`CustomerID`, `c`.`Name` ORDER BY sum(`p`.`TotalAmount`) DESC ;

-- --------------------------------------------------------

--
-- Structure for view `vw_working_sections`
--
DROP TABLE IF EXISTS `vw_working_sections`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_working_sections`  AS SELECT `cs`.`SectionID` AS `SectionID`, `cs`.`SectionName` AS `SectionName`, sum(`od`.`Quantity`) AS `items_prepared` FROM ((`orderdetails` `od` join `menuitems` `m` on(`od`.`MenuID` = `m`.`MenuID`)) join `chefsections` `cs` on(`m`.`SectionID` = `cs`.`SectionID`)) GROUP BY `cs`.`SectionID`, `cs`.`SectionName` ORDER BY sum(`od`.`Quantity`) DESC ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `chefsections`
--
ALTER TABLE `chefsections`
  ADD PRIMARY KEY (`SectionID`),
  ADD UNIQUE KEY `SectionName` (`SectionName`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`CustomerID`),
  ADD KEY `idx_customers_email` (`Email`);

--
-- Indexes for table `diningtables`
--
ALTER TABLE `diningtables`
  ADD PRIMARY KEY (`TableID`),
  ADD UNIQUE KEY `TableNumber` (`TableNumber`);

--
-- Indexes for table `menuitems`
--
ALTER TABLE `menuitems`
  ADD PRIMARY KEY (`MenuID`),
  ADD KEY `idx_menu_section` (`SectionID`);

--
-- Indexes for table `orderdetails`
--
ALTER TABLE `orderdetails`
  ADD PRIMARY KEY (`OrderDetailID`),
  ADD KEY `MenuID` (`MenuID`),
  ADD KEY `idx_orderdetails_order` (`OrderID`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`OrderID`),
  ADD KEY `TableID` (`TableID`),
  ADD KEY `idx_orders_customer` (`CustomerID`),
  ADD KEY `idx_orders_waiter` (`WaiterID`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`PaymentID`),
  ADD UNIQUE KEY `OrderID` (`OrderID`);

--
-- Indexes for table `stockmovements`
--
ALTER TABLE `stockmovements`
  ADD PRIMARY KEY (`MovementID`),
  ADD KEY `MenuID` (`MenuID`);

--
-- Indexes for table `waiters`
--
ALTER TABLE `waiters`
  ADD PRIMARY KEY (`WaiterID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `chefsections`
--
ALTER TABLE `chefsections`
  MODIFY `SectionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `CustomerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `diningtables`
--
ALTER TABLE `diningtables`
  MODIFY `TableID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `menuitems`
--
ALTER TABLE `menuitems`
  MODIFY `MenuID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `orderdetails`
--
ALTER TABLE `orderdetails`
  MODIFY `OrderDetailID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `OrderID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `PaymentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `stockmovements`
--
ALTER TABLE `stockmovements`
  MODIFY `MovementID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `waiters`
--
ALTER TABLE `waiters`
  MODIFY `WaiterID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `menuitems`
--
ALTER TABLE `menuitems`
  ADD CONSTRAINT `menuitems_ibfk_1` FOREIGN KEY (`SectionID`) REFERENCES `chefsections` (`SectionID`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `orderdetails`
--
ALTER TABLE `orderdetails`
  ADD CONSTRAINT `orderdetails_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `orderdetails_ibfk_2` FOREIGN KEY (`MenuID`) REFERENCES `menuitems` (`MenuID`) ON UPDATE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customers` (`CustomerID`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`WaiterID`) REFERENCES `waiters` (`WaiterID`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`TableID`) REFERENCES `diningtables` (`TableID`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `stockmovements`
--
ALTER TABLE `stockmovements`
  ADD CONSTRAINT `stockmovements_ibfk_1` FOREIGN KEY (`MenuID`) REFERENCES `menuitems` (`MenuID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
