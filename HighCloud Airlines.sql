select * from highcloud_airlines.main_data;

# Add Date column
alter table highcloud_airlines.main_data add Date date ;

SET SQL_SAFE_UPDATES = 0;

# Add inset data in Date column
update highcloud_airlines.main_data Set Date = concat(Year,'-',Month_Number,'-',Day) ;

# Add Month_FullName column
alter table highcloud_airlines.main_data add Month_FullName varchar(50) ;

# inset data in Month_FullName column
update highcloud_airlines.main_data Set Month_FullName = monthname(Date) ;


# Add Quarter column
alter table highcloud_airlines.main_data add Quarter varchar(10) ;

# inset data in Quarter column
update highcloud_airlines.main_data Set Quarter = concat('Q',quarter(Date)) ;

# Add YearMonth column
alter table highcloud_airlines.main_data add YearMonth varchar(20) ;

# inset data in YearMonth column
update highcloud_airlines.main_data Set YearMonth = concat(Year,'-',left(Month_FullName,3)) ;

# Add Weekday_Number column
alter table highcloud_airlines.main_data add Weekday_Number int ;

# inset data in Weekday_Number column
update highcloud_airlines.main_data Set Weekday_Number = weekday(Date) ;

# Add Weekday_Name column
alter table highcloud_airlines.main_data add Weekday_Name varchar(20) ;

# inset data in Weekday_Name column
update highcloud_airlines.main_data Set Weekday_Name = dayname(Date);

# Add Financial_Quarter column
alter table highcloud_airlines.main_data add Financial_Quarter varchar(10) ;

# inset data in Financial_Quarter column
update highcloud_airlines.main_data Set Financial_Quarter = 'Q1'
where Quarter = 'Q2';

update highcloud_airlines.main_data Set Financial_Quarter = 'Q2'
where Quarter = 'Q3';

update highcloud_airlines.main_data Set Financial_Quarter = 'Q3'
where Quarter = 'Q4';

update highcloud_airlines.main_data Set Financial_Quarter = 'Q4'
where Quarter = 'Q1';

# Add Financial_Month column
alter table highcloud_airlines.main_data add Financial_Month varchar(10) ;

# Add Weekday_Weekend column
alter table highcloud_airlines.main_data add Weekday_Weekend varchar(20) ;

# inset data in Weekday_Weekend column
update highcloud_airlines.main_data Set Weekday_Weekend = 'Weekend'
where Weekday_Number = 5 ;

update highcloud_airlines.main_data Set Weekday_Weekend = 'Weekend'
where Weekday_Number = 6 ;

update highcloud_airlines.main_data Set Weekday_Weekend = 'Weekday'
where Weekday_Number < 5 ;

alter table highcloud_airlines.main_data add Load_Fator int ;
# inset data in Weekday_Name column
update highcloud_airlines.main_data Set Load_Fator = (Transported_Passengers / Available_Seats*100,0);

# Find the load Factor percentage on a yearly , Quarterly , Monthly basis
select Year,
round(avg(Load_Fator),2) from highcloud_airlines.main_data
group by Year;

select Quarter,
round(avg(Load_Fator),2) from highcloud_airlines.main_data
group by Quarter;

select Month_Number,Month_FullName,
round(avg(Load_Fator),2) from highcloud_airlines.main_data
group by Month_FullName
order by Month_Number asc;

# Find the load Factor percentage on a Carrier Name basis
select Unique_Carrier,round(avg(Load_Fator),2) as Avg_Loadfactor
from highcloud_airlines.main_data
group by Unique_Carrier 
order by Avg_Loadfactor desc;

# Identify Top 10 Carrier Names based passengers preference 
select Unique_Carrier,count(Departures_Performed) as Departure_Performed
from highcloud_airlines.main_data
group by Unique_Carrier
order by Departure_Performed desc
limit 10;

# Display top Routes ( from-to City) based on Number of Flights 
select From_To_City,count(Carrier_Name) as Carrier_Name
from highcloud_airlines.main_data
group by From_To_City
order by Carrier_Name desc
limit 10;

# Identify the how much load factor is occupied on Weekend vs Weekdays. 
select Weekday_Weekend,
round(avg(Load_Fator),2) from highcloud_airlines.main_data
group by Weekday_Weekend;

select Weekday_Number,Weekday_Name,Weekday_Weekend,
round(avg(Load_Fator),2) from highcloud_airlines.main_data
group by Weekday_Weekend,Weekday_Name
order by Weekday_Number asc;

# Identify number of flights based on Distance groups
select distance_groups.Distance_Interval,count(Unique_Carrier) as Unique_carrier from main_data
inner join highcloud_airlines.distance_groups on main_data.Distance_Group_ID = distance_groups.Distance_Group_ID
group by distance_groups.Distance_Interval
order by Unique_carrier desc;