select U.USUARIO, NOME, SETOR, PADACES FROM HD_USUARIO U
JOIN HD_PADUSUARIO PU ON PU.USUARIO = U.USUARIO
WHERE PADACES = 'SEC_GERAL'