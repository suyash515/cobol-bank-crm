       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTREL.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z16.
       OBJECT-COMPUTER. IBM-Z16.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       EXEC SQL INCLUDE SQLCA END-EXEC.

       * Declare host variables
       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  HV-PRIMARY-ID           PIC X(10).
       01  HV-RELATED-ID           PIC X(10).
       01  HV-RELATIONSHIP-TYPE    PIC X(20).
       01  HV-CREATED-BY           PIC X(08).
       01  HV-TIMESTAMP            PIC X(26).
       EXEC SQL END DECLARE SECTION END-EXEC.

       01  WS-FUNCTION             PIC X(06).
           88  FUNC-LINK          VALUE 'LINK  '.
           88  FUNC-UNLINK        VALUE 'UNLINK'.
           88  FUNC-VIEW          VALUE 'VIEW  '.

       01  WS-RESPONSE             PIC X(100).
       01  WS-FOUND                PIC X VALUE 'N'.

       LINKAGE SECTION.
       01  DFHCOMMAREA.
           05  LK-PRIMARY-ID          PIC X(10).
           05  LK-RELATED-ID          PIC X(10).
           05  LK-RELATIONSHIP-TYPE   PIC X(20).
           05  LK-FUNCTION            PIC X(06).
           05  LK-EMPLOYEE-ID         PIC X(08).

       PROCEDURE DIVISION.

       MAIN-LOGIC.
           MOVE LK-PRIMARY-ID        TO HV-PRIMARY-ID.
           MOVE LK-RELATED-ID        TO HV-RELATED-ID.
           MOVE LK-RELATIONSHIP-TYPE TO HV-RELATIONSHIP-TYPE.
           MOVE LK-EMPLOYEE-ID       TO HV-CREATED-BY.
           MOVE FUNCTION CURRENT-TIMESTAMP TO HV-TIMESTAMP.
           MOVE LK-FUNCTION          TO WS-FUNCTION.

           EVALUATE TRUE
               WHEN FUNC-LINK
                   PERFORM LINK-RELATIONSHIP
               WHEN FUNC-UNLINK
                   PERFORM UNLINK-RELATIONSHIP
               WHEN FUNC-VIEW
                   PERFORM VIEW-RELATIONSHIP
               WHEN OTHER
                   MOVE 'INVALID FUNCTION SPECIFIED' TO WS-RESPONSE
                   DISPLAY WS-RESPONSE
           END-EVALUATE.

           GOBACK.

       LINK-RELATIONSHIP.
           EXEC SQL
               INSERT INTO CUSTOMER_RELATIONSHIP
                   (PRIMARY_CUSTOMER_ID, RELATED_CUSTOMER_ID, RELATIONSHIP_TYPE,
                    CREATED_BY, CREATED_AT)
               VALUES
                   (:HV-PRIMARY-ID, :HV-RELATED-ID, :HV-RELATIONSHIP-TYPE,
                    :HV-CREATED-BY, :HV-TIMESTAMP)
           END-EXEC.

           IF SQLCODE = 0
               MOVE 'RELATIONSHIP SUCCESSFULLY LINKED' TO WS-RESPONSE
           ELSE
               MOVE 'ERROR LINKING RELATIONSHIP' TO WS-RESPONSE
               DISPLAY 'SQLCODE:' SQLCODE
           END-IF.
           DISPLAY WS-RESPONSE.

       UNLINK-RELATIONSHIP.
           EXEC SQL
               DELETE FROM CUSTOMER_RELATIONSHIP
               WHERE PRIMARY_CUSTOMER_ID = :HV-PRIMARY-ID
                 AND RELATED_CUSTOMER_ID = :HV-RELATED-ID
                 AND RELATIONSHIP_TYPE = :HV-RELATIONSHIP-TYPE
           END-EXEC.

           IF SQLCODE = 0
               MOVE 'RELATIONSHIP UNLINKED' TO WS-RESPONSE
           ELSE
               MOVE 'FAILED TO UNLINK RELATIONSHIP' TO WS-RESPONSE
               DISPLAY 'SQLCODE:' SQLCODE
           END-IF.
           DISPLAY WS-RESPONSE.

       VIEW-RELATIONSHIP.
           EXEC SQL
               SELECT 'X' INTO :WS-FOUND
               FROM CUSTOMER_RELATIONSHIP
               WHERE PRIMARY_CUSTOMER_ID = :HV-PRIMARY-ID
                 AND RELATED_CUSTOMER_ID = :HV-RELATED-ID
                 AND RELATIONSHIP_TYPE = :HV-RELATIONSHIP-TYPE
           END-EXEC.

           IF SQLCODE = 0
               MOVE 'RELATIONSHIP EXISTS' TO WS-RESPONSE
           ELSE
               MOVE 'RELATIONSHIP NOT FOUND' TO WS-RESPONSE
               DISPLAY 'SQLCODE:' SQLCODE
           END-IF.
           DISPLAY WS-RESPONSE.
