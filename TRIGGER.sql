CREATE OR REPLACE TRIGGER recruit_to_user
AFTER UPDATE OF result ON tblRecruit
FOR EACH ROW
DECLARE
    v_userpk tblUser.userpk%TYPE;
    v_existing_user NUMBER;
BEGIN
    -- result가 'P'로 변경되었을 때만 작동
    IF :NEW.result = 'P' THEN
        -- 이미 존재하는지 확인
        SELECT COUNT(*)
        INTO v_existing_user
        FROM tblUser
        WHERE ssn = :NEW.ssn;

        -- 이미 사용자가 있는 경우 중복 방지
        IF v_existing_user = 0 THEN
            -- tblUser에 삽입
            INSERT INTO tblUser (userpk, role, name, ssn, tel, id, pw, regdate)
            VALUES (
                (SELECT NVL(MAX(userpk), 0) + 1 FROM tblUser),
                '학생', -- 역할
                :NEW.recname, -- 이름
                :NEW.ssn, -- 주민등록번호
                :NEW.rectel, -- 전화번호
                DBMS_RANDOM.STRING('A', 8),
                SUBSTR(:NEW.ssn, 8, 15), -- 임시 PW (주민등록번호 뒷자리)
                SYSDATE -- 등록일자
            )
            RETURNING userpk INTO v_userpk; -- 삽입된 사용자의 기본키를 저장

            -- tblStudent에 삽입
            INSERT INTO tblStudent (stupk, grade, attrate, stustspk)
            VALUES (
                v_userpk, 
                NULL,
                NULL,
                1
            );

            -- tblCourseParticipants에 삽입 (예시 데이터)
            INSERT INTO tblCourseParticipants (stupk, ocpk)
            VALUES (v_userpk, :NEW.ocpk); 
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- 오류 발생 시 아무 작업도 수행하지 않음
END;
/




