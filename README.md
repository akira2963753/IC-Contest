## IC-Contest : 

歷屆試題皆可從官網上下載  
https://proj.moe.edu.tw/moeisoc/cl.aspx?n=6129  

### Some tips for improving your RTL Code :   
1. 盡量不要使用大於、小於，會增加邏輯單元。  
2. 盡量減少Register的長度。  
3. 盡量使用Case語句，而不是If,else(優先級編碼可能會增加邏輯複雜度)。  
4. 盡量不要使用除法(很佔面積)，除2的幕次方可以使用位移技巧來取代(當然乘法也可以)。  
5. 取餘數的話可以使用這個技巧，a = b % 16 => a = b[3:0]
