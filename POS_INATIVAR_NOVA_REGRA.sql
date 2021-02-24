USE LYCEUM
GO 

SELECT DISTINCT A.ALUNO
FROM LY_ALUNO A
JOIN LY_CURSO C ON C.CURSO = A.CURSO
WHERE A.SIT_ALUNO = 'Ativo'
--AND NOT EXISTS (SELECT TOP 1 1 FROM VW_MATRICULA_E_PRE_MATRICULA WHERE ALUNO = A.ALUNO AND ANO = 2017)
--AND NOT EXISTS (SELECT TOP 1 1 FROM LY_ITEM_CRED WHERE COBRANCA = CO.COBRANCA AND TIPODESCONTO IS NULL AND TIPO_ENCARGO IS NULL AND DATA > '2017-01-01')
AND NOT EXISTS(SELECT TOP 1 1 FROM LY_COBRANCA WHERE DATA_DE_VENCIMENTO >= '2017-09-01' AND ALUNO = A.ALUNO)
AND A.ALUNO IN('051290779',
'142290579',
'142290326',
'142290653',
'142290281',
'142290655',
'142290619',
'142290280',
'142290635',
'142290286',
'142290617',
'142290676',
'142290672',
'142290647',
'061290752',
'071290906',
'142290585',
'142290658',
'111290497',
'142290597',
'091290327',
'152290216',
'170290298',
'170290211',
'170290216',
'170290219',
'170290228',
'170290222',
'170290316',
'170290226',
'170290225',
'142290284',
'152290267',
'142290589',
'152290223',
'041291574',
'142290643',
'152290299',
'142290661',
'142290636',
'142290596',
'142290582',
'142290618',
'142290678',
'062290135',
'111290268',
'071290735',
'142290675',
'142290625',
'142290588',
'152290310',
'142290583',
'101290383',
'062290366',
'111290269',
'051291247',
'161290763',
'152290003',
'152290240',
'161290778',
'152290238',
'161290811',
'121290172',
'152290251',
'142290651',
'161290799',
'052290082',
'170290186',
'170290036',
'170290032',
'170290239',
'170290236',
'170290254',
'170290001',
'142290601',
'142290634',
'052290429',
'142290640',
'081290759',
'142290644',
'061290753',
'152290256',
'152290257',
'152290258',
'121290060',
'142290236',
'142290603',
'142290272',
'142290416',
'142290608',
'142290241',
'142290250',
'142290262',
'142290226',
'151290443',
'111290097',
'152290191',
'151290420',
'152290288',
'151290180',
'142290255',
'152290131',
'151290456',
'151290343',
'092290117',
'142290227',
'142290633',
'082290483',
'101290159',
'152290112',
'152290225',
'170290313',
'170290300',
'170290105',
'151290187',
'170290277',
'152290202',
'151290425',
'151290372',
'051290256',
'152290135',
'151290367',
'092290290',
'151290427',
'152290118',
'151290251',
'152290205',
'152290292',
'042291008',
'142290610',
'142290264',
'141290438',
'151290445',
'151290418',
'151290203',
'152290132',
'161290837',
'161290258',
'161290477',
'161290014',
'161290625',
'161290482',
'161290598',
'161290399',
'161290206',
'152290108',
'161290205',
'161290688',
'111290200',
'161290430',
'152290287',
'102290320',
'101290698',
'161290714',
'161290592',
'102290382',
'161290730',
'161290298',
'161290733',
'161290708',
'161290204',
'161290611',
'041290440',
'151290437',
'142290263',
'121290177',
'142290247',
'142290223',
'152290120',
'111290220',
'142290580',
'142290594',
'041290005',
'142290650',
'142290235',
'151290272',
'161290695',
'152290139',
'081290754',
'071290529',
'142290570',
'142290221',
'151290186',
'152290162',
'152290325',
'152290232',
'151290452',
'022290005',
'101290318',
'151290252',
'151290304',
'152290137',
'041290259',
'152290165',
'111290201',
'142290211',
'152290228',
'142290234',
'142290193',
'072290334',
'142290204',
'142290230',
'142290218',
'142290224',
'142290216',
'142290249',
'142290188',
'051291195',
'142290220',
'152290209',
'161290824',
'111290208',
'161290616',
'161290786',
'161290597',
'161290350',
'072290273',
'161290844',
'161290742',
'111290215',
'170290174',
'170290166',
'170290116',
'170290039',
'170290122',
'170290019',
'170290154',
'170290003',
'170290220',
'170290218',
'170290202',
'170290201',
'170290213',
'170290278',
'170290251',
'170290230',
'170290209',
'170290204',
'170290208',
'170290261',
'170290206',
'051290272',
'142290489',
'081290527',
'081290736',
'142290654',
'142290680',
'142290550',
'142290684',
'142290677',
'142290660',
'142290523',
'152290245',
'152290259',
'142290612',
'142290563',
'170290304',
'170290321',
'170290137',
'170290305',
'170290306',
'170290280',
'170290038',
'170290348',
'152290316',
'142290668',
'161290839',
'161290690',
'161290015',
'161290762',
'161290816',
'152290244',
'142290564',
'142290679',
'092290189',
'142290662',
'142290595',
'142290642',
'031290028',
'101290603',
'142290645',
'142290664',
'142290622',
'142290667',
'102290324',
'161290674',
'112290269',
'161290772',
'170290232',
'142290630',
'142290663',
'142290616',
'081290253',
'132290263',
'142290628',
'142290669',
'142290002',
'142290665',
'131290232',
'061290754',
'142290590',
'142290639',
'142290620',
'152290231',
'142290656',
'142290632',
'152290226',
'111290494',
'142290571',
'142290629',
'142290670',
'142290613',
'142290631',
'142290615',
'142290611',
'142290683',
'102290470',
'142290584',
'142290626',
'142290641',
'142290614',
'142290673',
'051291248',
'142290592',
'142290587',
'142290591',
'151290370',
'151290436',
'151290200',
'142290657',
'170290333',
'170290340',
'170290336',
'170290224',
'151290157',
'011290007',
'151290457',
'151290419',
'151290183',
'151290430',
'101290284',
'151290458',
'170290217',
'151290345',
'151290162',
'151290440',
'111290533',
'101290797',
'151290433',
'091290264',
'151290164',
'091290014',
'082290423',
'051290054',
'151290159',
'091290132',
'170290100',
'151290434',
'151290350',
'151290380',
'151290181',
'151290365',
'151290340',
'151290182',
'051291135',
'111290455',
'170290242',
'170290190',
'170290130',
'151290441',
'081290231',
'151290386',
'152290156',
'152290078',
'152290145',
'082290447',
'152290002',
'152290229',
'052290303',
'152290036',
'161290760',
'042290411',
'041290618',
'161290575',
'161290540',
'161290581',
'161290556',
'161290704',
'161290539',
'161290795',
'111290749',
'152290168',
'152290042',
'161290782',
'151290199',
'091290091',
'161290537',
'121290160',
'142290646',
'131290231',
'161290639',
'161290815',
'161290544',
'152290081',
'152290149',
'081290257',
'151290264',
'052290067',
'151290249',
'092290187',
'152290050',
'012290003',
'092290172',
'170290274',
'170290303',
'170290360',
'170290357',
'170290339',
'170290353',
'170290302',
'170290362',
'061290751',
'152290051',
'151290438',
'152290314',
'152290099',
'151290155',
'151290174',
'061290684',
'161290583',
'161290838',
'161290650',
'161290486',
'161290016',
'102290328',
'102290327',
'031290004',
'161290524',
'082290309',
'032290008',
'152290151',
'152290079',
'152290266',
'151290188',
'092290003',
'170290121',
'170290314',
'170290037',
'152290224',
'152290313',
'152290243',
'152290317',
'091290207',
'111290546',
'152290301',
'022290004',
'152290270',
'152290227',
'152290305',
'101290203',
'152290302',
'101290195',
'051291134',
'161290522',
'101290388',
'102290200',
'161290476',
'122290036',
'161290303',
'101290514',
'071290574',
'161290357',
'102290380',
'152290319',
'072290271',
'170290256',
'170290195',
'170290096',
'170290062',
'170290033',
'170290133',
'170290245',
'170290259',
'161290416',
'161290351',
'161290617',
'092290359',
'170290260',
'170290142',
'170290151',
'170290342',
'092290221',
'111290214',
'091290311',
'161290706',
'161290582',
'170290317',
'161290532',
'161290514',
'161290317',
'161290561',
'170290270',
'170290161',
'170290158',
'170290103',
'170290355',
'170290063',
'170290177',
'072290309',
'121290251',
'161290657',
'161290560',
'170290319',
'161290847',
'161290710',
'161290753',
'101290227',
'161290679',
'161290804',
'161290801',
'142030876',
'142030871',
'102030378',
'092030100',
'132030491',
'142030915',
'142030834',
'142030436',
'142030847',
'142030229',
'102030095',
'142030863',
'142030896',
'142030886',
'142030909',
'041030241',
'021030681',
'142030835',
'121030386',
'142030870',
'142030914',
'142030913',
'142030860',
'142030891',
'092030202',
'142030924',
'142030927',
'101030591',
'091030556',
'091030284',
'061030081',
'142030934',
'031030424',
'142030892',
'142030888',
'142030867',
'142030910',
'012030154',
'142030873',
'092030214',
'142030842',
'142030833',
'142030874',
'142030849',
'142030911',
'101030666',
'142030889',
'142030912',
'091030278',
'151030527',
'142030836',
'131030497',
'101030686',
'151030605',
'012030497',
'152030510',
'151030773',
'101030505',
'031030092',
'151030601',
'152030432',
'152030322',
'152030370',
'152030423',
'152030413',
'152030355',
'152030335',
'012030350',
'142030932',
'142030933',
'152030396',
'142030844',
'152030441',
'151030531',
'152030459',
'152030415',
'052030061',
'101030187',
'152030492',
'102030609',
'170030289',
'170030260',
'170030313',
'170030314',
'170030286',
'170030328',
'170030432',
'170030287',
'170030237',
'170030341',
'170030373',
'170030331',
'170030330',
'170030204',
'170030423',
'170030279',
'170030394',
'170030022',
'170030332',
'170030429',
'170030016',
'170030379',
'170030152',
'170030214',
'170030117',
'170030155',
'170030061',
'170030418',
'170030377',
'170030361',
'170030296',
'170030175',
'170030150',
'170030316',
'170030357',
'170030310',
'170030086',
'170030342',
'170030297',
'170030318',
'170030321',
'170030360',
'170030422',
'170030392',
'170030149',
'170030255',
'170030329',
'170030199',
'170030326',
'170030185',
'170030277',
'170030402',
'170030325',
'170030343',
'170030312',
'170030317',
'170030244',
'170030115',
'170030225',
'170030231',
'170030424',
'170030427',
'170030387',
'031030770',
'041030341',
'101030382',
'142030930',
'152030469',
'152030495',
'101030160',
'152030400',
'152030426',
'081030573',
'142030868',
'152030511',
'111030571',
'152030515',
'152030387',
'151030457',
'152030482',
'152030358',
'152030473',
'071030098',
'152030345',
'121030118',
'112030180',
'012030078',
'081030089',
'111030606',
'152030468',
'101030242',
'111030207',
'152030409',
'121030441',
'152030350',
'071030352',
'112030513',
'152030513',
'152030359',
'082030443',
'152030530',
'071030396',
'152030464',
'152030007',
'111030291',
'152030392',
'152030476',
'152030460',
'051030886',
'152030324',
'142030866',
'152030512',
'152030507',
'152030425',
'152030444',
'161030879',
'161030134',
'161031038',
'161030802',
'161030725',
'161030975',
'161030699',
'161030973',
'161030903',
'161030842',
'161030852',
'161030939',
'161030846',
'161031065',
'161031028',
'161030634',
'161031082',
'161030992',
'161031004',
'161030957',
'161030965',
'161030893',
'161031072',
'161031074',
'161030904',
'161030201',
'161030726',
'161030976',
'161030899',
'161030877',
'161030759',
'161030504',
'161030933',
'161030793',
'161030929',
'161030930',
'170030338',
'161030192',
'161030017',
'121030132',
'161030686',
'161031041',
'161030685',
'161030480',
'161030705',
'161030236',
'170030376',
'091030265',
'161030715',
'161030993',
'051030838',
'031030235',
'161030710',
'082030139',
'161031058',
'161030787',
'161030905',
'161030774',
'161031054',
'161030997',
'161030927',
'051030226',
'042030131',
'161030900',
'121030483',
'161030558',
'152030450',
'161030855',
'062030218',
'161031034',
'161030857',
'161030874',
'161030827',
'102030404',
'121030481',
'161030206',
'161030212',
'161030766',
'161030949',
'161030769',
'152030341',
'111030090',
'161031019',
'101030786',
'161030741',
'161030700',
'161030844',
'152030399',
'161030952',
'161030198',
'161030890',
'161030983',
'161030801',
'161030706',
'161030811',
'161030941',
'111030772',
'052030219',
'091030235',
'161030194',
'161030297',
'032030338',
'111030161',
'102030184',
'161031048',
'011030002',
'071030116',
'052030238',
'152030498',
'101030094',
'161030901',
'161030708',
'161030464',
'111030378',
'161030940',
'161030800',
'161031029',
'072030095',
'161031000',
'161030944',
'161030268',
'161030147',
'161030942',
'032030042',
'161030891',
'161030935',
'052030387',
'102030508',
'161030885',
'161030221',
'161031006',
'161030484',
'161031010',
'161030836',
'101030414',
'152030353',
'161031061',
'161030924',
'161030772',
'022030381',
'161030829',
'161030991',
'161030621',
'161031063',
'111030155',
'161031011',
'161031067',
'131030541',
'021030629',
'161031022',
'161030889',
'161030796',
'161030881',
'170030049',
'051030193',
'032030216',
'051030623',
'012030489',
'081030739',
'170030156',
'081030742',
'081030741',
'170030172',
'161031078',
'170030145',
'022030420',
'081030734',
'081030733',
'081030717',
'081030738',
'081030721',
'031030495',
'081030730',
'081030740',
'042030527',
'170030229',
'081030728',
'081030727',
'041030492',
'081030716',
'021030125',
'081030725',
'021030272',
'081030720',
'012030404',
'032030516',
'081030737',
'031030139',
'051030129',
'081030710',
'081030711',
'012030165',
'170030250',
'170030311',
'041030380',
'041030557',
'042030479',
'042030290',
'170030012',
'081030715',
'081030723',
'081030736',
'012030392',
'051030236',
'042030415',
'170030050',
'022030370',
'041030385',
'081030746',
'081030714',
'042030464',
'081030735',
'081030745',
'021030444',
'061030689',
'081030747',
'081030744',
'081030732',
'031030101',
'170030319',
'081030731',
'021030115',
'021030114',
'081030719',
'081030718',
'081030729',
'170030252',
'032030220',
'052030490',
'042030400',
'081030726',
'031030444',
'051030610',
'170030085',
'081030712',
'081030713',
'032030524',
'081030743',
'021030262',
'081030724',
'031030291',
'170030052',
'170030114',
'170030040',
'170030141',
'170030116',
'170030245',
'170030026',
'170030083',
'170030095',
'170030305',
'170030033',
'101070066',
'101070478',
'142070735',
'111070320',
'051070521',
'092070376',
'072070297',
'142070760',
'101070803',
'142070756',
'102070833',
'072070188',
'142070746',
'081070013',
'101070490',
'132070062',
'102070293',
'101070350',
'101070349',
'151070586',
'101070688',
'092070236',
'092070238',
'151070572',
'151070597',
'151070601',
'151070621',
'152070225',
'051070977',
'151070592',
'101070534',
'131070575',
'151070603',
'151070612',
'151070580',
'151070616',
'102070546',
'151070578',
'012070535',
'151070619',
'042070028',
'170070219',
'170070135',
'170070185',
'170070112',
'170070222',
'170070201',
'170070186',
'170070218',
'170070085',
'170070157',
'170070215',
'170070197',
'170070145',
'170070210',
'170070216',
'102070109',
'102070591',
'101070393',
'022070109',
'092070349',
'142070749',
'091070422',
'101070072',
'151070579',
'151070634',
'152070247',
'071070588',
'142070758',
'142070757',
'082070494',
'051070050',
'102070307',
'151070596',
'081070356',
'152070241',
'152070242',
'052070125',
'142070752',
'052070229',
'151070620',
'081070638',
'151070577',
'052070028',
'142070736',
'151070602',
'151070627',
'101070352',
'091070526',
'041070745',
'082070309',
'052070719',
'142070744',
'082070014',
'061070570',
'012070108',
'151070618',
'062070262',
'151070566',
'111070807',
'142070747',
'082070339',
'151070622',
'012070040',
'012070411',
'061070458',
'051070174',
'091070393',
'111070293',
'052070357',
'081070203',
'152070246',
'102070306',
'101070376',
'111070116',
'151070598',
'101070777',
'102070632',
'142070739',
'142070738',
'142070759',
'152070259',
'082070257',
'102070325',
'101070579',
'101070122',
'142070745',
'151070574',
'052070635',
'102070753',
'061070045',
'101070257',
'152070240',
'012070441',
'061070627',
'151070570',
'152070238',
'081070601',
'071070499',
'082070177',
'101070355',
'142070006',
'142070005',
'082070183',
'152070253',
'161070614',
'161070679',
'161070636',
'161070678',
'152070254',
'161070008',
'161070632',
'161070626',
'111070233',
'071070284',
'161070673',
'170070174',
'151070564',
'170070103',
'082070568',
'082070134',
'092070524',
'111070557',
'161070643',
'101070314',
'111070553',
'092070186',
'151070589',
'152070261',
'101070588',
'142070733',
'161070682',
'081070159',
'032070119',
'170070071',
'081070675',
'161070728',
'112070405',
'091070522',
'111070580',
'071070304',
'170070074',
'101070367',
'101070114',
'081070674',
'161070725',
'161070734',
'061070630',
'161070737',
'161070739',
'142070606',
'142070607',
'042070363',
'091070755',
'021070637',
'041071251',
'031070706',
'021070199',
'091070822',
'042070418',
'061070240',
'031071562',
'051070507',
'051070621',
'081070662',
'041070344',
'091070802',
'051070988',
'081070673',
'051070951',
'031071291',
'051070959',
'091070846',
'081070672',
'091070794',
'051070948',
'032070627',
'051070971',
'170070170',
'031071175',
'012070208',
'091070815',
'041070676',
'021070641',
'091070839',
'081070696',
'081070669',
'081070668',
'041070742',
'032070170',
'031070906',
'061070148',
'041070497',
'081070686',
'021070122',
'052070093',
'061070828',
'031070691',
'091070801',
'041070735',
'041071259',
'081070685',
'042070475',
'032070730',
'091070841',
'031071338',
'041071232',
'041071268',
'081070684',
'041071258',
'091070809',
'031071137',
'091070845',
'091070805',
'091070819',
'031071128',
'031070774',
'041071216',
'091070837',
'081070679',
'091070820',
'032070031',
'091070865',
'031071099',
'081070678',
'032070618',
'031071284',
'091070823',
'081070676',
'031071037',
'051070730',
'031071651',
'091070784',
'051070987',
'091070773',
'091070826',
'031071552',
'081070671',
'041071269',
'052070462',
'091070002',
'041071206',
'081070670',
'091070747',
'022070278',
'091070758',
'091070769',
'022070110',
'041071264',
'041071223',
'091070825',
'091070834',
'032070636',
'041071214',
'091070832',
'091070745',
'031070880',
'041070447',
'041070165',
'042070347',
'091070842',
'041070640',
'041071041',
'021070134',
'091070778',
'091070811',
'091070807',
'091070766',
'051070532',
'051070369',
'091070756',
'091070813',
'041071247',
'031071321',
'081070692',
'071070464',
'081070694',
'081070693',
'091070806',
'091070776',
'091070795',
'041071058',
'081070691',
'041070337',
'081070690',
'091070828',
'081070689',
'091070829',
'091070767',
'091070869',
'081070688',
'041071267',
'032070435',
'091070757',
'091070824',
'091070777',
'041070172',
'170070169',
'041071208',
'041071254',
'042070032',
'031070719',
'091070840',
'021070647',
'091070753',
'091070843',
'081070687',
'091070831',
'041070164',
'021070399',
'022070060',
'091070775',
'091070810',
'031070946',
'091070804',
'091070751',
'042070458',
'081070665',
'091070816',
'032070496',
'081070683',
'091070844',
'041071213',
'091070754',
'041071255',
'041070062',
'011070006',
'052070042',
'081070682',
'091070830',
'031070815',
'052070243',
'091070827',
'091070833',
'081070681',
'041070864',
'041070162',
'091070814',
'081070695',
'091070808',
'051070172',
'021070097',
'041071215',
'081070680',
'041071265',
'091070868',
'081070664',
'091070746',
'032070535',
'081070677',
'041071204',
'091070812',
'061070808',
'081070667',
'041071235',
'081070666',
'091070803',
'091070793',
'012070127',
'032070076',
'031070146',
'091070783',
'091070821',
'091070779',
'170070024',
'160070001',
'160070002',
'170070001',
'051070341',
'142040531',
'142040520',
'142040465',
'142040538',
'142040560',
'142040466',
'031043623',
'061040144',
'142040498',
'071040805',
'142040477',
'142040548',
'142040537',
'142040502',
'142040453',
'142040510',
'092040525',
'142040470',
'142040519',
'101041007',
'142040487',
'142040493',
'142040508',
'072040252',
'142040535',
'102040535',
'142040556',
'142040471',
'142040552',
'081040290',
'142040481',
'142040567',
'131041079',
'041043110',
'102041460',
'142040464',
'102041226',
'142040549',
'142040511',
'142040551',
'142040507',
'142040482',
'022041796',
'142040524',
'142040509',
'081040783',
'142040480',
'032042024',
'091040066',
'052040428',
'092040516',
'142040468',
'142040463',
'142040562',
'142040494',
'142040566',
'142040455',
'142040456',
'101040137',
'142040518',
'142040461',
'142040533',
'051041911',
'061040979',
'142040469',
'101040749',
'031042753',
'142040536',
'142040564',
'142040563',
'142040554',
'022041231',
'142040523',
'102040821',
'152040464',
'152040481',
'152040497',
'152040595',
'152040621',
'042041613',
'092040078',
'092040317',
'152040136',
'152040465',
'152040617',
'091040100',
'152040692',
'152040694',
'152040578',
'152040073',
'101040729',
'151040713',
'151040912',
'152040697',
'152040492',
'062040137',
'152040622',
'062040772',
'081040365',
'091040471',
'152040013',
'112041096',
'151040758',
'071040142',
'152040693',
'152040677',
'111041717',
'152040670',
'152040493',
'170040317',
'170040267',
'170040297',
'170040242',
'170040291',
'170040345',
'170040249',
'170040023',
'170040301',
'170040178',
'170040225',
'170040060',
'170040347',
'170040284',
'170040320',
'170040314',
'170040203',
'170040352',
'170040285',
'170040388',
'170040247',
'170040435',
'170040409',
'170040305',
'170040281',
'170040294',
'170040108',
'170040215',
'170040123',
'170040318',
'170040278',
'170040282',
'170040035',
'170040258',
'170040280',
'170040214',
'170040272',
'170040250',
'170040351',
'170040386',
'170040246',
'170040055',
'170040179',
'170040252',
'170040277',
'170040312',
'170040292',
'170040153',
'170040147',
'170040216',
'170040273',
'170040259',
'170040279',
'170040264',
'170040319',
'170040236',
'170040217',
'170040286',
'170040048',
'170040188',
'170040271',
'170040303',
'170040339',
'170040333',
'170040095',
'170040368',
'170040075',
'170040248',
'170040254',
'170040032',
'170040275',
'170040289',
'170040244',
'170040299',
'170040330',
'170040296',
'170040313',
'170040256',
'170040287',
'170040298',
'170040290',
'170040069',
'170040338',
'170040308',
'170040349',
'170040404',
'170040190',
'170040257',
'170040334',
'170040340',
'170040434',
'170040337',
'170040024',
'170040343',
'170040307',
'170040300',
'170040079',
'170040335',
'170040283',
'170040263',
'170040266',
'170040058',
'170040141',
'170040126',
'170040293',
'170040074',
'170040253',
'170040238',
'170040262',
'170040327',
'170040025',
'170040310',
'170040261',
'170040268',
'170040316',
'170040325',
'170040288',
'170040210',
'170040336',
'170040274',
'170040324',
'170040326',
'170040265',
'170040046',
'170040309',
'170040235',
'170040322',
'170040107',
'170040379',
'170040350',
'170040315',
'170040302',
'170040145',
'170040239',
'170040321',
'170040323',
'170040255',
'170040260',
'170040276',
'170040304',
'170040111',
'170040341',
'170040245',
'170040332',
'170040331',
'170040344',
'170040189',
'170040348',
'170040372',
'170040329',
'170040270',
'170040391',
'170040426',
'170040056',
'170040269',
'170040243',
'170040251',
'170040050',
'170040091',
'170040410',
'170040431',
'170040367',
'161041314',
'142040513',
'132040455',
'152040644',
'101040200',
'071040187',
'152040703',
'142040540',
'051040586',
'101041030',
'091040185',
'102040371',
'101040622',
'152040746',
'152040576',
'151040806',
'152040710',
'052041382',
'052041269',
'151040697',
'152040712',
'111040370',
'042040986',
'142040488',
'142040546',
'111041340',
'142040472',
'121040829',
'152040648',
'152040717',
'022040673',
'152040696',
'152040602',
'041040170',
'102040148',
'122040514',
'152040489',
'152040749',
'102041435',
'151040918',
'151040923',
'152040459',
'152040666',
'152040495',
'151040741',
'101040898',
'031043610',
'142040526',
'152040653',
'152040752',
'151040814',
'151040694',
'092040228',
'152040643',
'152040695',
'152040619',
'152040077',
'142040517',
'151040911',
'151040698',
'152040627',
'151040914',
'102040435',
'102041056',
'152040337',
'131041145',
'152040685',
'101041923',
'151040695',
'152040662',
'151040902',
'091040500',
'102040750',
'151040805',
'152040701',
'152040652',
'042041343',
'151040692',
'061040585',
'151040922',
'152040682',
'152040664',
'142040543',
'142040504',
'142040512',
'142040484',
'152040466',
'152040671',
'152040346',
'151040788',
'161041949',
'161041766',
'161041936',
'161041960',
'170040392',
'161041834',
'161041402',
'161041708',
'161041797',
'161041682',
'161041572',
'161041149',
'161040757',
'161041900',
'161041727',
'161041861',
'161040462',
'161041434',
'161041871',
'161041634',
'161041092',
'161041730',
'161041224',
'161040999',
'161040603',
'161041752',
'161040601',
'161041680',
'161041830',
'161040346',
'161041335',
'161040602',
'161041851',
'161041876',
'161041559',
'161041059',
'161041636',
'161041815',
'161041903',
'161041921',
'161041579',
'161041600',
'161041643',
'161040552',
'161041692',
'161041159',
'161041846',
'161041375',
'161041864',
'161040328',
'161041892',
'161041291',
'161040944',
'161041302',
'161041476',
'161041768',
'161041896',
'161040340',
'161041927',
'170040161',
'161041477',
'161040617',
'161040016',
'161040754',
'161040031',
'161040349',
'161041689',
'161041930',
'161041877',
'161041913',
'161041235',
'161041925',
'161040334',
'161041924',
'161041238',
'161041024',
'161041044',
'161041820',
'161041313',
'161041709',
'161041228',
'161041897',
'161040959',
'161041753',
'161041806',
'161041488',
'161041571',
'161041432',
'161041891',
'161041517',
'161041567',
'161041856',
'161041857',
'161041658',
'161041465',
'161041558',
'161041816',
'161040451',
'161041875',
'161041430',
'161041882',
'161041467',
'161041845',
'161040551',
'161041401',
'161041366',
'161040330',
'161041844',
'161041642',
'161040545',
'161040573',
'161041097',
'161040550',
'161041530',
'161041220',
'161041804',
'161040459',
'161041363',
'161041957',
'161041649',
'170040397',
'161041939',
'161041954',
'161040424',
'161041878',
'161041738',
'161040831',
'161040830',
'170040143',
'170040430',
'161040345',
'161041808',
'170040149',
'161041906',
'161041229',
'161040505',
'111041096',
'161041854',
'161041828',
'101040408',
'152040707',
'021041457',
'161041822',
'161041733',
'161040867',
'091040805',
'161040709',
'102040320',
'061041052',
'161041860',
'161041802',
'071040266',
'041041219',
'072040234',
'051041897',
'052040960',
'161040389',
'101040403',
'161041742',
'161041832',
'051040338',
'161041873',
'161041881',
'161041460',
'161041283',
'161040747',
'161041867',
'161041868',
'161040488',
'161041865',
'032041648',
'161040540',
'170040219',
'062040059',
'062040058',
'161040498',
'092040574',
'161041685',
'081040796',
'061041075',
'061041074',
'161040458',
'161041202',
'101040048',
'161040957',
'161041840',
'161041745',
'101042117',
'161041428',
'102040235',
'161040494',
'161040487',
'161040762',
'161041818',
'161041568',
'161041307',
'161041794',
'092040233',
'161041137',
'161041862',
'161040590',
'111041214',
'101040980',
'161040002',
'161041777',
'161041908',
'161041177',
'161041750',
'161041007',
'161041759',
'161040370',
'161041122',
'112040831',
'161041843',
'101041342',
'161041775',
'161040018',
'161041884',
'161041748',
'112040322',
'121041084',
'102040651',
'142040491',
'161041870',
'161041779',
'161041573',
'142040542',
'152040483',
'121040783',
'121040229',
'151040813',
'161041500',
'161040443',
'161041574',
'111040524',
'161041774',
'161041773',
'142040565',
'161041566',
'142040506',
'161041741',
'111041749',
'102041090',
'041043679',
'101040436',
'071040395',
'161040715',
'102041112',
'161040581',
'161040580',
'111040005',
'042040981',
'142040544',
'022040075',
'101040889',
'161041697',
'081040445',
'081040447',
'152040494',
'142040489',
'161041749',
'112040153',
'170040306',
'061040474',
'032041185',
'161040546',
'161041743',
'101042014',
'161041947',
'161041652',
'101041035',
'022041274',
'151040916',
'022041943',
'161041587',
'142040516',
'022041999',
'161041603',
'052041032',
'142040497',
'161041863',
'161041812',
'142040550',
'041043098',
'161041597',
'061040697',
'152040519',
'142040478',
'052041021',
'161041575',
'031042191',
'161041612',
'152040720',
'142040503',
'161041662',
'161041756',
'042040922',
'161041645',
'161041472',
'161041842',
'102040375',
'142040499',
'142040490',
'032040058',
'152040711',
'161041644',
'041040315',
'161041464',
'041041922',
'142040476',
'161041647',
'161040343',
'142040525',
'161041811',
'081040452',
'022041909',
'142040514',
'031041432',
'111041573',
'161040574',
'152040750',
'142040449',
'161040032',
'161041497',
'142040532',
'121041192',
'042041628',
'142040457',
'101040457',
'161040536',
'161040535',
'042041888',
'042041887',
'142040505',
'142040495',
'161041478',
'161041850',
'161041922',
'161041739',
'101040438',
'161041852',
'161041911',
'161041824',
'161041839',
'161040326',
'161041931',
'161041849',
'112040821',
'161041679',
'161041872',
'112040114',
'161040012',
'161041823',
'161041918',
'161041800',
'061040473',
'161041833',
'071040124',
'161040403',
'131040671',
'101041292',
'161041638',
'111040600',
'131040493',
'101041541',
'161041853',
'161041805',
'161040377',
'122040215',
'061040666',
'161041747',
'161041744',
'161041915',
'161041847',
'122040674',
'112040892',
'161041781',
'112040969',
'161041874',
'102041474',
'131041148',
'101041283',
'161041831',
'072040399',
'161041681',
'161041848',
'161041713',
'032040079',
'111040574',
'112040429',
'161041675',
'161041663',
'161041948',
'161041694',
'161041793',
'161041198',
'152040689',
'161041817',
'161040362',
'161040412',
'161040411',
'161040647',
'170040362',
'161041045',
'170040363',
'161040013',
'161041855',
'051042560',
'161041659',
'161040023',
'161040022',
'161040020',
'161040021',
'161041632',
'161041671',
'161041941',
'081041083',
'011040119',
'051041055',
'031044552',
'031044556',
'041043762',
'031044551',
'031044530',
'051041586',
'031044516',
'031044529',
'170040059',
'041043770',
'051042663',
'011040009',
'081041087',
'031044550',
'031044554',
'031044531',
'031044517',
'081041086',
'042041376',
'031044549',
'031044548',
'031044547',
'031044546',
'081041081',
'081041095',
'051041062',
'031044553',
'041043761',
'102040393',
'042040462',
'031044532',
'031044514',
'041043760',
'031044533',
'031044527',
'031044518',
'022041763',
'022041735',
'041041018',
'031044526',
'031044520',
'051041838',
'041042107',
'041040382',
'031044519',
'031044528',
'031044534',
'031044545',
'051041405',
'031044525',
'051040793',
'031044544',
'031044524',
'031044536',
'031044521',
'011040089',
'031044537',
'031044543',
'041043759',
'041040332',
'031044542',
'042041445',
'041042913',
'031044523',
'041043756',
'161041625',
'081041084',
'081041085',
'041043755',
'031044541',
'031044522',
'021040817',
'051042633',
'041042522',
'041043757',
'051042411',
'031044538',
'051041567',
'011040217',
'161041546',
'042040766',
'041040061',
'031044540',
'041043758',
'031044539',
'051041153',
'170040027',
'170040062',
'170040101',
'161041929',
'170040160',
'170040419',
'170040224',
'170040137',
'161041722',
'170040177',
'170040122',
'161041718',
'161060002',
'151060370',
'082060115',
'121060201',
'052060164',
'151060369',
'151060330',
'051060261',
'061060254',
'151060368',
'151060373',
'151060376',
'151060367',
'151060378',
'151060325',
'151060375',
'041060056',
'151060305',
'151060335',
'151060377',
'151060328',
'051060170',
'102060188',
'151060327',
'041060227',
'151060371',
'151060334',
'051060202',
'151060320',
'151060374',
'151060191',
'081060162',
'151060366',
'151060362',
'061060210',
'041060313',
'142060128',
'081060258',
'021060126',
'151060093',
'161060407',
'161060449',
'161060426',
'142060290',
'072060021',
'101060166',
'052060052',
'101060058',
'082060171',
'041060027',
'142060111',
'081060264',
'081060232',
'052060048',
'102060041',
'092060079',
'170060096',
'170060022',
'170060010',
'170060009',
'170060011',
'170060059',
'170060028',
'101060097',
'152060176',
'152060180',
'152060161',
'042060125',
'102060056',
'152060179',
'062060010',
'042060106',
'101060225',
'111060052',
'092060047',
'170060039',
'170060023',
'170060016',
'142060235',
'142060273',
'102060130',
'101060280',
'142060274',
'071060089',
'102060054',
'170060136',
'170060138',
'041060065',
'051060152',
'071060201',
'031060019',
'051060063',
'142060161',
'101060266',
'081060081',
'142060281',
'142060322',
'071060099',
'091060068',
'081060073',
'071060125',
'161060465',
'161060485',
'161060492',
'161060466',
'161060476',
'161060458',
'161060396',
'152060153',
'152060151',
'152060144',
'152060152',
'152060170',
'041060031',
'142060241',
'170060088',
'170060082',
'170060080',
'170060101',
'170060067',
'170060083',
'170060089',
'170060076',
'170060075',
'170060079',
'170060064',
'170060085',
'170060086',
'170060078',
'152060166',
'152060149',
'152060191',
'052060184',
'152060190',
'170060001',
'161060495',
'161060473',
'161060479',
'161060483',
'101060095',
'102060074',
'122060121',
'111060091',
'170060057',
'170060045',
'170060050',
'161060494',
'161060498',
'170060044',
'170060073',
'121060166',
'131060097',
'161060489',
'161060475',
'170060046',
'041060223',
'032060020',
'170060094',
'170060074',
'170060065',
'170060036',
'170060033',
'170060012',
'170060060',
'122060133',
'031060065',
'111060049',
'102060032',
'161060421',
'112060037',
'041060198',
'132060216',
'071060150',
'081060194',
'161060410',
'152060150',
'142060293',
'142060324',
'142060292',
'142060285',
'142060286',
'142060330',
'142060287',
'142060334',
'092060140',
'142060325',
'142060333',
'142060291',
'142060283',
'142060278',
'142060298',
'142060295',
'031060278',
'142060316',
'142060302',
'142060317',
'142060282',
'142060294',
'142060277',
'142060311',
'142060276',
'142060307',
'142060327',
'142060304',
'142060309',
'021060031',
'142060275',
'142060329',
'142060303',
'142060321',
'142060315',
'142060318',
'142060306',
'142060314',
'142060280',
'142060308',
'142060288',
'142060279',
'142060328',
'142060332',
'142060305',
'142060300',
'142060313',
'142060323',
'142060326',
'142060289',
'082060108',
'101060252',
'051060087',
'101060031',
'092060110',
'111060048',
'102060033',
'152060160',
'152060162',
'142060310',
'101060263',
'142060301',
'091060147',
'051060243',
'102060040',
'051060104',
'102060048',
'082060052',
'102060133',
'092060091',
'142060299',
'092060080',
'071060202',
'082060134',
'092060036',
'101060268',
'071060122',
'081060062',
'102060044',
'091060043',
'092060007',
'142060296',
'082060064',
'142060312',
'102060046',
'170060162',
'170060146',
'170060158',
'170060163',
'170060165',
'170060147',
'170060156',
'170060152',
'170060180',
'170060142',
'170060144',
'170060145',
'170060157',
'170060177',
'170060092',
'170060071',
'170060093',
'170060169',
'170060072',
'170060014',
'142050425',
'142050432',
'142050441',
'142050435',
'142050423',
'142050436',
'142050420',
'142050448',
'142050449',
'142050418',
'151051009',
'170050060',
'170050093',
'170050076',
'170050100',
'170050065',
'170050091',
'170050101',
'170050062',
'170050064',
'170050074',
'170050063',
'170050098',
'170050077',
'151051012',
'151051021',
'151051031',
'151051015',
'151051028',
'161051047',
'151050087',
'101050344',
'151051019',
'101050519',
'151051008',
'151051017',
'102050369',
'151051014',
'151051020',
'061050813',
'151051033',
'151051024',
'151051016',
'151051025',
'161051056',
'161051050',
'091050335',
'170050069',
'170050066',
'170050090',
'170050057',
'170050071',
'170050072',
'170050088',
'152050333',
'152050293',
'031050196',
'042050351',
'170050085',
'170050059',
'170050094',
'170050092',
'170050087',
'170050084',
'170050082',
'170050095',
'170050067',
'170050061',
'170050102',
'170050073',
'170050058',
'170050086',
'170050083',
'170050075',
'101050034',
'091050364',
'041050665',
'121050471',
'111050760',
'152050354',
'152050331',
'152050359',
'161051063',
'091050170',
'152050368',
'152050312',
'081050307',
'152050364',
'152050353',
'082050230',
'121050655',
'111050773',
'061050433',
'152050350',
'092050143',
'152050292',
'102050729',
'152050304',
'152050306',
'101050744',
'071050749',
'102050303',
'142050419',
'081050007',
'142050443',
'142050438',
'142050446',
'142050444',
'101050592',
'142050433',
'151050086',
'142050447',
'142050439',
'142050437',
'142050442',
'091050221',
'142050422',
'081050869',
'142050440',
'082050152',
'081050540',
'121050213',
'170050078',
'170050079',
'170050034',
'170050068',
'170050033',
'170050036',
'170050031',
'111050211',
'102050245',
'081050144',
'081050900',
'061050545',
'152050294',
'121050078',
'152050362',
'152050334',
'081050784',
'152050305',
'152050325',
'152050302',
'151051022',
'102050321',
'151051023',
'151051034',
'071050491',
'151051029',
'051050095',
'121050648',
'121050491',
'072050332',
'061050272',
'151051026',
'151051013',
'061050536',
'151051018',
'091050469',
'082050288',
'072050087',
'112050273',
'101050331',
'122050508',
'112050139',
'121050604',
'121050492',
'071050766',
'062050556',
'161051090',
'131050127',
'161051074',
'161051073',
'152050352',
'152050345',
'170050080',
'170050020',
'121050654',
'111050675',
'152050343',
'152050339',
'161050995',
'071050266',
'161051004',
'161051009',
'161050993',
'161050115',
'022050095',
'131050121',
'101050594',
'161051046',
'161051057',
'161050798',
'142050434',
'142050427',
'142050430',
'052050043',
'142050428',
'031050015',
'101050400',
'092050127',
'161051071',
'101050123',
'142050431',
'142050421',
'101050404',
'142050429',
'142050426',
'131050573',
'101050343',
'101050221',
'092050172',
'031050250',
'081050328',
'111050600',
'102050590',
'152050298',
'170050010',
'170050003',
'170050012',
'111050262',
'111050440')
ORDER BY 3,2