       IDENTIFICATION DIVISION.
       PROGRAM-ID. DATAEXPORT.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z16.
       OBJECT-COMPUTER. IBM-Z16.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EXPORT-FILE ASSIGN TO DATAOUT
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.

       FILE SECTION.
       FD  EXPORT-FILE.
       01  EXPORT-RECORD         PIC X(300).

       WORKING-STORAGE SECTION.

       EXEC SQL INCLUDE SQLCA END-EXEC.

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  HV-CUSTOMER-ID        PIC X(10).
       01  HV-NAME               PIC X(50).
       01  HV-ADDRESS            PIC X(100).
       01  HV-PHONE              PIC X(15).
       01  HV-EMAIL              PIC X(50).
       01  HV-SEGMENT            PIC X(20).
       EXEC SQL END DECLARE SECTION END-EXEC.

       01  WS-FILE-STATUS        PIC XX.
       01  WS-RESPONSE           PIC X(100).
       01  WS-COUNT              PIC 9(5) VALUE ZERO.

       PROCEDURE DIVISION.

       MAIN-LOGIC.
           DISPLAY "STARTING CUSTOMER DATA EXPORT"

           OPEN OUTPUT EXPORT-FILE

           EXEC SQL
               DECLARE CUST_CUR CURSOR FOR
               SELECT CUSTOMER_ID, NAME, ADDRESS, PHONE, EMAIL, SEGMENT
               FROM CUSTOMER_MASTER
           END-EXEC

           EXEC SQL OPEN CUST_CUR END-EXEC

           PERFORM UNTIL SQLCODE NOT = 0
               EXEC SQL
                   FETCH CUST_CUR INTO
                       :HV-CUSTOMER-ID,
                       :HV-NAME,
                       :HV-ADDRESS,
                       :HV-PHONE,
                       :HV-EMAIL,
                       :HV-SEGMENT
               END-EXEC

               IF SQLCODE = 0
                   STRING
                       HV-CUSTOMER-ID DELIMITED BY SIZE ',' 
                       HV-NAME        DELIMITED BY SIZE ',' 
                       HV-ADDRESS     DELIMITED BY SIZE ',' 
                       HV-PHONE       DELIMITED BY SIZE ',' 
                       HV-EMAIL       DELIMITED BY SIZE ',' 
                       HV-SEGMENT     DELIMITED BY SIZE
                       INTO EXPORT-RECORD

                   WRITE EXPORT-RECORD
                   ADD 1 TO WS-COUNT
               END-IF
           END-PERFORM

           EXEC SQL CLOSE CUST_CUR END-EXEC

           IF SQLCODE = 100 AND WS-COUNT = 0
               MOVE 'NO CUSTOMER DATA TO EXPORT' TO WS-RESPONSE
           ELSE
               MOVE 'CUSTOMER DATA EXPORT COMPLETE' TO WS-RESPONSE
           END-IF

           DISPLAY WS-RESPONSE
           DISPLAY "RECORDS EXPORTED: " WS-COUNT

           CLOSE EXPORT-FILE

           GOBACK.
