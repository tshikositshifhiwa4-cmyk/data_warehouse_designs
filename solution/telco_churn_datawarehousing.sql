select count (*) from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]
--------------------------------------------------------------------------------------------
--checking didtinct rows
select distinct MultipleLines from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]

select distinct OnlineSecurity from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]

select distinct OnlineBackup from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]

select distinct DeviceProtection from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]

select distinct TechSupport from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]

select distinct StreamingTV from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]

select distinct StreamingMovies from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]

--cleaning the data
update [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]
set TotalCharges = NULL
where TotalCharges = ' '

update [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]
set MultipleLines = 'No' where MultipleLines = 'No phone service'

update [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]
set OnlineSecurity = 'No' where OnlineSecurity = 'No internet service'

update [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]
set OnlineBackup = 'No' where OnlineBackup = 'No internet service'

update [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]
set DeviceProtection = 'No' where DeviceProtection = 'No internet service'

update [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]
set TechSupport = 'No' where TechSupport = 'No internet service'

update [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]
set StreamingTV = 'No' where StreamingTV = 'No internet service'

update [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn]
set StreamingMovies = 'No' where StreamingMovies = 'No internet service'
--------------------------------------------------------------------------------------------
 --create dimension tables
 --1. dim_customer
 select distinct customerID as customer_id,
				gender,
				SeniorCitizen,
				Partner,
				Dependents
into dim_customer
from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn];

--2.dim_contract
select distinct 
			row_number () over (order by contract) as contract_id,
			contract as contract_type,
			PaperlessBilling
into dim_contract
from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn];

--3. dim_payment (run from here)
select distinct
			row_number () over (order by PaymentMethod) as payment_id,
			PaymentMethod as payment_method
into dim_payment
from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn];

--4.dim_services
select distinct	
			row_number () over (order by PhoneService, InternetService) as service_id,
			PhoneService,
			MultipleLines,
			InternetService,
			OnlineSecurity,
			OnlineBackup,
			DeviceProtection,
			TechSupport,
			StreamingTV,
			StreamingMovies
into dim_services
from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn];

--5. dim_date
create table dim_date (
			date_id int primary key,
			month int,
			year int,
			quarter int
);
insert into dim_date (date_id, month, year, quarter)
		select 
			row_number() over (order by (select null)) as date_id,
			month (dateadd (day, number, '2022-01-01')),
			year (dateadd (day, number, '2022-01-01')),
			datepart (quarter, dateadd (day, number, '2022-01-01'))
from master..spt_values
where type = 'p' and number between 0 and 364;


--6. creating the fact table
create table fact_customer_churn (
			customer_id varchar (250),
			contract_id int,
			payment_id int,
			service_id int,
			date_id int,
			tenure int,
			monthly_charges decimal (10,2),
			total_charges decimal(10,2),
			churn_flag int
	);
----------------------------------------------------------------------------------------
--inserting data into the fact table
insert into fact_customer_churn (
		   customer_id,
		   contract_id,
		   payment_id,
		   service_id,
		   date_id,
		   tenure,
		   monthly_charges,
		   total_charges,
		   churn_flag)

select a.customerID,
		   c.contract_id,
		   p.payment_id,
		   s.service_id,
		   abs(checksum(newid())) % 365 + 1 as date_id,
		   a.tenure,
		   a.MonthlyCharges,
		   cast (a.TotalCharges as decimal (10,2)),
		   case when a.Churn = 'yes' then 1 
				else 0 
				end as churn_flag
from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn] a

--join contract
join dim_contract c
	on a.Contract = c.contract_type
	and a.PaperlessBilling = c.PaperlessBilling

--join payment
join dim_payment p
	on a.PaymentMethod = p.payment_method

--join services
join dim_services s
	on a.PhoneService = s.PhoneService
	and a.MultipleLines = s.MultipleLines
	and a.InternetService = s.InternetService
	and a.OnlineSecurity = s.OnlineSecurity
	and a.OnlineBackup = s.OnlineBackup
	and a.DeviceProtection = s.DeviceProtection
	and a.TechSupport = s.TechSupport
	and a.StreamingTV = s.StreamingTV
	and a.StreamingMovies = s.StreamingMovies

	--join new date
	cross join dim_date d;

--------------------------------------------------------------------------------------------
insert into fact_customer_churn (
    customer_id,
    contract_id,
    payment_id,
    service_id,
    date_id,
    tenure,
    monthly_charges,
    total_charges,
    churn_flag
)

select 
    a.customerID,

    -- safer joins using TOP 1
    (select top 1 contract_id 
     from dim_contract c 
     where c.contract_type = a.Contract) as contract_id,

    (select top 1 payment_id 
     from dim_payment p 
     where p.payment_method = a.PaymentMethod) AS payment_id,

    (select top 1 service_id 
     from dim_services s) as service_id,  -- simplified

    abs(checksum(newid())) % 365 + 1 AS date_id,

    a.tenure,
    a.MonthlyCharges,
    cast(a.TotalCharges as decimal(10,2)),

    case 
        when a.Churn = 'Yes' THEN 1 
        else 0 
    end as churn_flag

from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn] a;
-----------------------------------------------------------------------------------------
select count (*) from [telco_churn_analysis].[dbo].[Telco_Cusomer_Churn] a