
&НаКлиенте
Перем МестныйКэш Экспорт;//aa.uferov добавлена переменная на формы сопоставления номенклатуры. Для работы через внешний интерфейс, когда не удаётся найти главное окно с инициированным кэшем.

// функции для совместимости кода 
&НаКлиенте
Функция сбисПолучитьФорму(СбисИмяФормы)
	Возврат ВладелецФормы.сбисПолучитьФорму(СбисИмяФормы);
КонецФункции
///////////////////////////////

// Получает контрагента 1С по структуре Контрагента СБИС, вызывает функцию поиска номенклатуры на сервере 
&НаКлиенте
Функция НайтиНоменклатуруПоставщикаПоТабличнойЧасти(стрКонтрагент, знач мТаблДок, КаталогНастроек, Ини) Экспорт
	Если МестныйКэш = Неопределено Тогда
		МестныйКэш = сбисПолучитьФорму("ФормаГлавноеОкно").Кэш;
	КонецЕсли;
	Контрагент		= МестныйКэш.ОбщиеФункции.НайтиКонтрагентаИзДокументаСБИС(Ини.Конфигурация, стрКонтрагент,,,Истина);
	Если Контрагент = Ложь Тогда
		Сообщить("Сопоставление номенклатуры может сохраняться некорректно. Заполните Контрагента в справочнике. Если документ исходящий, то для корректной записи сопоставления номенклатуры необходимо в справочнике Контрагентов завести Нашу организацию.");
	КонецЕсли;
	СчетчикСтрок	= 0;
	СтрокиПоиска	= Новый Структура;
	Для Каждого СтрТабл Из мТаблДок Цикл
		СтрокаПоиска = Новый Структура("Контрагент",Контрагент);
		Если СтрТабл.Свойство("Название") Тогда
			СтрокаПоиска.Вставить("Название",		СтрТабл.Название);
		КонецЕсли;
		Если СтрТабл.Свойство("КодПокупателя") Тогда
			СтрокаПоиска.Вставить("КодПокупателя",	СтрТабл.КодПокупателя);
		КонецЕсли;
		Если СтрТабл.Свойство("Идентификатор") Тогда
			СтрокаПоиска.Вставить("Идентификатор",	СтрТабл.Идентификатор);
		КонецЕсли;
		Если Не ЗначениеЗаполнено(СтрокаПоиска) Тогда
			ВызватьИсключение("НайтиНоменклатуруПоставщикаПоТабличнойЧасти() Отсутствует название и идентификатор номенклатуры для поиска в строке №" + (СчетчикСтрок+1));
		КонецЕсли;
		СтрокиПоиска.Вставить("СтрТабл_"+Формат(СчетчикСтрок, "ЧН=0; ЧГ=0"),СтрокаПоиска);
		СчетчикСтрок = СчетчикСтрок + 1;
	КонецЦикла;
	
	Возврат НайтиНоменклатуруПоставщикаПоТабличнойЧастиНаСервере(СтрокиПоиска, Ини.Конфигурация);	
КонецФункции

&НаСервереБезКонтекста
Функция НайтиНоменклатуруПоставщикаПоТабличнойЧастиНаСервере(стрНоменклатураПоставщикаВсе, ИниКонфигурация) Экспорт
// ищет запись с определенной номенклатурой поставщика по реквизитам, указанным в файле настроек
// возвращает структуру с полями Номенклатура и Характеристика	
	Для Каждого стрНоменклатураПоставщика Из стрНоменклатураПоставщикаВсе Цикл
		Результат = НайтиНоменклатуруПоставщикаНаСервере(стрНоменклатураПоставщика.Значение, ИниКонфигурация);	
		стрНоменклатураПоставщика.Значение.Вставить("НоменклатураПоставщика",Результат);
	КонецЦикла;
	Возврат стрНоменклатураПоставщикаВсе; 
КонецФункции

&НаКлиенте
Функция НайтиНоменклатуруПоставщика(стрКонтрагент, знач стрНоменклатураПоставщика, КаталогНастроек, Ини) Экспорт
// получает контрагента 1С по структуре Контрагента СБИС, вызывает функцию поиска номенклатуры на сервере 
	Если МестныйКэш = Неопределено Тогда
		МестныйКэш = сбисПолучитьФорму("ФормаГлавноеОкно").Кэш;
	КонецЕсли;
	Контрагент = МестныйКэш.ОбщиеФункции.НайтиКонтрагентаИзДокументаСБИС(Ини.Конфигурация, стрКонтрагент);
	стрНоменклатураПоставщика.Вставить("Контрагент", Контрагент);
	Возврат НайтиНоменклатуруПоставщикаНаСервере(стрНоменклатураПоставщика, Ини.Конфигурация);	
КонецФункции

&НаКлиенте
Процедура УстановитьСоответствиеНоменклатуры(стрКонтрагент,знач стрНоменклатураПоставщика, КаталогНастроек, Ини) Экспорт
// Получает контрагента 1С по структуре Контрагента СБИС, вызывает процедуру установки соответствия номенклатуры на сервере 
	Если МестныйКэш = Неопределено Тогда
		МестныйКэш = сбисПолучитьФорму("ФормаГлавноеОкно").Кэш;
	КонецЕсли;
	Контрагент = МестныйКэш.ОбщиеФункции.НайтиКонтрагентаИзДокументаСБИС(Ини.Конфигурация, стрКонтрагент);
	стрНоменклатураПоставщика.Вставить("Контрагент", Контрагент);
	УстановитьСоответствиеНоменклатурыНаСервере( стрНоменклатураПоставщика, Ини.Конфигурация);
КонецПроцедуры

&НаСервереБезКонтекста
Функция НайтиНоменклатуруПоставщикаНаСервере(стрНоменклатураПоставщика, ИниКонфигурация) Экспорт
// ищет запись с определенной номенклатурой поставщика по реквизитам, указанным в файле настроек
// возвращает структуру с полями Номенклатура и Характеристика	
	НоменклатураПоставщика = ПолучитьНоменклатуруПоставщикаНаСервере(стрНоменклатураПоставщика, ИниКонфигурация);
	Результат = Новый Структура("Номенклатура, Характеристика");
	
	Если НоменклатураПоставщика<>Неопределено Тогда
		ИмяРеквизитаНоменклатуры = сред(ИниКонфигурация.НоменклатураПоставщиков_Номенклатура.Значение,Найти(ИниКонфигурация.НоменклатураПоставщиков_Номенклатура.Значение,".")+1);
		Если ЗначениеЗаполнено(НоменклатураПоставщика[ИмяРеквизитаНоменклатуры]) Тогда
			Результат.Номенклатура = НоменклатураПоставщика[ИмяРеквизитаНоменклатуры];	
			Если ИниКонфигурация.Свойство("НоменклатураПоставщиков_Характеристика") и ИниКонфигурация.НоменклатураПоставщиков_Характеристика.Значение<>"''" Тогда
				ИмяРеквизитаХарактеристики = сред(ИниКонфигурация.НоменклатураПоставщиков_Характеристика.Значение,Найти(ИниКонфигурация.НоменклатураПоставщиков_Характеристика.Значение,".")+1);
				Если ЗначениеЗаполнено(ИмяРеквизитаХарактеристики) и ЗначениеЗаполнено(НоменклатураПоставщика[ИмяРеквизитаХарактеристики]) Тогда
					Результат.Характеристика = НоменклатураПоставщика[ИмяРеквизитаХарактеристики];	
				КонецЕсли;
			КонецЕсли;
			Возврат Результат;
		Иначе
			Возврат Неопределено;
		КонецЕсли;		
	КонецЕсли;
	
	Возврат Неопределено;
КонецФункции
&НаСервереБезКонтекста
Функция ПолучитьНоменклатуруПоставщикаНаСервере(стрНоменклатураПоставщика, ИниКонфигурация) Экспорт
// получает запись справочника или регистра сведений номенклатуры поставщика по реквизитам, указанным в файле настроек	
	Если стрНоменклатураПоставщика.Свойство("КодПокупателя") 
			И ЗначениеЗаполнено(стрНоменклатураПоставщика.КодПокупателя) Тогда
		стрНоменклатураПоставщика.Вставить("Идентификатор", стрНоменклатураПоставщика.КодПокупателя);
	КонецЕсли;
	Если (Не стрНоменклатураПоставщика.Свойство("Идентификатор") или Не ЗначениеЗаполнено(стрНоменклатураПоставщика.Идентификатор))
			Или (стрНоменклатураПоставщика.Свойство("Идентификатор") и стрНоменклатураПоставщика.Идентификатор="-") Тогда 
        стрНоменклатураПоставщика.Вставить("Идентификатор", ?(стрНоменклатураПоставщика.Свойство("Название"),стрНоменклатураПоставщика.Название, ""));
    КонецЕсли;
	ЗнПер = ИниКонфигурация.НоменклатураПоставщиков.Значение;
	Если Найти(ЗнПер,"Справочник")=1 Тогда	// ссылка на справочник
		ИмяСпр=сред(ЗнПер,12);
		
		// ▼ ayan#bitrix2889 Добавление строк в документ 1С из обработки СБИС  КирилловПС  2023.07.12 ▼ Начало
		//НоменклатураПоставщиков = Справочники[ИмяСпр].СоздатьЭлемент(); //Не правильно
		// ▲ ayan#bitrix2889 Добавление строк в документ 1С из обработки СБИС  КирилловПС  2023.07.12 ▲ Конец
		
		Если ИниКонфигурация.НоменклатураПоставщиков.Свойство("Отбор") Тогда // Надо установить отбор
			Отбор = Новый Структура;
			Для Каждого Элемент Из ИниКонфигурация.НоменклатураПоставщиков.Отбор Цикл
				Отбор.Вставить(Элемент.Ключ,ПолучитьЗначениеИзСтруктуры(ИниКонфигурация[Элемент.Значение].Данные, стрНоменклатураПоставщика));
			КонецЦикла;
			Если Отбор.Количество()>0 Тогда
				Запрос = Новый Запрос;
				Запрос.Текст="ВЫБРАТЬ
					|Спр.Ссылка
					|ИЗ
					|   Справочник."+ИмяСпр+" КАК Спр
					|ГДЕ
					| ";
				Для Каждого Элемент Из Отбор Цикл
					ЗначениеЭлемента = Элемент.Значение;
					Если Метаданные.Справочники[ИмяСпр].Реквизиты.Найти(Элемент.Ключ)<>Неопределено Тогда
						ЗначениеЭлемента = Метаданные.Справочники[ИмяСпр].Реквизиты[Элемент.Ключ].Тип.ПривестиЗначение(Элемент.Значение);
					КонецЕсли;    
					Запрос.УстановитьПараметр(Элемент.Ключ, ЗначениеЭлемента);
					Запрос.Текст=Запрос.Текст+"Спр."+Элемент.Ключ+"=&"+Элемент.Ключ+" И ";
				КонецЦикла;
				Запрос.Текст = Запрос.Текст+ "НЕ Спр.ПометкаУдаления";
				Выборка = Запрос.Выполнить().Выбрать();
				Если Выборка.Количество()>0 Тогда
					Пока Выборка.Следующий() Цикл
						НоменклатураПоставщиков = Выборка.Ссылка.ПолучитьОбъект();
						Возврат НоменклатураПоставщиков;
					КонецЦикла;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		// ▼ ayan#bitrix2889 Добавление строк в документ 1С из обработки СБИС  КирилловПС  2023.07.12 ▼ Начало
		//НоменклатураПоставщиков = ПредопределенноеЗначение("Справочник." + ИмяСпр + ".ПустаяСсылка");
		НоменклатураПоставщиков = Справочники[ИмяСпр].СоздатьЭлемент(); //Не оптимально, хоть так
		// ▲ ayan#bitrix2889 Добавление строк в документ 1С из обработки СБИС  КирилловПС  2023.07.12 ▲ Конец 
		
		Возврат НоменклатураПоставщиков;
	Иначе
		// надо как-то обругаться, что неверно настройки указаны
	КонецЕсли;
КонецФункции
&НаСервереБезКонтекста
Процедура УстановитьСоответствиеНоменклатурыНаСервере( стрНоменклатураПоставщика, ИниКонфигурация) Экспорт
// Процедура устанавливает/удаляет соответствие номенклатуры	
	Если стрНоменклатураПоставщика.Свойство("КодПокупателя")
			И ЗначениеЗаполнено(стрНоменклатураПоставщика.КодПокупателя) Тогда
		стрНоменклатураПоставщика.Идентификатор = стрНоменклатураПоставщика.КодПокупателя;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(стрНоменклатураПоставщика.Идентификатор) Или стрНоменклатураПоставщика.Идентификатор = "-"  Тогда
		стрНоменклатураПоставщика.Идентификатор = стрНоменклатураПоставщика.Название;
	КонецЕсли;
	
	НоменклатураПоставщиков = ПолучитьНоменклатуруПоставщикаНаСервере( стрНоменклатураПоставщика, ИниКонфигурация);
		
	Если НоменклатураПоставщиков<>Неопределено Тогда			
		Если ЗначениеЗаполнено(стрНоменклатураПоставщика.Номенклатура) Тогда
			ЗаполнитьРеквизиты(стрНоменклатураПоставщика,"НоменклатураПоставщиков",ИниКонфигурация,НоменклатураПоставщиков);
			НоменклатураПоставщиков.Записать();
		Иначе
			НоменклатураПоставщиков.Удалить();
		КонецЕсли;
	КонецЕсли;	
КонецПроцедуры
&НаСервереБезКонтекста
Функция ЗаполнитьРеквизиты(стрНоменклатураПоставщика,Раздел,Ини,Объект1С) Экспорт
// Функция используется при заполнении реквизитов номенклатуры поставщика по файлу настроек
	Длина = СтрДлина(Раздел);
	Для Каждого Параметр Из ини Цикл
		Если  Лев(Параметр.Ключ,Длина+1)=Раздел+"_" Тогда
			ИмяРеквизита=сред(Параметр.Значение.Значение,Найти(Параметр.Значение.Значение,".")+1);
			Попытка
				Объект1С[ИмяРеквизита]=ПолучитьЗначениеИзСтруктуры(Параметр.Значение.Данные, стрНоменклатураПоставщика);
			Исключение
			КонецПопытки;
		КонецЕсли;
	КонецЦикла;
КонецФункции
&НаСервереБезКонтекста
Функция ПолучитьЗначениеИзСтруктуры(Путь, знач стрНоменклатураПоставщика)
	ПутьКДанным = РазбитьСтрокуВМассив(Путь, ".");
	ЗначениеРеквизита = стрНоменклатураПоставщика;	
	Для Каждого Узел Из ПутьКДанным Цикл
		Попытка
			ЗначениеРеквизита = ЗначениеРеквизита[Узел];
		Исключение
			Возврат Неопределено;
		КонецПопытки;
	КонецЦикла;
	Возврат ЗначениеРеквизита;
КонецФункции
&НаСервереБезКонтекста
функция РазбитьСтрокуВМассив(знач Строка, Разделитель) Экспорт
	МассивЭлементов = Новый Массив();
	Если Строка<>"" Тогда
		ЕстьРазделитель = Истина;
		Пока ЕстьРазделитель И Строка<>"" И Разделитель<>"" Цикл
			Если Найти(Строка,Разделитель)=0 Тогда
				Прервать;
			КонецЕсли;
			Элемент = Сред(Строка,1,Найти(Строка,Разделитель)-1);
			МассивЭлементов.Добавить(Элемент);
			Строка = Сред(Строка,Найти(Строка,Разделитель)+1);
		КонецЦикла;
		МассивЭлементов.Добавить(Строка);
	КонецЕсли;
	Возврат МассивЭлементов;
КонецФункции
&НаКлиенте
Функция ПолучитьИдентификаторНоменклатурыПоставщика(стрКонтрагент, стрНоменклатура, КаталогНастроек, Ини) Экспорт
// Процедура ищет идентификатор номенклатуры контрагента	
	Если МестныйКэш = Неопределено Тогда
		МестныйКэш = сбисПолучитьФорму("ФормаГлавноеОкно").Кэш;
	КонецЕсли;
	Контрагент = МестныйКэш.ОбщиеФункции.НайтиКонтрагентаИзДокументаСБИС(Ини.Конфигурация, стрКонтрагент, , Истина, , Истина);
	стрНоменклатура.Вставить("Контрагент", Контрагент);
	Возврат сбисПолучитьРеквизитНоменклатурыПоставщикаНаСервере(стрНоменклатура, "Идентификатор", Ини.Конфигурация);
КонецФункции
&НаКлиенте
Функция сбисПолучитьРеквизитНоменклатурыПоставщика(стрКонтрагент, стрНоменклатура, ИмяРеквизита, КаталогНастроек, Ини) Экспорт
// Процедура ищет реквизит номенклатуры контрагента	
	Если МестныйКэш = Неопределено Тогда
		МестныйКэш = сбисПолучитьФорму("ФормаГлавноеОкно").Кэш;
	КонецЕсли;
	Контрагент = МестныйКэш.ОбщиеФункции.НайтиКонтрагентаИзДокументаСБИС(Ини.Конфигурация, стрКонтрагент);
	стрНоменклатура.Вставить("Контрагент", Контрагент);
	Возврат сбисПолучитьРеквизитНоменклатурыПоставщикаНаСервере(стрНоменклатура, ИмяРеквизита, Ини.Конфигурация);
КонецФункции
Функция сбисПолучитьРеквизитНоменклатурыПоставщикаНаСервере(стрНоменклатура, ИмяРеквизита, ИниКонфигурация) Экспорт
// Процедура ищет реквизит номенклатуры контрагента	 (используется для получения идентификатора, штрихкода номенклатуры контрагента)
	ЗнПер = ИниКонфигурация.НоменклатураПоставщиков.Значение;
	Если Найти(ЗнПер,"Справочник")=1 Тогда	// ссылка на справочник
		ИмяСпр=сред(ЗнПер,12);
		// Если нужны не контрагенты, а партнёры!!!
		Путь = ИниКонфигурация.НоменклатураПоставщиков_Контрагент.Данные;
		Если Найти(Путь, ".") И ТипЗнч(стрНоменклатура.Контрагент) = Тип("Массив") И стрНоменклатура.Контрагент.Количество() Тогда
			ТЗ = Новый ТаблицаЗначений;
			МассивТипов = Новый Массив;
			//МассивТипов.Добавить("Справочники." + Метаданные.НайтиПоТипу(ТипЗнч(стрНоменклатура.Контрагент[0])).Имя);
			МассивТипов.Добавить(ТипЗнч(стрНоменклатура.Контрагент[0]));
			ТЗ.Колонки.Добавить("сКонтрагент", Новый ОписаниеТипов(МассивТипов));
			Для Каждого ЭлМассива Из стрНоменклатура.Контрагент Цикл
				ТЗ.Добавить().сКонтрагент = ЭлМассива;
			КонецЦикла;
			Запрос = Новый Запрос("ВЫБРАТЬ
			                      |	ТЗ.сКонтрагент
								  |ПОМЕСТИТЬ ВТ
			                      |ИЗ
			                      |	&ТЗ КАК ТЗ;
								  |
								  |ВЫБРАТЬ РАЗЛИЧНЫЕ
								  | ВТ.сКонтрагент." + Сред(Путь, Найти(Путь, ".") + 1) + " КАК сПартнер
								  |ИЗ
								  | ВТ КАК ВТ");
			Запрос.УстановитьПараметр("ТЗ", ТЗ);
			Партнеры = Новый Структура("Контрагент", Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("сПартнер"));
			Путь = Лев(Путь, Найти(Путь, ".") - 1);
		Иначе
			Партнеры = Новый Структура("Контрагент", стрНоменклатура.Контрагент);
		КонецЕсли;
		Контрагент = ПолучитьЗначениеИзСтруктуры(Путь, Партнеры);
		ИмяРеквизитаКонтрагента = Сред(ИниКонфигурация.НоменклатураПоставщиков_Контрагент.Значение, Найти(ИниКонфигурация.НоменклатураПоставщиков_Контрагент.Значение,".")+1);
		ИмяРеквизитаНоменклатуры = Сред(ИниКонфигурация.НоменклатураПоставщиков_Номенклатура.Значение, Найти(ИниКонфигурация.НоменклатураПоставщиков_Номенклатура.Значение,".")+1);
		ИмяРеквизитаВИни = "НоменклатураПоставщиков_"+ИмяРеквизита;
		Если ИниКонфигурация.Свойство(ИмяРеквизитаВИни) Тогда
			ИмяРеквизитаВБазе = Сред(ИниКонфигурация[ИмяРеквизитаВИни].Значение, Найти(ИниКонфигурация[ИмяРеквизитаВИни].Значение,".")+1);
		Иначе
			ИмяРеквизитаВБазе = ИмяРеквизита 
		КонецЕсли;
		
		Запрос = Новый Запрос;
		Запрос.Текст="ВЫБРАТЬ
			|Спр."+ИмяРеквизитаВБазе+"
			|ИЗ
			|   Справочник."+ИмяСпр+" КАК Спр
			|ГДЕ
			| Спр."+ИмяРеквизитаКонтрагента+" В (&Контрагент)
			| И Спр."+ИмяРеквизитаНоменклатуры+"=&Номенклатура
			| И НЕ Спр.ПометкаУдаления";
		
		Запрос.УстановитьПараметр("Контрагент", Контрагент);
		Запрос.УстановитьПараметр("Номенклатура", стрНоменклатура.Номенклатура);
		
		ТекстЗапросаБезХарактеристики = Запрос.Текст;
		
		Если ИниКонфигурация.Свойство("НоменклатураПоставщиков_Характеристика") и ИниКонфигурация.НоменклатураПоставщиков_Характеристика.Значение<>"''" Тогда
			ИмяРеквизитаХарактеристики = Сред(ИниКонфигурация.НоменклатураПоставщиков_Характеристика.Значение, Найти(ИниКонфигурация.НоменклатураПоставщиков_Характеристика.Значение,".")+1);	
			Если ЗначениеЗаполнено(стрНоменклатура.Характеристика) Тогда
				Запрос.Текст = Запрос.Текст + " И Спр."+ИмяРеквизитаХарактеристики+"=&Характеристика";
				Запрос.УстановитьПараметр("Характеристика", стрНоменклатура.Характеристика);
			КонецЕсли;
		КонецЕсли;
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
				Возврат Выборка[ИмяРеквизитаВБазе];
		Иначе // Если не нашли по связке Номенклатура+Характеристика, ищем просто по номеклатуре, задача №1185740228
			
			ЗапросБезХарактеристики = Новый Запрос;
			ЗапросБезХарактеристики.Текст = ТекстЗапросаБезХарактеристики;
			ЗапросБезХарактеристики.Параметры.Вставить("Контрагент", Контрагент);
			ЗапросБезХарактеристики.Параметры.Вставить("Номенклатура", стрНоменклатура.Номенклатура);
			
			Выборка = ЗапросБезХарактеристики.Выполнить().Выбрать();
			
			Если Выборка.Следующий() Тогда
				Возврат Выборка[ИмяРеквизитаВБазе];
			КонецЕсли;

		КонецЕсли;
	КонецЕсли;
	Возврат "";
КонецФункции
