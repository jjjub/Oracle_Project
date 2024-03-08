--개설 과목 출력시 개설 과정 정보(과정명, 과정기간(시작 년월일, 끝 년월일), 강의실)와 과목명, 과목기간(시작 년월일, 끝 년월일), 교재명, 교사명을 출력;
create or replace view vwOpenSubject
as
select 
o.ocname as 과정명, o.regdate as 과정시작날짜,  o.regdate + c.crsduration as 과정종료날짜, s.subname as 과목명, t.tbname as 책이름, u.name as 강사명, r.crname as 강의실
from tblSubject s
    right outer join tblOnGoingSubject g
        on s.subpk = g.subpk
            right outer join tblCourse c
                on g.crspk = c.crspk
                    right outer join tblOpenCourse o
                        on c.crspk = o.crspk
                            left outer join tblClassRoom r
                                on o.crpk = r.crpk
                                    left outer join tblSubjectTextbook b
                                        on  b.subpk = s.subpk
                                            left outer join tblTextbook t
                                                on b.bookpk = t.bookpk
                                                    left outer join tblTeacher tc
                                                        on tc.tpk = o.tpk
                                                            left outer join tblUser u
                                                                on tc.tpk = u.userpk
                                                                    order by o.ocname asc;
                        
--교육생 정보 출력시 교육생 이름, 생년월일 , 전화번호, 등록일, 수강(신청)횟수,상담일지건수를 출력한다.
create or replace view vwStudentInfo
as
SELECT
    u.name AS 이름,
    u.bdate AS 생년월일,
    u.tel AS 전화번호,
    u.regdate AS 등록일,
    NVL(상담일지건수, 0) AS 상담일지건수,
    NVL(수강횟수, 0) AS 수강횟수
FROM
    tblUser u
        right outer join tblStudent s
            on s.stupk = u.userpk
                left outer join
                    (SELECT c.stupk, COUNT(*) AS 상담일지건수 FROM tblConsulting c GROUP BY stupk) c
                        ON s.stupk = c.stupk
                            left outer join
                                (SELECT p.stupk, COUNT(*) AS 수강횟수 FROM tblCourseParticipants p GROUP BY p.stupk) p
                                    ON s.stupk = p.stupk;
  
--교육생의 정보는 이름, 전화번호, 과정명, 담당강사, 수강상태, 상담일지 여부로 검색할 수 있다.
create or replace view vwStudentStauts
as
select
  u.name, u.tel, o.ocname, ss.stustatus,
    case
        when cs.상담일지여부 > 0 then '있음'
    else '없음'
    end as 상담일지여부
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
                                            tblTeacher t
                                                on o.tpk = t.tpk
                                                    left outer join
                                                        (SELECT c.stupk, COUNT(*) AS 상담일지여부 FROM tblConsulting c GROUP BY stupk) cs
                                                            on c.stupk = cs.stupk
                                                                left outer join tblStudentStatus ss
                                                                    on s.stustspk = ss.stustspk;
select * from vwOpenSubject;                                                                
select * from vwStudentInfo;
select * from vwStudentStauts;