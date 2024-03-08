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



BEGIN
   proc_Checkin(49);
END;
/

