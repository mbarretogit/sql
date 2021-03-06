USE LYCEUM
GO

INSERT INTO LY_CURRICULO_CONTRATO
SELECT DISTINCT  S.TURNO,S.CURSO,S.CURRICULO,S.SERIE,'MatriculaPosGrad',NULL,'N' FROM  LY_SERIE S
WHERE 1=1
AND S.CURSO IN(
                SELECT C.CURSO FROM LY_CURSO C
				JOIN LY_CURRICULO C1 ON C1.CURSO = C.CURSO
                WHERE 1=1
                AND C.TIPO='POS-GRADUACAO'
                AND C.ATIVO='S'
                AND NOT EXISTS(SELECT 1 FROM LY_CURRICULO_CONTRATO CC WHERE CC.CURSO=C.CURSO AND CC.CURRICULO = C1.CURRICULO AND CC.TURNO = C1.TURNO )
              )