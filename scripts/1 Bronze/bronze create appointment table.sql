CREATE TABLE bronze.appointments (
   SUB_ICB_LOCATION_CODE        varchar(255) NULL,
    SUB_ICB_LOCATION_ONS_CODE    varchar(255) NULL,
    SUB_ICB_LOCATION_NAME        varchar(255) NULL,
    ICB_ONS_CODE                 varchar(255) NULL,
    REGION_ONS_CODE              varchar(255) NULL,
    Appointment_Date             varchar(255) NULL,
    APPT_STATUS                  varchar(255) NULL,
    HCP_TYPE                     varchar(255) NULL,
    APPT_MODE                    varchar(255) NULL,
    TIME_BETWEEN_BOOK_AND_APPT   varchar(255) NULL,
    COUNT_OF_APPOINTMENTS        int          NULL
);



select * from bronze.appointments
