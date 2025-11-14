
-- ------------------------------------Analysis-----------------------------------------------
----------Applicants analysis----------------------------------------------------------
--  Number of Applicants by gender

SELECT 
    gender,
    COUNT(DISTINCT ApplicantID) AS TotalApplicants
FROM gold.ApplicantDIM
GROUP BY gender
ORDER BY TotalApplicants DESC;

--  Average GPA by current education level
SELECT 
    CurrentLevel,
    COUNT(DISTINCT ApplicantID) AS TotalApplicants,
    ROUND(AVG(GPA), 2) AS AvgGPA
FROM gold.ApplicantDIM
GROUP BY CurrentLevel
ORDER BY AvgGPA DESC;

--  Top 10 nationalities among applicants
SELECT TOP 10 
    Nationality,
    COUNT(*) AS TotalApplicants
FROM gold.ApplicantDIM
GROUP BY Nationality
ORDER BY TotalApplicants DESC;

--  Top 10 institutions with the most applicants
SELECT TOP 10 
    InstitutionName,
    COUNT(*) AS ApplicantsCount
FROM gold.ApplicantDIM
GROUP BY InstitutionName
ORDER BY ApplicantsCount DESC;

------------------scholarships analysis------------------------------------------------
--  Most popular programs (by number of applications)
SELECT TOP 10 
    S.Program,
    S.Degree,
    COUNT(DISTINCT A.ApplicationID) AS TotalApplications
FROM gold.ApplicationFact A
JOIN gold.ScholarshipDIM S 
    ON A.ScholarshipKey = S.ScholarshipKey
GROUP BY S.Program, S.Degree
ORDER BY TotalApplications DESC;

-- Scholarship distribution by teaching language
SELECT 
    TeachingLanguage,
    COUNT(DISTINCT ScholarshipKey) AS TotalScholarships
FROM gold.ScholarshipDIM
GROUP BY TeachingLanguage
ORDER BY TotalScholarships DESC;

--  Top 10 most expensive scholarships (by tuition)
SELECT TOP 10 
    Program,
    University,
    Degree,
    Tuition,
    Duration
FROM gold.ScholarshipDIM
ORDER BY Tuition DESC;

-- 1.3 Which group of applicants pays the highest living expenses after scholarships
-- Finds which cost category has the highest living expense burden


SELECT 
    LivingExpenseApplicantNeedToPayCategoryType AS LivingExpenseCategory,
    ROUND(AVG((MinApplicantNeedToPayLivingExpense + MaxApplicantNeedToPayLivingExpense) / 2.0), 2) AS AvgLivingExpenseToPay
FROM gold.ScholarshipDIM
GROUP BY LivingExpenseApplicantNeedToPayCategoryType
ORDER BY AvgLivingExpenseToPay DESC;



---------Exam Analysis--------------------------------------------------------------------------------
-- Average and count of scores by exam type
SELECT 
    ExamName,
    COUNT(DISTINCT ExamID) AS TotalTaken,
    ROUND(AVG(Score), 2) AS AvgScore
FROM gold.ExamDim
GROUP BY ExamName
ORDER BY AvgScore DESC;

-- Exam result distribution (Pass vs Fail)
SELECT 
    Result,
    COUNT(DISTINCT ExamID) AS CountExams
FROM gold.ExamDim
GROUP BY Result
ORDER BY CountExams DESC;

-- Comparison of pass rates between male and female applicants
-- Tests if gender affects exam outcomes.

SELECT 
    a.gender,
    ROUND(SUM(CASE WHEN e.Result IN ('Pass', 'Passed', 'Successful') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS PassRate,
    ROUND(SUM(CASE WHEN e.Result IN ('Fail', 'Failed', 'Unsuccessful') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS FailRate
FROM gold.ExamDim e
JOIN gold.ApplicationFact f 
    ON e.ApplicationID = f.ApplicationID
JOIN gold.ApplicantDIM a 
    ON f.ApplicantKey = a.ApplicantKey
GROUP BY a.gender
ORDER BY PassRate DESC;


--  Pass rate trends over the years
-- Tracks whether exam performance is improving or declining.

SELECT 
    D.YearNumber,
    ROUND(SUM(CASE WHEN E.Result IN ('Pass', 'Passed', 'Successful') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS PassRate,
    ROUND(SUM(CASE WHEN E.Result IN ('Fail', 'Failed', 'Unsuccessful') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS FailRate
FROM gold.ExamDim E
JOIN gold.ApplicationFact A 
    ON E.ApplicationID = A.ApplicationID
JOIN gold.DateDIM D 
    ON A.ApplicationDate = D.FullDate
GROUP BY D.YearNumber
ORDER BY D.YearNumber;





---------------Interview Analysis-----------------------------------------------------------------------
-- Interview result distribution (Accepted / Rejected )
SELECT 
    Result,
    COUNT(DISTINCT InterviewID) AS TotalInterviews
FROM gold.InterviewDim
GROUP BY Result
ORDER BY TotalInterviews DESC;

-- Top 10 most active interviewers
SELECT TOP 10 
    Name AS InterviewerName,
    Institution,
    COUNT(DISTINCT InterviewID) AS TotalInterviews
FROM gold.InterviewDim
GROUP BY Name, Institution
ORDER BY TotalInterviews DESC;



---------------------- Financial support Analysis------------------------------------------------------
--  Number of financial support requests by approval status
SELECT 
    ApprovalStatus,
    COUNT(DISTINCT ApplicantFinancialSupportID) AS TotalRequests,
    ROUND(AVG(RequestedSupportAmount), 2) AS AvgRequested
FROM gold.FinancialSupportDIM
GROUP BY ApprovalStatus
ORDER BY TotalRequests DESC;

--  Most common support types
SELECT 
    SupportType,
    COUNT(DISTINCT ApplicantFinancialSupportID) AS TotalRequests,
    ROUND(AVG(RequestedSupportAmount), 2) AS AvgRequested
FROM gold.FinancialSupportDIM
GROUP BY SupportType
ORDER BY TotalRequests DESC;

-- Average requested vs maximum allowed amounts
SELECT 
    SupportType,
    ROUND(AVG(RequestedSupportAmount), 2) AS AvgRequested,
    ROUND(AVG(MaxAmount), 2) AS AvgMaxAllowed,
    ROUND(AVG(RequestedSupportAmount) / NULLIF(AVG(MaxAmount), 0) * 100, 1) AS RequestToLimitRatio
FROM gold.FinancialSupportDIM
GROUP BY SupportType
ORDER BY RequestToLimitRatio DESC;

-- Most common types of financial support offered to applicants
-- Shows which support types (stipend, transport, etc.) are most frequent.

SELECT 
    SupportType,
    COUNT(*) AS TotalSupports
FROM gold.FinancialSupportDIM
GROUP BY SupportType
ORDER BY TotalSupports DESC;


--  Average maximum amount of financial support provided
-- Indicates typical upper limit of financial aid per type

SELECT 
    SupportType,
    ROUND(AVG(MaxAmount), 2) AS AvgMaxAmount
FROM gold.FinancialSupportDIM
GROUP BY SupportType
ORDER BY AvgMaxAmount DESC;



-----------------payment analysis---------------------------------------------------------

-- Total amount and count of payments by method
SELECT 
    PaymentMethod,
    COUNT(DISTINCT PaymentID) AS TotalPayments,
    ROUND(SUM(TuitionPay + AccommodationPay + LivingExpensePay + ServiceFee), 2) AS TotalAmount
FROM gold.ApplicationPaymentDIM
GROUP BY PaymentMethod
ORDER BY TotalAmount DESC;

-- Average values for each payment component
SELECT 
    ROUND(AVG(TuitionPay), 2) AS AvgTuitionPay,
    ROUND(AVG(AccommodationPay), 2) AS AvgAccommodation,
    ROUND(AVG(LivingExpensePay), 2) AS AvgLivingExpense,
    ROUND(AVG(ServiceFee), 2) AS AvgServiceFee
FROM gold.ApplicationPaymentDIM;


---------------------------committee analysis-----------------------------------------------

-- Number of members and average workload per committee
SELECT 
    CommitteeName,
    COUNT(DISTINCT Email) AS TotalMembers,
    ROUND(AVG(CurrentWorkedLoad), 2) AS AvgWorkload
FROM gold.CommitteeDIM
GROUP BY CommitteeName
ORDER BY AvgWorkload DESC;

-- Average years of experience by institution
SELECT 
    Institution,
    ROUND(AVG(YearsOfExperience), 1) AS AvgExperience,
    COUNT(*) AS MembersCount
FROM gold.CommitteeDIM
GROUP BY Institution
ORDER BY AvgExperience DESC;


-------------------------------Time-series analysis----------------------------------------------------

-- Monthly and yearly application trends
SELECT 
    D.YearNumber,
    D.MonthNumber,
    D.MonthName,
    COUNT(DISTINCT A.ApplicationID) AS TotalApplications
FROM gold.ApplicationFact A
JOIN gold.DateDIM D 
    ON A.ApplicationDate = D.FullDate
GROUP BY D.YearNumber, D.MonthNumber, D.MonthName
ORDER BY D.YearNumber, D.MonthNumber;

-- Yearly acceptance rate

SELECT 
    D.YearNumber,
    ROUND(SUM(CASE WHEN A.Comment LIKE '%accept%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS AcceptanceRate
FROM gold.ApplicationFact A
JOIN gold.DateDIM D 
    ON A.ApplicationDate = D.FullDate
GROUP BY D.YearNumber
ORDER BY D.YearNumber;

-------------------------- Overall KPIs------------------------------------------------------------

-- Total number of applications and applicants
SELECT 
    COUNT(DISTINCT ApplicationID) AS TotalApplications,
    COUNT(DISTINCT ApplicantKey) AS TotalApplicants
FROM gold.ApplicationFact;

-- Overall acceptance rate
SELECT 
    ROUND(SUM(CASE WHEN Comment LIKE '%accept%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS AcceptanceRate
FROM gold.ApplicationFact;


-- Acceptance rate by GPA category
SELECT 
    CASE 
        WHEN a.GPA >= 3.5 THEN 'High GPA'
        WHEN a.GPA BETWEEN 2.5 AND 3.49 THEN 'Medium GPA'
        ELSE 'Low GPA'
    END AS GPABand,
    COUNT(*) AS TotalApplicants,
    SUM(CASE WHEN f.Comment LIKE '%accept%' THEN 1 ELSE 0 END) AS Accepted,
    ROUND(SUM(CASE WHEN f.Comment LIKE '%accept%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS AcceptanceRate
FROM gold.ApplicantDIM a
JOIN gold.ApplicationFact f 
    ON a.ApplicantKey = f.ApplicantKey
GROUP BY 
    CASE 
        WHEN a.GPA >= 3.5 THEN 'High GPA'
        WHEN a.GPA BETWEEN 2.5 AND 3.49 THEN 'Medium GPA'
        ELSE 'Low GPA'
    END
ORDER BY AcceptanceRate DESC;

-- Acceptance rate by financial support type
SELECT 
    f.SupportType,
    COUNT(DISTINCT fs.ApplicationID) AS TotalApplicants,
    SUM(CASE WHEN a.Comment LIKE '%accept%' THEN 1 ELSE 0 END) AS Accepted,
    ROUND(SUM(CASE WHEN a.Comment LIKE '%accept%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS AcceptanceRate
FROM gold.FinancialSupportDIM f
JOIN gold.ApplicationFact fs 
    ON f.ApplicationID = fs.ApplicationID
JOIN gold.ApplicationFact a 
    ON fs.ApplicationID = a.ApplicationID
GROUP BY f.SupportType
ORDER BY AcceptanceRate DESC;


-- Which universities or academic institutions host the highest number of scholarships?
-- Shows which universities have the largest scholarship offerings.

SELECT 
    University,
    COUNT(DISTINCT Schol_ID) AS TotalScholarships
FROM gold.ScholarshipDIM
GROUP BY University
ORDER BY TotalScholarships DESC;



--  Are shorter-duration programs more in demand?
--  Measures whether applicants prefer shorter programs based on application counts
SELECT 
    S.Duration,
    COUNT(DISTINCT A.ApplicationID) AS TotalApplications
FROM gold.ApplicationFact A
JOIN gold.ScholarshipDIM S 
    ON A.ScholarshipKey = S.ScholarshipKey
GROUP BY S.Duration
ORDER BY TotalApplications DESC;


-- What are the most common types of financial support offered?
--  Identifies popular financial support types (tuition, accommodation, stipend, travel, etc.)

SELECT 
    SupportType,
    COUNT(*) AS TotalSupports
FROM gold.FinancialSupportDIM
GROUP BY SupportType
ORDER BY TotalSupports DESC;


--Which universities have the highest academic rankings?
-- Lists the top 10 universities by rating

SELECT TOP 10 
    University,
    Rating,
    Location
FROM gold.ScholarshipDIM
ORDER BY Rating DESC;


--  Has the number of participating universities increased over time?
-- (Measures university participation growth across scholarship start years.)

SELECT 
    StartYear,
    COUNT(DISTINCT University) AS ParticipatingUniversities
FROM gold.ScholarshipDIM
GROUP BY StartYear
ORDER BY StartYear;


-- Percentage of local vs international applicants
-- Measures how many applicants are from the home country versus abroad.


SELECT 
    CASE 
        WHEN Nationality IN ('Egyptian', 'Egypt', 'Local') THEN 'Local'
        ELSE 'International'
    END AS ApplicantType,
    COUNT(DISTINCT ApplicantID) AS TotalApplicants,
    ROUND(COUNT(DISTINCT ApplicantID) * 100.0 / 
          (SELECT COUNT(DISTINCT ApplicantID) FROM gold.ApplicantDIM), 2) AS Percentage
FROM gold.ApplicantDIM
GROUP BY 
    CASE 
        WHEN Nationality IN ('Egyptian', 'Egypt', 'Local') THEN 'Local'
        ELSE 'International'
    END
ORDER BY Percentage DESC;


