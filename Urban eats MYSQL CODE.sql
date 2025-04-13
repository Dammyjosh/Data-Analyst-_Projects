CREATE SCHEMA UrbanEats;
SHOW databases;
USE UrbanEats;

CREATE TABLE CustomerOrders2 (
  OrderID INT,
  CustomerID INT,
  DeliveryAddress VARCHAR(255),
  Latitude DECIMAL(10, 7),
  Longitude DECIMAL(10, 7),
  OrderTimestamp DATETIME,
  OrderStatus VARCHAR(50),
  DriverID INT,
  RestaurantID INT,
  LocationID INT,
  DistanceKM DECIMAL(8, 3),
  DeliveryHours DECIMAL(5, 2),
  TimeTakenToDeliver TIME,
  DeliveryTime DATETIME
  );
  SELECT * FROM CustomerOrders2;
  SET GLOBAL local_infile = 1;
  
  LOAD DATA LOCAL INFILE "C:/Users/damto/Downloads/customer_orders.csv"
  INTO TABLE CustomerOrders 
  FIELDS TERMINATED BY ','
  OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES 
  (OrderID, CustomerID, DeliveryAddress, Latitude, Longitude, @OrderTimestamp, OrderStatus, DriverID, RestaurantID, LocationID, DistanceKM, DeliveryHours, TimetakenToDeliver, @DeliveryTime)
  SET OrderTimestamp = STR_TO_DATE(@OrderTimestamp, '%d/%m/%Y %H:%i'),
  DeliveryTime = STR_TO_DATE(@DeliveryTime, '%d/%m/%Y %H:%i');
  
  SHOW tables;
  SHOW columns FROM Customerorders;
  DESCRIBE drivers;
  DESC restaurants_realistic;
  DESC traffic_data_realistic;
  
  
  update drivers
  SET shiftstart = STR_TO_DATE(shiftstart, '%d/%m/%Y %H:%i'),
  shiftend = STR_TO_DATE(shiftend, '%d/%m/%Y %H:%i');
   
alter table drivers
modify shiftstart datetime,
modify shiftend datetime;

-- Estimated Travel Time
select o.OrderID,
o.DistanceKM,
round(o.DistanceKM + (1 + t.TrafficDensity / 100)) AS EstimatedTravelTime_min
FROM customerorders AS o
JOIN traffic_data AS t ON o.LocationID = t.LocationID;

-- Driver Shift Length
select DriverID,
ShiftStart,
ShiftEnd,
timestampdiff(HOUR, ShiftStart, ShiftEnd) AS ShiftLength_hr
from drivers;

-- Average Delivery Time per Restaurant
 select r.RestaurantID,
 r.RestaurantName,
 AVG(o.DeliveryHours) AS AvgDeliveryTime
 from restaurants as r
 join customerorders as o on  r.RestaurantID = o.RestaurantID
 group by r.RestaurantID, r.RestaurantName;
 
 -- Busy Periods for Drivers
 select DriverID,
 extract(HOUR FROM OrderTimestamp) AS OrderHour,
 count(*) AS numberOfOrders
 FROM customerorders
 group by DriverID, OrderHour;
 
 -- Order Volume by Area
 select LocationID,
 count(*) as TotalOrders
 FROM customerorders
 group by LocationID;
 
 
 
 -- Average, Min, Max Delivery Time
 select avg(DeliveryHours) as AvgDeliveryTime,
 min(DeliveryHours) as MinDeliveryTime,
 max(DeliveryHours) as MaxDeliveryTime
 from customerorders;
 
 
 -- Frequency of Delivery Statuses
 SELECT OrderStatus,
 Count(*) as StatusCount
 from customerorders
 group by OrderStatus;
 
 
 -- Shift Lengths and Counts
 select DriverID,
 DriverName,
 round(avg(timestampdiff(hour, ShiftStart, ShiftEnd))) as AvgShiftLength,
 count(*) as NumberOfShifts
 from drivers
 group by DriverID, DriverName;
 
 
 -- Number of orders per Restaurant
 select RestaurantID,
 count(*) as TotalOrders
 from customerorders
 group by RestaurantID;
 
 -- Traffic Density Statistics
 select	avg(TrafficDensity) as avgTrafficDensity,
 min(TrafficDensity) as MinTrafficDensity,
 max(TrafficDensity) as MaxTrafficDensity
 from traffic_data;
 
 
-- Identifying Peak Delivery Times:
select extract(hour from OrderTimestamp) as HourOfDay,
Count(*) as OrderCount
from customerorders
group by HourOfDay;

select dayname(OrderTimestamp) as DayOfWeek,
count(*) as OrderCount
from customerorders
group by DayOfWeek;


select d.shiftID, 
avg(o.DeliveryHours) as AvgDeliveryTime
from customerorders o
join drivers d on o.DriverID = d.DriverID
group by d.ShiftID;

select t.TrafficDensity, avg(o.DeliveryHours) as AvgDeliveryTime
from customerorders o
join traffic_data t on o.LocationID = t.LocationID
group by t.TrafficDensity;
 
 select r.RestaurantID, avg(o.DeliveryHours) as avgDeliveryTime
 from customers o
 join restaurants r on o.RestaurantsID = r.RestaurantID
 group by r.RestaurantID;