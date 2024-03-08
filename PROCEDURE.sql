
--procCompany
--생성
CREATE OR REPLACE PROCEDURE procCompany (
    nameIn IN VARCHAR2 DEFAULT NULL,
    sizeIn IN VARCHAR2 DEFAULT NULL,
    categoryIn IN VARCHAR2 DEFAULT NULL,
    locationIn IN VARCHAR2 DEFAULT NULL,
    industryIn IN VARCHAR2 DEFAULT NULL,
    result_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN result_cursor FOR
    SELECT
        c.comname AS 기업명,
        s.comsize AS 규모,
        ct.category AS 업종,
        l.location AS 소재지,
        i.industry AS 산업
    FROM
        tblCompany c
        INNER JOIN tblComSize s ON c.sizepk=s.sizepk
        INNER JOIN tblComCategory ct ON c.catepk=ct.catepk
        INNER JOIN tblComLocation l ON c.locpk=l.locpk
        INNER JOIN tblComIndustry i ON c.idstpk=i.idstpk
    WHERE
        (nameIn IS NULL OR c.comname = nameIn) AND
        (sizeIn IS NULL OR s.comsize = sizeIn) AND
        (categoryIn IS NULL OR ct.category = categoryIn) AND
        (locationIn IS NULL OR l.location = locationIn) AND
        (industryIn IS NULL OR i.industry = industryIn);
END procCompany;
/


--출력
DECLARE
    v_result_cursor SYS_REFCURSOR;
    v_company_name tblCompany.comname%TYPE;
    v_company_size tblComSize.comsize%TYPE;
    v_company_category tblComCategory.category%TYPE;
    v_company_location tblComLocation.location%TYPE;
    v_company_industry tblComIndustry.industry%TYPE;
    v_separator VARCHAR2(10) := ' | ';
BEGIN
    procCompany(
        nameIn => NULL,
        sizeIn => NULL,
        categoryIn => NULL,
        locationIn => NULL,
        industryIn => NULL,
        result_cursor => v_result_cursor
    );

    LOOP
        FETCH v_result_cursor INTO
            v_company_name, v_company_size, v_company_category, v_company_location, v_company_industry;
        EXIT WHEN v_result_cursor%NOTFOUND;

        -- 결과 처리
        DBMS_OUTPUT.PUT_LINE('기업명: ' || v_company_name ||
                             v_separator || '규모: ' || v_company_size ||
                             v_separator || '업종: ' || v_company_category ||
                             v_separator || '소재지: ' || v_company_location ||
                             v_separator || '산업: ' || v_company_industry);
    END LOOP;

    CLOSE v_result_cursor;
END;
/


begin
    procCompany('삼성전자');
end;
/