-- 新增字段
ALTER TABLE `swagger_url_project` ADD COLUMN `config` longtext COMMENT '鉴权配置信息' AFTER `mode_id`;

-- 第三方平台模板
ALTER TABLE project ADD platform varchar(20) DEFAULT 'Local' NOT NULL COMMENT '项目使用哪个平台的模板';
ALTER TABLE project ADD third_part_template tinyint(1) DEFAULT 0 NULL COMMENT '是否使用第三方平台缺陷模板';

-- 处理历史数据
UPDATE issue_template SET platform = 'Local' WHERE platform = 'metersphere';
UPDATE project p JOIN issue_template it on p.issue_template_id = it.id SET p.platform = it.platform;
UPDATE custom_field SET `type` = 'date' WHERE `type` = 'data';


-- version
CREATE TABLE IF NOT EXISTS `project_version`
(
    `id`           varchar(50) NOT NULL,
    `project_id`   varchar(50)  DEFAULT NULL,
    `name`         varchar(100) DEFAULT NULL,
    `description`  varchar(200) DEFAULT NULL,
    `status`       varchar(20)  DEFAULT NULL,
    `latest`       tinyint(1)   DEFAULT NULL,
    `publish_time` bigint(13)   DEFAULT NULL,
    `start_time`   bigint(13)   DEFAULT NULL,
    `end_time`     bigint(13)   DEFAULT NULL,
    `create_time`  bigint(13)   DEFAULT NULL,
    `create_user`  varchar(100) DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

INSERT INTO project_version (id, name, description, status, latest, publish_time, start_time, end_time, create_time,
                             create_user, project_id)
SELECT UUID(),
       'v1.0.0',
       '系统默认版本',
       'open',
       TRUE,
       UNIX_TIMESTAMP() * 1000,
       UNIX_TIMESTAMP() * 1000,
       UNIX_TIMESTAMP() * 1000,
       UNIX_TIMESTAMP() * 1000,
       'admin',
       id
FROM project;

-- enable version manage
INSERT INTO system_parameter (param_key, param_value, type, sort)
VALUES ('project.version.enable', 'true', 'text', 2);

-- api definition
ALTER TABLE api_definition
    ADD version_id VARCHAR(50) NULL;

ALTER TABLE api_definition
    ADD ref_id VARCHAR(50) NULL;


CREATE INDEX api_definition_ref_id_index
    ON api_definition (ref_id);

CREATE INDEX api_definition_version_id_index
    ON api_definition (version_id);

UPDATE api_definition
SET ref_id = id;

UPDATE api_definition
    INNER JOIN project_version ON project_version.project_id = api_definition.project_id
SET version_id = project_version.id;

-- api test case
ALTER TABLE api_test_case
    ADD version_id VARCHAR(50) NULL;

CREATE INDEX api_test_case_version_id_index
    ON api_test_case (version_id);

UPDATE api_test_case
    INNER JOIN project_version ON project_version.project_id = api_test_case.project_id
SET version_id = project_version.id;

 -- load_test
ALTER TABLE load_test
    ADD version_id VARCHAR(50) NULL;

ALTER TABLE load_test
    ADD ref_id VARCHAR(50) NULL;

CREATE INDEX load_test_ref_id_index
    ON load_test(ref_id);

CREATE INDEX load_test_version_id_index
    ON load_test(version_id);

UPDATE load_test
SET ref_id = id;

UPDATE load_test
    INNER JOIN project_version ON project_version.project_id = load_test.project_id
SET version_id = project_version.id;

-- api scenario
ALTER TABLE api_scenario
    ADD version_id VARCHAR(50) NULL;

ALTER TABLE api_scenario
    ADD ref_id VARCHAR(50) NULL;


CREATE INDEX api_scenario_ref_id_index
    ON api_scenario (ref_id);

CREATE INDEX api_scenario_version_id_index
    ON api_scenario (version_id);

UPDATE api_scenario
SET ref_id = id;

UPDATE api_scenario
    INNER JOIN project_version ON project_version.project_id = api_scenario.project_id
SET version_id = project_version.id;

