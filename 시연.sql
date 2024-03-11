--학생, 과목, 책 기타 등등
select * from vwStudentStatus;
select * from vwSubject;
select * from vwSubBook;
select * from vwAllBook;
select * from vwSubBook;
--과정
select * from vwCourse;
select * from tblOpencourse;
select * from vwCourseparticipantions;
--기능
select * from vwIndCompany;
select * from vwAllTask;
select * from vwStudentTask;
select * from vwExamBySub;
select * from vwAllExamResult;

--자료
select * from vwTeacerData;

--게시판
select * from vwStudentBoard;
select * from vwStudentComment;

--시험
select * from vwStudentExam;
select * from vwStudentScore; --특정 한사람만인데?

--교육과정 등록
begin
     InsertOpencourse(1, '테스트', '2024-01-02', 20, 2, 212);
end;
/

begin
     InsertOpencourse(1, '테스트', '2024-01-02', 20, 2, 227);
end;
/    
select * from tblOpenCourse;

BEGIN
    procTeacherUpdate(235, '수정용', 'update1', '1234', '01011112222', '휴직');
END;
/
select * from tblUser;

BEGIN
    proc_Checkin(131);
END;
/


