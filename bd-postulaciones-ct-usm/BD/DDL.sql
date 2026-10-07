CREATE DATABASE ct_usm_postulaciones;
USE ct_usm_postulaciones;
CREATE TABLE region (
    id_region INT AUTO_INCREMENT PRIMARY KEY,
    nombre_region VARCHAR(40) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE estado_postulacion (
    id_estado_postulacion INT AUTO_INCREMENT PRIMARY KEY,
    nombre_estado_postulacion VARCHAR(11) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE tipo_iniciativa (
    id_tipo_iniciativa INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo_iniciativa VARCHAR(9) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE sede (
    id_sede INT AUTO_INCREMENT PRIMARY KEY,
    nombre_sede VARCHAR(30) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE tamanio_empresa (
    id_tamanio INT AUTO_INCREMENT PRIMARY KEY,
    tamanio VARCHAR(12) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE tipo_persona (
    id_tipo_persona INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo_persona VARCHAR(10) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE convenio_usm (
    id_convenio_usm INT AUTO_INCREMENT PRIMARY KEY,
    convenio_usm VARCHAR(2) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE etapa (
    cod_etapa INT AUTO_INCREMENT PRIMARY KEY,
    nombre_etapa VARCHAR(255) NOT NULL,
    plazo INT NOT NULL,
    entregable VARCHAR(255) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE empresa (
    rut_empresa VARCHAR(12) PRIMARY KEY,
    id_tamanio INT,
    nombre_empresa VARCHAR(150) NOT NULL,
    nombre_representante VARCHAR(150) NOT NULL,
    telefono_representante INT NOT NULL,
    id_convenio_usm INT,
    FOREIGN KEY (id_tamanio) REFERENCES tamanio_empresa(id_tamanio) ON DELETE CASCADE,
    FOREIGN KEY (id_convenio_usm) REFERENCES convenio_usm(id_convenio_usm) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE integrante (
    rut_integrante VARCHAR(12) PRIMARY KEY,
    nombre_integrante VARCHAR(60) NOT NULL,
    depto_integrante VARCHAR(40) NOT NULL,
    email_integrante VARCHAR(40) NOT NULL,
    telefono_integrante INT NOT NULL,
    id_sede INT,
    id_tipo_persona INT,
    FOREIGN KEY (id_sede) REFERENCES sede(id_sede) ON DELETE CASCADE,
    FOREIGN KEY (id_tipo_persona) REFERENCES tipo_persona(id_tipo_persona) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE postulacion (
    codigo_postulacion INT PRIMARY KEY,
    fecha_postulacion DATE NOT NULL,
    responsable_1 VARCHAR(50) NOT NULL,
    responsable_2 VARCHAR(50),
    numero_postulacion INT NOT NULL UNIQUE,
    presupuesto INT NOT NULL,
    id_sede INT,
    id_region_ejecucion INT,
    id_region_impacto INT,
    rut_empresa VARCHAR(12),
    id_estado_postulacion INT,
    FOREIGN KEY (id_sede) REFERENCES sede(id_sede) ON DELETE CASCADE,
    FOREIGN KEY (id_region_ejecucion) REFERENCES region(id_region) ON DELETE CASCADE,
    FOREIGN KEY (id_region_impacto) REFERENCES region(id_region) ON DELETE CASCADE,
    FOREIGN KEY (rut_empresa) REFERENCES empresa(rut_empresa) ON DELETE CASCADE,
    FOREIGN KEY (id_estado_postulacion) REFERENCES estado_postulacion(id_estado_postulacion) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE cronograma (
    codigo_postulacion INT,
    cod_etapa INT,
    PRIMARY KEY (codigo_postulacion, cod_etapa),
    FOREIGN KEY (codigo_postulacion) REFERENCES postulacion(codigo_postulacion) ON DELETE CASCADE,
    FOREIGN KEY (cod_etapa) REFERENCES etapa(cod_etapa) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE iniciativa (
    cod_iniciativa INT AUTO_INCREMENT PRIMARY KEY,
    nombre_iniciativa VARCHAR(40) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    solucion VARCHAR(255) NOT NULL,
    resultados_esperados VARCHAR(255) NOT NULL,
    documentos VARCHAR(255) NOT NULL,
    codigo_postulacion INT,
    id_tipo_iniciativa INT,
    FOREIGN KEY (codigo_postulacion) REFERENCES postulacion(codigo_postulacion) ON DELETE CASCADE,
    FOREIGN KEY (id_tipo_iniciativa) REFERENCES tipo_iniciativa(id_tipo_iniciativa) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE equipo (
    codigo_postulacion INT,
    rut_integrante VARCHAR(12),
    rol_integrante VARCHAR(30) NOT NULL,
    PRIMARY KEY (codigo_postulacion, rut_integrante),
    FOREIGN KEY (rut_integrante) REFERENCES integrante(rut_integrante) ON DELETE CASCADE,
    FOREIGN KEY (codigo_postulacion) REFERENCES postulacion(codigo_postulacion) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(13) NOT NULL UNIQUE
) ENGINE = InnoDB;

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    id_rol INT NOT NULL,
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol) ON DELETE CASCADE
) ENGINE=InnoDB;


-- Vista que junta la información general para gestionar la postulación
CREATE VIEW vw_postulacion_gestion AS
SELECT
    postulacion.codigo_postulacion,
    postulacion.presupuesto,
    postulacion.fecha_postulacion,
    re.nombre_region AS nombre_region_ejecucion,
    ri.nombre_region AS nombre_region_impacto,
    tipo_iniciativa.nombre_tipo_iniciativa,
    sede.nombre_sede,
    empresa.id_convenio_usm,
    convenio_usm.convenio_usm,
    empresa.nombre_empresa,
    empresa.rut_empresa,
    iniciativa.nombre_iniciativa,
    tamanio_empresa.tamanio,
    estado_postulacion.nombre_estado_postulacion


FROM postulacion
JOIN iniciativa ON postulacion.codigo_postulacion = iniciativa.codigo_postulacion
JOIN empresa ON postulacion.rut_empresa = empresa.rut_empresa
JOIN tipo_iniciativa ON iniciativa.id_tipo_iniciativa = tipo_iniciativa.id_tipo_iniciativa
JOIN sede ON postulacion.id_sede = sede.id_sede
JOIN region re ON postulacion.id_region_ejecucion = re.id_region
JOIN region ri ON postulacion.id_region_impacto = ri.id_region
JOIN convenio_usm ON empresa.id_convenio_usm = convenio_usm.id_convenio_usm
JOIN tamanio_empresa ON empresa.id_tamanio = tamanio_empresa.id_tamanio
JOIN estado_postulacion ON postulacion.id_estado_postulacion = estado_postulacion.id_estado_postulacion;

-- Vista que junta la información general para gestionar el equipo de trabajo
CREATE VIEW vw_equipo_gestion AS
SELECT
    equipo.codigo_postulacion,
    equipo.rol_integrante,
    integrante.nombre_integrante,
    integrante.id_tipo_persona,
    integrante.id_sede

FROM equipo
JOIN integrante ON equipo.rut_integrante = integrante.rut_integrante;