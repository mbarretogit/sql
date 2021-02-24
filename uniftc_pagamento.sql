USE [master]
GO
CREATE LOGIN [uniftc_pagamento]  WITH PASSWORD=N'!)d!DH2hd@Ds_', DEFAULT_DATABASE=[UNIFTC_ONE], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO

USE [UNIFTC_ONE]
GO
CREATE USER [uniftc_pagamento] FOR LOGIN [uniftc_pagamento]
GO
use [LYCEUMINTEGRACAO]
GO
CREATE USER [uniftc_pagamento] FOR LOGIN [uniftc_pagamento]
GO

USE [UNIFTC_ONE]
GO

GRANT ALL ON UNIFTC_ONE.DBO.PAGAMENTO_COBRANCA TO [uniftc_pagamento]
GRANT ALL ON UNIFTC_ONE.DBO.PAGAMENTO_CONFIG TO [uniftc_pagamento]
GRANT ALL ON UNIFTC_ONE.DBO.PAGAMENTO_LINK TO [uniftc_pagamento]
GRANT ALL ON UNIFTC_ONE.DBO.PAGAMENTO_OPERADORA TO [uniftc_pagamento]
GRANT ALL ON UNIFTC_ONE.DBO.PAGAMENTO TO [uniftc_pagamento]
GRANT ALL ON UNIFTC_ONE.DBO.PAGAMENTO_TRANSACAO TO [uniftc_pagamento]

USE [LYCEUMINTEGRACAO]
GO

GRANT EXECUTE ON LYCEUMINTEGRACAO.dbo.FTC_SP_LISTA_TRANSACOES_SEM_CANCELAMENTO TO [uniftc_pagamento]