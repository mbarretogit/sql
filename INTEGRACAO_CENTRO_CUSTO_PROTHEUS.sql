use [lyceum]
go

set ansi_nulls on
go

set quoted_identifier on
go


ALTER procedure [dbo].[INTEGRACAO_CENTRO_CUSTO_PROTHEUS]
as
begin
   -- declarar variaveis que serão usadas no cursor
   declare @vc_codcentrocusto          varchar(13),
           @vc_centrocusto             varchar(40)
   
   -- declaração das demais variaveis
   declare @v_codcentrocusto           varchar(13),
           @v_centrocusto              varchar(40),
		   @v_quantidade               int
                          
   select sp.codcentrocusto,
          sp.centrocusto
   into #t1
   from openquery(PRODUCAO, 'select t.ctt_custo  codcentrocusto,
                                    t.ctt_desc01 centrocusto
                             from siga.ctt040 t
                             where 1 = 1
                               and t.d_e_l_e_t_ <> ''*''
                               and substr(t.ctt_filial,1,1) = '' ''
                               and substr(t.ctt_dtexsf,1,1) = '' ''
                               and t.ctt_classe = ''2''
                               and t.ctt_ead = ''1''
                             union
                             select t.ctt_custo  codcentrocusto,
                                    t.ctt_desc01 centrocusto
                             from siga.ctt260 t
                             where 1 = 1
                               and t.d_e_l_e_t_ <> ''*''
                               and substr(t.ctt_filial,1,1) = '' ''
                               and substr(t.ctt_dtexsf,1,1) = '' ''
                               and t.ctt_classe = ''2''
                               and t.ctt_ead = ''1''
                            order by codcentrocusto') sp

   select @v_quantidade = count(1)
   from #t1
                          
   declare cursor_cc cursor static read_only for    
   select t.codcentrocusto,
          t.centrocusto
   from #t1 t
      
   open cursor_cc
   fetch next from cursor_cc into @vc_codcentrocusto, @vc_centrocusto
   
   begin transaction
   
   begin try
   
      while @@fetch_status = 0
      begin
      
         set @v_codcentrocusto = null
         set @v_centrocusto    = null

         -- Obter do lyceum o centro de custo e a descrição do centro de custo
         select @v_codcentrocusto = h.item,
                @v_centrocusto    = h.descr
         from hades..hd_tabelaitem h
         where h.tabela = 'CentroCusto'
           and rtrim(h.item) = rtrim(@vc_codcentrocusto)
         
         if @v_codcentrocusto is null begin

            -- Se o centro de custo não existe no Lyceum
            insert into hades..hd_tabelaitem (tabela, item, descr) values ('CentroCusto', @vc_codcentrocusto, @vc_centrocusto)
            
         end else begin
         
            -- Se o centro de custo existe no Lyceum, mas a descrição não é igual a do Protheus 
            if rtrim(@v_centrocusto) <> rtrim(@vc_centrocusto)
               update h set h.descr = @vc_centrocusto
               from hades..hd_tabelaitem h
               where h.tabela = 'CentroCusto'
                 and rtrim(h.item) = rtrim(@vc_codcentrocusto)

         end
         
         fetch next from cursor_cc into @vc_codcentrocusto, @vc_centrocusto
      end

   end try
       
   begin catch
      rollback transaction
   end catch 

   commit transaction

   close cursor_cc
   deallocate cursor_cc
end
go


