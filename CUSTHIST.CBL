       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTHIST.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z16.
       OBJECT-COMPUTER. IBM-Z16.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       EXEC SQL INCLUDE SQLCA END-EXEC.

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  HV-CUSTOMER-ID        PIC X(10).
       01  HV-EMPLOYEE-ID        PIC X(08).
       01  HV-INTERACTION-TYPE   PIC X(20).
       01  HV-INTERACTION-NOTES  PIC X(250).
       01  HV-TIMESTAMP          PIC X(26).
       EXEC SQL END DECLARE SECTION END-EXEC.

       01  WS-FUNCTION           PIC X(06).
           88  FUNC-LOG         VALUE 'LOG   '.
           88  FUNC-VIEW        VALUE 'VIEW  '.

       01  WS-RESPONSE           PIC X(100).
       01  WS-FOUND              PIC X VALUE 'N'.

       LINKAGE SECTION.
       01  DFHCOMMAREA.
           05  LK-CUSTOMER-ID        PIC X(10).
           05  LK-EMPLOYEE-ID        PIC X(08).
           05  LK-INTERACTION-TYPE   PIC X(20).
           05  LK-INTERACTION-NOTES  PIC X(250).
           05  LK-FUNCTION           PIC X(06).

       PROCEDURE DIVISION.

       MAIN-LOGIC.
           MOVE LK-CUSTOMER-ID       TO HV-CUSTOMER-ID.
           MOVE LK-EMPLOYEE-ID       TO HV-EMPLOYEE-ID.
           MOVE LK-INTERACTION-TYPE  TO HV-INTERACTION-TYPE.
           MOVE LK-INTERACTION-NOTES TO HV-INTERACTION-NOTES.
           MOVE FUNCTION CURRENT-TIMESTAMP TO HV-TIMESTAMP.
           MOVE LK-FUNCTION          TO WS-FUNCTION.

           EVALUATE TRUE
               WHEN FUNC-LOG
                   PERFORM LOG-INTERACTION
               WHEN FUNC-VIEW
                   PERFORM VIEW-INTERACTIONS
               WHEN OTHER
                   MOVE 'INVALID FUNCTION' TO WS-RESPONSE
                   DISPLAY WS-RESPONSE
           END-EVALUATE.

           GOBACK.

       LOG-INTERACTION.
           EXEC SQL
               INSERT INTO CUSTOMER_INTERACTIONS
                   (CUSTOMER_ID, EMPLOYEE_ID, INTERACTION_TYPE, 
                    INTERACTION_NOTES, INTERACTION_TIMESTAMP)
               VALUES
                   (:HV-CUSTOMER-ID, :HV-EMPLOYEE-ID, :HV-INTERACTION-TYPE,
                    :HV-INTERACTION-NOTES, :HV-TIMESTAMP)
           END-EXEC.

           IF SQLCODE = 0
               MOVE 'INTERACTION LOGGED SUCCESSFULLY' TO WS-RESPONSE
           ELSE
               MOVE 'ERROR LOGGING INTERACTION' TO WS-RESPONSE
               DISPLAY 'SQLCODE:' SQLCODE
           END-IF.
           DISPLAY WS-RESPONSE.

       VIEW-INTERACTIONS.
           EXEC SQL
               DECLARE CURSOR_INT CURSOR FOR
               SELECT EMPLOYEE_ID, INTERACTION_TYPE, INTERACTION_NOTES, INTERACTION_TIMESTAMP
               FROM CUSTOMER_INTERACTIONS
               WHERE CUSTOMER_ID = :HV-CUSTOMER-ID
               ORDER BY INTERACTION_TIMESTAMP DESC
           END-EXEC.

           EXEC SQL OPEN CURSOR_INT END-EXEC.

           PERFORM UNTIL SQLCODE NOT = 0
               EXEC SQL
                   FETCH CURSOR_INT INTO 
                       :HV-EMPLOYEE-ID, 
                       :HV-INTERACTION-TYPE, 
                       :HV-INTERACTION-NOTES, 
                       :HV-TIMESTAMP
               END-EXEC

               IF SQLCODE = 0
                   DISPLAY "-----------------------------"
                   DISPLAY "EMPLOYEE ID     : " HV-EMPLOYEE-ID
                   DISPLAY "TYPE            : " HV-INTERACTION-TYPE
                   DISPLAY "NOTES           : " HV-INTERACTION-NOTES
                   DISPLAY "TIMESTAMP       : " HV-TIMESTAMP
                   DISPLAY "-----------------------------"
               END-IF
           END-PERFORM.

           EXEC SQL CLOSE CURSOR_INT END-EXEC.

           IF SQLCODE = 100
               MOVE 'NO MORE INTERACTIONS FOUND' TO WS-RESPONSE
           ELSE
               MOVE 'ERROR FETCHING INTERACTIONS' TO WS-RESPONSE
               DISPLAY 'SQLCODE:' SQLCODE
           END-IF.

           DISPLAY WS-RESPONSE.
