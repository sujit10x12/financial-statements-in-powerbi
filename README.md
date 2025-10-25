# 🏬 GL Retail Corporation - Financial Reporting Automation (Power BI + Excel)

<img width="1584" height="396" alt="banner" src="/images/banner.png" />

---

## 🧾 Project Overview

**GL Retail Corporation** — a multi-store retail company with a data-driven culture — hired me as a **Business Intelligence Developer** to automate and modernize their reporting systems.

The goal was to enhance data reliability, improve report efficiency, and uncover deeper financial insights through modern BI tools.

---

## 🎯 Objectives

### 1. Automate & Visualize Reporting Integrity
- Streamlined manual AR & AP Ageing reports.
- Consolidated data from multiple sources into a single data model.
- Reduced manual adjustments by automating calculations in Power Query.

### 2. Improve Reporting Efficiency
- Automated **Income Statement**, **Balance Sheet**, and **Cash Flow** reporting using Power BI.
- Built dynamic dashboards with drill-through and ratio analysis.
- Integrated **Excel** for ad-hoc financial analysis.

### 3. Develop New Insights
- Enhanced visibility into **product category performance** and **inventory efficiency**.
- Identified data misallocations across sales categories.
- Enabled leadership to make faster, insight-driven decisions.

---

## 🏢 Organization Context

| Attribute | Description |
|------------|-------------|
| **Company Name** | GL Retail Corporation |
| **Industry** | Retail |
| **Head Office** | 1 Head Office + 5 Retail Stores |
| **Approach** | Data-driven decision-making |
| **Objective** | Turn good performance into great through analytics |

---

## ⚙️ Tools & Technologies

| Tool | Purpose |
|------|----------|
| **Azure Data Studio** | Data extraction from company database |
| **Power Query** | Data transformation and modeling |
| **Power BI** | Financial statement dashboards & visualizations |
| **Microsoft Excel** | Additional financial analysis and validation |

---

## 📊 Project Components

### 1. **Accounts Receivable (AR) & Accounts Payable (AP) Ageing**
- Automated ageing calculations using Power Query.
- Replicated the existing Excel format for familiarity.
- Ensured real-time refresh from database connections.

### 2. **Financial Statements**
- Developed automated **Income Statement**, **Balance Sheet**, and **Cash Flow** dashboards.
- Visualized **key financial ratios** (Profit Margin, Current Ratio, Debt-to-Equity).
- Created a high-level summary view for management.

### 3. **Sales & Inventory Analysis**
- Identified and corrected product/category misallocations.
- Improved accuracy for cross-team reporting.
- Analyzed category performance for strategic product planning.

---

## 🧩 Workflow Summary

```text
Azure Data Studio → Power Query → Power BI Financial Dashboards → Excel Analysis
```

- Data Extraction: Connected to the company’s SQL database.
- Data Modeling: Cleaned, merged, and structured data in Power Query.
- Visualization: Built interactive dashboards for financial KPIs.
- Validation: Cross-checked results and ratios in Excel.

---

## 🗄️ Data Extraction — SQL View (vwGLTrans)

To centralize and simplify the data needed for financial statements, a SQL view was created in Azure Data Studio.
This view joins multiple dimension and fact tables to provide a unified dataset for Power BI modeling.

```sql
-- =============================================
-- Author:      Sujeet Singh
-- Project:     GL Retail Corporation - BI Automation
-- Description: Consolidated view for Financial Statements
-- =============================================

CREATE VIEW vwGLTrans
AS
    -- This view contains all the information required 
    -- to create automated financial statements in Power BI.

    SELECT 
        -- FactGLTran
        gl.FactGLTranID,
        gl.JournalID,
        gl.GLTranDescription,
        gl.GLTranAmount,
        gl.GLTranDate,

        -- dimGLAcct
        acc.AlternateKey AS GLAccNum,
        acc.GLAcctName,
        acc.[Statement],
        acc.Category,
        acc.Subcategory,

        -- dimStore
        store.AlternateKey AS StoreNum,
        store.StoreName,
        store.ManagerID,
        store.PreviousManagerID,
        store.ContactTel,
        store.AddressLine1,
        store.AddressLine2,
        store.ZipCode,

        -- dimRegion
        region.AlternateKey AS RegionNum,
        region.RegionName,
        region.SalesRegionName,

        -- Metadata: Last Refresh Timestamp
        CONVERT(
            DATETIME2, 
            GETDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time'
        ) AS [Last Refresh Date]

    FROM dbo.FactGLTran AS gl
    INNER JOIN dbo.dimGLAcct AS acc 
        ON gl.GLAcctID = acc.GLAcctID
    INNER JOIN dbo.dimStore AS store 
        ON gl.StoreID = store.StoreID
    INNER JOIN dbo.dimRegion AS region 
        ON store.RegionID = region.RegionID;
GO
```

---

## 🧩 Data Modeling in Power BI

After extracting data from the SQL view (`vwGLTrans`) created in **Azure Data Studio**, the next step was to build a robust, relational data model using **Power Query Editor** and **DAX**.

---

### ⚙️ Steps to Build the Data Model

#### 1️⃣ Connect to the Database
- Connected **Power BI** to the company database via **Azure SQL Database**.  
- Imported the SQL View `vwGLTrans` as the single source of truth for all financial reporting.

#### 2️⃣ Load as a Staging Query
- In **Power Query Editor**, the SQL view was loaded as a **staging query**.  
- The staging query acts as a **raw data layer**, ensuring that transformations can be referenced rather than repeated.

#### 3️⃣ Create Fact and Dimension Queries
- **Fact Table:** `FactGLTran` (transactions)  
- **Dimension Tables:** `dimGLAcct`, `dimStore`, `dimRegion`  
- Each was created by referencing the staging query and filtering relevant columns.

#### 4️⃣ Build Relationships
- Linked dimensions to the fact table using **primary and foreign keys**:
  - `FactGLTran[GLAcctID]` → `dimGLAcct[GLAcctID]`
  - `FactGLTran[StoreID]` → `dimStore[StoreID]`
  - `dimStore[RegionID]` → `dimRegion[RegionID]`
- Ensured correct **cardinality (Many-to-One)** and **referential integrity** for accurate analysis.

---

## 💰 Financial Statement — Power BI Automation


### 🧩 Steps to Build the Income Statement & Balance Sheet

<img width="1584" height="396" alt="banner" src="/images/income-statement.png" />

#### 1️⃣ Create a Custom Headers Table in Excel
- Designed a **Headers Table** to control the contents and appearance of the financial statements.
- Defined **sorting order**, **hierarchy**, and **display names** for all financial line items.
- This table serves as the foundation for building a flexible and easily maintainable report.

#### 2️⃣ Import Headers Table to Power BI
- Imported the custom Headers Table into the **Power BI Data Model**.
- Used it as a **template** for dynamically organizing and formatting line items.

#### 3️⃣ Create DAX Measures for Income Statement Logic
Built key DAX measures to automate financial statement calculations and enable dynamic reporting.

---

## 🧾Income Statement DAX Calculation

🔹**Sum of all transactions**
```DAX
SumAmount = SUM(FactGLTran[GLTranAmount])
```

🔹**Income Statement transactions only**
```DAX
I/S Amount = CALCULATE(
    ABS([SumAmount]),
    DimHeaders[Statement] = "Income Statement"
)
```

🔹**Running subtotal for each section**
```DAX
I/S Subtotal = CALCULATE(
    [I/S Amount],
    FILTER(ALL(DimHeaders), DimHeaders[Sort] < MAX(DimHeaders[Sort]))
)
```

🔹**% of Revenue (staging)**
```DAX
Staging % of Revenue =
VAR Revenue =
    CALCULATE([I/S Amount], FILTER(ALL(DimHeaders), DimHeaders[Category] = "Revenue"))
RETURN
    DIVIDE([I/S Subtotal], Revenue, 0)
```

🔹**Final formatted % of Revenue**
```DAX
% of Revenue = FORMAT([Staging % of Revenue], "0.00%")
```
---

🔹**Flip sign for Waterfall Chart**
```DAX
Sign Flip SumAmount = [SumAmount] * -1
```

🔹**Gross Margin Ratio**
```DAX
Gross Margin Ratio =
VAR GrossProfit = CALCULATE([I/S Subtotal], DimHeaders[Category] = "Gross Profit")
VAR Revenue = ABS(CALCULATE([SumAmount], DimHeaders[Category] = "Revenue"))
RETURN DIVIDE(GrossProfit, Revenue, 0)
```

🔹**Operating Margin Ratio**
```DAX
Operating Margin Ratio =
VAR OperatingMargin = CALCULATE([I/S Subtotal], DimHeaders[Category] = "EBIT")
VAR Revenue = ABS(CALCULATE([SumAmount], DimHeaders[Category] = "Revenue"))
RETURN DIVIDE(OperatingMargin, Revenue, 0)
```

🔹**Gross Profit %**
```DAX
Gross Profit % = CALCULATE([Staging % of Revenue], DimHeaders[Category] = "Gross Profit %")
```

🔹**Main Income Statement measure (switch logic)**
```DAX
Income Statement =
VAR Display_Filter = NOT ISFILTERED(DimGLAccts[Subcategory])
RETURN
    SWITCH(
        TRUE(),
        SELECTEDVALUE(DimHeaders[MeasureName]) = "Subtotal" && Display_Filter, [I/S Subtotal],
        SELECTEDVALUE(DimHeaders[MeasureName]) = "Per_Of_Revenue" && Display_Filter, [% of Revenue],
        [I/S Amount]
    )
```

🔹 **Testing Measures**
```DAX
Is Subtotal = SELECTEDVALUE(DimHeaders[MeasureName]) = "Subtotal"
Is Filtered = ISFILTERED(DimGLAccts[Subcategory])
Is Not Filtered = NOT ISFILTERED(DimGLAccts[Subcategory])
Is Subtotal & Is Not Filtered = [Is Subtotal] && [Is Not Filtered]
```

---

## 🧾 Balance Sheet DAX Calculation

<img width="1584" height="396" alt="banner" src="/images/balance-sheet.png" />

### 🧩 Steps to Build the Balance Sheet

The Balance Sheet report in Power BI automates the calculation of assets, liabilities, and equity — dynamically updating as transactions flow into the system. It ensures accurate reflection of retained earnings and equity relationships across periods.

🔹 **Balance Sheet Amount**
```DAX
B/S Amount =
CALCULATE(
    [SumAmount],
    DimHeaders[Statement] = "Balance Sheet"
)
```

🔹 **Cumulative Amount for each section**
```DAX
Cumulative Amount =
CALCULATE(
    [B/S Amount],
    FILTER(
        ALL(DimDate),
        DimDate[Date] <= MAX(DimDate[Date])
    )
)
```

🔹 **Balance Sheet Subtotal for each section**
```DAX
B/S Subtotal =
CALCULATE(
    [B/S Amount],
    ALL(DimHeaders),
    DimHeaders[Balance Sheet Section] IN VALUES(DimHeaders[Balance Sheet Section])
)
```

🔹 **Opening Retained Earnings**
```DAX
Opening Retained Earnings =
CALCULATE(
    ABS([SumAmount]),
    FactGLTran[GLAcctNum] = 4100,
    ALL(DimDate),
    ALL(DimHeaders)
)
```

🔹 **Retained Earnings**
```DAX
Retained Earnings =
[Opening Retained Earnings] +
CALCULATE(
    ABS([SumAmount]),
    FILTER(ALL(DimDate), DimDate[Date] <= MAX(DimDate[Date])),
    FILTER(ALL(DimHeaders), DimHeaders[Statement] = "Income Statement")
)
```

🔹 **Total Equity**
```DAX
Total Equity = [B/S Subtotal] + [Retained Earnings]
```

🔹 **Total Liabilities & Equity**
```DAX
Total Liabilities & Equity =
CALCULATE(
    [Cumulative Balance],
    ALL(DimHeaders),
    DimHeaders[Balance Sheet Section] = "Total Liabilities"
        || DimHeaders[Balance Sheet Section] = "Total Equity"
)
+ [Retained Earnings]
```

🔹 **Final Balance Sheet Measure**
```DAX
Balance Sheet =
VAR Display_Filtered = NOT ISFILTERED(DimGLAccts[Subcategory])
RETURN
SWITCH(
    TRUE(),
    SELECTEDVALUE(DimHeaders[MeasureName]) = "Section_Subtotal" && Display_Filtered, [B/S Subtotal],
    SELECTEDVALUE(DimHeaders[MeasureName]) = "Retained_Earnings" && Display_Filtered, [Retained Earnings],
    SELECTEDVALUE(DimHeaders[MeasureName]) = "Total_Equity" && Display_Filtered, [Total Equity],
    SELECTEDVALUE(DimHeaders[MeasureName]) = "Total_LE" && Display_Filtered, [Total Liabilities & Equity],
    [Cumulative Balance]
)
```

## 📈 Financial Ratios — Analytical Insights

These measures enable real-time ratio analysis directly from the Power BI dashboard, providing management with deeper insights into the company’s financial health.

#### 1️⃣ Gross Margin Ratio

```DAX
Gross Margin Ratio =
VAR GrossProfit = CALCULATE([I/S Subtotal], DimHeaders[Category] = "Gross Profit")
VAR Revenue = ABS(CALCULATE([SumAmount], DimHeaders[Category] = "Revenue"))
RETURN DIVIDE(GrossProfit, Revenue, 0)
```

#### 2️⃣ Operating Margin Ratio

```DAX
Operating Margin Ratio =
VAR OperatingMargin = CALCULATE([I/S Subtotal], DimHeaders[Category] = "EBIT")
VAR Revenue = ABS(CALCULATE([SumAmount], DimHeaders[Category] = "Revenue"))
RETURN DIVIDE(OperatingMargin, Revenue, 0)
```

#### 3️⃣ Current Ratio

```DAX
Current Ratio =
VAR CurrentAssets = CALCULATE([Cumulative Amount], DimHeaders[Category] = "Current Assets")
VAR CurrentLiabilities = CALCULATE([Cumulative Amount], DimHeaders[Category] = "Current Liabilities")
RETURN DIVIDE(CurrentAssets, CurrentLiabilities, 0)
```

#### 4️⃣ Debt Ratio

```DAX
Debt Ratio =
VAR TotalDebt = CALCULATE([Cumulative Amount], DimGLAccts[Subcategory] = "Long-term Debt")
VAR TotalAssets = CALCULATE([B/S Subtotal], DimHeaders[Category] = "Total Assets")
RETURN DIVIDE(TotalDebt, TotalAssets, 0)
```
