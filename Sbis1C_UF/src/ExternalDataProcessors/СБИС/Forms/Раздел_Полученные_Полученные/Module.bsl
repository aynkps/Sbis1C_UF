
&НаКлиенте
Перем МестныйКэш;


#Область include_local_ПолучитьМодульОбъекта

&НаСервере
Функция МодульОбъектаСервер()
	Возврат РеквизитФормыВЗначение("Объект");
КонецФункции

&НаСервереБезКонтекста
Функция МодульОбъектаСерверБезКонтекста()
	Возврат Новый (Тип("ВнешняяОбработкаОбъект.СБИС"));
КонецФункции

&НаКлиенте
Функция МодульОбъектаКлиент() Экспорт
	Возврат ВладелецФормы.Кэш.СБИС.МодульОбъектаКлиент;
КонецФункции

#КонецОбласти

#Область include_core2_vo2_Раздел_Полученные

// Функция делает подготовку к переходу	
&НаКлиенте
Функция ОбновитьКонтент_ПередВызовом(СтруктураРаздела, Кэш) Экспорт
	
	Если ЗначениеЗаполнено(Кэш.Парам.ФильтрыПоРазделам["Полученные"]) Тогда
		Кэш.ГлавноеОкно.сбисВосстановитьФильтр(Кэш, Кэш.Парам.ФильтрыПоРазделам["Полученные"]);
	Иначе
		ФильтрОчистить(Кэш);
	КонецЕсли;

КонецФункции

// Процедура устанавливает панель навигации на 1ую страницу	
&НаКлиенте
Процедура НавигацияУстановитьПанель(Кэш=Неопределено) Экспорт
	Если МестныйКэш = Неопределено Тогда
		МестныйКэш = Кэш;
	КонецЕсли;
	ГлавноеОкно = МестныйКэш.ГлавноеОкно;
	ГлавноеОкно.сбисЭлементФормы(ГлавноеОкно,"ПанельНавигации").Видимость=Истина;
	ГлавноеОкно.сбисЭлементФормы(ГлавноеОкно,"ЗаписейНаСтранице1С").Видимость=Ложь;
	ГлавноеОкно.сбисЭлементФормы(ГлавноеОкно,"ЗаписейНаСтранице").Видимость=Истина;
КонецПроцедуры

// функция формирует структуру данных по пакету электронных документов, необходимую для его предварительного просмотра и загрузки в 1С		
&НаКлиенте
Функция ПодготовитьСтруктуруДокумента(СтрокаСпискаДокументов, Кэш) Экспорт

	Возврат Кэш.ОбщиеФункции.ПодготовитьСтруктуруДокументаСбис(СтрокаСпискаДокументов, Кэш);	
	
КонецФункции

&НаКлиенте
Функция ПодготовитьСтруктуруДокументаДляРасхождений(СтрокаСпискаДокументов, Кэш) Экспорт
			
	Попытка
		Возврат МодульОбъектаКлиент().ПодготовитьСтруктуруДокументаДляРасхожденийДляРеестраСБИС(СтрокаСпискаДокументов);
	Исключение
		МодульОбъектаКлиент().ВызватьСбисИсключение(ИнформацияОбОшибке(), "Раздел_Полученные_Полученные.ПодготовитьСтруктуруДокументаДляРасхождений");
	КонецПопытки;
			
КонецФункции

#КонецОбласти

// функции для совместимости кода 
&НаКлиенте
Функция сбисЭлементФормы(Форма,ИмяЭлемента)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Возврат Форма.Элементы.Найти(ИмяЭлемента);
	КонецЕсли;
	Возврат Форма.ЭлементыФормы.Найти(ИмяЭлемента);
КонецФункции

//------------------------------------------------------

//функция обновляет контент для раздела Полученные	
&НаКлиенте
Функция ОбновитьКонтент(Кэш) Экспорт
	Если МестныйКэш = Неопределено Тогда
		МестныйКэш = Кэш;
	КонецЕсли;
	ГлавноеОкно = Кэш.ГлавноеОкно;
	
	СтруктураДляОбновленияФормы = Кэш.Интеграция.ПолучитьСписокСобытий(Кэш, "Входящие");
	Кэш.ОбщиеФункции.ОбновитьПанельНавигации(Кэш);
	Контент = ГлавноеОкно.сбисЭлементФормы(ГлавноеОкно, "Контент");
	Контент.ТекущаяСтраница = ГлавноеОкно.сбисПолучитьСтраницу(Контент, "РеестрСобытий");	
	Кэш.ТаблДок = ГлавноеОкно.сбисЭлементФормы(ГлавноеОкно,"Таблица_РеестрСобытий");
	
	//Добавить колонки в таблицу
	СтруктураТаблицыСобытий	= ПолучитьСтруктуруТаблицыСобытий(Кэш);
	Кэш.ГлавноеОкно.НастроитьКолонкиФормы(СтруктураТаблицыСобытий);
	Кэш.ГлавноеОкно.СписокДопОперацийРеестра.Очистить();
	Возврат СтруктураДляОбновленияФормы;
КонецФункции

&НаКлиенте
Функция ПараметраФильтраДляСобытий() Экспорт
	
	ДопПараметрыФильтра = Новый Структура("ТипРеестра", "Входящие");
	Результат			= Новый Структура("ДопФильтры, Реестр", ДопПараметрыФильтра, "СписокСобытий");
	Возврат Результат;
	
КонецФункции

// Процедура обновляет панель массовых операций, панель фильтра, контекстное меню при смене раздела	
&НаКлиенте
Процедура НаСменуРаздела(Кэш) Экспорт
	Если МестныйКэш = Неопределено Тогда
		МестныйКэш = Кэш;
	КонецЕсли;
	
	ПодготовитьФильтрРаздела(Кэш);
		
	ГлавноеОкно = МестныйКэш.ГлавноеОкно;
	
	ГлавноеОкно.сбисУстановитьКонтекстноеМеню("Таблица_РеестрДокументов", "КонтекстноеМенюПолученные");
	ГлавноеОкно.сбисУстановитьКонтекстноеМеню("Таблица_РеестрСобытий", "КонтекстноеМенюПолученныеРеестрСобытий");
	ПанельМассовыхОпераций = ГлавноеОкно.сбисЭлементФормы(ГлавноеОкно,"ПанельМассовыхОпераций");
	ПанельМассовыхОпераций.ТекущаяСтраница = ГлавноеОкно.сбисПолучитьСтраницу(ПанельМассовыхОпераций,"Полученные");
	
	СпособИнтеграцииКаталог = МестныйКэш.Парам.СпособОбмена = 1;	
	ГлавноеОкно.сбисЭлементФормы(ГлавноеОкно,"ПанельМассовыхОпераций").Видимость = Истина;
	ГлавноеОкно.сбисЭлементФормы(ГлавноеОкно,"ПанельТулбар").Видимость = Истина;	
	ГлавноеОкно.сбисЭлементФормы(ГлавноеОкно,"МассовыеОперацииСопоставить2").Видимость	= Не СпособИнтеграцииКаталог;
	ГлавноеОкно.сбисЭлементФормы(ГлавноеОкно,"МассовыеОперацииУтвердить1").Видимость	= Не СпособИнтеграцииКаталог;
	ГлавноеОкно.сбисЭлементФормы(ГлавноеОкно,"Сохранить1").Видимость					= Не СпособИнтеграцииКаталог;
	
	ГлавноеОкно.сбисЭлементФормы(ГлавноеОкно,"ПанельФильтра").Видимость = Не СпособИнтеграцииКаталог;
	ГлавноеОкно.сбисЭлементФормы(ГлавноеОкно,"ПоказатьПанельФильтра").Видимость = Не СпособИнтеграцииКаталог;
КонецПроцедуры

//Процедура настройки видимости колонок при переходе в раздел.
&НаКлиенте
Процедура НастроитьКолонки(Кэш) Экспорт
	Если МестныйКэш = Неопределено Тогда
		МестныйКэш = Кэш;
	КонецЕсли;
	
	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(Кэш.ГлавноеОкно, "Таблица_РеестрДокументов.ТекущийЭтап").Видимость = Истина;
	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(Кэш.ГлавноеОкно, "Таблица_РеестрДокументов.СтатусВГосСистеме").Видимость = Кэш.Парам.СтатусыВГосСистеме;
	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(Кэш.ГлавноеОкно, "Таблица_РеестрСобытий.СтатусВГосСистеме").Видимость = Кэш.Парам.СтатусыВГосСистеме;
	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(Кэш.ГлавноеОкно, "Таблица_РеестрСобытий.Комментарий").Видимость = Истина;
	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(Кэш.ГлавноеОкно, "Таблица_РеестрСобытий.Ответственный").Видимость = Истина;
	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(Кэш.ГлавноеОкно, "Таблица_РеестрСобытий.Вложения").Видимость = Истина;
	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(Кэш.ГлавноеОкно, "Таблица_РеестрДокументов.Расхождение").Видимость = Кэш.Парам.СтатусыВГосСистеме;
	МодульОбъектаКлиент().ПолучитьЭлементФормыОбработки(Кэш.ГлавноеОкно, "Таблица_РеестрСобытий.Расхождение").Видимость = Кэш.Парам.СтатусыВГосСистеме;	
	
	МассивРеквизитов = Новый Массив;
	МассивРеквизитов.Добавить("Заказчик");
	МассивРеквизитов.Добавить("Перевозчик");
	
	Кэш.ГлавноеОкно.НастроитьКолонкиФормы(Новый Структура("ИмяТаблицы, СтруктураПолей", "Таблица_РеестрСобытий", Новый Структура("КолонкиУдалить", МассивРеквизитов)));
КонецПроцедуры	

// Процедура устанавливает значения фильтра по-умолчанию для текущего раздела	
&НаКлиенте
Процедура ФильтрОчистить(Кэш) Экспорт
	ГлавноеОкно = Кэш.ГлавноеОкно;
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		ГлавноеОкно.ФильтрПериод = "За весь период";
	Иначе
		ГлавноеОкно.ФильтрПериод = "0";
	КонецЕсли;
	Если Кэш.ТипыПолейФильтра.Свойство("ФильтрОрганизация") Тогда
		ГлавноеОкно.ФильтрОрганизация = Кэш.ТипыПолейФильтра.ФильтрОрганизация.ПривестиЗначение();
	Иначе	
		ГлавноеОкно.ФильтрОрганизация = "";
	КонецЕсли;
	Если Кэш.ТипыПолейФильтра.Свойство("ФильтрКонтрагент") Тогда
		ГлавноеОкно.ФильтрКонтрагент = Кэш.ТипыПолейФильтра.ФильтрКонтрагент.ПривестиЗначение();
	Иначе	
		ГлавноеОкно.ФильтрКонтрагент = "";
	КонецЕсли;
	Если Кэш.ТипыПолейФильтра.Свойство("ФильтрОтветственный") Тогда
		ГлавноеОкно.ФильтрОтветственный = Кэш.ТипыПолейФильтра.ФильтрОтветственный.ПривестиЗначение();
	Иначе	
		ГлавноеОкно.ФильтрОтветственный = "";
	КонецЕсли;
	ГлавноеОкно.ФильтрДатаНач = "";
	ГлавноеОкно.ФильтрДатаКнц = "";
	ГлавноеОкно.ФильтрСостояние = ГлавноеОкно.СписокСостояний.НайтиПоИдентификатору(0).Значение;
	ГлавноеОкно.ФильтрТипыДокументов = Новый СписокЗначений;
	ГлавноеОкно.ФильтрКонтрагентПодключен = "";
	ГлавноеОкно.ФильтрКонтрагентСФилиалами = Ложь;
	ГлавноеОкно.ФильтрСтраница = 1;
	ГлавноеОкно.ФильтрМаска = "";
	//++ Бухов А. Фильтр по умолчанию 	
	Если Кэш.Ини.Конфигурация.Свойство("ФильтрПоУмолчанию") И  Кэш.Ини.Конфигурация.ФильтрПоУмолчанию.Свойство(Кэш.Текущий.ТипДок) Тогда 
		Попытка
			Ини = Кэш.ОбщиеФункции.ПолучитьДанныеДокумента1С(Кэш.Ини.Конфигурация.ФильтрПоУмолчанию[Кэш.Текущий.ТипДок],Неопределено,Кэш.КэшЗначенийИни, Кэш.Парам);  // alo Меркурий
			Для Каждого Элем Из Ини Цикл 
				Если нрег(Лев(Элем.Ключ, 6)) = "фильтр" Тогда
					ГлавноеОкно[Элем.Ключ] = Элем.Значение;
				КонецЕсли;
			КонецЦикла;
		Исключение
		КонецПопытки;
	КонецЕсли;
	//-- Бухов А. Фильтр по умолчанию
КонецПроцедуры

&НаКлиенте
Функция ПолучитьСтруктуруТаблицыСобытий(Кэш) Экспорт//При переходе в раздел задач, установить таблицу событий
	
	КолонкиИзменить	= Новый	Массив;
	Если Кэш.ПараметрыСистемы.Клиент.УправляемоеПриложение Тогда
		ДобавитьКИмениКолонки = "Таблица_РеестрСобытий";
		ПараметрЗаголовок = "Заголовок";
		ПутьККолонкам = "Элементы.Таблица_РеестрСобытий.ПодчиненныеЭлементы";
	Иначе
		ДобавитьКИмениКолонки = "";
		ПараметрЗаголовок = "ТекстШапки";
		ПутьККолонкам	= "ЭлементыФормы.Таблица_РеестрСобытий.Колонки";
	КонецЕсли;
	КолонкиИзменить.Добавить(Новый Структура("ПолноеИмяКолонки, ИмяКолонки, ПараметрыИзменить", ДобавитьКИмениКолонки + "Контрагент", "Контрагент", Новый Структура(ПараметрЗаголовок, "Контрагент")));
	КолонкиИзменить.Добавить(Новый Структура("ПолноеИмяКолонки, ИмяКолонки, ПараметрыИзменить", ДобавитьКИмениКолонки + "НашаОрганизация", "НашаОрганизация", Новый Структура(ПараметрЗаголовок, "Организация")));
	
	СтруктураОбновления	= Новый	Структура();
	СтруктураОбновления.Вставить("ИмяТаблицы",		"Таблица_РеестрСобытий");
	СтруктураОбновления.Вставить("СтруктураПолей",	Новый	Структура("КолонкиИзменить", КолонкиИзменить));
	СтруктураОбновления.Вставить("ПутьККолонкам",	ПутьККолонкам);
	
	Возврат	СтруктураОбновления;

КонецФункции

&НаКлиенте
Процедура ФильтрУстановитьВидимость(ФормаФильтра) Экспорт
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"ФильтрКонтрагентПодключен");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Ложь;
	КонецЕсли;
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"ФильтрОтветственный");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Ложь;
	КонецЕсли;
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"ФильтрТипыДокументов");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Истина;
	КонецЕсли;
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"ФильтрКонтрагентСФилиалами");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Истина;
	КонецЕсли;
	
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"НадписьКонтрагентПодключен");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Ложь;
	КонецЕсли;
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"НадписьОтветственный");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Ложь;
	КонецЕсли;
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"НадписьТипыДокументов");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Истина;
	КонецЕсли;
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"НадписьКонтрагент");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Истина;
	КонецЕсли;
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"НадписьОрганизация");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Истина;
	КонецЕсли;
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"ФильтрКонтрагент");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Истина;
	КонецЕсли;
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"ФильтрОрганизация");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Истина;
	КонецЕсли;
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра, "ФильтрСостояние");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Истина;
	КонецЕсли;	
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"НадписьНоменклатураКонтрагента");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Ложь;
	КонецЕсли;    
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"НадписьНоменклатура1С");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Ложь;
	КонецЕсли;   
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"НадписьКодКонтрагента");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Ложь;
	КонецЕсли;  
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"НадписьGTIN");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Ложь;
	КонецЕсли; 
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"ФильтрНаименованиеНоменклатуры");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Ложь;
	КонецЕсли;    
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"ФильтрНоменклатура1С");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Ложь;
	КонецЕсли;   
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"ФильтрКодКонтрагента");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Ложь;
	КонецЕсли;  
	ВыбранныйЭлемент = сбисЭлементФормы(ФормаФильтра,"ФильтрGTIN");
	Если Не ВыбранныйЭлемент = Неопределено Тогда
		ВыбранныйЭлемент.Видимость = Ложь;
	КонецЕсли;
КонецПроцедуры

// Процедура для заполнения списков выбора в фильтре. Восстанавливает последние установки фильтра раздела
// 
// Параметры:
//  Кэш  - Структура - Кэш обработки
//
&НаКлиенте
Процедура ПодготовитьФильтрРаздела(Кэш) Экспорт

	СписокСостояний = Новый СписокЗначений();
	СписокСостояний.Добавить("Все документы");
	СписокСостояний.Добавить("Требующие ответа");
	СписокСостояний.Добавить("Утвержденные");
	СписокСостояний.Добавить("Отклоненные");
	СписокСостояний.Добавить("Незакрепленные");
	СписокСостояний.Добавить("Удаленные");
	СписокСостояний.Добавить("Аннулированные");
	СписокСостояний.Добавить("Черновики");

	Кэш.ГлавноеОкно.СписокСостояний = СписокСостояний;
	//ГлавноеОкно.ФильтрСостояние = СписокСостояний.НайтиПоИдентификатору(0).Значение;
	Кэш.ГлавноеОкно.ФильтрОбновитьПанель();
	
КонецПроцедуры // ПодготовитьФильтрРаздела()
