
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

#Область include_core2_vo2_Файл_АктСвер_301_ПолучитьТабличнуюЧастьДокумента1С_ВнещнийВызов


// Функция формирует структуру выгружаемого файла и добавляет его в состав пакета
&НаКлиенте
Функция ПолучитьДанныеИзДокумента1С(Кэш,Контекст) Экспорт
		
	СбисИмяФункции = "Файл_АктСвер_3_01.ПолучитьШапкуИзДокумента1С";       
	
	Попытка		
		
		Контекст.Вставить("ТаблДок",Новый Структура());
		Контекст.ТаблДок.Вставить("ИтогТабл",Новый Массив);
		Контекст.ТаблДок.Вставить("СтрТабл",Новый Массив);
		
		ПолучитьТабличнуюЧастьДокумента1С(Кэш,Контекст);
		//Если Контекст.ТаблДок.СтрТабл.Количество() = 0 Тогда//нет такого документа
		//	Возврат Истина;
		//КонецЕсли;		
		
		Док  = Новый Структура;
		Док.Вставить("Файл",Новый Структура);
		Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Файл",Контекст.ФайлДанные,Док.Файл);
		Док.Файл.Вставить("Документ",Новый Структура);
		Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Документ",Контекст.ФайлДанные,Док.Файл.Документ);
		
		СписокУзлов = Новый СписокЗначений;
		Период  = Новый Структура;
		Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Период",Контекст.ФайлДанные, Период);
		СписокУзлов.Добавить(Период, "Период");
		//Док.Файл.Документ.Вставить("Период",Новый Структура);
		//ЗаполнитьАтрибуты(Кэш,"Период",Контекст.ФайлДанные,Док.Файл.Документ.Период);
		ЗапретРедакций = Ложь;
		ОтправительРоль=Кэш.ОбщиеФункции.РассчитатьЗначение("Отправитель_Роль", Контекст.ФайлДанные, Кэш);
		ПолучательРоль=Кэш.ОбщиеФункции.РассчитатьЗначение("Получатель_Роль", Контекст.ФайлДанные, Кэш);
		
		Если Не ЗначениеЗаполнено(ОтправительРоль) Тогда   
			
			ОтправительРоль = "Отправитель";           
			
		КонецЕсли;                   
		
		Если Не ЗначениеЗаполнено(ПолучательРоль) Тогда  
			
			ПолучательРоль = "Получатель";         
			
		КонецЕсли;                  
		
		Для Каждого Параметр Из Контекст.ФайлДанные.мСторона Цикл
			
			Если Параметр.Значение.Свойство("Роль") Тогда    
				
				Роль = Кэш.ОбщиеФункции.РассчитатьЗначение("Роль",Параметр.Значение,Кэш);      
				
			Иначе                        
				
				Роль = Кэш.ОбщиеФункции.РассчитатьЗначение("Сторона_Роль",Параметр.Значение,Кэш);      
				
			КонецЕсли;    
			
			Если Роль = ОтправительРоль Тогда 
				
				Сертификат = Кэш.ОбщиеФункции.РассчитатьЗначение("Сертификат",Параметр.Значение,Кэш); 
				
			КонецЕсли;      
			
			Если Роль = ПолучательРоль Тогда   
				
				ЗапретРедакций = Кэш.ОбщиеФункции.РассчитатьЗначение("ЗапретРедакций",Параметр.Значение,Кэш); 
				
			КонецЕсли;    
			
			Сторона = Кэш.ОбщиеФункции.ПолучитьСторону(Кэш,Параметр.Значение);     //?????  
			
			Если Сторона<>Неопределено Тогда     
				
				СписокУзлов.Добавить(Сторона, Роль);
				
			КонецЕсли;  
			
		КонецЦикла; 
		
		//Сортируем узлы по алфавиту
		СписокУзлов.СортироватьПоПредставлению(); 
		
		Для Сч = 0 по СписокУзлов.Количество()-1 Цикл
			
			Док.Файл.Документ.Вставить(СписокУзлов.Получить(Сч).Представление, СписокУзлов.Получить(Сч).Значение); 
			
		КонецЦикла;
		
		Если Не Док.Файл.Документ.Свойство(ПолучательРоль) Тогда 
			
			СбисДетализация = "Не удалось определить ИНН получателя документа " + Строка(Контекст.Документ);
			МодульОбъектаКлиент().ВызватьСбисИсключение(721, СбисИмяФункции,,, СбисДетализация);
			
		КонецЕсли;   
		
		Если Не Док.Файл.Документ.Свойство(ОтправительРоль) Тогда
			
			СбисДетализация = "Не удалось определить ИНН отправителя документа " + Строка(Контекст.Документ);
			МодульОбъектаКлиент().ВызватьСбисИсключение(721, СбисИмяФункции,,, СбисДетализация);
			
		КонецЕсли;      
		
		Отправитель = Кэш.ОбщиеФункции.сбисСкопироватьОбъектНаКлиенте(Док.Файл.Документ[ОтправительРоль]); 
		Получатель = Кэш.ОбщиеФункции.сбисСкопироватьОбъектНаКлиенте(Док.Файл.Документ[ПолучательРоль]);
		
		Если ЗапретРедакций = Истина Тогда  
			
			Получатель.Вставить("ЗапретРедакций", Истина);	
			
		КонецЕсли;
		
		Если Контекст.ФайлДанные.Свойство("мПараметр") Тогда 
			
			Док.Файл.Документ.Вставить("Параметр",Новый Массив); 
			
			Для Каждого Элемент Из Контекст.ФайлДанные.мПараметр Цикл
				
				Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Контекст.ФайлДанные,Элемент.Значение);
				Параметр = Новый Структура();
				Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Параметр",Контекст.ФайлДанные,Параметр);
				Док.Файл.Документ.Параметр.Добавить(Параметр); 
				
			КонецЦикла;
			
		КонецЕсли;
		
		ОтветственныйСтруктура = Кэш.ОбщиеФункции.ПолучитьСтруктуруОтветственного(Кэш, Контекст);
		ПодразделениеСтруктура = Кэш.ОбщиеФункции.ПолучитьСтруктуруПодразделения(Кэш, Контекст);
		РегламентСтруктура = Кэш.ОбщиеФункции.ПолучитьСтруктуруРегламента(Кэш, Контекст);
		ОснованияМассив = Кэш.ОбщиеФункции.ПолучитьМассивОснований(Кэш, Контекст);  
		СвязанныеДокументы1С = Кэш.ОбщиеФункции.сбисПолучитьСвязанныеДокументы1С(Кэш, Контекст);
		ДатаВложения = ?(Док.Файл.Документ.Свойство("Дата"), Док.Файл.Документ.Дата, "");
		НомерВложения = ?(Док.Файл.Документ.Свойство("Номер"), Док.Файл.Документ.Номер, "");
		СуммаВложения = Формат(0, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
		НазваниеВложения = ?(Док.Файл.Документ.Свойство("Название"), Док.Файл.Документ.Название + " № " + НомерВложения + " от " + ДатаВложения, "");
		Тип = Кэш.ОбщиеФункции.РассчитатьЗначение("Вложение_Тип", Контекст.ФайлДанные,Кэш);
		ПодТип = Кэш.ОбщиеФункции.РассчитатьЗначение("Вложение_ПодТип", Контекст.ФайлДанные,Кэш);
		ВерсияФормата = Кэш.ОбщиеФункции.РассчитатьЗначение("Вложение_ВерсияФормата", Контекст.ФайлДанные,Кэш);
		ПодВерсияФормата = Кэш.ОбщиеФункции.РассчитатьЗначение("Вложение_ПодВерсияФормата", Контекст.ФайлДанные,Кэш);
		Примечание = Кэш.ОбщиеФункции.РассчитатьЗначение("Примечание", Контекст.ФайлДанные,Кэш);
		
		Док.Файл.Документ.Вставить("ТаблДок",Контекст.ТаблДок);
		
		Вложение = Новый Структура;
		Вложение.Вставить("СтруктураДокумента",	Док);
		Вложение.Вставить("Отправитель",		Отправитель);
		Вложение.Вставить("Получатель",			Получатель);
		Вложение.Вставить("Ответственный",		ОтветственныйСтруктура);
		Вложение.Вставить("Подразделение",		ПодразделениеСтруктура);
		Вложение.Вставить("Регламент",			РегламентСтруктура);
		Вложение.Вставить("ДокументОснование",	ОснованияМассив);
		Вложение.Вставить("Документ1С",			Контекст.Документ);
		Вложение.Вставить("Название",			НазваниеВложения);
		Вложение.Вставить("Тип",				Тип);
		Вложение.Вставить("ПодТип",				ПодТип);
		Вложение.Вставить("ВерсияФормата",		ВерсияФормата);
		Вложение.Вставить("ПодВерсияФормата",	ПодВерсияФормата);
		Вложение.Вставить("Дата",				ДатаВложения);
		Вложение.Вставить("Номер",				НомерВложения);
		Вложение.Вставить("Сумма",				СуммаВложения);
		
		Если ЗначениеЗаполнено(Примечание) Тогда 
			
			Вложение.Вставить("Примечание",Примечание);	
			
		КонецЕсли;     
		
		Если ЗначениеЗаполнено(Сертификат) Тогда
			
			Вложение.Вставить("Сертификат",Сертификат);	 
			
		КонецЕсли;                                 
		
		Если ЗначениеЗаполнено(СвязанныеДокументы1С) Тогда   
			
			СвязанныеДокументы1С.Вставить(0, Контекст.Документ);
			Вложение.Вставить("Документы1С",СвязанныеДокументы1С);
			
		КонецЕсли;
		
		ДопПараметры = Новый Структура("ГрязныйИни, ПолучательРоль, ОтправительРоль", Контекст.ФайлДанные, ПолучательРоль, ОтправительРоль);
		МодульОбъектаКлиент().ПропатчитьФайлВложенияСБИС(Вложение, ДопПараметры);
		
		Контекст.СоставПакета.Вложение.Добавить(Вложение);
		
		СбисОсновнаяФорма = "Файл_" + Контекст.ФайлДанные.Файл_Формат + "_" + СтрЗаменить(СтрЗаменить(Контекст.ФайлДанные.Файл_ВерсияФормата, ".", "_" ), " ", "");
		фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("сбисПослеФормированияДокумента", СбисОсновнаяФорма, "Файл_Шаблон", Кэш);
		
		Если фрм <> Ложь Тогда
			
			фрм.сбисПослеФормированияДокумента(Док, Кэш, Контекст);	
			Вложение.СтруктураДокумента = Док; // на случай, если Док поменялся в функции сбисПослеФормированияДокумента
			
		КонецЕсли;

		Возврат Истина;
		
	Исключение  
		
		ИсключениеФормирования = МодульОбъектаКлиент().НовыйСбисИсключение(ИнформацияОбОшибке(), СбисИмяФункции);
		Контекст.СоставПакета.Вставить("Ошибка", ИсключениеФормирования);
		
		Возврат Ложь;     
		
	КонецПопытки;    
	
КонецФункции

// Функция формирует структуру табличной части файла	
&НаКлиенте
Функция ПолучитьТабличнуюЧастьДокумента1С(Кэш, Контекст) Экспорт
	
	Перем ДанныеДокумента, Остатки;

	ВременныйКонтекст = Новый Структура;
	Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(ВременныйКонтекст, Контекст);
	ВременныйКонтекст.Вставить("СписокДоговоров", Новый СписокЗначений);
	
	Для Каждого Параметр Из Контекст.ФайлДанные.мТаблДок Цикл
		
		Если ВременныйКонтекст.Свойство("ВложениеКонтрагента") Тогда
			
			фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ОбработчикТабличногоДокумента","Файл_АктСверПолуч_3_01","", Кэш);
			фрм.ОбработчикТабличногоДокумента(Кэш, ВременныйКонтекст, Параметр);
			
		Иначе                           
			
			ОбработчикТабличногоДокумента(Кэш, ВременныйКонтекст, Параметр);	
			
		КонецЕсли;			   
		
	КонецЦикла;
	
	ЗаполнитьЗначенияСвойств(Контекст, ВременныйКонтекст);
	
КонецФункции	 

&НаКлиенте
Процедура ОбработчикТабличногоДокумента(Кэш, Контекст, Параметр) Экспорт

	ИтогиОснования = Новый Структура;
	ОбщиеИтоги = Новый Структура("Отправитель");
	
	Если Контекст.ТаблДок.ИтогТабл.Количество() >= 3
		И Контекст.ТаблДок.ИтогТабл[1].Тип = "Обороты"
		И Контекст.ТаблДок.ИтогТабл[1].Раздел = "Отправитель" Тогда
		
		ОбщиеИтоги.Отправитель = Новый Структура("ИтогДебет, ИтогКредит", Число(Контекст.ТаблДок.ИтогТабл[1].Дебет), Число(Контекст.ТаблДок.ИтогТабл[1].Кредит));
		
	Иначе 
		
		ОбщиеИтоги.Отправитель = Новый Структура("ИтогДебет, ИтогКредит", 0, 0);
		
	КонецЕсли;
	
	Если ТипЗнч(Параметр.Значение) = Тип("Массив") Тогда
		
		ТабЧастьДокумента = Параметр.Значение;
		
	Иначе  
		
		Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(Контекст.ФайлДанные, Параметр.Значение);
		//В случае, если получаем данные из документа через Узел ДанныеПоВзаиморасчетам, то функция/запрос должны вернуть структуру с полями ТабЧастьДокумента, НачальныйОстаток
		//Иначе будет посчитано старым алгоритмом, с обращением к узлам ОстатокНаНачало, ТаблДок
		ДанныеДокумента = Кэш.ОбщиеФункции.РассчитатьЗначение("ДанныеПоВзаиморасчетам", Контекст.ФайлДанные, Кэш);
		
		Если ДанныеДокумента = Неопределено Тогда         
			
			ТабЧастьДокумента = Кэш.ОбщиеФункции.РассчитатьЗначение("ТаблДок", Контекст.ФайлДанные, Кэш);  
			
		Иначе                            
			
			ТабЧастьДокумента = ДанныеДокумента.ТабЧастьДокумента;
			ОстаткиНачало = ДанныеДокумента.Остатки;        
			
		КонецЕсли;        
		
	КонецЕсли;  
	
	СальдоПоДоговорам = Кэш.ОбщиеФункции.РассчитатьЗначение("СальдоПоДоговорам", Контекст.ФайлДанные, Кэш);
	
	Для Каждого Стр Из ТабЧастьДокумента Цикл
		
		Если Число(Стр.ТаблДок_Кредит) + Число(Стр.ТаблДок_Дебет) = 0 Тогда 
			
			Продолжить;   
			
		КонецЕсли;    
		
		ДопПараметрыОбработки = Новый Структура;
		ДопПараметрыОбработки.Вставить("Кэш",				Кэш);
		ДопПараметрыОбработки.Вставить("Контекст",			Контекст);
		ДопПараметрыОбработки.Вставить("ИтогиОснования",	ИтогиОснования);
		ДопПараметрыОбработки.Вставить("СальдоПоДоговорам",	СальдоПоДоговорам);
		ДопПараметрыОбработки.Вставить("ОбщиеИтоги",		ОбщиеИтоги);
		
		ОбработатьДокумент(Стр, ДопПараметрыОбработки);
		
	КонецЦикла;	
	
	// Пологаем, что договоры приходят уже с точным сальдо за весь период
	// независимо от количество ТаблДок с одним разделом - Отправитель:
	// т.е. складывать по разным ТаблДок не нужно.
	//
	// Сальдо по документу тоже приходит по разово. Складывать по разным ТаблДок не нужно
	
	Для Каждого Элемент Из ОбщиеИтоги Цикл
		
		СмещениеПоРазделу = ?(Элемент.Ключ = "Отправитель", 0, 3);
		
		//Заполним начальное сальдо, если ранее не заполняли                       
		Если Контекст.ТаблДок.ИтогТабл.Количество() > СмещениеПоРазделу
			И Контекст.ТаблДок.ИтогТабл[0 + СмещениеПоРазделу].Раздел = Элемент.Ключ
			И Контекст.ТаблДок.ИтогТабл[0 + СмещениеПоРазделу].Тип = "Сальдо начальное" Тогда
			
			НачСальдо = Контекст.ТаблДок.ИтогТабл[0];
			
		Иначе 
			
			НачСальдо = ЗаполнитьИтоги_НачальноеСальдо(Кэш, Контекст, ОстаткиНачало, Элемент);
			
		КонецЕсли;
		
		//Заполним итоги по оборотам
		ЗаполнитьИтоги_Обороты(Кэш, Контекст, ИтогиОснования, Элемент);
		
		//Рассчитаем и заполним конечное сальдо
		Если Контекст.ТаблДок.ИтогТабл.Количество() >= 3 + СмещениеПоРазделу
			И Контекст.ТаблДок.ИтогТабл[2 + СмещениеПоРазделу].Раздел = Элемент.Ключ
			И Контекст.ТаблДок.ИтогТабл[2 + СмещениеПоРазделу].Тип = "Сальдо конечное" Тогда
			
			ЗаполнитьИтоги_КонечноеСальдо(Кэш, Контекст, НачСальдо, Элемент);
			
		Иначе 
			
			ЗаполнитьИтоги_КонечноеСальдо(Кэш, Контекст, НачСальдо, Элемент); 
			
		КонецЕсли;
		
	КонецЦикла;     
	
КонецПроцедуры	 


#КонецОбласти

#Область include_core2_vo2_Файл_АктСвер_301_ПолучитьТабличнуюЧастьДокумента1С_Прочее

// Процедура заполениет данные по договору
//
// Параметры:
//  СтрокаТаблДок		 - Структура	 - Строка мТаблДок, сформированная в ини
//  ПараметрОснование	 - Структура	 - Строка мОснование, сформаированная в ини
//  ДопПараметры		 - Структура	 - Состоит из
//		Кэш - Структура - Кэш обработки
//		Контекст - Структура - Контекст заполнения структуры документа
//		ИтогиОснования - Структура - Сальдо и обороты по основаниям
//		НоваяСтрока - Структура - Строка, формируемая для итогового документа
//		СальдоПоДоговорам - Структура - Сальдо по догворам
//
&НаКлиенте
Процедура ОбработатьДоговор(СтрокаТаблДок, ПараметрОснование, ДопПараметры)
	
	Кэш					= ДопПараметры.Кэш;
	Контекст			= ДопПараметры.Контекст;
	ИтогиОснования		= ДопПараметры.ИтогиОснования;
	НоваяСтрока			= ДопПараметры.НоваяСтрока;
	СальдоПоДоговорам	= ДопПараметры.СальдоПоДоговорам;

	Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(СтрокаТаблДок, ПараметрОснование.Значение);
	Основание = Новый Структура();
	Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Основание", СтрокаТаблДок, Основание);
	НоваяСтрока.Вставить("Основание", Основание);
	
	Если СтрокаТаблДок.Основание = Неопределено Тогда 
		УнИдентификатор = "Д00000000000000000000000000000000";
	Иначе
		УнИдентификатор = СтрЗаменить("Д" + СтрокаТаблДок.Основание.УникальныйИдентификатор(), "-", "");
	КонецЕсли;
	
	Если не ИтогиОснования.Свойство(СтрокаТаблДок.ТаблДок_Раздел) Тогда
		
		ИтогиОснования.Вставить(СтрокаТаблДок.ТаблДок_Раздел, Новый Структура);
		
	КонецЕсли; 
	
	Если не ИтогиОснования[СтрокаТаблДок.ТаблДок_Раздел].Свойство(УнИдентификатор) Тогда
		
		УзелОснования = Новый Структура;
		Кэш.ГлавноеОкно.сбисПолучитьФорму("РаботаСдокументами1С").сбисСкопироватьСтруктуру(УзелОснования, Основание);
		
		ОписаниеОСнования = Новый Структура;
		ОписаниеОСнования.Вставить("Основание",			СтрокаТаблДок.Основание);
		ОписаниеОСнования.Вставить("УзелОснования",		УзелОснования);
		ОписаниеОСнования.Вставить("Дебет",				0);
		ОписаниеОСнования.Вставить("Кредит",			0);
		ОписаниеОСнования.Вставить("НачальноеСальдоДт",	0);
		ОписаниеОСнования.Вставить("НачальноеСальдоКт",	0);
		ОписаниеОСнования.Вставить("КонечноеСальдоДт",	0);
		ОписаниеОСнования.Вставить("КонечноеСальдоКт",	0);
		
		ИтогиОснования[СтрокаТаблДок.ТаблДок_Раздел].Вставить(УнИдентификатор, ОписаниеОСнования);
		
	КонецЕсли;
		
	ИтогиОснования[СтрокаТаблДок.ТаблДок_Раздел][УнИдентификатор].Дебет = ИтогиОснования[СтрокаТаблДок.ТаблДок_Раздел][УнИдентификатор].Дебет + НоваяСтрока.Дебет;
	ИтогиОснования[СтрокаТаблДок.ТаблДок_Раздел][УнИдентификатор].Кредит = ИтогиОснования[СтрокаТаблДок.ТаблДок_Раздел][УнИдентификатор].Кредит + НоваяСтрока.Кредит;
	
	Если Контекст.ФайлДанные.Свойство("ИспользоватьНовыйФорматАктаСверки")	
		И Контекст.ФайлДанные.ИспользоватьНовыйФорматАктаСверки
		И ЗначениеЗаполнено(СальдоПоДоговорам) Тогда
		
		ТекДоговор = СтрокаТаблДок.мОснование.Договор.Основание;
		
		Для Каждого СальдоПоДоговору Из СальдоПоДоговорам Цикл 
			
			Если ТекДоговор = СальдоПоДоговору.Договор Тогда  
				
				ИтогиОснования[СтрокаТаблДок.ТаблДок_Раздел][УнИдентификатор].НачальноеСальдоДт = СальдоПоДоговору.НачОстатокПоДоговоруДт;
				ИтогиОснования[СтрокаТаблДок.ТаблДок_Раздел][УнИдентификатор].НачальноеСальдоКт = СальдоПоДоговору.НачОстатокПоДоговоруКт;
				Прервать;
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
	Попытка
		
		ИтогиОснования[СтрокаТаблДок.ТаблДок_Раздел][УнИдентификатор].НачальноеСальдоДт	= СтрокаТаблДок.мОснование.Договор.НачальноеСальдоДт;
		ИтогиОснования[СтрокаТаблДок.ТаблДок_Раздел][УнИдентификатор].НачальноеСальдоКт	= СтрокаТаблДок.мОснование.Договор.НачальноеСальдоКт;
		ИтогиОснования[СтрокаТаблДок.ТаблДок_Раздел][УнИдентификатор].КонечноеСальдоДт	= СтрокаТаблДок.мОснование.Договор.КонечноеСальдоДт;
		ИтогиОснования[СтрокаТаблДок.ТаблДок_Раздел][УнИдентификатор].КонечноеСальдоКт	= СтрокаТаблДок.мОснование.Договор.КонечноеСальдоКт; 
		
	Исключение
	КонецПопытки;

КонецПроцедуры

// Процедура формирует строку таблицы документа
//
// Параметры:
//  СтрокаТаблДок		 - Структура	 - Строка мТаблДок, сформированная в ини
//  ДопПараметры		 - Структура	 - Состоит из
//		Кэш - Структура - Кэш обработки
//		Контекст - Структура - Контекст заполнения структуры документа
//		ИтогиОснования - Структура - Сальдо и обороты по основаниям
//		НоваяСтрока - Структура - Строка, формируемая для итогового документа
//		СальдоПоДоговорам - Структура - Сальдо по догворам
//
&НаКлиенте
Процедура ОбработатьДокумент(СтрокаТаблДок, ДопПараметры)
	
	Кэш				= ДопПараметры.Кэш;
	Контекст		= ДопПараметры.Контекст;
	ИтогиОснования	= ДопПараметры.ИтогиОснования; 
	ОбщиеИтоги		= ДопПараметры.ОбщиеИтоги;

	НоваяСтрока = Новый Структура;
	Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш, "ТаблДок", СтрокаТаблДок, НоваяСтрока);			
	
	Если ЗначениеЗаполнено(СтрокаТаблДок.ДокументТабл)
		И (МодульОбъектаКлиент().ПолучитьЗначениеПараметраСбис("ИспользоватьНовыйФорматАктаСверки") = Истина
			Или Не СтрокаТаблДок.Свойство("ТаблДок_Примечание")) Тогда
		
		НоваяСтрока.Вставить("Название", Кэш.ОбщиеФункции.ПолучитьРеквизитМетаданныхОбъекта(СтрокаТаблДок.ДокументТабл, "Синоним"));
		
	Иначе
		
		НоваяСтрока.Вставить("Название", СтрокаТаблДок.ТаблДок_Примечание);
		
	КонецЕсли;
	
	Если СтрокаТаблДок.Свойство("мОснование") Тогда
		
		Для Каждого ПараметрОснование Из СтрокаТаблДок.мОснование Цикл
			
			ДопПараметры.Вставить("НоваяСтрока", НоваяСтрока);
			ОбработатьДоговор(СтрокаТаблДок, ПараметрОснование, ДопПараметры);
			
		КонецЦикла; 
		
	КонецЕсли;
	
	Если СтрокаТаблДок.Свойство("мПараметр") Тогда
		
		НоваяСтрока.Вставить("Параметр", Новый Массив); 
		
		Для Каждого Элемент Из СтрокаТаблДок.мПараметр Цикл
			
			Кэш.ОбщиеФункции.сбисСкопироватьСтруктуруНаКлиенте(СтрокаТаблДок,Элемент.Значение);
			Параметр = Новый Структура();
			Кэш.ОбщиеФункции.ЗаполнитьАтрибуты(Кэш,"Параметр",СтрокаТаблДок,Параметр);
			НоваяСтрока.Параметр.Добавить(Параметр);   
			
		КонецЦикла;
		
	КонецЕсли; 
	
	Если не ОбщиеИтоги.Свойство(СтрокаТаблДок.ТаблДок_Раздел) Тогда 
		
		ОбщиеИтоги.Вставить(СтрокаТаблДок.ТаблДок_Раздел, Новый Структура("ИтогДебет,ИтогКредит", 0, 0));
		
	КонецЕсли;
	
	ОбщиеИтоги[СтрокаТаблДок.ТаблДок_Раздел].ИтогДебет	= ОбщиеИтоги[СтрокаТаблДок.ТаблДок_Раздел].ИтогДебет	+ НоваяСтрока.Дебет;
	ОбщиеИтоги[СтрокаТаблДок.ТаблДок_Раздел].ИтогКредит	= ОбщиеИтоги[СтрокаТаблДок.ТаблДок_Раздел].ИтогКредит	+ НоваяСтрока.Кредит;
	
	Контекст.ТаблДок.СтрТабл.Добавить(НоваяСтрока);

КонецПроцедуры

// Функция заполняет начальное сальдо по документу
//
// Параметры:
//  Кэш					 - Структура	 - Кэш Внешней обработки
//  Контекст			 - Структура	 - Контекст заполнения структуры документа
//  ОстаткиНачало		 - Структура	 - Начальные остатка из ини
//  ЭлементОбщихИтогов	 - КлючИЗначение	 - Элемент общих итогов
// 
// Возвращаемое значение:
//  Структура - Строка итогов в итоговом документе
//
&НаКлиенте
Функция ЗаполнитьИтоги_НачальноеСальдо(Кэш, Контекст, ОстаткиНачало, ЭлементОбщихИтогов)

	НачСальдо = Новый Структура;
	
	Если ЗначениеЗаполнено(ОстаткиНачало) Тогда
		
		Если ЭлементОбщихИтогов.Ключ = "Отправитель" Тогда
			
			НачСальдоДебет = Макс(0, Число(ОстаткиНачало.НачальныйОстатокДебет));
			НачСальдоКредит = Макс(0, -Число(ОстаткиНачало.НачальныйОстатокКредит));
			
		Иначе                                 
			
			НачСальдоДебет = Макс(0, Число(ОстаткиНачало.НачальныйОстатокДебетКонтрагент));
			НачСальдоКредит = Макс(0, -Число(ОстаткиНачало.НачальныйОстатокКредитКонтрагент));   
			
		КонецЕсли; 
		
	Иначе	 
		
		ОстатокНаНачало = Кэш.ОбщиеФункции.РассчитатьЗначение("ОстатокНаНачало", Контекст.ФайлДанные, Кэш);
		
		Если ЭлементОбщихИтогов.Ключ = "Отправитель" Тогда
			
			НачСальдоДебет = Макс(0, Число(ОстатокНаНачало));
			НачСальдоКредит = Макс(0, -Число(ОстатокНаНачало));    
			
		Иначе                 
			
			НачСальдоДебет = Макс(0, -Число(ОстатокНаНачало));
			НачСальдоКредит = Макс(0, Число(ОстатокНаНачало)); 
			
		КонецЕсли;           
		
	КонецЕсли;     
	
	НачСальдо.Вставить("Дебет",		Формат(НачСальдоДебет, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
	НачСальдо.Вставить("Кредит",	Формат(НачСальдоКредит, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
	НачСальдо.Вставить("Тип",		"Сальдо начальное");	
	НачСальдо.Вставить("Дата",		Контекст.ФайлДанные.Период_ДатаНач);	
	НачСальдо.Вставить("Раздел",	ЭлементОбщихИтогов.Ключ);
	
	Контекст.ТаблДок.ИтогТабл.Добавить(НачСальдо);
	
	Возврат НачСальдо;

КонецФункции

// Функция заполняет начальное сальдо по документу
//
// Параметры:
//  Кэш					 - Структура	 - Кэш Внешней обработки
//  Контекст			 - Структура	 - Контекст заполнения структуры документа
//  ОстаткиНачало		 - Структура	 - Начальные остатка из ини
//  ЭлементОбщихИтогов	 - КлючИЗначение	 - Элемент общих итогов
// 
// Возвращаемое значение:
//  Структура - Строка итогов в итоговом документе
//
&НаКлиенте
Функция ЗаполнитьИтоги_Обороты(Кэш, Контекст, ИтогиОснования, ЭлементОбщихИтогов)

	СмещениеПоРазделу = ?(ЭлементОбщихИтогов.Ключ = "Отправитель", 0, 3);
	
	Если Контекст.ТаблДок.ИтогТабл.Количество() >= 2 + СмещениеПоРазделу Тогда
		
		ИтогТабл = Контекст.ТаблДок.ИтогТабл[1 + СмещениеПоРазделу];
		ИтогТабл.Дебет 	= Формат(ЭлементОбщихИтогов.Значение.ИтогДебет,		"ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");	
		ИтогТабл.Кредит	= Формат(ЭлементОбщихИтогов.Значение.ИтогКредит,	"ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00");
		
	Иначе
		
		ИтогТабл = Новый Структура;
		ИтогТабл.Вставить("Дебет", Формат(ЭлементОбщихИтогов.Значение.ИтогДебет, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
		ИтогТабл.Вставить("Кредит", Формат(ЭлементОбщихИтогов.Значение.ИтогКредит, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
		ИтогТабл.Вставить("Тип", "Обороты");		
		ИтогТабл.Вставить("Раздел", ЭлементОбщихИтогов.Ключ);
		//Добавим в итоги обротов итоги по основанию
		ИтогТабл.Вставить("Основание", Новый Массив);
		
	КонецЕсли;
	  
	
	Если ИтогиОснования.Свойство(ЭлементОбщихИтогов.Ключ) Тогда 
		
		Для каждого Строка из ИтогиОснования[ЭлементОбщихИтогов.Ключ] Цикл
			
			Если Не Контекст.СписокДоговоров.НайтиПоЗначению(Строка.Значение.Основание) = Неопределено Тогда 
				
				Продолжить;
				
			КонецЕсли;
			
			Основание = Строка.Значение.УзелОснования;
			Основание.Вставить("Дебет", Формат(Строка.Значение.Дебет, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));
			Основание.Вставить("Кредит", Формат(Строка.Значение.Кредит, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
			Основание.Вставить("НачальноеСальдоДт", Формат(Строка.Значение.НачальноеСальдоДт, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));
			Основание.Вставить("НачальноеСальдоКт", Формат(Строка.Значение.НачальноеСальдоКт, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00")); 
			
			Остаток = Основание.НачальноеСальдоДт - Основание.НачальноеСальдоКт + Основание.Дебет - Основание.Кредит;
			
			Если Остаток > 0 Тогда  
				
				ОснованиеИтогоКт = 0;
				ОснованиеИтогоДт = Остаток;  
				
			Иначе         
				
				ОснованиеИтогоКт = -Остаток;
				ОснованиеИтогоДт = 0;  
				
			КонецЕсли;      
			
			Основание.Вставить("КонечноеСальдоДт", Формат(ОснованиеИтогоДт, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));
			Основание.Вставить("КонечноеСальдоКт", Формат(ОснованиеИтогоКт, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));
			
			ИтогТабл.Основание.Добавить(Основание);
			
			Контекст.СписокДоговоров.Добавить(Строка.Значение.Основание);
			
		КонецЦикла;
		
	КонецЕсли;
	
	Если Контекст.ТаблДок.ИтогТабл.Количество() < 2 + СмещениеПоРазделу Тогда
		
		Контекст.ТаблДок.ИтогТабл.Добавить(ИтогТабл);
		
	Иначе 
		
		Контекст.ТаблДок.ИтогТабл[1 + СмещениеПоРазделу] = ИтогТабл;
		
	КонецЕсли;
	
	Возврат ИтогТабл;
	
КонецФункции

// Функция заполняет начальное сальдо по документу
//
// Параметры:
//  Кэш					 - Структура	 - Кэш Внешней обработки
//  Контекст			 - Структура	 - Контекст заполнения структуры документа
//  ОстаткиНачало		 - Структура	 - Начальные остатка из ини
//  ЭлементОбщихИтогов	 - КлючИЗначение	 - Элемент общих итогов
// 
// Возвращаемое значение:
//  Структура - Строка итогов в итоговом документе
//
&НаКлиенте
Функция ЗаполнитьИтоги_КонечноеСальдо(Кэш, Контекст, НачСальдо, ЭлементОбщихИтогов)
	
	СмещениеПоРазделу = ?(ЭлементОбщихИтогов.Ключ = "Отправитель", 0, 3);
	
	КонСальдо = Новый Структура;		
	КонСальдоДебет = Макс(0, НачСальдо.Дебет - НачСальдо.Кредит + ЭлементОбщихИтогов.Значение.ИтогДебет - ЭлементОбщихИтогов.Значение.ИтогКредит);
	КонСальдоКредит = Макс(0, НачСальдо.Кредит - НачСальдо.Дебет + ЭлементОбщихИтогов.Значение.ИтогКредит - ЭлементОбщихИтогов.Значение.ИтогДебет);
	КонСальдо.Вставить("Дебет", Формат(КонСальдоДебет, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
	КонСальдо.Вставить("Кредит", Формат(КонСальдоКредит, "ЧЦ=17; ЧДЦ=2; ЧРД=.; ЧГ=0; ЧН=0.00"));	
	КонСальдо.Вставить("Тип", "Сальдо конечное");	
	КонСальдо.Вставить("Дата", Контекст.ФайлДанные.Период_ДатаКнц);	
	КонСальдо.Вставить("Раздел", ЭлементОбщихИтогов.Ключ);//Берем раздел из последней строки табличной части
	
	Если Контекст.ТаблДок.ИтогТабл.Количество() < 3 + СмещениеПоРазделу Тогда
		
		Контекст.ТаблДок.ИтогТабл.Добавить(КонСальдо);
		
	Иначе 
		
		Контекст.ТаблДок.ИтогТабл[2 + СмещениеПоРазделу] = КонСальдо;
		
	КонецЕсли;
	
	Возврат КонСальдо;

КонецФункции // ЗаполнитьИтоги_КонечноеСальдо()


#КонецОбласти
