
set serveroutput on;


--프리시저
--특정 교육생 정보 출력시 교육생 이름, 생년월일 , 주민번호 뒷자리, 전화번호, 등록일, 수강 과정명, 담당 강사,수강상태(수강예정/수강중/수료/중도탈락),상담일지내용을 출력한다
CREATE OR REPLACE PROCEDURE procSearchStudent(
    pname varchar2
)
is
    name tblUser.name%type;
    pssn tblUser.ssn%type;
    ptel tblUser.tel%type;
    pRegdate tblUser.regdate%type;
    pocname tblOpenCourse.ocname%type;
    pteacher tblUser.name%type;
    pStustatus tblStudentStatus.stustatus%type;
    pcltdiary tblConsulting.cltdiary%type;
begin
    select u.name, u.ssn, u.tel, u.Regdate, o.ocname, t.tname, ss.stustatus, cs.cltdiary into name, pssn, ptel, pregdate, pocname, pteacher, pstustatus, pcltdiary 
        from tblUser u 
            right outer join 
            tblStudent s
                on u.userpk = s.stupk
                   right outer join 
                    tblCourseParticipants c
                        on c.stupk = s.stupk
                            left outer join
                                tblOpenCourse o
                                    on o.ocpk = c.ocpk
                                        left outer join
                                            (select u.name as tname, t.tpk from tblUser u left outer join tblTeacher t on u.userpk = t.tpk) t
                                                on o.tpk = t.tpk
                                                    left outer join 
                                                        tblConsulting cs
                                                            on c.stupk = cs.stupk
                                                                left outer join 
                                                                    tblStudentStatus ss
                                                                        on s.stustspk = ss.stustspk
                                                                            where name = pname;
    dbms_output.put_line(' | 이름 |' || '     | 전화번호 |     ' ||'|생년월일|'||'   '||'|주민등록번호 뒷자리|'||'     '  ||'|등록일|'||'                                '|| '| 과정명 |'|| '                             ' ||'|담당교사|' ||'           '|| '| 학생상태 |' || '         | 상담일지내용 |');
    dbms_output.put_line('-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
    dbms_output.put_line(' '||name ||'       '|| ptel ||'       '||substr(pssn, 1, 6)||'           '||substr(pssn, 8, 15)||'             '||pregdate||'                    ' ||pocname ||'        '|| pteacher ||'                '|| pStuStatus ||pcltdiary||'                  ' );
--     name, pbirth, ptel, pregdate, pocname, pteacher, pstustatus, pcltdiary 
end procSearchStudent;
/

begin
     procSearchStudent('백은현');
end;
/

CREATE OR REPLACE PROCEDURE proc_Checkin(
    p_stupk IN tblAttendance.stupk%TYPE
)
IS
    v_checkin TIMESTAMP;  -- 체크인 시간 변수
    v_attstspk NUMBER;    -- 출석 상태 변수
BEGIN
    -- 현재 시간을 체크인 시간으로 설정
    v_checkin := SYSTIMESTAMP;

    -- 출석 상태 판단
    IF TO_CHAR(v_checkin, 'HH24:MI:SS') <= '09:10:59' THEN
        v_attstspk := 1;  -- 출석 완료
    ELSIF TO_CHAR(v_checkin, 'HH24:MI:SS') BETWEEN '09:11:00' AND '13:00:00' THEN
        v_attstspk := 2;  -- 지각
    ELSE
        v_attstspk := 4;  -- 결석처리
    END IF;

    -- 출석 정보 삽입
    INSERT INTO tblAttendance (attpk, attenddate, checkin, stupk, attstspk)
    VALUES (
        (SELECT NVL(MAX(attpk), 0) + 1 FROM tblAttendance),
        TRUNC(SYSDATE),  -- 오늘 날짜
        v_checkin,
        p_stupk,
        v_attstspk
    );

    -- 결과 출력
    IF v_attstspk = 1 THEN
        dbms_output.put_line('출석 완료');
    ELSIF v_attstspk = 2 THEN
        dbms_output.put_line('지각');
    ELSE
        dbms_output.put_line('결석처리');
    END IF;
    
    
    
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('에러 발생: ' || SQLERRM);
END;
/


--procCompany
--기업명,규모,카테고리,주소,분야로 기업 검색
CREATE OR REPLACE PROCEDURE procCompany (
    nameIn IN VARCHAR2 DEFAULT NULL,
    sizeIn IN VARCHAR2 DEFAULT NULL,
    categoryIn IN VARCHAR2 DEFAULT NULL,
    locationIn IN VARCHAR2 DEFAULT NULL,
    industryIn IN VARCHAR2 DEFAULT NULL
)
IS
    v_result_cursor SYS_REFCURSOR;
    v_company_name tblCompany.comname%TYPE;
    v_company_size tblComSize.comsize%TYPE;
    v_company_category tblComCategory.category%TYPE;
    v_company_location tblComLocation.location%TYPE;
    v_company_industry tblComIndustry.industry%TYPE;
    v_separator VARCHAR2(10) := ' | ';
    v_check number := 0;
BEGIN
    OPEN v_result_cursor FOR
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
        v_check := 1;
    END LOOP;

    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 데이터가 없습니다.');
    END IF;

    CLOSE v_result_cursor;
EXCEPTION
--    WHEN v_result_cursor%notfound THEN

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('예외가 발생했습니다: ' || SQLERRM);

END procCompany;
/

--1. 기업명 검색
EXEC procCompany('삼성전자');
--2. 규모 검색
EXEC procCompany(null,'대기업');
--3. 업종 검색
EXEC procCompany(null,null,'서비스업');
--4. 소재지 검색
EXEC procCompany(null,null,null,'서울특별시');
--5. 산업 검색
EXEC procCompany(null,null,null,null,'SI');



--procTaskSubmit
--과제번호,학생명으로 제출답안 조회(과제번호,과제내용,답안,학생명)
CREATE OR REPLACE PROCEDURE procTaskSubmit (
    numIn IN number DEFAULT NULL,
    nameIn IN VARCHAR2 DEFAULT NULL
)
IS
    v_result_cursor SYS_REFCURSOR;
    v_task_num tblTask.taskpk%TYPE;
    v_task_name tblUser.name%TYPE;
    v_task_task tblTask.task%type;
    v_task_answer tblTaskSubmit.tsanswer%type;
    v_separator VARCHAR2(10) := ' | ';
    v_check number := 0;
BEGIN
    OPEN v_result_cursor FOR
    SELECT
        t.taskpk as 과제번호,
        u.name as 학생이름,
        t.task as 내용,
        ts.tsanswer as 답안
    FROM 
        tblTask t
        inner join tblTaskSubmit ts on t.taskpk =ts.taskpk
        inner join tblCourseParticipants cp on ts.stupk = cp.stupk
        inner join tblStudent st on st.stupk=cp.stupk
        inner join tblUser u on u.userpk = st.stupk
    WHERE
        (numIn IS NULL OR t.taskpk = numIn) AND
        (nameIn IS NULL OR u.name = nameIn);

    LOOP
        FETCH v_result_cursor INTO
            v_task_num, v_task_name,v_task_task,v_task_answer;
        EXIT WHEN v_result_cursor%NOTFOUND;

        -- 결과 처리
        DBMS_OUTPUT.PUT_LINE('과제번호: ' || v_task_num ||
                             v_separator || '이름: ' || v_task_name ||
                             v_separator || '내용: ' || v_task_task ||
                             v_separator || '답안: ' || v_task_answer);
        v_check := 1;
    END LOOP;

    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 데이터가 없습니다.');
    END IF;

    CLOSE v_result_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('예외가 발생했습니다: ' || SQLERRM);

END procTaskSubmit;
/

--1. 과제 번호로 조회
EXEC procTaskSubmit(1);
--2. 학생명으로 조회
EXEC procTaskSubmit(null,'박원석');



--procCompanyInsert
CREATE OR REPLACE PROCEDURE procCompanyInsert (
    comnameIn IN VARCHAR2,
    sizeTextIn IN VARCHAR2,
    cateTextIn IN VARCHAR2,
    locTextIn IN VARCHAR2,
    idstTextIn IN VARCHAR2
)
IS
    sizepkIn NUMBER;
    catepkIn NUMBER;
    locpkIn NUMBER;
    idstpkIn NUMBER;
    
BEGIN
    -- Size 텍스트를 번호로 변환
    BEGIN
        SELECT sizepk INTO sizepkIn FROM tblComSize WHERE comsize = sizeTextIn;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Size 텍스트에 대한 번호를 찾을 수 없습니다.');
    END;

    -- Category 텍스트를 번호로 변환
    BEGIN
        SELECT catepk INTO catepkIn FROM tblComCategory WHERE category = cateTextIn;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Category 텍스트에 대한 번호를 찾을 수 없습니다.');
    END;
    
    -- Location 텍스트를 번호로 변환
    BEGIN
        SELECT locpk INTO locpkIn FROM tblComLocation WHERE location = locTextIn;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Location 텍스트에 대한 번호를 찾을 수 없습니다.');
    END;

    -- Industry 텍스트를 번호로 변환
    BEGIN
        SELECT idstpk INTO idstpkIn FROM tblComIndustry WHERE industry = idstTextIn;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Industry 텍스트에 대한 번호를 찾을 수 없습니다.');
    END;

    -- 모든 SELECT 문에서 예외가 발생하지 않았을 때만 INSERT 실행
    IF sizepkIn IS NOT NULL AND catepkIn IS NOT NULL AND locpkIn IS NOT NULL AND idstpkIn IS NOT NULL THEN
        INSERT INTO tblCompany (compk, comname, sizepk, catepk,locpk, idstpk)
        VALUES ((SELECT NVL(MAX(compk), 0) + 1 FROM tblCompany), comnameIn, sizepkIn, catepkIn,locpkIn, idstpkIn);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('회사 정보가 성공적으로 추가되었습니다.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('회사 정보를 추가하는 동안 오류가 발생했습니다.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('회사 정보를 추가하는 동안 오류가 발생했습니다: ' || SQLERRM);
END procCompanyInsert;
/


--실행
BEGIN
    procCompanyInsert('시험용회사', '대기업', '서비스업', '서울특별시', 'SI');
END;
/


--procCompanyUpdate
CREATE OR REPLACE PROCEDURE procCompanyUpdate (
    comnameIn IN VARCHAR2,
    sizeTextIn IN VARCHAR2,
    cateTextIn IN VARCHAR2,
    locTextIn IN VARCHAR2,
    idstTextIn IN VARCHAR2
)
IS
    sizepkIn NUMBER;
    catepkIn NUMBER;
    locpkIn NUMBER;
    idstpkIn NUMBER;
    count_var NUMBER;
BEGIN
     -- 입력한 회사 이름이 테이블에 존재하는지 확인
    SELECT COUNT(*) INTO count_var FROM tblCompany WHERE comname = comnameIn;
    
    IF count_var = 0 THEN
        DBMS_OUTPUT.PUT_LINE('회사가 존재하지 않습니다.');
        RETURN; 
    END IF;
    
    -- Size 텍스트를 번호로 변환
    BEGIN
        SELECT sizepk INTO sizepkIn FROM tblComSize WHERE comsize = sizeTextIn;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Size 텍스트에 대한 번호를 찾을 수 없습니다.');
    END;

    -- Category 텍스트를 번호로 변환
    BEGIN
        SELECT catepk INTO catepkIn FROM tblComCategory WHERE category = cateTextIn;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Category 텍스트에 대한 번호를 찾을 수 없습니다.');
    END;
    
    -- Location 텍스트를 번호로 변환
    BEGIN
        SELECT locpk INTO locpkIn FROM tblComLocation WHERE location = locTextIn;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Location 텍스트에 대한 번호를 찾을 수 없습니다.');
    END;

    -- Industry 텍스트를 번호로 변환
    BEGIN
        SELECT idstpk INTO idstpkIn FROM tblComIndustry WHERE industry = idstTextIn;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Industry 텍스트에 대한 번호를 찾을 수 없습니다.');
    END;

    -- 모든 SELECT 문에서 예외가 발생하지 않았을 때만 UPDATE 실행
    IF sizepkIn IS NOT NULL AND catepkIn IS NOT NULL AND locpkIn IS NOT NULL AND idstpkIn IS NOT NULL THEN
        UPDATE tblCompany
        SET
            sizepk = sizepkIn,
            catepk = catepkIn,
            locpk = locpkIn,
            idstpk = idstpkIn
        WHERE
            comname = comnameIn;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('회사 정보가 성공적으로 업데이트되었습니다.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('회사 정보를 업데이트하는 동안 오류가 발생했습니다.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('회사 정보를 업데이트하는 동안 오류가 발생했습니다: ' || SQLERRM);
END procCompanyUpdate;
/

--실행
BEGIN
    procCompanyUpdate('시험용회사', '중견기업', '서비스업', '서울특별시', 'SI');
END;
/


--procCompanyDelete
CREATE OR REPLACE PROCEDURE procCompanyDelete (
    comnameIn IN VARCHAR2
)
IS
    count_var NUMBER;
    
BEGIN

     -- 입력한 회사 이름이 테이블에 존재하는지 확인
    SELECT COUNT(*) INTO count_var FROM tblCompany WHERE comname = comnameIn;

    IF count_var = 0 THEN
        DBMS_OUTPUT.PUT_LINE('회사가 존재하지 않습니다.');
        RETURN; 
    END IF;
    
    -- 입력한 회사명에 해당하는 행 삭제
    DELETE FROM tblCompany WHERE comname = comnameIn;

    -- tblItrsCompany 테이블에서도 관련된 레코드 삭제
    DELETE FROM tblItrsCompany WHERE compk IN (SELECT compk FROM tblCompany WHERE comname = comnameIn);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('회사 정보가 성공적으로 삭제되었습니다.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('회사 정보를 삭제하는 동안 오류가 발생했습니다: ' || SQLERRM);
END procCompanyDelete;
/


--실행
BEGIN
    procCompanyDelete('시험용회사');
END;
/


--procItrsCompany
--교육생 이름으로 검색시 그 교육생이 등록한 희망기업의 정보 확인 가능

CREATE OR REPLACE PROCEDURE procItrsCompany (
    nameIn IN VARCHAR2 DEFAULT NULL
)
IS
    v_result_cursor SYS_REFCURSOR;
    v_user_num tblUser.userpk%TYPE;
    v_user_name tblUser.name%TYPE;
    v_company_name tblCompany.comname%TYPE;
    v_company_size tblComSize.comsize%TYPE;
    v_company_category tblComCategory.category%TYPE;
    v_company_location tblComLocation.location%TYPE;
    v_company_industry tblComIndustry.industry%TYPE;
    v_separator VARCHAR2(10) := ' | ';
    v_check number := 0;
BEGIN
    OPEN v_result_cursor FOR
    SELECT
        u.userpk as 사용자번호,
        u.name as 교육생,
        c.comname AS 기업명,
        s.comsize AS 규모,
        ct.category AS 업종,
        l.location AS 소재지,
        i.industry AS 산업
    FROM
        tblCompany c
        inner join tblItrsCompany itrs on c.compk=itrs.compk
        inner join tblStudent st on st.stupk= itrs.stupk
        inner join tblUser u on st.stupk=u.userpk
        INNER JOIN tblComSize s ON c.sizepk=s.sizepk
        INNER JOIN tblComCategory ct ON c.catepk=ct.catepk
        INNER JOIN tblComLocation l ON c.locpk=l.locpk
        INNER JOIN tblComIndustry i ON c.idstpk=i.idstpk
        
    WHERE
        (nameIn IS NULL OR u.name = nameIn);

    LOOP
        FETCH v_result_cursor INTO
            v_user_num, v_user_name, v_company_name,
            v_company_size, v_company_category,
            v_company_location, v_company_industry;
        EXIT WHEN v_result_cursor%NOTFOUND;

        -- 결과 처리
        DBMS_OUTPUT.PUT_LINE('학생번호: ' || v_user_num ||
                             v_separator || '학생명: ' || v_user_name ||
                             v_separator || '기업명: ' || v_company_name ||
                             v_separator || '규모: ' || v_company_size ||
                             v_separator || '업종: ' || v_company_category ||
                             v_separator || '소재지: ' || v_company_location ||
                             v_separator || '산업: ' || v_company_industry);
        v_check := 1;
    END LOOP;

    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 데이터가 없습니다.');
    END IF;

    CLOSE v_result_cursor;

EXCEPTION
--    WHEN v_result_cursor%notfound THEN

END;
/




BEGIN
   proc_Checkin(49);
END;
/


    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('예외가 발생했습니다: ' || SQLERRM);


END procItrsCompany;
/

BEGIN
    procItrsCompany('백민근');
END;
/

begin
    procCompany('삼성전자');
end;
/


