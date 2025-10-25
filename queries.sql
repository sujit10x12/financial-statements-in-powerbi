CREATE VIEW vwGLTrans
-- This view contains all the information require to create financial statements.
AS
    -- SELECT TOP (5)
    -- FactGLTran
        gl.FactGLTranID,
        gl.JournalID,
        gl.GLTranDescription,
        gl.GLTranAmount,
        gl.GLTranDate,

    -- dimGLAcct
        acc.AlternateKey AS "GLAccNum",
        acc.GLAcctName,
        acc.[Statement],
        acc.Category,
        acc.Subcategory,

    -- store
        store.AlternateKey AS "StoreNum",
        store.StoreName,
        store.ManagerID,
        store.PreviousManagerID,
        store.ContactTel,
        store.AddressLine1,
        store.AddressLine2,
        store.ZipCode,

    -- region
        region.AlternateKey AS "RegionNum",
        region.RegionName,
        region.SalesRegionName,

    -- Last Refresh Date
        CONVERT(DATETIME2, GETDATE() at time zone 'UTC' at time zone 'Central Standard Time') AS "LASt Refresh Date"

    FROM 
    dbo.FactGLTran AS gl
    INNER JOIN dbo.dimGLAcct AS acc 
    ON gl.GLAcctID = acc.GLAcctID
    INNER JOIN dbo.dimStore AS store 
    ON gl.StoreID = store.StoreID
    INNER JOIN dbo.dimRegion AS region
    ON store.RegionID = region.RegionID
GO