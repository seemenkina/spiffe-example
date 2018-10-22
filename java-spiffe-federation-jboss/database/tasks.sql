CREATE TABLE tasks (
    id varchar(50),
	title text,
	PRIMARY KEY (id)
);

INSERT INTO tasks (id, title) VALUES  (1, 'Write report'),   (2, 'Run  tests'), (3, 'Configure Tomcat'), (4, 'Create Docker images');
