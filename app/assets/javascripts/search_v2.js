jQuery(function () {
     var stocks = [
        "AAPL - 苹果", 
        "AMZN - 亚马逊",
        "MSFT - 微软",
        "GOOGL - 谷歌A",
        "GOOG - 谷歌",
        "HSEA - HSBC Holdings PLC",
        "FB - Facebook",
        "BSMX - 桑坦德银行墨西",
        "BABA - 阿里巴巴",
        "BRK.B - 伯克希尔-哈撒韦B",
        "BRK.A - 伯克希尔-哈撒韦A",
        "JPM - 摩根大通",
        "DEO - 帝亚吉欧",
        "XOM - 埃克森美孚",
        "JNJ - 强生",
        "BAC - 美国银行",
        "FMX - Fomento Economico Mexicano S.A.B",
        "RDS.B - RDS_B",
        "V - Visa",
        "RDS.A - RDS_A",
        "ENIC - Enersis Chile S.A.",
        "WFC - 富国银行",
        "INTC - 英特尔",
        "HDB - HDFC银行",
        "WMT - 沃尔玛",
        "LYG - 劳埃德",
        "BBL - 必和必拓",
        "UNH - 联合健康",
        "CVX - 雪佛龙",
        "FFEU - Barclays ETN+ FI Enhanced Europe 50 ETN Series C",
        "FIYY - Barclays PLC",
        "PFE - 辉瑞",
        "HD - 家得宝",
        "BA - 波音",
        "TM - 丰田汽车",
        "CSCO - 思科",
        "TSM - 台积电",
        "NGG - National Grid PLC",
        "VZ - 威瑞森",
        "NVS - 诺华",
     ];

     var substringMatcher = function (strs) {
         return function findMatches(q, cb) {
             var matches, substrRegex;
             matches = [];//定义字符串数组
             substrRegex = new RegExp(q, 'i');
             //用正则表达式来确定哪些字符串包含子串的'q'
             $.each(strs, function (i, str) {
             //遍历字符串池中的任何字符串
                 if (substrRegex.test(str)) {
                     matches.push({ value: str });
                 }
             //包含子串的'q',将它添加到'match'
             });
             cb(matches);
         };
     };

     $('#search-v2').typeahead({
        hint: true,
        highlight: true,
        minLength: 1
     },
     {
        name: 'stocks',
        displayKey: 'value',
        source: substringMatcher(stocks)
     });

 });
