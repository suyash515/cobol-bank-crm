       IDENTIFICATION DIVISION.
       PROGRAM-ID. COMPLREP.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z16.
       OBJECT-COMPUTER. IBM-Z16.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       EXEC SQL INCLUDE SQLCA END-EXEC.

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  HV-COMPLAINT-ID       PIC X(10).
       01  HV-CUSTOMER-ID        PIC X(10).
       01  HV-DATE-RECEIVED      DATE.
       01  HV-STATUS             PIC X(10).
       01  HV-DESCRIPTION        PIC X(100).
       01  HV-RESOLUTION         PIC X(100).
       01  HV-RESOLVED-DATE      DATE.
       EXEC SQL END DECLARE SECTION END-EXEC.

       01  WS-COUNT              PIC 9(5) VALUE ZERO.
       01  WS-RESPONSE           PIC X(100).

       PROCEDURE DIVISION.

       MAIN-LOGIC.
           DISPLAY "GENERATING CUSTOMER COMPLAINT REPORT"

           EXEC SQL
               DECLARE COMPL_CURSOR CURSOR FOR
               SELECT COMPLAINT_ID, CUSTOMER_ID, DATE_RECEIVED, STATUS,
                      DESCRIPTION, RESOLUTION, RESOLVED_DATE
               FROM CUSTOMER_COMPLAINTS
               ORDER BY DATE_RECEIVED DESC
           END-EXEC

           EXEC SQL OPEN COMPL_CURSOR END-EXEC

           PERFORM UNTIL SQLCODE NOT = 0
               EXEC SQL
                   FETCH COMPL_CURSOR INTO
                       :HV-COMPLAINT-ID,
                       :HV-CUSTOMER-ID,
                       :HV-DATE-RECEIVED,
                       :HV-STATUS,
                       :HV-DESCRIPTION,
                       :HV-RESOLUTION,
                       :HV-RESOLVED-DATE
               END-EXEC

               IF SQLCODE = 0
                   ADD 1 TO WS-COUNT
                   DISPLAY "------------------------------"
                   DISPLAY "Complaint ID  : " HV-COMPLAINT-ID
                   DISPLAY "Customer ID   : " HV-CUSTOMER-ID
                   DISPLAY "Received Date : " HV-DATE-RECEIVED
                   DISPLAY "Status        : " HV-STATUS
                   DISPLAY "Description   : " HV-DESCRIPTION
                   DISPLAY "Resolution    : " HV-RESOLUTION
                   DISPLAY "Resolved Date : " HV-RESOLVED-DATE
                   DISPLAY "------------------------------"
               END-IF
           END-PERFORM

           EXEC SQL CLOSE COMPL_CURSOR END-EXEC

           IF SQLCODE = 100 AND WS-COUNT = 0
               MOVE 'NO COMPLAINT RECORDS FOUND' TO WS-RESPONSE
           ELSE
               MOVE 'COMPLAINT REPORT GENERATED' TO WS-RESPONSE
           END-IF

           DISPLAY WS-RESPONSE
           GOBACK.
