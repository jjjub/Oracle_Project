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
                        on c.crspk = o.cospk
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
                                                                    
select * from vwStudentInfo;


--vwData
--자료 조회, 출력될 정보는  자료번호, 자료제목, 자료내용, 등록일, 작성교사명   
CREATE OR REPLACE VIEW vwData AS
select 
    d.datapk as 번호,
    d.datatitle as 제목,
    d.datadetail as 내용,
    d.regdate as 등록일,
    u.name as 작성교사명
from tblData d 
    inner join tblTeacher t
        on d.tpk=t.tpk
            inner join tblUser u
                on u.userpk=t.tpk
                ORDER BY d.datapk ASC;

--vwAllCompany(전체 기업 조회)
CREATE OR REPLACE VIEW vwAllCompany AS
select 
    c.comname as 기업명,
    s.comsize as 규모,
    ct.category as 업종,
    l.location as 소재지,
    i.industry as 산업
from tblCompany c
    inner join tblComSize s on c.sizepk=s.sizepk
    inner join tblComCategory ct on c.catepk=ct.catepk
    inner join tblComLocation l on c.locpk=l.locpk
    inner join tblComIndustry i on c.idstpk=i.idstpk
    order by c.compk asc;

                                
--vwNameCompany(기업명으로 조회)
CREATE OR REPLACE VIEW vwNameCompany AS
select 
    c.comname as 기업명,
    s.comsize as 규모,
    ct.category as 업종,
    l.location as 소재지,
    i.industry as 산업
from tblCompany c
    inner join tblComSize s on c.sizepk=s.sizepk
    inner join tblComCategory ct on c.catepk=ct.catepk
    inner join tblComLocation l on c.locpk=l.locpk
    inner join tblComIndustry i on c.idstpk=i.idstpk
    where c.comname='삼성전자'
    order by c.compk asc;
    

--vwSizeCompany(규모로 조회)
CREATE OR REPLACE VIEW vwSizeCompany AS
select 
    c.comname as 기업명,
    s.comsize as 규모,
    ct.category as 업종,
    l.location as 소재지,
    i.industry as 산업
from tblCompany c
    inner join tblComSize s on c.sizepk=s.sizepk
    inner join tblComCategory ct on c.catepk=ct.catepk
    inner join tblComLocation l on c.locpk=l.locpk
    inner join tblComIndustry i on c.idstpk=i.idstpk
    where s.comsize='대기업'
    order by c.compk asc;

--vwCateCompany(업종으로 조회)
CREATE OR REPLACE VIEW vwCateCompany AS
select 
    c.comname as 기업명,
    s.comsize as 규모,
    ct.category as 업종,
    l.location as 소재지,
    i.industry as 산업
from tblCompany c
    inner join tblComSize s on c.sizepk=s.sizepk
    inner join tblComCategory ct on c.catepk=ct.catepk
    inner join tblComLocation l on c.locpk=l.locpk
    inner join tblComIndustry i on c.idstpk=i.idstpk
    where ct.category='서비스업'
    order by c.compk asc;
            
--vwLocCompany(소재지로 조회)
CREATE OR REPLACE VIEW vwLocCompany AS
select 
    c.comname as 기업명,
    s.comsize as 규모,
    ct.category as 업종,
    l.location as 소재지,
    i.industry as 산업
from tblCompany c
    inner join tblComSize s on c.sizepk=s.sizepk
    inner join tblComCategory ct on c.catepk=ct.catepk
    inner join tblComLocation l on c.locpk=l.locpk
    inner join tblComIndustry i on c.idstpk=i.idstpk
    where l.location='서울특별시'
    order by c.compk asc;

--vwIndCompany(산업으로 조회)
CREATE OR REPLACE VIEW vwIndCompany AS
select 
    c.comname as 기업명,
    s.comsize as 규모,
    ct.category as 업종,
    l.location as 소재지,
    i.industry as 산업
from tblCompany c
    inner join tblComSize s on c.sizepk=s.sizepk
    inner join tblComCategory ct on c.catepk=ct.catepk
    inner join tblComLocation l on c.locpk=l.locpk
    inner join tblComIndustry i on c.idstpk=i.idstpk
    where i.industry='SI'
    order by c.compk asc;
    


--vwAllTask
--과제조회(과제번호,과제내용,교사이름)
CREATE OR REPLACE VIEW vwAllTask AS
select
    t.taskpk as 과제번호,
    t.task as 내용,
    u.name as 교사이름
from tblTask t
    inner join tblTeacher tc
        on t.tpk=tc.tpk
            inner join tblUser u
                on u.userpk=tc.tpk
                    order by t.taskpk asc;
                    
--vwNumTask                   
CREATE OR REPLACE VIEW vwNumTask AS
select
    t.taskpk as 과제번호,
    t.task as 내용,
    u.name as 교사이름
from tblTask t
    inner join tblTeacher tc
        on t.tpk=tc.tpk
            inner join tblUser u
                on u.userpk=tc.tpk
                    where t.taskpk =1
                    order by t.taskpk asc;
                    

--vwTaskSubmit
--학생들이 제출한 답안 조회(과제번호,과제내용,답안,학생이름)"      
CREATE OR REPLACE VIEW vwTaskSubmit AS
select
    t.taskpk as 과제번호,
    t.task as 내용,
    ts.tsanswer as 답안,
    u.name as 학생이름
from tblTask t
    inner join tblTaskSubmit ts
        on t.taskpk =ts.taskpk
            inner join tblCourseParticipants cp
                on ts.stupk = cp.stupk
                    inner join tblStudent st
                        on st.stupk=cp.stupk
                            inner join tblUser u
                                on u.userpk = st.stupk
--                                where t.taskpk=1
--                                where u.name = '박원석'
                                ;

--vwCourse
CREATE OR REPLACE VIEW vwCourse AS
select 
    c.crspk as 과정번호,
    c.crsname as 과정명,
    sb.subname as 강의과목,
    oc.field as 최대인원수,
    u.name as 강의가능강사,
    c.crsduration as 훈련일수
from tblCourse c
    left outer join tblOnGoingSubject ogs
        on ogs.crspk=c.crspk
            inner join tblSubject sb
                on sb.subpk=ogs.subpk
                    inner join tblOpenCourse oc
                        on c.crspk=oc.crspk
                            inner join tblTeacher t
                                on t.tpk=oc.tpk
                                    inner join tblUser u
                                        on t.tpk=u.userpk
                                        order by c.crspk asc;
                                    
                         

--vwSubject
--과목 정보 출력(과목번호,과목명,강의내용,수업시간,필수과목여부,강의 가능 강사)
CREATE OR REPLACE VIEW vwSubject AS
select 
    sb.subpk as 과목번호,
    sb.subname as 과목명,
    sb.subdetail as 강의내용,
    sb.subhour as 수업시간,
    sb.essential as 필수과목여부
from tblSubject sb
order by sb.subpk;


--vwClassroom
--강의실 정보 출력(강의실번호,강의실명,수용인원,이용가능여부)
CREATE OR REPLACE VIEW vwClassroom AS
select 
    c.crpk as 강의실번호,
    c.crname as 강의실명,
    c.crcapacity as 수용인원,
    c.crpossible as 이용가능여부
from tblClassroom c
order by c.crpk asc;


--vwAllBook
--공통 교재 정보 출력(교재번호,교재명,저자,출판사)
CREATE OR REPLACE VIEW vwAllBook AS
select 
    b.bookpk as 교재번호,
    b.tbname as 교재명,
    b.writer as 저자,
    b.publisher as 출판사
from tblTextBook b
order by b.bookpk;
 
--vwSubBook   
--과목별 교재 정보 출력(교재번호,교재명,저자,출판사,발행일)  
CREATE OR REPLACE VIEW vwSubBook AS
select 
    sb.subpk as 과목번호,
    sb.subname as 과목명,
    b.bookpk as 교재번호,
    b.tbname as 교재명,
    b.writer as 저자,
    b.publisher as 출판사
from tblTextBook b
    inner join tblSubjectTextbook st
        on b.bookpk=st.bookpk
            inner join tblSubject sb
                on sb.subpk=st.subpk
                order by sb.subpk asc;
    



