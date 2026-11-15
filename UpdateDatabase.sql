/**********************************************************************************************
 * File      : Deploy_Tss_StatusLabels.sql
 * Purpose   : تبدیل تابع اسکالر Tss_StdStaLabelsUdf به جدول نگاشت Tss_StatusLabels
 * Author    : DBA Team
 * Version   : 1.0
 * Date      : 2026-11-14
 * Run As    : sysadmin / db_owner
 * Idempotent: بله (قابل اجرای چندباره)
 **********************************************************************************************/
SET NOCOUNT ON;

SET XACT_ABORT ON;

PRINT '========================================================';

PRINT ' شروع استقرار Tss_StatusLabels';

PRINT ' تاریخ: ' + CONVERT (VARCHAR (19), GETDATE(), 120);

PRINT ' دیتابیس: ' + DB_NAME();

PRINT '========================================================';

BEGIN TRY
    BEGIN TRANSACTION;
    ------------------------------------------------------------
    -- مرحله ۱: ایجاد جدول در صورت عدم وجود
    ------------------------------------------------------------
    IF OBJECT_ID('dbo.Tss_StatusLabels', 'U') IS NULL
        BEGIN
            PRINT '>> ایجاد جدول dbo.Tss_StatusLabels ...';
            CREATE TABLE dbo.Tss_StatusLabels (
                TblFlag INT NOT NULL,
                StaValue INT NOT NULL,
                Label NVARCHAR (200) NOT NULL,
                CONSTRAINT PK_Tss_StatusLabels PRIMARY KEY CLUSTERED (TblFlag, StaValue)
            );
            PRINT '   جدول با موفقیت ایجاد شد.';
        END
    ELSE
        BEGIN
            PRINT '>> جدول dbo.Tss_StatusLabels از قبل وجود دارد.';
        END
    ------------------------------------------------------------
    -- مرحله ۲: درج/به‌روزرسانی داده‌ها (Idempotent)
    --         از MERGE برای insert/update استفاده می‌کنیم
    ------------------------------------------------------------
    PRINT '>> درج/به‌روزرسانی داده‌های نگاشت ...';
    WITH SourceData (TblFlag, StaValue, Label)
    AS   (SELECT *
          FROM   (VALUES -- 1001
                 (1001, 0, N'برگ نيست'), (1001, 1, N'برگ است'), -- 1002
                 (1002, 0, N'نشود'), (1002, 1, N'بشود'), -- 1003
                 (1003, 0, N'برگ نيست'), (1003, 1, N'برگ هست'), -- 1004
                 (1004, 0, N'بدون كنترل'), (1004, 1, N'بدهكار'), (1004, 2, N'بستانكار'), -- 1005
                 (1005, 0, N'ندارد'), (1005, 1, N'اشخاص'), (1005, 2, N'مركز هزينه'), (1005, 3, N'پروژه و قرارداد'), (1005, 4, N'سفارشات'), -- 1006
                 (1006, 0, N'ندارد'), (1006, 1, N'اشخاص'), (1006, 2, N'مركز هزينه'), (1006, 3, N'پروژه و قرارداد'), (1006, 4, N'سفارشات'), -- 1007
                 (1007, 0, N'پيش فرض نيست'), (1007, 1, N'پيش فرض است'), -- 1008
                 (1008, 0, N'بدهكار'), (1008, 1, N'بستانكار'), -- 1009
                 (1009, 0, N'صادرشده'), (1009, 1, N'اشكالدار'), (1009, 2, N'غيرفعال'), (1009, 3, N'فعال'), (1009, 4, N'ثبت نهائي'), (1009, 5, N'ابطالي'), -- 1010
                 (1010, 0, N'كسر شود'), (1010, 1, N'اضافه شود'), -- 1011
                 (1011, 0, N'ثبت نشده'), (1011, 1, N'ثبت شده'), -- 1012
                 (1012, 0, N'درجريان'), (1012, 1, N'تائيد شده'), (1012, 2, N'تائيد نشده'), -- 1013
                 (1013, 0, N'ثبت نشده'), (1013, 1, N'ثبت شده'), -- 1014
                 (1014, 0, N'ساعتي'), (1014, 1, N'روزانه'), -- 1015
                 (1015, 0, N'نمايش داده شود'), (1015, 1, N'نمايش داده نشود'), -- 1016
                 (1016, 0, N'اشتغال'), (1016, 1, N'عدم اشتغال'), -- 1017
                 (1017, 0, N'درجريان'), (1017, 1, N'تائيد شده'), (1017, 2, N'تائيد نشده'), -- 1018
                 (1018, 0, N'استفاده نشده'), (1018, 1, N'استفاده شده'), -- 1019
                 (1019, 0, N'كسر شود'), (1019, 1, N'اضافه شود'), -- 1020
                 (1020, 0, N'درجريان'), (1020, 1, N'تائيد شده'), (1020, 2, N'تائيد نشده'), -- 1021
                 (1021, 0, N'ثبت نشده'), (1021, 1, N'ثبت شده'), -- 1022
                 (1022, 0, N'ازمانده كسر شود'), (1022, 1, N'ازمانده كسر نشود'), -- 1023
                 (1023, 0, N'نوع ساعتي'), (1023, 1, N'نوع روزانه'), -- 1024
                 (1024, 0, N'از كاركرد كسر نشود'), (1024, 1, N'از كاركرد كسر شود'), -- 1025
                 (1025, 0, N'اياب ذهاب ندارد'), (1025, 1, N'اياب و ذهاب دارد'), -- 1026
                 (1026, 0, N'كنترل نشده'), (1026, 1, N'كنترل شده'), -- 1027
                 (1027, 0, N'اجرا نشده'), (1027, 1, N'اجرا شده'), (1027, 2, N'نهائي شده'), -- 1028
                 (1028, 0, N'حضور ندارد'), (1028, 1, N'حضور دارد'), -- 1029
                 (1029, 0, N'ناهار ندارد'), (1029, 1, N'ناهار دارد'), -- 1030
                 (1030, 0, N'برگ نيست'), (1030, 1, N'برگ است'), -- 1031
                 (1031, 0, N'عادي'), (1031, 1, N'نوبتكاري'), (1031, 2, N'شبكاري'), (1031, 3, N'ساعتي'), (1031, 4, N'مديريتي'), -- 1032
                 (1032, 0, N'تعديل شود'), (1032, 1, N'تعديل نشود'), -- 1033
                 (1033, 0, N'تعديل نشود'), (1033, 1, N'تعديل شود'), -- 1034
                 (1034, 0, N'تعديل نشود'), (1034, 1, N'تعديل شود'), -- 1035
                 (1035, 0, N'خودكارنباشد'), (1035, 1, N'خودكارباشد'), -- 1036
                 (1036, 0, N'ورود وخروج در يكروز است'), (1036, 1, N'ورود وخروج در يكروز نيست'), -- 1037
                 (1037, 0, N'احتياج دارد'), (1037, 1, N'احتياج ندارد'), -- 1038
                 (1038, 0, N'اجرا نشده'), (1038, 1, N'اجرا شده'), -- 1039
                 (1039, 0, N'روز موظف'), (1039, 1, N'جمعه كاري'), (1039, 2, N'تعطيل كاري'), (1039, 3, N'استراحت'), -- 1040
                 (1040, 0, N'شمارشي'), (1040, 1, N'اندازه اي'), (1040, 2, N'وزني'), -- 1041
                 (1041, 0, N'فروشنده'), (1041, 1, N'بدون مرجع'), (1041, 2, N'پيش فاکتور خريد'), (1041, 3, N'برگشت از فروش'), (1041, 4, N'قرارداد فروش'), (1041, 5, N'تنخواه دار'), (1041, 6, N'برونسپاري'), (1041, 7, N'صادره فروش'), (1041, 8, N'درخواست خريد'), -- 1042
                 (1042, 0, N'شمارشي'), (1042, 1, N'اندازه اي'), (1042, 2, N'وزني'), -- 1043
                 (1043, 0, N'غير فعال'), (1043, 1, N'فعال'), -- 1044
                 (1044, 0, N'شمارشي'), (1044, 1, N'اندازه اي'), (1044, 2, N'وزني'), -- 1045
                 (1045, 0, N'بدون مرجع'), (1045, 1, N'برگشت از خريد'), -- 1046
                 (1046, 0, N'ثبت اوليه'), (1046, 1, N'نهايي شده'), -- 1047
                 (1047, 0, N'غير فعال'), (1047, 1, N'فعال'), -- 1048
                 (1048, 0, N'هزينه مستقيم توليد نيست'), (1048, 1, N'هزينه مستقيم توليد هست'), -- 1049
                 (1049, 0, N'اتصال به مراكزهزينه'), (1049, 1, N'اتصال به پروژه'), -- 1050
                 (1050, 0, N'غير فعال'), (1050, 1, N'فعال'), -- 1051
                 (1051, 0, N'غير فعال'), (1051, 1, N'فعال'), -- 1052
                 (1052, 0, N'اجرا نشده'), (1052, 1, N'اجرا شده'), -- 1053
                 (1053, 0, N'مستمر نيست'), (1053, 1, N'مستمر هست'), -- 1054
                 (1054, 0, N'ورود داده ندارد'), (1054, 1, N'ورود داده دارد'), -- 1055
                 (1055, 0, N'غير فعال'), (1055, 1, N'فعال'), -- 1056
                 (1056, 0, N'ثبت اوليه'), (1056, 1, N'تائيد شده'), -- 1057
                 (1057, 0, N'غير دايكاتي'), (1057, 1, N'دايكاتي'), -- 1058
                 (1058, 0, N'غير فعال'), (1058, 1, N'فعال'), -- 1059
                 (1059, 0, N'كارتن'), (1059, 1, N'ورق'), (1059, 2, N'آخال'), (1059, 3, N'ورق خط دار'), (1059, 4, N'ورق چاپ دار'), (1059, 5, N'کارتن دو تکه'), (1059, 6, N'ورق سينگل'), -- 1060
                 (1060, 0, N'مرحله بسته بندي نيست'), (1060, 1, N'مرحله بسته بندي است'), -- 1061
                 (1061, 0, N'مرحله چاپ نيست'), (1061, 1, N'مرحلة چاپ است'), -- 1062
                 (1062, 0, N'مركزهزينه'), (1062, 1, N'قسمت'), -- 1063
                 (1063, 0, N'شمارشي'), (1063, 1, N'اندازه اي'), (1063, 2, N'وزني'), -- 1064
                 (1064, 0, N'فعال نيست'), (1064, 1, N'فعال است'), -- 1065
                 (1065, 0, N'همه اشخاص'), (1065, 1, N'پرسنل'), (1065, 2, N'شركتها و سازمانها'), (1065, 3, N'شعب بيمه'), (1065, 4, N'شعب دارائي'), (1065, 5, N'بانكها'), -- 1066
                 (1066, 0, N'مجرد'), (1066, 1, N'متاهل'), (1066, 2, N'معيل'), (1066, 3, N'بيوه'), -- 1067
                 (1067, 0, N'مرد'), (1067, 1, N'زن'), -- 1068
                 (1068, 0, N'کارخانه'), (1068, 1, N'دفتر مرکزي'), (1068, 2, N'شركتها و سازمانها'), (1068, 3, N'شعب بيمه'), (1068, 4, N'شعب دارائي'), (1068, 5, N'بانكها'), (1068, 6, N'شرکت دوم'), (1068, 7, N'غيره'), (1068, 8, N'کهريزک'), -- 1069
                 (1069, 0, N'بدون مرجع'), (1069, 1, N'فاكتور خريد'), (1069, 2, N'فاكتور فروش'), -- 1070
                 (1070, 0, N'فعال'), (1070, 1, N'باطل'), (1070, 2, N'معوق'), -- 1071
                 (1071, 0, N'برگ نيست'), (1071, 1, N'برگ است'), -- 1072
                 (1072, 0, N'شمارشي'), (1072, 1, N'اندازه اي'), (1072, 2, N'وزني'), -- 1073
                 (1073, 0, N'ندارد'), (1073, 1, N'لب چسب در طول'), (1073, 2, N'لب چسب در عرض'), (1073, 3, N'منگنه در طول'), (1073, 4, N'منگنه در عرض'), (1073, 5, N'لب چسب و منگنه'), -- 1074
                 (1074, 0, N'چاپ گردد'), (1074, 1, N'چاپ نگردد'), -- 1075
                 (1075, 0, N'درخواست'), (1075, 1, N'توافق فروش'), -- 1076
                 (1076, 0, N'ثبت اوليه'), (1076, 1, N'تاييد جهت ساخت'), (1076, 2, N'معلق'), (1076, 3, N'ابطال'), (1076, 4, N'نهايي'), (1076, 5, N'تاييديه مالي'), (1076, 6, N'تاييديه مديريت'), (1076, 7, N'تاييديه مدير کارخانه'), (1076, 8, N'تاييديه توليد'), -- 1077
                 (1077, 0, N'قرارداد ساخت'), (1077, 1, N'فروش کاغذ و آخال'), (1077, 2, N'تبديل ورق'), (1077, 3, N'قرارداد برونسپاري'), -- 1078
                 (1078, 0, N'كسر نشود'), (1078, 1, N'كسر شود'), -- 1079
                 (1079, 0, N'مشتري'), (1079, 1, N'فروشنده'), -- 1080
                 (1080, 0, N'نقدي'), (1080, 1, N'اعتباري'), -- 1081
                 (1081, 0, N'تيپ 1'), (1081, 1, N'تيپ 2'), -- 1082
                 (1082, 0, N'در جريان'), (1082, 1, N'واخواست شده'), (1082, 2, N'وصول شده'), -- 1083
                 (1083, 0, N'عادي'), (1083, 1, N'تضميني'), -- 1084
                 (1084, 0, N'چک نيست'), (1084, 1, N'چک است'), -- 1085
                 (1085, 0, N'بدون مرجع'), (1085, 1, N'توافق فروش'), (1085, 2, N'فاكتور فروش'), (1085, 3, N'فاكتور خريد'), -- 1086
                 (1086, 0, N'دريافت'), (1086, 1, N'پرداخت'), -- 1087
                 (1087, 0, N'دسترسي ندارد'), (1087, 1, N'دسترسي دارد'), -- 1088
                 (1088, 0, N'برگ نيست'), (1088, 1, N'برگ است'), -- 1089
                 (1089, 0, N'كسري'), (1089, 1, N'مرجوعي'), -- 1090
                 (1090, 0, N''), (1090, 1, N'منگنه'), -- 1091
                 (1091, 0, N''), (1091, 1, N'لب چسب'), -- 1092  ← باگ اصلاح شد
                 (1092, 0, N'شمارشي'), (1092, 1, N'اندازه اي'), (1092, 2, N'وزني'), -- 1093
                 (1093, 0, N'واحد مکانيک'), (1093, 1, N'واحد برق'), (1093, 2, N'واحد توليد'), (1093, 3, N'واحد تاسيسات'), (1093, 4, N'واحد خدمات'), (1093, 5, N'واحد انتظامات'), (1093, 6, N'واحد ايمني'), (1093, 7, N'واحد ارسال'), (1093, 8, N'واحد انبار'), (1093, 9, N'واحد رستوران'), (1093, 10, N'واحد اداري'), (1093, 11, N'برنامه ريزي'), (1093, 12, N'بازرگاني'), (1093, 13, N'واحد کنترل کيفيت'), (1093, 14, N'واحد ترابري'), (1093, 15, N'واحد پيش ارسال'), (1093, 16, N'واحد کارگزيني'), (1093, 17, N'واحد کليشه'), (1093, 18, N'واحد قالب'), -- 1094
                 (1094, 0, N'انتظامات'), (1094, 1, N'ايمني'), (1094, 2, N'خدمات'), (1094, 3, N'رستوران'), (1094, 4, N'اداري'), (1094, 5, N'ارسال'), (1094, 6, N'انبار کاغذ'), (1094, 7, N'انبار قطعات'), (1094, 8, N'راننده ليفتراک'), (1094, 9, N'برنامه ريزي'), (1094, 10, N'مقوا سازي 140'), (1094, 11, N'مقوا سازي 170'), (1094, 12, N'اطاق چسب'), (1094, 13, N'اطاق رنگ'), (1094, 14, N'اطاق کليشه'), (1094, 15, N'امبا'), (1094, 16, N'برش'), (1094, 17, N'بسته بندي'), (1094, 18, N'پالت تراک'), (1094, 19, N'پرس'), (1094, 20, N'توليد'), (1094, 21, N'دايکات'), (1094, 22, N'سه رنگ'), (1094, 23, N'برق'), (1094, 24, N'تاسيسات'), (1094, 25, N'مکانيک'), (1094, 26, N'مديريت'), (1094, 27, N'تدارکات'), (1094, 28, N'فروش'), -- 1095
                 (1095, 0, N'برنامه صادر شد'), (1095, 1, N'پيش نمايش زمان بندي توليد'), (1095, 2, N'در جريان ساخت'), (1095, 3, N'تکميل شده'), (1095, 4, N'نيمه تمام شده'), (1095, 5, N'در صف توليد'), (1095, 6, N'ابطالي'), -- 1096
                 (1096, 0, N'ندارد'), (1096, 1, N'دارد'), -- 1097
                 (1097, 0, N'ندارد'), (1097, 1, N'دارد'), -- 1098
                 (1098, 0, N'ندارد'), (1098, 1, N'تسمه کشي'), (1098, 2, N'شرينک پالت'), -- 1099
                 (1099, 0, N'ندارد'), (1099, 1, N'دارد'), -- 1100
                 (1100, 0, N'ثبت اوليه'), (1100, 1, N'تاييد شده'), (1100, 2, N'باطل شده'), (1100, 3, N'تعليق شده'), (1100, 4, N'تکميل شده'), -- 1101
                 (1101, 0, N'واحد مکانيک'), (1101, 1, N'واحد برق'), (1101, 2, N'واحد توليد'), (1101, 3, N'واحد تاسيسات'), (1101, 4, N'واحد خدمات'), (1101, 5, N'واحد انتظامات'), (1101, 6, N'واحد ايمني'), (1101, 7, N'واحد ارسال'), (1101, 8, N'واحد انبار'), (1101, 9, N'واحد رستوران'), (1101, 10, N'واحد اداري'), (1101, 11, N'واحد برنامه ريزي'), (1101, 12, N'واحد بازرگاني'), (1101, 13, N'واحد اداري دفتر مرکزي'), (1101, 14, N'واحد فروش دفتر مرکزي'), (1101, 15, N'واحد ساختماني'), -- 1102
                 (1102, 0, N'ثبت اوليه'), (1102, 1, N'تاييد مدير واحد'), (1102, 2, N'تاييد مدير کارخانه'), (1102, 3, N'تاييد مدير تدارکات'), (1102, 4, N'تاييد کميسيون معاملات'), (1102, 5, N'مامور خريد مامونيه'), (1102, 6, N'حجت سيار'), (1102, 7, N'ميلاد شراحي'), (1102, 8, N'محمد جدي'), (1102, 9, N'تکميل مراحل خريد'), (1102, 10, N'روح الله محمودي'), (1102, 11, N'علي اکبر قضائي'), (1102, 12, N'تاييد مديريت'), (1102, 13, N'مسعود باقرزاده'), (1102, 14, N'سيد صادق اعظمي'), (1102, 15, N'روح الله مهدوي'), (1102, 16, N'آقاي پناهي'), (1102, 17, N'حامد آقاعلي'), (1102, 18, N'حميد ميرزاپور'), -- 1103
                 (1103, 0, N'گزارش توليد روزانه ماشين آلات'), (1103, 1, N'گزارش روزانه توليد'), -- 1104
                 (1104, 0, N'مورد تاييد نمي باشد'), (1104, 1, N'مورد تاييد است'), -- 1105
                 (1105, 0, N'تهيه کننده'), (1105, 1, N'تاييد کننده'), -- 1106
                 (1106, 0, N'صبح'), (1106, 1, N'عصر'), (1106, 2, N'شب'), -- 1107
                 (1107, 0, N'آماري'), (1107, 1, N'ترازنامه اي'), -- 1108
                 (1108, 0, N'سود و زياني'), (1108, 1, N'قيمت تمام شده'), -- 1109
                 (1109, 0, N'قيمت تمام شده استاندارد'), -- 1110
                 (1110, 0, N'ماليات بر ارزش افزوده ندارد'), (1110, 1, N'ماليات بر ارزش افزوده دارد'), -- 1111
                 (1111, 0, N'ثبت اوليه'), (1111, 1, N'مورد تاييد است'), -- 1112
                 (1112, 0, N'درآمدهاي عملياتي'), (1112, 1, N'هزينه هاي عملياتي'), (1112, 2, N'درآمدهاي غير عملياتي'), (1112, 3, N'هزينه هاي غير عملياتي'), (1112, 4, N'غير موثر بر سود و زيان'), -- 1113
                 (1113, 0, N'کالا'), (1113, 1, N'خدمات'), -- 1114
                 (1114, 0, N'واگذار به پرسنل'), (1114, 1, N'واگذار به شخص يا شرکت'), (1114, 2, N'واگذار به بانک'), (1114, 3, N'استرداد اسناد دريافتني به شخص'), (1114, 4, N'عودت اسناد واگذاري به صندوق'), (1114, 5, N'استرداد از بانک'), -- 1115
                 (1115, 0, N'فعال است'), (1115, 1, N'غيرفعال است'), -- 1116
                 (1116, 0, N'سنوات دارد'), (1116, 1, N'سنوات ندارد'), -- 1117
                 (1117, 0, N'عيدي دارد'), (1117, 1, N'عيدي ندارد'), -- 1118
                 (1118, 0, N'کاسپين'), (1118, 1, N'کهريزک'), -- 1119
                 (1119, 0, N'وايت تاپ'), (1119, 1, N'کرافت'), (1119, 2, N'فلوتينگ'), (1119, 3, N'تست لاينر'), (1119, 4, N'بازيافت'), -- 1120
                 (1120, 0, N'ندارد'), (1120, 1, N'اشخاص'), (1120, 2, N'مركز هزينه'), (1120, 3, N'پروژه و قرارداد'), (1120, 4, N'سفارشات'), -- 1121
                 (1121, 0, N'ندارد'), (1121, 1, N'اشخاص'), (1121, 2, N'مركز هزينه'), (1121, 3, N'پروژه و قرارداد'), (1121, 4, N'سفارشات'), -- 1122
                 (1122, 0, N'ندارد'), (1122, 1, N'اشخاص'), (1122, 2, N'مركز هزينه'), (1122, 3, N'پروژه و قرارداد'), (1122, 4, N'سفارشات'), -- 1123
                 (1123, 0, N'طرح ندارد'), (1123, 1, N'طرح دارد'), -- 1124
                 (1124, 0, N'چک دريافتي'), (1124, 1, N'در جريان وصول'), (1124, 2, N'وصول شد'), (1124, 3, N'واخواست شد'), (1124, 4, N'ابطال شد'), (1124, 5, N'واگذاري به غير'), (1124, 6, N'واگذاري به بانک'), (1124, 7, N'حقوقي'), (1124, 8, N'واگذاري مجدد به شخص يا بانک'), (1124, 9, N'به دهنده استرداد شد'), (1124, 10, N'استرداد به صندوق'), (1124, 11, N'چک تضمين'), -- 1125
                 (1125, 0, N'ريال'), (1125, 1, N'دلار'), (1125, 2, N'يورو'), (1125, 3, N'دينار'), (1125, 4, N'افغاني'), -- 1126
                 (1126, 0, N'بلامانع'), (1126, 1, N'پرسش'), (1126, 2, N'عدم ارسال'), -- 1127
                 (1127, 0, N'بدهکاران تجاري'), (1127, 1, N'بستانکاران تجاري'), (1127, 2, N'بدهکاران غير تجاري'), (1127, 3, N'بستانکاران غير تجاري'), (1127, 4, N'تسهيلات'), (1127, 5, N'دارائي ها'), (1127, 6, N'پرسنل'), (1127, 7, N'بانک ها'), (1127, 8, N'شعب بيمه'), (1127, 9, N'شعب دارائي'), (1127, 10, N'ساير'), -- 1128
                 (1128, 0, N'فاکتور اصلي'), (1128, 1, N'فاکتور اصلاحي'), (1128, 2, N'فاکتور ابطالي'), (1128, 3, N'فاکتور برگشت از فروش'), -- 1129
                 (1129, 0, N'عادی'), (1129, 1, N'ته قفلی'), (1129, 2, N'دو تکه'), (1129, 3, N'غیر لمینتی'), -- 1130
                 (1130, 0, N'عادی'), (1130, 1, N'دو تکه'), (1130, 2, N'دو تکه تک درب'), (1130, 3, N'عادی تک درب'), -- 1131
                 (1131, 0, N'چک پرداخت شده'), (1131, 1, N'برداشت شد'), (1131, 2, N'ابطال شد'), (1131, 3, N'ثبت سند شده'), (1131, 4, N'چک تضمینی'), (1131, 5, N'دستور پرداخت'), -- 1132
                 (1132, 0, N'نقد'), (1132, 1, N'نسیه'), (1132, 2, N'نقد و نسیه'), -- 1133
                 (1133, 0, N'یووی'), (1133, 1, N'ورنی'), (1133, 2, N'متالایز'), (1133, 3, N'سلفون مات چسبی'), (1133, 4, N'سلفون مات حرارتی'), (1133, 5, N'سلفون براق چسبی'), (1133, 6, N'سلفون براق حرارتی'), (1133, 7, N''), -- 1134
                 (1134, 0, N'بدون بسته بندی'), (1134, 1, N'نخ'), (1134, 2, N'تسمه'), (1134, 3, N'شرینک'), (1134, 4, N'شرینک پالت'), (1134, 5, N'پالت'), (1134, 6, N'شرینک پالت امانی')) AS V(TblFlag, StaValue, Label))
    MERGE INTO dbo.Tss_StatusLabels
     AS tgt
    USING SourceData AS src ON tgt.TblFlag = src.TblFlag
                               AND tgt.StaValue = src.StaValue
    WHEN MATCHED AND (tgt.Label <> src.Label) THEN UPDATE 
    SET Label = src.Label
    WHEN NOT MATCHED BY TARGET THEN INSERT (TblFlag, StaValue, Label) VALUES (src.TblFlag, src.StaValue, src.Label);
    DECLARE @Inserted AS INT = @@ROWCOUNT;
    PRINT '   تعداد ردیف‌های درج/به‌روزرسانی شده: ' + CAST (@Inserted AS VARCHAR (20));
    ------------------------------------------------------------
    -- مرحله ۳: بررسی سلامت داده‌ها
    ------------------------------------------------------------
    PRINT '>> بررسی سلامت داده‌ها ...';
    DECLARE @TotalRows AS INT, @DistinctFlags AS INT, @NullLabels AS INT;
    SELECT @TotalRows = COUNT(*),
           @DistinctFlags = COUNT(DISTINCT TblFlag),
           @NullLabels = SUM(CASE WHEN Label IS NULL THEN 1 ELSE 0 END)
    FROM   dbo.Tss_StatusLabels;
    PRINT '   تعداد کل ردیف‌ها: ' + CAST (@TotalRows AS VARCHAR (20));
    PRINT '   تعداد TblFlag های متمایز: ' + CAST (@DistinctFlags AS VARCHAR (20));
    PRINT '   تعداد برچسب‌های NULL: ' + CAST (ISNULL(@NullLabels, 0) AS VARCHAR (20));
    IF @NullLabels > 0
        RAISERROR ('   هشدار: برخی برچسب‌ها NULL هستند!', 10, 1)
            WITH NOWAIT;
    ------------------------------------------------------------
    -- مرحله ۴: تبدیل تابع قدیمی به Wrapper (در صورت وجود)
    ------------------------------------------------------------
    IF OBJECT_ID('dbo.Tss_StdStaLabelsUdf', 'FN') IS NOT NULL
        BEGIN
            PRINT '>> تابع قدیمی Tss_StdStaLabelsUdf پیدا شد. تبدیل به Wrapper ...';
            -- بررسی اینکه آیا تابع قبلاً به Wrapper تبدیل شده است یا نه
            -- (با جستجوی 'Tss_StatusLabels' در تعریف تابع)
            DECLARE @FuncDef AS NVARCHAR (MAX);
            SELECT @FuncDef = OBJECT_DEFINITION(OBJECT_ID('dbo.Tss_StdStaLabelsUdf'));
            IF @FuncDef NOT LIKE '%Tss_StatusLabels%'
                BEGIN
                    -- تابع هنوز Wrapper نیست، آن را با نسخه جدید جایگزین می‌کنیم
                    EXECUTE ('
                ALTER FUNCTION dbo.Tss_StdStaLabelsUdf (@TblFlag INT, @StaValue INT)
                RETURNS VARCHAR(200)
                AS
                BEGIN
                    DECLARE @ResLbl VARCHAR(200);
                    
                    SELECT @ResLbl = Label
                    FROM dbo.Tss_StatusLabels
                    WHERE TblFlag = @TblFlag AND StaValue = @StaValue;
                    
                    RETURN ISNULL(@ResLbl, '''');
                END;
            ');
                    PRINT '   تابع به Wrapper تبدیل شد (سازگار با برنامه‌های قدیمی).';
                END
            ELSE
                BEGIN
                    PRINT '   تابع قبلاً به Wrapper تبدیل شده است.';
                END
        END
    ELSE
        BEGIN
            PRINT '>> تابع Tss_StdStaLabelsUdf وجود ندارد (نیازی به Wrapper نیست).';
        END
    ------------------------------------------------------------
    -- مرحله ۵: Commit
    ------------------------------------------------------------
    COMMIT TRANSACTION;
    PRINT '========================================================';
    PRINT ' ✅ استقرار با موفقیت انجام شد.';
    PRINT '========================================================';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;
    PRINT '========================================================';
    PRINT ' ❌ خطا در استقرار!';
    PRINT '========================================================';
    PRINT ' Error Number : ' + CAST (ERROR_NUMBER() AS VARCHAR (20));
    PRINT ' Error Message: ' + ERROR_MESSAGE();
    PRINT ' Error Line   : ' + CAST (ERROR_LINE() AS VARCHAR (20));
    PRINT ' Error State  : ' + CAST (ERROR_STATE() AS VARCHAR (20));
    PRINT '========================================================';
    THROW;
END CATCH


GO
/**********************************************************************************************
 * گزارش نهایی
 **********************************************************************************************/
PRINT '>> گزارش نهایی:';

SELECT   TblFlag,
         COUNT(*) AS StaValueCount,
         MIN(StaValue) AS MinStaValue,
         MAX(StaValue) AS MaxStaValue
FROM     dbo.Tss_StatusLabels
GROUP BY TblFlag
ORDER BY TblFlag;


GO
-- First, check if the columns exist in the table
SELECT COLUMN_NAME,
       DATA_TYPE,
       IS_NULLABLE
FROM   INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_NAME = 'Tss_LonLoans'
       AND COLUMN_NAME IN ('Num_BreathDays', 'Num_ProfInBreathDate', 'Num_PorfInInstallments', 'SiPubCustomCodes', 'SiPubPersonsSpec', 'Sta_LoanType', 'DateLoanStartDate');

-- If any columns are missing, add them using this script
-- Add Num_BreathDays if missing
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_NAME = 'Tss_LonLoans'
                      AND COLUMN_NAME = 'Num_BreathDays')
    BEGIN
        ALTER TABLE [dbo].[Tss_LonLoans]
            ADD [Num_BreathDays] SMALLINT NULL;
    END


GO
-- Add Num_ProfInBreathDate if missing
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_NAME = 'Tss_LonLoans'
                      AND COLUMN_NAME = 'Num_ProfInBreathDate')
    BEGIN
        ALTER TABLE [dbo].[Tss_LonLoans]
            ADD [Num_ProfInBreathDate] NUMERIC (18, 0) NULL;
    END


GO
-- Add Num_PorfInInstallments if missing
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_NAME = 'Tss_LonLoans'
                      AND COLUMN_NAME = 'Num_PorfInInstallments')
    BEGIN
        ALTER TABLE [dbo].[Tss_LonLoans]
            ADD [Num_PorfInInstallments] NUMERIC (18, 0) NULL;
    END


GO
-- Add SiPubCustomCodes if missing
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_NAME = 'Tss_LonLoans'
                      AND COLUMN_NAME = 'SiPubCustomCodes')
    BEGIN
        ALTER TABLE [dbo].[Tss_LonLoans]
            ADD [SiPubCustomCodes] NUMERIC (18, 0) NULL;
    END


GO
-- Add SiPubPersonsSpec if missing
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_NAME = 'Tss_LonLoans'
                      AND COLUMN_NAME = 'SiPubPersonsSpec')
    BEGIN
        ALTER TABLE [dbo].[Tss_LonLoans]
            ADD [SiPubPersonsSpec] NUMERIC (18, 0) NULL;
    END


GO
-- Add Sta_LoanType if missing
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_NAME = 'Tss_LonLoans'
                      AND COLUMN_NAME = 'Sta_LoanType')
    BEGIN
        ALTER TABLE [dbo].[Tss_LonLoans]
            ADD [Sta_LoanType] SMALLINT NULL;
    END


GO
-- Add DateLoanStartDate if missing
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_NAME = 'Tss_LonLoans'
                      AND COLUMN_NAME = 'DateLoanStartDate')
    BEGIN
        ALTER TABLE [dbo].[Tss_LonLoans]
            ADD [DateLoanStartDate] VARCHAR (10) NULL;
    END


GO
-- After adding columns, refresh the stored procedure to recognize the new columns
-- You may need to execute sp_refreshsqlmodule or recreate the procedure
EXECUTE sp_refreshsqlmodule 'Tss_LonUntLoansIudStp';


GO
-- If the procedure still has errors, you can try to recompile it
EXECUTE sp_recompile 'Tss_LonUntLoansIudStp';


GO
-- Create version tracking table if it doesn't exist
IF NOT EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = OBJECT_ID(N'[dbo].[DBVersion]')
                      AND type IN (N'U'))
    BEGIN
        CREATE TABLE DBVersion (
            VersionID INT IDENTITY (1, 1) PRIMARY KEY,
            VersionNumber DECIMAL (10, 2) NOT NULL,
            AppliedDate DATETIME DEFAULT GETDATE(),
            Description NVARCHAR (500)
        );
    END


GO
-- Suppress row count messages
SET NOCOUNT ON;


GO
-- Add Sta_SayadiReg if it doesn't exist
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'Tss_RapReceivedCheque'
                      AND COLUMN_NAME = 'Sta_SayadiReg')
    BEGIN
        ALTER TABLE dbo.Tss_RapReceivedCheque
            ADD Sta_SayadiReg SMALLINT NULL;
    END


GO
-- Add Des_RecCheqOurSayadiNationalCode if it doesn't exist
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'Tss_RapReceivedCheque'
                      AND COLUMN_NAME = 'Des_RecCheqOurSayadiNationalCode')
    BEGIN
        ALTER TABLE dbo.Tss_RapReceivedCheque
            ADD Des_RecCheqOurSayadiNationalCode VARCHAR (500) NULL;
    END


GO
-- Add Dat_SayadiRegDate if it doesn't exist
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'Tss_RapReceivedCheque'
                      AND COLUMN_NAME = 'Dat_SayadiRegDate')
    BEGIN
        ALTER TABLE dbo.Tss_RapReceivedCheque
            ADD Dat_SayadiRegDate VARCHAR (10) NULL;
    END


GO
-- Add Sta_IsChecqueElectronic if it doesn't exist
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'Tss_RapReceivedCheque'
                      AND COLUMN_NAME = 'Sta_IsChecqueElectronic')
    BEGIN
        ALTER TABLE dbo.Tss_RapReceivedCheque
            ADD Sta_IsChecqueElectronic SMALLINT NULL;
    END


GO
-- Add Des_RecCheqOurSayadiNationalCode if it doesn't exist
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'Tss_RapReceivedCheque'
                      AND COLUMN_NAME = 'Des_ReceivedChequeSayadiNationalCode')
    BEGIN
        ALTER TABLE dbo.Tss_RapReceivedCheque
            ADD Des_ReceivedChequeSayadiNationalCode VARCHAR (500) NULL;
    END


GO
-- Add Dat_SayadiRegDate if it doesn't exist
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'Tss_RapReceivedCheque'
                      AND COLUMN_NAME = 'Des_ReceivedChequeSayadiCode')
    BEGIN
        ALTER TABLE dbo.Tss_RapReceivedCheque
            ADD Des_ReceivedChequeSayadiCode VARCHAR (10) NULL;
    END


GO
-- Rest of your procedures...
ALTER PROCEDURE Tss_RapUntReceivedCheque_HdVStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)='', @FromDate VARCHAR (10)='1399/09/01', @ToDate VARCHAR (10)='1399/12/29', @Flg SMALLINT=0, @SiUser NUMERIC=1
AS
DECLARE @Adate AS CHAR (10), @Des_StdUserToBdsCondition AS VARCHAR (8000), @SqlTxt AS VARCHAR (8000), @TodayShamsi AS NVARCHAR (10), @ThirtyDaysAgoShamsi AS NVARCHAR (10);
SET @TodayShamsi = dbo.Tss_MiladyToShamsiPar(GetDate());
SET @ThirtyDaysAgoShamsi = dbo.Tss_MiladyToShamsiPar(DATEADD(DAY, -7, GETDATE()));
--Set @Adate = dbo.Tss_MiladyToShamsiPar(DATEADD(d,-1,GetDate()))
SET @Adate = dbo.Tss_MiladyToShamsiPar(GetDate());
IF dbo.Tss_StdFindSubLoc(0) = 'Caspian'
    BEGIN
        IF dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'Sal') = 1
            SET @InternalWhere = 'Dat_RapReceivedChequeRegDate>''1398/01/23''';
        ELSE
            SET @InternalWhere = '';
    END
ELSE
    BEGIN
        SET @InternalWhere = '';
    END
IF @InternalWhere <> ''
    SET @Where = ' Where (Dat_RapReceivedChequeRegDate BETWEEN ''' + @ThirtyDaysAgoShamsi + ''' AND ''' + @TodayShamsi + '''' + ')';
/*
SELECT     
	@Des_StdUserToBdsCondition = Tss_StdUserToBds.Des_StdUserToBdsCondition
FROM         
	Tss_StdUserToBds INNER JOIN
   Tss_StdSystemUsers ON Tss_StdUserToBds.SiStdSystemUsers = Tss_StdSystemUsers.SiStdSystemUsers
WHERE     
	(Tss_StdSystemUsers.SiPubPersonsSpec = @SiUser) and 
	(Tss_StdUserToBds.Sta_HdDt = 0) and
	(Isnull(Des_StdUserToBdsCondition,'')<>'')

If Isnull(@Des_StdUserToBdsCondition,'')=''
Begin*/
IF @Where <> ''
    SET @Where = ' Where ' + @Where;
ELSE
    --   Set @Where=' Where left(Dat_RapReceivedChequeRegDate,12)='+''''+left(@Adate,12)+''''
    SET @Where = ' Where left(Dat_RapReceivedChequeRegDate,12)>=''1402/01/01''';
/*
End
Else
Begin
	If @Where<>''    
	   Set @Where=' Where '+@Des_StdUserToBdsCondition+' and '+@Where  
	Else
	   Set @Where=' Where '+@Des_StdUserToBdsCondition+' and Dat_RapReceivedChequeRegDate>'+''''+@Adate+''''
End */
/*Declare @SqlTxt Varchar(8000)

If @InternalWhere<>''   
   Set @InternalWhere=' Where '+@InternalWhere  
If @Where<>''   
   Set @Where=' Where '+@Where  */
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
ELSE
    SET @Order = ' Order By Dat_RapReceivedChequeRegDate desc';
SET @SqlTxt = 'Select distinct * From   
(  
   Select * From 
   (  
SELECT        
	RecChq.SiRapReceivedCheque, RecChq.SiRapCashDefine, RecChq.SiPubPersonsSpec, RecChq.SiPubCustomCodes, RecChq.Cod_RapReceivedChequeCode, RecChq.Des_RapReceivedChequeDesc, 
	RecChq.Cod_RapReceivedChqBankCode, RecChq.Des_RapReceivedChqBankName, RecChq.Cod_RapReceivedChqBankAccNo, RecChq.Des_RapReceivedChqSeriCode, RecChq.Cod_RapReceivedChequeSerial, 
	RecChq.Num_RapReceivedChequeAmount, RecChq.Sta_RapReceivedChequeState, RecChq.StmRapReceivedCheque, RecChq.Sta_ChekRecieptMainOrNot, RecChq.Des_RapReceivedChequeRecieptDesc, 
	pPers.Cod_PubPersonCode, pPers.Des_PubPersonName1, pPers.Des_PubPersonName2, pPers.Des_FullName, RapCash.Cod_RapCashDefCode, RapCash.Des_RapCashDefDesc, BankTp.Cod_CustomCodesCode, 
	BankTp.Des_CustomCodesDesc, ISNULL
	((SELECT        COUNT(SiVchDtForRecCheck) AS Expr1
	FROM            Tss_RapRecievedChequeRef AS Ref
	WHERE        (SiRapReceivedCheque = RecChq.SiRapReceivedCheque) AND (SiVchDtForRecCheck IS NOT NULL)), 0) AS VochCount,
	(SELECT        ISNULL(COUNT(ISNULL(SiRapRecChequeToBank, 0)), 0) AS Expr1
	FROM            Tss_RapRecChequeToBank
	WHERE        (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) AS ToBankCount, RecChq.Dat_RapReceivedChequeCngDate, RecChq.Dat_RapReceivedChequeRegDate, 
	LEFT(RecChq.Dat_RapReceivedChequeRegDate, 4) AS Dat_RapReceivedChequeRegDateYear, SUBSTRING(RecChq.Dat_RapReceivedChequeRegDate, 6, 2) AS Dat_RapReceivedChequeRegDateMonth, 
	RecChq.Dat_RapReceivedChequeEndDate, LEFT(RecChq.Dat_RapReceivedChequeEndDate, 4) AS Dat_RapReceivedChequeEndDateYear, SUBSTRING(RecChq.Dat_RapReceivedChequeEndDate, 6, 2) 
	AS Dat_RapReceivedChequeEndDateMonth, RecChq.Dat_RapReceivedChequeVosoolDate, LEFT(RecChq.Dat_RapReceivedChequeVosoolDate, 4) AS Dat_RapReceivedChequeVosoolDateYear, 
	SUBSTRING(RecChq.Dat_RapReceivedChequeVosoolDate, 6, 2) AS Dat_RapReceivedChequeVosoolDateMonth, RecChq.Dat_RapReceivedChequeBargashtDate, LEFT(RecChq.Dat_RapReceivedChequeBargashtDate, 4) 
	AS Dat_RapReceivedChequeBargashtDateYear, SUBSTRING(RecChq.Dat_RapReceivedChequeBargashtDate, 6, 2) AS Dat_RapReceivedChequeBargashtDateMonth, RecChq.Dat_RapReceivedChequeCancelDate, 
	RecChq.Dat_RapReceivedChequeToPerDate, LEFT(RecChq.Dat_RapReceivedChequeToPerDate, 4) AS Dat_RapReceivedChequeToPerDateYear, SUBSTRING(RecChq.Dat_RapReceivedChequeToPerDate, 6, 2) 
	AS Dat_RapReceivedChequeToPerDateMonth, RecChq.Dat_RapReceivedChequeToBankDate, LEFT(RecChq.Dat_RapReceivedChequeToBankDate, 4) AS Dat_RapReceivedChequeToBankDateYear, 
	SUBSTRING(RecChq.Dat_RapReceivedChequeToBankDate, 6, 2) AS Dat_RapReceivedChequeToBankDateMonth, RecChq.Dat_RapReceivedChequeHoghughiDate, LEFT(RecChq.Dat_RapReceivedChequeHoghughiDate, 4) 
	AS Dat_RapReceivedChequeHoghughiDateYear, SUBSTRING(RecChq.Dat_RapReceivedChequeHoghughiDate, 6, 2) AS Dat_RapReceivedChequeHoghughiDateMonth, RecChq.SiPubSubLocations, 
	Tss_PubSubLocations.Cod_SubLocCode, Tss_PubSubLocations.Des_SubLocName, RecChq.Dat_RapReceivedChequeToAgainDate, RecChq.Sta_ConcurrentChek, Tss_RapRecCheckGhabzRep1Vw.GirandehCode, 
	Tss_RapRecCheckGhabzRep1Vw.GirandehDesc,
	(SELECT top 1 SiVchDtForRecCheck FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForRecCheck,
	(SELECT top 1 SiVchDtForChekToBank FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForChekToBank,
	(SELECT top 1 SiVchDtForChekToPer FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForChekToPer,
	(SELECT top 1 SiVchDtForVosool FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForVosool,
	(SELECT top 1 SiVchDtForBargasht FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForBargasht,
	(SELECT top 1 SiVchDtForTazmini FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForTazmini,
	(SELECT top 1 SiVchDtForEsterdad FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForEsterdad,
	(SELECT top 1 SiVchDtForCashierBargasht FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForCashierBargasht,
	(SELECT SUM(Num_RapRecievedChequeRefAmount) FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) SumRow,
	RecChq.SiRapBehalfDefineHd, 
	RecChq.SiRapRecievedChequeRef_RefrenceHd, 
	Tss_RapBehalfDefine.Cod_RapBehalfCode, 
	Tss_RapBehalfDefine.Des_RapBehalfDesc,      
	RecChq.Dat_EsterdadToCashier, 
	RecChq.Dat_EsterdadToPer,
	RecChq.Sta_CalcInReturnRep,
	pPers.RelatedSalerName, 
	pPers.RelatedSalerCode,
    RecChq.Des_ReceivedChequeSayadiCode,
    RecChq.Des_ReceivedChequeSayadiNationalCode,
    RecChq.Sta_IsChecqueElectronic,
    RecChq.Sta_SayadiReg,
    RecChq.Des_RecCheqOurSayadiNationalCode,
    RecChq.Dat_SayadiRegDate
FROM         
	Tss_RapBehalfDefine RIGHT OUTER JOIN
	Tss_RapReceivedCheque RecChq INNER JOIN
	Tss_RapCashDefine RapCash ON RecChq.SiRapCashDefine = RapCash.SiRapCashDefine INNER JOIN
	Tss_PubPersonsViw pPers ON RecChq.SiPubPersonsSpec = pPers.SiPubPersonsSpec ON 
	Tss_RapBehalfDefine.SiRapBehalfDefine = RecChq.SiRapBehalfDefineHd LEFT OUTER JOIN
	Tss_RapRecCheckGhabzRep1Vw ON RecChq.SiRapReceivedCheque = Tss_RapRecCheckGhabzRep1Vw.SiRapReceivedCheque LEFT OUTER JOIN
	Tss_PubSubLocations ON RecChq.SiPubSubLocations = Tss_PubSubLocations.SiPubSubLocations LEFT OUTER JOIN
	Tss_PubCustomCodes BankTp ON RecChq.SiPubCustomCodes = BankTp.SiPubCustomCodes';
IF @Where <> ''
    SET @Where = @Where + ' and  (SiPubSubLocations in (SELECT DISTINCT 
		Tss_AccFinancePeriodToPlace.SiPubSubLocations
	FROM         
		Tss_AccUserToFinancePeriodAndPlace INNER JOIN
		Tss_AccFinancePeriodToPlace ON 
		Tss_AccUserToFinancePeriodAndPlace.SiAccFinancePeriodToPlace = Tss_AccFinancePeriodToPlace.SiAccFinancePeriodToPlace
	WHERE     
		(Tss_AccUserToFinancePeriodAndPlace.SiPubPersonsSpec = ' + CONVERT (VARCHAR, @SiUser) + ')))';
ELSE
    SET @Where = @Where + ' where  (SiPubSubLocations in  (SELECT DISTINCT 
		Tss_AccFinancePeriodToPlace.SiPubSubLocations
	FROM         
		Tss_AccUserToFinancePeriodAndPlace INNER JOIN
		Tss_AccFinancePeriodToPlace ON 
		Tss_AccUserToFinancePeriodAndPlace.SiAccFinancePeriodToPlace = Tss_AccFinancePeriodToPlace.SiAccFinancePeriodToPlace
	WHERE     
		(Tss_AccUserToFinancePeriodAndPlace.SiPubPersonsSpec = @' + CONVERT (VARCHAR, @SiUser) + ')))';
/*
if @Flg = 0 
	Set @SqlTxt = @SqlTxt +char(10)+ ' where (RecChq.Dat_RapReceivedChequeRegDate between '+''''+@FromDate+''''+' and '+''''+@ToDate+''''+')'
if @Flg = 1 
	Set @SqlTxt = @SqlTxt +char(10)+ ' where (RecChq.Dat_RapReceivedChequeEndDate between '+''''+@FromDate+''''+' and '+''''+@ToDate+''''+')'
if @Flg = 2 
	Set @SqlTxt = @SqlTxt +char(10)+ ' where (RecChq.Dat_RapReceivedChequeVosoolDate between '+''''+@FromDate+''''+' and '+''''+@ToDate+''''+')'
if @Flg = 3 
	Set @SqlTxt = @SqlTxt +char(10)+ ' where (RecChq.Dat_RapReceivedChequeToBankDate between '+''''+@FromDate+''''+' and '+''''+@ToDate+''''+')'
if @Flg = 4 
	Set @SqlTxt = @SqlTxt +char(10)+ ' where (RecChq.Dat_RapReceivedChequeToPerDate between '+''''+@FromDate+''''+' and '+''''+@ToDate+''''+')'
if @Flg = 5 
	Set @SqlTxt = @SqlTxt +char(10)+ ' where (RecChq.Dat_RapReceivedChequeBargashtDate between '+''''+@FromDate+''''+' and '+''''+@ToDate+''''+')'
*/
SET @SqlTxt = @SqlTxt + '  ) Ccc  ' + @InternalWhere + ') CalcSel ' + @Where + @Order;
PRINT @SqlTxt;
EXECUTE (@SqlTxt);


GO
ALTER PROCEDURE Tss_RapUntReceivedCheque_HdIudStp
@Err_Code INT OUTPUT, @SiRapReceivedCheque NUMERIC OUTPUT, @SiRapCashDefine NUMERIC=NULL, @SiPubPersonsSpec NUMERIC=NULL, @SiPubCustomCodes NUMERIC=NULL, @Cod_RapReceivedChqBankCode VARCHAR (50)='', @Des_RapReceivedChqBankName VARCHAR (200)='', @Cod_RapReceivedChqBankAccNo VARCHAR (50)='', @Des_RapReceivedChqSeriCode VARCHAR (50)='', @Cod_RapReceivedChequeCode VARCHAR (50)='', @Des_RapReceivedChequeDesc VARCHAR (500)='', @Dat_RapReceivedChequeRegDate VARCHAR (10)='', @Cod_RapReceivedChequeSerial VARCHAR (50)='', @Dat_RapReceivedChequeEndDate VARCHAR (10)='', @Num_RapReceivedChequeAmount NUMERIC=NULL, @Sta_RapReceivedChequeState SMALLINT=0, @Sta_ChekRecieptMainOrNot SMALLINT=0, @Dat_RapReceivedChequeCngDate VARCHAR (10)='', @Dat_RapReceivedChequeVosoolDate VARCHAR (10)='', @Dat_RapReceivedChequeBargashtDate VARCHAR (10)='', @Dat_RapReceivedChequeCancelDate VARCHAR (10)='', @Dat_RapReceivedChequeToPerDate VARCHAR (10)='', @Dat_RapReceivedChequeToBankDate VARCHAR (10)='', @Dat_RapReceivedChequeHoghughiDate VARCHAR (10)='', @Des_RapReceivedChequeRecieptDesc VARCHAR (1500)='', @Dat_RapReceivedChequeToAgainDate VARCHAR (10)='', @Dat_EsterdadToPer VARCHAR (10)='', @Dat_EsterdadToCashier VARCHAR (10)='', @Sta_ConcurrentChek SMALLINT=0, @SiPubSubLocations NUMERIC=1, @SiRapBehalfDefineHd NUMERIC=0, @SiRapRecievedChequeRef_RefrenceHd NUMERIC=0, @Sta_CalcInReturnRep SMALLINT=0, @Des_ReceivedChequeSayadiCode VARCHAR (50)='', @Sta_IsChecqueElectronic SMALLINT=0, @Des_ReceivedChequeSayadiNationalCode VARCHAR (50)='', @Sta_SayadiReg SMALLINT=0, @Des_RecCheqOurSayadiNationalCode VARCHAR (500)='', @Dat_SayadiRegDate VARCHAR (10)='', @StmRapReceivedCheque TIMESTAMP=0, @SiUser NUMERIC, @FlgInsUpdDel SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- Automatically rollback on error
    DECLARE @TransactionCount AS INT = @@TRANCOUNT;
    IF @FlgInsUpdDel = 0 -- INSERT
        BEGIN
            BEGIN TRY
                IF @TransactionCount = 0
                    BEGIN TRANSACTION;
                SET @Err_Code = 0;
                -- Handle code generation with transaction isolation
                IF ISNULL(@Cod_RapReceivedChequeCode, '') = ''
                    BEGIN
                        -- Use UPDLOCK to prevent race conditions
                        SELECT @Cod_RapReceivedChequeCode = MAX(CONVERT (NUMERIC, Cod_RapReceivedChequeCode)) + 1
                        FROM   Tss_RapReceivedCheque WITH (UPDLOCK, HOLDLOCK)
                        WHERE  (SiPubSubLocations = @SiPubSubLocations)
                               AND (Sta_ChekRecieptMainOrNot = @Sta_ChekRecieptMainOrNot)
                               AND (LEFT(Dat_RapReceivedChequeRegDate, 4) = LEFT(@Dat_RapReceivedChequeRegDate, 4))
                               AND (Cod_RapReceivedChequeCode <> '');
                    END
                IF @Cod_RapReceivedChequeCode IS NULL
                   OR @Cod_RapReceivedChequeCode = ''
                    SET @Cod_RapReceivedChequeCode = '1'; -- Default value
                INSERT  INTO dbo.Tss_RapReceivedCheque (SiRapCashDefine, SiPubPersonsSpec, Cod_RapReceivedChequeCode, Des_RapReceivedChequeDesc, Dat_RapReceivedChequeRegDate, Cod_RapReceivedChequeSerial, Dat_RapReceivedChequeEndDate, Num_RapReceivedChequeAmount, Sta_RapReceivedChequeState, Sta_ChekRecieptMainOrNot, Dat_RapReceivedChequeCngDate, SiPubCustomCodes, Cod_RapReceivedChqBankCode, Des_RapReceivedChqBankName, Cod_RapReceivedChqBankAccNo, Des_RapReceivedChqSeriCode, Dat_RapReceivedChequeVosoolDate, Dat_RapReceivedChequeBargashtDate, Dat_RapReceivedChequeCancelDate, Dat_RapReceivedChequeToPerDate, Dat_RapReceivedChequeToBankDate, Dat_RapReceivedChequeHoghughiDate, Dat_RapReceivedChequeToAgainDate, Dat_EsterdadToPer, Dat_EsterdadToCashier, Des_RapReceivedChequeRecieptDesc, SiPubSubLocations, Sta_ConcurrentChek, SiRapBehalfDefineHd, SiRapRecievedChequeRef_RefrenceHd, Sta_CalcInReturnRep, Des_ReceivedChequeSayadiCode, Des_ReceivedChequeSayadiNationalCode, Sta_IsChecqueElectronic, Sta_SayadiReg, Des_RecCheqOurSayadiNationalCode, Dat_SayadiRegDate)
                VALUES                                (@SiRapCashDefine, @SiPubPersonsSpec, @Cod_RapReceivedChequeCode, @Des_RapReceivedChequeDesc, @Dat_RapReceivedChequeRegDate, @Cod_RapReceivedChequeSerial, @Dat_RapReceivedChequeEndDate, @Num_RapReceivedChequeAmount, @Sta_RapReceivedChequeState, @Sta_ChekRecieptMainOrNot, @Dat_RapReceivedChequeCngDate, @SiPubCustomCodes, @Cod_RapReceivedChqBankCode, @Des_RapReceivedChqBankName, @Cod_RapReceivedChqBankAccNo, @Des_RapReceivedChqSeriCode, @Dat_RapReceivedChequeVosoolDate, @Dat_RapReceivedChequeBargashtDate, @Dat_RapReceivedChequeCancelDate, @Dat_RapReceivedChequeToPerDate, @Dat_RapReceivedChequeToBankDate, @Dat_RapReceivedChequeHoghughiDate, @Dat_RapReceivedChequeToAgainDate, @Dat_EsterdadToPer, @Dat_EsterdadToCashier, @Des_RapReceivedChequeRecieptDesc, @SiPubSubLocations, @Sta_ConcurrentChek, @SiRapBehalfDefineHd, @SiRapRecievedChequeRef_RefrenceHd, @Sta_CalcInReturnRep, @Des_ReceivedChequeSayadiCode, @Des_ReceivedChequeSayadiNationalCode, @Sta_IsChecqueElectronic, @Sta_SayadiReg, @Des_RecCheqOurSayadiNationalCode, @Dat_SayadiRegDate);
                SET @SiRapReceivedCheque = SCOPE_IDENTITY();
                IF ISNULL(@SiRapReceivedCheque, 0) <> 0
                    BEGIN
                        -- FIXED: Changed last parameter from 1 to 0 for INSERT mode
                        EXECUTE dbo.Tss_RapUntReceivedCheque_DtIudStp 0, 0, @SiRapReceivedCheque, @SiRapBehalfDefineHd, @SiRapRecievedChequeRef_RefrenceHd, @Num_RapReceivedChequeAmount, 0, @SiUser, 0; -- INSERT mode = 0
                        IF @Err_Code <> 0
                            RAISERROR ('Error in detail insert', 16, 1);
                    END
                IF ISNULL(@SiRapReceivedCheque, 0) = 0
                    BEGIN
                        SET @SiRapReceivedCheque = 0;
                        SET @Err_Code = 400;
                        RAISERROR ('Insert failed', 16, 1);
                    END
                IF @TransactionCount = 0
                    COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @TransactionCount = 0
                   AND XACT_STATE() <> 0
                    ROLLBACK;
                SET @Err_Code = ERROR_NUMBER();
                SET @SiRapReceivedCheque = 0;
                -- Re-throw error for client
                DECLARE @ErrorMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
                RAISERROR (@ErrorMsg, 16, 1);
            END CATCH
        END
    IF @FlgInsUpdDel = 1 -- UPDATE
        BEGIN
            BEGIN TRY
                IF @TransactionCount = 0
                    BEGIN TRANSACTION;
                SET @Err_Code = 0;
                DECLARE @CurrentStmRapReceivedCheque AS INT;
                DECLARE @RowCount AS INT;
                -- Check if record exists with proper locking
                SELECT @CurrentStmRapReceivedCheque = StmRapReceivedCheque
                FROM   dbo.Tss_RapReceivedCheque WITH (UPDLOCK, ROWLOCK)
                WHERE  SiRapReceivedCheque = @SiRapReceivedCheque;
                IF @CurrentStmRapReceivedCheque IS NULL
                    BEGIN
                        SET @Err_Code = 402; -- Record not found
                        RAISERROR ('Record not found', 16, 1);
                    END
                ELSE
                    IF @CurrentStmRapReceivedCheque <> @StmRapReceivedCheque
                        BEGIN
                            SET @Err_Code = 403; -- Concurrency conflict
                            RAISERROR ('Concurrent modification detected', 16, 1);
                        END
                    ELSE
                        BEGIN
                            -- Update main record
                            UPDATE dbo.Tss_RapReceivedCheque
                            SET    SiRapCashDefine                      = @SiRapCashDefine,
                                   SiPubPersonsSpec                     = @SiPubPersonsSpec,
                                   Cod_RapReceivedChequeCode            = @Cod_RapReceivedChequeCode,
                                   Des_RapReceivedChequeDesc            = @Des_RapReceivedChequeDesc,
                                   Dat_RapReceivedChequeRegDate         = @Dat_RapReceivedChequeRegDate,
                                   Cod_RapReceivedChequeSerial          = @Cod_RapReceivedChequeSerial,
                                   Dat_RapReceivedChequeEndDate         = @Dat_RapReceivedChequeEndDate,
                                   Num_RapReceivedChequeAmount          = @Num_RapReceivedChequeAmount,
                                   Sta_RapReceivedChequeState           = @Sta_RapReceivedChequeState,
                                   Sta_ChekRecieptMainOrNot             = @Sta_ChekRecieptMainOrNot,
                                   Dat_RapReceivedChequeCngDate         = GETDATE(),
                                   SiPubCustomCodes                     = @SiPubCustomCodes,
                                   Cod_RapReceivedChqBankCode           = @Cod_RapReceivedChqBankCode,
                                   Des_RapReceivedChqBankName           = @Des_RapReceivedChqBankName,
                                   Cod_RapReceivedChqBankAccNo          = @Cod_RapReceivedChqBankAccNo,
                                   Des_RapReceivedChqSeriCode           = @Des_RapReceivedChqSeriCode,
                                   Dat_RapReceivedChequeVosoolDate      = @Dat_RapReceivedChequeVosoolDate,
                                   Dat_RapReceivedChequeBargashtDate    = @Dat_RapReceivedChequeBargashtDate,
                                   Dat_RapReceivedChequeCancelDate      = @Dat_RapReceivedChequeCancelDate,
                                   Dat_RapReceivedChequeToPerDate       = @Dat_RapReceivedChequeToPerDate,
                                   Dat_RapReceivedChequeToBankDate      = @Dat_RapReceivedChequeToBankDate,
                                   Dat_RapReceivedChequeHoghughiDate    = @Dat_RapReceivedChequeHoghughiDate,
                                   Dat_RapReceivedChequeToAgainDate     = @Dat_RapReceivedChequeToAgainDate,
                                   Dat_EsterdadToPer                    = @Dat_EsterdadToPer,
                                   Dat_EsterdadToCashier                = @Dat_EsterdadToCashier,
                                   Des_RapReceivedChequeRecieptDesc     = @Des_RapReceivedChequeRecieptDesc,
                                   SiPubSubLocations                    = @SiPubSubLocations,
                                   Sta_ConcurrentChek                   = @Sta_ConcurrentChek,
                                   SiRapBehalfDefineHd                  = @SiRapBehalfDefineHd,
                                   SiRapRecievedChequeRef_RefrenceHd    = @SiRapRecievedChequeRef_RefrenceHd,
                                   Sta_CalcInReturnRep                  = @Sta_CalcInReturnRep,
                                   Des_ReceivedChequeSayadiCode         = @Des_ReceivedChequeSayadiCode,
                                   Des_ReceivedChequeSayadiNationalCode = @Des_ReceivedChequeSayadiNationalCode,
                                   Sta_IsChecqueElectronic              = @Sta_IsChecqueElectronic,
                                   Sta_SayadiReg                        = @Sta_SayadiReg,
                                   Des_RecCheqOurSayadiNationalCode     = @Des_RecCheqOurSayadiNationalCode,
                                   Dat_SayadiRegDate                    = @Dat_SayadiRegDate
                            WHERE  SiRapReceivedCheque = @SiRapReceivedCheque
                                   AND StmRapReceivedCheque = @StmRapReceivedCheque;
                            -- Call detail procedure after successful update
                            SELECT @RowCount = COUNT(*)
                            FROM   Tss_RapRecievedChequeRef
                            WHERE  SiRapReceivedCheque = @SiRapReceivedCheque;
                            IF @RowCount = 1
                                BEGIN
                                    DECLARE @SiRapRecievedChequeRef AS NUMERIC, @StmRapRecievedChequeRef AS TIMESTAMP;
                                    SET @SiRapRecievedChequeRef = 0;
                                    SELECT TOP 1 @SiRapRecievedChequeRef = SiRapRecievedChequeRef,
                                                 @StmRapRecievedChequeRef = StmRapRecievedChequeRef
                                    FROM   dbo.Tss_RapRecievedChequeRef
                                    WHERE  SiRapReceivedCheque = @SiRapReceivedCheque;
                                    IF ISNULL(@SiRapReceivedCheque, 0) <> 0
                                        BEGIN
                                            EXECUTE dbo.Tss_RapUntReceivedCheque_DtIudStp 0, @SiRapRecievedChequeRef, @SiRapReceivedCheque, @SiRapBehalfDefineHd, @SiRapRecievedChequeRef_RefrenceHd, @Num_RapReceivedChequeAmount, @StmRapRecievedChequeRef, @SiUser, 1;
                                        END
                                    IF @Err_Code <> 0
                                        RAISERROR ('Error in detail update', 16, 1);
                                END -- Added this END for the IF block
                        END -- Added this END for the ELSE block
                IF @TransactionCount = 0
                    COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @TransactionCount = 0
                   AND XACT_STATE() <> 0
                    ROLLBACK;
                SET @Err_Code = ERROR_NUMBER();
                DECLARE @ErrorMsg2 AS NVARCHAR (4000) = ERROR_MESSAGE();
                RAISERROR (@ErrorMsg2, 16, 1);
            END CATCH
        END
    IF @FlgInsUpdDel = 2 -- DELETE
        BEGIN
            BEGIN TRY
                IF @TransactionCount = 0
                    BEGIN TRANSACTION;
                SET @Err_Code = 0;
                -- Check existence and timestamp
                IF EXISTS (SELECT 1
                           FROM   dbo.Tss_RapReceivedCheque WITH (UPDLOCK, ROWLOCK)
                           WHERE  SiRapReceivedCheque = @SiRapReceivedCheque
                                  AND StmRapReceivedCheque = @StmRapReceivedCheque)
                    BEGIN
                        -- You might want to add a soft delete flag instead of hard delete
                        -- Or check for referential integrity first
                        DELETE dbo.Tss_RapReceivedCheque
                        WHERE  SiRapReceivedCheque = @SiRapReceivedCheque
                               AND StmRapReceivedCheque = @StmRapReceivedCheque;
                        SET @Err_Code = @@ERROR;
                        IF @Err_Code <> 0
                            BEGIN
                                SET @Err_Code = 4000;
                                RAISERROR ('Delete failed', 16, 1);
                            END -- Optionally, also delete related detail records
                     -- EXEC dbo.Tss_RapUntReceivedCheque_DtIudStp ... with FlgInsUpdDel = 2
                    END
                ELSE
                    BEGIN
                        SET @Err_Code = 4000; -- Record not found or timestamp mismatch
                        RAISERROR ('Record not found or concurrency conflict', 16, 1);
                    END
                IF @TransactionCount = 0
                    COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @TransactionCount = 0
                   AND XACT_STATE() <> 0
                    ROLLBACK;
                SET @Err_Code = ERROR_NUMBER();
                DECLARE @ErrorMsg3 AS NVARCHAR (4000) = ERROR_MESSAGE();
                RAISERROR (@ErrorMsg3, 16, 1);
            END CATCH
        END
END


GO
ALTER PROCEDURE Tss_RapUntReceivedCheque_DtVStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)=''
AS
IF @InternalWhere <> ''
    SET @InternalWhere = ' Where ' + @InternalWhere;
IF @Where <> ''
    SET @Where = ' Where ' + @Where;
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
EXECUTE ('Select * From   
   (  
   Select * From (  
      SELECT     rRCR.SiRapRecievedChequeRef, rRCR.SiRapReceivedCheque, rRCR.SiRapBehalfDefine, rRCR.SiVchDtForRecCheck, rRCR.SiVchDtForChekToBank, 
                      rRCR.SiVchDtForChekToPer, rRCR.SiVchDtForVosool, rRCR.SiVchDtForBargasht, rRCR.SiVchDtForEsterdad, rRCR.SiVchDtForTazmini, rRCR.SiVchDtForCashierBargasht,
                      rRCR.Num_RapRecievedChequeRefAmount, 
                      rRCR.SiRapRecievedChequeRef_Refrence, rRCR.StmRapRecievedChequeRef, rBD.Cod_RapBehalfCode, rBD.Des_RapBehalfDesc, 
                      VochDt.Num_VDetRow, VochDt.SiAccVoucher_Hd, Tss_AccVoucher_Dt_1.SiAccVoucher_Hd AS SiVchChekToBank, 
                      Tss_AccVoucher_Dt_2.SiAccVoucher_Hd AS SiVchChekToPer, Tss_AccVoucher_Dt_3.SiAccVoucher_Hd AS SiVchVosool, 
                      Tss_AccVoucher_Dt_4.SiAccVoucher_Hd AS SiVchBargasht, Tss_AccVoucher_Dt_1.Num_VDetRow AS VchRowToBank, 
                      Tss_AccVoucher_Dt_2.Num_VDetRow AS VchRowToPer, Tss_AccVoucher_Dt_3.Num_VDetRow AS VchRowVosool, 
                      Tss_AccVoucher_Dt_4.Num_VDetRow AS VshRowBargasht
FROM         dbo.Tss_AccVoucher_Dt VochDt RIGHT OUTER JOIN
                      dbo.Tss_AccVoucher_Dt Tss_AccVoucher_Dt_4 RIGHT OUTER JOIN
                      dbo.Tss_RapRecievedChequeRef rRCR INNER JOIN
                      dbo.Tss_RapBehalfDefine rBD ON rRCR.SiRapBehalfDefine = rBD.SiRapBehalfDefine ON 
                      Tss_AccVoucher_Dt_4.SiAccVoucher_Dt = rRCR.SiVchDtForBargasht LEFT OUTER JOIN
                      dbo.Tss_AccVoucher_Dt Tss_AccVoucher_Dt_3 ON rRCR.SiVchDtForVosool = Tss_AccVoucher_Dt_3.SiAccVoucher_Dt LEFT OUTER JOIN
                      dbo.Tss_AccVoucher_Dt Tss_AccVoucher_Dt_2 ON rRCR.SiVchDtForChekToPer = Tss_AccVoucher_Dt_2.SiAccVoucher_Dt LEFT OUTER JOIN
                      dbo.Tss_AccVoucher_Dt Tss_AccVoucher_Dt_1 ON rRCR.SiVchDtForChekToBank = Tss_AccVoucher_Dt_1.SiAccVoucher_Dt ON 
                      VochDt.SiAccVoucher_Dt = rRCR.SiVchDtForRecCheck
         ) Ccc  ' + @InternalWhere + '  
         ) CalcSel ' + @Where + @Order);


GO
ALTER PROCEDURE Tss_SalGoodsPriceCalcStp
@SiSalInvoice_Dt NUMERIC, @SiPubGoodsClassify NUMERIC, @Num_SampleInnerHeigth NUMERIC, @Num_ColoringRate INT, @Num_SampleHoleNo INT, @Sta_HasMangene SMALLINT, @Sta_EttesalType SMALLINT, @Num_FeeAdjust NUMERIC, @Sta_DieOrNot SMALLINT, @Sta_TipOfGoodsType SMALLINT, @TolSheet NUMERIC, @ArzSheet NUMERIC, @Area FLOAT, @Sta_Cyan SMALLINT, @Sta_Magenta SMALLINT, @Sta_Yellow SMALLINT, @Sta_Black SMALLINT, @Sta_HasVerni SMALLINT, @Sta_PackType SMALLINT, @Num_OneMeterSheetPrice NUMERIC, @Num_OneMeterBoxPrice NUMERIC, @Sta_IsFeeAdjustPercent SMALLINT, @Num_NoInPallete NUMERIC, @AmountNo NUMERIC, @CellophaneType SMALLINT, @LaminateType SMALLINT, @MatteOrGlossy SMALLINT, @NoGdsInDie SMALLINT, @SiPrcGoodsType NUMERIC, @SiPubGoodsClassifyCardBox NUMERIC, @OffsetAreaType SMALLINT, @OffsetHeightPrint NUMERIC, @PunchNo NUMERIC, @Prod_P NUMERIC OUTPUT, @ColorFee NUMERIC OUTPUT, @CardBoxPrice NUMERIC OUTPUT, @PalleteFee NUMERIC OUTPUT, @DieCut_Fee NUMERIC OUTPUT, @Laminate_Fee NUMERIC OUTPUT, @OffSet_Fee NUMERIC OUTPUT, @LaminateWage NUMERIC OUTPUT, @CellophoneGlueMatteCost NUMERIC OUTPUT, @CellophoneGlueGlossyCost NUMERIC OUTPUT, @CellophoneThermalMatteCost NUMERIC OUTPUT, @CellophoneThermalGlossyCost NUMERIC OUTPUT, @LaminateBoxLockBottomCost NUMERIC OUTPUT, @LaminateBoxTwoPieceCost NUMERIC OUTPUT, @FeeHaml NUMERIC OUTPUT
AS
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_NULLS ON;
SET ANSI_NULL_DFLT_ON ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET QUOTED_IDENTIFIER ON;
--Declare  
--   @SiSalInvoice_Dt numeric  
--Set @SiSalInvoice_Dt=7  
/*  
@P01=طول شيت   
@P02=عرض شيت  
@P03=ارتفاع شيت  
@P04=نرخ مصوب  
@P05=قيمت منگنه  
@P06=قيمت منفذ  
@P07=تعداد منفذ  
@P08=هزينه دايكات  
@P09=تعداد در قالب  
@P10=هزينه رنگ  
@P11=درصد رنگ خوري  
@P12=هزينه رنگ تا 1 متر  
@P13=هزينه رنگ بالاي 1 متر و تا 50 درصد رنگ خوري  
@P14=هزينه رنگ بالاي 1 متر و بالاي 50 درصد رنگ خوري  
@P15=هزينه رنگ هافتون سيان
@P16=هزينه رنگ هافتون مگنتا
@P17=هزينه رنگ هافتون زرد
@P18=هزينه رنگ هافتون سياه
@P19=هزينه ورني
@P20=هزينه پالت شرينگ
@P21=بهاي پالت جهت مساحت کالا بالاي 3 متر مربع
@P22=بهاي پالت جهت مساحت کالا زير3 متر مربع

@P23=هزينه يک متر مربع مقوا
@P24=دستمزد يک متر مربع لمينت کردن
@P25=هزينه هاي يک متر مربع سلوفون
@P26=هزينه سلوفون چسبي مات
@P27=هزينه سلوفون چسبي براق
@P28=هزينه سلوفون حرارتي مات
@P29=هزينه سلوفون حرارتي براق
@P30=هزينه ته قفلي  کارتن لمينت
@P31=هزنيه کارتن لمينت دو تکه
@P32=هزينه چاپ پوستر گروه 70 در 100
@P33=هزينه چاپ پوستر 100 در 140
@P34=هزينه چاپ پوستر 120 در 160
@P37= هزینه چاپ پوستر 50 در 70
@P39= هزینه چاپ پوستر 75 در 105
@P35= هزينه تسمه
@P36= هزينه حمل

*/
/*  
if (@Sta_EttesalType=3) or (@Sta_EttesalType=4) or (@Sta_EttesalType=5)
	Set @Sta_HasMangene = 1
else
	Set @Sta_HasMangene = 0
*/
DECLARE @TmpTbl TABLE (
    f_Abbr VARCHAR (10),
    f_Val  VARCHAR (50));
DECLARE @P01 AS VARCHAR (50), @P02 AS VARCHAR (50), @P03 AS VARCHAR (50), @P04 AS VARCHAR (50), @P05 AS VARCHAR (50), @P06 AS VARCHAR (50), @P07 AS VARCHAR (50), @P08 AS VARCHAR (50), @P09 AS VARCHAR (50), @P10 AS VARCHAR (50), @P11 AS VARCHAR (50), @P12 AS VARCHAR (50), @P13 AS VARCHAR (50), @P14 AS VARCHAR (50), @P15 AS VARCHAR (50), @P16 AS VARCHAR (50), @P17 AS VARCHAR (50), @P18 AS VARCHAR (50), @P19 AS VARCHAR (50), @P20 AS VARCHAR (50), @P21 AS VARCHAR (50), @P22 AS VARCHAR (50), @P23 AS VARCHAR (50), @P24 AS VARCHAR (50), @P25 AS VARCHAR (50), @P26 AS VARCHAR (50), @P27 AS VARCHAR (50), @P28 AS VARCHAR (50), @P29 AS VARCHAR (50), @P30 AS VARCHAR (50), @P31 AS VARCHAR (50), @P32 AS VARCHAR (50), @P33 AS VARCHAR (50), @P34 AS VARCHAR (50), @P35 AS VARCHAR (50), @P36 AS VARCHAR (50), @P37 AS VARCHAR (50), @P38 AS VARCHAR (50), @P39 AS VARCHAR (50), @P40 AS VARCHAR (50), @P1 AS VARCHAR (50), @SqlTxt AS NVARCHAR (4000), @iCount AS INT, @TmpStr AS VARCHAR (500), @TmpH AS VARCHAR (20), --   @Num_OneMeterSheetPrice Numeric,   
--   @Num_OneMeterBoxPrice Numeric,  
@Prod_Area AS NUMERIC, @PriceOfBoxFormula AS VARCHAR (500), @Gds_Area AS NUMERIC (18, 3), @c_Pr AS NUMERIC, @k_Tmp AS VARCHAR (50), @HasHafton AS SMALLINT, @Num_GdsAmountNo AS NUMERIC, @Sta_CellophaneType AS SMALLINT, @Sta_MatteOrGlossy AS SMALLINT, @Sta_LaminateType AS SMALLINT, @CeloMatteOrGlossyCost AS NUMERIC, @PosterPrintCost AS NUMERIC, @Num_NoGdsInDie AS SMALLINT, @Num_OneMeterCardBoxPrice AS NUMERIC, @TolSheetLaminate AS NUMERIC, @ArzSheetLaminate AS NUMERIC, @SiInvVehicles AS NUMERIC, @Num_NoInVehicle AS NUMERIC, @SiPubPersonsSpec AS NUMERIC, @SiPubGeoPlac AS NUMERIC, @Num_VehicleHamlCost AS NUMERIC, @Sta_TransportState AS SMALLINT, --@FeeHaml numeric,
@SiPrcPackagingTypes AS NUMERIC, @Num_PackagingTypesCost AS NUMERIC, @FeePallete AS NUMERIC;
IF @SiSalInvoice_Dt > 0
    BEGIN
        SELECT @Num_GdsAmountNo = Tss_SalInvoice_Dt.Num_GdsAmountNo,
               @Sta_CellophaneType = Tss_SalInvoice_Dt.Sta_CellophaneType,
               @Sta_MatteOrGlossy = Tss_SalInvoice_Dt.Sta_MatteOrGlossy,
               @Sta_LaminateType = Tss_PrcGoodsType.Sta_LaminateType,
               @Num_NoGdsInDie = isnull(dbo.Tss_PrcDieSpec.Num_NoGdsInDie, 1),
               @SiInvVehicles = SiInvVehicles,
               @Num_NoInVehicle = Num_NoInVehicle,
               @SiPubPersonsSpec = Tss_SalInvoice_Hd.SiPubPersonsSpec,
               @Sta_TransportState = Tss_SalInvoice_Hd.Sta_TransportState,
               @SiPrcPackagingTypes = Tss_SalInvoice_Dt.SiPrcPackagingTypes
        FROM   Tss_SalInvoice_Dt
               INNER JOIN
               Tss_PrcGoodsType
               ON Tss_SalInvoice_Dt.SiPrcGoodsType = Tss_PrcGoodsType.SiPrcGoodsType
               LEFT OUTER JOIN
               Tss_PrcDieSpec
               ON Tss_SalInvoice_Dt.SiPrcDieSpec = Tss_PrcDieSpec.SiPrcDieSpec
               INNER JOIN
               Tss_SalInvoice_Hd
               ON Tss_SalInvoice_Dt.SiSalInvoice_Hd = Tss_SalInvoice_Hd.SiSalInvoice_Hd
        WHERE  (Tss_SalInvoice_Dt.SiSalInvoice_Dt = @SiSalInvoice_Dt);
        SELECT @SiPubGeoPlac = Tss_PubGeoPlac.SiPubGeoPlac
        FROM   Tss_PubPersonsSpec
               INNER JOIN
               Tss_PubGeoPlac
               ON Tss_PubPersonsSpec.SiPubGeoPlacCity = Tss_PubGeoPlac.SiPubGeoPlac
        WHERE  (Tss_PubPersonsSpec.SiPubPersonsSpec = @SiPubPersonsSpec);
        SET @Num_PackagingTypesCost = 0;
        SELECT @Num_PackagingTypesCost = isnull(Num_PackagingTypesCost, 0)
        FROM   Tss_PrcPackagingTypes
        WHERE  (SiPrcPackagingTypes = @SiPrcPackagingTypes);
        SET @FeePallete = round(@Num_PackagingTypesCost / @Num_NoInPallete, -1, 0);
        SET @PalleteFee = round(@Num_PackagingTypesCost / @Num_NoInPallete, -1, 0);
        IF EXISTS (SELECT *
                   FROM   Tss_InvVehiclesDt
                   WHERE  (SiInvVehicles = @SiInvVehicles)
                          AND (SiPubGeoPlacCity = @SiPubGeoPlac))
            BEGIN
                SELECT @Num_VehicleHamlCost = isnull(Num_VehicleHamlCost, 0)
                FROM   Tss_InvVehiclesDt
                WHERE  (SiInvVehicles = @SiInvVehicles)
                       AND (SiPubGeoPlacCity = @SiPubGeoPlac);
                IF @Sta_TransportState = 1
                    SET @FeeHaml = round(@Num_VehicleHamlCost / @Num_NoInVehicle, -1, 0);
            END
        ELSE
            SET @FeeHaml = 0;
    END
ELSE
    BEGIN
        SET @Num_GdsAmountNo = @AmountNo;
        SET @Sta_CellophaneType = @CellophaneType;
        SET @Sta_MatteOrGlossy = @MatteOrGlossy;
        SET @Num_NoGdsInDie = @NoGdsInDie;
        SET @SiInvVehicles = NULL;
        SET @Num_NoInVehicle = 0;
        SELECT @Sta_LaminateType = @LaminateType
        FROM   dbo.Tss_PrcGoodsType
        WHERE  (SiPrcGoodsType = @SiPrcGoodsType);
    END
IF @Sta_LaminateType = 3
    SET @Sta_HasVerni = 0;
ELSE
    SET @Sta_HasVerni = 1;
SET @HasHafton = 0;
IF @Sta_Cyan = 1
    SET @HasHafton = 1;
IF @Sta_Magenta = 1
    SET @HasHafton = 1;
IF @Sta_Yellow = 1
    SET @HasHafton = 1;
IF @Sta_Black = 1
    SET @HasHafton = 1;
SET @Prod_P = 0;
SET @Prod_Area = 0;
SET @Num_FeeAdjust = 0;
SELECT @P40 = ltrim(rtrim(dbo.Tss_StdFindSystemParamValue('ProfitPercentage')));
SET @P40 = '0.' + @P40;
SET @P03 = CONVERT (VARCHAR (10), @Num_SampleInnerHeigth);
IF isnull(@PunchNo, 0) > 0
    SET @P03 = @PunchNo * 50;
ELSE
    SET @P03 = @Num_SampleInnerHeigth;
IF ((isnull(@Num_OneMeterSheetPrice, 0) = 0)
    AND (isnull(@Num_OneMeterBoxPrice, 0) = 0))
    BEGIN
        SELECT   TOP 1 @Num_OneMeterSheetPrice = Num_OneMeterSheetPrice,
                       @Num_OneMeterBoxPrice = Num_OneMeterBoxPrice
        FROM     Tss_PubSalGoodsPrices
        WHERE    (SiPubGoodsClassify = @SiPubGoodsClassify)
                 AND (Sta_SalGoodsPricesEnabled = 1)
        ORDER BY Dat_GoodsPricesEffDate DESC;
    END
IF (@Sta_TipOfGoodsType = 0)
   OR (@Sta_TipOfGoodsType = 5)
    BEGIN
        SELECT @PriceOfBoxFormula = Des_SysParamsValue
        FROM   Tss_StdAllSystemParams
        WHERE  (SiStdSystemsList = 20)
               AND (Des_SysParamsName = 'PriceOfBoxFormula');
        SELECT @P04 = Ltrim(Rtrim(Str(@Num_OneMeterBoxPrice))) + '.00';
    END
IF (@Sta_TipOfGoodsType = 1)
   OR (@Sta_TipOfGoodsType = 3)
   OR (@Sta_TipOfGoodsType = 6)
    BEGIN
        SELECT @PriceOfBoxFormula = Des_SysParamsValue
        FROM   Tss_StdAllSystemParams
        WHERE  (SiStdSystemsList = 20)
               AND (Des_SysParamsName = 'PriceOfSheetFormula');
        SELECT @P04 = Ltrim(Rtrim(Str(@Num_OneMeterSheetPrice))) + '.00';
    END
IF (@Sta_TipOfGoodsType = 4)
    BEGIN
        SELECT @PriceOfBoxFormula = Des_SysParamsValue
        FROM   Tss_StdAllSystemParams
        WHERE  (SiStdSystemsList = 20)
               AND (Des_SysParamsName = 'PriceOfSheetFormula');
        SELECT @P04 = Ltrim(Rtrim(Str((@Num_OneMeterSheetPrice + @Num_OneMeterBoxPrice) / 2))) + '.00';
    END
IF (isnull(@Num_SampleHoleNo, 0) > 0)
   AND (@Sta_DieOrNot = 0)
    SET @Num_SampleHoleNo = 1;
ELSE
    IF (isnull(@Num_SampleHoleNo, 0) > 0)
       AND (@Sta_DieOrNot = 1)
        SET @Num_SampleHoleNo = 0;
SET @Num_OneMeterCardBoxPrice = 0;
SELECT   TOP 1 @Num_OneMeterCardBoxPrice = Num_OneMeterSheetPrice,
               @Num_OneMeterCardBoxPrice = Num_OneMeterBoxPrice
FROM     Tss_PubSalGoodsPrices
WHERE    (SiPubGoodsClassify = @SiPubGoodsClassifyCardBox)
         AND (Sta_SalGoodsPricesEnabled = 1)
ORDER BY Dat_GoodsPricesEffDate DESC;
SELECT @TolSheetLaminate = Ltrim(Rtrim(Str(@TolSheet)));
SELECT @ArzSheetLaminate = Ltrim(Rtrim(Str(@ArzSheet)));
SELECT @P01 = Ltrim(Rtrim(Str(@TolSheet)));
SELECT @P02 = Ltrim(Rtrim(Str(@ArzSheet)));
SELECT @P05 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'PunchUnitPrice');
SELECT @P06 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'HolePrice');
SELECT @P07 = Ltrim(Rtrim(Str(@Num_SampleHoleNo)));
SELECT @P08 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'DieCutPrice');
SELECT @P09 = CONVERT (VARCHAR, isnull(@Num_NoGdsInDie, 1));
SELECT @P11 = Ltrim(Rtrim(Str(@Num_ColoringRate)));
SELECT @P12 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'OneMeterColorPrice');
SELECT @P13 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'UpOneMeterTo50ColorPrice');
SELECT @P14 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'UpOneMeterUp50ColorPrice');
SELECT @P15 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'CyanPrice');
SELECT @P16 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'MagentaPrice');
SELECT @P17 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'YellowPrice');
SELECT @P18 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'BlackPrice');
SELECT @P19 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'VerniPrice');
IF dbo.Tss_StdFindSubLoc(0) <> 'Caspian'
    BEGIN
        SELECT @P20 = ltrim(rtrim(Str(isnull(@FeePallete, 0))));
        --SELECT @P20=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'PalleteShrinkPrice')  
        SELECT @P21 = Des_SysParamsValue
        FROM   Tss_StdAllSystemParams
        WHERE  (SiStdSystemsList = 20)
               AND (Des_SysParamsName = 'PalleteFeeForOver3m');
        SELECT @P22 = Des_SysParamsValue
        FROM   Tss_StdAllSystemParams
        WHERE  (SiStdSystemsList = 20)
               AND (Des_SysParamsName = 'PalleteFeeForUnder3m');
    END
ELSE
    BEGIN
        SELECT @P20 = ltrim(rtrim(Str(isnull(@FeePallete, 0)))) + '.00';
        SELECT @P21 = 0;
        SELECT @P22 = 0;
    END
--print @FeePallete
--Set @PalleteFee=Convert(numeric,@P20)  
IF dbo.Tss_StdFindSubLoc(0) = 'Caspian'
    BEGIN
        SET @P36 = ltrim(rtrim(Str(@FeeHaml))) + '.00';
    END
ELSE
    BEGIN
        SET @P36 = '0';
    END
--SELECT @P23=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'CardboardFee') 
SELECT @P23 = @Num_OneMeterCardBoxPrice;
SELECT @P24 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'LaminateOneMeteWage');
SELECT @P25 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'CellophoneOneMeterCost');
SELECT @P26 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'CellophoneGlueMatteCost');
SELECT @P27 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'CellophoneGlueGlossyCost');
SELECT @P28 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'CellophoneThermalMatteCost');
SELECT @P29 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'CellophoneThermalGlossyCost');
SELECT @P30 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'LaminateBoxLockBottomCost');
SELECT @P31 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'LaminateBoxTwoPieceCost');
SELECT @P32 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'PosterPrintCostGroup1');
SELECT @P33 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'PosterPrintCostGroup2');
SELECT @P34 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'PosterPrintCostGroup3');
SELECT @P37 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'PosterPrintCostGroup0');
SELECT @P39 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'PosterPrintCostGroup4');
SELECT @P38 = Des_SysParamsValue
FROM   Tss_StdAllSystemParams
WHERE  (SiStdSystemsList = 20)
       AND (Des_SysParamsName = 'LabchasbPrice');
IF isnull(@Sta_PackType, 0) = 1
    SELECT @P35 = Des_SysParamsValue
    FROM   Tss_StdAllSystemParams
    WHERE  (SiStdSystemsList = 20)
           AND (Des_SysParamsName = 'StrapCost');
ELSE
    SET @P35 = 0;
/*if @Sta_Cyan=0
	Set @P15='0'
if @Sta_Magenta=0
	Set @P16='0'
if @Sta_Yellow=0
	Set @P17='0'
if @Sta_Black=0
	Set @P18='0'
*/
--------------------------------------محاسبات لمينه
IF @Sta_HasVerni = 0
    SET @P19 = '0';
ELSE
    BEGIN
        IF (@Sta_CellophaneType = 0)
           AND (@Sta_MatteOrGlossy = 0)
            BEGIN
                SET @CeloMatteOrGlossyCost = isnull(CONVERT (NUMERIC, @P26), 0);
                SET @P27 = '0';
                SET @P28 = '0';
                SET @P29 = '0';
            END
        IF (@Sta_CellophaneType = 0)
           AND (@Sta_MatteOrGlossy = 1)
            BEGIN
                SET @CeloMatteOrGlossyCost = isnull(CONVERT (NUMERIC, @P27), 0);
                SET @P26 = '0';
                SET @P28 = '0';
                SET @P29 = '0';
            END
        IF (@Sta_CellophaneType = 1)
           AND (@Sta_MatteOrGlossy = 0)
            BEGIN
                SET @CeloMatteOrGlossyCost = isnull(CONVERT (NUMERIC, @P28), 0);
                SET @P26 = '0';
                SET @P27 = '0';
                SET @P29 = '0';
            END
        IF (@Sta_CellophaneType = 1)
           AND (@Sta_MatteOrGlossy = 1)
            BEGIN
                SET @CeloMatteOrGlossyCost = isnull(CONVERT (NUMERIC, @P29), 0);
                SET @P26 = '0';
                SET @P27 = '0';
                SET @P28 = '0';
            END
        IF (@Sta_LaminateType = 1)
            SET @P31 = '0';
        IF (@Sta_LaminateType = 2)
            SET @P30 = '0';
        IF (@Sta_LaminateType = 0)
            SET @P31 = '0';
        IF (@Sta_LaminateType = 0)
            SET @P30 = '0';
        /*	if (@Sta_CellophaneType = 2) Set @P25 = '0'
	if (@Sta_CellophaneType = 2) Set @P26 = '0'
	if (@Sta_CellophaneType = 2) Set @P27 = '0'
	if (@Sta_CellophaneType = 2) Set @P28 = '0'
	if (@Sta_CellophaneType = 2) Set @P29 = '0'
*/
        --@P32=هزينه چاپ پوستر گروه 70 در 100
        --@P33=هزينه چاپ پوستر 100 در 140
        --@P34=هزينه چاپ پوستر 120 در 160
        --@P37= هزینه چاپ پوستر 50 در 70
        --@P39= هزینه چاپ پوستر 75 در 105
        IF (@TolSheet > @ArzSheet)
            BEGIN
                IF @OffsetAreaType = 1
                    SET @ArzSheetLaminate = @OffsetHeightPrint;
                IF ((@TolSheetLaminate <= 700)
                    AND (@ArzSheetLaminate <= 500))
                    --	if (@TolSheet*@ArzSheet)<=700000
                    BEGIN
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) < 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P37), 0) / (@Num_GdsAmountNo / @Num_NoGdsInDie), 0) / @Num_NoGdsInDie;
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) >= 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P37), 0) / (5000), 0) / @Num_NoGdsInDie; --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
                    END
                IF ((@TolSheetLaminate <= 1000)
                    AND (@ArzSheetLaminate <= 700))
                    --	if (@TolSheet*@ArzSheet)<=700000
                    BEGIN
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) < 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P32), 0) / (@Num_GdsAmountNo / @Num_NoGdsInDie), 0) / @Num_NoGdsInDie;
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) >= 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P32), 0) / (5000), 0) / @Num_NoGdsInDie; --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
                    END
                --	if ((@TolSheetLaminate>1000) or (@ArzSheetLaminate>700)) and ((@TolSheetLaminate<=1400) and (@ArzSheetLaminate<=1000))
                IF ((@TolSheetLaminate <= 1400)
                    AND (@ArzSheetLaminate <= 1000))
                    BEGIN
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) < 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P33), 0) / (@Num_GdsAmountNo / @Num_NoGdsInDie), 0) / @Num_NoGdsInDie;
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) >= 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P33), 0) / (5000), 0) / @Num_NoGdsInDie; --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
                    END
                --	if ((@TolSheetLaminate>1400) or (@ArzSheetLaminate>1000)) and ((@TolSheetLaminate<=1600) and (@ArzSheetLaminate<=1200))
                IF ((@TolSheetLaminate <= 1600)
                    AND (@ArzSheetLaminate <= 1200))
                    BEGIN
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) < 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P34), 0) / (@Num_GdsAmountNo / @Num_NoGdsInDie), 0) / @Num_NoGdsInDie;
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) >= 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P34), 0) / (5000), 0) / @Num_NoGdsInDie; --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
                    END
            END
        ELSE
            BEGIN
                IF @OffsetAreaType = 1
                    SET @TolSheetLaminate = @OffsetHeightPrint;
                IF ((@TolSheetLaminate <= 500)
                    AND (@ArzSheetLaminate <= 700))
                    --	if (@TolSheet*@ArzSheet)<=700000
                    BEGIN
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) < 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P37), 0) / (@Num_GdsAmountNo / @Num_NoGdsInDie), 0) / @Num_NoGdsInDie;
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) >= 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P37), 0) / (5000), 0) / @Num_NoGdsInDie; --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
                    END
                IF ((@TolSheetLaminate <= 700)
                    AND (@ArzSheetLaminate <= 1000))
                    --	if (@TolSheet*@ArzSheet)<=700000
                    BEGIN
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) < 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P32), 0) / (@Num_GdsAmountNo / @Num_NoGdsInDie), 0) / @Num_NoGdsInDie;
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) >= 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P32), 0) / (5000), 0) / @Num_NoGdsInDie; --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
                    END
                --	if ((@TolSheetLaminate>700) or (@ArzSheetLaminate>1000)) and ((@TolSheetLaminate<=1000) and (@ArzSheetLaminate<=1400))
                --	if ((@TolSheet*@ArzSheet)>700000) AND ((@TolSheet*@ArzSheet)<=1400000)
                IF ((@TolSheetLaminate <= 1000)
                    AND (@ArzSheetLaminate <= 1400))
                    BEGIN
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) < 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P33), 0) / (@Num_GdsAmountNo / @Num_NoGdsInDie), 0) / @Num_NoGdsInDie;
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) >= 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P33), 0) / (5000), 0) / @Num_NoGdsInDie; --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
                    END
                --	if ((@TolSheetLaminate>1000) or (@ArzSheetLaminate>1400)) and ((@TolSheetLaminate<=1200) and (@ArzSheetLaminate<=1600))
                --	if ((@TolSheet*@ArzSheet)>1400000) AND ((@TolSheet*@ArzSheet)<=1920000)
                IF ((@TolSheetLaminate <= 1200)
                    AND (@ArzSheetLaminate <= 1600))
                    BEGIN
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) < 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P34), 0) / (@Num_GdsAmountNo / @Num_NoGdsInDie), 0) / @Num_NoGdsInDie;
                        IF (@Num_GdsAmountNo / @Num_NoGdsInDie) >= 5000
                            SET @PosterPrintCost = round(isnull(CONVERT (NUMERIC, @P34), 0) / (5000), 0) / @Num_NoGdsInDie; --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
                    END
            END
        IF (@Sta_CellophaneType = 2)
            SET @P19 = (((@TolSheetLaminate * @ArzSheetLaminate) / (1000000 * @Num_NoGdsInDie)) * (CONVERT (NUMERIC, @P23) + CONVERT (NUMERIC, @P24) + CONVERT (NUMERIC, @P25))) + (CONVERT (NUMERIC, @P30) + CONVERT (NUMERIC, @P31)) + (isnull(@PosterPrintCost, 0));
        ELSE
            SET @P19 = (((@TolSheetLaminate * @ArzSheetLaminate) / (1000000 * @Num_NoGdsInDie)) * (CONVERT (NUMERIC, @P23) + CONVERT (NUMERIC, @P24) + CONVERT (NUMERIC, @P25) + CONVERT (NUMERIC, @P26) + CONVERT (NUMERIC, @P27) + CONVERT (NUMERIC, @P28) + CONVERT (NUMERIC, @P29))) + (CONVERT (NUMERIC, @P30) + CONVERT (NUMERIC, @P31)) + (isnull(@PosterPrintCost, 0));
        SET @P19 = @P19 * (CONVERT (NUMERIC, dbo.Tss_StdFindSystemParamValue('ProfitPercentage')) + 100) / 100;
        SET @Laminate_Fee = isnull(@P19, 0);
        SET @CardBoxPrice = ((@TolSheetLaminate * @ArzSheetLaminate) / (1000000 * @Num_NoGdsInDie)) * (CONVERT (NUMERIC, @P23)) * (CONVERT (NUMERIC, dbo.Tss_StdFindSystemParamValue('ProfitPercentage')) + 100) / 100;
        SET @OffSet_Fee = (isnull(@PosterPrintCost, 0)) * (CONVERT (NUMERIC, dbo.Tss_StdFindSystemParamValue('ProfitPercentage')) + 100) / 100;
        SET @LaminateWage = ((@TolSheetLaminate * @ArzSheetLaminate) / (1000000 * @Num_NoGdsInDie)) * (CONVERT (NUMERIC, @P24)) * (CONVERT (NUMERIC, dbo.Tss_StdFindSystemParamValue('ProfitPercentage')) + 100) / 100;
        SET @CellophoneGlueMatteCost = ((@TolSheetLaminate * @ArzSheetLaminate) / 1000000) * (CONVERT (NUMERIC, @P26)) * (CONVERT (NUMERIC, dbo.Tss_StdFindSystemParamValue('ProfitPercentage')) + 100) / 100;
        SET @CellophoneGlueGlossyCost = ((@TolSheetLaminate * @ArzSheetLaminate) / 1000000) * (CONVERT (NUMERIC, @P27)) * (CONVERT (NUMERIC, dbo.Tss_StdFindSystemParamValue('ProfitPercentage')) + 100) / 100;
        SET @CellophoneThermalMatteCost = ((@TolSheetLaminate * @ArzSheetLaminate) / 1000000) * (CONVERT (NUMERIC, @P28)) * (CONVERT (NUMERIC, dbo.Tss_StdFindSystemParamValue('ProfitPercentage')) + 100) / 100;
        SET @CellophoneThermalGlossyCost = ((@TolSheetLaminate * @ArzSheetLaminate) / 1000000) * (CONVERT (NUMERIC, @P29)) * (CONVERT (NUMERIC, dbo.Tss_StdFindSystemParamValue('ProfitPercentage')) + 100) / 100;
        SET @LaminateBoxLockBottomCost = (CONVERT (NUMERIC, @P30)) * (CONVERT (NUMERIC, dbo.Tss_StdFindSystemParamValue('ProfitPercentage')) + 100) / 100;
        SET @LaminateBoxTwoPieceCost = (CONVERT (NUMERIC, @P31)) * (CONVERT (NUMERIC, dbo.Tss_StdFindSystemParamValue('ProfitPercentage')) + 100) / 100;
    END
--------------------------------------محاسبات لمينه
IF @Sta_HasMangene = 0
    SET @P05 = '0';
IF @Sta_EttesalType <> 1
    SET @P38 = '0';
--If @Sta_HasVerni=1  
-- Set @P05='0'  
IF ((@Sta_PackType = 0)
    OR (@Sta_PackType = 1))
    SET @P20 = '0';
SET @DieCut_Fee = 0;
IF @Sta_DieOrNot = 1
    BEGIN
        IF @P09 >= 1
            SET @DieCut_Fee = Round(CONVERT (INT, @P08) / CONVERT (FLOAT, @P09), 0);
        ELSE
            SET @DieCut_Fee = Round(CONVERT (INT, @P08) * 2, 0);
    END
ELSE
    SET @P08 = '0';
SET @c_Pr = 0;
IF dbo.Tss_StdFindSubLoc(0) <> 'Caspian'
    SET @P20 = CONVERT (INT, @P20) * (@TolSheet * @ArzSheet) / 1000000;
IF (dbo.Tss_StdFindSubLoc(0) <> 'Caspian')
   AND (@Num_NoInPallete > 0)
    BEGIN
        IF ((@TolSheet * @ArzSheet) / 1000000) >= 3
            BEGIN
                IF @Num_NoInPallete * ((@TolSheet * @ArzSheet) / 1000000) > 500
                    SET @P20 = (@P21 / @Num_NoInPallete);
                ELSE
                    SET @P20 = (500 / (@Num_NoInPallete * ((@TolSheet * @ArzSheet) / 1000000))) * (@P21 / 500) * ((@TolSheet * @ArzSheet) / 1000000);
            END
        ELSE
            BEGIN
                IF @Num_NoInPallete * ((@TolSheet * @ArzSheet) / 1000000) > 500
                    SET @P20 = (@P22 / @Num_NoInPallete);
                ELSE
                    SET @P20 = (500 / (@Num_NoInPallete * ((@TolSheet * @ArzSheet) / 1000000))) * (@P22 / 500) * ((@TolSheet * @ArzSheet) / 1000000);
            END
    END
IF ((@Sta_PackType = 0)
    OR (@Sta_PackType = 1))
    SET @P20 = '0';
SET @c_Pr = CONVERT (INT, @P12) * isnull(@Num_ColoringRate, 0) / 100 * (@TolSheet * @ArzSheet) / 1000000;
IF (@Num_ColoringRate = 0)
   AND (@Sta_HasVerni = 0)
    SET @c_Pr = 0;
IF (@Num_ColoringRate = 0)
   AND (@HasHafton = 1)
    BEGIN
        SET @c_Pr = 0;
    END
SET @P15 = '0';
SET @P16 = '0';
SET @P17 = '0';
SET @P18 = '0';
--	Set @P19='0'
--------
SET @P10 = Ltrim(Rtrim(Str(@c_Pr)));
INSERT INTO @TmpTbl (f_Abbr, f_Val)
SELECT *
FROM   (SELECT '@P01' AS abbr,
               @P01 AS fVal
        UNION ALL
        SELECT '@P02' AS abbr,
               @P02 AS fVal
        UNION ALL
        SELECT '@P03' AS abbr,
               @P03 AS fVal
        UNION ALL
        SELECT '@P04' AS abbr,
               @P04 AS fVal
        UNION ALL
        SELECT '@P05' AS abbr,
               @P05 AS fVal
        UNION ALL
        SELECT '@P06' AS abbr,
               @P06 AS fVal
        UNION ALL
        SELECT '@P07' AS abbr,
               @P07 AS fVal
        UNION ALL
        SELECT '@P08' AS abbr,
               @P08 AS fVal
        UNION ALL
        SELECT '@P09' AS abbr,
               @P09 AS fVal
        UNION ALL
        SELECT '@P10' AS abbr,
               @P10 AS fVal
        UNION ALL
        SELECT '@P15' AS abbr,
               @P15 AS fVal
        UNION ALL
        SELECT '@P19' AS abbr,
               @P19 AS fVal
        UNION ALL
        SELECT '@P20' AS abbr,
               @P20 AS fVal
        UNION ALL
        SELECT '@P35' AS abbr,
               @P35 AS fVal
        UNION ALL
        SELECT '@P36' AS abbr,
               @P36 AS fVal
        UNION ALL
        SELECT '@P16' AS abbr,
               @P16 AS fVal
        UNION ALL
        SELECT '@P17' AS abbr,
               @P17 AS fVal
        UNION ALL
        SELECT '@P18' AS abbr,
               @P18 AS fVal
        UNION ALL
        SELECT '@P38' AS abbr,
               @P38 AS fVal
        UNION ALL
        SELECT '@P40' AS abbr,
               @P40 AS fVal) AS Ccc;
--select * from @TmpTbl  
SET @SqlTxt = 'Set @Prod_P=';
SET @TmpStr = @PriceOfBoxFormula;
SET @iCount = 1;
--print '@TmpStr'
--print @TmpStr
WHILE 1 = 1
    BEGIN
        -- print 'tammmmmammm'
        SET @k_Tmp = '';
        IF Substring(@TmpStr, @iCount, 1) = '@'
            BEGIN
                SELECT @k_Tmp = f_Val
                FROM   @TmpTbl
                WHERE  f_Abbr = Substring(@TmpStr, @iCount, 4);
                IF Substring(@TmpStr, @iCount, 4) = '@P20'
                    SET @k_Tmp = 0;
                IF Substring(@TmpStr, @iCount, 4) = '@P36'
                    SET @k_Tmp = 0;
                SET @SqlTxt = @SqlTxt + @k_Tmp;
                SET @iCount = @iCount + 3;
            END
        ELSE
            BEGIN
                SET @SqlTxt = @SqlTxt + Substring(@TmpStr, @iCount, 1);
            END
        SET @iCount = @iCount + 1;
        IF @iCount > Len(@TmpStr)
            BREAK;
    END
--print @SqlTxt
EXECUTE sp_executesql @SqlTxt, N'@Prod_P numeric output', @Prod_P OUTPUT;
IF @Sta_IsFeeAdjustPercent = 0
    BEGIN
        IF @Prod_P >= @Num_FeeAdjust
            IF @Num_FeeAdjust < 0
                SET @Prod_P = @Prod_P - Abs(@Num_FeeAdjust);
            ELSE
                SET @Prod_P = @Prod_P + Abs(@Num_FeeAdjust);
    END
IF @Sta_IsFeeAdjustPercent = 1
    BEGIN
        IF @Prod_P >= @Num_FeeAdjust
            IF @Num_FeeAdjust < 0
                SET @Prod_P = @Prod_P - (Abs(@Num_FeeAdjust) * @Prod_P / 100);
            ELSE
                SET @Prod_P = @Prod_P + (Abs(@Num_FeeAdjust) * @Prod_P / 100);
    END
SET @ColorFee = CONVERT (INT, @P10);
RETURN;


GO
ALTER PROCEDURE Tss_SalGoodsCalcStp
@SiSalInvoice_Dt NUMERIC=0, @SiPubGoodsClassify NUMERIC=21312, @SiPrcFlutType NUMERIC=9, @Num_SampleInnerLength NUMERIC=373, @Num_SampleInnerWidth NUMERIC=283, @Num_SampleInnerHeigth NUMERIC=190, @Num_DarbConst NUMERIC=0, @Num_ErtefaConst NUMERIC=0, @Des_LenghtFormula VARCHAR (500)='2*@TTT+2*@AAA', @Des_WidthFormula VARCHAR (500)='@EEE+@AAA', @Num_UpDoorOpenSize NUMERIC=0, @Num_DownDoorOpenSize NUMERIC=0, @SiPrcGoodsType NUMERIC=3, @LabConst NUMERIC=0, @TolSheet NUMERIC=0 OUTPUT, @ArzSheet NUMERIC=0 OUTPUT
AS
SET XACT_ABORT ON;
DECLARE @TmpTbl TABLE (
    f_Abbr VARCHAR (10),
    f_Val  VARCHAR (50));
DECLARE @P01 AS VARCHAR (50), @P02 AS VARCHAR (50), @P03 AS VARCHAR (50), @P04 AS VARCHAR (50), @P05 AS VARCHAR (50), @P06 AS VARCHAR (50), @P07 AS VARCHAR (50), @P08 AS VARCHAR (50), @P09 AS VARCHAR (50), @P10 AS VARCHAR (50), @P11 AS VARCHAR (50), @P12 AS VARCHAR (50), @P13 AS VARCHAR (50), @P14 AS VARCHAR (50), @TTT AS VARCHAR (10), @AAA AS VARCHAR (10), @EEE AS VARCHAR (10), @HHH AS VARCHAR (10), @FFF AS VARCHAR (10), @SqlTxtTool AS NVARCHAR (4000), @SqlTxtArzi AS NVARCHAR (4000), @iCount AS INT, @Layers AS INT, @TmpStr AS VARCHAR (500), @TmpH AS VARCHAR (20), @TotalDarbBaz AS INT, @ToolConst AS NUMERIC, @ArzConst AS NUMERIC, @Num_WidthPert AS NUMERIC, @Num_LabChasbConst AS NUMERIC, @OuterOrInnerFlag AS SMALLINT, @Num_SampleOuterLength AS NUMERIC, @Num_SampleOuterWidth AS NUMERIC, @Num_SampleOuterHeigth AS NUMERIC, @Sta_TipType AS SMALLINT, @Sta_TipOfGoodsType AS SMALLINT;
SET @OuterOrInnerFlag = dbo.Tss_StdFindSystemParamValue('CalcOuterBased');
SELECT @Num_LabChasbConst = Num_ContLabChasbConst
FROM   Tss_SalInvoice_Dt
WHERE  (SiSalInvoice_Dt = @SiSalInvoice_Dt);
IF isnull(@LabConst, 0) > 0
    SET @Num_LabChasbConst = @LabConst;
IF @SiPrcGoodsType = 0
    BEGIN
        IF (dbo.Tss_StdFindSubLoc(0) = 'aeen')
           OR (dbo.Tss_StdFindSubLoc(0) = 'delta')
           OR (dbo.Tss_StdFindSubLoc(0) = 'zarin')
            SELECT @SiPrcGoodsType = SiPrcGoodsType,
                   @Num_WidthPert = isnull(Num_WidthPert, 0)
            FROM   Tss_SalInvoice_Dt
            WHERE  (SiSalInvoice_Dt = @SiSalInvoice_Dt);
        ELSE
            SELECT @SiPrcGoodsType = SiPrcGoodsType,
                   @Num_WidthPert = isnull(Num_WidthPert, 0)
            FROM   Tss_SalInvoice_Dt
            WHERE  (SiSalInvoice_Dt = @SiSalInvoice_Dt);
    END
SELECT @Sta_TipType = Sta_TipType
FROM   dbo.Tss_PrcGoodsType
WHERE  SiPrcGoodsType = @SiPrcGoodsType;
SELECT @Sta_TipOfGoodsType = Sta_TipOfGoodsType
FROM   dbo.Tss_PrcGoodsType
WHERE  SiPrcGoodsType = @SiPrcGoodsType;
IF @Sta_TipType = 1
    SET @Num_LabChasbConst = @Num_LabChasbConst * 2;
IF isnull(@SiSalInvoice_Dt, 0) > 0
    BEGIN
        SELECT @Num_SampleOuterLength = Num_SampleOuterLength
        FROM   dbo.Tss_SalInvoice_Dt
        WHERE  SiSalInvoice_Dt = @SiSalInvoice_Dt;
        SELECT @Num_SampleOuterWidth = Num_SampleOuterWidth
        FROM   dbo.Tss_SalInvoice_Dt
        WHERE  SiSalInvoice_Dt = @SiSalInvoice_Dt;
        SELECT @Num_SampleOuterHeigth = Num_SampleOuterHeigth
        FROM   dbo.Tss_SalInvoice_Dt
        WHERE  SiSalInvoice_Dt = @SiSalInvoice_Dt;
    END
ELSE
    BEGIN
        IF (@Sta_TipOfGoodsType = 0)
           OR (@Sta_TipOfGoodsType = 5)
            BEGIN
                SELECT @Num_SampleOuterLength = dbo.ConvertInnerOuterBoxDimensions(0, 0, @Num_SampleInnerLength, @SiPrcFlutType);
                SELECT @Num_SampleOuterWidth = dbo.ConvertInnerOuterBoxDimensions(0, 1, @Num_SampleInnerWidth, @SiPrcFlutType);
                SELECT @Num_SampleOuterHeigth = dbo.ConvertInnerOuterBoxDimensions(0, 2, @Num_SampleInnerHeigth, @SiPrcFlutType);
            END
        ELSE
            BEGIN
                SELECT @Num_SampleOuterLength = @Num_SampleInnerLength;
                SELECT @Num_SampleOuterWidth = @Num_SampleInnerWidth;
            END
    END
IF @Num_UpDoorOpenSize = 0
    SELECT @Num_UpDoorOpenSize = Num_UpDoorOpenSize
    FROM   dbo.Tss_SalInvoice_Dt
    WHERE  SiSalInvoice_Dt = @SiSalInvoice_Dt;
IF @Num_DownDoorOpenSize = 0
    SELECT @Num_DownDoorOpenSize = Num_DownDoorOpenSize
    FROM   dbo.Tss_SalInvoice_Dt
    WHERE  SiSalInvoice_Dt = @SiSalInvoice_Dt;
IF @Num_SampleInnerLength = 0
    SELECT @Num_SampleInnerLength = Num_SampleInnerLength,
           @Num_SampleOuterLength = Num_SampleOuterLength
    FROM   dbo.Tss_SalInvoice_Dt
    WHERE  SiSalInvoice_Dt = @SiSalInvoice_Dt;
IF @Num_SampleInnerWidth = 0
    SELECT @Num_SampleInnerWidth = Num_SampleInnerWidth,
           @Num_SampleOuterWidth = Num_SampleOuterWidth
    FROM   dbo.Tss_SalInvoice_Dt
    WHERE  SiSalInvoice_Dt = @SiSalInvoice_Dt;
IF @Num_SampleInnerHeigth = 0
    SELECT @Num_SampleInnerHeigth = Num_SampleInnerHeigth,
           @Num_SampleOuterHeigth = Num_SampleOuterHeigth
    FROM   dbo.Tss_SalInvoice_Dt
    WHERE  SiSalInvoice_Dt = @SiSalInvoice_Dt;
IF @Num_UpDoorOpenSize = 0
    SELECT @Num_UpDoorOpenSize = Num_UpDoorOpenSize
    FROM   dbo.Tss_SalInvoice_Dt
    WHERE  SiSalInvoice_Dt = @SiSalInvoice_Dt;
IF @Num_DownDoorOpenSize = 0
    SELECT @Num_DownDoorOpenSize = Num_DownDoorOpenSize
    FROM   dbo.Tss_SalInvoice_Dt
    WHERE  SiSalInvoice_Dt = @SiSalInvoice_Dt;
IF @OuterOrInnerFlag = 0
    BEGIN
        SET @TTT = CONVERT (VARCHAR (10), @Num_SampleInnerLength);
        SET @AAA = CONVERT (VARCHAR (10), @Num_SampleInnerWidth);
        SET @EEE = CONVERT (VARCHAR (10), @Num_SampleInnerHeigth);
    END
ELSE
    BEGIN
        SET @TTT = CONVERT (VARCHAR (10), @Num_SampleOuterLength);
        SET @AAA = CONVERT (VARCHAR (10), @Num_SampleOuterWidth);
        SET @EEE = CONVERT (VARCHAR (10), @Num_SampleOuterHeigth);
    END
--print 'ddddd'
--print @TTT
--print @AAA
--print @EEE
--PRINT '@SiPubGoodsClassify'
--PRINT @SiPubGoodsClassify
IF EXISTS (SELECT SiPubGoodsClassifyFormula
           FROM   dbo.Tss_PrcMatFormulaClaToPaperTypesCla
           WHERE  (SiPubGoodsClassifyFormula = @SiPubGoodsClassify))
    SELECT @Layers = Count(SiPubGoodsClassifyFormula)
    FROM   dbo.Tss_PrcMatFormulaClaToPaperTypesCla
    WHERE  (SiPubGoodsClassifyFormula = @SiPubGoodsClassify);
ELSE
    SELECT @Layers = Num_Layer
    FROM   Tss_PubGoodsClassify
    WHERE  (SiPubGoodsClassify = @SiPubGoodsClassify);
IF ISNULL(@Layers, 0) = 0
    SET @Layers = 3;
IF ISNULL(@Layers, 0) = 1
    SET @Layers = 5;
IF (isnull(@Num_UpDoorOpenSize, 0) = 0)
   AND (isnull(@Num_DownDoorOpenSize, 0) = 0)
    SELECT @TotalDarbBaz = (isnull(Num_UpDoorOpenSize, 0) + isnull(Num_DownDoorOpenSize, 0))
    FROM   Tss_SalInvoice_Dt
    WHERE  (SiSalInvoice_Dt = @SiSalInvoice_Dt);
ELSE
    SET @TotalDarbBaz = isnull(@Num_UpDoorOpenSize, 0) + isnull(@Num_DownDoorOpenSize, 0);
SET @TotalDarbBaz = @TotalDarbBaz / 2;
SELECT @FFF = Ltrim(Rtrim(Tss_PrcFlutType.Des_FlutTypeName))
FROM   Tss_SalInvoice_Dt
       LEFT OUTER JOIN
       Tss_PrcFlutType
       ON Tss_SalInvoice_Dt.SiPrcFlutType = Tss_PrcFlutType.SiPrcFlutType
WHERE  (Tss_SalInvoice_Dt.SiSalInvoice_Dt = @SiSalInvoice_Dt);
SET @TmpStr = Ltrim(Rtrim(@Des_LenghtFormula));
SET @SqlTxtTool = 'Set @TolSheet=';
SET @iCount = 1;
--PRINT '@Layers'
--PRINT @Layers
WHILE 1 = 1
    BEGIN
        IF Substring(@TmpStr, @iCount, 1) = '@'
            BEGIN
                IF Substring(@TmpStr, @iCount + 1, 1) = 'T'
                    BEGIN
                        SET @SqlTxtTool = @SqlTxtTool + @TTT;
                        SET @iCount = @iCount + 3;
                    END
                IF Substring(@TmpStr, @iCount + 1, 1) = 'A'
                    BEGIN
                        SET @SqlTxtTool = @SqlTxtTool + @AAA;
                        SET @iCount = @iCount + 3;
                    END
                IF Substring(@TmpStr, @iCount + 1, 1) = 'E'
                    BEGIN
                        SET @SqlTxtTool = @SqlTxtTool + @EEE;
                        SET @iCount = @iCount + 3;
                    END
                IF Substring(@TmpStr, @iCount + 1, 1) = 'F'
                    BEGIN
                        SET @SqlTxtTool = @SqlTxtTool + '''' + @FFF + '''';
                        SET @iCount = @iCount + 3;
                    END
                IF Substring(@TmpStr, @iCount + 1, 1) = 'H'
                    BEGIN
                        --PRINT 'HHH'
                        SET @HHH = '0';
                        SET @TmpH = Substring(@TmpStr, @iCount, 13);
                        IF @Layers = 3
                            SET @HHH = SubString(@TmpH, 6, 3);
                        IF @Layers = 5
                            SET @HHH = SubString(@TmpH, 10, 3);
                        SET @SqlTxtTool = @SqlTxtTool + @HHH;
                        SET @iCount = @iCount + 12;
                    END
            END
        ELSE
            BEGIN
                SET @SqlTxtTool = @SqlTxtTool + Substring(@TmpStr, @iCount, 1);
            END
        SET @iCount = @iCount + 1;
        IF @iCount > Len(@TmpStr)
            BREAK;
    END
--print '@SiPrcFlutType'
--print @SiPrcFlutType
--print '@SiPrcFlutType'
IF @OuterOrInnerFlag = 0
    BEGIN
        IF isnull(@Num_LabChasbConst, 0) > 0
            BEGIN
                IF @SiPrcFlutType = 0
                    SELECT @ToolConst = ((2 * Num_OuterLengthConst) + (2 * Num_OuterWidthConst) + @Num_LabChasbConst)
                    FROM   Tss_PrcFlutType
                    WHERE  (SiPrcFlutType = (SELECT SiPrcFlutType
                                             FROM   Tss_SalInvoice_Dt
                                             WHERE  (SiSalInvoice_Dt = @SiSalInvoice_Dt)));
                ELSE
                    SELECT @ToolConst = ((2 * Num_OuterLengthConst) + (2 * Num_OuterWidthConst) + @Num_LabChasbConst)
                    FROM   Tss_PrcFlutType
                    WHERE  (SiPrcFlutType = @SiPrcFlutType);
            END
        ELSE
            BEGIN
                IF @SiPrcFlutType = 0
                    SELECT @ToolConst = ((2 * Num_OuterLengthConst) + (2 * Num_OuterWidthConst) + Num_LabChasbConst)
                    FROM   Tss_PrcFlutType
                    WHERE  (SiPrcFlutType = (SELECT SiPrcFlutType
                                             FROM   Tss_SalInvoice_Dt
                                             WHERE  (SiSalInvoice_Dt = @SiSalInvoice_Dt)));
                ELSE
                    SELECT @ToolConst = ((2 * Num_OuterLengthConst) + (2 * Num_OuterWidthConst) + Num_LabChasbConst)
                    FROM   Tss_PrcFlutType
                    WHERE  (SiPrcFlutType = @SiPrcFlutType);
            END
    END
ELSE
    BEGIN
        IF isnull(@Num_LabChasbConst, 0) > 0
            BEGIN
                IF @SiPrcFlutType = 0
                    SELECT @ToolConst = @Num_LabChasbConst
                    FROM   Tss_PrcFlutType
                    WHERE  (SiPrcFlutType = (SELECT SiPrcFlutType
                                             FROM   Tss_SalInvoice_Dt
                                             WHERE  (SiSalInvoice_Dt = @SiSalInvoice_Dt)));
                ELSE
                    SELECT @ToolConst = @Num_LabChasbConst
                    FROM   Tss_PrcFlutType
                    WHERE  (SiPrcFlutType = @SiPrcFlutType);
            END
        ELSE
            BEGIN
                IF @SiPrcFlutType = 0
                    SELECT @ToolConst = Num_LabChasbConst
                    FROM   Tss_PrcFlutType
                    WHERE  (SiPrcFlutType = (SELECT SiPrcFlutType
                                             FROM   Tss_SalInvoice_Dt
                                             WHERE  (SiSalInvoice_Dt = @SiSalInvoice_Dt)));
                ELSE
                    SELECT @ToolConst = Num_LabChasbConst
                    FROM   Tss_PrcFlutType
                    WHERE  (SiPrcFlutType = @SiPrcFlutType);
            END
    END
IF @SiPrcGoodsType = 29
    SET @ToolConst = 0;
IF len(Ltrim(Rtrim(@SqlTxtTool))) > 18
    SET @SqlTxtTool = @SqlTxtTool + '+' + CONVERT (VARCHAR, @ToolConst);
EXECUTE sp_executesql @SqlTxtTool, N'@TolSheet numeric output', @TolSheet OUTPUT;
SET @TmpStr = Ltrim(Rtrim(@Des_WidthFormula));
SET @SqlTxtArzi = 'Set @ArzSheet=';
SET @iCount = 1;
WHILE 1 = 1
    BEGIN
        IF Substring(@TmpStr, @iCount, 1) = '@'
            BEGIN
                IF Substring(@TmpStr, @iCount + 1, 1) = 'T'
                    BEGIN
                        SET @SqlTxtArzi = @SqlTxtArzi + @TTT;
                        SET @iCount = @iCount + 3;
                    END
                IF Substring(@TmpStr, @iCount + 1, 1) = 'A'
                    BEGIN
                        SET @SqlTxtArzi = @SqlTxtArzi + @AAA;
                        SET @iCount = @iCount + 3;
                    END
                IF Substring(@TmpStr, @iCount + 1, 1) = 'E'
                    BEGIN
                        SET @SqlTxtArzi = @SqlTxtArzi + @EEE;
                        SET @iCount = @iCount + 3;
                    END
                IF Substring(@TmpStr, @iCount + 1, 1) = 'F'
                    BEGIN
                        SET @SqlTxtArzi = @SqlTxtArzi + '''' + @FFF + '''';
                        SET @iCount = @iCount + 3;
                    END
                IF Substring(@TmpStr, @iCount + 1, 1) = 'H'
                    BEGIN
                        SET @HHH = '0';
                        SET @TmpH = Substring(@TmpStr, @iCount, 13);
                        IF @Layers = 3
                            SET @HHH = SubString(@TmpH, 6, 3);
                        IF @Layers = 5
                            SET @HHH = SubString(@TmpH, 10, 3);
                        SET @SqlTxtArzi = @SqlTxtArzi + @HHH;
                        SET @iCount = @iCount + 12;
                    END
            END
        ELSE
            BEGIN
                SET @SqlTxtArzi = @SqlTxtArzi + Substring(@TmpStr, @iCount, 1);
            END
        SET @iCount = @iCount + 1;
        IF @iCount > Len(@TmpStr)
            BREAK;
    END
--print @SqlTxtArzi
IF SubString(@SqlTxtArzi, len(@ArzSheet), 1) = '+'
    SET @SqlTxtArzi = SubString(@SqlTxtArzi, 1, len(@ArzSheet) - 1);
IF @SiPrcFlutType = 0
    BEGIN
        IF @Num_DarbConst = 0
            SELECT @Num_DarbConst = Num_DarbConst + @Num_SampleInnerWidth / 2
            FROM   Tss_PrcFlutType
            WHERE  (SiPrcFlutType = (SELECT SiPrcFlutType
                                     FROM   Tss_SalInvoice_Dt
                                     WHERE  (SiSalInvoice_Dt = @SiSalInvoice_Dt)));
        IF @Num_ErtefaConst = 0
            SELECT @Num_ErtefaConst = Num_ErtefaConst + @Num_SampleInnerHeigth
            FROM   Tss_PrcFlutType
            WHERE  (SiPrcFlutType = (SELECT SiPrcFlutType
                                     FROM   Tss_SalInvoice_Dt
                                     WHERE  (SiSalInvoice_Dt = @SiSalInvoice_Dt)));
    END
ELSE
    BEGIN
        IF @Num_DarbConst = 0
            SELECT @Num_DarbConst = Num_DarbConst + @Num_SampleInnerWidth / 2
            FROM   Tss_PrcFlutType
            WHERE  (SiPrcFlutType = @SiPrcFlutType);
        IF @Num_ErtefaConst = 0
            SELECT @Num_ErtefaConst = Num_ErtefaConst + @Num_SampleInnerHeigth
            FROM   Tss_PrcFlutType
            WHERE  (SiPrcFlutType = @SiPrcFlutType);
        IF @SiPrcGoodsType = 29
            SELECT @Num_ErtefaConst = @Num_SampleInnerHeigth - Num_ErtefaConst
            FROM   Tss_PrcFlutType
            WHERE  (SiPrcFlutType = @SiPrcFlutType);
    END
IF @OuterOrInnerFlag = 0
    BEGIN
        IF (@SiPrcGoodsType IN (SELECT SiPrcGoodsType
                                FROM   Tss_PrcGoodsType
                                WHERE  (Cod_PrcGoodsTypeCode = '3')
                                       OR (Cod_PrcGoodsTypeCode = '35')
                                       OR (Cod_PrcGoodsTypeCode = '36')
                                       OR (Cod_PrcGoodsTypeCode = '65')
                                       OR (Cod_PrcGoodsTypeCode = '70')
                                       OR (Cod_PrcGoodsTypeCode = '71')
                                       OR (Cod_PrcGoodsTypeCode = '90')
                                       OR (Cod_PrcGoodsTypeCode = '93')
                                       OR (Cod_PrcGoodsTypeCode = '96')
                                       OR (Cod_PrcGoodsTypeCode = '97')
                                       OR (Cod_PrcGoodsTypeCode = '101')
                                       OR (Cod_PrcGoodsTypeCode = '4')
                                       OR (Cod_PrcGoodsTypeCode = '104')
                                       OR (Cod_PrcGoodsTypeCode = '68')
                                       OR (Cod_PrcGoodsTypeCode = '107')))
            SELECT @ArzConst = (@Num_DarbConst - @Num_SampleInnerWidth / 2) + (@Num_ErtefaConst - @Num_SampleInnerHeigth);
        IF (@SiPrcGoodsType NOT IN (SELECT SiPrcGoodsType
                                    FROM   Tss_PrcGoodsType
                                    WHERE  (Cod_PrcGoodsTypeCode = '3')
                                           OR (Cod_PrcGoodsTypeCode = '35')
                                           OR (Cod_PrcGoodsTypeCode = '36')
                                           OR (Cod_PrcGoodsTypeCode = '65')
                                           OR (Cod_PrcGoodsTypeCode = '70')
                                           OR (Cod_PrcGoodsTypeCode = '71')
                                           OR (Cod_PrcGoodsTypeCode = '90')
                                           OR (Cod_PrcGoodsTypeCode = '93')
                                           OR (Cod_PrcGoodsTypeCode = '96')
                                           OR (Cod_PrcGoodsTypeCode = '97')
                                           OR (Cod_PrcGoodsTypeCode = '101')
                                           OR (Cod_PrcGoodsTypeCode = '4')
                                           OR (Cod_PrcGoodsTypeCode = '104')
                                           OR (Cod_PrcGoodsTypeCode = '68')
                                           OR (Cod_PrcGoodsTypeCode = '107')))
            SELECT @ArzConst = (2 * @Num_DarbConst - @Num_SampleInnerWidth) + (@Num_ErtefaConst - @Num_SampleInnerHeigth);
        IF (len(Ltrim(Rtrim(@SqlTxtTool))) = 23)
           OR (len(Ltrim(Rtrim(@SqlTxtTool))) = 25)
            SET @ArzConst = (@Num_DarbConst - @Num_SampleInnerWidth / 2) + (@Num_ErtefaConst - @Num_SampleInnerHeigth);
        IF (len(Ltrim(Rtrim(@SqlTxtTool))) = 18)
            SET @ArzConst = (@Num_ErtefaConst - @Num_SampleInnerHeigth);
    END
IF (len(Ltrim(Rtrim(@SqlTxtTool))) > 18)
   AND (@OuterOrInnerFlag = 0)
    SET @SqlTxtArzi = @SqlTxtArzi + '+' + isnull(CONVERT (VARCHAR, @ArzConst), '');
IF @TotalDarbBaz >= 0
    BEGIN
        IF (dbo.Tss_StdFindSubLoc(0) = 'aeen')
           OR (dbo.Tss_StdFindSubLoc(0) = 'delta')
           OR (dbo.Tss_StdFindSubLoc(0) = 'zarin')
            SET @SqlTxtArzi = @SqlTxtArzi + '-' + isnull(Ltrim(Rtrim(Str(isnull(@TotalDarbBaz, 0)))), 0) + '+' + isnull(Ltrim(Rtrim(Str(isnull(@Num_WidthPert, 0)))), 0);
        ELSE
            SET @SqlTxtArzi = @SqlTxtArzi + '-' + isnull(Ltrim(Rtrim(Str(isnull(@TotalDarbBaz, 0)))), 0) + '+' + isnull(Ltrim(Rtrim(Str(isnull(0, 0)))), 0);
    END
IF @TotalDarbBaz < 0
    BEGIN
        IF (dbo.Tss_StdFindSubLoc(0) = 'aeen')
           OR (dbo.Tss_StdFindSubLoc(0) = 'delta')
           OR (dbo.Tss_StdFindSubLoc(0) = 'zarin')
            SET @SqlTxtArzi = @SqlTxtArzi + '+(-1*' + isnull(Ltrim(Rtrim(Str(isnull(@TotalDarbBaz, 0)))), 0) + ')' + '+' + isnull(Ltrim(Rtrim(Str(isnull(@Num_WidthPert, 0)))), 0);
        ELSE
            SET @SqlTxtArzi = @SqlTxtArzi + '+(-1*' + isnull(Ltrim(Rtrim(Str(isnull(@TotalDarbBaz, 0)))), 0) + ')' + '+' + isnull(Ltrim(Rtrim(Str(isnull(0, 0)))), 0);
    END
EXECUTE sp_executesql @SqlTxtArzi, N'@ArzSheet numeric output', @ArzSheet OUTPUT;


GO
ALTER PROCEDURE Tss_SalUntGdsFeeCalcStp
@SiSalInvoice_Dt NUMERIC, @SiPrcGoodsType NUMERIC, @SiPubGoodsClassify NUMERIC, @SiPrcFlutType NUMERIC, @Num_SampleInnerLength NUMERIC, @Num_SampleInnerWidth NUMERIC, @Num_SampleInnerHeigth NUMERIC, @Num_ColoringRate NUMERIC, @Num_SampleHoleNo NUMERIC, @Sta_HasMangene SMALLINT, @Sta_EttesalType SMALLINT, @Sta_IsLipStick SMALLINT, @Die_Len NUMERIC, @Die_Wdt NUMERIC, @NoInDie NUMERIC, @Sta_Cyan SMALLINT, @Sta_Magenta SMALLINT, @Sta_Yellow SMALLINT, @Sta_Black SMALLINT, @Sta_HasVerni SMALLINT, @Sta_PackType SMALLINT, @Num_OneMeterSheetPrice NUMERIC, @Num_OneMeterBoxPrice NUMERIC, @Num_UpDoorOpenSize NUMERIC=0, @Num_DownDoorOpenSize NUMERIC=0, @Num_PalleteNo NUMERIC=0, @Num_GdsAmountNo NUMERIC=0, @CellophaneType SMALLINT=0, @MatteOrGlossy SMALLINT=0, @OffsetAreaType SMALLINT=0, @OffsetHeightPrint NUMERIC=0, @SiPubGoodsClassifyCardBox NUMERIC, @PunchNo NUMERIC, @LabConst NUMERIC=0, @Gds_Len NUMERIC=0 OUTPUT, @Gds_Wdt NUMERIC=0 OUTPUT, @Gds_Fee NUMERIC=0 OUTPUT, @Col_Fee NUMERIC=0 OUTPUT, @Pal_Fee NUMERIC=0 OUTPUT, @Die_Fee NUMERIC=0 OUTPUT, @Lam_Fee NUMERIC=0 OUTPUT, @OffSet_Fee NUMERIC=0 OUTPUT, @LaminateWage NUMERIC=0 OUTPUT, @CellophoneGlueMatteCost NUMERIC=0 OUTPUT, @CellophoneGlueGlossyCost NUMERIC=0 OUTPUT, @CellophoneThermalMatteCost NUMERIC=0 OUTPUT, @CellophoneThermalGlossyCost NUMERIC=0 OUTPUT, @LaminateBoxLockBottomCost NUMERIC=0 OUTPUT, @LaminateBoxTwoPieceCost NUMERIC=0 OUTPUT, @CardBoxPrice NUMERIC=0 OUTPUT
AS
SET @Gds_Len = 0;
SET @Gds_Wdt = 0;
SET @Gds_Fee = 0;
SET @Col_Fee = 0;
SET @Pal_Fee = 0;
SET @Die_Fee = 0;
DECLARE @Sta_DieOrNot AS SMALLINT, @Sta_TipOfGoodsType AS SMALLINT, @Des_LenghtFormula AS VARCHAR (500), @Des_WidthFormula AS VARCHAR (500), @Num_GoodsLength AS NUMERIC, @Num_GoodsWidth AS NUMERIC, @Num_NoInDie AS NUMERIC, @Area AS NUMERIC (30, 4), @Gds_Area AS NUMERIC (30, 4), @Prod_P AS NUMERIC, @ColorFee AS NUMERIC, @CardBoxPriceOut AS NUMERIC, @PalleteFee AS NUMERIC, @DieCut_Fee AS NUMERIC, @Laminate_Fee AS NUMERIC, @Num_FeeAdjust AS NUMERIC, @LaminateType AS SMALLINT, @OffSet_FeeOut AS NUMERIC, @LaminateWageOut AS SMALLINT, @CellophoneGlueMatteCostOut AS NUMERIC, @CellophoneGlueGlossyCostOut AS NUMERIC, @CellophoneThermalMatteCostOut AS NUMERIC, @CellophoneThermalGlossyCostOut AS NUMERIC, @LaminateBoxLockBottomCostOut AS NUMERIC, @LaminateBoxTwoPieceCostOut AS NUMERIC, @FeeHaml AS NUMERIC;
SET @Prod_P = 0;
SET @ColorFee = 0;
SET @CardBoxPrice = 0;
SET @PalleteFee = 0;
SET @DieCut_Fee = 0;
SET @Laminate_Fee = 0;
SET @Num_FeeAdjust = 0;
SET @Num_GoodsLength = 0;
SET @Num_GoodsWidth = 0;
SELECT @Des_LenghtFormula = Des_LenghtFormula,
       @Des_WidthFormula = Des_WidthFormula,
       @Sta_DieOrNot = Sta_DieOrNot,
       @Sta_TipOfGoodsType = Sta_TipOfGoodsType,
       @LaminateType = Sta_LaminateType
FROM   dbo.Tss_PrcGoodsType
WHERE  (SiPrcGoodsType = @SiPrcGoodsType);
IF @Sta_DieOrNot = 0
    BEGIN
        EXECUTE dbo.Tss_SalGoodsCalcStp @SiSalInvoice_Dt, @SiPubGoodsClassify, @SiPrcFlutType, @Num_SampleInnerLength, @Num_SampleInnerWidth, @Num_SampleInnerHeigth, 0, 0, @Des_LenghtFormula, @Des_WidthFormula, @Num_UpDoorOpenSize, @Num_DownDoorOpenSize, @SiPrcGoodsType, @LabConst, @Num_GoodsLength OUTPUT, @Num_GoodsWidth OUTPUT;
    END
ELSE
    BEGIN
        SET @Num_GoodsLength = @Die_Len;
        SET @Num_GoodsWidth = @Die_Wdt;
        SET @Num_NoInDie = @NoInDie;
        SET @Sta_DieOrNot = 1;
    END
SET @Area = @Num_GoodsLength * @Num_GoodsWidth;
SET @Gds_Area = (@Area / 1000000.00);
SET @Prod_P = 0;
SET @ColorFee = 0;
SET @CardBoxPrice = 0;
SET @PalleteFee = 0;
SET @DieCut_Fee = 0;
SET @Laminate_Fee = 0;
EXECUTE dbo.Tss_SalGoodsPriceCalcStp @SiSalInvoice_Dt, @SiPubGoodsClassify, @Num_SampleInnerHeigth, @Num_ColoringRate, @Num_SampleHoleNo, @Sta_HasMangene, @Sta_EttesalType, @Num_FeeAdjust, @Sta_DieOrNot, @Sta_TipOfGoodsType, @Num_GoodsLength, @Num_GoodsWidth, @Area, @Sta_Cyan, @Sta_Magenta, @Sta_Yellow, @Sta_Black, @Sta_HasVerni, @Sta_PackType, @Num_OneMeterSheetPrice, @Num_OneMeterBoxPrice, 0, @Num_PalleteNo, @Num_GdsAmountNo, @CellophaneType, @LaminateType, @MatteOrGlossy, @Num_NoInDie, @SiPrcGoodsType, @SiPubGoodsClassifyCardBox, @OffsetAreaType, @OffsetHeightPrint, @PunchNo, @Prod_P OUTPUT, @ColorFee OUTPUT, @CardBoxPriceOut OUTPUT, @PalleteFee OUTPUT, @DieCut_Fee OUTPUT, @Laminate_Fee OUTPUT, @OffSet_FeeOut OUTPUT, @LaminateWageOut OUTPUT, @CellophoneGlueMatteCostOut OUTPUT, @CellophoneGlueGlossyCostOut OUTPUT, @CellophoneThermalMatteCostOut OUTPUT, @CellophoneThermalGlossyCostOut OUTPUT, @LaminateBoxLockBottomCostOut OUTPUT, @LaminateBoxTwoPieceCostOut OUTPUT, @FeeHaml OUTPUT;
SET @Gds_Len = @Num_GoodsLength;
SET @Gds_Wdt = @Num_GoodsWidth;
SET @Gds_Fee = @Prod_P;
SET @Col_Fee = @ColorFee;
SET @CardBoxPrice = @CardBoxPriceOut;
SET @Pal_Fee = @PalleteFee;
SET @Die_Fee = @DieCut_Fee;
SET @Lam_Fee = @Laminate_Fee;
SET @OffSet_Fee = @OffSet_FeeOut;
SET @LaminateWage = @LaminateWageOut;
SET @CellophoneGlueMatteCost = @CellophoneGlueMatteCostOut;
SET @CellophoneGlueGlossyCost = @CellophoneGlueGlossyCostOut;
SET @CellophoneThermalMatteCost = @CellophoneThermalMatteCostOut;
SET @CellophoneThermalGlossyCost = @CellophoneThermalGlossyCostOut;
SET @LaminateBoxLockBottomCost = @LaminateBoxLockBottomCostOut;
SET @LaminateBoxTwoPieceCost = @LaminateBoxTwoPieceCostOut;
RETURN;


GO
IF NOT EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = OBJECT_ID(N'[dbo].[Tss_LonUntLoansDtVStp]')
                      AND type IN (N'P', N'PC'))
    BEGIN
        EXECUTE dbo.sp_executesql N'CREATE PROCEDURE [dbo].[Tss_LonUntLoansDtVStp]
    (
        @InternalWhere VarChar(8000)='''',
        @Where VarChar(8000)='''',
        @Order VarChar(8000)=''''
    ) AS 
    If @InternalWhere<>'''' 
        Set @InternalWhere='' Where ''+@InternalWhere
    If @Where<>'''' 
        Set @Where='' Where ''+@Where
    If @Order<>'''' 
        Set @Order='' Order By ''+@Order
    Exec(
        ''Select * From 
        (
        SELECT        
            SiLonLoans_Dt, 
            SiLonLoans, 
            Cod_LoansDtCode, 
            Dat_InstallmentDate, 
            Num_InstallmentBase, 
            Num_InstallmentProf, 
            Num_BaseRemain, 
            Num_ProfRemain
        FROM            
            Tss_LonLoansDt ''+@InternalWhere+''
        ) CalcSel '' + @Where + @Order
    )';
    END


GO
ALTER PROCEDURE dbo.Tss_LonUntLoansVStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)=''
AS
IF @InternalWhere <> ''
    SET @InternalWhere = ' Where ' + @InternalWhere;
IF @Where <> ''
    SET @Where = ' Where ' + @Where;
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
EXECUTE ('Select * From 
	(
	SELECT        
		Tss_LonLoans.SiLonLoans, 
		Tss_LonLoans.StmLonLoans, 
		Tss_LonLoans.Cod_LoansCode, 
		Tss_LonLoans.Des_LoansDesc, 
		Tss_LonLoans.Num_LoansAmt, 
		Tss_LonLoans.Num_LoansInstalmentNo, 
		Tss_LonLoans.Sta_LoansStatus,
		Tss_LonLoans.SiPubCustomCodes, 
		Tss_LonLoans.SiPubPersonsSpec, 
		Tss_LonLoans.Sta_LoanType, 
		Tss_LonLoans.DateLoanStartDate, 
		Tss_LonLoans.Num_BreathDays, 
		Tss_LonLoans.Num_ProfInBreathDate,
		Tss_LonLoans.Num_PorfInInstallments,
		Tss_PubPersonsSpec.Cod_PubPersonCode, 
		Tss_PubPersonsSpec.Des_PubPersonName1,
		Tss_PubPersonsSpec.Des_PubPersonName2, 
		Tss_PubCustomCodes.Cod_CustomCodesCode, 
		Tss_PubCustomCodes.Des_CustomCodesDesc
	FROM            
		Tss_LonLoans LEFT OUTER JOIN
		Tss_PubPersonsSpec ON Tss_LonLoans.SiPubPersonsSpec = Tss_PubPersonsSpec.SiPubPersonsSpec LEFT OUTER JOIN
		Tss_PubCustomCodes ON Tss_LonLoans.SiPubCustomCodes = Tss_PubCustomCodes.SiPubCustomCodes ' + @InternalWhere + '
	) CalcSel ' + @Where + @Order);


GO
ALTER PROCEDURE dbo.Tss_LonUntLoansIudStp
@Err_Code INT OUTPUT, @SiLonLoans NUMERIC OUTPUT, @Cod_LoansCode VARCHAR (50)='', @Des_LoansDesc VARCHAR (500)='', @Num_LoansAmt BIGINT=0, @Num_LoansInstalmentNo INT=0, @Sta_LoansStatus SMALLINT=0, @SiPubCustomCodes NUMERIC=NULL, @SiPubPersonsSpec NUMERIC=NULL, @Sta_LoanType SMALLINT=0, @DateLoanStartDate VARCHAR (10)='', @Num_BreathDays SMALLINT=0, @Num_ProfInBreathDate NUMERIC=0, @Num_PorfInInstallments NUMERIC=0, @StmLonLoans TIMESTAMP=0, @SiUser NUMERIC, @FlgInsUpdDel SMALLINT
AS
IF @FlgInsUpdDel = 0
    BEGIN
        INSERT  INTO dbo.Tss_LonLoans (Cod_LoansCode, Des_LoansDesc, Num_LoansAmt, Num_LoansInstalmentNo, Sta_LoansStatus, SiPubCustomCodes, SiPubPersonsSpec, Sta_LoanType, DateLoanStartDate, Num_BreathDays, Num_ProfInBreathDate, Num_PorfInInstallments)
        VALUES                       (@Cod_LoansCode, @Des_LoansDesc, @Num_LoansAmt, @Num_LoansInstalmentNo, @Sta_LoansStatus, @SiPubCustomCodes, @SiPubPersonsSpec, @Sta_LoanType, @DateLoanStartDate, @Num_BreathDays, @Num_ProfInBreathDate, @Num_PorfInInstallments);
        SET @SiLonLoans = Scope_Identity();
        IF IsNull(@SiLonLoans, 0) = 0
            BEGIN
                SET @SiLonLoans = 0;
                SET @Err_Code = 400;
            END
        RETURN;
    END
IF @FlgInsUpdDel = 1
    BEGIN
        SET @Err_Code = 0;
        IF EXISTS (SELECT StmLonLoans
                   FROM   dbo.Tss_LonLoans
                   WHERE  (SiLonLoans = @SiLonLoans)
                          AND (StmLonLoans = @StmLonLoans))
            BEGIN
                UPDATE dbo.Tss_LonLoans
                SET    Cod_LoansCode          = @Cod_LoansCode,
                       Des_LoansDesc          = @Des_LoansDesc,
                       Num_LoansAmt           = @Num_LoansAmt,
                       Num_LoansInstalmentNo  = @Num_LoansInstalmentNo,
                       Sta_LoansStatus        = @Sta_LoansStatus,
                       SiPubCustomCodes       = @SiPubCustomCodes,
                       SiPubPersonsSpec       = @SiPubPersonsSpec,
                       Sta_LoanType           = @Sta_LoanType,
                       DateLoanStartDate      = @DateLoanStartDate,
                       Num_BreathDays         = @Num_BreathDays,
                       Num_ProfInBreathDate   = @Num_ProfInBreathDate,
                       Num_PorfInInstallments = @Num_PorfInInstallments
                WHERE  (SiLonLoans = @SiLonLoans);
                SET @Err_Code = @@Error;
                IF @Err_Code <> 0
                    SET @Err_Code = 401;
                RETURN;
            END
        ELSE
            SET @Err_Code = 402;
    END
IF @FlgInsUpdDel = 2
    BEGIN
        SET @Err_Code = 0;
        IF EXISTS (SELECT StmLonLoans
                   FROM   dbo.Tss_LonLoans
                   WHERE  (SiLonLoans = @SiLonLoans)
                          AND (StmLonLoans = @StmLonLoans))
            BEGIN
                DELETE dbo.Tss_LonLoans
                WHERE  (SiLonLoans = @SiLonLoans);
                SET @Err_Code = @@Error;
                IF @Err_Code <> 0
                    SET @Err_Code = 4000;
            END
        ELSE
            SET @Err_Code = 4001;
        RETURN;
    END


GO
SET ANSI_NULLS ON;


GO
SET QUOTED_IDENTIFIER ON;


GO
IF NOT EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = OBJECT_ID(N'[dbo].[Tss_LonLoansDt]')
                      AND type IN (N'U'))
    BEGIN
        CREATE TABLE [dbo].[Tss_LonLoansDt] (
            [SiLonLoans_Dt] NUMERIC (18, 0) IDENTITY (1, 1) NOT NULL,
            [SiLonLoans] NUMERIC (18, 0) NULL,
            [Cod_LoansDtCode] NCHAR (10) NULL,
            [Dat_InstallmentDate] VARCHAR (50) NULL,
            [Num_InstallmentBase] NUMERIC (18, 0) NULL,
            [Num_InstallmentProf] NUMERIC (18, 0) NULL,
            [Num_BaseRemain] NUMERIC (18, 0) NULL,
            [Num_ProfRemain] NUMERIC (18, 0) NULL,
            [StmLonLoans_Dt] TIMESTAMP NULL,
            CONSTRAINT [PK_Tss_LonLoansDt] PRIMARY KEY CLUSTERED ([SiLonLoans_Dt] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
        ) ON [PRIMARY];
        PRINT 'Table dbo.Tss_LonLoansDt created successfully.';
    END
ELSE
    BEGIN
        PRINT 'Table dbo.Tss_LonLoansDt already exists.';
    END


GO
ALTER PROCEDURE Tss_RapUntPayedCheque_HdIudStp
@Err_Code INT OUTPUT, @SiRapPayedCheque NUMERIC OUTPUT, @SiRapChequesDefine NUMERIC=NULL, @SiPubPersonsSpec NUMERIC=NULL, @Cod_RapPayedChequeCode VARCHAR (50)='', @Cod_RapPayedOrderCode VARCHAR (50)='', @Des_RapPayedChequeDesc VARCHAR (500)='', @Dat_RapPayedChequeRegDate VARCHAR (10)='', @Cod_RapPayedChequeSerial VARCHAR (50)='', @Dat_RapPayedChequeEndDate VARCHAR (10)='', @Num_RapPayedChequeAmount NUMERIC=NULL, @Sta_RapPayedChequeState SMALLINT=0, @Dat_RapPayedChequeCngDate VARCHAR (10)='', @Dat_RapPayedChequeVosoolDate VARCHAR (10)='', @Dat_RapPayedChequeCancelDate VARCHAR (10)='', @SiPubSubLocations NUMERIC=1, @Des_ChekDesc VARCHAR (1000)='', @SiRapBehalfDefineHd NUMERIC=NULL, @SiRapPayedChequeRef_RefrenceHd NUMERIC=NULL, @Des_PayedChequeSayadiCode VARCHAR (50)='', @Des_PayedChequeSayadiNationalCode VARCHAR (50)='', @StmRapPayedCheque TIMESTAMP=0, @SiUser NUMERIC, @FlgInsUpdDel SMALLINT
AS
IF @FlgInsUpdDel = 0
    BEGIN
        IF isnull(@Cod_RapPayedChequeCode, '') = ''
            SET @Cod_RapPayedChequeCode = (SELECT isnull(Max(CONVERT (NUMERIC, Isnull(Cod_RapPayedChequeCode, 0))), 0) + 1
                                           FROM   dbo.Tss_RapPayedCheque
                                           WHERE  Cod_RapPayedChequeCode <> '');
        INSERT  INTO dbo.Tss_RapPayedCheque (SiRapChequesDefine, SiPubPersonsSpec, Cod_RapPayedChequeCode, Cod_RapPayedOrderCode, Des_RapPayedChequeDesc, Dat_RapPayedChequeRegDate, Cod_RapPayedChequeSerial, Dat_RapPayedChequeEndDate, Num_RapPayedChequeAmount, Sta_RapPayedChequeState, Dat_RapPayedChequeCngDate, Dat_RapPayedChequeVosoolDate, Dat_RapPayedChequeCancelDate, SiPubSubLocations, Des_ChekDesc, SiRapBehalfDefineHd, SiRapPayedChequeRef_RefrenceHd, Des_PayedChequeSayadiCode, Des_PayedChequeSayadiNationalCode)
        VALUES                             (@SiRapChequesDefine, @SiPubPersonsSpec, @Cod_RapPayedChequeCode, @Cod_RapPayedOrderCode, @Des_RapPayedChequeDesc, @Dat_RapPayedChequeRegDate, @Cod_RapPayedChequeSerial, @Dat_RapPayedChequeEndDate, @Num_RapPayedChequeAmount, @Sta_RapPayedChequeState, @Dat_RapPayedChequeCngDate, @Dat_RapPayedChequeVosoolDate, @Dat_RapPayedChequeCancelDate, @SiPubSubLocations, @Des_ChekDesc, @SiRapBehalfDefineHd, @SiRapPayedChequeRef_RefrenceHd, @Des_PayedChequeSayadiCode, @Des_PayedChequeSayadiNationalCode);
        SET @SiRapPayedCheque = Scope_Identity();
        IF IsNull(@SiRapPayedCheque, 0) <> 0
            BEGIN
                EXECUTE dbo.Tss_RapUntPayedCheque_DtIudStp 0, 0, @SiRapPayedCheque, @SiRapBehalfDefineHd, @SiRapPayedChequeRef_RefrenceHd, @Num_RapPayedChequeAmount, '1', '', @SiPubPersonsSpec, NULL, NULL, 0, @SiUser, 0;
            END
        IF IsNull(@SiRapPayedCheque, 0) = 0
            BEGIN
                SET @SiRapPayedCheque = 0;
                SET @Err_Code = 400;
            END
        RETURN;
    END
IF @FlgInsUpdDel = 1
    BEGIN
        DECLARE @SiRapPayedChequeRef AS NUMERIC, @StmRapPayedChequeRef AS TIMESTAMP, @Cod_RapPayedChequeRefCode AS VARCHAR (50) = '', @Des_RapPayedChequeRefDesc AS VARCHAR (1000) = '', @SiPubPersonsSpecdt AS NUMERIC, @SiRapCashDefine AS NUMERIC, @SiPubCostCenter AS NUMERIC, @RowCount AS INT, @CurrentStmRapPayedCheque AS TIMESTAMP;
        SET @Err_Code = 0;
        -- Look up the row by key only (no timestamp in the WHERE yet) so we can
        -- tell "doesn't exist" apart from "exists but timestamp is stale".
        SELECT @CurrentStmRapPayedCheque = StmRapPayedCheque
        FROM   dbo.Tss_RapPayedCheque
        WHERE  SiRapPayedCheque = @SiRapPayedCheque;
        IF @CurrentStmRapPayedCheque IS NULL
            BEGIN
                -- ============================================================
                -- Row doesn't exist -> fall back to insert (same as @FlgInsUpdDel = 0)
                -- ============================================================
                IF isnull(@Cod_RapPayedChequeCode, '') = ''
                    SET @Cod_RapPayedChequeCode = (SELECT isnull(Max(CONVERT (NUMERIC, Isnull(Cod_RapPayedChequeCode, 0))), 0) + 1
                                                   FROM   dbo.Tss_RapPayedCheque
                                                   WHERE  Cod_RapPayedChequeCode <> '');
                INSERT  INTO dbo.Tss_RapPayedCheque (SiRapChequesDefine, SiPubPersonsSpec, Cod_RapPayedChequeCode, Cod_RapPayedOrderCode, Des_RapPayedChequeDesc, Dat_RapPayedChequeRegDate, Cod_RapPayedChequeSerial, Dat_RapPayedChequeEndDate, Num_RapPayedChequeAmount, Sta_RapPayedChequeState, Dat_RapPayedChequeCngDate, Dat_RapPayedChequeVosoolDate, Dat_RapPayedChequeCancelDate, SiPubSubLocations, Des_ChekDesc, SiRapBehalfDefineHd, SiRapPayedChequeRef_RefrenceHd, Des_PayedChequeSayadiCode, Des_PayedChequeSayadiNationalCode)
                VALUES                             (@SiRapChequesDefine, @SiPubPersonsSpec, @Cod_RapPayedChequeCode, @Cod_RapPayedOrderCode, @Des_RapPayedChequeDesc, @Dat_RapPayedChequeRegDate, @Cod_RapPayedChequeSerial, @Dat_RapPayedChequeEndDate, @Num_RapPayedChequeAmount, @Sta_RapPayedChequeState, @Dat_RapPayedChequeCngDate, @Dat_RapPayedChequeVosoolDate, @Dat_RapPayedChequeCancelDate, @SiPubSubLocations, @Des_ChekDesc, @SiRapBehalfDefineHd, @SiRapPayedChequeRef_RefrenceHd, @Des_PayedChequeSayadiCode, @Des_PayedChequeSayadiNationalCode);
                SET @SiRapPayedCheque = Scope_Identity();
                IF IsNull(@SiRapPayedCheque, 0) <> 0
                    BEGIN
                        EXECUTE dbo.Tss_RapUntPayedCheque_DtIudStp 0, 0, @SiRapPayedCheque, @SiRapBehalfDefineHd, @SiRapPayedChequeRef_RefrenceHd, @Num_RapPayedChequeAmount, '1', '', @SiPubPersonsSpec, NULL, NULL, 0, @SiUser, 0;
                    END
                IF IsNull(@SiRapPayedCheque, 0) = 0
                    BEGIN
                        SET @SiRapPayedCheque = 0;
                        SET @Err_Code = 400;
                    END
                RETURN;
            END
        IF @CurrentStmRapPayedCheque <> @StmRapPayedCheque
            BEGIN
                -- ============================================================
                -- Row exists but caller's timestamp is stale -> real concurrency conflict
                -- ============================================================
                SET @Err_Code = 403;
                RETURN;
            END
        -- ============================================================
        -- Row exists and timestamp matches -> normal update
        -- ============================================================
        UPDATE dbo.Tss_RapPayedCheque
        SET    SiRapChequesDefine                = @SiRapChequesDefine,
               SiPubPersonsSpec                  = @SiPubPersonsSpec,
               Cod_RapPayedChequeCode            = @Cod_RapPayedChequeCode,
               Cod_RapPayedOrderCode             = @Cod_RapPayedOrderCode,
               Des_RapPayedChequeDesc            = @Des_RapPayedChequeDesc,
               Dat_RapPayedChequeRegDate         = @Dat_RapPayedChequeRegDate,
               Cod_RapPayedChequeSerial          = @Cod_RapPayedChequeSerial,
               Dat_RapPayedChequeEndDate         = @Dat_RapPayedChequeEndDate,
               Num_RapPayedChequeAmount          = @Num_RapPayedChequeAmount,
               Sta_RapPayedChequeState           = @Sta_RapPayedChequeState,
               Dat_RapPayedChequeCngDate         = @Dat_RapPayedChequeCngDate,
               Dat_RapPayedChequeVosoolDate      = @Dat_RapPayedChequeVosoolDate,
               Dat_RapPayedChequeCancelDate      = @Dat_RapPayedChequeCancelDate,
               SiPubSubLocations                 = @SiPubSubLocations,
               Des_ChekDesc                      = @Des_ChekDesc,
               SiRapBehalfDefineHd               = @SiRapBehalfDefineHd,
               SiRapPayedChequeRef_RefrenceHd    = @SiRapPayedChequeRef_RefrenceHd,
               Des_PayedChequeSayadiCode         = @Des_PayedChequeSayadiCode,
               Des_PayedChequeSayadiNationalCode = @Des_PayedChequeSayadiNationalCode
        WHERE  (SiRapPayedCheque = @SiRapPayedCheque)
               AND (StmRapPayedCheque = @StmRapPayedCheque);
        SELECT @RowCount = COUNT(*)
        FROM   Tss_RapPayedChequeRef
        WHERE  SiRapPayedCheque = @SiRapPayedCheque;
        IF @RowCount = 1
            BEGIN
                SELECT TOP 1 @SiRapPayedChequeRef = SiRapPayedChequeRef,
                             @StmRapPayedChequeRef = StmRapPayedChequeRef,
                             @Cod_RapPayedChequeRefCode = Cod_RapPayedChequeRefCode,
                             @Des_RapPayedChequeRefDesc = Des_RapPayedChequeRefDesc,
                             @SiPubPersonsSpecdt = SiPubPersonsSpec,
                             @SiRapCashDefine = SiRapCashDefine,
                             @SiPubCostCenter = SiPubCostCenter
                FROM   dbo.Tss_RapPayedChequeRef
                WHERE  SiRapPayedCheque = @SiRapPayedCheque;
                EXECUTE dbo.Tss_RapUntPayedCheque_DtIudStp 0, @SiRapPayedChequeRef, @SiRapPayedCheque, @SiRapBehalfDefineHd, @SiRapPayedChequeRef_RefrenceHd, @Num_RapPayedChequeAmount, @Cod_RapPayedChequeRefCode, @Des_RapPayedChequeRefDesc, @SiPubPersonsSpecdt, @SiRapCashDefine, @SiPubCostCenter, @StmRapPayedChequeRef, @SiUser, 1;
            END
        ELSE
            IF @RowCount = 0
                BEGIN
                    -- Header exists but somehow has no detail row -> create one
                    -- (matches the pattern already used in Tss_RapUntCashRecievePayIudStp)
                    EXECUTE dbo.Tss_RapUntPayedCheque_DtIudStp 0, 0, @SiRapPayedCheque, @SiRapBehalfDefineHd, @SiRapPayedChequeRef_RefrenceHd, @Num_RapPayedChequeAmount, '1', '', @SiPubPersonsSpec, NULL, NULL, 0, @SiUser, 0;
                END
        SET @Err_Code = @@Error;
        IF @Err_Code <> 0
            SET @Err_Code = 401;
        RETURN;
    END
IF @FlgInsUpdDel = 2
    BEGIN
        SET @Err_Code = 0;
        IF EXISTS (SELECT StmRapPayedCheque
                   FROM   dbo.Tss_RapPayedCheque
                   WHERE  (SiRapPayedCheque = @SiRapPayedCheque)
                          AND (StmRapPayedCheque = @StmRapPayedCheque))
            BEGIN
                DELETE dbo.Tss_RapPayedCheque
                WHERE  (SiRapPayedCheque = @SiRapPayedCheque);
                SET @Err_Code = @@Error;
                IF @Err_Code <> 0
                    SET @Err_Code = 4000;
            END
        ELSE
            SET @Err_Code = 4000;
        RETURN;
    END


GO
ALTER PROCEDURE dbo.Tss_RapUntCashRecIudStp
@Err_Code INT OUTPUT, @SiRapCashRecievePay NUMERIC OUTPUT, @SiRapCashDefine NUMERIC, @SiPubPersonsSpec NUMERIC, @Cod_RapCashRecPayCode VARCHAR (50)='', @Des_RapCashRecPayDesc VARCHAR (1000)='', @Sta_RapCashRecOrPayFlag SMALLINT=0, @Sta_RapCashRecPayState SMALLINT=1, @Dat_RapCashRecPayRegDate VARCHAR (10)='', @Dat_RapCashRecPayCngDate VARCHAR (10)='', @Num_RapCashRecPayAmount NUMERIC=0, @Cod_BankBranchCashPayCode VARCHAR (50)='', @Des_BankPayedCash VARCHAR (200)='', @Des_RapCashRecPayGhabzDesc VARCHAR (1000)='', @SiPubPersonsSpec2 NUMERIC=NULL, @SiPubCustomCodes NUMERIC=NULL, @Cod_CashPayedRecieptCode VARCHAR (50)='', @Dat_PayDate VARCHAR (10)='', @SiPubSubLocations NUMERIC=1, @Sta_CashRecieptMainOrNot SMALLINT=0, @SiRapBehalfDefineHd NUMERIC=NULL, @SiRapCashRecievePayRef_refrenceHd NUMERIC=NULL, @Sta_ConcurrentReceipt SMALLINT=0, @StmRapCashRecievePay TIMESTAMP=0, @SiUser NUMERIC, @FlgInsUpdDel SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @TransactionCount AS INT = @@TRANCOUNT;
    IF @FlgInsUpdDel = 0 -- INSERT
        BEGIN
            BEGIN TRY
                IF @TransactionCount = 0
                    BEGIN TRANSACTION;
                SET @Err_Code = 0;
                -- Handle code generation with transaction isolation
                IF ISNULL(@Cod_RapCashRecPayCode, '') = ''
                    BEGIN
                        SELECT @Cod_RapCashRecPayCode = MAX(CONVERT (NUMERIC, Cod_RapCashRecPayCode)) + 1
                        FROM   dbo.Tss_RapCashRecievePay WITH (UPDLOCK, HOLDLOCK)
                        WHERE  (LEFT(Dat_RapCashRecPayRegDate, 4) = LEFT(@Dat_RapCashRecPayRegDate, 4))
                               AND (Cod_RapCashRecPayCode <> '');
                    END
                IF @Cod_RapCashRecPayCode IS NULL
                   OR @Cod_RapCashRecPayCode = ''
                    SET @Cod_RapCashRecPayCode = '1';
                INSERT  INTO dbo.Tss_RapCashRecievePay (SiRapCashDefine, SiPubPersonsSpec, Cod_RapCashRecPayCode, Des_RapCashRecPayDesc, Sta_RapCashRecOrPayFlag, Sta_RapCashRecPayState, Dat_RapCashRecPayRegDate, Dat_RapCashRecPayCngDate, Num_RapCashRecPayAmount, Cod_BankBranchCashPayCode, Des_BankPayedCash, Des_RapCashRecPayGhabzDesc, SiPubPersonsSpec2, SiPubCustomCodes, Cod_CashPayedRecieptCode, Dat_PayDate, Sta_CashRecieptMainOrNot, SiPubSubLocations, SiRapBehalfDefineHd, SiRapCashRecievePayRef_refrenceHd, Sta_ConcurrentReceipt)
                VALUES                                (@SiRapCashDefine, @SiPubPersonsSpec, @Cod_RapCashRecPayCode, @Des_RapCashRecPayDesc, 0, @Sta_RapCashRecPayState, @Dat_RapCashRecPayRegDate, GETDATE(), @Num_RapCashRecPayAmount, @Cod_BankBranchCashPayCode, @Des_BankPayedCash, @Des_RapCashRecPayGhabzDesc, @SiPubPersonsSpec2, @SiPubCustomCodes, @Cod_CashPayedRecieptCode, @Dat_PayDate, @Sta_CashRecieptMainOrNot, @SiPubSubLocations, @SiRapBehalfDefineHd, @SiRapCashRecievePayRef_refrenceHd, @Sta_ConcurrentReceipt);
                SET @SiRapCashRecievePay = SCOPE_IDENTITY();
                -- Insert detail record
                IF ISNULL(@SiRapCashRecievePay, 0) > 0
                    BEGIN
                        EXECUTE dbo.Tss_RapUntCashRecievePayRefIudStp 0, 0, @SiRapBehalfDefineHd, @SiRapCashRecievePay, @Num_RapCashRecPayAmount, @SiRapCashRecievePayRef_refrenceHd, '1', @Des_RapCashRecPayGhabzDesc, @SiPubPersonsSpec2, @SiRapCashDefine, NULL, 0, @SiUser, 0;
                        IF @Err_Code <> 0
                            RAISERROR ('Error in detail insert', 16, 1);
                    END
                IF ISNULL(@SiRapCashRecievePay, 0) = 0
                    BEGIN
                        SET @SiRapCashRecievePay = 0;
                        SET @Err_Code = 400;
                        RAISERROR ('Insert failed', 16, 1);
                    END
                IF @TransactionCount = 0
                    COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @TransactionCount = 0
                   AND XACT_STATE() <> 0
                    ROLLBACK;
                SET @Err_Code = ERROR_NUMBER();
                SET @SiRapCashRecievePay = 0;
                DECLARE @ErrorMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
                RAISERROR (@ErrorMsg, 16, 1);
            END CATCH
        END
    IF @FlgInsUpdDel = 1 -- UPDATE
        BEGIN
            BEGIN TRY
                IF @TransactionCount = 0
                    BEGIN TRANSACTION;
                SET @Err_Code = 0;
                DECLARE @CurrentStmRapCashRecievePay AS TIMESTAMP;
                DECLARE @RowCount AS INT;
                DECLARE @SiRapCashRecievePayRef AS NUMERIC;
                DECLARE @StmRapCashRecievePayRef AS TIMESTAMP;
                -- Check if record exists with proper locking
                SELECT @CurrentStmRapCashRecievePay = StmRapCashRecievePay
                FROM   dbo.Tss_RapCashRecievePay WITH (UPDLOCK, ROWLOCK)
                WHERE  SiRapCashRecievePay = @SiRapCashRecievePay;
                IF @CurrentStmRapCashRecievePay IS NULL
                    BEGIN
                        SET @Err_Code = 402;
                        RAISERROR ('Record not found', 16, 1);
                    END
                ELSE
                    IF @CurrentStmRapCashRecievePay <> @StmRapCashRecievePay
                        BEGIN
                            SET @Err_Code = 403;
                            RAISERROR ('Concurrent modification detected', 16, 1);
                        END
                    ELSE
                        BEGIN
                            -- Update main record
                            UPDATE dbo.Tss_RapCashRecievePay
                            SET    SiRapCashDefine                   = @SiRapCashDefine,
                                   SiPubPersonsSpec                  = @SiPubPersonsSpec,
                                   Cod_RapCashRecPayCode             = @Cod_RapCashRecPayCode,
                                   Des_RapCashRecPayDesc             = @Des_RapCashRecPayDesc,
                                   Sta_RapCashRecOrPayFlag           = @Sta_RapCashRecOrPayFlag,
                                   Sta_RapCashRecPayState            = @Sta_RapCashRecPayState,
                                   Dat_RapCashRecPayRegDate          = @Dat_RapCashRecPayRegDate,
                                   Dat_RapCashRecPayCngDate          = @Dat_RapCashRecPayCngDate,
                                   Num_RapCashRecPayAmount           = @Num_RapCashRecPayAmount,
                                   Cod_BankBranchCashPayCode         = @Cod_BankBranchCashPayCode,
                                   Des_BankPayedCash                 = @Des_BankPayedCash,
                                   Des_RapCashRecPayGhabzDesc        = @Des_RapCashRecPayGhabzDesc,
                                   SiPubPersonsSpec2                 = @SiPubPersonsSpec2,
                                   SiPubCustomCodes                  = @SiPubCustomCodes,
                                   Cod_CashPayedRecieptCode          = @Cod_CashPayedRecieptCode,
                                   Dat_PayDate                       = @Dat_PayDate,
                                   Sta_CashRecieptMainOrNot          = @Sta_CashRecieptMainOrNot,
                                   SiPubSubLocations                 = @SiPubSubLocations,
                                   SiRapBehalfDefineHd               = @SiRapBehalfDefineHd,
                                   SiRapCashRecievePayRef_refrenceHd = @SiRapCashRecievePayRef_refrenceHd,
                                   Sta_ConcurrentReceipt             = @Sta_ConcurrentReceipt
                            WHERE  SiRapCashRecievePay = @SiRapCashRecievePay
                                   AND StmRapCashRecievePay = @StmRapCashRecievePay;
                            -- Check if detail record exists
                            SELECT @RowCount = COUNT(*)
                            FROM   Tss_RapCashRecievePayRef
                            WHERE  SiRapCashRecievePay = @SiRapCashRecievePay;
                            IF @RowCount = 1
                                BEGIN
                                    -- Get the first detail record
                                    SELECT TOP 1 @SiRapCashRecievePayRef = SiRapCashRecievePayRef,
                                                 @StmRapCashRecievePayRef = StmRapCashRecievePayRef
                                    FROM   dbo.Tss_RapCashRecievePayRef
                                    WHERE  SiRapCashRecievePay = @SiRapCashRecievePay;
                                    -- Update the detail record
                                    EXECUTE dbo.Tss_RapUntCashRecievePayRefIudStp 0, @SiRapCashRecievePayRef, @SiRapBehalfDefineHd, @SiRapCashRecievePay, @Num_RapCashRecPayAmount, @SiRapCashRecievePayRef_refrenceHd, '1', @Des_RapCashRecPayGhabzDesc, @SiPubPersonsSpec2, @SiRapCashDefine, NULL, @StmRapCashRecievePayRef, @SiUser, 1;
                                END
                            ELSE
                                IF @RowCount = 0
                                    BEGIN
                                        -- No detail exists, insert one
                                        EXECUTE dbo.Tss_RapUntCashRecievePayRefIudStp 0, 0, @SiRapBehalfDefineHd, @SiRapCashRecievePay, @Num_RapCashRecPayAmount, @SiRapCashRecievePayRef_refrenceHd, '1', @Des_RapCashRecPayGhabzDesc, @SiPubPersonsSpec2, @SiRapCashDefine, NULL, 0, @SiUser, 0;
                                    END
                            IF @Err_Code <> 0
                                BEGIN
                                    SET @Err_Code = 401;
                                    RAISERROR ('Error in detail operation', 16, 1);
                                END
                        END
                IF @TransactionCount = 0
                    COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @TransactionCount = 0
                   AND XACT_STATE() <> 0
                    ROLLBACK;
                SET @Err_Code = ERROR_NUMBER();
                DECLARE @ErrorMsg2 AS NVARCHAR (4000) = ERROR_MESSAGE();
                RAISERROR (@ErrorMsg2, 16, 1);
            END CATCH
        END
    IF @FlgInsUpdDel = 2 -- DELETE
        BEGIN
            BEGIN TRY
                IF @TransactionCount = 0
                    BEGIN TRANSACTION;
                SET @Err_Code = 0;
                IF EXISTS (SELECT 1
                           FROM   dbo.Tss_RapCashRecievePay WITH (UPDLOCK, ROWLOCK)
                           WHERE  SiRapCashRecievePay = @SiRapCashRecievePay
                                  AND StmRapCashRecievePay = @StmRapCashRecievePay)
                    BEGIN
                        -- Delete detail records first
                        DELETE dbo.Tss_RapCashRecievePayRef
                        WHERE  SiRapCashRecievePay = @SiRapCashRecievePay;
                        DELETE dbo.Tss_RapCashRecievePay
                        WHERE  SiRapCashRecievePay = @SiRapCashRecievePay;
                        SET @Err_Code = @@ERROR;
                        IF @Err_Code <> 0
                            BEGIN
                                SET @Err_Code = 4000;
                                RAISERROR ('Delete failed', 16, 1);
                            END
                    END
                ELSE
                    BEGIN
                        SET @Err_Code = 4001;
                        RAISERROR ('Record not found or concurrency conflict', 16, 1);
                    END
                IF @TransactionCount = 0
                    COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @TransactionCount = 0
                   AND XACT_STATE() <> 0
                    ROLLBACK;
                SET @Err_Code = ERROR_NUMBER();
                DECLARE @ErrorMsg3 AS NVARCHAR (4000) = ERROR_MESSAGE();
                RAISERROR (@ErrorMsg3, 16, 1);
            END CATCH
        END
END


GO
ALTER PROCEDURE Tss_RapUntCashPayIudStp
@Err_Code INT OUTPUT, @SiRapCashRecievePay NUMERIC OUTPUT, @SiRapCashDefine NUMERIC=NULL, @SiPubSubLocations NUMERIC=1, @SiPubPersonsSpec NUMERIC=NULL, @Cod_RapCashRecPayCode VARCHAR (50)='', @Des_RapCashRecPayDesc VARCHAR (1000)='', @Sta_RapCashRecOrPayFlag SMALLINT=1, @Sta_RapCashRecPayState SMALLINT=0, @Dat_RapCashRecPayRegDate VARCHAR (10)='', @Dat_RapCashRecPayCngDate VARCHAR (10)='', @Num_RapCashRecPayAmount NUMERIC=0, @Cod_BankBranchCashPayCode VARCHAR (50)='', @Des_BankPayedCash VARCHAR (200)='', @Des_RapCashRecPayGhabzDesc VARCHAR (1000)='', @SiPubPersonsSpec2 NUMERIC=NULL, @SiPubPersonsSpec3 NUMERIC=NULL, @SiPubCustomCodes NUMERIC=NULL, @Cod_CashPayedRecieptCode VARCHAR (50)='', @Dat_PayDate VARCHAR (10)='', @Sta_CashRecieptType SMALLINT=0, @SiRapBehalfDefineHd NUMERIC=NULL, @SiRapCashRecievePayRef_refrenceHd NUMERIC=NULL, @SiPubCostCenter NUMERIC=NULL, @SiRapPaymentAuthorization NUMERIC=NULL, @StmRapCashRecievePay TIMESTAMP=0, @SiUser NUMERIC, @FlgInsUpdDel SMALLINT
AS
IF @FlgInsUpdDel = 0
    BEGIN
        INSERT  INTO dbo.Tss_RapCashRecievePay (SiRapCashDefine, SiPubPersonsSpec, SiPubSubLocations, Cod_RapCashRecPayCode, Des_RapCashRecPayDesc, Sta_RapCashRecOrPayFlag, Sta_RapCashRecPayState, Dat_RapCashRecPayRegDate, Dat_RapCashRecPayCngDate, Num_RapCashRecPayAmount, Cod_BankBranchCashPayCode, Des_BankPayedCash, Des_RapCashRecPayGhabzDesc, SiPubPersonsSpec2, SiPubPersonsSpec3, SiPubCustomCodes, Cod_CashPayedRecieptCode, Dat_PayDate, Sta_CashRecieptType, SiRapBehalfDefineHd, SiRapCashRecievePayRef_refrenceHd, SiPubCostCenter, SiRapPaymentAuthorization)
        VALUES                                (@SiRapCashDefine, @SiPubPersonsSpec, @SiPubSubLocations, @Cod_RapCashRecPayCode, @Des_RapCashRecPayDesc, 1, @Sta_RapCashRecPayState, @Dat_RapCashRecPayRegDate, @Dat_RapCashRecPayCngDate, @Num_RapCashRecPayAmount, @Cod_BankBranchCashPayCode, @Des_BankPayedCash, @Des_RapCashRecPayGhabzDesc, @SiPubPersonsSpec2, @SiPubPersonsSpec3, @SiPubCustomCodes, @Cod_CashPayedRecieptCode, @Dat_PayDate, @Sta_CashRecieptType, @SiRapBehalfDefineHd, @SiRapCashRecievePayRef_refrenceHd, @SiPubCostCenter, @SiRapPaymentAuthorization);
        SET @SiRapCashRecievePay = Scope_Identity();
        IF IsNull(@SiRapCashRecievePay, 0) <> 0
            BEGIN
                EXECUTE dbo.Tss_RapUntCashRecievePayRefIudStp 0, 0, @SiRapBehalfDefineHd, @SiRapCashRecievePay, @Num_RapCashRecPayAmount, @SiRapCashRecievePayRef_refrenceHd, '1', @Des_RapCashRecPayDesc, @SiPubPersonsSpec, @SiRapCashDefine, @SiPubCostCenter, 0, @SiUser, 0;
            END
        IF IsNull(@SiRapCashRecievePay, 0) = 0
            BEGIN
                SET @SiRapCashRecievePay = 0;
                SET @Err_Code = 400;
            END
        RETURN;
    END
IF @FlgInsUpdDel = 1
    BEGIN
        DECLARE @CurrentStmRapCashRecievePay AS TIMESTAMP, @RowCount AS INT, @SiRapCashRecievePayRef AS NUMERIC, @StmRapCashRecievePayRef AS TIMESTAMP, @Cod_RapCashRecievePayRefCode AS VARCHAR (50), @Des_RapCashRecievePayRefDesc AS VARCHAR (1000), @SiPubPersonsSpecdt AS NUMERIC, @SiRapCashDefinedt AS NUMERIC, @SiPubCostCenterdt AS NUMERIC;
        SET @Err_Code = 0;
        -- Look up by key only first, so "not found" and "stale timestamp" can be
        -- told apart instead of both collapsing into the same error code.
        SELECT @CurrentStmRapCashRecievePay = StmRapCashRecievePay
        FROM   dbo.Tss_RapCashRecievePay
        WHERE  SiRapCashRecievePay = @SiRapCashRecievePay;
        IF @CurrentStmRapCashRecievePay IS NULL
            BEGIN
                -- ============================================================
                -- Row doesn't exist -> fall back to insert (same as @FlgInsUpdDel = 0)
                -- ============================================================
                INSERT  INTO dbo.Tss_RapCashRecievePay (SiRapCashDefine, SiPubPersonsSpec, SiPubSubLocations, Cod_RapCashRecPayCode, Des_RapCashRecPayDesc, Sta_RapCashRecOrPayFlag, Sta_RapCashRecPayState, Dat_RapCashRecPayRegDate, Dat_RapCashRecPayCngDate, Num_RapCashRecPayAmount, Cod_BankBranchCashPayCode, Des_BankPayedCash, Des_RapCashRecPayGhabzDesc, SiPubPersonsSpec2, SiPubPersonsSpec3, SiPubCustomCodes, Cod_CashPayedRecieptCode, Dat_PayDate, Sta_CashRecieptType, SiRapBehalfDefineHd, SiRapCashRecievePayRef_refrenceHd, SiPubCostCenter, SiRapPaymentAuthorization)
                VALUES                                (@SiRapCashDefine, @SiPubPersonsSpec, @SiPubSubLocations, @Cod_RapCashRecPayCode, @Des_RapCashRecPayDesc, @Sta_RapCashRecOrPayFlag, @Sta_RapCashRecPayState, @Dat_RapCashRecPayRegDate, @Dat_RapCashRecPayCngDate, @Num_RapCashRecPayAmount, @Cod_BankBranchCashPayCode, @Des_BankPayedCash, @Des_RapCashRecPayGhabzDesc, @SiPubPersonsSpec2, @SiPubPersonsSpec3, @SiPubCustomCodes, @Cod_CashPayedRecieptCode, @Dat_PayDate, @Sta_CashRecieptType, @SiRapBehalfDefineHd, @SiRapCashRecievePayRef_refrenceHd, @SiPubCostCenter, @SiRapPaymentAuthorization);
                SET @SiRapCashRecievePay = Scope_Identity();
                IF IsNull(@SiRapCashRecievePay, 0) <> 0
                    BEGIN
                        EXECUTE dbo.Tss_RapUntCashRecievePayRefIudStp 0, 0, @SiRapBehalfDefineHd, @SiRapCashRecievePay, @Num_RapCashRecPayAmount, @SiRapCashRecievePayRef_refrenceHd, '1', @Des_RapCashRecPayDesc, @SiPubPersonsSpec, @SiRapCashDefine, @SiPubCostCenter, 0, @SiUser, 0;
                    END
                IF IsNull(@SiRapCashRecievePay, 0) = 0
                    BEGIN
                        SET @SiRapCashRecievePay = 0;
                        SET @Err_Code = 400;
                    END
                RETURN;
            END
        IF @CurrentStmRapCashRecievePay <> @StmRapCashRecievePay
            BEGIN
                -- ============================================================
                -- Row exists but caller's timestamp is stale -> real concurrency conflict
                -- ============================================================
                SET @Err_Code = 403;
                RETURN;
            END
        -- ============================================================
        -- Row exists and timestamp matches -> normal update
        -- ============================================================
        UPDATE dbo.Tss_RapCashRecievePay
        SET    SiRapCashDefine                   = @SiRapCashDefine,
               SiPubPersonsSpec                  = @SiPubPersonsSpec,
               SiPubSubLocations                 = @SiPubSubLocations,
               Cod_RapCashRecPayCode             = @Cod_RapCashRecPayCode,
               Des_RapCashRecPayDesc             = @Des_RapCashRecPayDesc,
               Sta_RapCashRecOrPayFlag           = @Sta_RapCashRecOrPayFlag,
               Sta_RapCashRecPayState            = @Sta_RapCashRecPayState,
               Dat_RapCashRecPayRegDate          = @Dat_RapCashRecPayRegDate,
               Dat_RapCashRecPayCngDate          = @Dat_RapCashRecPayCngDate,
               Num_RapCashRecPayAmount           = @Num_RapCashRecPayAmount,
               Cod_BankBranchCashPayCode         = @Cod_BankBranchCashPayCode,
               Des_BankPayedCash                 = @Des_BankPayedCash,
               Des_RapCashRecPayGhabzDesc        = @Des_RapCashRecPayGhabzDesc,
               SiPubPersonsSpec2                 = @SiPubPersonsSpec2,
               SiPubPersonsSpec3                 = @SiPubPersonsSpec3,
               SiPubCustomCodes                  = @SiPubCustomCodes,
               Cod_CashPayedRecieptCode          = @Cod_CashPayedRecieptCode,
               Dat_PayDate                       = @Dat_PayDate,
               Sta_CashRecieptType               = @Sta_CashRecieptType,
               SiRapBehalfDefineHd               = @SiRapBehalfDefineHd,
               SiRapCashRecievePayRef_refrenceHd = @SiRapCashRecievePayRef_refrenceHd,
               SiPubCostCenter                   = @SiPubCostCenter,
               SiRapPaymentAuthorization         = @SiRapPaymentAuthorization
        WHERE  (SiRapCashRecievePay = @SiRapCashRecievePay);
        SELECT @RowCount = COUNT(*)
        FROM   Tss_RapCashRecievePayRef
        WHERE  SiRapCashRecievePay = @SiRapCashRecievePay;
        IF @RowCount = 1
            BEGIN
                SELECT TOP 1 @SiRapCashRecievePayRef = SiRapCashRecievePayRef,
                             @StmRapCashRecievePayRef = StmRapCashRecievePayRef,
                             @Cod_RapCashRecievePayRefCode = Cod_RapCashRecievePayRefCode,
                             @Des_RapCashRecievePayRefDesc = Des_RapCashRecievePayRefDesc,
                             @SiPubPersonsSpecdt = SiPubPersonsSpec,
                             @SiRapCashDefinedt = SiRapCashDefine,
                             @SiPubCostCenterdt = SiPubCostCenter
                FROM   dbo.Tss_RapCashRecievePayRef
                WHERE  SiRapCashRecievePay = @SiRapCashRecievePay;
                EXECUTE dbo.Tss_RapUntCashRecievePayRefIudStp 0, @SiRapCashRecievePayRef, @SiRapBehalfDefineHd, @SiRapCashRecievePay, @Num_RapCashRecPayAmount, @SiRapCashRecievePayRef_refrenceHd, '1', @Des_RapCashRecPayGhabzDesc, @SiPubPersonsSpec2, @SiRapCashDefine, NULL, @StmRapCashRecievePayRef, @SiUser, 1;
            END
        ELSE
            IF @RowCount = 0
                BEGIN
                    -- Header exists but has no detail row -> create one
                    EXECUTE dbo.Tss_RapUntCashRecievePayRefIudStp 0, 0, @SiRapBehalfDefineHd, @SiRapCashRecievePay, @Num_RapCashRecPayAmount, @SiRapCashRecievePayRef_refrenceHd, '1', @Des_RapCashRecPayGhabzDesc, @SiPubPersonsSpec2, @SiRapCashDefine, NULL, 0, @SiUser, 0;
                END
        SET @Err_Code = @@Error;
        IF @Err_Code <> 0
            SET @Err_Code = 401;
        RETURN;
    END
IF @FlgInsUpdDel = 2
    BEGIN
        SET @Err_Code = 0;
        IF EXISTS (SELECT StmRapCashRecievePay
                   FROM   dbo.Tss_RapCashRecievePay
                   WHERE  (SiRapCashRecievePay = @SiRapCashRecievePay)
                          AND (StmRapCashRecievePay = @StmRapCashRecievePay))
            BEGIN
                DELETE dbo.Tss_RapCashRecievePay
                WHERE  (SiRapCashRecievePay = @SiRapCashRecievePay);
                SET @Err_Code = @@Error;
                IF @Err_Code <> 0
                    SET @Err_Code = 4000;
            END
        ELSE
            SET @Err_Code = 4001;
        RETURN;
    END


GO
-- =====================================================================
-- Ensure the stored procedure exists; if not, create a dummy version.
-- =====================================================================
IF OBJECT_ID('dbo.Tss_LonUntLoansDtIudStp', 'P') IS NULL
    BEGIN
        EXECUTE ('
        CREATE PROCEDURE dbo.Tss_LonUntLoansDtIudStp
        AS
        BEGIN
            SELECT 1;   -- dummy body
        END
    ');
    END


GO
-- =====================================================================
-- Alter the procedure to the final definition.
-- =====================================================================
ALTER PROCEDURE dbo.Tss_LonUntLoansDtIudStp
@Err_Code INT OUTPUT, @SiLonLoans_Dt NUMERIC OUTPUT, @SiLonLoans NUMERIC=0, @Cod_LoansDtCode VARCHAR (50)='', @Dat_InstallmentDate VARCHAR (10)='', @Num_InstallmentBase NUMERIC=0, @Num_InstallmentProf NUMERIC=0, @Num_BaseRemain NUMERIC=0, @Num_ProfRemain NUMERIC=0, @StmLonLoans_Dt TIMESTAMP=0, @SiUser NUMERIC, @FlgInsUpdDel SMALLINT -- Code for the installment
AS
BEGIN
    SET NOCOUNT ON;
    -- ============================================================
    -- INSERT
    -- ============================================================
    IF @FlgInsUpdDel = 0
        BEGIN
            SET @Err_Code = 0;
            INSERT  INTO dbo.Tss_LonLoansDt (SiLonLoans, Cod_LoansDtCode, Dat_InstallmentDate, Num_InstallmentBase, Num_InstallmentProf, Num_BaseRemain, Num_ProfRemain)
            VALUES                         (@SiLonLoans, @Cod_LoansDtCode, @Dat_InstallmentDate, @Num_InstallmentBase, @Num_InstallmentProf, @Num_BaseRemain, @Num_ProfRemain);
            SET @SiLonLoans_Dt = SCOPE_IDENTITY();
            IF ISNULL(@SiLonLoans_Dt, 0) = 0
                BEGIN
                    SET @SiLonLoans_Dt = 0;
                    SET @Err_Code = 400;
                END
            RETURN;
        END
    -- ============================================================
    -- UPDATE
    -- ============================================================
    IF @FlgInsUpdDel = 1
        BEGIN
            SET @Err_Code = 0;
            IF EXISTS (SELECT StmLonLoans_Dt
                       FROM   dbo.Tss_LonLoansDt
                       WHERE  SiLonLoans_Dt = @SiLonLoans_Dt
                              AND StmLonLoans_Dt = @StmLonLoans_Dt)
                BEGIN
                    UPDATE dbo.Tss_LonLoansDt
                    SET    SiLonLoans          = @SiLonLoans,
                           Cod_LoansDtCode     = @Cod_LoansDtCode,
                           Dat_InstallmentDate = @Dat_InstallmentDate,
                           Num_InstallmentBase = @Num_InstallmentBase,
                           Num_InstallmentProf = @Num_InstallmentProf,
                           Num_BaseRemain      = @Num_BaseRemain,
                           Num_ProfRemain      = @Num_ProfRemain
                    WHERE  SiLonLoans_Dt = @SiLonLoans_Dt;
                    SET @Err_Code = @@ERROR;
                    IF @Err_Code <> 0
                        SET @Err_Code = 401;
                END
            ELSE
                BEGIN
                    SET @Err_Code = 402;
                END
            RETURN;
        END
    -- ============================================================
    -- DELETE
    -- ============================================================
    IF @FlgInsUpdDel = 2
        BEGIN
            SET @Err_Code = 0;
            IF EXISTS (SELECT StmLonLoans_Dt
                       FROM   dbo.Tss_LonLoansDt
                       WHERE  SiLonLoans_Dt = @SiLonLoans_Dt
                              AND StmLonLoans_Dt = @StmLonLoans_Dt)
                BEGIN
                    DELETE dbo.Tss_LonLoansDt
                    WHERE  SiLonLoans_Dt = @SiLonLoans_Dt;
                    SET @Err_Code = @@ERROR;
                    IF @Err_Code <> 0
                        SET @Err_Code = 4000;
                END
            ELSE
                BEGIN
                    SET @Err_Code = 4001;
                END
            RETURN;
        END
    -- If none of the above, return with an error (optional)
    SET @Err_Code = 999; -- Unknown operation
END


GO
-- Script to create or alter the Tss_GenDates table
DECLARE @TableName AS NVARCHAR (128) = 'Tss_GenDates';

DECLARE @SchemaName AS NVARCHAR (128) = 'dbo';

DECLARE @FullTableName AS NVARCHAR (256) = @SchemaName + '.' + @TableName;

-- Check if table exists
IF NOT EXISTS (SELECT 1
               FROM   sys.objects
               WHERE  object_id = OBJECT_ID(@FullTableName)
                      AND type = 'U')
    BEGIN
        -- Table doesn't exist, create it
        PRINT 'Table ' + @FullTableName + ' does not exist. Creating...';
        CREATE TABLE [dbo].[Tss_GenDates] (
            [SiGenDates] NUMERIC (18, 0) IDENTITY (1, 1) NOT NULL,
            [Dat_GenShamsiDate] VARCHAR (10) NOT NULL,
            [Dat_GenMiladiDate] VARCHAR (10) NOT NULL,
            [Dat_GenGhamariDate] VARCHAR (500) NULL,
            [Num_GenDayNo] SMALLINT NOT NULL,
            [IsHoliday] BIT NULL,
            [HolidayTitle] NVARCHAR (500) NULL,
            [StmGenDates] TIMESTAMP NULL,
            CONSTRAINT [PK_TSS_GENDATES] PRIMARY KEY CLUSTERED ([SiGenDates] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
        ) ON [PRIMARY];
        PRINT 'Table ' + @FullTableName + ' created successfully.';
    END
ELSE
    BEGIN
        -- Table exists, compare and apply changes
        PRINT 'Table ' + @FullTableName + ' exists. Checking for differences...';
        -- 1. Check and add missing columns
        -- SiGenDates
        IF NOT EXISTS (SELECT 1
                       FROM   sys.columns
                       WHERE  object_id = OBJECT_ID(@FullTableName)
                              AND name = 'SiGenDates')
            BEGIN
                PRINT 'Adding column SiGenDates...';
                ALTER TABLE [dbo].[Tss_GenDates]
                    ADD [SiGenDates] NUMERIC (18, 0) IDENTITY (1, 1) NOT NULL;
            END
        -- Dat_GenShamsiDate
        IF NOT EXISTS (SELECT 1
                       FROM   sys.columns
                       WHERE  object_id = OBJECT_ID(@FullTableName)
                              AND name = 'Dat_GenShamsiDate')
            BEGIN
                PRINT 'Adding column Dat_GenShamsiDate...';
                ALTER TABLE [dbo].[Tss_GenDates]
                    ADD [Dat_GenShamsiDate] VARCHAR (10) NOT NULL;
            END
        -- Dat_GenMiladiDate
        IF NOT EXISTS (SELECT 1
                       FROM   sys.columns
                       WHERE  object_id = OBJECT_ID(@FullTableName)
                              AND name = 'Dat_GenMiladiDate')
            BEGIN
                PRINT 'Adding column Dat_GenMiladiDate...';
                ALTER TABLE [dbo].[Tss_GenDates]
                    ADD [Dat_GenMiladiDate] VARCHAR (10) NOT NULL;
            END
        -- Dat_GenGhamariDate
        IF NOT EXISTS (SELECT 1
                       FROM   sys.columns
                       WHERE  object_id = OBJECT_ID(@FullTableName)
                              AND name = 'Dat_GenGhamariDate')
            BEGIN
                PRINT 'Adding column Dat_GenGhamariDate...';
                ALTER TABLE [dbo].[Tss_GenDates]
                    ADD [Dat_GenGhamariDate] VARCHAR (500) NULL;
            END
        -- Num_GenDayNo
        IF NOT EXISTS (SELECT 1
                       FROM   sys.columns
                       WHERE  object_id = OBJECT_ID(@FullTableName)
                              AND name = 'Num_GenDayNo')
            BEGIN
                PRINT 'Adding column Num_GenDayNo...';
                ALTER TABLE [dbo].[Tss_GenDates]
                    ADD [Num_GenDayNo] SMALLINT NOT NULL;
            END
        -- IsHoliday
        IF NOT EXISTS (SELECT 1
                       FROM   sys.columns
                       WHERE  object_id = OBJECT_ID(@FullTableName)
                              AND name = 'IsHoliday')
            BEGIN
                PRINT 'Adding column IsHoliday...';
                ALTER TABLE [dbo].[Tss_GenDates]
                    ADD [IsHoliday] BIT NULL;
            END
        -- HolidayTitle
        IF NOT EXISTS (SELECT 1
                       FROM   sys.columns
                       WHERE  object_id = OBJECT_ID(@FullTableName)
                              AND name = 'HolidayTitle')
            BEGIN
                PRINT 'Adding column HolidayTitle...';
                ALTER TABLE [dbo].[Tss_GenDates]
                    ADD [HolidayTitle] NVARCHAR (500) NULL;
            END
        -- StmGenDates
        IF NOT EXISTS (SELECT 1
                       FROM   sys.columns
                       WHERE  object_id = OBJECT_ID(@FullTableName)
                              AND name = 'StmGenDates')
            BEGIN
                PRINT 'Adding column StmGenDates...';
                ALTER TABLE [dbo].[Tss_GenDates]
                    ADD [StmGenDates] TIMESTAMP NULL;
            END
        -- 2. Check and modify column data types if needed
        -- Check Dat_GenShamsiDate
        IF EXISTS (SELECT 1
                   FROM   sys.columns AS c
                          INNER JOIN
                          sys.types AS t
                          ON c.user_type_id = t.user_type_id
                   WHERE  c.object_id = OBJECT_ID(@FullTableName)
                          AND c.name = 'Dat_GenShamsiDate'
                          AND (t.name != 'varchar'
                               OR c.max_length != 10
                               OR c.is_nullable != 0))
            BEGIN
                PRINT 'Modifying column Dat_GenShamsiDate data type...';
                ALTER TABLE [dbo].[Tss_GenDates] ALTER COLUMN [Dat_GenShamsiDate] VARCHAR (10) NOT NULL;
            END
        -- Check Dat_GenMiladiDate
        IF EXISTS (SELECT 1
                   FROM   sys.columns AS c
                          INNER JOIN
                          sys.types AS t
                          ON c.user_type_id = t.user_type_id
                   WHERE  c.object_id = OBJECT_ID(@FullTableName)
                          AND c.name = 'Dat_GenMiladiDate'
                          AND (t.name != 'varchar'
                               OR c.max_length != 10
                               OR c.is_nullable != 0))
            BEGIN
                PRINT 'Modifying column Dat_GenMiladiDate data type...';
                ALTER TABLE [dbo].[Tss_GenDates] ALTER COLUMN [Dat_GenMiladiDate] VARCHAR (10) NOT NULL;
            END
        -- Check Dat_GenGhamariDate
        IF EXISTS (SELECT 1
                   FROM   sys.columns AS c
                          INNER JOIN
                          sys.types AS t
                          ON c.user_type_id = t.user_type_id
                   WHERE  c.object_id = OBJECT_ID(@FullTableName)
                          AND c.name = 'Dat_GenGhamariDate'
                          AND (t.name != 'varchar'
                               OR c.max_length != 500
                               OR c.is_nullable != 1))
            BEGIN
                PRINT 'Modifying column Dat_GenGhamariDate data type...';
                ALTER TABLE [dbo].[Tss_GenDates] ALTER COLUMN [Dat_GenGhamariDate] VARCHAR (500) NULL;
            END
        -- Check Num_GenDayNo
        IF EXISTS (SELECT 1
                   FROM   sys.columns AS c
                          INNER JOIN
                          sys.types AS t
                          ON c.user_type_id = t.user_type_id
                   WHERE  c.object_id = OBJECT_ID(@FullTableName)
                          AND c.name = 'Num_GenDayNo'
                          AND (t.name != 'smallint'
                               OR c.is_nullable != 0))
            BEGIN
                PRINT 'Modifying column Num_GenDayNo data type...';
                ALTER TABLE [dbo].[Tss_GenDates] ALTER COLUMN [Num_GenDayNo] SMALLINT NOT NULL;
            END
        -- Check IsHoliday
        IF EXISTS (SELECT 1
                   FROM   sys.columns AS c
                          INNER JOIN
                          sys.types AS t
                          ON c.user_type_id = t.user_type_id
                   WHERE  c.object_id = OBJECT_ID(@FullTableName)
                          AND c.name = 'IsHoliday'
                          AND (t.name != 'bit'
                               OR c.is_nullable != 1))
            BEGIN
                PRINT 'Modifying column IsHoliday data type...';
                ALTER TABLE [dbo].[Tss_GenDates] ALTER COLUMN [IsHoliday] BIT NULL;
            END
        -- Check HolidayTitle
        IF EXISTS (SELECT 1
                   FROM   sys.columns AS c
                          INNER JOIN
                          sys.types AS t
                          ON c.user_type_id = t.user_type_id
                   WHERE  c.object_id = OBJECT_ID(@FullTableName)
                          AND c.name = 'HolidayTitle'
                          AND (t.name != 'nvarchar'
                               OR c.max_length != 1000
                               OR c.is_nullable != 1))
            BEGIN
                PRINT 'Modifying column HolidayTitle data type...';
                ALTER TABLE [dbo].[Tss_GenDates] ALTER COLUMN [HolidayTitle] NVARCHAR (500) NULL;
            END
        -- 3. Check and create primary key if missing
        IF NOT EXISTS (SELECT 1
                       FROM   sys.key_constraints
                       WHERE  parent_object_id = OBJECT_ID(@FullTableName)
                              AND type = 'PK'
                              AND name = 'PK_TSS_GENDATES')
            BEGIN
                PRINT 'Creating primary key PK_TSS_GENDATES...';
                ALTER TABLE [dbo].[Tss_GenDates]
                    ADD CONSTRAINT [PK_TSS_GENDATES] PRIMARY KEY CLUSTERED ([SiGenDates] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
            END
        PRINT 'Table ' + @FullTableName + ' verified and updated successfully.';
    END


GO
ALTER PROCEDURE Tss_AccUntAccountReviewRStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)='', @DsFromDate VARCHAR (10)='1399/01/01', @DsToDate VARCHAR (10)='1399/03/13', @SiAccFinancePeriod NUMERIC=20, @SiPubSubLocations VARCHAR (500)='1,2', @Sta_Start SMALLINT=0, @Sta_End SMALLINT=0, @Sta_Close SMALLINT=0, @FlgLevel SMALLINT=2, @FlgTafType SMALLINT=0, @SiSelected VARCHAR (50)='', @Cod_AccountLevel1 VARCHAR (50)='', @Cod_AccountLevel2 VARCHAR (50)='', @StaBaMandeh SMALLINT=0
AS
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_NULLS ON;
SET ANSI_NULL_DFLT_ON ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET QUOTED_IDENTIFIER ON;
IF @InternalWhere <> ''
    SET @InternalWhere = ' Where ' + @InternalWhere;
IF @Where <> ''
    SET @Where = ' Where ' + @Where;
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
ELSE
    SET @Order = ' Order By Acc_Code';
DECLARE @WhType AS VARCHAR (500), @SqlTxt AS VARCHAR (4000), @AccAllDocs AS SMALLINT, @TafName AS VARCHAR (100);
SELECT SiAccFinancePeriodToPlace
INTO   #TempTable
FROM   dbo.Tss_AccFinancePeriodToPlace
WHERE  (SiPubSubLocations IN (SELECT *
                              FROM   dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations)));
--select * from #TempTable
SET @WhType = '';
IF @Sta_Start = 0
    SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
    FROM   Tss_AccVoucherType
    WHERE  (Sta_VoucherTypeGroup = 0);
IF @Sta_End = 0
    IF @WhType = ''
        SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
    ELSE
        SELECT @WhType = @WhType + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
IF @Sta_Close = 0
    IF @WhType = ''
        SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
    ELSE
        SELECT @WhType = @WhType + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
IF @FlgTafType = 0
    SET @TafName = 'SiPubPersonsSpec1';
IF @FlgTafType = 1
    SET @TafName = 'SiPubCostCenter1';
IF @FlgTafType = 2
    SET @TafName = 'SiPubProjects1';
IF @FlgTafType = 3
    SET @TafName = 'SiPurOrder_Hd1';
SELECT @AccAllDocs = dbo.Tss_StdFindSystemParamValue('AccAllDocs');
IF @FlgLevel = 1
    BEGIN
        SET @SqlTxt = 'SELECT     
      left(cBook.Cod_AccountCode,2) Acc_Code, 
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2, 
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3, 
      cBook.SiAccCodeBook as SiAccCodeBook,
      vDet.Num_VdetDebtAmount, 
      vDet.Num_VdetCreditAmount
   FROM         
      dbo.Tss_AccCodeBook cBook 
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook 
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) AND
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) AND
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        IF @SiSelected <> ''
            SET @SqlTxt = @SqlTxt + ' and (vDet.' + @TafName + '=' + @SiSelected + ') ';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = 'Select
         Ddd2.Acc_Code,
         Ddd2.SiAccCodeBook,  -- Qualified with Ddd2 alias
         Ddd2.Acc_Bed,
         Ddd2.Acc_Bes,
         Case When Ddd2.Acc_Bed>Ddd2.Acc_Bes Then Ddd2.Acc_Bed-Ddd2.Acc_Bes Else 0 End As Rst_Bed,
         Case When Ddd2.Acc_Bes>Ddd2.Acc_Bed Then Ddd2.Acc_Bes-Ddd2.Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1 
      From 
      (
         Select 
            Acc_Code,
            SiAccCodeBook,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From 
         (' + @SqlTxt + '

         ) Ddd
         Group By Acc_Code, SiAccCodeBook
      ) Ddd2 
      INNER JOIN dbo.Tss_AccCodeBook ON 
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode';
    END
IF @FlgLevel = 2
    BEGIN
        SET @SqlTxt = 'SELECT     
      left(cBook.Cod_AccountCode,4) As Acc_Code, 
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2, 
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3, 
      cBook.SiAccCodeBook as SiAccCodeBook,
      vDet.Num_VdetDebtAmount, 
      vDet.Num_VdetCreditAmount
   FROM         
      dbo.Tss_AccCodeBook cBook 
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook 
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE  ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        IF @Cod_AccountLevel1 <> ''
            SET @SqlTxt = @SqlTxt + 'AND (left(cBook.Cod_AccountCode,2)=' + '''' + @Cod_AccountLevel1 + '''' + ')';
        ELSE
            SET @SqlTxt = @SqlTxt; --+' AND (Len(cBook.Cod_AccountCode)=4)'
        IF @SiSelected <> ''
            SET @SqlTxt = @SqlTxt + ' and (vDet.' + @TafName + '=' + @SiSelected + ') ';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = 'Select
         Ddd2.Acc_Code,
         Ddd2.SiAccCodeBook,  -- Qualified with Ddd2 alias
         Ddd2.Acc_Bed,
         Ddd2.Acc_Bes,
         Case When Ddd2.Acc_Bed>Ddd2.Acc_Bes Then Ddd2.Acc_Bed-Ddd2.Acc_Bes Else 0 End As Rst_Bed,
         Case When Ddd2.Acc_Bes>Ddd2.Acc_Bed Then Ddd2.Acc_Bes-Ddd2.Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1 
      From 
      (
         Select 
            Acc_Code,
            SiAccCodeBook,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From 
         (' + @SqlTxt + '

         ) Ddd
         Group By Acc_Code, SiAccCodeBook
      ) Ddd2 
      INNER JOIN dbo.Tss_AccCodeBook ON 
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode';
    END
IF @FlgLevel = 3
    BEGIN
        SET @SqlTxt = 'SELECT     
      left(cBook.Cod_AccountCode,6) As Acc_Code, 
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2, 
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3, 
      cBook.SiAccCodeBook as SiAccCodeBook,
      vDet.Num_VdetDebtAmount, 
      vDet.Num_VdetCreditAmount
   FROM         
      dbo.Tss_AccCodeBook cBook 
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook 
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        IF len(@Cod_AccountLevel2) = 4
            SET @SqlTxt = @SqlTxt + 'AND (left(cBook.Cod_AccountCode,4)=' + '''' + @Cod_AccountLevel2 + '''' + ')';
        IF @Cod_AccountLevel2 = ''
            SET @SqlTxt = @SqlTxt + 'AND (len(cBook.Cod_AccountCode)=6)';
        IF @SiSelected <> ''
            SET @SqlTxt = @SqlTxt + ' and (vDet.' + @TafName + '=' + @SiSelected + ') ';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = 'Select
         Ddd2.Acc_Code,
         Ddd2.SiAccCodeBook,  -- Qualified with Ddd2 alias
         Ddd2.Acc_Bed,
         Ddd2.Acc_Bes,
         Case When Ddd2.Acc_Bed>Ddd2.Acc_Bes Then Ddd2.Acc_Bed-Ddd2.Acc_Bes Else 0 End As Rst_Bed,
         Case When Ddd2.Acc_Bes>Ddd2.Acc_Bed Then Ddd2.Acc_Bes-Ddd2.Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1 
      From 
      (
         Select 
            Acc_Code,
            SiAccCodeBook,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From 
         (' + @SqlTxt + '

         ) Ddd
         Group By Acc_Code, SiAccCodeBook
      ) Ddd2 
      INNER JOIN dbo.Tss_AccCodeBook ON 
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode';
    END
EXECUTE ('Select * From
(
   Select * From
   ( ' + @SqlTxt + ' ) Ccc  ' + @InternalWhere + '
) CalcSel ' + @Where + @Order);
PRINT @SqlTxt;


GO
ALTER PROCEDURE Tss_AccUntAccountReviewTafsilRStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)='', @DsFromDate VARCHAR (10)='1390/01/01', @DsToDate VARCHAR (10)='1397/12/29', @SiAccFinancePeriod NUMERIC=9, @SiPubSubLocations VARCHAR (500)='1,2', @Sta_Start SMALLINT=0, @Sta_End SMALLINT=0, @Sta_Close SMALLINT=0, @FlgLevel SMALLINT=4, @Cod_AccountCode VARCHAR (50)='611012', @StaBaMandeh SMALLINT=0
AS
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_NULLS ON;
SET ANSI_NULL_DFLT_ON ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET QUOTED_IDENTIFIER ON;
IF @InternalWhere <> ''
    SET @InternalWhere = ' Where ' + @InternalWhere;
IF @Where <> ''
    SET @Where = ' Where ' + @Where;
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
ELSE
    SET @Order = ' Order By convert(numeric,TafCode)';
DECLARE @WhType AS VARCHAR (20), @SqlTxt AS VARCHAR (4000), @Sta_TafType1 AS SMALLINT, @SiAccCodeBook AS NUMERIC, @AccAllDocs AS SMALLINT;
SELECT @AccAllDocs = dbo.Tss_StdFindSystemParamValue('AccAllDocs');
SELECT SiAccFinancePeriodToPlace
INTO   #TempTable
FROM   dbo.Tss_AccFinancePeriodToPlace
WHERE  --	(SiAccFinancePeriod=@SiAccFinancePeriod) And
(SiPubSubLocations IN (SELECT *
                       FROM   dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations)));
--select * from #TempTable
SELECT @Sta_TafType1 = Sta_TafType1,
       @SiAccCodeBook = SiAccCodeBook
FROM   dbo.Tss_AccCodeBook AS cBook
WHERE  (Cod_AccountCode = @Cod_AccountCode);
SET @WhType = '';
IF @Sta_Start = 0
    SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
    FROM   Tss_AccVoucherType
    WHERE  (Sta_VoucherTypeGroup = 0);
IF @Sta_End = 0
    IF @WhType = ''
        SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
    ELSE
        SELECT @WhType = @WhType + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
IF @Sta_Close = 0
    IF @WhType = ''
        SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
    ELSE
        SELECT @WhType = @WhType + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
IF @Sta_TafType1 = 1
    BEGIN
        SET @SqlTxt = '
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Acc_Bed,
      Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
		Des_CodeDescription
   From
   (
      SELECT     
         dbo.Tss_PubPersonsViw.Cod_PubPersonCode TafCode, 
         dbo.Tss_PubPersonsViw.Des_FullName TafDesc,
         dbo.Tss_PubPersonsViw.SiPubPersonsSpec as SiTaf,  -- SiPubPersonsSpec for @Sta_TafType1=1
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount,
			'''' Des_VdetDesc,
			'''' Dat_AccVoucherDetDate,
			$0.0 Num_VdetAmount,
			dbo.Tss_PubPersonsViw.Des_CodeDescription
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubPersonsViw ON vDet.SiPubPersonsSpec1 = dbo.Tss_PubPersonsViw.SiPubPersonsSpec
      WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND 
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND 
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = @SqlTxt + ' ) Ddd ';
        SET @SqlTxt = @SqlTxt + ' Group By TafCode, TafDesc, SiTaf, Des_VdetDesc, Dat_AccVoucherDetDate, Num_VdetAmount, Des_CodeDescription ) Dd2 '; --print @SqlTxt
    END
IF @Sta_TafType1 = 2
    BEGIN
        SET @SqlTxt = '
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Acc_Bed,
      Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
		Des_CodeDescription
   From
   (
      SELECT     
         dbo.Tss_PubCostCenter.Cod_CostCenterCode TafCode,  
         dbo.Tss_PubCostCenter.Des_CostCenterName TafDesc,
         dbo.Tss_PubCostCenter.SiPubCostCenter as SiTaf,  -- SiPubCostCenter for @Sta_TafType1=2
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount,
			'''' Des_VdetDesc,
			'''' Dat_AccVoucherDetDate,
			$0.0 Num_VdetAmount,
			dbo.Tss_PubCostCenter.Des_CodeDescription
      FROM   
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubCostCenter ON vDet.SiPubCostCenter1 = dbo.Tss_PubCostCenter.SiPubCostCenter
      WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
	      (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
	      (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = @SqlTxt + ' ) Ddd
   Group By TafCode, TafDesc, SiTaf, Des_VdetDesc, Dat_AccVoucherDetDate, Num_VdetAmount, Des_CodeDescription ) Dd2';
    END
IF @Sta_TafType1 = 3
    BEGIN
        SET @SqlTxt = '
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Acc_Bed,
      Acc_Bes,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		'''' as Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes
   From
   (
      SELECT     
         dbo.Tss_PubProjects.Cod_ProjectsCode TafCode,  
         dbo.Tss_PubProjects.Des_ProjectsThemeDesc TafDesc,
         dbo.Tss_PubProjects.SiPubProjects as SiTaf,  -- SiPubProjects for @Sta_TafType1=3
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount 
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubProjects ON vDet.SiPubProjects1 = dbo.Tss_PubProjects.SiPubProjects
      WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = @SqlTxt + ' ) Ddd
   Group By TafCode, TafDesc, SiTaf ) Dd2'; -- Added SiTaf to GROUP BY
    END
IF @Sta_TafType1 = 4
    BEGIN
        SET @SqlTxt = '
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Acc_Bed,
      Acc_Bes,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		'''' Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes
   From
   (
      SELECT     
         dbo.Tss_PurOrder_Hd.Cod_PurOrderCode TafCode,  
         dbo.Tss_PurOrder_Hd.Des_PurOrderDesc TafDesc,
         dbo.Tss_PurOrder_Hd.SiPurOrder_Hd as SiTaf,  -- SiPurOrder_Hd for @Sta_TafType1=4
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount 
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PurOrder_Hd ON vDet.SiPurOrder_Hd1 = dbo.Tss_PurOrder_Hd.SiPurOrder_Hd
      WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = @SqlTxt + ' ) Ddd
   Group By TafCode, TafDesc, SiTaf ) Dd2'; -- Added SiTaf to GROUP BY
    END
-- If @Sta_TafType1=0, return NULL for SiTaf
IF @Sta_TafType1 = 0
    BEGIN
        SET @SqlTxt = '
   Select 
      '''' TafCode,
      '''' TafDesc,
      NULL as SiTaf,  -- NULL when @Sta_TafType1=0
      convert(numeric,0) Acc_Bed,
      convert(numeric,0) Acc_Bes,
      convert(numeric,0) Rst_Bed,
      convert(numeric,0) Rst_Bes,
      '''' Des_VdetDesc,
      '''' Dat_AccVoucherDetDate,
      convert(numeric,0) Num_VdetAmount,
      '''' RelatedSaler,
      '''' Des_CodeDescription
   ';
    END
PRINT @SqlTxt;
IF @Sta_TafType1 <> 0
    EXECUTE ('Select * From
(
   Select * From
   ( ' + @SqlTxt + ' ) Ccc  ' + @InternalWhere + '
) CalcSel ' + @Where + @Order);
ELSE
    EXECUTE (@SqlTxt);


GO
ALTER PROCEDURE Tss_AccUntAccountReviewRStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)='', @DsFromDate VARCHAR (10)='1399/01/01', @DsToDate VARCHAR (10)='1399/03/13', @SiAccFinancePeriod NUMERIC=20, @SiPubSubLocations VARCHAR (500)='1,2', @Sta_Start SMALLINT=0, @Sta_End SMALLINT=0, @Sta_Close SMALLINT=0, @FlgLevel SMALLINT=2, @FlgTafType SMALLINT=0, @SiSelected VARCHAR (50)='', @Cod_AccountLevel1 VARCHAR (50)='', @Cod_AccountLevel2 VARCHAR (50)='', @StaBaMandeh SMALLINT=0
AS
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_NULLS ON;
SET ANSI_NULL_DFLT_ON ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET QUOTED_IDENTIFIER ON;
IF @InternalWhere <> ''
    SET @InternalWhere = ' Where ' + @InternalWhere;
IF @Where <> ''
    SET @Where = ' Where ' + @Where;
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
ELSE
    SET @Order = ' Order By Acc_Code';
DECLARE @WhType AS VARCHAR (500), @SqlTxt AS VARCHAR (4000), @AccAllDocs AS SMALLINT, @TafName AS VARCHAR (100);
SELECT SiAccFinancePeriodToPlace
INTO   #TempTable
FROM   dbo.Tss_AccFinancePeriodToPlace
WHERE  (SiPubSubLocations IN (SELECT *
                              FROM   dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations)));
--select * from #TempTable
SET @WhType = '';
IF @Sta_Start = 0
    SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
    FROM   Tss_AccVoucherType
    WHERE  (Sta_VoucherTypeGroup = 0);
IF @Sta_End = 0
    IF @WhType = ''
        SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
    ELSE
        SELECT @WhType = @WhType + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
IF @Sta_Close = 0
    IF @WhType = ''
        SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
    ELSE
        SELECT @WhType = @WhType + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
IF @FlgTafType = 0
    SET @TafName = 'SiPubPersonsSpec1';
IF @FlgTafType = 1
    SET @TafName = 'SiPubCostCenter1';
IF @FlgTafType = 2
    SET @TafName = 'SiPubProjects1';
IF @FlgTafType = 3
    SET @TafName = 'SiPurOrder_Hd1';
SELECT @AccAllDocs = dbo.Tss_StdFindSystemParamValue('AccAllDocs');
IF @FlgLevel = 1
    BEGIN
        SET @SqlTxt = 'SELECT     
      left(cBook.Cod_AccountCode,2) Acc_Code, 
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2, 
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3, 
      cBook.SiAccCodeBook as SiAccCodeBook,
      vDet.Num_VdetDebtAmount, 
      vDet.Num_VdetCreditAmount
   FROM         
      dbo.Tss_AccCodeBook cBook 
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook 
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) AND
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) AND
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        IF @SiSelected <> ''
            SET @SqlTxt = @SqlTxt + ' and (vDet.' + @TafName + '=' + @SiSelected + ') ';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = 'Select
         Ddd2.Acc_Code,
         Ddd2.SiAccCodeBook,  -- Qualified with Ddd2 alias
         Ddd2.Acc_Bed,
         Ddd2.Acc_Bes,
         Case When Ddd2.Acc_Bed>Ddd2.Acc_Bes Then Ddd2.Acc_Bed-Ddd2.Acc_Bes Else 0 End As Rst_Bed,
         Case When Ddd2.Acc_Bes>Ddd2.Acc_Bed Then Ddd2.Acc_Bes-Ddd2.Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1 
      From 
      (
         Select 
            Acc_Code,
            SiAccCodeBook,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From 
         (' + @SqlTxt + '

         ) Ddd
         Group By Acc_Code, SiAccCodeBook
      ) Ddd2 
      INNER JOIN dbo.Tss_AccCodeBook ON 
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode';
    END
IF @FlgLevel = 2
    BEGIN
        SET @SqlTxt = 'SELECT     
      left(cBook.Cod_AccountCode,4) As Acc_Code, 
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2, 
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3, 
      cBook.SiAccCodeBook as SiAccCodeBook,
      vDet.Num_VdetDebtAmount, 
      vDet.Num_VdetCreditAmount
   FROM         
      dbo.Tss_AccCodeBook cBook 
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook 
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE  ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        IF @Cod_AccountLevel1 <> ''
            SET @SqlTxt = @SqlTxt + 'AND (left(cBook.Cod_AccountCode,2)=' + '''' + @Cod_AccountLevel1 + '''' + ')';
        ELSE
            SET @SqlTxt = @SqlTxt; --+' AND (Len(cBook.Cod_AccountCode)=4)'
        IF @SiSelected <> ''
            SET @SqlTxt = @SqlTxt + ' and (vDet.' + @TafName + '=' + @SiSelected + ') ';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = 'Select
         Ddd2.Acc_Code,
         Ddd2.SiAccCodeBook,  -- Qualified with Ddd2 alias
         Ddd2.Acc_Bed,
         Ddd2.Acc_Bes,
         Case When Ddd2.Acc_Bed>Ddd2.Acc_Bes Then Ddd2.Acc_Bed-Ddd2.Acc_Bes Else 0 End As Rst_Bed,
         Case When Ddd2.Acc_Bes>Ddd2.Acc_Bed Then Ddd2.Acc_Bes-Ddd2.Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1 
      From 
      (
         Select 
            Acc_Code,
            SiAccCodeBook,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From 
         (' + @SqlTxt + '

         ) Ddd
         Group By Acc_Code, SiAccCodeBook
      ) Ddd2 
      INNER JOIN dbo.Tss_AccCodeBook ON 
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode';
    END
IF @FlgLevel = 3
    BEGIN
        SET @SqlTxt = 'SELECT     
      left(cBook.Cod_AccountCode,6) As Acc_Code, 
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2, 
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3, 
      cBook.SiAccCodeBook as SiAccCodeBook,
      vDet.Num_VdetDebtAmount, 
      vDet.Num_VdetCreditAmount
   FROM         
      dbo.Tss_AccCodeBook cBook 
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook 
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        IF len(@Cod_AccountLevel2) = 4
            SET @SqlTxt = @SqlTxt + 'AND (left(cBook.Cod_AccountCode,4)=' + '''' + @Cod_AccountLevel2 + '''' + ')';
        IF @Cod_AccountLevel2 = ''
            SET @SqlTxt = @SqlTxt + 'AND (len(cBook.Cod_AccountCode)=6)';
        IF @SiSelected <> ''
            SET @SqlTxt = @SqlTxt + ' and (vDet.' + @TafName + '=' + @SiSelected + ') ';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = 'Select
         Ddd2.Acc_Code,
         Ddd2.SiAccCodeBook,  -- Qualified with Ddd2 alias
         Ddd2.Acc_Bed,
         Ddd2.Acc_Bes,
         Case When Ddd2.Acc_Bed>Ddd2.Acc_Bes Then Ddd2.Acc_Bed-Ddd2.Acc_Bes Else 0 End As Rst_Bed,
         Case When Ddd2.Acc_Bes>Ddd2.Acc_Bed Then Ddd2.Acc_Bes-Ddd2.Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1 
      From 
      (
         Select 
            Acc_Code,
            SiAccCodeBook,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From 
         (' + @SqlTxt + '

         ) Ddd
         Group By Acc_Code, SiAccCodeBook
      ) Ddd2 
      INNER JOIN dbo.Tss_AccCodeBook ON 
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode';
    END
EXECUTE ('Select * From
(
   Select * From
   ( ' + @SqlTxt + ' ) Ccc  ' + @InternalWhere + '
) CalcSel ' + @Where + @Order);


GO
ALTER PROCEDURE Tss_AccUntAccountReviewTafsilRStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)='', @DsFromDate VARCHAR (10)='1390/01/01', @DsToDate VARCHAR (10)='1397/12/29', @SiAccFinancePeriod NUMERIC=9, @SiPubSubLocations VARCHAR (500)='1,2', @Sta_Start SMALLINT=0, @Sta_End SMALLINT=0, @Sta_Close SMALLINT=0, @FlgLevel SMALLINT=4, @Cod_AccountCode VARCHAR (50)='611012', @StaBaMandeh SMALLINT=0
AS
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_NULLS ON;
SET ANSI_NULL_DFLT_ON ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET QUOTED_IDENTIFIER ON;
IF @InternalWhere <> ''
    SET @InternalWhere = ' Where ' + @InternalWhere;
IF @Where <> ''
    SET @Where = ' Where ' + @Where;
-- Fixed ORDER BY to avoid conversion errors
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
ELSE
    SET @Order = ' Order By CASE WHEN ISNUMERIC(TafCode)=1 THEN convert(numeric, TafCode) ELSE 999999 END';
DECLARE @WhType AS VARCHAR (20), @SqlTxt AS VARCHAR (4000), @Sta_TafType1 AS SMALLINT, @SiAccCodeBook AS NUMERIC, @AccAllDocs AS SMALLINT;
SELECT @AccAllDocs = dbo.Tss_StdFindSystemParamValue('AccAllDocs');
SELECT SiAccFinancePeriodToPlace
INTO   #TempTable
FROM   dbo.Tss_AccFinancePeriodToPlace
WHERE  (SiPubSubLocations IN (SELECT *
                              FROM   dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations)));
SELECT @Sta_TafType1 = Sta_TafType1,
       @SiAccCodeBook = SiAccCodeBook
FROM   dbo.Tss_AccCodeBook AS cBook
WHERE  (Cod_AccountCode = @Cod_AccountCode);
SET @WhType = '';
IF @Sta_Start = 0
    SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
    FROM   Tss_AccVoucherType
    WHERE  (Sta_VoucherTypeGroup = 0);
IF @Sta_End = 0
    IF @WhType = ''
        SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
    ELSE
        SELECT @WhType = @WhType + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
IF @Sta_Close = 0
    IF @WhType = ''
        SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
    ELSE
        SELECT @WhType = @WhType + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
IF @Sta_TafType1 = 1
    BEGIN
        SET @SqlTxt = '
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Acc_Bed,
      Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
		Des_CodeDescription
   From
   (
      SELECT     
         dbo.Tss_PubPersonsViw.Cod_PubPersonCode TafCode, 
         dbo.Tss_PubPersonsViw.Des_FullName TafDesc,
         dbo.Tss_PubPersonsViw.SiPubPersonsSpec as SiTaf,
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount,
			'''' Des_VdetDesc,
			'''' Dat_AccVoucherDetDate,
			$0.0 Num_VdetAmount,
			dbo.Tss_PubPersonsViw.Des_CodeDescription
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubPersonsViw ON vDet.SiPubPersonsSpec1 = dbo.Tss_PubPersonsViw.SiPubPersonsSpec
      WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND 
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND 
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = @SqlTxt + ' ) Ddd ';
        SET @SqlTxt = @SqlTxt + ' Group By TafCode, TafDesc, SiTaf, Des_VdetDesc, Dat_AccVoucherDetDate, Num_VdetAmount, Des_CodeDescription ) Dd2 ';
    END
IF @Sta_TafType1 = 2
    BEGIN
        SET @SqlTxt = '
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Acc_Bed,
      Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
		Des_CodeDescription
   From
   (
      SELECT     
         dbo.Tss_PubCostCenter.Cod_CostCenterCode TafCode,  
         dbo.Tss_PubCostCenter.Des_CostCenterName TafDesc,
         dbo.Tss_PubCostCenter.SiPubCostCenter as SiTaf,
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount,
			'''' Des_VdetDesc,
			'''' Dat_AccVoucherDetDate,
			$0.0 Num_VdetAmount,
			dbo.Tss_PubCostCenter.Des_CodeDescription
      FROM   
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubCostCenter ON vDet.SiPubCostCenter1 = dbo.Tss_PubCostCenter.SiPubCostCenter
      WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
	      (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
	      (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = @SqlTxt + ' ) Ddd
   Group By TafCode, TafDesc, SiTaf, Des_VdetDesc, Dat_AccVoucherDetDate, Num_VdetAmount, Des_CodeDescription ) Dd2';
    END
IF @Sta_TafType1 = 3
    BEGIN
        SET @SqlTxt = '
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Acc_Bed,
      Acc_Bes,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		'''' as Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes
   From
   (
      SELECT     
         dbo.Tss_PubProjects.Cod_ProjectsCode TafCode,  
         dbo.Tss_PubProjects.Des_ProjectsThemeDesc TafDesc,
         dbo.Tss_PubProjects.SiPubProjects as SiTaf,
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount 
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubProjects ON vDet.SiPubProjects1 = dbo.Tss_PubProjects.SiPubProjects
      WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = @SqlTxt + ' ) Ddd
   Group By TafCode, TafDesc, SiTaf ) Dd2';
    END
IF @Sta_TafType1 = 4
    BEGIN
        SET @SqlTxt = '
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Acc_Bed,
      Acc_Bes,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		'''' Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes
   From
   (
      SELECT     
         dbo.Tss_PurOrder_Hd.Cod_PurOrderCode TafCode,  
         dbo.Tss_PurOrder_Hd.Des_PurOrderDesc TafDesc,
         dbo.Tss_PurOrder_Hd.SiPurOrder_Hd as SiTaf,
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount 
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PurOrder_Hd ON vDet.SiPurOrder_Hd1 = dbo.Tss_PurOrder_Hd.SiPurOrder_Hd
      WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = @SqlTxt + ' ) Ddd
   Group By TafCode, TafDesc, SiTaf ) Dd2';
    END
-- If @Sta_TafType1=0, return NULL for SiTaf
IF @Sta_TafType1 = 0
    BEGIN
        SET @SqlTxt = '
   Select 
      '''' TafCode,
      '''' TafDesc,
      NULL as SiTaf,
      convert(numeric,0) Acc_Bed,
      convert(numeric,0) Acc_Bes,
      convert(numeric,0) Rst_Bed,
      convert(numeric,0) Rst_Bes,
      '''' Des_VdetDesc,
      '''' Dat_AccVoucherDetDate,
      convert(numeric,0) Num_VdetAmount,
      '''' RelatedSaler,
      '''' Des_CodeDescription
   ';
    END
PRINT @SqlTxt;
IF @Sta_TafType1 <> 0
    EXECUTE ('Select * From
(
   Select * From
   ( ' + @SqlTxt + ' ) Ccc  ' + @InternalWhere + '
) CalcSel ' + @Where + @Order);
ELSE
    EXECUTE (@SqlTxt);


GO
ALTER PROCEDURE Tss_AccUntDailyDafDetailedPreRepVStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)='', @DsStart VARCHAR (10)='1402/01/01', @DsEnd VARCHAR (10)='1402/01/05', @SiAccCodeBook VARCHAR (8000)='', @Desc VARCHAR (500)='', @TafDesc VARCHAR (500)='', @MoeinCode VARCHAR (500)='', @MoeinDesc VARCHAR (500)='', @BedAmountFilter VARCHAR (500)='', @BesAmountFilter VARCHAR (500)='', @StaFtet SMALLINT=1, @StaEkhtem SMALLINT=0, @StavClose SMALLINT=0, @SiFinProd NUMERIC=14, @SiSubLoc VARCHAR (500)='1,2,3,4,5,6,7,8,9,10', @SiUser NUMERIC=1
AS
SET XACT_ABORT ON;
IF @InternalWhere <> ''
    SET @InternalWhere = ' Where ' + @InternalWhere;
IF isnull(@Where, '') = ''
    BEGIN
        IF (dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'AccStar') <> 1)
            SET @Where = 'where (isnull(Sta_IsHidden,0)=0)';
    END
ELSE
    BEGIN
        IF (dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'AccStar') <> 1)
            SET @Where = @Where + ' and (isnull(Sta_IsHidden,0)=0)';
    END
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
ELSE
    SET @Order = ' Order By KolCode,MoeinCode' + @Order;
SELECT SiAccFinancePeriodToPlace
INTO   #TempTable
FROM   dbo.Tss_AccFinancePeriodToPlace
WHERE  --	(SiAccFinancePeriod=@SiFinProd) And
(SiPubSubLocations IN (SELECT *
                       FROM   dbo.Tss_StdStringSiFindUdf(@SiSubLoc)));
DECLARE @SqlTxt AS VARCHAR (8000), @WhSi AS VARCHAR (200);
SET @SqlTxt = 'Select 
		SiAccCodeBook, 
		SiPubPersonsSpec1, 
		SiPubCostCenter1, 
		Num_VhedFinalNo,
		Num_VhedSubNo,
		Sta_VdetDebtOrCredit, 
		Dat_AccVoucherDetDate,
		SiAccVoucher_Dt, 
		SiAccVoucher_Hd, 
		Des_VdetDesc, 
		Num_VdetDebtAmount, 
		Num_VdetCreditAmount, 
		Dat_VhedDate, 
		Cod_AccountCodeTot, 
		GroupCode, 
		KolCode, 
		MoeinCode, 
		Cod_PubPersonCode, 
		Cod_CostCenterCode, 
		Cod_AccFinancePeriod, 
		Des_AccFinancePeriod, 
		Cod_SubLocCode, 
		Des_SubLocName, 
		Num_VdetAmount, 
		Num_VDetRow, 
		Des_CostCenterName, 
		Cod_VoucherType, 
		Des_VoucherType, 
		Des_AccountDesc, 
		Des_AccountFullDesc, 
		Des_FullName,
		Cod1,
		Cod2,
		Cod3,
		SiRelatedSenderSerial,
		Sta_IsHidden,
		Case
			When  Num_VdetDebtAmount>Num_VdetCreditAmount then Num_VdetDebtAmount-Num_VdetCreditAmount
			When  Num_VdetDebtAmount<Num_VdetCreditAmount then 0
		End sRestBed,
		Case
			When  Num_VdetDebtAmount>Num_VdetCreditAmount then 0
			When  Num_VdetDebtAmount<Num_VdetCreditAmount then Num_VdetCreditAmount-Num_VdetDebtAmount
		End sRestBes,
		case 
			when isnull(Cod_PubPersonCode,'''')<>'''' then Cod_PubPersonCode 
			when isnull(Cod_CostCenterCode,'''')<>'''' then Cod_CostCenterCode 
		end as CodTaf,
		case 
			when isnull(Des_SubLocName,'''')<>'''' then Des_SubLocName 
			when isnull(Des_CostCenterName,'''')<>'''' then Des_CostCenterName 
		end as DesTaf
	From 
	   (
	   Select * From 
	(
	SELECT TOP 100 PERCENT 
		(SELECT Des_AccountDesc FROM Tss_AccCodeBook WHERE (Cod_AccountCode IN (SELECT LEFT(Cod_AccountCode, 2) FROM Tss_AccCodeBook WHERE (SiAccCodeBook = Tss_AccVoucher_Dt.SiAccCodeBook)))) Cod1,
		(SELECT Des_AccountDesc FROM Tss_AccCodeBook WHERE (Cod_AccountCode IN (SELECT LEFT(Cod_AccountCode, 4) FROM Tss_AccCodeBook WHERE (SiAccCodeBook = Tss_AccVoucher_Dt.SiAccCodeBook)))) Cod2,
		(SELECT Des_AccountDesc FROM Tss_AccCodeBook WHERE (Cod_AccountCode IN (SELECT LEFT(Cod_AccountCode, 6) FROM Tss_AccCodeBook WHERE (SiAccCodeBook = Tss_AccVoucher_Dt.SiAccCodeBook)))) Cod3,
		Tss_AccVoucher_Dt.SiAccVoucher_Dt, 
		Tss_AccVoucher_Dt.SiAccVoucher_Hd, 
		Tss_AccVoucher_Dt.Des_VdetDesc, 
		Tss_AccVoucher_Dt.Num_VdetDebtAmount, 
		Tss_AccVoucher_Dt.Num_VdetCreditAmount, 
		Tss_AccVoucher_Hd.Dat_VhedDate, 
		Tss_AccVoucher_Hd.Num_VhedFinalNo,
		Tss_AccVoucher_Hd.Num_VhedSubNo,
		Tss_AccCodeBook.Cod_AccountCode as Cod_AccountCodeTot, 
		SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 1, 2) AS GroupCode, 
		SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 1, 2) + SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 3, 2) AS KolCode, 
		SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 1, 2) + SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 3, 2) + SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 5, 2) AS MoeinCode, 
		Tss_PubPersonsViw.Cod_PubPersonCode, 
		Tss_PubCostCenter.Cod_CostCenterCode, 
		Tss_AccFinancePeriod.Cod_AccFinancePeriod, 
		Tss_AccFinancePeriod.Des_AccFinancePeriod, 
		Tss_PubSubLocations.Cod_SubLocCode, 
		Tss_PubSubLocations.Des_SubLocName, 
		Tss_AccVoucher_Dt.Num_VdetAmount, 
		Tss_AccVoucher_Dt.Num_VDetRow, 
		Tss_PubCostCenter.Des_CostCenterName, 
		Tss_AccVoucherType.Cod_VoucherType, 
		Tss_AccVoucherType.Des_VoucherType, 
		Tss_AccCodeBook.Des_AccountDesc, 
		Tss_AccCodeBook.Des_AccountFullDesc, 
		Tss_PubPersonsViw.Des_FullName, 

		Tss_AccVoucher_Dt.SiAccCodeBook, 
		Tss_AccVoucher_Dt.SiPubPersonsSpec1, 
		Tss_AccVoucher_Dt.SiPubCostCenter1, 
		Tss_AccVoucher_Dt.Sta_VdetDebtOrCredit, 
		Tss_AccVoucher_Dt.Dat_AccVoucherDetDate,
		Tss_AccVoucher_Dt.SiRelatedSenderSerial,
		Tss_AccVoucher_Dt.Sta_IsHidden
	FROM         
		Tss_AccVoucher_Dt INNER JOIN
		Tss_AccVoucher_Hd ON Tss_AccVoucher_Dt.SiAccVoucher_Hd = Tss_AccVoucher_Hd.SiAccVoucher_Hd INNER JOIN
		Tss_AccCodeBook ON Tss_AccVoucher_Dt.SiAccCodeBook = Tss_AccCodeBook.SiAccCodeBook INNER JOIN
		Tss_AccFinancePeriodToPlace ON 
		Tss_AccVoucher_Hd.SiAccFinancePeriodToPlace = Tss_AccFinancePeriodToPlace.SiAccFinancePeriodToPlace INNER JOIN
		Tss_AccFinancePeriod ON Tss_AccFinancePeriodToPlace.SiAccFinancePeriod = Tss_AccFinancePeriod.SiAccFinancePeriod INNER JOIN
		Tss_PubSubLocations ON Tss_AccFinancePeriodToPlace.SiPubSubLocations = Tss_PubSubLocations.SiPubSubLocations INNER JOIN
		Tss_AccVoucherType ON Tss_AccVoucher_Hd.SiAccVoucherType = Tss_AccVoucherType.SiAccVoucherType LEFT OUTER JOIN
		Tss_PubCostCenter ON Tss_AccVoucher_Dt.SiPubCostCenter1 = Tss_PubCostCenter.SiPubCostCenter LEFT OUTER JOIN
		Tss_PubPersonsViw ON Tss_AccVoucher_Dt.SiPubPersonsSpec1 = Tss_PubPersonsViw.SiPubPersonsSpec		
	WHERE     
		(dbo.Tss_AccVoucher_Hd.Dat_VhedDate BETWEEN ' + '''' + @DsStart + '''' + ' AND ' + '''' + @DsEnd + '''' + ') And
		(dbo.Tss_AccVoucher_Hd.SiAccFinancePeriodToPlace in (select * from #TempTable))';
IF Isnull(@Desc, '') <> ''
    SET @SqlTxt = @SqlTxt + ' and (Des_VdetDesc like ' + '''' + '%' + @Desc + '%' + '''' + ')';
IF Isnull(@TafDesc, '') <> ''
    SET @SqlTxt = @SqlTxt + ' and (Des_FullName like ' + '''' + '%' + @TafDesc + '%' + '''' + ')';
IF Isnull(@MoeinCode, '') <> ''
    SET @SqlTxt = @SqlTxt + ' and (SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 1, 2) + SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 3, 2) + SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 5, 2) like ' + '''' + '%' + @MoeinCode + '%' + '''' + ')';
IF Isnull(@MoeinDesc, '') <> ''
    SET @SqlTxt = @SqlTxt + ' and (Des_AccountFullDesc like ' + '''' + '%' + @MoeinDesc + '%' + '''' + ')';
IF Isnull(@BedAmountFilter, '') <> ''
    SET @SqlTxt = @SqlTxt + ' and (Num_VdetDebtAmount like ' + '''' + '%' + @BedAmountFilter + '%' + '''' + ')';
IF Isnull(@BesAmountFilter, '') <> ''
    SET @SqlTxt = @SqlTxt + ' and (Num_VdetCreditAmount like ' + '''' + '%' + @BesAmountFilter + '%' + '''' + ')';
SET @WhSi = '';
IF @StaFtet = 0
    SELECT @WhSi = CONVERT (VARCHAR, SiAccVoucherType)
    FROM   Tss_AccVoucherType
    WHERE  (Sta_VoucherTypeGroup = 0);
IF @StaEkhtem = 0
    IF @WhSi = ''
        SELECT @WhSi = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
    ELSE
        SELECT @WhSi = @WhSi + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
IF @StavClose = 0
    IF @WhSi = ''
        SELECT @WhSi = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
    ELSE
        SELECT @WhSi = @WhSi + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
IF @WhSi <> ''
    BEGIN
        SET @WhSi = ' And (Not (dbo.Tss_AccVoucher_Hd.SiAccVoucherType in (' + @WhSi + ')))';
        SET @SqlTxt = @SqlTxt + Char(10) + @WhSi;
    END
SET @SqlTxt = @SqlTxt + ') Ccc ';
IF Isnull(@SiAccCodeBook, 0) > 0
    SET @SqlTxt = @SqlTxt + 'Where (SiAccCodeBook = ' + CONVERT (VARCHAR, @SiAccCodeBook) + ')';
EXECUTE (@SqlTxt + ' ' + @InternalWhere + ') CalcSel ' + @Where + @Order);


GO
ALTER PROCEDURE Tss_InvAsnadVaredehRep
@SiVouchers VARCHAR (8000)='', @SiSanad VARCHAR (8000)='', @SiAnbar VARCHAR (8000)='', @StDate VARCHAR (10)='', @EnDate VARCHAR (10)='', @SiGds VARCHAR (8000)='', @SiPer VARCHAR (8000)='', @SortFlag SMALLINT=0, @InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)='', @SiCust VARCHAR (8000)='', @SiUser NUMERIC=1
AS
SET XACT_ABORT ON;
IF @InternalWhere <> ''
    SET @InternalWhere = ' Where ' + @InternalWhere;
IF @Where <> ''
    SET @Where = ' Where ' + @Where;
--Else
--   Set @Where=' Where SiInvInventory in (SELECT SiInvInventory FROM Tss_InvInventoryToPerson WHERE (SiPubPersonsSpec = '+convert(varchar(50),@SiUser)+'))' 
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
ELSE
    SET @Order = ' Order By Dat_InvEnterDate';
DECLARE @SqlTxt1 AS NVARCHAR (MAX), @SqlTxt2 AS NVARCHAR (MAX), @Sta_PubPersonsGroup AS SMALLINT, @Branch AS SMALLINT, @IsInvAdmin AS SMALLINT;
SELECT @IsInvAdmin = dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'InvAdmin');
SELECT @Sta_PubPersonsGroup = Sta_PubPersonsGroup
FROM   Tss_PubPersonsSpec
WHERE  (SiPubPersonsSpec = @SiUser);
IF @Sta_PubPersonsGroup = 8
    SET @Branch = 1;
ELSE
    SET @Branch = 0;
IF EXISTS (SELECT *
           FROM   tempdb.dbo.sysobjects
           WHERE  (name = '##AsnadVaredehRepTemp'))
    DROP TABLE ##AsnadVaredehRepTemp;
SET @SqlTxt1 = ' 
SELECT distinct
Tss_InvInventory.Sta_InvType,
Tss_InvEntrance_Dt.SiInvEntrance_Dt, 
Tss_InvEntrance_Hd.SiInvEntrance_Hd, 
Tss_InvEntrance_Hd.Des_HavalehNo, 
Tss_InvEntrance_Hd.Num_FactoryBascule, 
Tss_InvEntrance_Hd.Num_ResidOriginWeight, 
Tss_InvEntrance_Hd.SiPubCustomCodes, 
Tss_InvInventory.SiInvInventory, 
Tss_PubGoods.Cod_PubGoodsCode, 
Tss_PubGoods.SiPubGoods, 
Tss_PubGoods.Des_PubGoodsDesc, 
Tss_InvInventory.Cod_InvInventoryCode, 
Tss_InvInventory.Des_InvInventoryDesc, 
Tss_PubCustomCodes.Cod_CustomCodesCode, 
Tss_PubCustomCodes.Des_CustomCodesDesc, 
Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount2, 
Tss_InvEntrance_Hd.Cod_InvEntHeaderCode, 
Tss_InvEntrance_Hd.Dat_InvEnterDate, 
Tss_InvEntrance_Hd.Cod_InvProvisionalRecieptNo, 
Tss_PubUnitSpecs_1.Des_PubUnitDesc, 
Tss_InvEntrance_Hd.SiPubPersonsSpec, 
DeliveryPers.Des_FullName, 
Tss_PubUnitSpecs_2.Des_PubUnitDesc AS VahedeSanjesh2, 
Tss_InvEntrance_Dt.Num_InvEntDtGdsAmt2Coef, 
Tss_InvEntrance_Dt.Num_InvEntDetailRialFee,
Tss_SalInvoice_Hd.SiPubPersonsSpec as SiCust,
Tss_SalInvoice_Hd.Cod_SaleAgreement2, 
Tss_SalInvoice_Hd.Cod_SaleAgreement, 
Tss_InvEntrance_Dt.Num_Serial, 
Tss_PubSubLocations.SiPubSubLocations, 
Tss_PubSubLocations.Cod_SubLocCode, 
Tss_PubSubLocations.Des_SubLocName, 
Tss_InvEntrance_Dt.SiVchDt, 
Customer.Cod_PubPersonCode CodCust, 
Customer.Des_FullName AS DesCust,
Tss_PurInvoice_Hd.Cod_PurInvoiceSalerCode, 
Tss_PurInvoice_Hd.Dat_PurInvoiceDate, 
Tss_PubPersonsViw.Sta_IsForeign,
Tss_InvEntrance_Hd.Des_VehicleNo, 
Tss_InvEntrance_Dt.Des_InvEntDetailDesc, 
Tss_SalInvoice_Hd.SiSalInvoice_Hd,
Tss_InvEntrance_Dt.Sta_InvEntUsedUnit,
Tss_InvEntrance_Hd.Num_TransportCost,
Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount,
Tss_InvEntrance_Dt.Num_TaxFee,
ISNULL(Tss_InvEntrance_Dt.Num_TransportCostFee, 0) AS Num_TransportCostFee,
Tss_InvEntrance_Dt.Num_VaredehRialiAmt,
Tss_InvEntrance_Dt.Des_StoreName,
Tss_PurInvoice_Dt.SiPurInvoice_Hd,
Tss_PurInvoice_Dt.Cod_PurInvoiceDtCode,
(SELECT        
	TOP 1 Tss_InvOutGo_Hd.Cod_InvExtHeaderCode
FROM            
	Tss_InvOutGo_Dt AS Tss_InvOutGo_Dt_1 INNER JOIN
	Tss_InvOutGo_Hd AS Tss_InvOutGo_Hd_1 ON Tss_InvOutGo_Dt_1.SiInvOutGo_Hd = Tss_InvOutGo_Hd_1.SiInvOutGo_Hd
WHERE        
	(Tss_InvOutGo_Dt_1.SiPubGoods =  Tss_PubGoods.SiPubGoods) and  
	(isnull(Tss_InvOutGo_Dt_1.Num_Serial,0)=isnull(Tss_InvEntrance_Dt.Num_Serial,0))
ORDER BY 
	Tss_InvOutGo_Hd.Dat_InvExitDate DESC) AS OutCode,

(SELECT        
	TOP 1 Tss_InvOutGo_Hd_1.Dat_InvExitDate
FROM            
	Tss_InvOutGo_Dt AS Tss_InvOutGo_Dt_1 INNER JOIN
	Tss_InvOutGo_Hd AS Tss_InvOutGo_Hd_1 ON Tss_InvOutGo_Dt_1.SiInvOutGo_Hd = Tss_InvOutGo_Hd_1.SiInvOutGo_Hd
WHERE        
	(Tss_InvOutGo_Dt_1.SiPubGoods =  Tss_PubGoods.SiPubGoods) and 
	(isnull(Tss_InvOutGo_Dt_1.Num_Serial,0)=isnull(Tss_InvEntrance_Dt.Num_Serial,0))
ORDER BY 
	Tss_InvOutGo_Hd_1.Dat_InvExitDate DESC) AS OutDate,

';
IF (dbo.Tss_StdFindSubLoc(0) = 'Simorgh')
    SET @SqlTxt2 = ' 
	isnull(Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount*Tss_InvEntrance_Dt.Num_TransportCostFee,0)+
	isnull(Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount*Tss_InvEntrance_Dt.Num_TaxFee,0)+
	isnull(Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount*Tss_InvEntrance_Dt.Num_InvEntDetailRialFee,0) as RowTotalFee,
	Tss_SalFactorRespect_Hd.Cod_FactRespCode, 
	Tss_SalFactorRespect_Hd.Dat_FactRespRegDate, 
	Tss_InvEntrance_Hd.Sta_InvEntBranch, 
	Tss_InvEntrance_Hd.SiOutDeliReceipt, 
	Tss_InvOutGo_Hd.Cod_InvExtHeaderCode,
	Case 
	when GdsInv.Sta_InvType = 0 
		then round(dbo.Tss_SalFindGdsGramage(Tss_PubGoods.SiPubGoods)*Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount/1000,2)
	when GdsInv.Sta_InvType = 6 
		then round(dbo.Tss_PrcFindGdsTheoreiticalGramage(Tss_PubGoods.SiPubGoods,'''')*Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount/1000,2)
--		then round(dbo.Tss_PrcFindGdsTheoreiticalGramage(Tss_PubGoods.SiPubGoods,'''')*dbo.Tss_SalFindGdsArea(Tss_PubGoods.SiPubGoods)*Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount/1000,2)
	else 0
	End as VaredehWeight, 
	Tss_InvBuyReq_Hd.Cod_BuyReqHdCode,
	Tss_InvBuyReq_Hd.Cod_ReqestCode,
	Tss_InvBuyReq_Hd.Des_SalerContCode,

	'''' UserCode, 
	'''' UserDesc, 
  --  0.0$ Sta_ActionType, 
	CAST(0 AS INT) AS Sta_ActionType,
	'''' Mdt_TransDateShamsi, 
	'''' FindWindowsUser,
	GdsInv.Sta_InvType As GdsInvType

	/*Tss_PubPersonsViw_1.Cod_PubPersonCode UserCode, 
	Tss_PubPersonsViw_1.Des_FullName UserDesc, 
    Tss_StdLogFileDet.Sta_ActionType, 
	Tss_StdLogFileDet.Mdt_TransDateShamsi, 
	Tss_StdLogFileDet.FindWindowsUser*/

FROM            Tss_InvInventory AS GdsInv INNER JOIN
                         Tss_PubGoods ON GdsInv.SiInvInventory = Tss_PubGoods.SiInvInventory RIGHT OUTER JOIN
                         Tss_StdLogFileDet INNER JOIN
                         Tss_PubPersonsViw AS Tss_PubPersonsViw_1 ON Tss_StdLogFileDet.SiPubPersonsSpec = Tss_PubPersonsViw_1.SiPubPersonsSpec RIGHT OUTER JOIN
                         Tss_InvEntrance_Dt INNER JOIN
                         Tss_InvEntrance_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd INNER JOIN
                         Tss_PubSubLocations ON Tss_InvEntrance_Hd.SiPubSubLocations = Tss_PubSubLocations.SiPubSubLocations ON Tss_StdLogFileDet.SiRecord = Tss_InvEntrance_Dt.SiInvEntrance_Dt LEFT OUTER JOIN
                         Tss_InvBuyReq_Hd INNER JOIN
                         Tss_InvBuyReq_Dt ON Tss_InvBuyReq_Hd.SiInvBuyReq_Hd = Tss_InvBuyReq_Dt.SiInvBuyReq_Hd ON Tss_InvEntrance_Dt.SiInvBuyReq_Dt = Tss_InvBuyReq_Dt.SiInvBuyReq_Dt LEFT OUTER JOIN
                         Tss_PubPersonsViw AS Customer INNER JOIN
                         Tss_SalInvoice_Hd ON Customer.SiPubPersonsSpec = Tss_SalInvoice_Hd.SiPubPersonsSpec ON Tss_InvEntrance_Dt.SiSalInvoice_Hd = Tss_SalInvoice_Hd.SiSalInvoice_Hd LEFT OUTER JOIN
                         Tss_InvOutGo_Hd ON Tss_InvEntrance_Hd.SiOutDeliReceipt = Tss_InvOutGo_Hd.SiInvOutGo_Hd LEFT OUTER JOIN
                         Tss_SalFactorRespect_Hd INNER JOIN
                         Tss_SalFactorRespect_Dt ON Tss_SalFactorRespect_Hd.SiSalFactorRespect_Hd = Tss_SalFactorRespect_Dt.SiSalFactorRespect_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Dt = Tss_SalFactorRespect_Dt.SiInvEntrance_Dt ON 
                         Tss_PubGoods.SiPubGoods = Tss_InvEntrance_Dt.SiPubGoods LEFT OUTER JOIN
                         Tss_PurInvoice_Dt INNER JOIN
                         Tss_PurInvoice_Hd ON Tss_PurInvoice_Dt.SiPurInvoice_Hd = Tss_PurInvoice_Hd.SiPurInvoice_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Dt = Tss_PurInvoice_Dt.SiInvEntrance_Dt LEFT OUTER JOIN
                         Tss_PubPersonsViw AS DeliveryPers ON Tss_InvEntrance_Dt.SiPubPersonsSpec = DeliveryPers.SiPubPersonsSpec LEFT OUTER JOIN
                         Tss_PubPersonsViw AS Tss_PubPersonsViw ON Tss_InvEntrance_Hd.SiPubPersonsSpec = Tss_PubPersonsViw.SiPubPersonsSpec LEFT OUTER JOIN
                         Tss_PubCustomCodes ON Tss_InvEntrance_Hd.SiPubCustomCodes = Tss_PubCustomCodes.SiPubCustomCodes LEFT OUTER JOIN
                         Tss_InvInventory AS Tss_InvInventory ON Tss_InvEntrance_Hd.SiInvInventory = Tss_InvInventory.SiInvInventory LEFT OUTER JOIN
                         Tss_PubUnitSpecs AS Tss_PubUnitSpecs_2 ON Tss_PubGoods.SiPubUnitSpecs1 = Tss_PubUnitSpecs_2.SiPubUnitSpecs LEFT OUTER JOIN
                         Tss_PubUnitSpecs AS Tss_PubUnitSpecs_1 ON Tss_PubGoods.SiPubUnitSpecs2 = Tss_PubUnitSpecs_1.SiPubUnitSpecs
Where
--		(Tss_InvEntrance_Hd.Sta_InvEntBranch = ' + CONVERT (VARCHAR, @Branch) + ') and 
		(Dat_InvEnterDate BETWEEN ' + '''' + @StDate + '''' + ' AND ' + '''' + @EnDate + '''' + ')';
ELSE
    SET @SqlTxt2 = ' 
	isnull(Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount*Tss_InvEntrance_Dt.Num_TransportCostFee,0)+
	isnull(Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount*Tss_InvEntrance_Dt.Num_TaxFee,0)+
	isnull(Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount*Tss_InvEntrance_Dt.Num_InvEntDetailRialFee,0) as RowTotalFee,
	Tss_SalFactorRespect_Hd.Cod_FactRespCode, 
	Tss_SalFactorRespect_Hd.Dat_FactRespRegDate, 
	Tss_InvEntrance_Hd.Sta_InvEntBranch, 
	Tss_InvEntrance_Hd.SiOutDeliReceipt, 
	Tss_InvOutGo_Hd.Cod_InvExtHeaderCode,
	Case 
	when GdsInv.Sta_InvType = 0 
		then round(dbo.Tss_SalFindGdsGramage(Tss_PubGoods.SiPubGoods)*Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount/1000,2)
	when GdsInv.Sta_InvType = 6 
		then round(dbo.Tss_PrcFindGdsTheoreiticalGramage(Tss_PubGoods.SiPubGoods,'''')*Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount/1000,2)
--		then round(dbo.Tss_PrcFindGdsTheoreiticalGramage(Tss_PubGoods.SiPubGoods,'''')*dbo.Tss_SalFindGdsArea(Tss_PubGoods.SiPubGoods)*Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount/1000,2)
	else 0
	End as VaredehWeight, 
	Tss_InvBuyReq_Hd.Cod_BuyReqHdCode,
	Tss_InvBuyReq_Hd.Cod_ReqestCode,
	Tss_InvBuyReq_Hd.Des_SalerContCode,
	'''' UserCode, 
	'''' UserDesc, 
  --  0.0$ Sta_ActionType, 
	CAST(0 AS INT) AS Sta_ActionType,
	'''' Mdt_TransDateShamsi, 
	'''' FindWindowsUser,
	GdsInv.Sta_InvType As GdsInvType
FROM            Tss_InvInventory AS GdsInv INNER JOIN
                         Tss_PubGoods ON GdsInv.SiInvInventory = Tss_PubGoods.SiInvInventory RIGHT OUTER JOIN
                         Tss_StdLogFileDet INNER JOIN
                         Tss_PubPersonsViw AS Tss_PubPersonsViw_1 ON Tss_StdLogFileDet.SiPubPersonsSpec = Tss_PubPersonsViw_1.SiPubPersonsSpec RIGHT OUTER JOIN
                         Tss_InvEntrance_Dt INNER JOIN
                         Tss_InvEntrance_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd INNER JOIN
                         Tss_PubSubLocations ON Tss_InvEntrance_Hd.SiPubSubLocations = Tss_PubSubLocations.SiPubSubLocations ON Tss_StdLogFileDet.SiRecord = Tss_InvEntrance_Dt.SiInvEntrance_Dt LEFT OUTER JOIN
                         Tss_InvBuyReq_Hd INNER JOIN
                         Tss_InvBuyReq_Dt ON Tss_InvBuyReq_Hd.SiInvBuyReq_Hd = Tss_InvBuyReq_Dt.SiInvBuyReq_Hd ON Tss_InvEntrance_Dt.SiInvBuyReq_Dt = Tss_InvBuyReq_Dt.SiInvBuyReq_Dt LEFT OUTER JOIN
                         Tss_PubPersonsViw AS Customer INNER JOIN
                         Tss_SalInvoice_Hd ON Customer.SiPubPersonsSpec = Tss_SalInvoice_Hd.SiPubPersonsSpec ON Tss_InvEntrance_Dt.SiSalInvoice_Hd = Tss_SalInvoice_Hd.SiSalInvoice_Hd LEFT OUTER JOIN
                         Tss_InvOutGo_Hd ON Tss_InvEntrance_Hd.SiOutDeliReceipt = Tss_InvOutGo_Hd.SiInvOutGo_Hd LEFT OUTER JOIN
                         Tss_SalFactorRespect_Hd INNER JOIN
                   Tss_SalFactorRespect_Dt ON Tss_SalFactorRespect_Hd.SiSalFactorRespect_Hd = Tss_SalFactorRespect_Dt.SiSalFactorRespect_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Dt = Tss_SalFactorRespect_Dt.SiInvEntrance_Dt ON 
                         Tss_PubGoods.SiPubGoods = Tss_InvEntrance_Dt.SiPubGoods LEFT OUTER JOIN
                         Tss_PurInvoice_Dt INNER JOIN
                         Tss_PurInvoice_Hd ON Tss_PurInvoice_Dt.SiPurInvoice_Hd = Tss_PurInvoice_Hd.SiPurInvoice_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Dt = Tss_PurInvoice_Dt.SiInvEntrance_Dt LEFT OUTER JOIN
                         Tss_PubPersonsViw AS DeliveryPers ON Tss_InvEntrance_Dt.SiPubPersonsSpec = DeliveryPers.SiPubPersonsSpec LEFT OUTER JOIN
                         Tss_PubPersonsViw AS Tss_PubPersonsViw ON Tss_InvEntrance_Hd.SiPubPersonsSpec = Tss_PubPersonsViw.SiPubPersonsSpec LEFT OUTER JOIN
                         Tss_PubCustomCodes ON Tss_InvEntrance_Hd.SiPubCustomCodes = Tss_PubCustomCodes.SiPubCustomCodes LEFT OUTER JOIN
                         Tss_InvInventory AS Tss_InvInventory ON Tss_InvEntrance_Hd.SiInvInventory = Tss_InvInventory.SiInvInventory LEFT OUTER JOIN
                         Tss_PubUnitSpecs AS Tss_PubUnitSpecs_2 ON Tss_PubGoods.SiPubUnitSpecs1 = Tss_PubUnitSpecs_2.SiPubUnitSpecs LEFT OUTER JOIN
                         Tss_PubUnitSpecs AS Tss_PubUnitSpecs_1 ON Tss_PubGoods.SiPubUnitSpecs2 = Tss_PubUnitSpecs_1.SiPubUnitSpecs
Where
--		(Tss_InvEntrance_Hd.Sta_InvEntBranch = ' + CONVERT (VARCHAR, @Branch) + ') and 
		(Dat_InvEnterDate BETWEEN ' + '''' + @StDate + '''' + ' AND ' + '''' + @EnDate + '''' + ')';
IF @SiSanad <> ''
    SET @SqlTxt2 = @SqlTxt2 + ' and (Tss_PubCustomCodes.SiPubCustomCodes IN (select sisel from dbo.Tss_StdStringSiFindUdf(' + '''' + @SiSanad + '''' + ')))';
IF @SiAnbar <> ''
    SET @SqlTxt2 = @SqlTxt2 + ' and (Tss_InvInventory.SiInvInventory IN (select sisel from dbo.Tss_StdStringSiFindUdf(' + '''' + @SiAnbar + '''' + ')))';
IF @SiGds <> ''
    SET @SqlTxt2 = @SqlTxt2 + ' and (Tss_PubGoods.SiPubGoods in (select sisel from dbo.Tss_StdStringSiFindUdf(' + '''' + @SiGds + '''' + ')))';
IF @SiPer <> ''
    SET @SqlTxt2 = @SqlTxt2 + ' and (Tss_InvEntrance_Hd.SiPubPersonsSpec in (select sisel from dbo.Tss_StdStringSiFindUdf(' + '''' + @SiPer + '''' + ')))';
IF @SiCust <> ''
    SET @SqlTxt2 = @SqlTxt2 + ' and (Tss_SalInvoice_Hd.SiPubPersonsSpec in (select sisel from dbo.Tss_StdStringSiFindUdf(' + '''' + @SiCust + '''' + ')))';
IF @SiVouchers <> ''
    SET @SqlTxt2 = @SqlTxt2 + ' and (Tss_InvEntrance_Hd.SiInvEntrance_Hd in (select sisel from dbo.Tss_StdStringSiFindUdf(' + '''' + @SiVouchers + '''' + ')))';
PRINT @SqlTxt1;
PRINT @SqlTxt2;
EXECUTE ('Select distinct * into ##AsnadVaredehRepTemp From  (Select * from
		(' + @SqlTxt1 + @SqlTxt2 + ') Calc ' + @InternalWhere + ') CalcSel ' + @Where + @Order);
DECLARE @FinalSql AS NVARCHAR (MAX);
SET @FinalSql = '
Select distinct
ROW_NUMBER() OVER(' + CASE WHEN @Order <> '' THEN @Order ELSE 'ORDER BY Dat_InvEnterDate' END + ') as RowNumber,
UserCode, 
UserDesc, 
Sta_ActionType, 
Mdt_TransDateShamsi, 
FindWindowsUser,
SiInvEntrance_Dt, 
SiInvEntrance_Hd, 
Des_HavalehNo, 
Num_FactoryBascule, 
Num_ResidOriginWeight, 
SiPubCustomCodes, 
SiInvInventory, 
Cod_PubGoodsCode, 
SiPubGoods, 
Des_PubGoodsDesc, 
Cod_InvInventoryCode, 
Des_InvInventoryDesc, 
Cod_CustomCodesCode, 
Des_CustomCodesDesc, 
Num_InvEntDetailGdsAmount2, 
Cod_InvEntHeaderCode, 
Dat_InvEnterDate, 
Cod_InvProvisionalRecieptNo, 
Des_PubUnitDesc, 
SiPubPersonsSpec, 
Des_FullName, 
VahedeSanjesh2, 
Num_InvEntDtGdsAmt2Coef, 
Num_InvEntDetailRialFee,
Cod_SaleAgreement2, 
Cod_SaleAgreement, 
Num_Serial, 
SiPubSubLocations, 
Cod_SubLocCode, 
Des_SubLocName, 
SiVchDt, 
CodCust, 
DesCust,
Cod_PurInvoiceSalerCode, 
Dat_PurInvoiceDate, 
Sta_IsForeign,
Des_VehicleNo, 
Des_InvEntDetailDesc, 
Cod_FactRespCode, 
Dat_FactRespRegDate, 
Sta_InvEntBranch, 
SiOutDeliReceipt, 
Cod_InvExtHeaderCode,
dbo.Tss_SalFindGdsArea(SiPubGoods) gdsarea,
SUM(Num_InvEntDetailGdsAmount)*dbo.Tss_SalFindGdsArea(SiPubGoods) Allgdsarea,
Case
when GdsInvType = 0 then convert(varchar,ISNULL(dbo.Tss_SalFindGdsGramage(SiPubGoods), 0)) 
when (GdsInvType = 6) or (GdsInvType = 7) then Convert(varchar,dbo.Tss_PrcFindGdsTheoreiticalGramage(SiPubGoods,''''))
End AS Gramage, 
ISNULL(dbo.PubFindGdsTechSpec(SiPubGoods, 1299), '''') AS Arz, 
ISNULL(dbo.PubFindGdsTechSpec(SiPubGoods, 1665), '''') AS Jens, 
dbo.Tss_SalFindContGoodsLayes(SiPubGoods) GoodsLayer,
dbo.Tss_StdStaLabelsUdf(1092, Sta_InvEntUsedUnit) AS VahedSanjesh, 
SUM(Num_InvEntDetailGdsAmount) AS Num_InvEntDetailGdsAmount, 
ISNULL(Num_TransportCost, 0) AS Num_TransportCostFee, 
Sum(ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_InvEntDetailRialFee, 0), 0)) AS RialiRow, 
ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_TransportCostFee, 0), 0) AS TransRateRow, 
Sum(ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_InvEntDetailRialFee, 0), 0))+ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_TransportCostFee, 0), 0) AS RialiRowWithHaml, 
Sum(ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_TaxFee, 0), 0)) AS TaxRow, 
SUM(Num_VaredehRialiAmt) as Num_VaredehRialiAmt, 
(SELECT Dat_VhedDate FROM Tss_AccVoucher_Hd WHERE (SiAccVoucher_Hd = SiVchDt)) as Dat_VhedDate , 
case when SiSalInvoice_Hd>0 then
	dbo.Tss_SalFindContSbLoc(SiSalInvoice_Hd) 
Else
	''''
End As ContSubLoc,
OutCode,
OutDate,
Des_StoreName,
RowTotalFee,
VaredehWeight,
Cod_BuyReqHdCode,
dbo.Tss_SalFindGoodsType(SiPubGoods) AS GoodsType,
SiPurInvoice_Hd,
Cod_ReqestCode,
Des_SalerContCode

From
	##AsnadVaredehRepTemp
GROUP BY 
	SiSalInvoice_Hd, 
	SiInvEntrance_Dt, 
	SiInvEntrance_Hd, 
	Des_HavalehNo, 
	Num_FactoryBascule, 
	Num_ResidOriginWeight, 
	SiPubCustomCodes, 
	SiInvInventory, 
	SiPubCustomCodes, 
	Cod_PubGoodsCode, 
	SiPubGoods, 
	Des_PubGoodsDesc, 
	ISNULL(dbo.PubFindGdsTechSpec(SiPubGoods, 1298), ''''), 
	ISNULL(dbo.PubFindGdsTechSpec(SiPubGoods, 1299), ''''), 
	ISNULL(dbo.PubFindGdsTechSpec(SiPubGoods, 1665), ''''), 
	Cod_InvInventoryCode, 
	Des_InvInventoryDesc, 
	Cod_CustomCodesCode, 
	Des_CustomCodesDesc, 
	dbo.Tss_StdStaLabelsUdf(1092, Sta_InvEntUsedUnit), 
	Num_InvEntDetailGdsAmount2, 
	Cod_InvEntHeaderCode, 
	Dat_InvEnterDate, 
	Cod_InvProvisionalRecieptNo, 
	Des_PubUnitDesc, 
	SiPubPersonsSpec, 
	Des_FullName, 
	Num_InvEntDetailRialFee, 
	Des_PubUnitDesc, 
	Num_InvEntDtGdsAmt2Coef, 
	ISNULL(Num_TransportCost, 0), 
	ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_InvEntDetailRialFee, 0), 0), ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) 
	* ISNULL(Num_TransportCostFee, 0), 0), 
	ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_TaxFee, 0), 0), 
	Num_VaredehRialiAmt, 
	Cod_SaleAgreement2, 
	Cod_SaleAgreement, 
	Num_Serial, 
	SiPubSubLocations, 
	Cod_SubLocCode, 
	Des_SubLocName, 
	SiVchDt, 
	CodCust, 
	Des_FullName, 
	Cod_PurInvoiceSalerCode, 
	Dat_PurInvoiceDate, 
	Des_VehicleNo, 
	SiPubPersonsSpec, 
	Cod_FactRespCode, 
	Dat_FactRespRegDate, 
	Sta_InvEntBranch, 
	SiOutDeliReceipt, 
	Cod_InvExtHeaderCode, 
	Des_InvEntDetailDesc, 
	SiPubCustomCodes, 
	Sta_IsForeign,
	VahedeSanjesh2,
	DesCust,
	Des_StoreName,
	Num_InvEntDetailGdsAmount,
	Num_TransportCostFee,
	OutCode,
	OutDate,
	RowTotalFee,
	VaredehWeight,
	Cod_BuyReqHdCode,
	SiPurInvoice_Hd,
	Cod_PurInvoiceDtCode,
	Cod_ReqestCode,
	Des_SalerContCode,
	UserCode, 
	UserDesc, 
	Sta_ActionType, 
	Mdt_TransDateShamsi, 
	FindWindowsUser,
	Sta_InvType,
	GdsInvType';
-- Add the ORDER BY clause
IF @Order <> ''
    SET @FinalSql = @FinalSql + @Order;
ELSE
    SET @FinalSql = @FinalSql + ' Order by Dat_InvEnterDate';
--print @FinalSql
-- Execute the final SQl
EXECUTE (@FinalSql);


GO
ALTER PROCEDURE Tss_EmpUntLeaveDocsIudStp
@Err_Code INT=0 OUTPUT, @SiEmpLeaveDocs NUMERIC=0 OUTPUT, @SiEmpLeaveTypes NUMERIC=6, @SiPubPersonsSpec VARCHAR (8000)='1217', @Cod_LeaveDocNumber VARCHAR (50)='10702', @Dat_LeaveStartDate VARCHAR (10)='1390/07/01', @Dat_LevaEndedDate VARCHAR (10)='1390/07/05', @Dat_LeaveRequstDate VARCHAR (10)='1390/07/01', @Sta_LeaveDocAcceptStat SMALLINT=1, @Sta_LeaveDocRegStat SMALLINT=1, @Num_LeaveStartTime INT=0, @Num_LeaveEndedTime INT=0, @DesWorkStart VARCHAR (500)='', @DesWorkEnd VARCHAR (500)='', @StmEmpLeaveDocs TIMESTAMP=0, @SiUser NUMERIC=1, @FlgInsUpdDel SMALLINT=1
AS
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
IF @FlgInsUpdDel = 0
    BEGIN
        DECLARE @PerTable TABLE (
            SiPer NUMERIC);
        DECLARE @SiSelected AS NUMERIC;
        INSERT INTO @PerTable (SiPer)
        SELECT   DISTINCT SiSel
        FROM     dbo.Tss_StdStringSiFindUdf(@SiPubPersonsSpec)
        ORDER BY SiSel;
        WHILE EXISTS (SELECT SiPer
                      FROM   @PerTable)
            BEGIN
                SELECT   TOP 1 @SiSelected = SiPer
                FROM     @PerTable
                ORDER BY SiPer;
                -------------------------------------------------------------------------------------------------
                -- NEW: if a record already exists for this person with the same
                -- SiEmpLeaveTypes, SiPubPersonsSpec (=@SiSelected), Dat_LeaveStartDate,
                -- Dat_LevaEndedDate, Dat_LeaveRequstDate, Num_LeaveStartTime and
                -- Num_LeaveEndedTime, skip inserting a duplicate for this person and
                -- move on to the next one in @PerTable.
                -------------------------------------------------------------------------------------------------
                IF EXISTS (SELECT 1
                           FROM   dbo.Tss_EmpLeaveDocs
                           WHERE  SiEmpLeaveTypes = @SiEmpLeaveTypes
                                  AND SiPubPersonsSpec = @SiSelected
                                  AND Dat_LeaveStartDate = @Dat_LeaveStartDate
                                  AND Dat_LevaEndedDate = @Dat_LevaEndedDate
                                  AND Dat_LeaveRequstDate = @Dat_LeaveRequstDate
                                  AND Num_LeaveStartTime = @Num_LeaveStartTime
                                  AND Num_LeaveEndedTime = @Num_LeaveEndedTime)
                    BEGIN
                        DELETE @PerTable
                        WHERE  SiPer = @SiSelected;
                        CONTINUE;
                    END
                -------------------------------------------------------------------------------------------------
                --		select @Cod_LeaveDocNumber=isnull(Max(Convert(Int,Cod_LeaveDocNumber)),0)+1 from dbo.Tss_EmpLeaveDocs
                IF EXISTS (SELECT 1
                           FROM   dbo.Tss_EmpLeaveDocs)
                    SELECT @Cod_LeaveDocNumber = isnull(Max(CONVERT (INT, Cod_LeaveDocNumber)), 0) + 1
                    FROM   dbo.Tss_EmpLeaveDocs;
                ELSE
                    SET @Cod_LeaveDocNumber = 1;
                INSERT  INTO dbo.Tss_EmpLeaveDocs (SiEmpLeaveTypes, SiPubPersonsSpec, Cod_LeaveDocNumber, Dat_LeaveStartDate, Dat_LevaEndedDate, Dat_LeaveRequstDate, Sta_LeaveDocAcceptStat, Sta_LeaveDocRegStat, Num_LeaveStartTime, Num_LeaveEndedTime)
                VALUES                           (@SiEmpLeaveTypes, @SiSelected, @Cod_LeaveDocNumber, @Dat_LeaveStartDate, @Dat_LevaEndedDate, @Dat_LeaveRequstDate, @Sta_LeaveDocAcceptStat, @Sta_LeaveDocRegStat, @Num_LeaveStartTime, @Num_LeaveEndedTime);
                SET @SiEmpLeaveDocs = Scope_Identity();
                ---------------------------------------------------------------------------------------------------------------------------------------
                IF EXISTS (SELECT Tss_EmpLeaveTypes.SiEmpLeaveTypes
                           FROM   Tss_EmpLeaveTypes
                           WHERE  (Tss_EmpLeaveTypes.Sta_LeaveTypeWorkCalc = 0)
                                  AND (Tss_EmpLeaveTypes.SiEmpLeaveTypes = @SiEmpLeaveTypes))
                    BEGIN
                        DECLARE @SiGenDates AS NUMERIC;
                        DECLARE mm CURSOR
                            FOR SELECT SiGenDates
                                FROM   Tss_GenDates
                                WHERE  (Dat_GenShamsiDate BETWEEN @Dat_LeaveStartDate AND @Dat_LevaEndedDate);
                        OPEN mm;
                        FETCH NEXT FROM mm INTO @SiGenDates;
                        WHILE @@Fetch_status = 0
                            BEGIN
                                UPDATE Tss_EmpWorkDailyCalc
                                SET    Sta_IsEstelaji = 1
                                WHERE  (SiGenDates = @SiGenDates)
                                       AND (SiPubPersonsSpec = @SiSelected);
                                FETCH NEXT FROM mm INTO @SiGenDates;
                            END
                        CLOSE mm;
                        DEALLOCATE mm;
                    END
                ELSE
                    BEGIN
                        DECLARE nn CURSOR
                            FOR SELECT SiGenDates
                                FROM   Tss_GenDates
                                WHERE  (Dat_GenShamsiDate BETWEEN @Dat_LeaveStartDate AND @Dat_LevaEndedDate);
                        OPEN nn;
                        FETCH NEXT FROM nn INTO @SiGenDates;
                        WHILE @@Fetch_status = 0
                            BEGIN
                                UPDATE Tss_EmpWorkDailyCalc
                                SET    Sta_IsEstelaji = 0
                                WHERE  (SiGenDates = @SiGenDates)
                                       AND (SiPubPersonsSpec = @SiSelected);
                                FETCH NEXT FROM nn INTO @SiGenDates;
                            END
                        CLOSE nn;
                        DEALLOCATE nn;
                    END
                ---------------------------------------------------------------------------------------------------------------------------------------
                ------------------------------------------------درج در محاسبه مرخصي------------------------------------------------------
                DECLARE @SiGenDate AS NUMERIC, @LeaveDate AS VARCHAR (10), @NumEndOfDay AS NUMERIC, @NumStartOfDay AS NUMERIC, @Sta_WorkDayState AS SMALLINT, @LeaveAmt AS NUMERIC, @SiEmpWorkGroups AS NUMERIC;
                SET @LeaveAmt = 0;
                DECLARE LeaveDates CURSOR
                    FOR SELECT   SiGenDates,
                                 Dat_GenShamsiDate
                        FROM     Tss_GenDates
                        WHERE    (Dat_GenShamsiDate BETWEEN @Dat_LeaveStartDate AND @Dat_LevaEndedDate)
                        ORDER BY Dat_GenShamsiDate;
                OPEN LeaveDates;
                FETCH NEXT FROM LeaveDates INTO @SiGenDate, @LeaveDate;
                PRINT 'من اينجاممممممممممممممممم';
                WHILE @@Fetch_Status = 0
                    BEGIN
                        SELECT @SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@LeaveDate, CONVERT (NUMERIC, @SiSelected));
                        SELECT @Sta_WorkDayState = Sta_WorkDayState
                        FROM   Tss_EmpWorkTime
                        WHERE  (SiGenDates = @SiGenDate)
                               AND (SiEmpWorkGroups = @SiEmpWorkGroups);
                        SELECT @LeaveAmt = dbo.Tss_EmpFindLeaveAmt(@SiEmpLeaveDocs, @SiSelected, @LeaveDate);
                        IF isnull(@LeaveAmt, 0) > 0
                            BEGIN
                                IF EXISTS (SELECT SiEmpLeaveCalc
                                           FROM   Tss_EmpLeaveCalc
                                           WHERE  (SiEmpLeaveDocs = @SiEmpLeaveDocs)
                                                  AND (Dat_LeaveDate = @LeaveDate))
                                    BEGIN
                                        IF (@Sta_WorkDayState = 0)
                                            UPDATE dbo.Tss_EmpLeaveCalc
                                            SET    SiEmpLeaveDocs   = @SiEmpLeaveDocs,
                                                   Dat_LeaveDate    = @LeaveDate,
                                                   Num_LeaveUsedMin = @LeaveAmt
                                            WHERE  Dat_LeaveDate = @LeaveDate
                                                   AND SiEmpLeaveDocs = @SiEmpLeaveDocs;
                                        ELSE
                                            UPDATE dbo.Tss_EmpLeaveCalc
                                            SET    SiEmpLeaveDocs   = @SiEmpLeaveDocs,
                                                   Dat_LeaveDate    = @LeaveDate,
                                                   Num_LeaveUsedMin = 0
                                            WHERE  Dat_LeaveDate = @LeaveDate
                                                   AND SiEmpLeaveDocs = @SiEmpLeaveDocs;
                                    END
                                ELSE
                                    INSERT  INTO dbo.Tss_EmpLeaveCalc (SiEmpLeaveDocs, Dat_LeaveDate, Num_LeaveUsedMin)
                                    VALUES                           (@SiEmpLeaveDocs, @LeaveDate, @LeaveAmt);
                            END
                        FETCH NEXT FROM LeaveDates INTO @SiGenDate, @LeaveDate;
                    END
                CLOSE LeaveDates;
                DEALLOCATE LeaveDates;
                ------------------------------------------------درج در محاسبه مرخصي------------------------------------------------------
                IF IsNull(@SiEmpLeaveDocs, 0) = 0
                    BEGIN
                        SET @SiEmpLeaveDocs = 0;
                        SET @Err_Code = 400;
                    END
                DELETE @PerTable
                WHERE  SiPer = @SiSelected;
            END
    END
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
IF @FlgInsUpdDel = 1
    BEGIN
        SET @Err_Code = 0;
        IF EXISTS (SELECT StmEmpLeaveDocs
                   FROM   dbo.Tss_EmpLeaveDocs
                   WHERE  (SiEmpLeaveDocs = @SiEmpLeaveDocs)) -- And (StmEmpLeaveDocs=@StmEmpLeaveDocs))
            BEGIN
                UPDATE dbo.Tss_EmpLeaveDocs
                SET    SiEmpLeaveTypes        = @SiEmpLeaveTypes,
                       SiPubPersonsSpec       = CONVERT (NUMERIC, @SiPubPersonsSpec),
                       Cod_LeaveDocNumber     = @Cod_LeaveDocNumber,
                       Dat_LeaveStartDate     = @Dat_LeaveStartDate,
                       Dat_LevaEndedDate      = @Dat_LevaEndedDate,
                       Dat_LeaveRequstDate    = @Dat_LeaveRequstDate,
                       Sta_LeaveDocAcceptStat = @Sta_LeaveDocAcceptStat,
                       Sta_LeaveDocRegStat    = @Sta_LeaveDocRegStat,
                       Num_LeaveStartTime     = @Num_LeaveStartTime,
                       Num_LeaveEndedTime     = @Num_LeaveEndedTime
                WHERE  (SiEmpLeaveDocs = @SiEmpLeaveDocs);
                ---------------------------------------------------------------------------------------------------------------------------------------
                /*		if Exists
		(
		SELECT     
			Tss_EmpLeaveTypes.SiEmpLeaveTypes
		FROM         
			Tss_EmpLeaveTypes
		WHERE     
			(Tss_EmpLeaveTypes.Sta_LeaveTypeWorkCalc = 0) and (Tss_EmpLeaveTypes.SiEmpLeaveTypes=@SiEmpLeaveTypes)
		)
		Begin
--print 'ok'
			Declare mm cursor for 
			SELECT     
				SiGenDates
			FROM         
				Tss_GenDates
			WHERE     
				(Dat_GenShamsiDate between @Dat_LeaveStartDate and @Dat_LevaEndedDate)

			open mm

			Fetch next from mm into @SiGenDates
			
			while @@Fetch_status=0 
			Begin
				UPDATE    
					Tss_EmpWorkDailyCalc
				SET              
					Sta_IsEstelaji = 1
				WHERE     
					(SiGenDates = @SiGenDates) and
					(SiPubPersonsSpec = convert(numeric,@SiPubPersonsSpec))
				Fetch next from mm into @SiGenDates
			End
			Close mm
			Deallocate mm
		End
		Else
		Begin
print 'ok'
			Declare nn cursor for 
			SELECT     
				SiGenDates
			FROM         
				Tss_GenDates
			WHERE     
				(Dat_GenShamsiDate between @Dat_LeaveStartDate and @Dat_LevaEndedDate)

			open nn

			Fetch next from nn into @SiGenDates
			
			while @@Fetch_status=0 
			Begin
				UPDATE    
					Tss_EmpWorkDailyCalc
				SET              
					Sta_IsEstelaji = 0
				WHERE     
					(SiGenDates = @SiGenDates) and
					(SiPubPersonsSpec = convert(numeric,@SiPubPersonsSpec))
				Fetch next from nn into @SiGenDates
			End
			Close nn
			Deallocate nn
		End*/
                ---------------------------------------------------------------------------------------------------------------------------------------
                ------------------------------------------------درج در محاسبه مرخصي------------------------------------------------------
                SET @LeaveAmt = 0;
                DECLARE LeaveDates CURSOR
                    FOR SELECT   SiGenDates,
                                 Dat_GenShamsiDate
                        FROM     Tss_GenDates
                        WHERE    (Dat_GenShamsiDate BETWEEN @Dat_LeaveStartDate AND @Dat_LevaEndedDate)
                        ORDER BY Dat_GenShamsiDate;
                OPEN LeaveDates;
                FETCH NEXT FROM LeaveDates INTO @SiGenDate, @LeaveDate;
                WHILE @@Fetch_Status = 0
                    BEGIN
                        SELECT @SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@LeaveDate, CONVERT (NUMERIC, @SiPubPersonsSpec));
                        SELECT @Sta_WorkDayState = Sta_WorkDayState
                        FROM   Tss_EmpWorkTime
                        WHERE  (SiGenDates = @SiGenDate)
                               AND (SiEmpWorkGroups = @SiEmpWorkGroups);
                        SELECT @LeaveAmt = dbo.Tss_EmpFindLeaveAmt(@SiEmpLeaveDocs, CONVERT (NUMERIC, @SiPubPersonsSpec), @LeaveDate);
                        IF isnull(@LeaveAmt, 0) > 0
                            BEGIN
                                IF EXISTS (SELECT SiEmpLeaveCalc
                                           FROM   Tss_EmpLeaveCalc
                                           WHERE  (SiEmpLeaveDocs = @SiEmpLeaveDocs)
                                                  AND (Dat_LeaveDate = @LeaveDate))
                                    BEGIN
                                        IF (@Sta_WorkDayState = 0)
                                            UPDATE dbo.Tss_EmpLeaveCalc
                                            SET    SiEmpLeaveDocs   = @SiEmpLeaveDocs,
                                                   Dat_LeaveDate    = @LeaveDate,
                                                   Num_LeaveUsedMin = @LeaveAmt
                                            WHERE  Dat_LeaveDate = @LeaveDate
                                                   AND SiEmpLeaveDocs = @SiEmpLeaveDocs;
                                        ELSE
                                            UPDATE dbo.Tss_EmpLeaveCalc
                                            SET    SiEmpLeaveDocs   = @SiEmpLeaveDocs,
                                                   Dat_LeaveDate    = @LeaveDate,
                                                   Num_LeaveUsedMin = 0
                                            WHERE  Dat_LeaveDate = @LeaveDate
                                                   AND SiEmpLeaveDocs = @SiEmpLeaveDocs;
                                    END
                                ELSE
                                    INSERT  INTO dbo.Tss_EmpLeaveCalc (SiEmpLeaveDocs, Dat_LeaveDate, Num_LeaveUsedMin)
                                    VALUES                           (@SiEmpLeaveDocs, @LeaveDate, @LeaveAmt);
                            END
                        FETCH NEXT FROM LeaveDates INTO @SiGenDate, @LeaveDate;
                    END
                CLOSE LeaveDates;
                DEALLOCATE LeaveDates;
                ------------------------------------------------درج در محاسبه مرخصي------------------------------------------------------
                SET @Err_Code = @@Error;
                IF @Err_Code <> 0
                    SET @Err_Code = 401;
                RETURN;
            END
        ELSE
            SET @Err_Code = 402;
    END
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
IF @FlgInsUpdDel = 2
    BEGIN
        SET @Err_Code = 0;
        IF EXISTS (SELECT StmEmpLeaveDocs
                   FROM   dbo.Tss_EmpLeaveDocs
                   WHERE  (SiEmpLeaveDocs = @SiEmpLeaveDocs)
                          AND (StmEmpLeaveDocs = @StmEmpLeaveDocs))
            BEGIN
                DELETE dbo.Tss_EmpLeaveCalc
                WHERE  SiEmpLeaveDocs = @SiEmpLeaveDocs;
                DELETE dbo.Tss_EmpLeaveDocs
                WHERE  (SiEmpLeaveDocs = @SiEmpLeaveDocs);
                ------------------------------------------------حذف محاسبه مرخصي-------------------------------------
                DECLARE LeaveDates CURSOR
                    FOR SELECT   SiGenDates,
                                 Dat_GenShamsiDate
                        FROM     Tss_GenDates
                        WHERE    (Dat_GenShamsiDate BETWEEN @Dat_LeaveStartDate AND @Dat_LevaEndedDate)
                        ORDER BY Dat_GenShamsiDate;
                OPEN LeaveDates;
                FETCH NEXT FROM LeaveDates INTO @SiGenDate, @LeaveDate;
                WHILE @@Fetch_Status = 0
                    BEGIN
                        IF @Dat_LeaveStartDate < @Dat_LevaEndedDate
                            BEGIN
                                IF @LeaveDate = @Dat_LeaveStartDate
                                    BEGIN
                                        SELECT @NumEndOfDay = (Num_WorkGroupStartTime + Num_WorkGroupLenTime),
                                               @Sta_WorkDayState = Sta_WorkDayState
                                        FROM   Tss_EmpWorkTime
                                        WHERE  (SiGenDates = @SiGenDate);
                                        IF (@Sta_WorkDayState = 0)
                                            DELETE dbo.Tss_EmpLeaveCalc
                                            WHERE  SiEmpLeaveDocs = @SiEmpLeaveDocs;
                                    END
                                ELSE
                                    IF (@LeaveDate > @Dat_LeaveStartDate)
                                       AND (@LeaveDate < @Dat_LevaEndedDate)
                                        BEGIN
                                            SELECT @NumStartOfDay = Num_WorkGroupStartTime,
                                                   @NumEndOfDay = (Num_WorkGroupStartTime + Num_WorkGroupLenTime),
                                                   @Sta_WorkDayState = Sta_WorkDayState
                                            FROM   Tss_EmpWorkTime
                                            WHERE  (SiGenDates = @SiGenDate);
                                            IF (@Sta_WorkDayState = 0)
                                                DELETE dbo.Tss_EmpLeaveCalc
                                                WHERE  SiEmpLeaveDocs = @SiEmpLeaveDocs;
                                        END
                                    ELSE
                                        IF (@LeaveDate = @Dat_LevaEndedDate)
                                            BEGIN
                                                SELECT @NumStartOfDay = Num_WorkGroupStartTime,
                                                       @Sta_WorkDayState = Sta_WorkDayState
                                                FROM   Tss_EmpWorkTime
                                                WHERE  (SiGenDates = @SiGenDate);
                                                IF (@Sta_WorkDayState = 0)
                                                    DELETE dbo.Tss_EmpLeaveCalc
                                                    WHERE  SiEmpLeaveDocs = @SiEmpLeaveDocs;
                                            END
                                FETCH NEXT FROM LeaveDates INTO @SiGenDate, @LeaveDate;
                            END
                        ELSE
                            IF @Dat_LeaveStartDate = @Dat_LevaEndedDate
                                BEGIN
                                    SELECT @NumStartOfDay = Num_WorkGroupStartTime,
                                           @Sta_WorkDayState = Sta_WorkDayState
                                    FROM   Tss_EmpWorkTime
                                    WHERE  (SiGenDates = @SiGenDate);
                                    IF (@Sta_WorkDayState = 0)
                                        DELETE dbo.Tss_EmpLeaveCalc
                                        WHERE  SiEmpLeaveDocs = @SiEmpLeaveDocs;
                                END
                        FETCH NEXT FROM LeaveDates INTO @SiGenDate, @LeaveDate;
                    END
                CLOSE LeaveDates;
                DEALLOCATE LeaveDates;
                ------------------------------------------------حذف محاسبه مرخصي-------------------------------------
                SET @Err_Code = @@Error;
                IF @Err_Code <> 0
                    SET @Err_Code = 4000;
            END
        ELSE
            SET @Err_Code = 4001;
        RETURN;
    END


GO
ALTER PROCEDURE Tss_RapUntCashPayIudStp
@Err_Code INT OUTPUT, @SiRapCashRecievePay NUMERIC OUTPUT, @SiRapCashDefine NUMERIC=NULL, @SiPubSubLocations NUMERIC=1, @SiPubPersonsSpec NUMERIC=NULL, @Cod_RapCashRecPayCode VARCHAR (50)='', @Des_RapCashRecPayDesc VARCHAR (1000)='', @Sta_RapCashRecOrPayFlag SMALLINT=1, @Sta_RapCashRecPayState SMALLINT=0, @Dat_RapCashRecPayRegDate VARCHAR (10)='', @Dat_RapCashRecPayCngDate VARCHAR (10)='', @Num_RapCashRecPayAmount NUMERIC=0, @Cod_BankBranchCashPayCode VARCHAR (50)='', @Des_BankPayedCash VARCHAR (200)='', @Des_RapCashRecPayGhabzDesc VARCHAR (1000)='', @SiPubPersonsSpec2 NUMERIC=NULL, @SiPubPersonsSpec3 NUMERIC=NULL, @SiPubCustomCodes NUMERIC=NULL, @Cod_CashPayedRecieptCode VARCHAR (50)='', @Dat_PayDate VARCHAR (10)='', @Sta_CashRecieptType SMALLINT=0, @SiRapBehalfDefineHd NUMERIC=NULL, @SiRapCashRecievePayRef_refrenceHd NUMERIC=NULL, @SiPubCostCenter NUMERIC=NULL, @SiRapPaymentAuthorization NUMERIC=NULL, @StmRapCashRecievePay TIMESTAMP=0, @SiUser NUMERIC, @FlgInsUpdDel SMALLINT
AS
IF @FlgInsUpdDel = 0
    BEGIN
        INSERT  INTO dbo.Tss_RapCashRecievePay (SiRapCashDefine, SiPubPersonsSpec, SiPubSubLocations, Cod_RapCashRecPayCode, Des_RapCashRecPayDesc, Sta_RapCashRecOrPayFlag, Sta_RapCashRecPayState, Dat_RapCashRecPayRegDate, Dat_RapCashRecPayCngDate, Num_RapCashRecPayAmount, Cod_BankBranchCashPayCode, Des_BankPayedCash, Des_RapCashRecPayGhabzDesc, SiPubPersonsSpec2, SiPubPersonsSpec3, SiPubCustomCodes, Cod_CashPayedRecieptCode, Dat_PayDate, Sta_CashRecieptType, SiRapBehalfDefineHd, SiRapCashRecievePayRef_refrenceHd, SiPubCostCenter, SiRapPaymentAuthorization)
        VALUES                                (@SiRapCashDefine, @SiPubPersonsSpec, @SiPubSubLocations, @Cod_RapCashRecPayCode, @Des_RapCashRecPayDesc, 1, @Sta_RapCashRecPayState, @Dat_RapCashRecPayRegDate, @Dat_RapCashRecPayCngDate, @Num_RapCashRecPayAmount, @Cod_BankBranchCashPayCode, @Des_BankPayedCash, @Des_RapCashRecPayGhabzDesc, @SiPubPersonsSpec2, @SiPubPersonsSpec3, @SiPubCustomCodes, @Cod_CashPayedRecieptCode, @Dat_PayDate, @Sta_CashRecieptType, @SiRapBehalfDefineHd, @SiRapCashRecievePayRef_refrenceHd, @SiPubCostCenter, @SiRapPaymentAuthorization);
        SET @SiRapCashRecievePay = Scope_Identity();
        IF IsNull(@SiRapCashRecievePay, 0) <> 0
            BEGIN
                EXECUTE dbo.Tss_RapUntCashRecievePayRefIudStp 0, 0, @SiRapBehalfDefineHd, @SiRapCashRecievePay, @Num_RapCashRecPayAmount, @SiRapCashRecievePayRef_refrenceHd, '1', @Des_RapCashRecPayDesc, @SiPubPersonsSpec, @SiRapCashDefine, @SiPubCostCenter, 0, @SiUser, 0;
            END
        IF IsNull(@SiRapCashRecievePay, 0) = 0
            BEGIN
                SET @SiRapCashRecievePay = 0;
                SET @Err_Code = 400;
            END
        RETURN;
    END
IF @FlgInsUpdDel = 1
    BEGIN
        DECLARE @CurrentStmRapCashRecievePay AS TIMESTAMP, @RowCount AS INT, @SiRapCashRecievePayRef AS NUMERIC, @StmRapCashRecievePayRef AS TIMESTAMP, @Cod_RapCashRecievePayRefCode AS VARCHAR (50), @Des_RapCashRecievePayRefDesc AS VARCHAR (1000), @SiPubPersonsSpecdt AS NUMERIC, @SiRapCashDefinedt AS NUMERIC, @SiPubCostCenterdt AS NUMERIC;
        SET @Err_Code = 0;
        -- Look up by key only first, so "not found" and "stale timestamp" can be
        -- told apart instead of both collapsing into the same error code.
        SELECT @CurrentStmRapCashRecievePay = StmRapCashRecievePay
        FROM   dbo.Tss_RapCashRecievePay
        WHERE  SiRapCashRecievePay = @SiRapCashRecievePay;
        IF @CurrentStmRapCashRecievePay IS NULL
            BEGIN
                -- ============================================================
                -- Row doesn't exist -> fall back to insert (same as @FlgInsUpdDel = 0)
                -- ============================================================
                INSERT  INTO dbo.Tss_RapCashRecievePay (SiRapCashDefine, SiPubPersonsSpec, SiPubSubLocations, Cod_RapCashRecPayCode, Des_RapCashRecPayDesc, Sta_RapCashRecOrPayFlag, Sta_RapCashRecPayState, Dat_RapCashRecPayRegDate, Dat_RapCashRecPayCngDate, Num_RapCashRecPayAmount, Cod_BankBranchCashPayCode, Des_BankPayedCash, Des_RapCashRecPayGhabzDesc, SiPubPersonsSpec2, SiPubPersonsSpec3, SiPubCustomCodes, Cod_CashPayedRecieptCode, Dat_PayDate, Sta_CashRecieptType, SiRapBehalfDefineHd, SiRapCashRecievePayRef_refrenceHd, SiPubCostCenter, SiRapPaymentAuthorization)
                VALUES                                (@SiRapCashDefine, @SiPubPersonsSpec, @SiPubSubLocations, @Cod_RapCashRecPayCode, @Des_RapCashRecPayDesc, @Sta_RapCashRecOrPayFlag, @Sta_RapCashRecPayState, @Dat_RapCashRecPayRegDate, @Dat_RapCashRecPayCngDate, @Num_RapCashRecPayAmount, @Cod_BankBranchCashPayCode, @Des_BankPayedCash, @Des_RapCashRecPayGhabzDesc, @SiPubPersonsSpec2, @SiPubPersonsSpec3, @SiPubCustomCodes, @Cod_CashPayedRecieptCode, @Dat_PayDate, @Sta_CashRecieptType, @SiRapBehalfDefineHd, @SiRapCashRecievePayRef_refrenceHd, @SiPubCostCenter, @SiRapPaymentAuthorization);
                SET @SiRapCashRecievePay = Scope_Identity();
                IF IsNull(@SiRapCashRecievePay, 0) <> 0
                    BEGIN
                        EXECUTE dbo.Tss_RapUntCashRecievePayRefIudStp 0, 0, @SiRapBehalfDefineHd, @SiRapCashRecievePay, @Num_RapCashRecPayAmount, @SiRapCashRecievePayRef_refrenceHd, '1', @Des_RapCashRecPayDesc, @SiPubPersonsSpec, @SiRapCashDefine, @SiPubCostCenter, 0, @SiUser, 0;
                    END
                IF IsNull(@SiRapCashRecievePay, 0) = 0
                    BEGIN
                        SET @SiRapCashRecievePay = 0;
                        SET @Err_Code = 400;
                    END
                RETURN;
            END
        IF @CurrentStmRapCashRecievePay <> @StmRapCashRecievePay
            BEGIN
                -- ============================================================
                -- Row exists but caller's timestamp is stale -> real concurrency conflict
                -- ============================================================
                SET @Err_Code = 403;
                RETURN;
            END
        -- ============================================================
        -- Row exists and timestamp matches -> normal update
        -- ============================================================
        UPDATE dbo.Tss_RapCashRecievePay
        SET    SiRapCashDefine                   = @SiRapCashDefine,
               SiPubPersonsSpec                  = @SiPubPersonsSpec,
               SiPubSubLocations                 = @SiPubSubLocations,
               Cod_RapCashRecPayCode             = @Cod_RapCashRecPayCode,
               Des_RapCashRecPayDesc             = @Des_RapCashRecPayDesc,
               Sta_RapCashRecOrPayFlag           = @Sta_RapCashRecOrPayFlag,
               Sta_RapCashRecPayState            = @Sta_RapCashRecPayState,
               Dat_RapCashRecPayRegDate          = @Dat_RapCashRecPayRegDate,
               Dat_RapCashRecPayCngDate          = @Dat_RapCashRecPayCngDate,
               Num_RapCashRecPayAmount           = @Num_RapCashRecPayAmount,
               Cod_BankBranchCashPayCode         = @Cod_BankBranchCashPayCode,
               Des_BankPayedCash                 = @Des_BankPayedCash,
               Des_RapCashRecPayGhabzDesc        = @Des_RapCashRecPayGhabzDesc,
               SiPubPersonsSpec2                 = @SiPubPersonsSpec2,
               SiPubPersonsSpec3                 = @SiPubPersonsSpec3,
               SiPubCustomCodes                  = @SiPubCustomCodes,
               Cod_CashPayedRecieptCode          = @Cod_CashPayedRecieptCode,
               Dat_PayDate                       = @Dat_PayDate,
               Sta_CashRecieptType               = @Sta_CashRecieptType,
               SiRapBehalfDefineHd               = @SiRapBehalfDefineHd,
               SiRapCashRecievePayRef_refrenceHd = @SiRapCashRecievePayRef_refrenceHd,
               SiPubCostCenter                   = @SiPubCostCenter,
               SiRapPaymentAuthorization         = @SiRapPaymentAuthorization
        WHERE  (SiRapCashRecievePay = @SiRapCashRecievePay);
        SELECT @RowCount = COUNT(*)
        FROM   Tss_RapCashRecievePayRef
        WHERE  SiRapCashRecievePay = @SiRapCashRecievePay;
        IF @RowCount = 1
            BEGIN
                SELECT TOP 1 @SiRapCashRecievePayRef = SiRapCashRecievePayRef,
                             @StmRapCashRecievePayRef = StmRapCashRecievePayRef,
                             @Cod_RapCashRecievePayRefCode = Cod_RapCashRecievePayRefCode,
                             @Des_RapCashRecievePayRefDesc = Des_RapCashRecievePayRefDesc,
                             @SiPubPersonsSpecdt = SiPubPersonsSpec,
                             @SiRapCashDefinedt = SiRapCashDefine,
                             @SiPubCostCenterdt = SiPubCostCenter
                FROM   dbo.Tss_RapCashRecievePayRef
                WHERE  SiRapCashRecievePay = @SiRapCashRecievePay;
                EXECUTE dbo.Tss_RapUntCashRecievePayRefIudStp 0, @SiRapCashRecievePayRef, @SiRapBehalfDefineHd, @SiRapCashRecievePay, @Num_RapCashRecPayAmount, @SiRapCashRecievePayRef_refrenceHd, '1', @Des_RapCashRecPayGhabzDesc, @SiPubPersonsSpec, @SiRapCashDefine, NULL, @StmRapCashRecievePayRef, @SiUser, 1;
            END
        ELSE
            IF @RowCount = 0
                BEGIN
                    -- Header exists but has no detail row -> create one
                    EXECUTE dbo.Tss_RapUntCashRecievePayRefIudStp 0, 0, @SiRapBehalfDefineHd, @SiRapCashRecievePay, @Num_RapCashRecPayAmount, @SiRapCashRecievePayRef_refrenceHd, '1', @Des_RapCashRecPayGhabzDesc, @SiPubPersonsSpec, @SiRapCashDefine, NULL, 0, @SiUser, 0;
                END
        SET @Err_Code = @@Error;
        IF @Err_Code <> 0
            SET @Err_Code = 401;
        RETURN;
    END
IF @FlgInsUpdDel = 2
    BEGIN
        SET @Err_Code = 0;
        IF EXISTS (SELECT StmRapCashRecievePay
                   FROM   dbo.Tss_RapCashRecievePay
                   WHERE  (SiRapCashRecievePay = @SiRapCashRecievePay)
                          AND (StmRapCashRecievePay = @StmRapCashRecievePay))
            BEGIN
                DELETE dbo.Tss_RapCashRecievePay
                WHERE  (SiRapCashRecievePay = @SiRapCashRecievePay);
                SET @Err_Code = @@Error;
                IF @Err_Code <> 0
                    SET @Err_Code = 4000;
            END
        ELSE
            SET @Err_Code = 4001;
        RETURN;
    END


GO
/* ---------------------------------------------------------------------------
   Reverse lookup: for the selected tafsils, which Moein / Kol / Group accounts
   do they have postings in (same scope, voucher types and status rules as the
   other review procedures).
   @TafSelected : 'type:si,type:si'   (0 person, 1 cost center, 2 project)
   --------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE Tss_AccUntTafsilAccountsStp
@DsFromDate VARCHAR (10)='1405/01/01', @DsToDate VARCHAR (10)='1405/12/29', @SiAccFinancePeriod NUMERIC=0, @SiPubSubLocations VARCHAR (500)='1,2', @Sta_Start SMALLINT=0, @Sta_End SMALLINT=0, @Sta_Close SMALLINT=0, @TafSelected VARCHAR (MAX)=''
AS
BEGIN
    SET NOCOUNT ON;
    SET ARITHABORT ON;
    SET CONCAT_NULL_YIELDS_NULL ON;
    SET ANSI_NULLS ON;
    SET ANSI_NULL_DFLT_ON ON;
    SET ANSI_PADDING ON;
    SET ANSI_WARNINGS ON;
    SET QUOTED_IDENTIFIER ON;
    DROP TABLE IF EXISTS #TempTable;
    DROP TABLE IF EXISTS #ExcType;
    DROP TABLE IF EXISTS #Taf;
    DROP TABLE IF EXISTS #A;
    DECLARE @AccAllDocs AS SMALLINT = dbo.Tss_StdFindSystemParamValue('AccAllDocs');
    SELECT SiAccFinancePeriodToPlace
    INTO   #TempTable
    FROM   dbo.Tss_AccFinancePeriodToPlace
    WHERE  SiPubSubLocations IN (SELECT *
                                 FROM   dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations));
    SELECT SiAccVoucherType
    INTO   #ExcType
    FROM   Tss_AccVoucherType
    WHERE  (@Sta_Start = 0
            AND Sta_VoucherTypeGroup = 0)
           OR (@Sta_End = 0
               AND Sta_VoucherTypeGroup = 1)
           OR (@Sta_Close = 0
               AND Sta_VoucherTypeGroup = 3);
    SELECT TRY_CAST (LEFT(v, CHARINDEX(':', v) - 1) AS INT) AS TafType,
           TRY_CAST (SUBSTRING(v, CHARINDEX(':', v) + 1, 30) AS NUMERIC (18, 0)) AS SiTaf
    INTO   #Taf
    FROM   (SELECT LTRIM(RTRIM(value)) AS v
            FROM   dbo.Tss_StdStringSplitUdf(ISNULL(@TafSelected, ''), ',')) AS s
    WHERE  v LIKE '%:%';
    -- one row per Moein code (6 chars)
    SELECT   LEFT(cb.Cod_AccountCode, 6) AS Acc_Code,
             SUM(d.Num_VdetDebtAmount) AS Acc_Bed,
             SUM(d.Num_VdetCreditAmount) AS Acc_Bes
    INTO     #A
    FROM     Tss_AccVoucher_Dt AS d
             INNER JOIN
             Tss_AccVoucher_Hd AS h
             ON d.SiAccVoucher_Hd = h.SiAccVoucher_Hd
             INNER JOIN
             Tss_AccCodeBook AS cb
             ON d.SiAccCodeBook = cb.SiAccCodeBook
    WHERE    h.Sta_VochStatus >= 3
             AND (@AccAllDocs <> 0
                  OR h.Sta_VochStatus <> 5)
             AND h.SiAccFinancePeriodToPlace IN (SELECT SiAccFinancePeriodToPlace
                                                 FROM   #TempTable)
             AND h.Dat_VhedDate BETWEEN @DsFromDate AND @DsToDate
             AND h.SiAccVoucherType NOT IN (SELECT SiAccVoucherType
                                            FROM   #ExcType)
             AND EXISTS (SELECT 1
                         FROM   #Taf AS t
                         WHERE  (t.TafType = 0
                                 AND d.SiPubPersonsSpec1 = t.SiTaf)
                                OR (t.TafType = 1
                                    AND d.SiPubCostCenter1 = t.SiTaf)
                                OR (t.TafType = 2
                                    AND d.SiPubProjects1 = t.SiTaf))
    GROUP BY LEFT(cb.Cod_AccountCode, 6);
    SELECT   a.Acc_Code,
             m.Des_AccountDesc,
             LEFT(a.Acc_Code, 4) AS Kol_Code,
             k.Des_AccountDesc AS Des_KolDesc,
             LEFT(a.Acc_Code, 2) AS Grp_Code,
             g.Des_AccountDesc AS Des_GrpDesc,
             a.Acc_Bed,
             a.Acc_Bes,
             CASE WHEN a.Acc_Bed > a.Acc_Bes THEN a.Acc_Bed - a.Acc_Bes ELSE 0 END AS Rst_Bed,
             CASE WHEN a.Acc_Bes > a.Acc_Bed THEN a.Acc_Bes - a.Acc_Bed ELSE 0 END AS Rst_Bes
    FROM     #A AS a
             LEFT OUTER JOIN
             Tss_AccCodeBook AS m
             ON m.Cod_AccountCode = a.Acc_Code
             LEFT OUTER JOIN
             Tss_AccCodeBook AS k
             ON k.Cod_AccountCode = LEFT(a.Acc_Code, 4)
             LEFT OUTER JOIN
             Tss_AccCodeBook AS g
             ON g.Cod_AccountCode = LEFT(a.Acc_Code, 2)
    ORDER BY a.Acc_Code;
    DROP TABLE IF EXISTS #TempTable;
    DROP TABLE IF EXISTS #ExcType;
    DROP TABLE IF EXISTS #Taf;
    DROP TABLE IF EXISTS #A;
END


GO
CREATE OR ALTER PROCEDURE Tss_AccUntAccountReviewRStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)='', @DsFromDate VARCHAR (10)='1405/01/01', @DsToDate VARCHAR (10)='1405/06/31', @SiAccFinancePeriod NUMERIC=20, @SiPubSubLocations VARCHAR (500)='1,2', @Sta_Start SMALLINT=0, @Sta_End SMALLINT=0, @Sta_Close SMALLINT=0, @FlgLevel SMALLINT=1, @FlgTafType SMALLINT=0, @SiSelected VARCHAR (50)='', @Cod_AccountLevel1 VARCHAR (50)='', @Cod_AccountLevel2 VARCHAR (50)='', @StaBaMandeh SMALLINT=0, @AccPrefixes VARCHAR (MAX)='' -- NEW: '11,12' / '1101,1102' / '110101,110102' ; '' = no restriction
AS
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_NULLS ON;
SET ANSI_NULL_DFLT_ON ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET QUOTED_IDENTIFIER ON;
IF @InternalWhere <> ''
    SET @InternalWhere = ' Where ' + @InternalWhere;
IF @Where <> ''
    SET @Where = ' Where ' + @Where;
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
ELSE
    SET @Order = ' Order By Acc_Code';
DECLARE @WhType AS VARCHAR (500), @SqlTxt AS VARCHAR (MAX), @AccAllDocs AS SMALLINT, @TafName AS VARCHAR (100);
SELECT LTRIM(RTRIM(value)) AS Pfx
INTO   #Pfx
FROM   dbo.Tss_StdStringSplitUdf(ISNULL(@AccPrefixes, ''), ',')
WHERE  LTRIM(RTRIM(value)) <> '';
SELECT SiAccFinancePeriodToPlace
INTO   #TempTable
FROM   dbo.Tss_AccFinancePeriodToPlace
WHERE  (SiPubSubLocations IN (SELECT *
                              FROM   dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations)));
SET @WhType = '';
IF @Sta_Start = 0
    SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
    FROM   Tss_AccVoucherType
    WHERE  (Sta_VoucherTypeGroup = 0);
IF @Sta_End = 0
    IF @WhType = ''
        SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
    ELSE
        SELECT @WhType = @WhType + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
IF @Sta_Close = 0
    IF @WhType = ''
        SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
    ELSE
        SELECT @WhType = @WhType + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
IF @FlgTafType = 0
    SET @TafName = 'SiPubPersonsSpec1';
IF @FlgTafType = 1
    SET @TafName = 'SiPubCostCenter1';
IF @FlgTafType = 2
    SET @TafName = 'SiPubProjects1';
IF @FlgTafType = 3
    SET @TafName = 'SiPurOrder_Hd1';
SELECT @AccAllDocs = dbo.Tss_StdFindSystemParamValue('AccAllDocs');
IF @FlgLevel = 1
    BEGIN
        SET @SqlTxt = 'SELECT
      left(cBook.Cod_AccountCode,2) Acc_Code,
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2,
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3,
      vDet.Num_VdetDebtAmount,
      vDet.Num_VdetCreditAmount
   FROM
      dbo.Tss_AccCodeBook cBook
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) AND
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) AND
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        IF @SiSelected <> ''
            SET @SqlTxt = @SqlTxt + ' and (vDet.' + @TafName + '=' + @SiSelected + ') ';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = 'Select
         Acc_Code,
         Acc_Bed,
         Acc_Bes,
         Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
         Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1
      From
      (
         Select
            Acc_Code,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From
         (' + @SqlTxt + '

         ) Ddd
         Group By Acc_Code
      )
      Ddd2 INNER JOIN dbo.Tss_AccCodeBook ON
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode';
    END
IF @FlgLevel = 2
    BEGIN
        SET @SqlTxt = 'SELECT
      left(cBook.Cod_AccountCode,4) As Acc_Code,
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2,
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3,
      vDet.Num_VdetDebtAmount,
      vDet.Num_VdetCreditAmount
   FROM
      dbo.Tss_AccCodeBook cBook
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE  ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) and
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) and
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        -- NEW: list of group codes (prefixes) selected above; falls back to the old single-value parameter
        IF EXISTS (SELECT 1
                   FROM   #Pfx)
            SET @SqlTxt = @SqlTxt + ' AND (EXISTS (SELECT 1 FROM #Pfx p WHERE cBook.Cod_AccountCode LIKE p.Pfx + ''%''))';
        ELSE
            IF @Cod_AccountLevel1 <> ''
                SET @SqlTxt = @SqlTxt + ' AND (left(cBook.Cod_AccountCode,2)=' + '''' + @Cod_AccountLevel1 + '''' + ')';
        IF @SiSelected <> ''
            SET @SqlTxt = @SqlTxt + ' and (vDet.' + @TafName + '=' + @SiSelected + ') ';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = 'Select
         Acc_Code,
         Acc_Bed,
         Acc_Bes,
         Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
         Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1
      From
      (
         Select
            Acc_Code,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From
         (' + @SqlTxt + '

         ) Ddd
         Group By Acc_Code
      )
      Ddd2 INNER JOIN dbo.Tss_AccCodeBook ON
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode';
    END
IF @FlgLevel = 3
    BEGIN
        SET @SqlTxt = 'SELECT
      left(cBook.Cod_AccountCode,6) As Acc_Code,
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2,
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3,
      vDet.Num_VdetDebtAmount,
      vDet.Num_VdetCreditAmount
   FROM
      dbo.Tss_AccCodeBook cBook
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) and
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) and
	      (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ')';
        -- NEW: list of group / kol codes (prefixes) selected above
        IF EXISTS (SELECT 1
                   FROM   #Pfx)
            SET @SqlTxt = @SqlTxt + ' AND (EXISTS (SELECT 1 FROM #Pfx p WHERE cBook.Cod_AccountCode LIKE p.Pfx + ''%''))';
        ELSE
            BEGIN
                IF len(@Cod_AccountLevel2) = 2
                    SET @SqlTxt = @SqlTxt + ' AND (left(cBook.Cod_AccountCode,2)=' + '''' + @Cod_AccountLevel2 + '''' + ')';
                IF len(@Cod_AccountLevel2) = 4
                    SET @SqlTxt = @SqlTxt + ' AND (left(cBook.Cod_AccountCode,4)=' + '''' + @Cod_AccountLevel2 + '''' + ')';
                IF @Cod_AccountLevel2 = ''
                    SET @SqlTxt = @SqlTxt + ' AND (len(cBook.Cod_AccountCode)=6)';
            END
        IF @SiSelected <> ''
            SET @SqlTxt = @SqlTxt + ' and (vDet.' + @TafName + '=' + @SiSelected + ') ';
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = 'Select
         Acc_Code,
         Acc_Bed,
         Acc_Bes,
         Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
         Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1
      From
      (
         Select
            Acc_Code,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From
         (' + @SqlTxt + '

         ) Ddd
         Group By Acc_Code
      )
      Ddd2 INNER JOIN dbo.Tss_AccCodeBook ON
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode';
    END
EXECUTE ('Select * From
(
   Select * From
   ( ' + @SqlTxt + ' ) Ccc  ' + @InternalWhere + '
) CalcSel ' + @Where + @Order);


GO
/* ---------------------------------------------------------------------------
   2) Tafsil level
   - @AccPrefixes: comma list of account-code prefixes ('' = all accounts)
   - @Sta_LastSanad = 1: adds description / date / amount of the last voucher
     (types 1,2 excluded) of every tafsil; when 0 those three columns are NULL.
   - No DISTINCT collapse of equal lines any more (voucher + row number are part
     of the distinct key), so Moein totals and Tafsil totals reconcile.
   --------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE Tss_AccUntAllTafsilisReviewVStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)='', @DsFromDate VARCHAR (10)='1399/01/01', @DsToDate VARCHAR (10)='1399/03/17', @SiAccFinancePeriod NUMERIC=20, @SiPubSubLocations VARCHAR (500)='1,2', @Sta_Start SMALLINT=0, @Sta_Close SMALLINT=0, @Sta_End SMALLINT=0, @Sta_BiMandeh SMALLINT=0, @AccMoeinCode VARCHAR (10)='', @AccPrefixes VARCHAR (MAX)='', @Sta_LastSanad SMALLINT=0
AS
BEGIN
    SET NOCOUNT ON;
    SET ARITHABORT ON;
    SET CONCAT_NULL_YIELDS_NULL ON;
    SET ANSI_NULLS ON;
    SET ANSI_NULL_DFLT_ON ON;
    SET ANSI_PADDING ON;
    SET ANSI_WARNINGS ON;
    SET QUOTED_IDENTIFIER ON;
    DROP TABLE IF EXISTS #TempTable;
    DROP TABLE IF EXISTS #ExcType;
    DROP TABLE IF EXISTS #Pfx;
    DROP TABLE IF EXISTS #Acc;
    DROP TABLE IF EXISTS #B;
    DROP TABLE IF EXISTS #L;
    DROP TABLE IF EXISTS #Last;
    DROP TABLE IF EXISTS #R;
    IF @InternalWhere <> ''
        SET @InternalWhere = ' Where ' + @InternalWhere;
    IF @Where <> ''
        SET @Where = ' Where ' + @Where;
    IF @Order <> ''
        SET @Order = ' Order By ' + @Order;
    ELSE
        SET @Order = ' Order By StaTafType, CodeTaf';
    DECLARE @AccAllDocs AS SMALLINT = dbo.Tss_StdFindSystemParamValue('AccAllDocs');
    SELECT SiAccFinancePeriodToPlace
    INTO   #TempTable
    FROM   dbo.Tss_AccFinancePeriodToPlace
    WHERE  SiPubSubLocations IN (SELECT *
                                 FROM   dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations));
    -- voucher types that are excluded (opening / ending / closing groups when not ticked)
    SELECT SiAccVoucherType
    INTO   #ExcType
    FROM   Tss_AccVoucherType
    WHERE  (@Sta_Start = 0
            AND Sta_VoucherTypeGroup = 0)
           OR (@Sta_End = 0
               AND Sta_VoucherTypeGroup = 1)
           OR (@Sta_Close = 0
               AND Sta_VoucherTypeGroup = 3);
    -- account prefixes (new list parameter; falls back to the old single-code parameter)
    SELECT LTRIM(RTRIM(value)) AS Pfx
    INTO   #Pfx
    FROM   dbo.Tss_StdStringSplitUdf(CASE WHEN ISNULL(@AccPrefixes, '') <> '' THEN @AccPrefixes ELSE ISNULL(@AccMoeinCode, '') END, ',')
    WHERE  LTRIM(RTRIM(value)) <> '';
    DECLARE @HasPfx AS BIT = CASE WHEN EXISTS (SELECT 1
                                               FROM   #Pfx) THEN 1 ELSE 0 END;
    SELECT cb.SiAccCodeBook
    INTO   #Acc
    FROM   Tss_AccCodeBook AS cb
    WHERE  EXISTS (SELECT 1
                   FROM   #Pfx AS p
                   WHERE  cb.Cod_AccountCode LIKE p.Pfx + '%');
    CREATE CLUSTERED INDEX IX_Acc
        ON #Acc(SiAccCodeBook);
    -- filtered voucher lines (one row per line)
    SELECT Acchd.SiAccVoucher_Hd,
           Accdt.Num_VDetRow,
           Acchd.SiAccVoucherType,
           Accdt.SiPubPersonsSpec1,
           Accdt.SiPubCostCenter1,
           Accdt.SiPubProjects1,
           Accdt.Num_VdetDebtAmount,
           Accdt.Num_VdetCreditAmount,
           Accdt.Des_VdetDesc,
           Accdt.Dat_AccVoucherDetDate,
           Accdt.Num_VdetAmount
    INTO   #B
    FROM   Tss_AccVoucher_Dt AS Accdt
           INNER JOIN
           Tss_AccVoucher_Hd AS Acchd
           ON Accdt.SiAccVoucher_Hd = Acchd.SiAccVoucher_Hd
    WHERE  Acchd.Sta_VochStatus >= 3
           AND (@AccAllDocs <> 0
                OR Acchd.Sta_VochStatus <> 5)
           AND Acchd.SiAccFinancePeriodToPlace IN (SELECT SiAccFinancePeriodToPlace
                                                   FROM   #TempTable)
           AND Acchd.Dat_VhedDate BETWEEN @DsFromDate AND @DsToDate
           AND Acchd.SiAccVoucherType NOT IN (SELECT SiAccVoucherType
                                              FROM   #ExcType)
           AND (@HasPfx = 0
                OR Accdt.SiAccCodeBook IN (SELECT SiAccCodeBook
                                           FROM   #Acc));
    -- lines expanded per tafsil type
    SELECT *
    INTO   #L
    FROM   (SELECT DISTINCT 0 AS StaTafType,
                            'تفصیلی اشخاص' AS TafType,
                            b.SiPubPersonsSpec1 AS SiTaf,
                            pv.Cod_PubPersonCode AS CodeTaf,
                            pv.Des_FullName AS NameTaf,
                            b.SiAccVoucher_Hd,
                            b.Num_VDetRow,
                            b.SiAccVoucherType,
                            b.Num_VdetDebtAmount,
                            b.Num_VdetCreditAmount,
                            b.Des_VdetDesc,
                            b.Dat_AccVoucherDetDate,
                            b.Num_VdetAmount
            FROM   #B AS b
                   INNER JOIN
                   Tss_PubPersonsViw AS pv
                   ON b.SiPubPersonsSpec1 = pv.SiPubPersonsSpec
            UNION ALL
            SELECT DISTINCT 1,
                            'تفصیلی مرکز هزینه',
                            b.SiPubCostCenter1,
                            cc.Cod_CostCenterCode,
                            cc.Des_CostCenterName,
                            b.SiAccVoucher_Hd,
                            b.Num_VDetRow,
                            b.SiAccVoucherType,
                            b.Num_VdetDebtAmount,
                            b.Num_VdetCreditAmount,
                            b.Des_VdetDesc,
                            b.Dat_AccVoucherDetDate,
                            b.Num_VdetAmount
            FROM   #B AS b
                   INNER JOIN
                   Tss_PubCostCenter AS cc
                   ON b.SiPubCostCenter1 = cc.SiPubCostCenter
            UNION ALL
            SELECT DISTINCT 2,
                            'تفصیلی پروژه قرارداد',
                            b.SiPubProjects1,
                            pr.Cod_ProjectsCode,
                            pr.Des_ProjectsThemeDesc,
                            b.SiAccVoucher_Hd,
                            b.Num_VDetRow,
                            b.SiAccVoucherType,
                            b.Num_VdetDebtAmount,
                            b.Num_VdetCreditAmount,
                            b.Des_VdetDesc,
                            b.Dat_AccVoucherDetDate,
                            b.Num_VdetAmount
            FROM   #B AS b
                   INNER JOIN
                   Tss_PubProjects AS pr
                   ON b.SiPubProjects1 = pr.SiPubProjects) AS X;
    -- last voucher per tafsil (only when asked)
    SELECT StaTafType,
           SiTaf,
           Des_VdetDesc,
           Dat_AccVoucherDetDate,
           Num_VdetAmount
    INTO   #Last
    FROM   (SELECT StaTafType,
                   SiTaf,
                   Des_VdetDesc,
                   Dat_AccVoucherDetDate,
                   Num_VdetAmount,
                   ROW_NUMBER() OVER (PARTITION BY StaTafType, SiTaf ORDER BY Dat_AccVoucherDetDate DESC, SiAccVoucher_Hd DESC, Num_VDetRow DESC) AS rn
            FROM   #L
            WHERE  @Sta_LastSanad = 1
                   AND SiAccVoucherType NOT IN (1, 2)) AS Z
    WHERE  rn = 1;
    SELECT a.StaTafType,
           a.TafType,
           a.SiTaf,
           a.CodeTaf,
           a.NameTaf,
           a.Acc_Bed,
           a.Acc_Bes,
           CASE WHEN a.Acc_Bed > a.Acc_Bes THEN a.Acc_Bed - a.Acc_Bes ELSE 0 END AS Rst_Bed,
           CASE WHEN a.Acc_Bes > a.Acc_Bed THEN a.Acc_Bes - a.Acc_Bed ELSE 0 END AS Rst_Bes,
           l.Des_VdetDesc,
           l.Dat_AccVoucherDetDate,
           l.Num_VdetAmount
    INTO   #R
    FROM   (SELECT   StaTafType,
                     TafType,
                     SiTaf,
                     CodeTaf,
                     NameTaf,
                     SUM(Num_VdetDebtAmount) AS Acc_Bed,
                     SUM(Num_VdetCreditAmount) AS Acc_Bes
            FROM     #L
            GROUP BY StaTafType, TafType, SiTaf, CodeTaf, NameTaf) AS a
           LEFT OUTER JOIN
           #Last AS l
           ON l.StaTafType = a.StaTafType
              AND l.SiTaf = a.SiTaf
    WHERE  (@Sta_BiMandeh = 0
            OR a.Acc_Bed <> a.Acc_Bes);
    EXECUTE ('Select * From
   (
      Select * From
      ( Select * From #R ) Ccc ' + @InternalWhere + '
   ) CalcSel ' + @Where + @Order);
END


GO
CREATE OR ALTER FUNCTION dbo.Tss_StdStringSplitUdf
(@List NVARCHAR (MAX), @Delim NCHAR (1)=N',')
RETURNS 
    @T TABLE (
        value NVARCHAR (MAX))
AS
BEGIN
    IF @List IS NULL
       OR @List = N''
        RETURN;
    DECLARE @Pos AS INT, @Prev AS INT;
    SET @Prev = 1;
    SET @Pos = CHARINDEX(@Delim, @List, @Prev);
    WHILE @Pos > 0
        BEGIN
            INSERT  @T (value)
            VALUES    (SUBSTRING(@List, @Prev, @Pos - @Prev));
            SET @Prev = @Pos + 1;
            SET @Pos = CHARINDEX(@Delim, @List, @Prev);
        END
    -- last token
    INSERT  @T (value)
    VALUES    (SUBSTRING(@List, @Prev, LEN(@List) - @Prev + 1));
    RETURN;
END


GO
ALTER PROCEDURE Tss_SalGdsPriceListRep
AS
BEGIN
    SET NOCOUNT ON;
    SELECT   C.Cod_GoodsClassCode,
             C.Des_GoodsClassDesc,
             C.Num_Layer,
             CASE WHEN C.Num_Layer = 0 THEN 3 WHEN C.Num_Layer = 1 THEN 9 ELSE 3 END AS SiFlute, -- ۳ لایه → فلوت C
              -- ۵ لایه → فلوت B+C
             L.L1,
             L.L2,
             L.L3,
             L.L4,
             L.L5,
             dbo.Tss_SalCalcGdsFormulaPricUdf(3, CASE WHEN C.Num_Layer = 0 THEN 3 WHEN C.Num_Layer = 1 THEN 9 ELSE 3 END, L.L1, L.L2, L.L3, L.L4, L.L5) AS Num_OneMeterSheetPrice,
             dbo.Tss_SalCalcGdsFormulaPricBoxUdf(3, CASE WHEN C.Num_Layer = 0 THEN 3 WHEN C.Num_Layer = 1 THEN 9 ELSE 3 END, L.L1, L.L2, L.L3, L.L4, L.L5) AS Num_OneMeterBoxPrice
    FROM     Tss_PubGoodsClassify AS C CROSS APPLY (SELECT MAX(CASE WHEN F.Sta_LayerType = 0 THEN F.SiPubGoodsClassifyGds END) AS L1,
                                                           MAX(CASE WHEN F.Sta_LayerType = 1 THEN F.SiPubGoodsClassifyGds END) AS L2,
                                                           MAX(CASE WHEN F.Sta_LayerType = 2 THEN F.SiPubGoodsClassifyGds END) AS L3,
                                                           MAX(CASE WHEN F.Sta_LayerType = 3 THEN F.SiPubGoodsClassifyGds END) AS L4,
                                                           MAX(CASE WHEN F.Sta_LayerType = 4 THEN F.SiPubGoodsClassifyGds END) AS L5
                                                    FROM   Tss_PrcMatFormulaClaToPaperTypesCla AS F
                                                    WHERE  F.SiPubGoodsClassifyFormula = C.SiPubGoodsClassify) AS L
    WHERE    C.Sta_GoodsClassifyEnabled = 1
             AND C.Num_Layer IN (0, 1)
             AND L.L1 IS NOT NULL
    ORDER BY C.Num_Layer, C.Des_GoodsClassDesc;
END


GO
CREATE OR ALTER FUNCTION dbo.Tss_StdStringSplitUdf
(@List NVARCHAR (MAX), @Delim NCHAR (1)=N',')
RETURNS 
    @T TABLE (
        value NVARCHAR (MAX))
AS
BEGIN
    IF @List IS NULL
       OR @List = N''
        RETURN;
    DECLARE @Pos AS INT, @Prev AS INT;
    SET @Prev = 1;
    SET @Pos = CHARINDEX(@Delim, @List, @Prev);
    WHILE @Pos > 0
        BEGIN
            INSERT  @T (value)
            VALUES    (SUBSTRING(@List, @Prev, @Pos - @Prev));
            SET @Prev = @Pos + 1;
            SET @Pos = CHARINDEX(@Delim, @List, @Prev);
        END
    -- last token
    INSERT  @T (value)
    VALUES    (SUBSTRING(@List, @Prev, LEN(@List) - @Prev + 1));
    RETURN;
END


GO
ALTER PROCEDURE Tss_AccUntTafsiliReview_01VStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)='', @FlgTafType SMALLINT=1, @DsFromDate VARCHAR (10)='1401/01/01', @DsToDate VARCHAR (10)='1401/09/20', @SiUser NUMERIC=11224, @Sta_GardeshDar SMALLINT=0
AS
SET XACT_ABORT ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_NULLS ON;
SET ANSI_NULL_DFLT_ON ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET QUOTED_IDENTIFIER ON;
IF @InternalWhere <> ''
    SET @InternalWhere = ' Where ' + @InternalWhere;
IF @Where <> ''
    SET @Where = ' Where ' + @Where;
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
DECLARE @SqlTxt AS VARCHAR (2000), @UserGroup AS VARCHAR (500), @SiPer AS VARCHAR (50), @AccAllDocs AS SMALLINT;
SELECT @AccAllDocs = dbo.Tss_StdFindSystemParamValue('AccAllDocs');
SET @UserGroup = '';
SELECT @UserGroup = isnull(Tss_PubCustomCodes.Des_CustomCodesDesc, ''),
       @SiPer = CONVERT (VARCHAR (50), Tss_StdSystemUsers.SiPubPersonsSpec)
FROM   Tss_StdSystemUserTogrps
       INNER JOIN
       Tss_PubCustomCodes
       ON Tss_StdSystemUserTogrps.SiPubCustomCodes = Tss_PubCustomCodes.SiPubCustomCodes
       INNER JOIN
       Tss_StdSystemUsers
       ON Tss_StdSystemUserTogrps.SiStdSystemUsers = Tss_StdSystemUsers.SiStdSystemUsers
WHERE  (Tss_StdSystemUsers.SiPubPersonsSpec = @SiUser);
IF @Sta_GardeshDar = 1
    BEGIN
        IF (@FlgTafType = 1)
           AND (dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'sal') = 1)
           AND (dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'acc') <> 1)
            EXECUTE ('Select distinct * From 
	   (
		SELECT     
			Accdt.SiPubPersonsSpec1 As SiTaf, 
			Tss_PubPersonsViw.Cod_PubPersonCode As CodeTaf, 
			Tss_PubPersonsViw.Des_FullName As NameTaf,
--			dbo.Tss_PubFindRelatedSalerDes(Tss_PubPersonsViw.SiPerRelatedSaler) as RelatedSaler
			Tss_PubPersonsViw.RelatedSalerFamily as RelatedSaler,
			Tss_PubPersonsViw.Sta_PerNature,
			Tss_PubPersonsViw.Sta_PerNatureDes
		FROM         
			Tss_AccVoucher_Dt Accdt INNER JOIN
			Tss_AccVoucher_Hd Acchd ON Accdt.SiAccVoucher_Hd = Acchd.SiAccVoucher_Hd INNER JOIN
			Tss_PubPersonsViw ON Accdt.SiPubPersonsSpec1 = Tss_PubPersonsViw.SiPubPersonsSpec
		WHERE     
			(Acchd.Dat_VhedDate between ' + '''' + @DsFromDate + '''' + ' and ' + '''' + @DsToDate + '''' + ' AND (Tss_PubPersonsViw.SiPerRelatedSaler =' + @SiPer + '))' + @InternalWhere + '
	   ) CalcSel ' + @Where + @Order);
        IF (@FlgTafType = 1)
           AND (dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'sal') <> 1)
            EXECUTE ('Select * From 
	   (
		SELECT distinct    
			Accdt.SiPubPersonsSpec1 As SiTaf, 
			Tss_PubPersonsViw.Cod_PubPersonCode As CodeTaf, 
			Tss_PubPersonsViw.Des_FullName As NameTaf,
			Tss_PubPersonsViw.Sta_PerNature,
			Tss_PubPersonsViw.Sta_PerNatureDes
		FROM         
			Tss_AccVoucher_Dt Accdt INNER JOIN
			Tss_AccVoucher_Hd Acchd ON Accdt.SiAccVoucher_Hd = Acchd.SiAccVoucher_Hd INNER JOIN
			Tss_PubPersonsViw ON Accdt.SiPubPersonsSpec1 = Tss_PubPersonsViw.SiPubPersonsSpec
		WHERE     
			(Acchd.Dat_VhedDate between ' + '''' + @DsFromDate + '''' + ' and ' + '''' + @DsToDate + '''' + ')' + @InternalWhere + '
	   ) CalcSel ' + @Where + @Order);
        IF (@FlgTafType = 1)
           AND (dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'Acc') = 1)
            EXECUTE ('Select * From 
	   (
		SELECT distinct    
			Accdt.SiPubPersonsSpec1 As SiTaf, 
			Tss_PubPersonsViw.Cod_PubPersonCode As CodeTaf, 
			Tss_PubPersonsViw.Des_FullName As NameTaf,
--			dbo.Tss_PubFindRelatedSalerDes(Tss_PubPersonsViw.SiPerRelatedSaler) as RelatedSaler
			Tss_PubPersonsViw.RelatedSalerFamily as RelatedSaler,
			Tss_PubPersonsViw.Sta_PerNature,
			Tss_PubPersonsViw.Sta_PerNatureDes
		FROM         
			Tss_AccVoucher_Dt Accdt INNER JOIN
			Tss_AccVoucher_Hd Acchd ON Accdt.SiAccVoucher_Hd = Acchd.SiAccVoucher_Hd INNER JOIN
			Tss_PubPersonsViw ON Accdt.SiPubPersonsSpec1 = Tss_PubPersonsViw.SiPubPersonsSpec
		WHERE     
			(Acchd.Dat_VhedDate between ' + '''' + @DsFromDate + '''' + ' and ' + '''' + @DsToDate + '''' + ')' + @InternalWhere + '
	   ) CalcSel ' + @Where + @Order);
    END
IF @Sta_GardeshDar = 0
    BEGIN
        IF (@FlgTafType = 1)
           AND (dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'sal') = 1)
           AND (dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'acc') <> 1)
            BEGIN
                PRINT 'injam';
                IF dbo.Tss_StdFindSubLoc(0) = 'Caspian'
                    EXECUTE ('Select * From 
	   (
	   SELECT     
	      SiPubPersonsSpec As SiTaf, 
	      Cod_PubPersonCode As CodeTaf , 
	      Des_FullName As NameTaf,
--			dbo.Tss_PubFindRelatedSalerDes(Tss_PubPersonsViw.SiPerRelatedSaler) as RelatedSaler
			Tss_PubPersonsViw.RelatedSalerFamily as RelatedSaler,
			Tss_PubPersonsViw.Sta_PerNature,
			Tss_PubPersonsViw.Sta_PerNatureDes
	   FROM  
			dbo.Tss_PubPersonsViw 
		Where
			(Tss_PubPersonsViw.SiPerRelatedSaler =' + @SiPer + ') and SiPerRelatedSaler = ' + @SiPer + @InternalWhere + '
	   ) CalcSel ' + @Where + @Order);
                ELSE
                    EXECUTE ('Select * From 
	   (
	   SELECT     
	      SiPubPersonsSpec As SiTaf, 
	      Cod_PubPersonCode As CodeTaf , 
	      Des_FullName As NameTaf,
--			dbo.Tss_PubFindRelatedSalerDes(Tss_PubPersonsViw.SiPerRelatedSaler) as RelatedSaler
			Tss_PubPersonsViw.RelatedSalerFamily as RelatedSaler,
			Tss_PubPersonsViw.Sta_PerNature,
			Tss_PubPersonsViw.Sta_PerNatureDes
	   FROM  
			dbo.Tss_PubPersonsViw 
		Where
			Sta_PubPersonsGroup=2
	   ) CalcSel ' + @Where + @Order);
            END
        IF (@FlgTafType = 1)
           AND (dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'sal') <> 1)
            EXECUTE ('Select * From 
	   (
	   SELECT     
	      SiPubPersonsSpec As SiTaf, 
	      Cod_PubPersonCode As CodeTaf , 
	      Des_FullName As NameTaf,
--			dbo.Tss_PubFindRelatedSalerDes(Tss_PubPersonsViw.SiPerRelatedSaler) as RelatedSaler
			Tss_PubPersonsViw.RelatedSalerFamily as RelatedSaler,
			Tss_PubPersonsViw.Sta_PerNature,
			Tss_PubPersonsViw.Sta_PerNatureDes
	   FROM  dbo.Tss_PubPersonsViw ' + @InternalWhere + '
	   ) CalcSel ' + @Where + @Order);
        IF (@FlgTafType = 1)
           AND (dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'Acc') = 1)
            EXECUTE ('Select * From 
	   (
	   SELECT     
	      SiPubPersonsSpec As SiTaf, 
	      Cod_PubPersonCode As CodeTaf , 
	      Des_FullName As NameTaf,
--			dbo.Tss_PubFindRelatedSalerDes(Tss_PubPersonsViw.SiPerRelatedSaler) as RelatedSaler
			Tss_PubPersonsViw.RelatedSalerFamily as RelatedSaler,
			Tss_PubPersonsViw.Sta_PerNature,
			Tss_PubPersonsViw.Sta_PerNatureDes
	   FROM  dbo.Tss_PubPersonsViw ' + @InternalWhere + '
	   ) CalcSel ' + @Where + @Order);
    END
IF @FlgTafType = 2
    EXECUTE ('Select * From 
   (
   SELECT     
	SiPubCostCenter As SiTaf, 
	Cod_CostCenterCode As CodeTaf, 
	Des_CostCenterName As NameTaf,
	'''' as RelatedSaler,
	0 as Sta_PerNature,
	'''' as Sta_PerNatureDes
   FROM         dbo.Tss_PubCostCenter ' + @InternalWhere + '
   ) CalcSel ' + @Where + @Order);
IF @FlgTafType = 3
    EXECUTE ('Select * From 
   (
   SELECT     
	SiPubProjects As SiTaf, 
	Cod_ProjectsCode As CodeTaf, 
	Des_ProjectsThemeDesc As NameTaf,
	'''' as RelatedSaler,
	0 as Sta_PerNature,
	'''' as Sta_PerNatureDes
   FROM         dbo.Tss_PubProjects ' + @InternalWhere + '
   ) CalcSel ' + @Where + @Order);
IF @FlgTafType = 4
    EXECUTE ('Select * From 
   (
   SELECT     
		SiCntContracts_Hd AS SiTaf, 
		Cod_CntContractsCode AS CodeTaf, 
		Des_CntContractsDesc AS NameTaf, 
		'''' AS RelatedSaler,
		0 as Sta_PerNature,
		'''' as Sta_PerNatureDes
	FROM         
		Tss_CntContracts_Hd ' + @InternalWhere + '
   ) CalcSel ' + @Where + @Order);
PRINT @SqlTxt;
EXECUTE (@SqlTxt);


GO
ALTER VIEW Tss_RapRecCheckGhabzRep1Vw
AS
SELECT   dbo.Tss_RapReceivedCheque.Des_RecCheqOurSayadiNationalCode,
         dbo.Tss_RapReceivedCheque.Cod_RapReceivedChequeCode AS GhabzNo,
         dbo.Tss_PubCustomCodes.Des_CustomCodesDesc AS BankName,
         Tss_PubPersonsViw_1.Cod_PubPersonCode AS RecieverCode,
         Tss_PubPersonsViw_1.Des_FullName AS RecieverName,
         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeEndDate AS UsanceDate,
         dbo.Tss_RapReceivedCheque.Num_RapReceivedChequeAmount AS ChequeAmount,
         dbo.Tss_RapReceivedCheque.Cod_RapReceivedChqBankCode AS BankBranchCode,
         dbo.Tss_RapReceivedCheque.Cod_RapReceivedChequeSerial AS ChequeSerial,
         dbo.Tss_RapReceivedCheque.Des_RapReceivedChequeDesc AS Tozihat,
         dbo.Tss_RapReceivedCheque.Des_RapReceivedChequeRecieptDesc AS RecieptTozih,
         dbo.Tss_RapReceivedCheque.Sta_ChekRecieptMainOrNot,
         dbo.Tss_RapReceivedCheque.SiRapReceivedCheque,
         dbo.Tss_RapReceivedCheque.SiPubPersonsSpec,
         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeCngDate,
         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeVosoolDate,
         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeBargashtDate,
         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeCancelDate,
         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeToPerDate,
         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeToBankDate,
         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeHoghughiDate,
         dbo.Tss_RapReceivedCheque.SiPubSubLocations,
         dbo.Tss_RapReceivedCheque.SiRapCashDefine,
         dbo.Tss_RapReceivedCheque.SiPubCustomCodes,
         Tss_PubPersonsViw_2.Cod_PubPersonCode AS GiverCode,
         Tss_PubPersonsViw_2.Des_FullName AS GiverName,
         Tss_PubPersonsViw_2.Cod_PubPersonCode,
         Tss_PubPersonsViw_2.Des_FullName,
         dbo.Tss_RapRecChequeToBankVw.Sta_CheckToBankState,
         (SELECT   TOP (1) dbo.Tss_PubPersonsViw.Des_FullName
          FROM     dbo.Tss_RapRecChequeToBank
                   INNER JOIN
                   dbo.Tss_PubPersonsViw
                   ON dbo.Tss_RapRecChequeToBank.SiPubPersonsSpec = dbo.Tss_PubPersonsViw.SiPubPersonsSpec
          WHERE    (dbo.Tss_RapRecChequeToBank.Sta_CheckToBankState < 3)
                   AND (dbo.Tss_RapRecChequeToBank.SiRapReceivedCheque = dbo.Tss_RapReceivedCheque.SiRapReceivedCheque)
          ORDER BY dbo.Tss_RapRecChequeToBank.SiRapRecChequeToBank DESC) AS GirandehDesc,
         (SELECT   TOP (1) Tss_PubPersonsViw_3.Cod_PubPersonCode
          FROM     dbo.Tss_RapRecChequeToBank AS Tss_RapRecChequeToBank_1
                   INNER JOIN
                   dbo.Tss_PubPersonsViw AS Tss_PubPersonsViw_3
                   ON Tss_RapRecChequeToBank_1.SiPubPersonsSpec = Tss_PubPersonsViw_3.SiPubPersonsSpec
          WHERE    (Tss_RapRecChequeToBank_1.Sta_CheckToBankState < 3)
                   AND (Tss_RapRecChequeToBank_1.SiRapReceivedCheque = dbo.Tss_RapReceivedCheque.SiRapReceivedCheque)
          ORDER BY Tss_RapRecChequeToBank_1.SiRapRecChequeToBank DESC) AS GirandehCode,
         dbo.Tss_RapReceivedCheque.Dat_EsterdadToPer,
         dbo.Tss_RapReceivedCheque.Dat_EsterdadToCashier,
         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeToAgainDate,
         dbo.Tss_RapReceivedCheque.SiRapRecievedChequeRef_RefrenceHd,
         dbo.Tss_RapReceivedCheque.SiRapBehalfDefineHd,
         dbo.Tss_RapReceivedCheque.Sta_CalcInReturnRep,
         dbo.Tss_RapReceivedCheque.Sta_RapReceivedChequeState,
         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeRegDate AS RegDate,
         Tss_PubPersonsViw_4.Cod_PubPersonCode AS Expr1,
         Tss_PubPersonsViw_4.Des_FullName AS Expr2,
         Tss_PubPersonsViw_2.SiPerRelatedSaler,
         dbo.Tss_RapReceivedCheque.Des_ReceivedChequeSayadiCode,
         dbo.Tss_RapReceivedCheque.Des_ReceivedChequeSayadiNationalCode,
         dbo.Tss_RapReceivedCheque.Sta_IsChecqueElectronic
FROM     dbo.Tss_PubPersonsViw AS Tss_PubPersonsViw_4
         RIGHT OUTER JOIN
         dbo.Tss_RapReceivedCheque
         INNER JOIN
         dbo.Tss_RapCashDefine
         ON dbo.Tss_RapReceivedCheque.SiRapCashDefine = dbo.Tss_RapCashDefine.SiRapCashDefine
         INNER JOIN
         dbo.Tss_RapCashOwners
         ON dbo.Tss_RapCashDefine.SiRapCashDefine = dbo.Tss_RapCashOwners.SiRapCashDefine
         INNER JOIN
         dbo.Tss_PubPersonsViw AS Tss_PubPersonsViw_1
         ON dbo.Tss_RapCashOwners.SiPubPersonsSpec = Tss_PubPersonsViw_1.SiPubPersonsSpec
         INNER JOIN
         dbo.Tss_PubPersonsViw AS Tss_PubPersonsViw_2
         ON dbo.Tss_RapReceivedCheque.SiPubPersonsSpec = Tss_PubPersonsViw_2.SiPubPersonsSpec
         ON Tss_PubPersonsViw_4.SiPubPersonsSpec = Tss_PubPersonsViw_2.SiPerRelatedSaler
         LEFT OUTER JOIN
         dbo.Tss_RapRecChequeToBankVw
         ON dbo.Tss_RapReceivedCheque.SiRapReceivedCheque = dbo.Tss_RapRecChequeToBankVw.SiRapReceivedCheque
         LEFT OUTER JOIN
         dbo.Tss_PubCustomCodes
         ON dbo.Tss_RapReceivedCheque.SiPubCustomCodes = dbo.Tss_PubCustomCodes.SiPubCustomCodes
GROUP BY dbo.Tss_PubCustomCodes.Des_CustomCodesDesc, Tss_PubPersonsViw_1.Cod_PubPersonCode, Tss_PubPersonsViw_1.Des_FullName, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeEndDate, dbo.Tss_RapReceivedCheque.Num_RapReceivedChequeAmount, dbo.Tss_RapReceivedCheque.Cod_RapReceivedChqBankCode, dbo.Tss_RapReceivedCheque.Cod_RapReceivedChequeSerial, dbo.Tss_RapReceivedCheque.SiRapReceivedCheque, dbo.Tss_RapReceivedCheque.Cod_RapReceivedChequeCode, Tss_PubPersonsViw_1.Des_FullName, Tss_PubPersonsViw_1.Cod_PubPersonCode, dbo.Tss_RapReceivedCheque.Des_RapReceivedChequeDesc, dbo.Tss_RapReceivedCheque.Des_RapReceivedChequeRecieptDesc, dbo.Tss_RapReceivedCheque.Sta_ChekRecieptMainOrNot, dbo.Tss_RapReceivedCheque.SiPubPersonsSpec, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeCngDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeVosoolDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeBargashtDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeCancelDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeToPerDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeToBankDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeHoghughiDate, dbo.Tss_RapReceivedCheque.SiPubSubLocations, dbo.Tss_RapReceivedCheque.SiRapCashDefine, dbo.Tss_RapReceivedCheque.SiPubCustomCodes, Tss_PubPersonsViw_2.Cod_PubPersonCode, Tss_PubPersonsViw_2.Des_FullName, Tss_PubPersonsViw_2.Cod_PubPersonCode, Tss_PubPersonsViw_2.Des_FullName, dbo.Tss_RapRecChequeToBankVw.Sta_CheckToBankState, dbo.Tss_RapReceivedCheque.Dat_EsterdadToPer, dbo.Tss_RapReceivedCheque.Dat_EsterdadToCashier, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeToAgainDate, dbo.Tss_RapReceivedCheque.SiRapRecievedChequeRef_RefrenceHd, dbo.Tss_RapReceivedCheque.SiRapBehalfDefineHd, dbo.Tss_RapReceivedCheque.Sta_CalcInReturnRep, dbo.Tss_RapReceivedCheque.Sta_RapReceivedChequeState, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeRegDate, Tss_PubPersonsViw_4.Cod_PubPersonCode, Tss_PubPersonsViw_4.Des_FullName, Tss_PubPersonsViw_2.SiPerRelatedSaler, dbo.Tss_RapReceivedCheque.Des_ReceivedChequeSayadiCode, dbo.Tss_RapReceivedCheque.Des_ReceivedChequeSayadiNationalCode, dbo.Tss_RapReceivedCheque.Sta_IsChecqueElectronic, dbo.Tss_RapReceivedCheque.Des_RecCheqOurSayadiNationalCode;


GO
ALTER PROCEDURE Tss_RapFrmRecievedChequeRepRStpAll
@SiPubSubLocations NUMERIC=0, @SiRapCashDefine NUMERIC=0, @SiPubPersonsSpec NUMERIC=0, @GhabzNo VARCHAR (50)='', @RegDate VARCHAR (10)='1404/01/01', @RegDate2 VARCHAR (10)='1404/12/29', @UsanceDate VARCHAR (10)='', @UsanceDate2 VARCHAR (10)='', @Dat_RapReceivedChequeVosoolDate VARCHAR (10)='', @Dat_RapReceivedChequeVosoolDate2 VARCHAR (10)='', @Dat_RapReceivedChequeBargashtDate VARCHAR (10)='', @Dat_RapReceivedChequeBargashtDate2 VARCHAR (10)='', @Dat_RapReceivedChequeToPerDate VARCHAR (10)='', @Dat_RapReceivedChequeToPerDate2 VARCHAR (10)='', @Dat_RapReceivedChequeToBankDate VARCHAR (10)='', @Dat_RapReceivedChequeToBankDate2 VARCHAR (10)='', @Dat_RapReceivedChequeHoghughiDate VARCHAR (10)='', @Dat_RapReceivedChequeHoghughiDate2 VARCHAR (10)='', @Dat_RapReceivedChequeCancelDate VARCHAR (10)='', @Dat_RapReceivedChequeCancelDate2 VARCHAR (10)='', @Dat_EsterdadToPer VARCHAR (10)='', @Dat_EsterdadToPer2 VARCHAR (10)='', @Dat_EsterdadToCashier VARCHAR (10)='', @Dat_EsterdadToCashier2 VARCHAR (10)='', @Dat_RapReceivedChequeToAgainDate VARCHAR (10)='', @Dat_RapReceivedChequeToAgainDate2 VARCHAR (10)='', @Sta_ChekRecieptMainOrNot SMALLINT=0, @Sta_RapReceivedChequeState VARCHAR (500)='1', @SiCheks VARCHAR (8000)='', @StaDateFilter SMALLINT=0, @SiUser NUMERIC=1, @SiToPer VARCHAR (1000)='', @SiRelatedPer VARCHAR (1000)='', @SayadiRegistered CHAR (1)='0', @NotSayadiRegistered CHAR (1)='0', @IsElectronic CHAR (1)='0', @IsSayadiInCartable CHAR (1)='0', @NotSayadiInCartable CHAR (1)='0', @StaSumPers SMALLINT=0
AS
DECLARE @SayadiSql AS VARCHAR (1000);
-- صیادی ثبت شده: مقدار معتبر و بزرگتر از صفر داشته باشد
IF @SayadiRegistered = '1'
   AND @NotSayadiRegistered = '0'
    SET @SayadiSql = 'AND (ISNULL(NULLIF(LTRIM(RTRIM(cheks1.Des_ReceivedChequeSayadiNationalCode)), ''''), ''0'') > ''0'')';
-- صیادی ثبت نشده: مقدار خالی، NULL یا صفر باشد
IF @SayadiRegistered = '0'
   AND @NotSayadiRegistered = '1'
    SET @SayadiSql = 'AND (ISNULL(NULLIF(LTRIM(RTRIM(cheks1.Des_ReceivedChequeSayadiNationalCode)), ''''), ''0'') = ''0'')';
IF @SayadiRegistered = '1'
   AND @NotSayadiRegistered = '1'
    SET @SayadiSql = '';
IF @SayadiRegistered = '0'
   AND @NotSayadiRegistered = '0'
    SET @SayadiSql = '';
IF @IsElectronic = '1'
    SET @SayadiSql = 'AND (isnull(cheks1.Sta_IsChecqueElectronic,''0'')=''1'')';
IF @IsSayadiInCartable = '1'
    SET @SayadiSql = 'AND (isnull(cheks1.Sta_SayadiReg,''0'')=''1'')';
IF @NotSayadiInCartable = '1'
    SET @SayadiSql = 'AND (isnull(cheks1.Sta_SayadiReg,''0'')=''0'')';
IF @GhabzNo = ''
    BEGIN
        DECLARE @SqlText AS VARCHAR (8000), @Whr AS VARCHAR (8000);
        -- Check if aggregation is needed
        IF @StaSumPers = 1
            BEGIN
                SET @SqlText = 'SELECT 
			CAST(NULL AS varchar(50)) AS GhabzNo,
			CAST(NULL AS varchar(200)) AS BankName,
			cheks1.GiverCode,
			cheks1.GiverName,
			CAST(NULL AS varchar(1)) AS RecieverCode,
			CAST(NULL AS varchar(1)) AS RecieverName,
			CAST(NULL AS varchar(10)) AS RegDate,
			CAST(NULL AS varchar(10)) AS UsanceDate,
			SUM(cheks1.ChequeAmount) AS ChequeAmount,
			CAST(NULL AS varchar(50)) AS BankBranchCode,
			CAST(NULL AS varchar(50)) AS ChequeSerial,
			CAST(NULL AS varchar(500)) AS Tozihat,
			CAST(NULL AS varchar(1500)) AS RecieptTozih,
			CAST(NULL AS smallint) AS Sta_ChekRecieptMainOrNot,
			CAST(NULL AS numeric(18,0)) AS SiRapReceivedCheque,
			CAST(NULL AS varchar(50)) AS ContractNo,
			CAST(NULL AS numeric(18,0)) AS SiPubPersonsSpec,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeCngDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeVosoolDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeBargashtDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeCancelDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeToPerDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeToBankDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeHoghughiDate,
			CAST(NULL AS numeric(18,0)) AS SiPubSubLocations,
			CAST(NULL AS smallint) AS Sta_RapReceivedChequeState,
			CAST(NULL AS numeric(18,0)) AS SiRapCashDefine,
			CAST(NULL AS numeric(18,0)) AS SiPubCustomCodes,
			CAST(NULL AS varchar(50)) AS Cod_PubPersonCode,
			CAST(NULL AS varchar(401)) AS Des_FullName,
			CAST(NULL AS varchar(50)) AS GirandehCode,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeToAgainDate,
			CAST(NULL AS varchar(50)) AS Dat_EsterdadToPer,
			CAST(NULL AS varchar(50)) AS Dat_EsterdadToCashier,
			CAST(NULL AS varchar(401)) AS GirandehDesc,
			CAST(NULL AS varchar(50)) AS Des_ReceivedChequeSayadiCode,
			CAST(NULL AS varchar(50)) AS Des_ReceivedChequeSayadiNationalCode,
			CAST(NULL AS varchar(50)) AS Des_RecCheqOurSayadiNationalCode,
			CAST(NULL AS smallint) AS Sta_IsChecqueElectronic
		FROM         
			Tss_RapRecCheckGhabzRep1Vw cheks1 LEFT OUTER JOIN
			Tss_RapRecCheckGhabzRep2Vw cheks2 ON cheks1.SiRapReceivedCheque = cheks2.SiRapReceivedCheque
		';
            END
        ELSE
            BEGIN
                SET @SqlText = 'select * from (SELECT   distinct  
			cheks1.GhabzNo, 
			cheks1.BankName, 
			cheks1.GiverCode, 
			cheks1.GiverName, 
			'''' RecieverCode, 
			'''' RecieverName, 
			cheks1.RegDate, 
			cheks1.UsanceDate, 
			cheks1.ChequeAmount, 
			cheks1.BankBranchCode, 
			cheks1.ChequeSerial, 
			cheks1.Tozihat, 
			cheks1.RecieptTozih, 
			cheks1.Sta_ChekRecieptMainOrNot, 
			cheks1.SiRapReceivedCheque, 
			cheks2.Cod_SaleAgreement AS ContractNo, 
			cheks1.SiPubPersonsSpec, 
			cheks1.Dat_RapReceivedChequeCngDate, 
			cheks1.Dat_RapReceivedChequeVosoolDate, 
			cheks1.Dat_RapReceivedChequeBargashtDate, 
			cheks1.Dat_RapReceivedChequeCancelDate, 
			cheks1.Dat_RapReceivedChequeToPerDate, 
			cheks1.Dat_RapReceivedChequeToBankDate, 
			cheks1.Dat_RapReceivedChequeHoghughiDate,
			cheks1.SiPubSubLocations, 
			cheks1.Sta_RapReceivedChequeState, 
			cheks1.SiRapCashDefine, 
			cheks1.SiPubCustomCodes, 
			cheks1.Cod_PubPersonCode, 
			cheks1.Des_FullName, 
			cheks1.GirandehCode, 
			cheks1.Dat_RapReceivedChequeToAgainDate, 
			cheks1.Dat_EsterdadToPer, 
			cheks1.Dat_EsterdadToCashier, 
			cheks1.GirandehDesc,
			cheks1.Des_ReceivedChequeSayadiCode,
			cheks1.Des_ReceivedChequeSayadiNationalCode,
			cheks1.Des_RecCheqOurSayadiNationalCode,
			cheks1.Sta_IsChecqueElectronic
		FROM         
			Tss_RapRecCheckGhabzRep1Vw cheks1 LEFT OUTER JOIN
			Tss_RapRecCheckGhabzRep2Vw cheks2 ON cheks1.SiRapReceivedCheque = cheks2.SiRapReceivedCheque
		';
            END
        SET @Whr = '';
        IF isnull(@SiPubSubLocations, 0) <> 0
            BEGIN
                SET @Whr = ' WHERE     
				     (cheks1.SiPubSubLocations = ' + CONVERT (VARCHAR, @SiPubSubLocations) + ') ';
                IF isnull(@SiPubPersonsSpec, 0) <> 0
                    SET @Whr = @Whr + ' AND  (cheks1.SiPubPersonsSpec = ' + CONVERT (VARCHAR, @SiPubPersonsSpec) + ') ';
            END
        ELSE
            BEGIN
                IF isnull(@SiPubPersonsSpec, 0) <> 0
                    SET @Whr = @Whr + ' Where  (cheks1.SiPubPersonsSpec = ' + CONVERT (VARCHAR, @SiPubPersonsSpec) + ') ';
                ELSE
                    SET @Whr = @Whr + ' Where ';
            END
        IF @SiToPer <> ''
            BEGIN
                IF isnull(@Whr, '') <> ' Where '
                    SET @Whr = @Whr + ' AND (cheks1.SiRapReceivedCheque in (SELECT SiRapReceivedCheque FROM Tss_RapRecChequeToBank WHERE (SiPubPersonsSpec IN (SELECT Sisel FROM dbo.Tss_StdStringSiFindUdf(' + '''' + @SiToPer + '''' + ')))))';
                ELSE
                    SET @Whr = @Whr + ' (cheks1.SiRapReceivedCheque in (SELECT SiRapReceivedCheque FROM Tss_RapRecChequeToBank WHERE (SiPubPersonsSpec IN (SELECT Sisel FROM dbo.Tss_StdStringSiFindUdf(' + '''' + @SiToPer + '''' + ')))))';
            END
        IF @SiRelatedPer <> ''
            BEGIN
                IF isnull(@Whr, '') <> ' Where '
                    SET @Whr = @Whr + ' AND (cheks1.SiPerRelatedSaler in  (SELECT Sisel FROM dbo.Tss_StdStringSiFindUdf(' + '''' + @SiRelatedPer + '''' + ')))';
                ELSE
                    SET @Whr = @Whr + ' (cheks1.SiPerRelatedSaler in  (SELECT Sisel FROM dbo.Tss_StdStringSiFindUdf(' + '''' + @SiRelatedPer + '''' + ')))';
            END
        IF (@Sta_RapReceivedChequeState <> '')
           AND (@Sta_RapReceivedChequeState <> '1')
            BEGIN
                IF isnull(@Whr, '') <> ' Where '
                    SET @Whr = @Whr + ' AND (cheks1.Sta_RapReceivedChequeState in (Select Sisel from dbo.Tss_StdStringSiFindUdf(' + '''' + @Sta_RapReceivedChequeState + '''' + ')))';
                ELSE
                    SET @Whr = @Whr + ' (cheks1.Sta_RapReceivedChequeState in (Select Sisel from dbo.Tss_StdStringSiFindUdf(' + '''' + @Sta_RapReceivedChequeState + '''' + ')))';
            END
        ELSE
            IF (@Sta_RapReceivedChequeState = '1')
                BEGIN
                    DECLARE @Condition AS NVARCHAR (MAX);
                    SET @Condition = 'cheks1.RegDate BETWEEN ''' + @RegDate + ''' AND ''' + @RegDate2 + ''' ' + 'AND (' + '(ISNULL(cheks1.Dat_RapReceivedChequeToPerDate, '''') <> '''' AND ' + 'cheks1.Dat_RapReceivedChequeToPerDate NOT BETWEEN ''' + @RegDate + ''' AND ''' + @RegDate2 + ''') ' + 'OR ' + '(ISNULL(cheks1.Dat_RapReceivedChequeToBankDate, '''') <> '''' AND ' + 'cheks1.Dat_RapReceivedChequeToBankDate NOT BETWEEN ''' + @RegDate + ''' AND ''' + @RegDate2 + ''') ' + 'OR ' + '(ISNULL(cheks1.Dat_RapReceivedChequeBargashtDate, '''') BETWEEN ''' + @RegDate + ''' AND ''' + @RegDate2 + ''') ' + 'OR ' + '(ISNULL(cheks1.Dat_RapReceivedChequeToAgainDate, '''') BETWEEN ''' + @RegDate + ''' AND ''' + @RegDate2 + ''')' + ')';
                    IF ISNULL(@Whr, '') <> ' Where '
                        SET @Whr = @Whr + ' AND ' + @Condition;
                    ELSE
                        SET @Whr = ' Where ' + @Condition;
                END
        IF @SiCheks <> ''
            SET @Whr = @Whr + ' AND (cheks1.SiRapReceivedCheque in (Select SiSel From dbo.Tss_StdStringSiFindUdf(' + '''' + @SiCheks + '''' + ')))';
        IF @StaDateFilter = 0
            BEGIN
                IF isnull(@Whr, '') <> ' Where '
                    SET @Whr = @Whr + ' AND (cheks1.RegDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
                ELSE
                    SET @Whr = @Whr + ' (cheks1.RegDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
            END
        IF @StaDateFilter = 1
            BEGIN
                IF isnull(@Whr, '') <> ' Where '
                    SET @Whr = @Whr + ' AND (cheks1.UsanceDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
                ELSE
                    SET @Whr = @Whr + ' (cheks1.UsanceDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
            END
        IF @StaDateFilter = 2
            BEGIN
                IF isnull(@Whr, '') <> ' Where '
                    SET @Whr = @Whr + ' AND (cheks1.Dat_RapReceivedChequeVosoolDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
                ELSE
                    SET @Whr = @Whr + ' (cheks1.Dat_RapReceivedChequeVosoolDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
            END
        IF @StaDateFilter = 3
            BEGIN
                IF isnull(@Whr, '') <> ' Where '
                    SET @Whr = @Whr + ' AND (cheks1.Dat_RapReceivedChequeBargashtDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
                ELSE
                    SET @Whr = @Whr + ' (cheks1.Dat_RapReceivedChequeBargashtDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
            END
        IF @StaDateFilter = 4
            BEGIN
                IF isnull(@Whr, '') <> ' Where '
                    SET @Whr = @Whr + ' AND (cheks1.Dat_RapReceivedChequeToPerDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
                ELSE
                    SET @Whr = @Whr + ' (cheks1.Dat_RapReceivedChequeToPerDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
            END
        IF @StaDateFilter = 5
            BEGIN
                IF isnull(@Whr, '') <> ' Where '
                    SET @Whr = @Whr + ' AND (cheks1.Dat_RapReceivedChequeToBankDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
                ELSE
                    SET @Whr = @Whr + ' (cheks1.Dat_RapReceivedChequeToBankDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
            END
        IF @StaDateFilter = 6
            BEGIN
                IF isnull(@Whr, '') <> ' Where '
                    SET @Whr = @Whr + ' AND (cheks1.Dat_RapReceivedChequeToAgainDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
                ELSE
                    SET @Whr = @Whr + ' (cheks1.Dat_RapReceivedChequeToAgainDate BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
            END
        IF @StaDateFilter = 7
            BEGIN
                IF isnull(@Whr, '') <> ' Where '
                    SET @Whr = @Whr + ' AND (cheks1.Dat_EsterdadToPer BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
                ELSE
                    SET @Whr = @Whr + ' (cheks1.Dat_EsterdadToPer BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
            END
        IF @StaDateFilter = 8
            BEGIN
                IF isnull(@Whr, '') <> ' Where '
                    SET @Whr = @Whr + ' AND (cheks1.Dat_EsterdadToCashier BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
                ELSE
                    SET @Whr = @Whr + ' (cheks1.Dat_EsterdadToCashier BETWEEN ' + '''' + @RegDate + '''' + ' AND ' + '''' + @RegDate2 + '''' + ')';
            END
        IF @SayadiSql <> ''
            SET @Whr = @Whr + @SayadiSql;
        -- Handle ORDER BY for aggregation
        IF @StaSumPers = 1
            BEGIN
                -- Add GROUP BY for GiverCode and GiverName
                SET @SqlText = @SqlText + @Whr + ' GROUP BY cheks1.GiverCode, cheks1.GiverName ORDER BY cheks1.GiverName';
            END
        ELSE
            BEGIN
                IF @Sta_ChekRecieptMainOrNot = 0
                    SET @SqlText = @SqlText + @Whr + ') ccc order by UsanceDate';
                IF @Sta_ChekRecieptMainOrNot = 1
                    SET @SqlText = @SqlText + @Whr + ') ccc order by Dat_RapReceivedChequeVosoolDate';
                IF @Sta_ChekRecieptMainOrNot = 2
                    SET @SqlText = @SqlText + @Whr + ') ccc order by Dat_RapReceivedChequeBargashtDate';
                IF @Sta_ChekRecieptMainOrNot = 3
                    SET @SqlText = @SqlText + @Whr + ') ccc order by Dat_RapReceivedChequeToPerDate';
                IF @Sta_ChekRecieptMainOrNot = 4
                    SET @SqlText = @SqlText + @Whr + ') ccc order by Dat_RapReceivedChequeToBankDate';
                IF @Sta_ChekRecieptMainOrNot = 5
                    SET @SqlText = @SqlText + @Whr + ') ccc order by Dat_RapReceivedChequeToAgainDate';
                IF @Sta_ChekRecieptMainOrNot = 6
                    SET @SqlText = @SqlText + @Whr + ') ccc order by Dat_EsterdadToPer';
                IF @Sta_ChekRecieptMainOrNot = 7
                    SET @SqlText = @SqlText + @Whr + ') ccc order by Dat_EsterdadToCashier';
                IF @Sta_ChekRecieptMainOrNot = 8
                    SET @SqlText = @SqlText + @Whr + ') ccc order by RegDate';
            END
        IF @SayadiSql <> ''
            IF @Whr <> ''
                SET @Whr = @Whr + ' and  (SiPubSubLocations in  (SELECT DISTINCT 
		Tss_AccFinancePeriodToPlace.SiPubSubLocations
	FROM         
		Tss_AccUserToFinancePeriodAndPlace INNER JOIN
		Tss_AccFinancePeriodToPlace ON 
		Tss_AccUserToFinancePeriodAndPlace.SiAccFinancePeriodToPlace = Tss_AccFinancePeriodToPlace.SiAccFinancePeriodToPlace
	WHERE     
		(Tss_AccUserToFinancePeriodAndPlace.SiPubPersonsSpec = ' + CONVERT (VARCHAR, @SiUser) + ')))';
            ELSE
                SET @Whr = @Whr + ' where  (SiPubSubLocations in  (SELECT DISTINCT 
		Tss_AccFinancePeriodToPlace.SiPubSubLocations
	FROM         
		Tss_AccUserToFinancePeriodAndPlace INNER JOIN
		Tss_AccFinancePeriodToPlace ON 
		Tss_AccUserToFinancePeriodAndPlace.SiAccFinancePeriodToPlace = Tss_AccFinancePeriodToPlace.SiAccFinancePeriodToPlace
	WHERE     
		(Tss_AccUserToFinancePeriodAndPlace.SiPubPersonsSpec = @' + CONVERT (VARCHAR, @SiUser) + ')))';
        PRINT @SqlText;
        EXECUTE (@SqlText);
    END
ELSE
    BEGIN
        -- Handle the ELSE block when @GhabzNo is not empty
        IF @StaSumPers = 1
            BEGIN
                SELECT   CAST (NULL AS VARCHAR (50)) AS GhabzNo,
                         CAST (NULL AS VARCHAR (200)) AS BankName,
                         cheks1.GiverCode,
                         cheks1.GiverName,
                         CAST (NULL AS VARCHAR (1)) AS RecieverCode,
                         CAST (NULL AS VARCHAR (1)) AS RecieverName,
                         CAST (NULL AS VARCHAR (10)) AS RegDate,
                         CAST (NULL AS VARCHAR (10)) AS UsanceDate,
                         SUM(cheks1.ChequeAmount) AS ChequeAmount,
                         CAST (NULL AS VARCHAR (50)) AS BankBranchCode,
                         CAST (NULL AS VARCHAR (50)) AS ChequeSerial,
                         CAST (NULL AS VARCHAR (500)) AS Tozihat,
                         CAST (NULL AS VARCHAR (1500)) AS RecieptTozih,
                         CAST (NULL AS SMALLINT) AS Sta_ChekRecieptMainOrNot,
                         CAST (NULL AS NUMERIC (18, 0)) AS SiRapReceivedCheque,
                         CAST (NULL AS VARCHAR (50)) AS ContractNo,
                         CAST (NULL AS NUMERIC (18, 0)) AS SiPubPersonsSpec,
                         CAST (NULL AS VARCHAR (10)) AS Dat_RapReceivedChequeCngDate,
                         CAST (NULL AS VARCHAR (10)) AS Dat_RapReceivedChequeVosoolDate,
                         CAST (NULL AS VARCHAR (10)) AS Dat_RapReceivedChequeBargashtDate,
                         CAST (NULL AS VARCHAR (10)) AS Dat_RapReceivedChequeCancelDate,
                         CAST (NULL AS VARCHAR (10)) AS Dat_RapReceivedChequeToPerDate,
                         CAST (NULL AS VARCHAR (10)) AS Dat_RapReceivedChequeToBankDate,
                         CAST (NULL AS VARCHAR (10)) AS Dat_RapReceivedChequeHoghughiDate,
                         CAST (NULL AS NUMERIC (18, 0)) AS SiPubSubLocations,
                         CAST (NULL AS SMALLINT) AS Sta_RapReceivedChequeState,
                         CAST (NULL AS NUMERIC (18, 0)) AS SiRapCashDefine,
                         CAST (NULL AS NUMERIC (18, 0)) AS SiPubCustomCodes,
                         CAST (NULL AS VARCHAR (50)) AS Cod_PubPersonCode,
                         CAST (NULL AS VARCHAR (401)) AS Des_FullName,
                         CAST (NULL AS VARCHAR (50)) AS GirandehCode,
                         CAST (NULL AS VARCHAR (10)) AS Dat_RapReceivedChequeToAgainDate,
                         CAST (NULL AS VARCHAR (50)) AS Dat_EsterdadToPer,
                         CAST (NULL AS VARCHAR (50)) AS Dat_EsterdadToCashier,
                         CAST (NULL AS VARCHAR (401)) AS GirandehDesc,
                         CAST (NULL AS VARCHAR (50)) AS Des_ReceivedChequeSayadiCode,
                         CAST (NULL AS VARCHAR (50)) AS Des_ReceivedChequeSayadiNationalCode,
                         CAST (NULL AS SMALLINT) AS Sta_IsChecqueElectronic
                FROM     Tss_RapRecCheckGhabzRep1Vw AS cheks1
                         LEFT OUTER JOIN
                         Tss_RapRecCheckGhabzRep2Vw AS cheks2
                         ON cheks1.SiRapReceivedCheque = cheks2.SiRapReceivedCheque
                WHERE    (cheks1.Sta_CheckToBankState <> 4)
                         AND (cheks1.Sta_CheckToBankState <> 3)
                         AND (cheks1.GhabzNo = @GhabzNo)
                         AND (cheks1.Sta_ChekRecieptMainOrNot = @Sta_ChekRecieptMainOrNot)
                GROUP BY cheks1.GiverCode, cheks1.GiverName
                ORDER BY cheks1.GiverName;
            END
        ELSE
            BEGIN
                SELECT DISTINCT cheks1.GhabzNo,
                                cheks1.BankName,
                                '' AS GiverCode,
                                '' AS GiverName,
                                cheks1.RecieverCode,
                                cheks1.RecieverName,
                                cheks1.RegDate,
                                cheks1.UsanceDate,
                                cheks1.ChequeAmount,
                                cheks1.BankBranchCode,
                                cheks1.ChequeSerial,
                                cheks1.Tozihat,
                                cheks1.RecieptTozih,
                                cheks1.Sta_ChekRecieptMainOrNot,
                                cheks1.SiRapReceivedCheque,
                                cheks2.Cod_SaleAgreement AS ContractNo,
                                cheks1.SiPubPersonsSpec,
                                cheks1.Dat_RapReceivedChequeCngDate,
                                cheks1.Dat_RapReceivedChequeVosoolDate,
                                cheks1.Dat_RapReceivedChequeBargashtDate,
                                cheks1.Dat_RapReceivedChequeCancelDate,
                                cheks1.Dat_RapReceivedChequeToPerDate,
                                cheks1.Dat_RapReceivedChequeToBankDate,
                                cheks1.Dat_RapReceivedChequeHoghughiDate,
                                cheks1.SiPubSubLocations,
                                cheks1.Sta_RapReceivedChequeState,
                                cheks1.SiRapCashDefine,
                                cheks1.SiPubCustomCodes,
                                cheks1.Cod_PubPersonCode,
                                cheks1.Des_FullName,
                                cheks1.GirandehCode,
                                cheks1.GirandehDesc,
                                cheks1.Dat_EsterdadToCashier,
                                cheks1.Dat_EsterdadToPer,
                                cheks1.Des_ReceivedChequeSayadiCode,
                                cheks1.Des_ReceivedChequeSayadiNationalCode,
                                cheks1.Dat_RapReceivedChequeToAgainDate,
                                cheks1.Sta_IsChecqueElectronic
                FROM   Tss_RapRecCheckGhabzRep1Vw AS cheks1
                       LEFT OUTER JOIN
                       Tss_RapRecCheckGhabzRep2Vw AS cheks2
                       ON cheks1.SiRapReceivedCheque = cheks2.SiRapReceivedCheque
                WHERE  (cheks1.Sta_CheckToBankState <> 4)
                       AND (cheks1.Sta_CheckToBankState <> 3)
                       AND (cheks1.GhabzNo = @GhabzNo)
                       AND (cheks1.Sta_ChekRecieptMainOrNot = @Sta_ChekRecieptMainOrNot);
            END
    END


GO
ALTER PROCEDURE Tss_AccUntDailyDafDetailedPreRepVStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)='', @DsStart VARCHAR (10)='1402/01/01', @DsEnd VARCHAR (10)='1402/01/05', @SiAccCodeBook VARCHAR (8000)='', @Desc VARCHAR (500)='', @TafDesc VARCHAR (500)='', @MoeinCode VARCHAR (500)='', @MoeinDesc VARCHAR (500)='', @BedAmountFilter VARCHAR (500)='', @BesAmountFilter VARCHAR (500)='', @StaFtet SMALLINT=1, @StaEkhtem SMALLINT=0, @StavClose SMALLINT=0, @SiFinProd NUMERIC=14, @SiSubLoc VARCHAR (500)='1,2,3,4,5,6,7,8,9,10', @SiUser NUMERIC=1
AS
SET XACT_ABORT ON;
IF @InternalWhere <> ''
    SET @InternalWhere = ' Where ' + @InternalWhere;
IF @Where <> ''
    SET @Where = ' Where ' + @Where;
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
ELSE
    SET @Order = ' Order By KolCode,MoeinCode' + @Order;
SELECT SiAccFinancePeriodToPlace
INTO   #TempTable
FROM   dbo.Tss_AccFinancePeriodToPlace
WHERE  --	(SiAccFinancePeriod=@SiFinProd) And
(SiPubSubLocations IN (SELECT *
                       FROM   dbo.Tss_StdStringSiFindUdf(@SiSubLoc)));
DECLARE @SqlTxt AS VARCHAR (8000), @WhSi AS VARCHAR (200);
SET @SqlTxt = 'Select 
		SiAccCodeBook, 
		SiPubPersonsSpec1, 
		SiPubCostCenter1, 
		Num_VhedFinalNo,
		Num_VhedSubNo,
		Sta_VdetDebtOrCredit, 
		Dat_AccVoucherDetDate,
		SiAccVoucher_Dt, 
		SiAccVoucher_Hd, 
		Des_VdetDesc, 
		Num_VdetDebtAmount, 
		Num_VdetCreditAmount, 
		Dat_VhedDate, 
		Cod_AccountCodeTot, 
		GroupCode, 
		KolCode, 
		MoeinCode, 
		Cod_PubPersonCode, 
		Cod_CostCenterCode, 
		Cod_AccFinancePeriod, 
		Des_AccFinancePeriod, 
		Cod_SubLocCode, 
		Des_SubLocName, 
		Num_VdetAmount, 
		Num_VDetRow, 
		Des_CostCenterName, 
		Cod_VoucherType, 
		Des_VoucherType, 
		Des_AccountDesc, 
		Des_AccountFullDesc, 
		Des_FullName,
		Cod1,
		Cod2,
		Cod3,
		SiRelatedSenderSerial,
		Case
			When  Num_VdetDebtAmount>Num_VdetCreditAmount then Num_VdetDebtAmount-Num_VdetCreditAmount
			When  Num_VdetDebtAmount<Num_VdetCreditAmount then 0
		End sRestBed,
		Case
			When  Num_VdetDebtAmount>Num_VdetCreditAmount then 0
			When  Num_VdetDebtAmount<Num_VdetCreditAmount then Num_VdetCreditAmount-Num_VdetDebtAmount
		End sRestBes,
		case 
			when isnull(Cod_PubPersonCode,'''')<>'''' then Cod_PubPersonCode 
			when isnull(Cod_CostCenterCode,'''')<>'''' then Cod_CostCenterCode 
		end as CodTaf,
		case 
			when isnull(Des_SubLocName,'''')<>'''' then Des_SubLocName 
			when isnull(Des_CostCenterName,'''')<>'''' then Des_CostCenterName 
		end as DesTaf
	From 
	   (
	   Select * From 
	(
	SELECT TOP 100 PERCENT 
		(SELECT Des_AccountDesc FROM Tss_AccCodeBook WHERE (Cod_AccountCode IN (SELECT LEFT(Cod_AccountCode, 2) FROM Tss_AccCodeBook WHERE (SiAccCodeBook = Tss_AccVoucher_Dt.SiAccCodeBook)))) Cod1,
		(SELECT Des_AccountDesc FROM Tss_AccCodeBook WHERE (Cod_AccountCode IN (SELECT LEFT(Cod_AccountCode, 4) FROM Tss_AccCodeBook WHERE (SiAccCodeBook = Tss_AccVoucher_Dt.SiAccCodeBook)))) Cod2,
		(SELECT Des_AccountDesc FROM Tss_AccCodeBook WHERE (Cod_AccountCode IN (SELECT LEFT(Cod_AccountCode, 6) FROM Tss_AccCodeBook WHERE (SiAccCodeBook = Tss_AccVoucher_Dt.SiAccCodeBook)))) Cod3,
		Tss_AccVoucher_Dt.SiAccVoucher_Dt, 
		Tss_AccVoucher_Dt.SiAccVoucher_Hd, 
		Tss_AccVoucher_Dt.Des_VdetDesc, 
		Tss_AccVoucher_Dt.Num_VdetDebtAmount, 
		Tss_AccVoucher_Dt.Num_VdetCreditAmount, 
		Tss_AccVoucher_Hd.Dat_VhedDate, 
		Tss_AccVoucher_Hd.Num_VhedFinalNo,
		Tss_AccVoucher_Hd.Num_VhedSubNo,
		Tss_AccCodeBook.Cod_AccountCode as Cod_AccountCodeTot, 
		SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 1, 2) AS GroupCode, 
		SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 1, 2) + SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 3, 2) AS KolCode, 
		SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 1, 2) + SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 3, 2) + SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 5, 2) AS MoeinCode, 
		Tss_PubPersonsViw.Cod_PubPersonCode, 
		Tss_PubCostCenter.Cod_CostCenterCode, 
		Tss_AccFinancePeriod.Cod_AccFinancePeriod, 
		Tss_AccFinancePeriod.Des_AccFinancePeriod, 
		Tss_PubSubLocations.Cod_SubLocCode, 
		Tss_PubSubLocations.Des_SubLocName, 
		Tss_AccVoucher_Dt.Num_VdetAmount, 
		Tss_AccVoucher_Dt.Num_VDetRow, 
		Tss_PubCostCenter.Des_CostCenterName, 
		Tss_AccVoucherType.Cod_VoucherType, 
		Tss_AccVoucherType.Des_VoucherType, 
		Tss_AccCodeBook.Des_AccountDesc, 
		Tss_AccCodeBook.Des_AccountFullDesc, 
		Tss_PubPersonsViw.Des_FullName, 

		Tss_AccVoucher_Dt.SiAccCodeBook, 
		Tss_AccVoucher_Dt.SiPubPersonsSpec1, 
		Tss_AccVoucher_Dt.SiPubCostCenter1, 
		Tss_AccVoucher_Dt.Sta_VdetDebtOrCredit, 
		Tss_AccVoucher_Dt.Dat_AccVoucherDetDate,
		Tss_AccVoucher_Dt.SiRelatedSenderSerial
	FROM         
		Tss_AccVoucher_Dt INNER JOIN
		Tss_AccVoucher_Hd ON Tss_AccVoucher_Dt.SiAccVoucher_Hd = Tss_AccVoucher_Hd.SiAccVoucher_Hd INNER JOIN
		Tss_AccCodeBook ON Tss_AccVoucher_Dt.SiAccCodeBook = Tss_AccCodeBook.SiAccCodeBook INNER JOIN
		Tss_AccFinancePeriodToPlace ON 
		Tss_AccVoucher_Hd.SiAccFinancePeriodToPlace = Tss_AccFinancePeriodToPlace.SiAccFinancePeriodToPlace INNER JOIN
		Tss_AccFinancePeriod ON Tss_AccFinancePeriodToPlace.SiAccFinancePeriod = Tss_AccFinancePeriod.SiAccFinancePeriod INNER JOIN
		Tss_PubSubLocations ON Tss_AccFinancePeriodToPlace.SiPubSubLocations = Tss_PubSubLocations.SiPubSubLocations INNER JOIN
		Tss_AccVoucherType ON Tss_AccVoucher_Hd.SiAccVoucherType = Tss_AccVoucherType.SiAccVoucherType LEFT OUTER JOIN
		Tss_PubCostCenter ON Tss_AccVoucher_Dt.SiPubCostCenter1 = Tss_PubCostCenter.SiPubCostCenter LEFT OUTER JOIN
		Tss_PubPersonsViw ON Tss_AccVoucher_Dt.SiPubPersonsSpec1 = Tss_PubPersonsViw.SiPubPersonsSpec		
	WHERE     
		(dbo.Tss_AccVoucher_Hd.Dat_VhedDate BETWEEN ' + '''' + @DsStart + '''' + ' AND ' + '''' + @DsEnd + '''' + ') And
		(dbo.Tss_AccVoucher_Hd.SiAccFinancePeriodToPlace in (select * from #TempTable))';
IF Isnull(@Desc, '') <> ''
    SET @SqlTxt = @SqlTxt + ' and (Des_VdetDesc like ' + '''' + '%' + @Desc + '%' + '''' + ')';
IF Isnull(@TafDesc, '') <> ''
    SET @SqlTxt = @SqlTxt + ' and (Des_FullName like ' + '''' + '%' + @TafDesc + '%' + '''' + ')';
IF Isnull(@MoeinCode, '') <> ''
    SET @SqlTxt = @SqlTxt + ' and (SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 1, 2) + SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 3, 2) + SUBSTRING(Tss_AccCodeBook.Cod_AccountCode, 5, 2) like ' + '''' + '%' + @MoeinCode + '%' + '''' + ')';
IF Isnull(@MoeinDesc, '') <> ''
    SET @SqlTxt = @SqlTxt + ' and (Des_AccountFullDesc like ' + '''' + '%' + @MoeinDesc + '%' + '''' + ')';
IF Isnull(@BedAmountFilter, '') <> ''
    SET @SqlTxt = @SqlTxt + ' and (Num_VdetDebtAmount like ' + '''' + '%' + @BedAmountFilter + '%' + '''' + ')';
IF Isnull(@BesAmountFilter, '') <> ''
    SET @SqlTxt = @SqlTxt + ' and (Num_VdetCreditAmount like ' + '''' + '%' + @BesAmountFilter + '%' + '''' + ')';
SET @WhSi = '';
IF @StaFtet = 0
    SELECT @WhSi = CONVERT (VARCHAR, SiAccVoucherType)
    FROM   Tss_AccVoucherType
    WHERE  (Sta_VoucherTypeGroup = 0);
IF @StaEkhtem = 0
    IF @WhSi = ''
        SELECT @WhSi = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
    ELSE
        SELECT @WhSi = @WhSi + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
IF @StavClose = 0
    IF @WhSi = ''
        SELECT @WhSi = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
    ELSE
        SELECT @WhSi = @WhSi + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
IF @WhSi <> ''
    BEGIN
        SET @WhSi = ' And (Not (dbo.Tss_AccVoucher_Hd.SiAccVoucherType in (' + @WhSi + ')))';
        SET @SqlTxt = @SqlTxt + Char(10) + @WhSi;
    END
-- Hide hidden voucher lines from users who are not in the AccStar group
IF dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'AccStar') <> 1
    SET @SqlTxt = @SqlTxt + ' And (Tss_AccVoucher_Dt.Sta_IsHidden = 0 OR Tss_AccVoucher_Dt.Sta_IsHidden IS NULL)';
SET @SqlTxt = @SqlTxt + ') Ccc ';
IF Isnull(@SiAccCodeBook, 0) > 0
    SET @SqlTxt = @SqlTxt + 'Where (SiAccCodeBook = ' + CONVERT (VARCHAR, @SiAccCodeBook) + ')';
PRINT @SqlTxt;
EXECUTE (@SqlTxt + ' ' + @InternalWhere + ') CalcSel ' + @Where + @Order);


GO
ALTER PROCEDURE Tss_AccUntAccountReviewTafsilRStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)='', @DsFromDate VARCHAR (10)='1390/01/01', @DsToDate VARCHAR (10)='1397/12/29', @SiAccFinancePeriod NUMERIC=9, @SiPubSubLocations VARCHAR (500)='1,2', @Sta_Start SMALLINT=0, @Sta_End SMALLINT=0, @Sta_Close SMALLINT=0, @FlgLevel SMALLINT=4, @Cod_AccountCode VARCHAR (50)='611012', @StaBaMandeh SMALLINT=0, @SiUser NUMERIC=1
AS
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_NULLS ON;
SET ANSI_NULL_DFLT_ON ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET QUOTED_IDENTIFIER ON;
IF @InternalWhere <> ''
    SET @InternalWhere = ' Where ' + @InternalWhere;
IF @Where <> ''
    SET @Where = ' Where ' + @Where;
-- Fixed ORDER BY to avoid conversion errors
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
ELSE
    SET @Order = ' Order By CASE WHEN ISNUMERIC(TafCode)=1 THEN convert(numeric, TafCode) ELSE 999999 END';
DECLARE @WhType AS VARCHAR (20), @SqlTxt AS VARCHAR (8000), @Sta_TafType1 AS SMALLINT, @SiAccCodeBook AS NUMERIC, @AccAllDocs AS SMALLINT;
SELECT @AccAllDocs = dbo.Tss_StdFindSystemParamValue('AccAllDocs');
-- Hide hidden voucher lines from users who are not in the AccStar group
DECLARE @HiddenFilter AS VARCHAR (200);
IF dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'AccStar') = 1
    SET @HiddenFilter = '';
ELSE
    SET @HiddenFilter = ' AND (vDet.Sta_IsHidden = 0 OR vDet.Sta_IsHidden IS NULL) ';
SELECT SiAccFinancePeriodToPlace
INTO   #TempTable
FROM   dbo.Tss_AccFinancePeriodToPlace
WHERE  (SiPubSubLocations IN (SELECT *
                              FROM   dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations)));
SELECT @Sta_TafType1 = Sta_TafType1,
       @SiAccCodeBook = SiAccCodeBook
FROM   dbo.Tss_AccCodeBook AS cBook
WHERE  (Cod_AccountCode = @Cod_AccountCode);
SET @WhType = '';
IF @Sta_Start = 0
    SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
    FROM   Tss_AccVoucherType
    WHERE  (Sta_VoucherTypeGroup = 0);
IF @Sta_End = 0
    IF @WhType = ''
        SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
    ELSE
        SELECT @WhType = @WhType + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 1);
IF @Sta_Close = 0
    IF @WhType = ''
        SELECT @WhType = CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
    ELSE
        SELECT @WhType = @WhType + ',' + CONVERT (VARCHAR, SiAccVoucherType)
        FROM   Tss_AccVoucherType
        WHERE  (Sta_VoucherTypeGroup = 3);
IF @Sta_TafType1 = 1
    BEGIN
        SET @SqlTxt = '
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Acc_Bed,
      Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
		Des_CodeDescription
   From
   (
      SELECT     
         dbo.Tss_PubPersonsViw.Cod_PubPersonCode TafCode, 
         dbo.Tss_PubPersonsViw.Des_FullName TafDesc,
         dbo.Tss_PubPersonsViw.SiPubPersonsSpec as SiTaf,
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount,
			'''' Des_VdetDesc,
			'''' Dat_AccVoucherDetDate,
			$0.0 Num_VdetAmount,
			dbo.Tss_PubPersonsViw.Des_CodeDescription
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubPersonsViw ON vDet.SiPubPersonsSpec1 = dbo.Tss_PubPersonsViw.SiPubPersonsSpec
      WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND 
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND 
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        SET @SqlTxt = @SqlTxt + @HiddenFilter;
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = @SqlTxt + ' ) Ddd ';
        SET @SqlTxt = @SqlTxt + ' Group By TafCode, TafDesc, SiTaf, Des_VdetDesc, Dat_AccVoucherDetDate, Num_VdetAmount, Des_CodeDescription ) Dd2 ';
    END
IF @Sta_TafType1 = 2
    BEGIN
        SET @SqlTxt = '
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Acc_Bed,
      Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
		Des_CodeDescription
   From
   (
      SELECT     
         dbo.Tss_PubCostCenter.Cod_CostCenterCode TafCode,  
         dbo.Tss_PubCostCenter.Des_CostCenterName TafDesc,
         dbo.Tss_PubCostCenter.SiPubCostCenter as SiTaf,
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount,
			'''' Des_VdetDesc,
			'''' Dat_AccVoucherDetDate,
			$0.0 Num_VdetAmount,
			dbo.Tss_PubCostCenter.Des_CodeDescription
      FROM   
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubCostCenter ON vDet.SiPubCostCenter1 = dbo.Tss_PubCostCenter.SiPubCostCenter
      WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
	      (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
	      (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        SET @SqlTxt = @SqlTxt + @HiddenFilter;
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = @SqlTxt + ' ) Ddd
   Group By TafCode, TafDesc, SiTaf, Des_VdetDesc, Dat_AccVoucherDetDate, Num_VdetAmount, Des_CodeDescription ) Dd2';
    END
IF @Sta_TafType1 = 3
    BEGIN
        SET @SqlTxt = '
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Acc_Bed,
      Acc_Bes,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		'''' as Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes
   From
   (
      SELECT     
         dbo.Tss_PubProjects.Cod_ProjectsCode TafCode,  
         dbo.Tss_PubProjects.Des_ProjectsThemeDesc TafDesc,
         dbo.Tss_PubProjects.SiPubProjects as SiTaf,
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount 
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubProjects ON vDet.SiPubProjects1 = dbo.Tss_PubProjects.SiPubProjects
      WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        SET @SqlTxt = @SqlTxt + @HiddenFilter;
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = @SqlTxt + ' ) Ddd
   Group By TafCode, TafDesc, SiTaf ) Dd2';
    END
IF @Sta_TafType1 = 4
    BEGIN
        SET @SqlTxt = '
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Acc_Bed,
      Acc_Bes,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		'''' Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes
   From
   (
      SELECT     
         dbo.Tss_PurOrder_Hd.Cod_PurOrderCode TafCode,  
         dbo.Tss_PurOrder_Hd.Des_PurOrderDesc TafDesc,
         dbo.Tss_PurOrder_Hd.SiPurOrder_Hd as SiTaf,
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount 
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PurOrder_Hd ON vDet.SiPurOrder_Hd1 = dbo.Tss_PurOrder_Hd.SiPurOrder_Hd
      WHERE ';
        IF @AccAllDocs = 0
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        ELSE
            SET @SqlTxt = @SqlTxt + '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between ' + '''' + @DsFromDate + '''' + ' And ' + '''' + @DsToDate + '''' + ') AND
         (vDet.SiAccCodeBook = ' + Str(@SiAccCodeBook) + ')';
        SET @SqlTxt = @SqlTxt + @HiddenFilter;
        IF @WhType <> ''
            SET @SqlTxt = @SqlTxt + ' AND (vHed.SiAccVoucherType Not In (' + @WhType + '))';
        SET @SqlTxt = @SqlTxt + ' ) Ddd
   Group By TafCode, TafDesc, SiTaf ) Dd2';
    END
-- If @Sta_TafType1=0, return NULL for SiTaf
IF @Sta_TafType1 = 0
    BEGIN
        SET @SqlTxt = '
   Select 
      '''' TafCode,
      '''' TafDesc,
      NULL as SiTaf,
      convert(numeric,0) Acc_Bed,
      convert(numeric,0) Acc_Bes,
      convert(numeric,0) Rst_Bed,
      convert(numeric,0) Rst_Bes,
      '''' Des_VdetDesc,
      '''' Dat_AccVoucherDetDate,
      convert(numeric,0) Num_VdetAmount,
      '''' RelatedSaler,
      '''' Des_CodeDescription
   ';
    END
PRINT @SqlTxt;
IF @Sta_TafType1 <> 0
    EXECUTE ('Select * From
(
   Select * From
   ( ' + @SqlTxt + ' ) Ccc  ' + @InternalWhere + '
) CalcSel ' + @Where + @Order);
ELSE
    EXECUTE (@SqlTxt);


GO
ALTER PROCEDURE dbo.Tss_AccUntTafsiliReview_03VStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)='', @DsFromDate VARCHAR (10)='1399/01/01', @DsToDate VARCHAR (10)='1399/09/07', @SiAccFinancePeriod NUMERIC=20, @SiPubSubLocations VARCHAR (500)='1,2', @Sta_Start SMALLINT=0, @Sta_End SMALLINT=0, @Sta_Close SMALLINT=0, @StaMandehOrNot SMALLINT=1, @SiAccCodeBook VARCHAR (MAX)='', @SiSelected VARCHAR (50)='', @SiUser NUMERIC=1, @AccCodePrefix VARCHAR (MAX)='', @FlgTafType SMALLINT=-1, @TafSelected VARCHAR (MAX)=''
AS
BEGIN
    SET NOCOUNT ON;
    SET ANSI_NULL_DFLT_ON, ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER, XACT_ABORT ON;
    DROP TABLE IF EXISTS #TmpVchTaf;
    DROP TABLE IF EXISTS #TmpVchTafMandeh;
    DROP TABLE IF EXISTS #TmpVchTafBaBiMandeh;
    DROP TABLE IF EXISTS #TempTable;
    DROP TABLE IF EXISTS #Pfx;
    DROP TABLE IF EXISTS #Taf;
    SET @InternalWhere = CASE WHEN @InternalWhere IS NOT NULL
                                   AND @InternalWhere <> '' THEN ' WHERE ' + @InternalWhere ELSE '' END;
    SET @Where = CASE WHEN @Where IS NOT NULL
                           AND @Where <> '' THEN ' WHERE ' + @Where ELSE '' END;
    SET @Order = CASE WHEN @Order IS NOT NULL
                           AND @Order <> '' THEN ' ORDER BY ' + @Order ELSE '' END;
    -- Build voucher-type exclusion list
    DECLARE @WhType AS VARCHAR (300) = CASE WHEN @Sta_Start = 0 THEN (SELECT STRING_AGG(SiAccVoucherType, ',')
                                                                      FROM   Tss_AccVoucherType
                                                                      WHERE  Sta_VoucherTypeGroup = 0) ELSE '' END;
    SET @WhType = ISNULL(@WhType, '') + CASE WHEN @Sta_End = 0
                                                  AND @WhType <> '' THEN ',' ELSE '' END + CASE WHEN @Sta_End = 0 THEN ISNULL((SELECT STRING_AGG(SiAccVoucherType, ',')
                                                                                                                               FROM   Tss_AccVoucherType
                                                                                                                               WHERE  Sta_VoucherTypeGroup = 1), '') ELSE '' END;
    SET @WhType = @WhType + CASE WHEN @Sta_Close = 0
                                      AND @WhType <> '' THEN ',' ELSE '' END + CASE WHEN @Sta_Close = 0 THEN ISNULL((SELECT STRING_AGG(SiAccVoucherType, ',')
                                                                                                                     FROM   Tss_AccVoucherType
                                                                                                                     WHERE  Sta_VoucherTypeGroup = 3), '') ELSE '' END;
    SET @WhType = CASE WHEN @WhType <> '' THEN ' AND vHed.SiAccVoucherType NOT IN (' + @WhType + ')' ELSE '' END;
    -- Determine which tafsil column to filter on
    DECLARE @TafName AS VARCHAR (100) = CASE @FlgTafType WHEN 0 THEN 'SiPubPersonsSpec1' WHEN 1 THEN 'SiPubCostCenter1' WHEN 2 THEN 'SiPubProjects1' ELSE CASE (SELECT TOP 1 Sta_TafType1
                                                                                                                                                                FROM   Tss_AccCodeBook
                                                                                                                                                                WHERE  SiAccCodeBook = (SELECT TOP 1 SiSel
                                                                                                                                                                                        FROM   dbo.Tss_StdStringSiFindUdf(@SiAccCodeBook))) WHEN 1 THEN 'SiPubPersonsSpec1' WHEN 2 THEN 'SiPubCostCenter1' WHEN 3 THEN 'SiPubProjects1' WHEN 4 THEN 'SiPurOrder_Hd1' END END;
    -- Account-code prefixes
    SELECT LTRIM(RTRIM(value)) AS Pfx
    INTO   #Pfx
    FROM   dbo.Tss_StdStringSplitUdf(ISNULL(@AccCodePrefix, ''), ',')
    WHERE  LTRIM(RTRIM(value)) <> '';
    -- Tafsil selection pairs (type:si)
    SELECT TRY_CAST (LEFT(v, CHARINDEX(':', v) - 1) AS INT) AS TafType,
           TRY_CAST (SUBSTRING(v, CHARINDEX(':', v) + 1, 30) AS NUMERIC (18, 0)) AS SiTaf
    INTO   #Taf
    FROM   (SELECT LTRIM(RTRIM(value)) AS v
            FROM   dbo.Tss_StdStringSplitUdf(ISNULL(@TafSelected, ''), ',')) AS s
    WHERE  v LIKE '%:%';
    DECLARE @AccFilter AS VARCHAR (MAX) = '';
    IF EXISTS (SELECT 1
               FROM   #Pfx)
        SET @AccFilter = ' AND EXISTS (SELECT 1 FROM #Pfx p WHERE cBook.Cod_AccountCode LIKE p.Pfx + ''%'')';
    ELSE
        IF ISNULL(@SiAccCodeBook, '') <> ''
            SET @AccFilter = ' AND cBook.SiAccCodeBook IN (SELECT SiSel FROM dbo.Tss_StdStringSiFindUdf(''' + @SiAccCodeBook + '''))';
    DECLARE @TafFilter AS VARCHAR (1000) = '';
    IF EXISTS (SELECT 1
               FROM   #Taf)
        SET @TafFilter = ' AND EXISTS (SELECT 1 FROM #Taf t WHERE (t.TafType=0 AND vDet.SiPubPersonsSpec1=t.SiTaf) OR (t.TafType=1 AND vDet.SiPubCostCenter1=t.SiTaf) OR (t.TafType=2 AND vDet.SiPubProjects1=t.SiTaf))';
    ELSE
        IF ISNULL(@SiSelected, '') <> ''
           AND @TafName IS NOT NULL
            SET @TafFilter = ' AND vDet.' + @TafName + ' = ' + @SiSelected;
    DECLARE @AccAllDocs AS SMALLINT = dbo.Tss_StdFindSystemParamValue('AccAllDocs');
    DECLARE @HiddenFilter AS VARCHAR (500);
    IF dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'AccStar') = 1
        SET @HiddenFilter = '';
    ELSE
        SET @HiddenFilter = ' AND (vDet.Sta_IsHidden = 0 OR vDet.Sta_IsHidden IS NULL) ';
    SELECT SiAccFinancePeriodToPlace
    INTO   #TempTable
    FROM   dbo.Tss_AccFinancePeriodToPlace
    WHERE  SiPubSubLocations IN (SELECT *
                                 FROM   dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations));
    -- -------------------------------------------------------------------
    -- #TmpVchTaf: filtered voucher lines for the requested date range
    -- -------------------------------------------------------------------
    CREATE TABLE #TmpVchTaf (
        SiAccVoucher_Hd NUMERIC NULL,
        Dat_VhedDate VARCHAR (10) NULL,
        Num_VDetRow INT NULL,
        Des_VdetDesc NVARCHAR (4000) NULL,
        Num_VdetDebtAmount BIGINT NULL,
        Num_VdetCreditAmount BIGINT NULL,
        Num_VhedFinalNo DECIMAL (18, 0) NULL,
        Num_VhedSubNo INT NULL, -- ← تغییر: numeric → INT
        Cod_AccountCode VARCHAR (50) NULL,
        Des_AccountDesc NVARCHAR (200) NULL,
        TafCode VARCHAR (50) NULL,
        TafName NVARCHAR (401) NULL
    );
    DECLARE @StatusFilter AS VARCHAR (100) = CASE WHEN @AccAllDocs = 0 THEN 'vHed.Sta_VochStatus >= 3 AND vHed.Sta_VochStatus <> 5 AND ' ELSE 'vHed.Sta_VochStatus >= 3 AND ' END;
    DECLARE @SqlTxt AS NVARCHAR (MAX) = N'
    SELECT
        vHed.SiAccVoucher_Hd,
        vHed.Dat_VhedDate,
        vDet.Num_VDetRow,
        Des_VdetDesc = CAST(CASE WHEN Tss_AccVoucherType.Sta_VoucherTypeGroup IN (4,5)
                                 THEN ISNULL(vDet.Des_VdetDesc,'''')
                                 ELSE vDet.Des_VdetDesc
                            END AS NVARCHAR(4000)),
        CAST(vDet.Num_VdetDebtAmount   AS BIGINT) AS Num_VdetDebtAmount,
        CAST(vDet.Num_VdetCreditAmount AS BIGINT) AS Num_VdetCreditAmount,
        CAST(vHed.Num_VhedFinalNo      AS DECIMAL(18,0)) AS Num_VhedFinalNo,
        CAST(vHed.Num_VhedSubNo        AS INT)           AS Num_VhedSubNo,   -- ← تغییر: INT
        CAST(cBook.Cod_AccountCode     AS VARCHAR(50))   AS Cod_AccountCode,
        CAST(cBook.Des_AccountDesc     AS NVARCHAR(200)) AS Des_AccountDesc,
        CAST(COALESCE(pv.Cod_PubPersonCode, cc.Cod_CostCenterCode, pr.Cod_ProjectsCode, '''') AS VARCHAR(50)) AS TafCode,
        CAST(COALESCE(pv.Des_FullName, cc.Des_CostCenterName, pr.Des_ProjectsThemeDesc, '''') AS NVARCHAR(401)) AS TafName
    FROM Tss_AccCodeBook cBook
    INNER JOIN Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook
    INNER JOIN Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
    INNER JOIN Tss_AccVoucherType   ON vHed.SiAccVoucherType = Tss_AccVoucherType.SiAccVoucherType
    LEFT JOIN Tss_PubPersonsViw pv ON vDet.SiPubPersonsSpec1 = pv.SiPubPersonsSpec
    LEFT JOIN Tss_PubCostCenter cc ON vDet.SiPubCostCenter1 = cc.SiPubCostCenter
    LEFT JOIN Tss_PubProjects   pr ON vDet.SiPubProjects1   = pr.SiPubProjects
    WHERE ' + @StatusFilter + N'
        vHed.SiAccFinancePeriodToPlace IN (SELECT SiAccFinancePeriodToPlace FROM #TempTable)
        AND vHed.Dat_VhedDate BETWEEN ''' + @DsFromDate + N''' AND ''' + @DsToDate + N'''
        ' + @AccFilter + N'
        ' + @TafFilter + N'
        ' + @HiddenFilter + N'
        ' + @WhType;
    -- Combine the two optional WHERE wrappers into a single clause
    DECLARE @CombinedWhere AS VARCHAR (MAX) = '';
    IF @InternalWhere <> ''
       AND @Where <> ''
        SET @CombinedWhere = @InternalWhere + ' AND ' + SUBSTRING(@Where, 8, LEN(@Where));
    ELSE
        IF @InternalWhere <> ''
            SET @CombinedWhere = @InternalWhere;
        ELSE
            SET @CombinedWhere = @Where;
    -- NOTE: no ORDER BY inside INSERT
    DECLARE @InsertSql AS NVARCHAR (MAX) = N'
    INSERT INTO #TmpVchTaf
    SELECT * FROM (' + @SqlTxt + N') AS Ccc
    ' + @CombinedWhere;
    BEGIN TRY
        EXECUTE sp_executesql @InsertSql;
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting into #TmpVchTaf: ' + ERROR_MESSAGE();
    END CATCH
    -- -------------------------------------------------------------------
    -- #TmpVchTafMandeh: opening balance (before @DsFromDate)
    -- -------------------------------------------------------------------
    CREATE TABLE #TmpVchTafMandeh (
        Num_VdetDebtAmount BIGINT NULL,
        Num_VdetCreditAmount BIGINT NULL
    );
    DECLARE @SqlTxtMandeh AS NVARCHAR (MAX) = N'
    SELECT
        CAST(SUM(vDet.Num_VdetDebtAmount)   AS BIGINT) AS Num_VdetDebtAmount,
        CAST(SUM(vDet.Num_VdetCreditAmount) AS BIGINT) AS Num_VdetCreditAmount
    FROM Tss_AccCodeBook cBook
    INNER JOIN Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook
    INNER JOIN Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
    WHERE ' + @StatusFilter + N'
        vHed.SiAccFinancePeriodToPlace IN (SELECT SiAccFinancePeriodToPlace FROM #TempTable)
        AND vHed.Dat_VhedDate BETWEEN ''1385/01/01'' AND ''' + dbo.Tss_StdOneDayDecUdf(@DsFromDate) + N'''
        ' + @AccFilter + N'
        ' + @TafFilter + N'
        ' + @HiddenFilter + N'
        ' + @WhType;
    DECLARE @InsertMandehSql AS NVARCHAR (MAX) = N'
    INSERT INTO #TmpVchTafMandeh
    SELECT * FROM (' + @SqlTxtMandeh + N') AS Ccc';
    BEGIN TRY
        EXECUTE sp_executesql @InsertMandehSql;
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting into #TmpVchTafMandeh: ' + ERROR_MESSAGE();
    END CATCH
    -- -------------------------------------------------------------------
    -- #TmpVchTafBaBiMandeh: opening row + in-range rows
    -- -------------------------------------------------------------------
    CREATE TABLE #TmpVchTafBaBiMandeh (
        SiAccVoucher_Hd NUMERIC NULL,
        Dat_VhedDate VARCHAR (10) NULL,
        Num_VDetRow INT NULL,
        Des_VdetDesc NVARCHAR (4000) NULL,
        Num_VdetDebtAmount BIGINT NULL,
        Num_VdetCreditAmount BIGINT NULL,
        Num_VhedFinalNo DECIMAL (18, 0) NULL,
        Num_VhedSubNo INT NULL, -- ← تغییر: numeric → INT
        Cod_AccountCode VARCHAR (50) NULL,
        Des_AccountDesc NVARCHAR (200) NULL,
        TafCode VARCHAR (50) NULL,
        TafName NVARCHAR (401) NULL
    );
    DECLARE @SqlTxtBaBiMandeh AS NVARCHAR (MAX);
    IF @StaMandehOrNot = 1
        BEGIN
            SET @SqlTxtBaBiMandeh = N'
        SELECT
            CAST(0 AS NUMERIC)        AS SiAccVoucher_Hd,
            CAST('''' AS VARCHAR(10)) AS Dat_VhedDate,
            0                         AS Num_VDetRow,
            CAST(N''مانده از قبل'' AS NVARCHAR(4000)) AS Des_VdetDesc,
            CAST(ISNULL(Num_VdetDebtAmount, 0)   AS BIGINT) AS Num_VdetDebtAmount,
            CAST(ISNULL(Num_VdetCreditAmount, 0) AS BIGINT) AS Num_VdetCreditAmount,
            CAST(0 AS DECIMAL(18,0))  AS Num_VhedFinalNo,
            CAST(0 AS INT)            AS Num_VhedSubNo,   -- ← تغییر: INT
            CAST('''' AS VARCHAR(50)) AS Cod_AccountCode,
            CAST('''' AS NVARCHAR(200)) AS Des_AccountDesc,
            CAST('''' AS VARCHAR(50)) AS TafCode,
            CAST('''' AS NVARCHAR(401)) AS TafName
        FROM #TmpVchTafMandeh
        UNION ALL
        SELECT
            SiAccVoucher_Hd, Dat_VhedDate, Num_VDetRow, Des_VdetDesc,
            Num_VdetDebtAmount, Num_VdetCreditAmount, Num_VhedFinalNo, Num_VhedSubNo,
            Cod_AccountCode, Des_AccountDesc, TafCode, TafName
        FROM #TmpVchTaf';
        END
    ELSE
        BEGIN
            SET @SqlTxtBaBiMandeh = N'
        SELECT
            SiAccVoucher_Hd, Dat_VhedDate, Num_VDetRow, Des_VdetDesc,
            Num_VdetDebtAmount, Num_VdetCreditAmount, Num_VhedFinalNo, Num_VhedSubNo,
            Cod_AccountCode, Des_AccountDesc, TafCode, TafName
        FROM #TmpVchTaf';
        END
    DECLARE @InsertCombineSql AS NVARCHAR (MAX) = N'
    INSERT INTO #TmpVchTafBaBiMandeh
    SELECT * FROM (' + @SqlTxtBaBiMandeh + N') AS Ccc
    ' + @CombinedWhere;
    BEGIN TRY
        EXECUTE sp_executesql @InsertCombineSql;
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting into #TmpVchTafBaBiMandeh: ' + ERROR_MESSAGE();
    END CATCH -- -------------------------------------------------------------------
     -- Final result: running balance over the ordered set
     -- -------------------------------------------------------------------
    WITH     FinalData
    AS       (SELECT CAST (ROW_NUMBER() OVER (ORDER BY Dat_VhedDate, SiAccVoucher_Hd, Num_VDetRow) AS DECIMAL (18, 0)) AS MyId,
                     SiAccVoucher_Hd,
                     CAST (Num_VhedFinalNo AS DECIMAL (18, 0)) AS Num_VhedFinalNo,
                     CAST (Num_VhedSubNo AS INT) AS Num_VhedSubNo, -- ← تغییر: INT
                     Dat_VhedDate,
                     LEFT(Dat_VhedDate, 7) AS Dat_VhedDateMonth,
                     Num_VDetRow,
                     Des_VdetDesc,
                     CAST (Num_VdetDebtAmount AS BIGINT) AS Num_VdetDebtAmount,
                     CAST (Num_VdetCreditAmount AS BIGINT) AS Num_VdetCreditAmount,
                     CAST (Num_VdetDebtAmount - Num_VdetCreditAmount AS BIGINT) AS Acc_Rest,
                     Cod_AccountCode,
                     Des_AccountDesc,
                     TafCode,
                     TafName
              FROM   #TmpVchTafBaBiMandeh),
             RunningSum
    AS       (SELECT *,
                     SUM(Acc_Rest) OVER (ORDER BY MyId ROWS UNBOUNDED PRECEDING) AS Acc_Rest_Sum
              FROM   FinalData)
    SELECT   MyId,
             SiAccVoucher_Hd,
             Num_VhedFinalNo,
             Num_VhedSubNo,
             Dat_VhedDate,
             Dat_VhedDateMonth,
             Num_VDetRow,
             Des_VdetDesc,
             Num_VdetDebtAmount,
             Num_VdetCreditAmount,
             Acc_Rest,
             Acc_Rest_Sum,
             Cod_AccountCode,
             Des_AccountDesc,
             TafCode,
             TafName
    FROM     RunningSum
    ORDER BY MyId;
    DROP TABLE IF EXISTS #TempTable;
    DROP TABLE IF EXISTS #TmpVchTaf;
    DROP TABLE IF EXISTS #TmpVchTafMandeh;
    DROP TABLE IF EXISTS #TmpVchTafBaBiMandeh;
    DROP TABLE IF EXISTS #Pfx;
    DROP TABLE IF EXISTS #Taf;
END


GO
ALTER PROCEDURE Tss_PubUntBankVStp
@InternalWhere VARCHAR (8000)='', @Where VARCHAR (8000)='', @Order VARCHAR (8000)=''
AS
IF @InternalWhere <> ''
    SET @InternalWhere = ' Where ' + @InternalWhere;
IF @Where <> ''
    SET @Where = ' Where ' + @Where;
IF @Order <> ''
    SET @Order = ' Order By ' + @Order;
EXECUTE ('Select * From
(
   Select * From
   (
   SELECT 
		pBank.Des_CodeDescription,
		pBank.SiPubPersonsSpec, 
		pBank.Cod_PubPersonCode, 
		pBank.Des_PubPersonName1, 
		pBank.Des_PersonAddress, 
		pBank.Des_PersonPhons, 
		pBank.Des_Person_FaxNo, 
		pBank.SiPubGeoPlacCity, 
		pBank.Cod_BankDefAccountCode, 
		pBank.Cod_BankDefBranchCode, 
		pBank.Num_BankDefMaxPayment, 
		pBank.Num_BankDefCashInStart, 
		pBank.Dat_BankDefAccRegDate, 
		pBank.Dat_BankDefAccCloseDate, 
		dbo.Tss_PubGeoPlac.Cod_GeoPlaceCode, 
		dbo.Tss_PubGeoPlac.Des_GeoPlaceName, 
		pBank.Sta_PubPersonsGroup, 
		pBank.StmPubPersonsSpec, 
		pBank.SiPubCustomCodesBankType, 
		BankTp.Cod_CustomCodesCode, 
		BankTp.Des_CustomCodesDesc,
		pBank.Dat_BankFristMoney, 
		pBank.Num_BankFirstMoney,
		pBank.Des_BankAccountOwnerName, 
		Tss_PubSubLocations.Cod_SubLocCode, 
		Tss_PubSubLocations.Des_SubLocName, 
        pBank.SiPubSubLocations,
		pBank.Des_AccountSheba,
		pBank.Des_AccountOwnerNationalCode,
		pBank.Des_AccountRegisterNo,
		pBank.Des_AccountOwnerAddress,
		pBank.Des_AccountOwnerTel
FROM        
	Tss_PubSubLocations RIGHT OUTER JOIN
	Tss_PubPersonsSpec AS pBank ON Tss_PubSubLocations.SiPubSubLocations = pBank.SiPubSubLocations LEFT OUTER JOIN
	Tss_PubCustomCodes AS BankTp ON pBank.SiPubCustomCodesBankType = BankTp.SiPubCustomCodes LEFT OUTER JOIN
	Tss_PubGeoPlac ON pBank.SiPubGeoPlacCity = Tss_PubGeoPlac.SiPubGeoPlac
WHERE     
	(pBank.Sta_PubPersonsGroup = 5)
   ) Ccc  ' + @InternalWhere + '
) CalcSel ' + @Where + @Order);


GO
-- 1) Des_AccountSheba
IF NOT EXISTS (SELECT 1
               FROM   sys.columns
               WHERE  object_id = OBJECT_ID(N'dbo.Tss_PubPersonsSpec')
                      AND name = N'Des_AccountSheba')
    BEGIN
        ALTER TABLE [dbo].[Tss_PubPersonsSpec]
            ADD [Des_AccountSheba] VARCHAR (200) NULL;
        PRINT 'Added column: Des_AccountSheba';
    END
ELSE
    PRINT 'Column already exists, skipped: Des_AccountSheba';


GO
-- 2) Des_AccountOwnerNationalCode
IF NOT EXISTS (SELECT 1
               FROM   sys.columns
               WHERE  object_id = OBJECT_ID(N'dbo.Tss_PubPersonsSpec')
                      AND name = N'Des_AccountOwnerNationalCode')
    BEGIN
        ALTER TABLE [dbo].[Tss_PubPersonsSpec]
            ADD [Des_AccountOwnerNationalCode] VARCHAR (50) NULL;
        PRINT 'Added column: Des_AccountOwnerNationalCode';
    END
ELSE
    PRINT 'Column already exists, skipped: Des_AccountOwnerNationalCode';


GO
-- 3) Des_AccountRegisterNo
IF NOT EXISTS (SELECT 1
               FROM   sys.columns
               WHERE  object_id = OBJECT_ID(N'dbo.Tss_PubPersonsSpec')
                      AND name = N'Des_AccountRegisterNo')
    BEGIN
        ALTER TABLE [dbo].[Tss_PubPersonsSpec]
            ADD [Des_AccountRegisterNo] VARCHAR (50) NULL;
        PRINT 'Added column: Des_AccountRegisterNo';
    END
ELSE
    PRINT 'Column already exists, skipped: Des_AccountRegisterNo';


GO
-- 4) Des_AccountOwnerAddress
IF NOT EXISTS (SELECT 1
               FROM   sys.columns
               WHERE  object_id = OBJECT_ID(N'dbo.Tss_PubPersonsSpec')
                      AND name = N'Des_AccountOwnerAddress')
    BEGIN
        ALTER TABLE [dbo].[Tss_PubPersonsSpec]
            ADD [Des_AccountOwnerAddress] VARCHAR (2000) NULL;
        PRINT 'Added column: Des_AccountOwnerAddress';
    END
ELSE
    PRINT 'Column already exists, skipped: Des_AccountOwnerAddress';


GO
-- 5) Des_AccountOwnerTel
IF NOT EXISTS (SELECT 1
               FROM   sys.columns
               WHERE  object_id = OBJECT_ID(N'dbo.Tss_PubPersonsSpec')
                      AND name = N'Des_AccountOwnerTel')
    BEGIN
        ALTER TABLE [dbo].[Tss_PubPersonsSpec]
            ADD [Des_AccountOwnerTel] VARCHAR (50) NULL;
        PRINT 'Added column: Des_AccountOwnerTel';
    END
ELSE
    PRINT 'Column already exists, skipped: Des_AccountOwnerTel';


GO
ALTER PROCEDURE Tss_PubUntBankIudStp
@Err_Code INT OUTPUT, @SiPubPersonsSpec NUMERIC OUTPUT, @SiPubGeoPlacCity NUMERIC=NULL, @SiPubCustomCodesBankType NUMERIC=NULL, @Cod_PubPersonCode VARCHAR (50)='', @Des_PubPersonName1 VARCHAR (200)='', @Des_PersonAddress VARCHAR (200)='', @Des_PersonPhons VARCHAR (200)='', @Des_Person_FaxNo VARCHAR (200)='', @Cod_BankDefAccountCode VARCHAR (50)='', @Cod_BankDefBranchCode VARCHAR (50)='', @Num_BankDefMaxPayment NUMERIC=0, @Num_BankDefCashInStart NUMERIC=0, @Dat_BankDefAccRegDate VARCHAR (10)='', @Dat_BankDefAccCloseDate VARCHAR (10)='', @Dat_BankFristMoney VARCHAR (10)='', @Num_BankFirstMoney NUMERIC=0, @Des_BankAccountOwnerName VARCHAR (500)='', @SiPubSubLocations NUMERIC=NULL, @Des_CodeDescription VARCHAR (2000)='', @Des_AccountSheba VARCHAR (200)='', @Des_AccountOwnerNationalCode VARCHAR (50)='', @Des_AccountRegisterNo VARCHAR (50)='', @Des_AccountOwnerAddress VARCHAR (2000)='', @Des_AccountOwnerTel VARCHAR (50)='', @StmPubPersonsSpec TIMESTAMP=0, @SiUser NUMERIC, @FlgInsUpdDel SMALLINT
AS
DECLARE @Sta_PubPersonsGroup AS SMALLINT;
SET @Sta_PubPersonsGroup = 5;
IF @FlgInsUpdDel = 0
    BEGIN
        INSERT  INTO dbo.Tss_PubPersonsSpec (SiPubGeoPlacCity, SiPubCustomCodesBankType, Cod_PubPersonCode, Des_PubPersonName1, Des_PersonAddress, Des_PersonPhons, Des_Person_FaxNo, Sta_PubPersonsGroup, Cod_BankDefAccountCode, Cod_BankDefBranchCode, Num_BankDefMaxPayment, Num_BankDefCashInStart, Dat_BankDefAccRegDate, Dat_BankDefAccCloseDate, Dat_BankFristMoney, Num_BankFirstMoney, Des_BankAccountOwnerName, Sta_Enable, SiPubSubLocations, Des_CodeDescription, Des_AccountSheba, Des_AccountOwnerNationalCode, Des_AccountRegisterNo, Des_AccountOwnerAddress, Des_AccountOwnerTel)
        VALUES                             (@SiPubGeoPlacCity, @SiPubCustomCodesBankType, @Cod_PubPersonCode, @Des_PubPersonName1, @Des_PersonAddress, @Des_PersonPhons, @Des_Person_FaxNo, @Sta_PubPersonsGroup, @Cod_BankDefAccountCode, @Cod_BankDefBranchCode, @Num_BankDefMaxPayment, @Num_BankDefCashInStart, @Dat_BankDefAccRegDate, @Dat_BankDefAccCloseDate, @Dat_BankFristMoney, @Num_BankFirstMoney, @Des_BankAccountOwnerName, 0, @SiPubSubLocations, @Des_CodeDescription, @Des_AccountSheba, @Des_AccountOwnerNationalCode, @Des_AccountRegisterNo, @Des_AccountOwnerAddress, @Des_AccountOwnerTel);
        SET @SiPubPersonsSpec = Scope_Identity();
        IF IsNull(@SiPubPersonsSpec, 0) = 0
            BEGIN
                SET @SiPubPersonsSpec = 0;
                SET @Err_Code = 400;
            END
        RETURN;
    END
IF @FlgInsUpdDel = 1
    BEGIN
        SET @Err_Code = 0;
        IF EXISTS (SELECT StmPubPersonsSpec
                   FROM   dbo.Tss_PubPersonsSpec
                   WHERE  (SiPubPersonsSpec = @SiPubPersonsSpec)
                          AND (StmPubPersonsSpec = @StmPubPersonsSpec))
            BEGIN
                UPDATE dbo.Tss_PubPersonsSpec
                SET    SiPubCustomCodesBankType     = @SiPubCustomCodesBankType,
                       SiPubGeoPlacCity             = @SiPubGeoPlacCity,
                       Cod_PubPersonCode            = @Cod_PubPersonCode,
                       Des_PubPersonName1           = @Des_PubPersonName1,
                       Des_PersonAddress            = @Des_PersonAddress,
                       Des_PersonPhons              = @Des_PersonPhons,
                       Des_Person_FaxNo             = @Des_Person_FaxNo,
                       Cod_BankDefAccountCode       = @Cod_BankDefAccountCode,
                       Cod_BankDefBranchCode        = @Cod_BankDefBranchCode,
                       Num_BankDefMaxPayment        = @Num_BankDefMaxPayment,
                       Num_BankDefCashInStart       = @Num_BankDefCashInStart,
                       Dat_BankDefAccRegDate        = @Dat_BankDefAccRegDate,
                       Dat_BankDefAccCloseDate      = @Dat_BankDefAccCloseDate,
                       Dat_BankFristMoney           = @Dat_BankFristMoney,
                       Num_BankFirstMoney           = @Num_BankFirstMoney,
                       Des_BankAccountOwnerName     = @Des_BankAccountOwnerName,
                       SiPubSubLocations            = @SiPubSubLocations,
                       Des_CodeDescription          = @Des_CodeDescription,
                       Des_AccountSheba             = @Des_AccountSheba,
                       Des_AccountOwnerNationalCode = @Des_AccountOwnerNationalCode,
                       Des_AccountRegisterNo        = @Des_AccountRegisterNo,
                       Des_AccountOwnerAddress      = @Des_AccountOwnerAddress,
                       Des_AccountOwnerTel          = @Des_AccountOwnerTel
                WHERE  (SiPubPersonsSpec = @SiPubPersonsSpec);
                SET @Err_Code = @@Error;
                IF @Err_Code <> 0
                    SET @Err_Code = 401;
                RETURN;
            END
        ELSE
            SET @Err_Code = 402;
    END
IF @FlgInsUpdDel = 2
    BEGIN
        SET @Err_Code = 0;
        IF EXISTS (SELECT StmPubPersonsSpec
                   FROM   dbo.Tss_PubPersonsSpec
                   WHERE  (SiPubPersonsSpec = @SiPubPersonsSpec)
                          AND (StmPubPersonsSpec = @StmPubPersonsSpec))
            BEGIN
                DELETE dbo.Tss_PubPersonsSpec
                WHERE  (SiPubPersonsSpec = @SiPubPersonsSpec);
                SET @Err_Code = @@Error;
                IF @Err_Code <> 0
                    SET @Err_Code = 4000;
            END
        ELSE
            SET @Err_Code = 4000;
        RETURN;
    END