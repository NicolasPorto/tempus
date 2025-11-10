CREATE DATABASE tempus;

CREATE TABLE SessionFocus(
    UUID CHAR(36) PRIMARY KEY,
    StartDtTime DATETIME NOT NULL,
    FinishDtTime DATETIME NULL,
    SupposedFinish DATETIME NOT NULL,
    StudyingMinutes int NOT NULL,
    BreakMinutes int NULL,
    DistractedMinutes int NULL
);