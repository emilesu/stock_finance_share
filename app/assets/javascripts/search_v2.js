jQuery(function () {
     var stocks = [
       
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
