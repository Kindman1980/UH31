&ИзменениеИКонтроль("ОбработатьСтруктуруТаблицТекущаяИБ")
Процедура ОбработатьСтруктуруТаблицТекущаяИБ_ОЦО()

	Если СтруктураТаблиц.Количество()=0 Тогда

		ДобавитьЗаписьпоСеансуЗагрузки();
		Возврат;

	КонецЕсли;

	Запрос=Новый Запрос;
	Запрос.МенеджерВременныхТаблиц=Новый МенеджерВременныхТаблиц;

	ТекстЗапроса="";

	Для Каждого КлючИЗначение ИЗ СтруктураТаблиц Цикл

		Если КлючИЗначение.Ключ="Шапка" Тогда

			Если КлючИЗначение.Значение.Количество()=0 Тогда

				ДобавитьЗаписьпоСеансуЗагрузки();
				Возврат;

			КонецЕсли;

			Если ПравилоЗаполнения.ПоОбъектуБД=1 Тогда

				ТаблицаРеквизитов=КлючИЗначение.Значение;

			Иначе	

				ТаблицаРеквизитов=ПолучитьТаблицуРеквизитов(КлючИЗначение.Ключ);
				ОбщегоНазначенияУХ.ЗагрузитьВТаблицуЗначений(КлючИЗначение.Значение,ТаблицаРеквизитов);

				СтруктураТаблиц.Вставить(КлючИЗначение.Ключ,ТаблицаРеквизитов);

			КонецЕсли;

		Иначе

			ТаблицаРеквизитов=КлючИЗначение.Значение;

		КонецЕсли;

		ТекстВыборки="";

		Для Каждого Колонка ИЗ ТаблицаРеквизитов.Колонки Цикл

			ТекстВыборки=ТекстВыборки+",
			|"+КлючИЗначение.Ключ+"_Исходник."+Колонка.Имя;

		КонецЦикла;

		ТекстЗапроса=ТекстЗапроса+"
		|ВЫБРАТЬ "+Сред(ТекстВыборки,2)+" Поместить "+КлючИЗначение.Ключ+"_ВТ ИЗ &"+КлючИЗначение.Ключ+" КАК "+КлючИЗначение.Ключ+"_Исходник
		|;";

		Запрос.УстановитьПараметр(КлючИЗначение.Ключ,ТаблицаРеквизитов);

	КонецЦикла;

	ТекстСоединение="";
	ОписаниеТиповСтрокаНеограниченнойДлины=ОбщегоНазначенияУХ.ПолучитьОписаниеТиповСтроки(0);

	Если ПравилоЗаполнения.ПоОбъектуБД=1 Тогда

		ТекстЗапроса=ТекстЗапроса+"
		|ВЫБРАТЬ Шапка_ВТ.*,
		|ЕСТЬNULL(ОбработанныеОбъектыБДИсточник.ОбработанныйОбъектСсылка,Неопределено) КАК СуществующийДокумент,
		|ЕСТЬNULL(ОбработанныеОбъектыБДПриемник.ИсходныйОбъектСсылка,Неопределено) КАК ДокументПланирования
		|ИЗ Шапка_ВТ 
		|ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ОбработанныеОбъектыБД КАК ОбработанныеОбъектыБДИсточник ПО Шапка_ВТ.ИсходныйОбъектСсылка=ОбработанныеОбъектыБДИсточник.ИсходныйОбъектСсылка
		|ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ОбработанныеОбъектыБД КАК ОбработанныеОбъектыБДПриемник ПО Шапка_ВТ.ИсходныйОбъектСсылка=ОбработанныеОбъектыБДПриемник.ОбработанныйОбъектСсылка";

	Иначе	

		СтруктураПоиска=Новый Структура("ОбъектБД,Организация,ПериодОтчета,Сценарий,ПравилоЗаполнения,ИспользуемаяИБ");

		ЗаполнитьЗначенияСвойств(СтруктураПоиска,ЭтотОбъект);

		СеансОбменаДанными=Справочники.СеансыОбменаДанными.НайтиСоздатьСеансОбменаДанными(СтруктураПоиска);

		ТекстЗапроса=ТекстЗапроса+"
		|ВЫБРАТЬ Шапка_ВТ.*,ЕСТЬNULL(ОбработанныеОбъектыБДПриемник.ОбработанныйОбъектСсылка,Неопределено) КАК СуществующийДокумент
		|ИЗ Шапка_ВТ ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ОбработанныеОбъектыБД КАК ОбработанныеОбъектыБДПриемник ПО
		|ОбработанныеОбъектыБДПриемник.СеансОбменаДанными=&СеансОбменаДанными";

		Запрос.УстановитьПараметр("СеансОбменаДанными",СеансОбменаДанными);

	КонецЕсли;

	Запрос.Текст=ТекстЗапроса;
	ТаблицаДокументов=Запрос.Выполнить().Выгрузить();

	СтруктураПоиска=Новый Структура;
	ТекстОтбор="";

	Для Каждого СтрРеквизит ИЗ ПравилоЗаполнения.РеквизитыШапкиДляСинхронизацииТЧ Цикл

		СтруктураПоиска.Вставить(СтрРеквизит.Имя);

		ТекстОтбор=СтрШаблон(Нстр("ru = '%1
		|И %2=&%3'"), ТекстОтбор, СтрРеквизит.Имя, СтрРеквизит.Имя);

	КонецЦикла;

	ТекстОтбор=Сред(ТекстОтбор,3);
	ТаблицаОбъектов=Новый ТаблицаЗначений;
	ТаблицаОбъектов.Колонки.Добавить("ОбработанныйОбъектСсылка");
	ТаблицаОбъектов.Колонки.Добавить("ИсходныйОбъектНомер");
	ТаблицаОбъектов.Колонки.Добавить("ИсходныйОбъектКод");
	ТаблицаОбъектов.Колонки.Добавить("ИсходныйОбъектНаименование");
	ТаблицаОбъектов.Колонки.Добавить("ИсходныйОбъектДата");
	ТаблицаОбъектов.Колонки.Добавить("ИсходныйОбъектСсылка");
	ТаблицаОбъектов.Колонки.Добавить("ОбработкаЗавершена");
	ТаблицаОбъектов.Колонки.Добавить("ЕстьОшибкиИмпорта");

	РеквизитыДляЗаполненияШапки=ПолучитьСтрокуРеквизитовДляЗаполненияШапки();

	Для Каждого СтрДокумент ИЗ ТаблицаДокументов Цикл

		Если СтрДокумент.СуществующийДокумент=Неопределено Тогда

			ДокументОбъект=Документы[ОбъектБД.Наименование].СоздатьДокумент();

		Иначе

			ДокументОбъект=СтрДокумент.СуществующийДокумент.ПолучитьОбъект();

		КонецЕсли;
		#Вставка
		Если ТипЗнч(ДокументОбъект) = тип("ДокументОбъект.ОтражениеФактическихДанныхБюджетирования") и ДокументОбъект.скорректирован тогда
			продолжить; // не перезаполняем так были правки пользователя
		//	//SSC-475 Правила создания/заполнения документов ОФД по первичным бухгалтерским документам //
		Конецесли;	
		#Конецвставки

		ЗаполнитьЗначенияСвойств(ДокументОбъект,СтрДокумент,РеквизитыДляЗаполненияШапки);

		Если Не ЗначениеЗаполнено(ДокументОбъект.Дата) Тогда

			ДокументОбъект.Дата=ПериодОтчета.ДатаОкончания;

		КонецЕсли;

		Если Не ЗначениеЗаполнено(ДокументОбъект.Номер) Тогда

			ДокументОбъект.УстановитьНовыйНомер(Организация.Префикс);

		КонецЕсли;

		ЗаполнитьЗначенияСвойств(СтруктураПоиска,СтрДокумент);

		Для Каждого КлючИЗначение ИЗ СтруктураТаблиц Цикл

			Если КлючИЗначение.Ключ="Шапка" Тогда
				Продолжить;
			КонецЕсли;

			ДокументОбъект[КлючИЗначение.Ключ].Очистить();

			Запрос.Текст="ВЫБРАТЬ * ИЗ "+КлючИЗначение.Ключ + "_ВТ";

			Если Не ПустаяСтрока(ТекстОтбор) Тогда

				Запрос.Текст=СтрШаблон(Нстр("ru = '%1 ГДЕ %2'"), Запрос.Текст, ТекстОтбор);

				Для Каждого ПараметрПоиска ИЗ СтруктураПоиска Цикл

					Запрос.УстановитьПараметр(ПараметрПоиска.Ключ,ПараметрПоиска.Значение);

				КонецЦикла;

			КонецЕсли;

			Результат=Запрос.Выполнить().Выбрать();

			Пока Результат.Следующий() Цикл

				НоваяСтрока=ДокументОбъект[КлючИЗначение.Ключ].Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрока,СтрДокумент);
				ЗаполнитьЗначенияСвойств(НоваяСтрока,Результат);

			КонецЦикла;

		КонецЦикла;

		ДокументОбъект.ПометкаУдаления=Ложь;
		ДокументПроведен=Ложь;
		ДокументЗаписан=Ложь;
		ЕстьОшибкиИмпорта=Ложь;
		ТекстОшибки="";

		Если ПравилоЗаполнения.ПроизвольныйКодПослеЗаполнения И ЗначениеЗаполнено(ПравилоЗаполнения.ПроцедураЗаполнения) Тогда

			Попытка



				Выполнить(ПравилоЗаполнения.ПроцедураЗаполнения);

			Исключение

				ТекстОшибки=СтрШаблон(Нстр("ru = 'Не удалось выполнить процедуру после заполнения объекта;
				|%1'"), ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));

				ОбщегоНазначенияУХ.СообщитьОбОшибке(ТекстОшибки,,,СтатусСообщения.Внимание);

			КонецПопытки;

		КонецЕсли;

		Если ПроводитьДокументы Тогда

			ТекстОшибки=ЗаписатьОбъект(ДокументОбъект,РежимЗаписиДокумента.Проведение,Ложь,ДокументПроведен);

			Если НЕ ДокументПроведен Тогда

				ТекстОшибки=ЗаписатьОбъект(ДокументОбъект,РежимЗаписиДокумента.Запись,Истина,ДокументЗаписан);

			КонецЕсли;

		Иначе

			ТекстОшибки=ЗаписатьОбъект(ДокументОбъект,РежимЗаписиДокумента.Запись,Истина,ДокументЗаписан);

		КонецЕсли;

		Если ПустаяСтрока(ТекстОшибки) Тогда

			НоваяСтрока=ТаблицаОбъектов.Добавить();
			НоваяСтрока.ОбработанныйОбъектСсылка=ДокументОбъект.Ссылка;
			НоваяСтрока.ОбработкаЗавершена=ДокументПроведен;
			НоваяСтрока.ЕстьОшибкиИмпорта=Ложь;
			ЗаполнитьЗначенияСвойств(НоваяСтрока,СтрДокумент);

		Иначе

			ТекстОшибки=СтрШаблон(Нстр("ru = '%1
			|Не удалось записать документ со следующими реквизитами:'"), ТекстОшибки);

			Для Каждого СтрРеквизит ИЗ ОбъектБД.Реквизиты Цикл

				Если ЗначениеЗаполнено(ДокументОбъект[СтрРеквизит.Имя]) Тогда

					ТекстОшибки=ТекстОшибки+"
					|"+СтрРеквизит.Синоним+": "+ДокументОбъект[СтрРеквизит.Имя];

				КонецЕсли;

			КонецЦикла;

			ОбщегоНазначенияУХ.СообщитьОбОшибке(ТекстОшибки,ЕстьОшибкиИмпорта);

			НоваяСтрока=ТаблицаОбъектов.Добавить();
			НоваяСтрока.ОбработкаЗавершена=Ложь;
			НоваяСтрока.ЕстьОшибкиИмпорта=Истина;
			ЗаполнитьЗначенияСвойств(НоваяСтрока,СтрДокумент);

		КонецЕсли;

	КонецЦикла;

	ОтразитьОбработкуТаблицыОбъектов(ТаблицаОбъектов);

КонецПроцедуры
