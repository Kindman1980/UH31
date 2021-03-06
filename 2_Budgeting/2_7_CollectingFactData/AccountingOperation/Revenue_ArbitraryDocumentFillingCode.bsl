ИсходныйДокументСсылка = ДокументОбъект.ИсходныйДокумент;
ЗаполнениеОФДАлгоритмы.ЗаполнитьДатуДокументаОФДСУчетомДопСведений(ДокументОбъект,ИсходныйДокументСсылка);

ДокументОбъект.ДокументБД = Справочники.ДокументыБД.НайтиПоНаименованию("ОперацияБух");
БюджетДоходовИРасходов  = ДокументОбъект.БюджетДоходовИРасходов; //получаем табчасть БДиР
ДокументОбъект.Организация = ИсходныйДокументСсылка.Организация;
ДокументОбъект.Комментарий = "SSC-476"+" "+ Строка(ТекущаяДата());

Запрос = Новый Запрос;
Запрос.Текст = "ВЫБРАТЬ
|	ХозрасчетныйОборотыДтКт.Регистратор КАК Регистратор,
|	ХозрасчетныйОборотыДтКт.Период КАК Период,
|	ХозрасчетныйОборотыДтКт.СчетКт КАК СчетКт,
|	ВЫРАЗИТЬ(ХозрасчетныйОборотыДтКт.СубконтоКт1 КАК Справочник.НоменклатурныеГруппы) КАК СубконтоКт1,
|	ХозрасчетныйОборотыДтКт.СуммаОборот КАК Сумма
|ПОМЕСТИТЬ ПроводкиКт90
|ИЗ
|	РегистрБухгалтерии.Хозрасчетный.ОборотыДтКт(&НачПериода, &КонПериода, Запись, , , счетКт В ИЕРАРХИИ (&Счет90), , ) КАК ХозрасчетныйОборотыДтКт
|ГДЕ
|	ХозрасчетныйОборотыДтКт.Регистратор = &Регистратор
|	И ХозрасчетныйОборотыДтКт.Регистратор ССЫЛКА Документ.ОперацияБух
|;
|
|////////////////////////////////////////////////////////////////////////////////
|ВЫБРАТЬ
|	ПроводкиКт90.Регистратор КАК Регистратор,
|	ПроводкиКт90.Период КАК Период,
|	ПроводкиКт90.СчетКт КАК СчетКт,
|	ПроводкиКт90.СубконтоКт1 КАК СубконтоКт1,
|	ПроводкиКт90.Сумма КАК Сумма,
|	НоменклатурныеГруппыДополнительныеРеквизиты.Значение КАК проект
|ИЗ
|	ПроводкиКт90 КАК ПроводкиКт90
|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.НоменклатурныеГруппы.ДополнительныеРеквизиты КАК НоменклатурныеГруппыДополнительныеРеквизиты
|		ПО ПроводкиКт90.СубконтоКт1 = НоменклатурныеГруппыДополнительныеРеквизиты.Ссылка
|			И (НоменклатурныеГруппыДополнительныеРеквизиты.Свойство.Имя = ""Проект"")";

Счет90 = ПланыСчетов.Хозрасчетный.Продажи; // 90 счет

// Установка параметров.
Запрос.УстановитьПараметр("Регистратор",  ДокументОбъект.ИсходныйДокумент);
Запрос.УстановитьПараметр("НачПериода", ДокументОбъект.ИсходныйДокумент.Дата);
Запрос.УстановитьПараметр("КонПериода",КонецДня( ДокументОбъект.ИсходныйДокумент.Дата));
Запрос.УстановитьПараметр("Счет90", Счет90);


БюджетДоходовИРасходов.очистить();
лВыборка =Запрос.Выполнить().Выбрать();
	
Пока лВыборка.Следующий() Цикл
		лНоваяСтрока = БюджетДоходовИРасходов.Добавить();	
		лНоваяСтрока.СтатьяДоходовИРасходов         =  справочники.СтатьиДоходовИРасходов.НайтиПоНаименованию("PL.REV.1 > Выручка");
		лНоваяСтрока.Проект               =  лвыборка.проект;
		лНоваяСтрока.СуммаБезНДС          = лВыборка.Сумма;
		лНоваяСтрока.СуммаНДС             =    0;
		лНоваяСтрока.Сумма                =        лВыборка.Сумма;
		лНоваяСтрока.СуммУпр_ОЦО =   лВыборка.Сумма;
		
		//добавить условие по валюте
		лНоваяСтрока.СуммаВзаиморасчетовБезНДС   = лНоваяСтрока.СуммаБезНДС;
		лНоваяСтрока.СуммаВзаиморасчетовНДС         = лНоваяСтрока.СуммаНДС;
		лНоваяСтрока.СуммаВзаиморасчетов                 =лНоваяСтрока.Сумма;
		
		
		//Если ЗначениеЗаполнено(лвыборка.Валюта) тогда
			
		//	лНоваяСтрока.ВалютаВзаиморасчетов = лвыборка.валюта;
		//	лНоваяСтрока.СуммаБезНДС          = лвыборка.ВалютнаяСумма;
		//	лНоваяСтрока.СуммаНДС             =    0;
		//	лНоваяСтрока.Сумма                =        лвыборка.валютнаясумма;
		//	лНоваяСтрока.СуммаВзаиморасчетовБезНДС = лвыборка.ВалютнаяСумма;
		//	лНоваяСтрока.СуммаВзаиморасчетов = лвыборка.валютнаясумма;
		//КонецЕсли;
		
	КонецЦикла;
	ДокументОбъект.СуммаДокумента= БюджетДоходовИРасходов.Итог("Сумма");
