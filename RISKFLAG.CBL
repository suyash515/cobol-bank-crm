       IDENTIFICATION DIVISION.
       PROGRAM-ID. RISKFLAG.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z16.
       OBJECT-COMPUTER. IBM-Z16.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       EXEC SQL INCLUDE SQLCA END-EXEC.

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  HV-CUSTOMER-ID        PIC X(10).
       01  HV-NAME               PIC X(50).
       01  HV-SSN                PIC X(11).
       01  HV-RISK-FLAG          PIC X(20).
       01  HV-MATCHED-LIST       PIC X(20).
       EXEC SQL END DECLARE SECTION END-EXEC.

       01  WS-FLAGGED-COUNT      PIC 9(5) VALUE ZERO.
       01  WS-RESPONSE           PIC X(100).
       01  WS-WATCHLIST-TBL.
           05  WL-IDX            PIC 9(3) VALUE 1.
           05  WL-ENTRIES OCCURS 100 TIMES.
               10  WL-SSN        PIC X(11).
               10  WL-NAME       PIC X(50).
               10  WL-LIST-TYPE  PIC X(20).

       PROCEDURE DIVISION.

       MAIN-LOGIC.
           DISPLAY "STARTING RISK FLAGGING PROCESS"

           PERFORM LOAD-WATCHLIST

           EXEC SQL
               DECLARE CURSOR_CUST CURSOR FOR
               SELECT CUSTOMER_ID, NAME, SSN
               FROM CUSTOMER_MASTER
           END-EXEC.

           EXEC SQL OPEN CURSOR_CUST END-EXEC.

           PERFORM UNTIL SQLCODE NOT = 0
               EXEC SQL
                   FETCH CURSOR_CUST INTO
                       :HV-CUSTOMER-ID,
                       :HV-NAME,
                       :HV-SSN
               END-EXEC

               IF SQLCODE = 0
                   PERFORM CHECK-WATCHLIST
                   IF HV-RISK-FLAG NOT = SPACES
                       PERFORM UPDATE-RISK-FLAG
                   END-IF
               END-IF
           END-PERFORM.

           EXEC SQL CLOSE CURSOR_CUST END-EXEC.

           DISPLAY "RISK FLAGGING COMPLETE. CUSTOMERS FLAGGED: " WS-FLAGGED-COUNT
           GOBACK.

       LOAD-WATCHLIST.
           DISPLAY "LOADING SIMULATED WATCHLIST ENTRIES"
           MOVE '123-45-6789' TO WL-SSN (1)
           MOVE 'JOHN DOE'    TO WL-NAME (1)
           MOVE 'AML'         TO WL-LIST-TYPE (1)

           MOVE '999-99-9999' TO WL-SSN (2)
           MOVE 'JANE BLACK'  TO WL-NAME (2)
           MOVE 'FATCA'       TO WL-LIST-TYPE (2)

           MOVE 2 TO WL-IDX.

       CHECK-WATCHLIST.
           MOVE SPACES TO HV-RISK-FLAG
           PERFORM VARYING WL-IDX FROM 1 BY 1 UNTIL WL-IDX > 2
               IF HV-SSN = WL-SSN(WL-IDX)
                   MOVE WL-LIST-TYPE(WL-IDX) TO HV-RISK-FLAG
                   MOVE WL-LIST-TYPE(WL-IDX) TO HV-MATCHED-LIST
                   EXIT PERFORM
               END-IF
           END-PERFORM.

       UPDATE-RISK-FLAG.
           EXEC SQL
               UPDATE CUSTOMER_MASTER
               SET RISK_FLAG = :HV-RISK-FLAG
               WHERE CUSTOMER_ID = :HV-CUSTOMER-ID
           END-EXEC.

           IF SQLCODE = 0
               ADD 1 TO WS-FLAGGED-COUNT
               DISPLAY "FLAGGED CUSTOMER: " HV-CUSTOMER-ID
               DISPLAY "MATCHED LIST TYPE: " HV-MATCHED-LIST
           ELSE
               DISPLAY "ERROR FLAGGING CUSTOMER " HV-CUSTOMER-ID
               DISPLAY "SQLCODE: " SQLCODE
           END-IF.
