CREATE TABLE Memo
(id CHAR(36) NOT NULL UNIQUE,
title VARCHAR(100) NOT NULL,
content VARCHAR(400) NOT NULL,
PRIMARY KEY (id));